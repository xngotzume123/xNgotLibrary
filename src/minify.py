#!/usr/bin/env python3
"""xNgot Library - minifier Lua/Luau (thuần Python, không cần thư viện ngoài).

Ba mức:
    light  bỏ comment, bỏ dòng trống, bỏ khoảng trắng cuối dòng — giữ nguyên tên & xuống dòng
    full   light + đổi tên local cấp chunk thành tên ngẫu nhiên + dồn về 1 dòng

Nguyên tắc an toàn:
    - Chỉ đổi tên `local` khai báo ở **cấp chunk** và không bị khai báo lại (không shadow)
      ở bất kỳ scope nào khác trong tệp.
    - Không bao giờ đổi tên sau `.` hoặc `:` (field/method) hay trước `=` khi đang ở trong
      bảng (field key).
    - Sau khi biến đổi, token stream được so lại với bản gốc (có áp bảng đổi tên): phải
      giống hệt, nếu không thì từ chối xuất.
    - Khi dồn 1 dòng, chèn `;` hoặc giữ `\\n` ở các chỗ Lua coi là nhoà nghĩa
      (`f()` rồi `(x)` / `[x]`), và chèn khoảng trắng ở các chỗ có thể dính token
      (`- -`, `[[`, số + `..`).
"""
from __future__ import annotations

import random
import re

KEYWORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if",
    "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
    "continue",
}

# toán tử nhiều ký tự — xếp dài trước để lex đúng
OPERATORS = [
    "...", "..=", "//=",
    "==", "~=", "<=", ">=", "..", "//", "::", "+=", "-= ", "*=", "/=", "%=", "^=",
    "->",
]
OPERATORS = [op.strip() for op in OPERATORS]

NAME_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
NUMBER_RE = re.compile(
    r"0[xX][0-9a-fA-F]*(?:\.[0-9a-fA-F]*)?(?:[pP][+-]?[0-9]+)?"
    r"|(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][+-]?[0-9]+)?")
LONG_OPEN_RE = re.compile(r"\[(=*)\[")

EXPR_END_KINDS = {"name", "number", "string", "op"}  # op: chỉ ) ] } và ... được coi là kết thúc


class Token:
    __slots__ = ("kind", "text", "line")

    def __init__(self, kind: str, text: str, line: int) -> None:
        self.kind = kind      # name | number | string | op | comment | ws | longstring
        self.text = text
        self.line = line

    def __repr__(self) -> str:  # pragma: no cover
        return "Token(%s,%r)" % (self.kind, self.text)


def tokenize(text: str) -> list[Token]:
    tokens: list[Token] = []
    i, n, line = 0, len(text), 1
    while i < n:
        c = text[i]
        if c == "\n":
            tokens.append(Token("ws", "\n", line))
            line += 1
            i += 1
            continue
        if c in " \t\r\f\v":
            j = i
            while j < n and text[j] in " \t\r\f\v":
                j += 1
            tokens.append(Token("ws", text[i:j], line))
            i = j
            continue
        if text.startswith("--", i):
            m = LONG_OPEN_RE.match(text, i + 2)
            start_line = line
            if m:
                closer = "]" + m.group(1) + "]"
                j = text.find(closer, m.end())
                j = n if j < 0 else j + len(closer)
            else:
                j = text.find("\n", i)
                j = n if j < 0 else j
            body = text[i:j]
            tokens.append(Token("comment", body, start_line))
            line += body.count("\n")
            i = j
            continue
        m = LONG_OPEN_RE.match(text, i)
        if m:
            closer = "]" + m.group(1) + "]"
            j = text.find(closer, m.end())
            j = n if j < 0 else j + len(closer)
            body = text[i:j]
            tokens.append(Token("string", body, line))
            line += body.count("\n")
            i = j
            continue
        if c in "\"'":
            q = c
            j = i + 1
            while j < n:
                ch = text[j]
                if ch == "\\":
                    j += 2
                    continue
                if ch == q:
                    j += 1
                    break
                if ch == "\n":
                    break
                j += 1
            body = text[i:j]
            tokens.append(Token("string", body, line))
            i = j
            continue
        m = NAME_RE.match(text, i)
        if m:
            tokens.append(Token("name", m.group(0), line))
            i = m.end()
            continue
        m = NUMBER_RE.match(text, i)
        if m and m.group(0):
            tokens.append(Token("number", m.group(0), line))
            i = m.end()
            continue
        for op in OPERATORS:
            if text.startswith(op, i):
                tokens.append(Token("op", op, line))
                i += len(op)
                break
        else:
            tokens.append(Token("op", c, line))
            i += 1
    return tokens


def strip(tokens: list[Token]) -> list[Token]:
    return [t for t in tokens if t.kind not in ("ws", "comment")]


# ── phân tích scope ──────────────────────────────────────────────────────────
OPEN = {"function", "if", "do", "repeat"}
CLOSE = {"end", "until"}


def _block_depths(tokens: list[Token]) -> list[int]:
    """Độ sâu khối tại mỗi token (token mở khối có độ sâu trước khi mở)."""
    depths = []
    depth = 0
    for tok in tokens:
        depths.append(depth)
        if tok.kind == "name" and tok.text in OPEN:
            depth += 1
        elif tok.kind == "name" and tok.text in CLOSE:
            depth -= 1
    return depths


def _declarations(tokens: list[Token], depths: list[int]) -> dict[str, set[int]]:
    """Tên -> tập độ sâu nơi nó được khai báo (local, tham số, biến vòng for)."""
    found: dict[str, set[int]] = {}

    def add(name: str, depth: int) -> None:
        found.setdefault(name, set()).add(depth)

    for idx, tok in enumerate(tokens):
        if tok.kind != "name":
            continue
        prev = tokens[idx - 1].text if idx else ""
        if tok.text == "local":
            j = idx + 1
            if j < len(tokens) and tokens[j].text == "function":
                j += 1
                if j < len(tokens) and tokens[j].kind == "name":
                    add(tokens[j].text, depths[idx])
                continue
            # danh sách: local a, b = ...
            while j < len(tokens):
                if tokens[j].kind == "name" and tokens[j].text not in KEYWORDS:
                    add(tokens[j].text, depths[idx])
                    j += 1
                    if j < len(tokens) and tokens[j].text == ",":
                        j += 1
                        continue
                break
        elif tok.text == "for":
            j = idx + 1
            while j < len(tokens) and tokens[j].text not in ("do", "=", "in"):
                if tokens[j].kind == "name" and tokens[j].text not in KEYWORDS:
                    add(tokens[j].text, depths[idx])
                j += 1
        elif tok.text == "function":
            # tham số: NAME ( ... ) hoặc NAME : NAME ( ... )
            j = idx + 1
            while j < len(tokens) and tokens[j].text != "(" and tokens[j].kind != "name":
                j += 1
            while j < len(tokens) and tokens[j].text != "(":
                j += 1
            if j < len(tokens):
                j += 1
                while j < len(tokens) and tokens[j].text != ")":
                    if tokens[j].kind == "name" and tokens[j].text != "self":
                        add(tokens[j].text, depths[idx] + 1)
                    j += 1
        elif prev == "until":
            continue
    return found


def rename_chunk_locals(tokens: list[Token], seed: str) -> tuple[list[Token], dict[str, str]]:
    """Đổi tên local cấp chunk (không shadow, không dùng trước khi khai báo)."""
    depths = _block_depths(tokens)
    decls = _declarations(tokens, depths)
    chunk_locals = {name for name, where in decls.items()
                    if 0 in where and name not in KEYWORDS and name != "self"}

    # đếm số lần khai báo ở cấp chunk + vị trí khai báo đầu tiên
    decl_index: dict[str, list[int]] = {}
    for idx, tok in enumerate(tokens):
        if depths[idx] != 0 or tok.kind != "name":
            continue
        prev = tokens[idx - 1].text if idx else ""
        if prev == "local" or (prev == "function" and idx >= 2 and tokens[idx - 2].text == "local"):
            decl_index.setdefault(tok.text, []).append(idx)

    candidates = set()
    for name in chunk_locals:
        spots = decl_index.get(name, [])
        if len(spots) != 1:
            continue                      # khai báo nhiều lần -> bỏ
        first = spots[0]
        if any(t.kind == "name" and t.text == name for t in tokens[:first]):
            continue                      # có tham chiếu trước khai báo (vd. bắt global `require`) -> bỏ
        candidates.add(name)

    # loại tên bị khai báo lại ở scope khác (shadow) — đổi sẽ sai nghĩa
    safe = {name for name in candidates if decls[name] == {0}}

    rng = random.Random(seed)
    used = {t.text for t in tokens if t.kind == "name"} | KEYWORDS
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    pool: list[str] = list(alphabet)
    for a in alphabet:
        for b in alphabet:
            pool.append(a + b)
    rng.shuffle(pool)

    mapping: dict[str, str] = {}
    pool_iter = iter(pool)
    for name in sorted(safe):
        while True:
            try:
                cand = next(pool_iter)
            except StopIteration:  # pragma: no cover
                cand = "v%d" % len(mapping)
            if cand not in used:
                break
        used.add(cand)
        mapping[name] = cand

    out: list[Token] = []
    for idx, tok in enumerate(tokens):
        if tok.kind == "name" and tok.text in mapping:
            prev = tokens[idx - 1].text if idx else ""
            nxt = tokens[idx + 1].text if idx + 1 < len(tokens) else ""
            if prev in (".", ":") or (nxt == "=" and prev in ("{", ",", ";")):
                out.append(tok)  # field / method / field-key: giữ nguyên
                continue
            out.append(Token("name", mapping[tok.text], tok.line))
        else:
            out.append(tok)
    return out, mapping


# ── xuất văn bản ────────────────────────────────────────────────────────────
def _needs_space(prev: Token, nxt: Token) -> bool:
    a, b = prev.text[-1:], nxt.text[:1]
    if not a or not b:
        return False
    if (a.isalnum() or a == "_") and (b.isalnum() or b == "_"):
        return True              # hai định danh/số dính nhau
    if a == "-" and b == "-":
        return True              # tránh tạo comment `--`
    if a == "[" and b in "[=":
        return True              # tránh `[[` / `[=`
    if a.isdigit() and b == ".":
        return True              # `1..2` là lỗi cú pháp
    if a == "." and b.isdigit():
        return True
    return False


def _needs_break(prev: Token, nxt: Token) -> bool:
    """Chỗ Lua coi là nhoà nghĩa khi dồn dòng: `f()` rồi `(x)` / `[x]`."""
    if nxt.text not in ("(", "["):
        return False
    if prev.kind == "name":
        return prev.text not in KEYWORDS or prev.text in ("end", "true", "false", "nil")
    if prev.kind == "number" or prev.kind == "string":
        return True
    return prev.text in (")", "]", "}", "...", "end")


def emit(tokens: list[Token], single_line: bool) -> tuple[str, int]:
    """Dựng lại văn bản từ danh sách token đã bỏ ws/comment (dùng số dòng để biết chỗ xuống dòng).

    single_line=False (light): giữ đúng các chỗ xuống dòng của bản gốc (mỗi chỗ 1 lần),
        bỏ thụt lề và dòng trống.
    single_line=True (full): dồn về 1 dòng; chỉ giữ `\\n` ở chỗ Lua coi là nhoà nghĩa
        (`f()` rồi `(x)` / `[x]` ở đầu dòng mới) — đo trên bản gốc là 0 chỗ.
    """
    parts: list[str] = []
    prev: Token | None = None
    breaks = 0
    for tok in tokens:
        if prev is not None:
            newline = tok.line > prev.line
            if newline and single_line and _needs_break(prev, tok):
                parts.append("\n")
                breaks += 1
            elif newline and not single_line:
                parts.append("\n")
            elif _needs_space(prev, tok):
                parts.append(" ")
        parts.append(tok.text)
        prev = tok
    return "".join(parts), breaks


def _token_signature(tokens: list[Token], mapping: dict[str, str] | None = None) -> list[str]:
    sig = []
    for tok in tokens:
        if tok.kind in ("ws", "comment"):
            continue
        text = tok.text
        if mapping and tok.kind == "name" and text in mapping:
            text = mapping[text]
        sig.append(tok.kind[:1] + ":" + text)
    return sig


def minify(text: str, level: str = "light", seed: str = "xngot", rename: bool = True) -> dict:
    """Trả về dict: code, bytes, lines, mapping, breaks, renamed, tokens."""
    if level not in ("light", "full"):
        raise ValueError("level phải là 'light' hoặc 'full'")
    tokens = tokenize(text)
    bare = strip(tokens)
    mapping: dict[str, str] = {}
    if level == "full" and rename:
        bare, mapping = rename_chunk_locals(bare, seed)

    code, breaks = emit(bare, single_line=(level == "full"))

    # tự kiểm chứng: token stream phải trùng khớp bản gốc (sau khi áp bảng đổi tên)
    round_trip = _token_signature(strip(tokenize(code)))
    expected = _token_signature(bare)
    if round_trip != expected:
        for i, (a, b) in enumerate(zip(expected, round_trip)):
            if a != b:
                raise SystemExit("minify: token lệch ở vị trí %d: gốc %r → ra %r" % (i, a, b))
        raise SystemExit("minify: số token khác nhau (%d → %d)" % (len(expected), len(round_trip)))

    return {
        "code": code,
        "bytes": len(code.encode("utf-8")),
        "lines": code.count("\n") + 1,           # kể cả xuống dòng nằm trong chuỗi dài
        "code_lines": (breaks if level == "full" else code.count("\n")) + 1,
        "mapping": mapping,
        "breaks": breaks,
        "renamed": len(mapping),
        "tokens": len(bare),
    }
