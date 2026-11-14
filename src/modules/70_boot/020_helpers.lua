--[[ xngot-studio · src/modules/70_boot/020_helpers.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.helpers
     role   : bootEnv/bootSafe/bootTrace
     source : main 2.txt L26062-26077 · 16 dòng · delta +0
--]]
local function bootEnv()
	return type(getgenv) == "function" and getgenv() or _G
end

local function bootSafe(value)
	local ok, text = pcall(tostring, value)
	return ok and text or "<không đọc được>"
end

local function bootTrace(err)
	if debug and type(debug.traceback) == "function" then
		return debug.traceback(bootSafe(err), 2)
	end
	return bootSafe(err)
end

