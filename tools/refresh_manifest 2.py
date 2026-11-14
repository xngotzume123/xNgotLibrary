# tools/refresh_manifest.py
# lang   : python 3
# folder : tools · công cụ tách / kiểm tra / làm mới manifest
# role   : Cập nhật sha256 + delta của từng module trong src/manifest.json sau khi sửa tay.
#          from/to/lines vẫn trỏ về dòng gốc trong 'main 2.txt' nên không đổi.
#
# Dùng: python3 tools/refresh_manifest.py [--check]

import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src")
sys.path.insert(0, SRC)

from build import BANNER_RE, do_khoi, sha256, strip_banner  # noqa: E402

MANIFEST_PATH = os.path.join(SRC, "manifest.json")
MODULES_DIR = os.path.join(SRC, "modules")


def main() -> int:
    dry = "--check" in sys.argv[1:]
    with open(MANIFEST_PATH, encoding="utf-8") as fh:
        manifest = json.load(fh)

    changed = 0
    missing = 0
    for mod in manifest["modules"]:
        path = os.path.join(MODULES_DIR, mod["path"])
        if not os.path.exists(path):
            print("  thiếu tệp: %s" % mod["path"])
            missing += 1
            continue
        with open(path, encoding="utf-8") as fh:
            text = fh.read()
        try:
            body = strip_banner(text)
        except ValueError:
            print("  thiếu banner: %s" % mod["path"])
            missing += 1
            continue
        digest = sha256(body)
        delta = do_khoi(body)
        if digest == mod["sha256"] and delta == mod["delta"]:
            continue
        changed += 1
        if dry:
            print("  lệch: %s" % mod["path"])
            continue
        print("  cập nhật: %s (delta %+d -> %+d)" % (mod["path"], mod["delta"], delta))
        mod["sha256"] = digest
        mod["delta"] = delta

    if dry:
        print("  %d/%d module lệch manifest%s" % (changed, len(manifest["modules"]),
                                                  "" if not missing else ", %d tệp lỗi" % missing))
        return 1 if changed or missing else 0

    with open(MANIFEST_PATH, "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print("  ✔ manifest đã làm mới · %d module đổi" % changed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
