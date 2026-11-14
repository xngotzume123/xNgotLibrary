#!/usr/bin/env python3
"""xNgot Library - kiểm chứng vòng tròn (round-trip) giữa bản gốc và repo.

Cách dùng:
    python3 tools/verify_roundtrip.py "main 2.txt" .

Bốn lớp kiểm chứng:
    A. PHỦ DÒNG      mỗi dòng 1..N của bản gốc thuộc đúng một module (hoặc thuộc 4 dòng đã bỏ)
    B. GHÉP LẠI      thân 150 module ghép theo manifest == bản gốc sau khi áp source_transforms
    C. BYTE          build 2 lần cho ra tệp giống hệt; dist hiện có trùng bản vừa build
    D. TÁI TẠO       chạy lại split_source.py vào thư mục tạm -> từng module khớp bản trong repo
"""
from __future__ import annotations

import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))


def load_build(repo: str):
    path = os.path.join(repo, "src", "build.py")
    spec = importlib.util.spec_from_file_location("xngot_build", path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    source, repo = sys.argv[1], sys.argv[2]
    build = load_build(repo)
    manifest = build.load_manifest()
    profile = build.load_profile("dev")
    items = build.collect(manifest, profile)

    with open(source, encoding="utf-8") as fh:
        original = fh.read()

    ok = True

    # ── A. phủ dòng ────────────────────────────────────────────────────────────
    covered: dict[int, str] = {}
    for mod in manifest["modules"]:
        for n in range(mod["from"], mod["to"] + 1):
            if n in covered:
                print("  ✘ A: dòng %d bị hai module chiếm (%s, %s)" % (n, covered[n], mod["path"]))
                ok = False
            covered[n] = mod["path"]
    dropped = set(manifest["source_transforms"]["dropped_lines"])
    missing = [n for n in range(1, manifest["source"]["lines"] + 1)
               if n not in covered and n not in dropped]
    if missing:
        print("  ✘ A: thiếu %d dòng, ví dụ %s" % (len(missing), missing[:8]))
        ok = False
    else:
        print("  ✔ A  phủ dòng: %d dòng nguồn phủ kín (%d dòng có trong module, %d dòng bỏ)"
              % (manifest["source"]["lines"], len(covered), len(dropped)))

    # ── B. ghép lại ───────────────────────────────────────────────────────────
    payload = build.assemble(items, False)
    expected = build.apply_source_transforms(original, manifest["source_transforms"])
    if payload == expected:
        print("  ✔ B  ghép lại: khớp từng byte (%d dòng)" % payload.count("\n"))
    else:
        print("  ✘ B  ghép lại: KHÔNG khớp")
        want, got = expected.split("\n"), payload.split("\n")
        for no, (a, b) in enumerate(zip(want, got), 1):
            if a != b:
                print("       dòng %d\n       gốc: %r\n       ra : %r" % (no, a[:90], b[:90]))
                break
        ok = False

    # ── C. byte & ổn định ─────────────────────────────────────────────────────
    tmp = tempfile.mkdtemp(prefix="xngot-verify-")
    try:
        first = os.path.join(tmp, "a.lua")
        second = os.path.join(tmp, "b.lua")
        for out in (first, second):
            code = subprocess.run([sys.executable, os.path.join(repo, "src", "build.py"),
                                   "--quiet", "--out", out],
                                  capture_output=True, text=True)
            if code.returncode != 0:
                print("  ✘ C  build lỗi:\n%s%s" % (code.stdout, code.stderr))
                ok = False
                break
        else:
            data_a = open(first, "rb").read()
            data_b = open(second, "rb").read()
            dist = os.path.join(repo, "dist", manifest["entry"])
            data_d = open(dist, "rb").read() if os.path.exists(dist) else b""
            if data_a == data_b == data_d:
                print("  ✔ C  byte: build 2 lần giống hệt và trùng dist/%s (%d B)"
                      % (manifest["entry"], len(data_a)))
            else:
                print("  ✘ C  byte: build không ổn định hoặc dist cũ (a=%d b=%d dist=%d)"
                      % (len(data_a), len(data_b), len(data_d)))
                ok = False
            if b"--[[ xngot-studio" in data_a:
                print("  ✘ C  còn banner module lọt vào bản build")
                ok = False
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    # ── D. tái tạo module từ bản gốc ─────────────────────────────────────────
    tmp = tempfile.mkdtemp(prefix="xngot-split-")
    try:
        code = subprocess.run([sys.executable, os.path.join(repo, "tools", "split_source.py"),
                               source, tmp], capture_output=True, text=True)
        if code.returncode != 0:
            print("  ✘ D  split_source lỗi:\n%s%s" % (code.stdout, code.stderr))
            ok = False
        else:
            same, diff = 0, []
            for mod in manifest["modules"]:
                a = os.path.join(repo, "src", "modules", mod["path"])
                b = os.path.join(tmp, "src", "modules", mod["path"])
                if not os.path.exists(b):
                    diff.append(mod["path"] + " (thiếu)")
                elif open(a, "rb").read() == open(b, "rb").read():
                    same += 1
                else:
                    diff.append(mod["path"])
            if diff:
                print("  ✘ D  %d module khác bản tái tạo: %s" % (len(diff), ", ".join(diff[:5])))
                ok = False
            else:
                print("  ✔ D  tái tạo: %d/%d module giống hệt khi chia lại từ bản gốc"
                      % (same, len(manifest["modules"])))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    print()
    print("  KẾT LUẬN: %s" % ("TẤT CẢ ĐỀU ĐẠT ✔" if ok else "CÓ LỖI ✘"))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
