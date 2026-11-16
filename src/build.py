#!/usr/bin/env python3
"""xNgot Library - build script (python3, không cần thư viện ngoài).

Cách dùng:
    python3 src/build.py                     # build dev   -> dist/xngot_studio.lua
    python3 src/build.py --release           # build phát hành -> dist/main.lua
    python3 src/build.py --release --minify  # + bản minify (single) -> dist/main.min.lua
    python3 src/build.py --minify light      # nhẹ tay: chỉ bỏ comment
    python3 src/build.py --minify full       # đổi tên định danh + dồn 1 dòng
    python3 src/build.py --check             # kiểm tra module, không ghi gì
    python3 src/build.py --stats             # bảng thống kê module
    python3 src/build.py --out path.lua      # đổi đường dẫn xuất
    python3 src/build.py --tag-modules       # chèn 1 dòng `-- [module]` giữa các module
    python3 src/build.py --verify-source "main 2.txt"   # đối chiếu bản gốc từng byte
    python3 src/build.py --quiet             # không in gì, chỉ exit code

Các module trong src/modules/** là source duy trì hiện tại. Manifest lưu thứ tự,
hash và thông tin lịch sử; sau khi sửa module, --verify-source có thể không còn
khớp bản gốc. --check kiểm tra hash và cân bằng khối của bản hiện tại.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import hashlib
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import minify as _minify  # noqa: E402

ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(ROOT)
MANIFEST_PATH = os.path.join(ROOT, "manifest.json")
MODULES_DIR = os.path.join(ROOT, "modules")
PROFILE_DIR = os.path.join(ROOT, "profiles")

BANNER_RE = re.compile(r"\A--\[\[ xngot-studio [^\n]*\n.*?\n--\]\]\n", re.S)
OPEN_TOKENS = ("function", "if", "do", "repeat")
CLOSE_TOKENS = ("end", "until")
LONG_COMMENT = re.compile(r"--\[(=*)\[")
LONG_STRING = re.compile(r"\[(=*)\[")


class Colors:
    on = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None

    @classmethod
    def wrap(cls, code: str, text: str) -> str:
        return "\033[%sm%s\033[0m" % (code, text) if cls.on else text

    @classmethod
    def ok(cls, text: str) -> str:
        return cls.wrap("32", text)

    @classmethod
    def warn(cls, text: str) -> str:
        return cls.wrap("33", text)

    @classmethod
    def err(cls, text: str) -> str:
        return cls.wrap("31", text)

    @classmethod
    def dim(cls, text: str) -> str:
        return cls.wrap("90", text)


class LuaScan:
    """Quét token mở/đóng khối, bỏ qua chuỗi và comment (đủ dùng cho Luau)."""

    def __init__(self) -> None:
        self.long = None
        self.eq = 0
        self.quote = ""

    def tokens(self, line: str) -> list[str]:
        out: list[str] = []
        i, n = 0, len(line)
        while i < n:
            if self.long is not None:
                closer = "]" + "=" * self.eq + "]"
                j = line.find(closer, i)
                if j < 0:
                    return out
                i = j + len(closer)
                self.long = None
                continue
            if self.quote:
                q = self.quote
                while i < n:
                    c = line[i]
                    if c == "\\":
                        i += 2
                        continue
                    if c == q:
                        i += 1
                        self.quote = ""
                        break
                    i += 1
                continue
            c = line[i]
            if c == "-" and line.startswith("--", i):
                m = LONG_COMMENT.match(line, i)
                if not m:
                    return out
                self.eq = len(m.group(1))
                self.long = "comment"
                i = m.end()
                continue
            if c == "[":
                m = LONG_STRING.match(line, i)
                if m:
                    self.eq = len(m.group(1))
                    self.long = "string"
                    i = m.end()
                    continue
                i += 1
                continue
            if c in "\"'`":
                self.quote = c
                i += 1
                continue
            if c.isalpha() or c == "_":
                j = i
                while j < n and (line[j].isalnum() or line[j] == "_"):
                    j += 1
                word = line[i:j]
                if word in OPEN_TOKENS or word in CLOSE_TOKENS:
                    out.append(word)
                i = j
                continue
            i += 1
        if self.quote:
            self.quote = ""
        return out


def do_khoi(text: str) -> int:
    scan = LuaScan()
    depth = 0
    for line in text.split("\n"):
        for token in scan.tokens(line):
            depth += 1 if token in OPEN_TOKENS else -1
    return depth


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def load_manifest() -> dict:
    with open(MANIFEST_PATH, encoding="utf-8") as fh:
        return json.load(fh)


def load_profile(name: str) -> dict:
    if name == "dev":
        return {"name": "dev", "replace": {}, "tag": False}
    path = os.path.join(PROFILE_DIR, name + ".json")
    if not os.path.exists(path):
        sys.exit(Colors.err("profile không tồn tại: %s" % path))
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
    data.setdefault("name", name)
    data.setdefault("replace", {})
    data.setdefault("tag", False)
    return data


def read_module(rel: str) -> str:
    path = os.path.join(MODULES_DIR, rel)
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def strip_banner(text: str) -> str:
    if not BANNER_RE.match(text):
        raise ValueError("thiếu banner đầu tệp")
    return BANNER_RE.sub("", text, count=1)


def collect(manifest: dict, profile: dict) -> list[dict]:
    items = []
    for mod in manifest["modules"]:
        rel = mod["path"]
        text = read_module(rel)
        stub = profile["replace"].get(mod["id"])
        if stub:
            with open(os.path.join(ROOT, stub), encoding="utf-8") as fh:
                stub_text = fh.read()
            body = strip_banner(stub_text) if BANNER_RE.match(stub_text) else stub_text
            items.append({"mod": mod, "path": stub, "body": body, "stub": True})
            continue
        try:
            # The copyright header is already the first payload; it has no module banner.
            body = text if mod["id"] == "header.banner" else strip_banner(text)
        except ValueError as exc:
            sys.exit(Colors.err("%s: %s" % (rel, exc)))
        items.append({"mod": mod, "path": rel, "body": body, "stub": False})
    return items


def check(items: list[dict], manifest: dict, profile: dict) -> list[str]:
    errors = []
    depth = 0
    last = len(items) - 1
    for index, item in enumerate(items):
        mod, body = item["mod"], item["body"]
        if item["stub"]:
            delta = do_khoi(body)
            if delta != 0:
                errors.append("%s: module thay thế lệch khối %+d" % (item["path"], delta))
            depth += delta
            continue
        if body.count("--[[ xngot-studio") != 0:
            errors.append("%s: banner lặp trong thân tệp" % item["path"])
        digest = sha256(body)
        if digest != mod["sha256"]:
            errors.append("%s: sha256 lệch (manifest %s…, thực tế %s…)"
                          % (item["path"], mod["sha256"][:12], digest[:12]))
        delta = do_khoi(body)
        if delta != mod["delta"]:
            errors.append("%s: độ lệch khối %+d, manifest ghi %+d"
                          % (item["path"], delta, mod["delta"]))
        depth += delta
        if depth < 0:
            errors.append("%s: đóng khối quá tay (tổng %d)" % (item["path"], depth))
            depth = 0
        if index != last:
            scan = LuaScan()
            running = depth - delta
            for no, line in enumerate(body.split("\n"), 0):
                if running == 0 and re.match(r"^\s*return\b", line):
                    errors.append("%s: có `return` ở cấp ngoài cùng (dòng %d) - sẽ cắt chunk"
                                  % (item["path"], mod["from"] + no))
                    break
                for token in scan.tokens(line):
                    running += 1 if token in OPEN_TOKENS else -1
    if depth != 0:
        errors.append("tổng độ lệch khối cuối file = %+d (phải bằng 0)" % depth)
    if not items:
        errors.append("không có module nào")
    if profile["name"] != "dev":
        stubbed = [i["mod"]["id"] for i in items if i["stub"]]
        if stubbed:
            print(Colors.dim("  thay thế ở profile %s: %s" % (profile["name"], ", ".join(stubbed))))
    return errors


def assemble(items: list[dict], tag: bool) -> str:
    parts = []
    for item in items:
        if tag:
            parts.append("-- [%s]\n" % item["mod"]["id"])
        parts.append(item["body"])
    return "".join(parts)


def apply_source_transforms(text: str, transforms: dict) -> str:
    lines = text.split("\n")
    if lines and lines[-1] == "":
        lines = lines[:-1]
    dropped = set(int(n) for n in transforms.get("dropped_lines", []))
    replaced = {int(k): v for k, v in transforms.get("replaced_lines", {}).items()}
    out = []
    for no, line in enumerate(lines, 1):
        if no in dropped:
            continue
        out.append(replaced.get(no, line))
    return "\n".join(out) + "\n"


def verify_source(payload: str, source_path: str, manifest: dict) -> bool:
    with open(source_path, encoding="utf-8") as fh:
        source = fh.read()
    expected = apply_source_transforms(source, manifest["source_transforms"])
    if sha256(source) != manifest["source"]["sha256"]:
        print(Colors.warn("  cảnh báo: sha256 bản gốc khác manifest"))
    if payload == expected:
        print(Colors.ok("  ✔ verify-source: khớp từng byte (%d dòng)" % payload.count("\n")))
        return True
    want = expected.split("\n")
    got = payload.split("\n")
    for no, (a, b) in enumerate(zip(want, got), 1):
        if a != b:
            print(Colors.err("  ✘ lệch ở dòng %d:\n    gốc: %r\n    ra : %r" % (no, a[:100], b[:100])))
            break
    else:
        print(Colors.err("  ✘ số dòng khác nhau: gốc %d, ra %d" % (len(want), len(got))))
    return False


def build_header(manifest: dict, profile: dict, items: list[dict], payload_hash: str) -> str:
    flag = "" if profile["name"] == "dev" else " --" + profile["name"]
    return "\n".join([
        "-- xNgot Library · Thư viện UI (Roblox)",
        "--",
        "-- build   : python3 src/build.py%s" % flag,
        "-- profile : %s" % profile["name"],
        "-- version : %s" % manifest["version"],
        "-- modules : %d/%d" % (len(items), len(manifest["modules"])),
        "-- payload : %s" % payload_hash[:16],
        "--",
        "-- Sinh tự động từ src/modules/** - đừng sửa tay, sửa module rồi build lại.",
        "",
    ]) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(add_help=True, description="Build xNgot Library từ src/modules/**")
    parser.add_argument("--release", action="store_true", help="build profile release -> dist/main.lua")
    parser.add_argument("--profile", default=None, help="tên profile trong src/profiles/")
    parser.add_argument("--out", default=None, help="đường dẫn xuất")
    parser.add_argument("--check", action="store_true", help="chỉ kiểm tra")
    parser.add_argument("--stats", action="store_true", help="in thống kê module")
    parser.add_argument("--minify", nargs="?", const="single", default=None,
                        choices=["light", "compact", "single", "full"],
                        help="xuất thêm bản minify: single (mặc định, một dòng), light (giữ dòng), "
                             "compact (dồn dòng) hoặc full (đổi tên)")
    parser.add_argument("--no-rename", action="store_true",
                        help="giữ nguyên tên định danh kể cả khi chọn mức full")
    parser.add_argument("--tag-modules", action="store_true", help="chèn `-- [module]` giữa các module")
    parser.add_argument("--verify-source", default=None, metavar="PATH", help="đối chiếu bản gốc")
    parser.add_argument("--quiet", action="store_true", help="không in")
    args = parser.parse_args(argv)

    log = (lambda *a: None) if args.quiet else print
    manifest = load_manifest()
    profile = load_profile("release" if args.release else (args.profile or "dev"))
    items = collect(manifest, profile)

    errors = check(items, manifest, profile)
    if errors:
        for err in errors:
            print(Colors.err("  ✘ " + err))
        return 1

    payload = assemble(items, args.tag_modules or profile.get("tag", False))
    payload_hash = sha256(payload)

    if args.verify_source:
        ok = verify_source(payload, args.verify_source, manifest)
        if not ok:
            return 1

    if args.stats:
        groups: dict[str, int] = {}
        for item in items:
            groups[item["path"].split("/")[0]] = groups.get(item["path"].split("/")[0], 0) + item["mod"]["lines"]
        print("profile: %s · %d module · %d dòng" % (profile["name"], len(items), sum(groups.values())))
        for group, count in groups.items():
            print("  %-12s %6d dòng" % (group, count))

    if args.check:
        log(Colors.ok("✔ check  %d module hợp lệ (profile: %s)" % (len(items), profile["name"])))
        return 0

    entry = manifest["entry"] if profile["name"] == "dev" else manifest.get(
        "release_entry", manifest["entry"])
    out = args.out or os.path.join(REPO, "dist", entry)
    # Bản dev không có header: tệp xuất ra chính là bản gốc (chỉ khác 4 dòng đã ghi ở
    # đã ghi trong manifest), nên có thể `diff` với tệp gốc bất cứ lúc nào.
    header = "" if profile["name"] == "dev" else build_header(manifest, profile, items, payload_hash)
    # Keep the project's banner at the very beginning of every release.
    banner = items[0]["body"] if items and items[0]["mod"]["id"] == "header.banner" else ""
    if banner and payload.startswith(banner):
        bundle = banner + header + payload[len(banner):]
    else:
        bundle = header + payload
    # The release file uses the requested credit banner; keep the vendor notice in the source module.
    license_tokens = [tok.text for tok in _minify.tokenize(bundle)
                      if tok.kind == "comment" and "Ophyn UI / snowdev: MIT License" in tok.text]
    if len(license_tokens) != 1:
        raise ValueError("missing or ambiguous Ophyn license notice")
    license_notice = license_tokens[0]
    bundle = bundle.replace(license_notice, "", 1)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(bundle)

    lines = bundle.count("\n")
    size = len(bundle.encode("utf-8"))
    if not args.quiet:
        print(Colors.ok("✔ build  %s" % os.path.relpath(out, REPO))
              + Colors.dim("  ·  %d module · %d dòng · %d KB" % (len(items), lines, size // 1024)))

    if args.minify:
        base, ext = os.path.splitext(out)
        min_path = base + ".min" + ext
        seed = sha256(payload)[:16]
        result = _minify.minify(bundle, args.minify, seed=seed, rename=not args.no_rename)
        # Minification removes comments, so reinsert the requested banner.
        notice = banner if banner else ("--[[xNgot Library v%s · %s]]\n" % (manifest["version"], profile["name"]))
        with open(min_path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(notice + result["code"])
        if not args.quiet:
            pct = 100.0 * result["bytes"] / max(1, size)
            print(Colors.ok("✔ minify %s" % os.path.relpath(min_path, REPO))
                  + Colors.dim("  ·  %s · %d KB (%.1f%%) · %d dòng mã · %d tên đổi · %d token khớp"
                               % (args.minify, (result["bytes"] + len(notice)) // 1024, pct,
                                  result["code_lines"], result["renamed"],
                                  result["tokens"])))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
