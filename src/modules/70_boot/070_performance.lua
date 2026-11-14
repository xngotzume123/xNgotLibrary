--[[ xngot-studio · src/modules/70_boot/070_performance.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.performance
     role   : performance() / lowPower() / confirmRun()
     source : main 2.txt L26267-26297 · 31 dòng · delta +0
--]]
function __xNgotBoot.performance()
	local env = bootEnv()
	local window = env.Window or _G.Window
	local api = window and window.DynamicIsland or nil
	if not api then return nil end
	if type(api.State) == "function" then
		local ok, stats = pcall(api.State, api)
		if ok then return stats end
	end
	return nil
end

function __xNgotBoot.lowPower(on)
	local window = __xNgotBoot.Window or bootEnv().Window or _G.Window
	local island = type(window) == "table" and window.DynamicIsland or nil
	if type(island) ~= "table" then return false end
	local ok = pcall(function()
		if island.Set then
			island:Set("Ring", not on)
			island:Set("RimLight", not on)
			island:Set("Fps", not on)
		end
	end)
	__xNgotBoot.log(ok and "info" or "warn", "low power mode: " .. tostring(on))
	return ok
end

function __xNgotBoot.confirmRun(row)
	return true
end

