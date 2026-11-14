#!/usr/bin/env python3
"""xNgot Library - tiện ích dùng chung cho các script trong tools/.

- LuaScan : bộ quét token theo dòng, hiểu chuỗi/comment dài của Lua/Luau.
- do_khoi  : đếm độ lệch khối (function/if/do/repeat ... end/until) của một đoạn.
- sha256   : băm nội dung.
"""
from __future__ import annotations

import hashlib
import re

OPEN_TOKENS = ("function", "if", "do", "repeat")
CLOSE_TOKENS = ("end", "until")

LONG_COMMENT = re.compile(r"--\[(=*)\[")
LONG_STRING = re.compile(r"\[(=*)\[")


class LuaScan:
    """Quét một dòng và trả về các token mở/đóng khối (bỏ qua chuỗi và comment)."""

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
    """Độ lệch khối của một đoạn Lua (0 = cân bằng)."""
    scan = LuaScan()
    depth = 0
    for line in text.split("\n"):
        for token in scan.tokens(line):
            depth += 1 if token in OPEN_TOKENS else -1
    return depth


def do_sau(text: str, base: int = 0) -> list[int]:
    """Độ sâu khối tại từng dòng (base = độ sâu lúc bắt đầu)."""
    scan = LuaScan()
    depths = []
    depth = base
    for line in text.split("\n"):
        depths.append(depth)
        for token in scan.tokens(line):
            depth += 1 if token in OPEN_TOKENS else -1
    return depths


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def do_dong(text: str) -> int:
    """Số dòng theo cách đếm của `wc -l`."""
    if not text:
        return 0
    return text.count("\n") + (0 if text.endswith("\n") else 1)
