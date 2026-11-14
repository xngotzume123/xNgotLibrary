#!/usr/bin/env python3
"""xNgot Studio - dựng ảnh minh hoạ (mockup) cho README.

    python3 tools/make_demo_images.py

Ghi ra docs/demo/*.png. Đây là ảnh **mockup** vẽ lại theo đúng bảng màu và kích thước
trong src/modules/30_island/016_palettes.lua + 040_island_consts.lua — không phải ảnh
chụp màn hình Roblox.
"""
from __future__ import annotations

import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "demo")
S = 2  # scale

# bảng màu lấy từ 30_island/016_palettes.lua (theme "Tối", accent "Xanh dương")
BG_A, BG_B = (11, 11, 15), (19, 19, 24)
WINDOW, CARD, FIELD = (24, 24, 27), (44, 44, 48), (28, 28, 31)
OFF, TEXT, SUB = (78, 78, 84), (245, 245, 247), (152, 152, 160)
LINE = (255, 255, 255, 26)
ACCENT = (10, 132, 255)
GREEN, ORANGE, RED, PURPLE = (48, 209, 88), (255, 159, 10), (255, 69, 58), (191, 90, 242)

FONT_DIR = "/usr/share/fonts/truetype/dejavu"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    name = "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"
    return ImageFont.truetype(os.path.join(FONT_DIR, name), size * S)


def mono(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(os.path.join(FONT_DIR, "DejaVuSansMono.ttf"), size * S)


def px(v: float) -> int:
    return int(round(v * S))


def D(img: Image.Image) -> ImageDraw.ImageDraw:
    return ImageDraw.Draw(img)


def blend(img: Image.Image, fn) -> None:
    """Vẽ lên lớp trong suốt rồi trộn xuống — để màu có alpha thực sự hoà vào nền."""
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    fn(ImageDraw.Draw(layer))
    img.alpha_composite(layer)


def canvas(w: int, h: int) -> Image.Image:
    img = Image.new("RGBA", (px(w), px(h)), BG_A + (255,))
    draw = D(img)
    for y in range(img.height):
        t = y / max(1, img.height - 1)
        draw.line([(0, y), (img.width, y)],
                  fill=tuple(int(BG_A[i] + (BG_B[i] - BG_A[i]) * t) for i in range(3)))
    return img


def blob(img: Image.Image, box, color, alpha=70, blur=90) -> None:
    """Vệt sáng mờ phía sau (glow) — cần ảnh RGBA."""
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse([px(v) for v in box], fill=color + (alpha,))
    layer = layer.filter(ImageFilter.GaussianBlur(px(blur / 2)))
    img.alpha_composite(layer)


def panel(img: Image.Image, box, r=18, fill=WINDOW, outline=LINE, shadow=True, glow=None) -> None:
    x0, y0, x1, y1 = [px(v) for v in box]
    if glow:
        layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
        ImageDraw.Draw(layer).rounded_rectangle([x0 - px(6), y0 - px(2), x1 + px(6), y1 + px(14)],
                                                radius=px(r + 6), fill=glow + (60,))
        img.alpha_composite(layer.filter(ImageFilter.GaussianBlur(px(18))))
    if shadow:
        layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
        ImageDraw.Draw(layer).rounded_rectangle([x0, y0 + px(8), x1, y1 + px(16)],
                                                radius=px(r), fill=(0, 0, 0, 150))
        img.alpha_composite(layer.filter(ImageFilter.GaussianBlur(px(16))))
    blend(img, lambda d: d.rounded_rectangle([x0, y0, x1, y1], radius=px(r),
                                             fill=fill, outline=outline, width=px(1)))


def rrect(img: Image.Image, box, r=10, fill=FIELD, outline=None) -> None:
    blend(img, lambda d: d.rounded_rectangle([px(v) for v in box], radius=px(r), fill=fill,
                                             outline=outline, width=px(1) if outline else 0))


def text(img: Image.Image, xy, s, f, fill=TEXT, anchor="la") -> None:
    if not isinstance(xy, (tuple, list)):
        xy = (xy, anchor[1] if len(anchor) > 1 else "a")  # cho phép text(img, x, y, …)
    D(img).text((px(xy[0]), px(xy[1])), s, font=f, fill=fill, anchor=anchor)


def hline(img, x0, x1, y, color=(255, 255, 255, 20)) -> None:
    blend(img, lambda d: d.line([(px(x0), px(y)), (px(x1), px(y))], fill=color, width=px(1)))


def icon_dot(img, cx, cy, r, color) -> None:
    D(img).ellipse([px(cx - r), px(cy - r), px(cx + r), px(cy + r)], fill=color)


def glyph(img, cx, cy, kind, color=SUB, size=8) -> None:
    """Icon tối giản (hình học) thay cho spritesheet icon."""
    d = D(img)
    s = size
    if kind == "home":
        d.polygon([(px(cx - s), px(cy)), (px(cx), px(cy - s * 0.85)), (px(cx + s), px(cy))], fill=color)
        d.rectangle([px(cx - s * 0.6), px(cy), px(cx + s * 0.6), px(cy + s * 0.8)], fill=color)
    elif kind == "music":
        d.ellipse([px(cx - s * 0.55), px(cy + s * 0.25), px(cx), px(cy + s * 0.8)], fill=color)
        d.rectangle([px(cx - s * 0.1), px(cy - s * 0.9), px(cx + s * 0.15), px(cy + s * 0.5)], fill=color)
        d.rectangle([px(cx + s * 0.15), px(cy - s * 0.9), px(cx + s * 0.8), px(cy - s * 0.55)], fill=color)
    elif kind == "settings":
        d.ellipse([px(cx - s * 0.85), px(cy - s * 0.85), px(cx + s * 0.85), px(cy + s * 0.85)],
                  outline=color, width=px(2))
        d.ellipse([px(cx - s * 0.3), px(cy - s * 0.3), px(cx + s * 0.3), px(cy + s * 0.3)], fill=color)
    elif kind == "spark":
        d.polygon([(px(cx), px(cy - s)), (px(cx + s * 0.3), px(cy - s * 0.25)),
                   (px(cx + s), px(cy)), (px(cx + s * 0.3), px(cy + s * 0.25)),
                   (px(cx), px(cy + s)), (px(cx - s * 0.3), px(cy + s * 0.25)),
                   (px(cx - s), px(cy)), (px(cx - s * 0.3), px(cy - s * 0.25))], fill=color)
    elif kind == "info":
        d.ellipse([px(cx - s * 0.9), px(cy - s * 0.9), px(cx + s * 0.9), px(cy + s * 0.9)],
                  outline=color, width=px(2))
        d.rectangle([px(cx - s * 0.08), px(cy - s * 0.05), px(cx + s * 0.08), px(cy + s * 0.55)], fill=color)
        icon_dot(img, cx, cy - s * 0.4, s * 0.12, color)


def switch(img, x, y, on=True, w=44, h=24) -> None:
    color = ACCENT if on else OFF
    D(img).rounded_rectangle([px(x), px(y), px(x + w), px(y + h)], radius=px(h / 2), fill=color)
    cx = x + (w - h / 2 - 2 if on else h / 2 + 2)
    icon_dot(img, cx, y + h / 2, h / 2 - 3, (255, 255, 255))


def slider(img, x, y, w, value=0.62, h=6) -> None:
    D(img).rounded_rectangle([px(x), px(y), px(x + w), px(y + h)], radius=px(h / 2), fill=OFF)
    D(img).rounded_rectangle([px(x), px(y), px(x + w * value), px(y + h)],
                                          radius=px(h / 2), fill=ACCENT)
    icon_dot(img, x + w * value, y + h / 2, h / 2 + 3, (255, 255, 255))


def ring(img, cx, cy, r, pct, color=ACCENT, width=3) -> None:
    box = [px(cx - r), px(cy - r), px(cx + r), px(cy + r)]
    D(img).arc(box, start=-90, end=270, fill=OFF, width=px(width))
    D(img).arc(box, start=-90, end=-90 + 360 * pct, fill=color, width=px(width))


# ── ảnh 1: cửa sổ chính ───────────────────────────────────────────────────────
def demo_window() -> Image.Image:
    img = canvas(1400, 980)
    panel(img, (70, 60, 1330, 920), r=22, fill=WINDOW, outline=(255, 255, 255, 34), glow=ACCENT)

    # thanh tiêu đề
    rrect(img, (94, 84, 130, 120), 10, fill=ACCENT)
    glyph(img, 112, 102, "spark", (255, 255, 255), size=9)
    text(img, (146, 92), "xNgot Studio", font(20, True))
    text(img, (146, 118), "v3.0.0 · UI Library", font(11), SUB)
    rrect(img, (1136, 88, 1214, 116), 8, fill=FIELD, outline=(255, 255, 255, 22))
    text(img, (1175, 102), "RightShift", font(10), SUB, anchor="mm")
    for i, c in enumerate((RED, ORANGE, GREEN)):
        icon_dot(img, 1242 + i * 18, 102, 5, c)
    hline(img, 94, 1306, 138)

    # rail trái
    rrect(img, (94, 158, 378, 198), 10, fill=FIELD, outline=(255, 255, 255, 18))
    text(img, (112, 178), "Tìm kiếm…", font(11), (120, 120, 128), anchor="lm")
    tabs = [("home", "Trang chủ", True), ("music", "Giao diện", False),
            ("spark", "Âm thanh", False), ("settings", "Cài đặt", False), ("info", "Thông tin", False)]
    y = 226
    for kind, label, active in tabs:
        if active:
            rrect(img, (94, y - 16, 378, y + 16), 10, fill=(10, 132, 255, 40))
            D(img).rounded_rectangle([px(94), px(y - 16), px(378), px(y + 16)],
                                                  radius=px(10), outline=ACCENT, width=px(1))
        glyph(img, 118, y, kind, ACCENT if active else SUB, size=8)
        text(img, (142, y), label, font(12, active), TEXT if active else SUB, anchor="lm")
        y += 56

    D(img).line([(px(378), px(158)), (px(378), px(902))], fill=(255, 255, 255, 18), width=px(1))

    # cột nội dung
    x0, x1 = 410, 1306
    text(img, (x0, 168), "GIAO DIỆN", font(10, True), (130, 130, 140))

    def card(y, h):
        rrect(img, (x0, y, x1, y + h), 14, fill=CARD, outline=(255, 255, 255, 16))
        return y

    y = 190
    card(y, 96)
    text(img, (x0 + 24, y + 26), "Bảng nổi", font(13, True))
    text(img, (x0 + 24, y + 56), "Hiện thanh điều khiển nổi ở cạnh trên màn hình", font(10), SUB)
    switch(img, x1 - 76, y + 34, True)
    y += 112

    card(y, 96)
    text(img, (x0 + 24, y + 26), "Độ trong suốt", font(13, True))
    text(img, (x1 - 60, y + 26), "62%", font(12, True), ACCENT, anchor="ra")
    slider(img, x0 + 24, y + 62, x1 - x0 - 48, 0.62)
    y += 112

    card(y, 96)
    text(img, (x0 + 24, y + 26), "Nguồn nhạc", font(13, True))
    rrect(img, (x0 + 200, y + 14, x0 + 420, y + 60), 10, fill=FIELD, outline=(255, 255, 255, 18))
    text(img, (x0 + 216, y + 37), "YouTube", font(11), TEXT, anchor="lm")
    text(img, (x0 + 400, y + 37), "▾", font(11), SUB, anchor="mm")
    text(img, (x0 + 440, y + 33), "sau khi đổi, engine tìm ở nguồn này trước", font(10), SUB)
    y += 112

    card(y, 96)
    text(img, (x0 + 24, y + 26), "Từ khoá AI", font(13, True))
    rrect(img, (x0 + 200, y + 14, x1 - 24, y + 60), 10, fill=FIELD, outline=(255, 255, 255, 18))
    text(img, (x0 + 216, y + 37), "lofi chill buổi tối, jazz nhẹ…", font(11), TEXT, anchor="lm")
    y += 112

    card(y, 96)
    text(img, (x0 + 24, y + 26), "Màu nhấn", font(13, True))
    for i, c in enumerate((ACCENT, PURPLE, (255, 55, 132), ORANGE, GREEN, (64, 200, 255))):
        cx = x0 + 200 + i * 40
        icon_dot(img, cx, y + 37, 13, c)
        if i == 0:
            D(img).ellipse([px(cx - 18), px(y + 19), px(cx + 18), px(y + 55)],
                                        outline=(255, 255, 255, 200), width=px(2))
    rrect(img, (x1 - 210, y + 20, x1 - 24, y + 76), 10, fill=ACCENT)
    text(img, (x1 - 117, y + 48), "Áp dụng", font(12, True), (255, 255, 255), anchor="mm")
    y += 112

    # code block
    rrect(img, (x0, y, x1, y + 150), 14, fill=(16, 16, 19), outline=(255, 255, 255, 16))
    text(img, (x0 + 20, y + 16), "Code", font(10, True), (130, 130, 140))
    code = ['local LIB = loadstring(game:HttpGet(url))()',
            'local Win = LIB:CreateWindow({ Title = "Hub" })',
            'Win:Tab({ Title = "Main" }):Toggle({ Title = "ESP" })']
    for i, line in enumerate(code):
        text(img, (x0 + 20, y + 42 + i * 30), line, mono(10), (198, 208, 222))
    return img


# ── ảnh 2: bảng nổi + thông báo ─────────────────────────────────────────────────
def demo_overlay() -> Image.Image:
    img = canvas(1400, 900)
    blob(img, (200, 40, 1200, 420), ACCENT, alpha=48, blur=120)

    # pill idle
    panel(img, (560, 70, 840, 132), r=31, fill=(16, 16, 19), outline=(255, 255, 255, 30), shadow=True)
    icon_dot(img, 596, 101, 7, GREEN)
    text(img, (614, 101), "xNgot Studio", font(12, True), TEXT, anchor="lm")
    ring(img, 800, 101, 13, 0.64, ACCENT, 2)

    # pill expanded
    panel(img, (330, 168, 1100, 672), r=38, fill=(16, 16, 19), outline=(255, 255, 255, 34),
          shadow=True, glow=PURPLE)
    # album art
    art = Image.new("RGB", (px(126), px(126)))
    ad = D(art)
    for yy in range(art.height):
        t = yy / art.height
        ad.line([(0, yy), (art.width, yy)],
                fill=(int(60 + 120 * t), int(40 + 60 * (1 - t)), int(180 + 60 * t)))
    mask = Image.new("L", art.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, art.width - 1, art.height - 1], radius=px(14), fill=255)
    img.paste(art, (px(366), px(212)), mask)
    glyph(img, 429, 275, "music", (255, 255, 255), size=16)

    text(img, (522, 216), "lofi chill buổi tối", font(16, True))
    text(img, (522, 244), "YouTube · Indie Mix", font(11), SUB)
    # nút điều khiển
    for i, cx in enumerate((560, 610, 660)):
        icon_dot(img, cx, 296, 15, (32, 32, 36) if i != 1 else ACCENT)
        sym = "◀◀" if i == 0 else ("▶" if i == 1 else "▶▶")
        text(img, (cx, 296), sym, font(8, True), (255, 255, 255), anchor="mm")
    # progress
    slider(img, 522, 340, 240, 0.38, 5)
    text(img, (522, 356), "1:12", font(9), SUB)
    text(img, (762, 356), "3:18", font(9), SUB, anchor="ra")
    # volume
    text(img, (522, 392), "Vol", font(9), SUB)
    slider(img, 556, 396, 150, 0.55, 5)
    # ring lớn bên phải
    ring(img, 900, 268, 54, 0.72, ACCENT, 5)
    text(img, (900, 258), "72%", font(15, True), TEXT, anchor="mm")
    text(img, (900, 282), "download", font(8), SUB, anchor="mm")
    # dock trang
    pages = ["Home", "Music", "Cross", "Timer"]
    for i, p in enumerate(pages):
        bx = 398 + i * 130
        active = i == 1
        rrect(img, (bx, 470, bx + 118, 514), 22, fill=(10, 132, 255, 55) if active else (32, 32, 36),
              outline=ACCENT if active else (255, 255, 255, 18))
        text(img, (bx + 59, 492), p, font(11, active), TEXT if active else SUB, anchor="mm")
    text(img, (366, 556), "Cross AI", font(11, True), SUB)
    rrect(img, (366, 578, 1064, 620), 20, fill=(32, 32, 36), outline=(255, 255, 255, 16))
    text(img, (386, 599), "tìm nhạc lofi cho buổi tối…", font(10), (140, 140, 150), anchor="lm")
    icon_dot(img, 1038, 599, 15, ACCENT)
    text(img, (1038, 599), "↑", font(10, True), (255, 255, 255), anchor="mm")

    # toast
    for i, (title, msg, color, kind) in enumerate((
            ("Đã tải xong", "lofi-chill-01.mp3 · 3.2 MB", GREEN, "info"),
            ("Không tìm thấy nguồn", "thử lại với SoundCloud", ORANGE, "warn"))):
        y = 200 + i * 104
        panel(img, (1120, y, 1340, y + 88), r=16, fill=CARD, outline=(255, 255, 255, 26), shadow=True)
        icon_dot(img, 1152, y + 44, 16, color)
        text(img, (1176, y + 24), title, font(11, True))
        text(img, (1176, y + 46), msg, font(9), SUB)
    # pill activity
    panel(img, (1120, 430, 1340, 500), r=24, fill=(16, 16, 19), outline=(255, 255, 255, 26), shadow=True)
    icon_dot(img, 1152, 465, 10, ORANGE)
    text(img, (1172, 456), "Auto Farm", font(10, True))
    text(img, (1172, 474), "đang chạy · 11s", font(9), SUB)
    return img


# ── ảnh 3: bộ element ────────────────────────────────────────────────────────
def demo_elements() -> Image.Image:
    img = canvas(1400, 760)
    blob(img, (100, 100, 700, 700), PURPLE, alpha=42, blur=130)
    cells = [(80, 90), (740, 90), (80, 420), (740, 420)]
    titles = ["Toggle · Slider", "Dropdown · Input", "Colorpicker · Button", "Paragraph · Code"]
    for (cx, cy), title in zip(cells, titles):
        panel(img, (cx, cy, cx + 580, cy + 290), r=18, fill=CARD, outline=(255, 255, 255, 20))
        text(img, (cx + 24, cy + 22), title, font(10, True), (140, 140, 150))

    # toggle + slider
    x, y = 104, 140
    text(img, (x, y), "Bật bảng nổi", font(12, True))
    text(img, (x, y + 26), "thanh điều khiển nổi", font(9), SUB)
    switch(img, x + 420, y + 12, True)
    text(img, (x, y + 76), "Tốc độ", font(12, True))
    text(img, (x + 500, y + 76), "120", font(11, True), ACCENT, anchor="ra")
    slider(img, x, y + 108, 500, 0.7)

    # dropdown + input
    x, y = 764, 140
    text(img, (x, y), "Nguồn nhạc", font(12, True))
    rrect(img, (x, y + 26, x + 500, y + 72), 10, fill=FIELD, outline=(255, 255, 255, 18))
    text(img, (x + 16, y + 49), "SoundCloud", font(10), TEXT, anchor="lm")
    text(img, (x + 480, y + 49), "▾", font(10), SUB, anchor="mm")
    text(img, (x, y + 100), "Từ khoá", font(12, True))
    rrect(img, (x, y + 126, x + 500, y + 172), 10, fill=FIELD, outline=ACCENT)
    text(img, (x + 16, y + 149), "jazz nhẹ|", font(10), TEXT, anchor="lm")

    # colorpicker + button
    x, y = 104, 470
    text(img, (x, y), "Màu nhấn", font(12, True))
    for i, c in enumerate((ACCENT, PURPLE, (255, 55, 132), ORANGE, GREEN, (64, 200, 255))):
        icon_dot(img, x + 24 + i * 40, y + 80, 13, c)
    rrect(img, (x + 24, y + 130, x + 300, y + 186), 12, fill=ACCENT)
    text(img, (x + 162, y + 158), "Chạy script", font(11, True), (255, 255, 255), anchor="mm")
    rrect(img, (x + 316, y + 130, x + 528, y + 186), 12, fill=CARD, outline=(255, 255, 255, 40))
    text(img, (x + 422, y + 158), "Huỷ", font(11), SUB, anchor="mm")

    # paragraph + code
    x, y = 764, 470
    text(img, (x, y), "Nguồn gốc", font(12, True))
    text(img, (x, y + 28), "Một thư viện: cửa sổ, tab, element, thông báo,", font(9), SUB)
    text(img, (x, y + 48), "bảng nổi và engine nhạc.", font(9), SUB)
    rrect(img, (x, y + 78, x + 500, y + 186), 12, fill=(16, 16, 19), outline=(255, 255, 255, 16))
    text(img, (x + 16, y + 96), "LIB:Notify({ Title = \"Xong\" })", mono(9), (198, 208, 222))
    text(img, (x + 16, y + 122), "Win:SelectTab(\"Main\")", mono(9), (198, 208, 222))
    text(img, (x + 16, y + 148), "Island:MusicSearch(prompt)", mono(9), (198, 208, 222))
    return img


# ── ảnh 4: hero ─────────────────────────────────────────────────────────────
def demo_hero() -> Image.Image:
    img = canvas(1600, 620)
    blob(img, (60, -140, 700, 460), ACCENT, alpha=70, blur=150)
    blob(img, (1000, 180, 1680, 760), PURPLE, alpha=56, blur=150)

    text(img, (110, 150), "xNgot Studio", font(56, True))
    text(img, (112, 236), "Thư viện UI Roblox · cửa sổ, tab, element, thông báo", font(20), SUB)
    badges = [("150 module", ACCENT), ("11 element", PURPLE), ("MIT", GREEN), ("build 1 lệnh", ORANGE)]
    bx = 112
    for label, color in badges:
        w = 30 + len(label) * 9
        rrect(img, (bx, 300, bx + w, 340), 20, fill=(255, 255, 255, 14), outline=(255, 255, 255, 30))
        icon_dot(img, bx + 18, 320, 5, color)
        text(img, (bx + 32, 320), label, font(11, True), TEXT, anchor="lm")
        bx += w + 14

    # window mini
    panel(img, (980, 96, 1496, 520), r=20, fill=WINDOW, outline=(255, 255, 255, 30), glow=ACCENT)
    rrect(img, (1004, 120, 1040, 156), 9, fill=ACCENT)
    glyph(img, 1022, 138, "spark", (255, 255, 255), size=8)
    text(img, (1052, 128), "xNgot Studio", font(13, True))
    text(img, (1052, 148), "UI Library", font(9), SUB)
    hline(img, 1004, 1472, 176)
    for i in range(3):
        y = 196 + i * 62
        rrect(img, (1004, y, 1472, y + 50), 10, fill=CARD, outline=(255, 255, 255, 14))
        text(img, (1022, y + 16), ["Bảng nổi", "Độ trong suốt", "Nguồn nhạc"][i], font(10, True))
        if i == 0:
            switch(img, 1404, y + 14, True, 40, 22)
        elif i == 1:
            slider(img, 1180, y + 32, 200, 0.6, 5)
        else:
            text(img, (1404, y + 24), "YouTube ▾", font(9), SUB, anchor="ra")
    # code block trong cửa sổ mini
    rrect(img, (1004, 380, 1472, 494), 10, fill=(16, 16, 19), outline=(255, 255, 255, 18))
    for i, line in enumerate(('local LIB = loadstring(game:HttpGet(u))()',
                              'LIB:CreateWindow({ Title = "Hub" })',
                              'Window:Tab({ Title = "Main" })')):
        text(img, (1020, 398 + i * 30), line, mono(9), (198, 208, 222))

    # island pill mini
    panel(img, (112, 430, 470, 560), r=30, fill=(16, 16, 19), outline=(255, 255, 255, 34), shadow=True)
    icon_dot(img, 150, 470, 9, GREEN)
    text(img, (170, 470), "Playing · lofi chill", font(11, True), TEXT, anchor="lm")
    slider(img, 140, 500, 300, 0.42, 5)
    text(img, (140, 516), "1:12 / 3:18", font(9), SUB)
    return img


def main() -> int:
    os.makedirs(OUT, exist_ok=True)
    jobs = [("hero", demo_hero), ("window", demo_window),
            ("overlay", demo_overlay), ("elements", demo_elements)]
    for name, fn in jobs:
        path = os.path.join(OUT, name + ".png")
        fn().convert("RGB").save(path, optimize=True)
        print("  ✔ docs/demo/%s.png  %d KB" % (name, os.path.getsize(path) // 1024))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
