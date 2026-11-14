--[[ xngot-studio · src/stubs/debug_bridge.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/stubs · thay thế cho module khi build --release
     module : stub.debug_bridge
     role   : Bridge debug rỗng — _G.xNgotDebugBridge vẫn tồn tại nhưng không làm gì
     source : viết tay (không có trong bản gốc)
--]]
local env = type(getgenv) == "function" and getgenv() or _G

local Bridge = {}
Bridge.Version = "3.0.0-stub"
Bridge.stub = true

local function noop() return nil end
Bridge.open = noop
Bridge.close = noop
Bridge.show = noop
Bridge.notify = noop
Bridge.playMusic = noop
Bridge.timer = noop
Bridge.state = function() return { stub = true } end
Bridge.report = function() return { stub = true } end
Bridge.copyLog = noop
Bridge.copyReport = noop

local __xNgotDebugBridge = function()
	env.xNgotDebugBridge = Bridge
	if _G ~= env then _G.xNgotDebugBridge = Bridge end
	return Bridge
end

__xNgotDebugBridge()
