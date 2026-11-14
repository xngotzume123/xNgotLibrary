--[[ xngot-studio · src/stubs/debug_panel.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/stubs · thay thế cho module khi build --release
     module : stub.debug_panel
     role   : Debug rỗng — không panel, chỉ trả về log dạng bảng
     source : viết tay (không có trong bản gốc)
--]]
local Debug = {}
Debug.Version = "3.0.0-stub"
Debug.stub = true
Debug.hotkey = "RightShift"
Debug.cycles = 0

local function noop() return false end

function Debug.getLogPanel()
	local lines = {}
	local api = type(Log) == "table" and Log or nil
	if api and type(api.entries) == "table" then
		for _, entry in ipairs(api.entries) do
			lines[#lines + 1] = string.format("%s [%s] %s: %s", tostring(entry.time), tostring(entry.level),
				tostring(entry.tag), tostring(entry.message))
		end
	end
	return table.concat(lines, "\n")
end

Debug.exportLog = Debug.getLogPanel
Debug.openPanel = noop
Debug.closePanel = noop
Debug.toggle = noop
Debug.open = noop
Debug.mode = function() return "stub" end
Debug.report = function() return { stub = true, cycles = 0 } end

local env = type(getgenv) == "function" and getgenv() or _G
env.xNgotDebug = Debug
if _G ~= env then
	pcall(function() _G.xNgotDebug = Debug end)
end
