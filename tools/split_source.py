#!/usr/bin/env python3
"""xNgot Library - chia bản một-tệp gốc thành các module nhỏ.

Cách dùng:
    python3 tools/split_source.py "main 2.txt" .

Nguyên tắc:
1. Mỗi module là một LÁT CẮT NGUYÊN VĂN của tệp gốc (không sửa, không thụt lề lại),
   nên ghép theo manifest sẽ tái tạo đúng từng byte của bản gốc.
2. Chỉ 4 thay đổi có chủ đích (xem docs/PROVENANCE.md):
   - bỏ dòng 19  `local LIB = (function()`   (gỡ closure ngoài cùng)
   - đổi dòng 201 `local LIB = (function()`  -> `local LIB`
   - đổi dòng 25082 `return require(...)`    -> `LIB = require(...)`
   - bỏ dòng 25083 `end)()`
   - bỏ dòng 26021 `return LIB` + 26022 `end)()` (closure ngoài cùng đã gỡ)
3. Mỗi tệp có đúng một comment đầu tệp: ngôn ngữ + thư mục + module + nguồn.
4. Script ghi ra src/manifest.json (thứ tự, số dòng, độ lệch khối, sha256).
"""
from __future__ import annotations

import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import do_khoi, sha256  # noqa: E402

FOLDER_DESC = {
    "00_header": "banner gốc của bản phát hành",
    "10_config": "cấu hình nhạc toàn cục _G.xNgotMusicConfig",
    "20_lib": "lõi thư viện UI (template giao diện + closure 3e)",
    "30_overlay": "bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai",
    "40_window": "Window / Tab / element builder + Settings tab",
    "45_notify": "thông báo dạng thẻ (LIB:Notify)",
    "50_icons": "bộ icon dựng sẵn (16 spritesheet, 1.548 icon)",
    "60_runtime": "log, DevTools, bridge debug",
    "70_boot": "khởi động, loader, chọn nguồn thư viện",
}

# (path, module id, role, dòng đầu, dòng cuối) - 1-based, bao gồm cả hai đầu
SLICES = [
    # ── 00 · banner ────────────────────────────────────────────────────────────
    ("00_header/010_banner.lua", "header.banner",
     "Banner + bản quyền + hướng dẫn build của bản phát hành", 1, 18),

    # ── 10 · cấu hình nhạc ─────────────────────────────────────────────────────
    ("10_config/010_schema.lua", "config.schema",
     "Bảng schema cho _G.xNgotMusicConfig (kiểu, min/max, mặc định)", 20, 59),
    ("10_config/020_coerce.lua", "config.coerce",
     "Chuẩn hoá giá trị theo schema + bảng Config + listeners", 60, 82),
    ("10_config/030_set.lua", "config.set",
     "Hàm set(): ghi giá trị, phát listener, lưu vào engine", 83, 104),
    ("10_config/040_log.lua", "config.log",
     "Log riêng của lớp cấu hình (xoay vòng 120 dòng)", 105, 110),
    ("10_config/050_apply.lua", "config.apply",
     "Áp cấu hình xuống _G.CrossAIMusic (nguồn, timeout, thư mục...)", 111, 131),
    ("10_config/060_api.lua", "config.api",
     "Api: Get/Set/Schema/OnChange/Apply/Preset/Presets + xuất _G", 132, 200),

    # ── 20 · lõi thư viện UI ───────────────────────────────────────────────────
    ("20_lib/010_open.lua", "lib.open",
     "`local LIB` + CrossAIMusic + bảng NgotStudio (thay closure ngoài cùng)", 201, 206),
    ("20_lib/020_template_01.lua", "lib.template.01",
     "Template: ScreenGui gốc, Window, TopBar, TabButtons, khung dropdown", 207, 651),
    ("20_lib/020_template_02.lua", "lib.template.02",
     "Template: nút Hide, Tabs, NotificationFrame/List, folder Library/IconModule", 652, 1103),
    ("20_lib/020_template_03.lua", "lib.template.03",
     "Template: Ball (nút nổi), Notification toast, Slider", 1104, 1561),
    ("20_lib/020_template_04.lua", "lib.template.04",
     "Template: Dropdown list + ô tìm kiếm, Code block", 1562, 2007),
    ("20_lib/020_template_05.lua", "lib.template.05",
     "Template: Section, Button, Dialog, Notification, TabButton cuối", 2008, 2452),
    ("20_lib/070_require_shim.lua", "lib.require",
     "Shim require() nội bộ: NgotStudio_MODULES + require gốc", 2453, 2466),
    ("20_lib/080_module_open.lua", "lib.module_open",
     "Mở module 3e: bảng NgotStudio_MODULES + closure + IconModule", 2467, 2470),
    ("20_lib/090_runtime_refs.lua", "lib.runtime",
     "Tham chiếu service, Gui/Templates cũ, bảng TweenConfigs", 2471, 2504),
    ("20_lib/100_tween.lua", "lib.tween", "Hàm Tween() bọc TweenService", 2505, 2511),
    ("20_lib/110_draggable.lua", "lib.draggable",
     "Kéo cửa sổ bằng topbar (chuột + cảm ứng)", 2512, 2591),
    ("20_lib/120_resizable.lua", "lib.resizable",
     "Kéo góc để đổi kích thước cửa sổ", 2592, 2663),
    ("20_lib/130_clipboard.lua", "lib.clipboard",
     "CopyText(): clipboard + thông báo 'Copied'", 2664, 2702),
    ("20_lib/140_social_icons.lua", "lib.social",
     "Icon mạng xã hội (Discord/GitHub) + tip copy link", 2703, 2744),
    ("20_lib/150_apply_icon.lua", "lib.icon",
     "ApplyIcon(): gán icon hoặc ảnh cho ImageLabel", 2745, 2768),

    # ── 30 · bảng nổi (overlay) ────────────────────────────────────────────────────
    ("30_overlay/010_bootstrap.lua", "overlay.bootstrap",
     "Mở hàm createIntegratedDynamicIsland + service + guard", 2769, 2809),
    ("30_overlay/012_connections.lua", "overlay.connections",
     "Bảng connections + track() huỷ kết nối khi destroy", 2810, 2816),
    ("30_overlay/014_fonts.lua", "overlay.fonts",
     "VERSION, FAMILY font, bảng Fonts, rgb()", 2817, 2830),
    ("30_overlay/016_palettes.lua", "overlay.palettes",
     "Bảng màu Static/Palettes/Accents + Settings mặc định", 2831, 2952),
    ("30_overlay/020_prompt_i18n.lua", "overlay.i18n",
     "Nhận diện prompt tiếng Việt + từ điển VI_EN/EN_VI", 2953, 3314),
    ("30_overlay/024_i18n_index.lua", "overlay.i18n_index",
     "orderedKeys/replacePlain/translate + State/Metrics/P", 3315, 3387),
    ("30_overlay/028_theme_helpers.lua", "overlay.theme",
     "new/paint/applyTheme/applyAccent/corner/stroke/text/box", 3388, 3498),
    ("30_overlay/030_glass.lua", "overlay.glass",
     "Glass (kính mờ) + Search (chỉ mục tìm kiếm)", 3499, 3788),
    ("30_overlay/034_spring.lua", "overlay.spring",
     "Spring vật lý lò xo cho chuyển động island", 3789, 3845),
    ("30_overlay/036_gui_surface.lua", "overlay.surface",
     "GUI nổi: frame gốc + BlurEffect của island", 3846, 3894),
    ("30_overlay/038_hooks.lua", "overlay.hooks",
     "Hooks: đăng ký hàm chạy theo Frame/Stride", 3895, 3993),
    ("30_overlay/040_island_consts.lua", "overlay.consts",
     "Kích thước ISLAND, islandState, Media, Ring, layoutGlow", 3994, 4052),
    ("30_overlay/044_ring.lua", "overlay.ring",
     "Vòng tiến trình: vẽ mask, glow, ringShow/ringHide", 4053, 4710),
    ("30_overlay/048_hooks_register.lua", "overlay.hooks_register",
     "Hooks.Tasks + Hooks.Frame (vòng cập nhật mỗi frame)", 4711, 4758),
    ("30_overlay/052_alerts.lua", "overlay.alerts",
     "Hàng đợi cảnh báo: KINDS, Isl.*, notify(), History", 4759, 5092),
    ("30_overlay/056_activities.lua", "overlay.activities",
     "Activity: timer, stopwatch, FPS, ping, đồng hồ", 5093, 5334),
    ("30_overlay/060_cross_state.lua", "overlay.cross_state",
     "Bảng Cross (AI chat) + state ban đầu", 5335, 5358),
    ("30_overlay/064_cross_face.lua", "overlay.cross_face",
     "Mặt AI: shell, face, pose, renderLine, cử động", 5359, 6021),
    ("30_overlay/068_music_core.lua", "overlay.music_core",
     "Bảng Music: downloadState, Progress, Sync", 6022, 6277),
    ("30_overlay/070_engine_open.lua", "engine.open",
     "Tạo CrossAIMusic: CFG, Sources, Util, request, Llm", 6278, 6559),
    ("30_overlay/074_engine_crypto.lua", "engine.crypto",
     "SHA-256 + solvePow (proof-of-work) cho API nhạc", 6560, 6664),
    ("30_overlay/076_engine_lexicon.lua", "engine.lexicon",
     "LEXICON + put() + STOP: từ điển phân tích prompt", 6665, 6768),
    ("30_overlay/080_engine_parse.lua", "engine.parse",
     "parse()/durationSeconds()/normalizeRow()", 6769, 6916),
    ("30_overlay/084_engine_score.lua", "engine.score",
     "score() xếp hạng track + learn() học từ lựa chọn", 6917, 7029),
    ("30_overlay/088_engine_search.lua", "engine.search",
     "queryVariants/searchOne/search (đa nguồn)", 7030, 7194),
    ("30_overlay/092_engine_download.lua", "engine.download",
     "Token PoW, powHeaders, getPowToken, download()", 7195, 7329),
    ("30_overlay/096_engine_audio.lua", "engine.audio",
     "Nhận dạng audio, đọc ID3, hash, cache, cover, saveBytes", 7330, 7585),
    ("30_overlay/100_engine_files.lua", "engine.files",
     "File manager engine: liệt kê/xoá/thống kê mp3 đã tải", 7586, 7914),
    ("30_overlay/104_engine_resolve.lua", "engine.resolve",
     "resolve(), rowLabel/rowValue/rowData, say(), enrich()", 7915, 8177),
    ("30_overlay/108_remote.lua", "overlay.remote",
     "Remote: dựng catalog từ engine, bảng hàng, refresh", 8178, 8420),
    ("30_overlay/112_remote_io.lua", "overlay.remote_io",
     "Nạp nhạc đã tải, phát/dừng, next/shuffle/repeat", 8421, 8773),
    ("30_overlay/116_pages_core.lua", "overlay.pages",
     "PAGE_ORDER, View, helper vẽ (label/pressable/action/icon)", 8774, 9067),
    ("30_overlay/120_quick_actions.lua", "overlay.quick",
     "Nút hành động nhanh + View.bars", 9068, 9263),
    ("30_overlay/124_transport.lua", "overlay.transport",
     "Nút play/next + seek bằng chuột/cảm ứng", 9264, 9431),
    ("30_overlay/128_cross_page.lua", "overlay.cross_page",
     "Trang Cross: crossActive, crossSend, crossFocus, crossMode", 9432, 9824),
    ("30_overlay/132_view_layout.lua", "overlay.view_layout",
     "View.available + layoutDock (dàn nút theo bề rộng)", 9825, 9890),
    ("30_overlay/136_view_show.lua", "overlay.view_show",
     "View.show/nudge/step/tick/refresh + toast", 9891, 10148),
    ("30_overlay/140_expand.lua", "overlay.expand",
     "drainToToast, Isl.expand/collapse, xử lý input", 10149, 10347),
    ("30_overlay/144_bubble.lua", "overlay.bubble",
     "Bong bóng thu nhỏ: secondaryKey, bubble, tự thu sau idle", 10348, 10443),
    ("30_overlay/148_cross_control.lua", "overlay.cross_control",
     "refreshIslandScale, Cross.setEnabled/ask/clearChat/shutdown", 10444, 10784),
    ("30_overlay/152_api.lua", "overlay.api",
     "API công khai của island: Notify/Music*/Ai*/Expand/State/Destroy", 10785, 11080),

    # ── 40 · Window builder ────────────────────────────────────────────────────
    ("40_window/010_open.lua", "window.open",
     "local Windows + function LIB:CreateWindow + opts mặc định", 11081, 11152),
    ("40_window/020_config_io.lua", "window.config_io",
     "WRITECONFIG/SAVECONFIG + Window:SaveConfig/GetConfigPath", 11153, 11210),
    ("40_window/030_value_helpers.lua", "window.values",
     "clampNumber/colorToHex/colorFrom/font helpers", 11211, 11381),
    ("40_window/040_settings_copy.lua", "window.settings_copy",
     "copy/serialize/merge UISettings + capture/restore theme", 11382, 11585),
    ("40_window/050_size_restore.lua", "window.size",
     "Kích thước cửa sổ, restoreOriginalUI, accent, ảnh nền", 11586, 11736),
    ("40_window/060_theme_apply.lua", "window.theme_apply",
     "applyThemeToObject/applyUITheme/schedule/store", 11737, 11873),
    ("40_window/070_set_ui_setting.lua", "window.set_ui_setting",
     "setUISetting + queueUISettingsSave", 11874, 11919),
    ("40_window/080_settings_presets.lua", "window.settings_presets",
     "applyPreset + API UI: SetUISettings/Export/Import/Profile", 11920, 12166),
    ("40_window/090_tab_list.lua", "window.tab_list",
     "AddTabToList, DropdownPopup, SelectTab (nội bộ)", 12167, 12335),
    ("40_window/100_tab_open.lua", "window.tab_open",
     "Window:Tab — khung tab mới, TabData, Tab:_Use, parentElement", 12336, 12421),
    ("40_window/110_el_section.lua", "window.el_section", "Tab:Section", 12422, 12488),
    ("40_window/120_el_button.lua", "window.el_button", "Tab:Button", 12489, 12631),
    ("40_window/130_el_code.lua", "window.el_code", "Tab:Code", 12632, 12667),
    ("40_window/140_el_paragraph.lua", "window.el_paragraph", "Tab:Paragraph", 12668, 12711),
    ("40_window/150_el_colorpicker.lua", "window.el_colorpicker", "Tab:Colorpicker", 12712, 12918),
    ("40_window/160_el_toggle.lua", "window.el_toggle", "Tab:Toggle", 12919, 13072),
    ("40_window/170_el_slider.lua", "window.el_slider", "Tab:Slider", 13073, 13315),
    ("40_window/180_el_input.lua", "window.el_input", "Tab:Input", 13316, 13489),
    ("40_window/185_dropdown_helpers.lua", "window.dropdown_helpers",
     "AddDropdownButton + TableToString", 13490, 13517),
    ("40_window/190_el_dropdown.lua", "window.el_dropdown", "Tab:Dropdown", 13518, 13960),
    ("40_window/200_el_info.lua", "window.el_info", "Tab:InfoNguyenNhat", 13961, 14130),
    ("40_window/210_el_discord.lua", "window.el_discord", "Tab:Discord", 14131, 14283),
    ("40_window/220_window_actions.lua", "window.actions",
     "SelectTab(index), OpenUISettings, Divider", 14284, 14309),
    ("40_window/230_toggle_key.lua", "window.toggle_key",
     "SetToggleKey/SetToggleButtonPlatform/EditOpenButton", 14310, 14366),
    ("40_window/240_dialog.lua", "window.dialog", "Window:Dialog + nút xác nhận", 14367, 14508),
    ("40_window/250_toggle_window.lua", "window.toggle_window",
     "toggleButtonAllowed, ToggleWindow, Show/Hide/Toggle", 14509, 14597),
    ("40_window/260_destroy_gate.lua", "window.destroy_gate",
     "Window:Destroy + cổng khoá key (KeySystem) + ForgetSavedKey", 14598, 15113),
    ("40_window/270_island_bridge.lua", "window.island_bridge",
     "GetDynamicIsland / NotifyIsland / IslandActivity", 15114, 15149),
    ("40_window/280_settings_tab.lua", "window.settings_tab",
     "Settings tab: giao diện, theme, preset, slider, profile", 15150, 16103),
    ("40_window/290_ui_language.lua", "window.ui_language",
     "GetUILanguage / SetUILanguage", 16104, 16129),
    ("40_window/300_ui_controls.lua", "window.ui_controls",
     "Điều khiển UI: font, scale, kích thước, blur, opacity", 16130, 16287),
    ("40_window/310_ui_profile.lua", "window.ui_profile",
     "Lưu/đọc/xoá profile giao diện + import/export JSON", 16288, 16426),
    ("40_window/320_island_settings.lua", "window.island_settings",
     "Bảng mặc định __NgotIslandSettings + helper đổi setting", 16427, 16814),
    ("40_window/330_island_tab.lua", "window.island_tab",
     "Tab bảng nổi: toggle/slider theme/ngôn ngữ", 16815, 17059),
    ("40_window/340_music_fm_tab.lua", "window.music_tab",
     "Tab nhạc + AI prompt + file manager trong tab island", 17060, 17212),

    # ── 45 · Notify + đóng module 3e ───────────────────────────────────────────
    ("45_notify/010_notify.lua", "notify",
     "LIB:Notify - thẻ thông báo, icon, duration, tự đóng", 17213, 17280),
    ("20_lib/890_module_close.lua", "lib.module_close",
     "Đóng closure 3e: return LIB / end; / };", 17281, 17284),

    # ── 50 · icon ────────────────────────────────────────────────────────────
    ("50_icons/020_module_open.lua", "icons.module_open",
     "Mở module 40 (spritesheet): registry + closure", 17315, 17318),
    ("50_icons/030_spritesheets.lua", "icons.spritesheets",
     "16 spritesheet rbxassetid + mở bảng Icons", 17319, 17336),
    ("50_icons/900_close.lua", "icons.close",
     "Đóng bảng Icons, bảng trả về, closure, module", 25077, 25081),
    ("50_icons/010_iconmodule.lua", "icons.iconmodule",
     "Module 3f: IconModule.Icon()/SetIconsType()", 17285, 17314),

    # ── 60 · runtime: log / debug ──────────────────────────────────────────────
    ("60_runtime/000_lib_assign.lua", "runtime.lib_assign",
     "LIB = require(module 3e) - bàn giao thư viện cho phần runtime", 25082, 25082),
    ("60_runtime/010_startup_error.lua", "runtime.startup_error",
     "Hộp thoại + cảnh báo lỗi khởi động (__xNgotShowStartupError)", 25084, 25172),
    ("60_runtime/020_create_window_guard.lua", "runtime.create_window_guard",
     "Bọc LIB:CreateWindow bằng xpcall + LIB.ShowStartupError", 25173, 25191),
    ("60_runtime/030_log_core.lua", "runtime.log_core",
     "Bảng Log + trimText/looksLikeSelf/safe", 25192, 25260),
    ("60_runtime/040_log_api.lua", "runtime.log_api",
     "Log: add/fromPrint/filter/export/hookConsole + mức log", 25261, 25469),
    ("60_runtime/050_devtools.lua", "runtime.devtools",
     "DevTools: note/vars/executors/run/selftest/report", 25470, 25636),
    ("60_runtime/060_http_log.lua", "runtime.http_log",
     "Hook http_request để ghi log request/response", 25637, 25667),
    ("60_runtime/070_debug_bridge.lua", "runtime.debug_bridge",
     "__xNgotDebugBridge: open/close/show/notify/playMusic/state/report", 25668, 25834),
    ("60_runtime/080_debug_panel.lua", "runtime.debug_panel",
     "Debug: panel log, export, toggle/open/close", 25835, 26019),

    # ── 70 · boot ─────────────────────────────────────────────────────────────
    ("70_boot/010_state.lua", "boot.state",
     "_G.__xNgotEmbeddedLibrary + __xNgotBoot + Opts", 26020, 26061),
    ("70_boot/020_helpers.lua", "boot.helpers",
     "bootEnv/bootSafe/bootTrace", 26062, 26077),
    ("70_boot/030_log.lua", "boot.log",
     "__xNgotBoot.log/info/warn/error/recordError", 26078, 26101),
    ("70_boot/040_io.lua", "boot.io",
     "bootUserGui / bootRead / bootFetch", 26102, 26130),
    ("70_boot/050_sources.lua", "boot.sources",
     "bootClean + bootSources (nguồn nhúng / local / remote)", 26131, 26192),
    ("70_boot/060_debug.lua", "boot.debug",
     "__xNgotBoot.openDebug / attachDebug", 26193, 26266),
    ("70_boot/070_performance.lua", "boot.performance",
     "performance() / lowPower() / confirmRun()", 26267, 26297),
    ("70_boot/080_start_a.lua", "boot.start_a",
     "__xNgotBoot.start() phần đầu: nạp cấu hình, chọn nguồn", 26298, 26365),
    ("70_boot/085_start_b.lua", "boot.start_b",
     "createWindow() + vòng thử nguồn + selftest + Stage=ready", 26366, 26503),
    ("70_boot/090_library_mode.lua", "boot.library_mode",
     "LIB.Version, OpenXNgotHub, cờ xNgotLibraryOnly", 26504, 26514),
    ("70_boot/099_return.lua", "boot.return", "return LIB - điểm kết thúc chunk", 26515, 26515),
]

# Dòng bị thay thế (không lấy nguyên văn)
REPLACED = {
    201: "local LIB",
    25082: 'LIB = require(NgotStudio["3e"])',
}

# Dòng bị bỏ / bị thay (không thuộc module nào)
DROPPED = {
    19: "gỡ closure ngoài cùng `local LIB = (function()`",
    25083: "gỡ `end)()` của closure ngoài cùng",
    26021: "gỡ `return LIB` của closure ngoài cùng",
    26022: "gỡ `end)()` của closure ngoài cùng",
}

FOLDERS = {
    "00_header": "modules/00_header",
    "10_config": "modules/10_config",
    "20_lib": "modules/20_lib",
    "30_overlay": "modules/30_overlay",
    "40_window": "modules/40_window",
    "45_notify": "modules/45_notify",
    "50_icons": "modules/50_icons",
    "60_runtime": "modules/60_runtime",
    "70_boot": "modules/70_boot",
}


def banner(rel: str, module_id: str, role: str, first: int, last: int, delta: int,
           lines: int | None = None, note: str | None = None) -> str:
    folder = rel.split("/")[0]
    lines = (last - first + 1) if lines is None else lines
    extra = ("     note   : %s\n" % note) if note else ""
    return (
        "--[[ xngot-studio · src/modules/%s\n"
        "     lang   : lua (Luau / Roblox) · executor\n"
        "     folder : src/modules/%s · %s\n"
        "     module : %s\n"
        "     role   : %s\n"
        "     source : main 2.txt L%d-%d · %d dòng · delta %+d\n"
        "%s"
        "--]]\n"
        % (rel, folder, FOLDER_DESC[folder], module_id, role, first, last, lines, delta, extra)
    )


def lucide_shards(lines: list[str], start: int, end: int) -> list[tuple[str, int, int]]:
    """Chia khối icon thành từng tệp theo chữ cái đầu của tên icon."""
    keys = []
    for line in lines[start - 1:end]:
        m = re.match(r'^\t*\["(.+?)"\] = \{', line)
        if m:
            keys.append(m.group(1))
    # mỗi entry đúng 5 dòng (key + 3 trường + đóng), chia theo chữ cái đầu
    shards: list[tuple[str, int, int]] = []
    cur = None
    begin = start
    for index, key in enumerate(keys):
        head = key[0].lower()
        line = start + index * 5
        if cur is None:
            cur = head
        elif head != cur:
            shards.append((cur, begin, line - 1))
            cur = head
            begin = line
    shards.append((cur, begin, start + len(keys) * 5 - 1))
    return shards


def slug(char: str) -> str:
    return char if char.isalnum() else "num"


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    src_path, repo = sys.argv[1], sys.argv[2]
    with open(src_path, encoding="utf-8") as fh:
        text = fh.read()
    lines = text.split("\n")
    if lines and lines[-1] == "":
        lines = lines[:-1]
    total = len(lines)

    slices = list(SLICES)

    # Chèn shard icon vào giữa 030_spritesheets và 900_close
    icons_first, icons_last = 17337, 25076
    shard_files = []
    for char, a, b in lucide_shards(lines, icons_first, icons_last):
        name = "50_icons/040_icons_%s.lua" % slug(char)
        if name not in [s[0] for s in shard_files]:
            shard_files.append((name, "icons.icons.%s" % slug(char),
                                "nhóm icon '%s' — %d icon, tiếp nối bảng Icons"
                            % (char, (b - a + 1) // 5), a, b))
    shards = sorted(shard_files, key=lambda s: s[3])
    pos = [i for i, s in enumerate(slices) if s[0] == "50_icons/900_close.lua"][0]
    slices = slices[:pos] + shards + slices[pos:]

    # Sắp theo dòng bắt đầu: manifest = đúng thứ tự ghép của bản gốc
    slices.sort(key=lambda item: (item[3], item[4]))

    # Kiểm tra phủ kín 1..total
    covered = {}
    for path, mid, role, a, b in slices:
        for n in range(a, b + 1):
            if n in covered:
                raise SystemExit("dòng %d bị trùng: %s và %s" % (n, covered[n], path))
            covered[n] = path
    missing = [n for n in range(1, total + 1)
               if n not in covered and n not in DROPPED and n not in REPLACED]
    if missing:
        raise SystemExit("thiếu %d dòng, ví dụ: %s" % (len(missing), missing[:12]))

    # Ghi module
    modules = []
    for path, mid, role, a, b in slices:
        kept = [(n, REPLACED.get(n, lines[n - 1]))
                for n in range(a, b + 1) if n not in DROPPED]
        body = "\n".join(text for _, text in kept) + "\n"
        delta = do_khoi(body)
        gone = [n for n in range(a, b + 1) if n in DROPPED]
        notes = []
        if gone:
            notes.append("đã bỏ %s (closure ngoài cùng, xem docs/PROVENANCE.md)" % ", ".join(map(str, gone)))
        swapped = [n for n in range(a, b + 1) if n in REPLACED]
        if swapped:
            notes.append("dòng %s viết lại: %s" % (", ".join(map(str, swapped)),
                                                  " / ".join(REPLACED[n] for n in swapped)))
        note = "; ".join(notes) or None
        head = banner(path, mid, role, a, b, delta, lines=len(kept), note=note)
        target = os.path.join(repo, "src", "modules", path)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with open(target, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(head + body)
        modules.append({
            "id": mid,
            "path": path,
            "role": role,
            "from": a,
            "to": b,
            "lines": len(kept),
            "delta": delta,
            "sha256": sha256(body),
        })

    manifest = {
        "name": "xngot-studio",
        "title": "xNgot Library · Thư viện UI (Roblox)",
        "version": "3.0.0",
        "entry": "xngot_studio.lua",
        "release_entry": "main.lua",
        "source": {
            "file": "main 2.txt",
            "lines": total,
            "sha256": sha256(text),
        },
        "source_transforms": {
            "dropped_lines": sorted(n for n in DROPPED if n not in REPLACED),
            "replaced_lines": {str(k): v for k, v in
                               REPLACED.items()},
        },
        "modules": modules,
    }
    os.makedirs(os.path.join(repo, "src"), exist_ok=True)
    with open(os.path.join(repo, "src", "manifest.json"), "w", encoding="utf-8", newline="\n") as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)
        fh.write("\n")

    print("✔ %d module · %d dòng nguồn · %d tệp shard icon" % (len(modules), total, len(shards)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
