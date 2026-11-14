# tools/test_gui_cleanup.py
# lang   : python 3 (+ lupa: Lua 5.4 thật)
# folder : tools · kiểm thử logic dọn GUI bằng Lua runtime giả lập Roblox
# role   : chạy khối XN-GUI-CLEANUP của 20_lib/020_template_01.lua trên các
#          tình huống dựng sẵn để chắc nó diệt đúng UI cũ và không diệt UI lạ.
#
# Dùng: python3 tools/test_gui_cleanup.py

import os
import sys

try:
    from lupa import LuaRuntime
except ImportError:
    print("  ! thiếu lupa · pip install lupa")
    raise SystemExit(2)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATE = os.path.join(ROOT, "src", "modules", "20_lib", "020_template_01.lua")

MOCK = r"""
-- ===== giả lập tối thiểu API Roblox =====
destroyed = {}
all = {}

local function isInst(v) return type(v) == "table" and v.__inst == true end
typeof = function(v) if isInst(v) then return "Instance" end return type(v) end

Instance = {}
function Instance.new(className, name)
	local self = { __inst = true, ClassName = className, Name = name or className, _kids = {} }
	all[#all + 1] = self
	function self:IsA(cls) return self.ClassName == cls end
	function self:FindFirstChild(name)
		for _, k in ipairs(self._kids) do
			if k.Name == name then return k end
		end
		return nil
	end
	function self:GetChildren()
		local out = {}
		for i, k in ipairs(self._kids) do out[i] = k end
		return out
	end
	function self:Destroy()
		destroyed[self] = true
		for _, k in ipairs(self._kids) do k:Destroy() end
	end
	function self:AddChild(k) self._kids[#self._kids + 1] = k return k end
	return self
end

coreGui = Instance.new("CoreGui", "CoreGui")
playerGui = Instance.new("PlayerGui", "PlayerGui")
lighting = Instance.new("Lighting", "Lighting")

services = { CoreGui = coreGui, PlayerGui = playerGui, Lighting = lighting,
	Players = { LocalPlayer = { __inst = true, Name = "LocalPlayer",
		FindFirstChildOfClass = function(_, cls) if cls == "PlayerGui" then return playerGui end end } } }

game = { GetService = function(_, name) return services[name] or Instance.new(name) end }
gethui = function() return playerGui end
cloneref = nil
"""

HARNESS = r"""
function make_old_gui(variant)
	local gui = Instance.new("ScreenGui", "NgotStudio")
	if variant == "renamed_with_window" then
		gui.Name = "xNgọt Studio"
		-- bản build thật: ModuleScript 3e + NotificationList + Folder chứa cửa sổ
		gui:AddChild(Instance.new("ModuleScript", "3e"))
		gui:AddChild(Instance.new("NotificationList"))
		local folder = Instance.new("Folder", "Folder")
		local win = Instance.new("Frame", "xNgọt Studio")
		win:AddChild(Instance.new("Frame", "TopFrame"))
		win:AddChild(Instance.new("ScrollingFrame", "TabButtons"))
		folder:AddChild(win)
		gui:AddChild(folder)
	elseif variant == "renamed_minimal" then
		gui.Name = "xNgọt Studio"
		local folder = Instance.new("Folder", "Folder")
		local win = Instance.new("Frame", "xNgọt Studio")
		win:AddChild(Instance.new("Frame", "TopFrame"))
		win:AddChild(Instance.new("ScrollingFrame", "TabButtons"))
		folder:AddChild(win)
		gui:AddChild(folder)
	elseif variant == "legacy_name" then
		gui.Name = "NgotStudio"
	elseif variant == "island" then
		gui.Name = "xNgotStudio_FullDynamicIsland"
	else
		error("variant lạ")
	end
	playerGui:AddChild(gui)
	return gui
end

function make_foreign_gui()
	local gui = Instance.new("ScreenGui", "SomeGameUI")
	local frame = Instance.new("Frame", "Main")
	frame:AddChild(Instance.new("Frame", "TopFrame"))
	gui:AddChild(frame)
	coreGui:AddChild(gui)
	return gui
end

function is_dead(inst)
	local seen = {}
	local function check(i)
		if destroyed[i] then return true end
		for _, k in ipairs(i._kids) do if check(k) then return true end end
		return false
	end
	return check(inst)
end
"""

CASES = [
    ("renamed_with_window", True),
    ("renamed_minimal", True),
    ("legacy_name", True),
    ("island", True),
]


def main() -> int:
    lua = LuaRuntime(unpack_returned_tuples=True)
    with open(TEMPLATE, encoding="utf-8") as fh:
        text = fh.read()
    start = text.index("local __xNgotIsInstance")
    end = text.index('NgotStudio["1"] = Instance.new("ScreenGui");')
    block = text[start:end]

    open_path = os.path.join(ROOT, "src", "modules", "40_window", "010_open.lua")
    with open(open_path, encoding="utf-8") as fh:
        open_text = fh.read()
    singleton = open_text[open_text.index("local OwnerToken = {}"):open_text.index("function LIB:CreateWindow(data)")]

    lua.execute(MOCK)
    lua.execute(HARNESS)

    failures = 0
    for variant, should_die in CASES:
        lua.execute("__gui = make_old_gui(%r)" % variant)
        lua.execute("__foreign = make_foreign_gui()")
        lua.execute("__tracked_before = _G.__xNgotStudioGui")
        result = lua.execute("return pcall(function()\n" + block + "\nend)")
        ok, err = (result if isinstance(result, tuple) else (result, None))
        if not ok:
            print("  ✘ %-22s lỗi khi chạy: %s" % (variant, err))
            failures += 1
            continue
        dead = lua.eval("is_dead(__gui)")
        foreign_dead = lua.eval("is_dead(__foreign)")
        status = "✔" if (dead == should_die and not foreign_dead) else "✘"
        if status == "✘":
            failures += 1
        print("  %s %-22s UI cũ bị dọn: %-5s · UI lạ còn nguyên: %s"
              % (status, variant, str(bool(dead)), str(not foreign_dead)))

    # ── CleanupOtherInstances (chạy mỗi lần CreateWindow) ───────────────────
    lua.execute("__ours = make_old_gui('renamed_with_window')")
    lua.execute("Gui = __ours")
    lua.execute("__prev_window_destroyed = false")
    lua.execute("_G.xNgotStudio = { Window = { Destroy = function() __prev_window_destroyed = true end } }")
    lua.execute("_G.Window = _G.xNgotStudio.Window")
    lua.execute("__foreign2 = make_foreign_gui()")
    lua.execute("__other_lib = make_old_gui('renamed_minimal')")
    wrapped = "local function __run()\n" + singleton + "\nCleanupOtherInstances()\nend"
    result = lua.execute("return pcall(function()\n" + wrapped + "\n__run()\nend)")
    ok, err = (result if isinstance(result, tuple) else (result, None))
    checks = [
        ("cửa sổ bản cũ được Destroy()", lua.eval("__prev_window_destroyed") is True),
        ("GUI thư viện khác bị dọn", lua.eval("is_dead(__other_lib)") is True),
        ("GUI của mình còn nguyên", not lua.eval("is_dead(__ours)")),
        ("UI game không bị đụng", not lua.eval("is_dead(__foreign2)")),
    ]
    if not ok:
        print("  ✘ CleanupOtherInstances lỗi: %s" % err)
        failures += 1
    for label, passed in checks:
        print("  %s %s" % ("✔" if passed else "✘", label))
        if not passed:
            failures += 1

    # chạy lần hai: không còn gì để dọn, không được lỗi
    result = lua.execute("return pcall(function()\n" + block + "\nend)")
    ok, err = (result if isinstance(result, tuple) else (result, None))
    print("  %s chạy lại (idempotent): %s" % ("✔" if ok else "✘", "ok" if ok else err))
    if not ok:
        failures += 1

    print()
    print("  KẾT LUẬN: %s" % ("TẤT CẢ ĐẠT ✔" if failures == 0 else "CÓ %d LỖI ✘" % failures))
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
