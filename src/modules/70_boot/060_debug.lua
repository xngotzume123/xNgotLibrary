--[[ xngot-studio · src/modules/70_boot/060_debug.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.debug
     role   : __xNgotBoot.openDebug / attachDebug
     source : main 2.txt L26193-26266 · 74 dòng · delta +0
--]]
function __xNgotBoot.openDebug()
	local debugApi = _G.xNgotDebug
	if debugApi and type(debugApi.openPanel) == "function" then
		if debugApi.Build == "release" then

			if type(debugApi.getLogPanel) == "function" then
				local okLog = pcall(debugApi.getLogPanel)
				__xNgotBoot.info(okLog
					and "bản phát hành không có panel — đã xuất log thật (clipboard + F9)"
					or "bản phát hành không có panel — chạy _G.xNgotDebug.getLogPanel() để lấy log")
				return false
			end
			return nil
		end
		local ok, opened = pcall(debugApi.openPanel)
		if ok then
			if opened ~= true then
				__xNgotBoot.warn("không mở được panel: " .. tostring(debugApi.error or "?"))
			end
			return opened
		end
	end
	__xNgotBoot.warn("panel debug không khả dụng (Iris chưa nạp)")
	return nil
end

function __xNgotBoot.attachDebug()
	local debugApi = _G.xNgotDebug
	if not debugApi or type(debugApi.attach) ~= "function" then
		__xNgotBoot.warn("không thấy xNgotDebug — bỏ qua panel")
		return false
	end
	if debugApi.Build == "release" then
		pcall(debugApi.attach)
		pcall(function()
			local env = bootEnv()
			env.xNgotPanel = function()
				if type(debugApi.getLogPanel) == "function" then pcall(debugApi.getLogPanel) end
				return debugApi.panel and debugApi.panel() or { build = "release" }
			end
			if _G ~= env then _G.xNgotPanel = env.xNgotPanel end
		end)
		__xNgotBoot.info("bản phát hành: không có panel Iris · lấy log bằng _G.xNgotDebug.getLogPanel()")
		return false
	end
	local ok = pcall(debugApi.attach)
	if ok then
		pcall(function()
			local env = bootEnv()
			debugApi.place = debugApi.place or function() end
			debugApi.panel = debugApi.panel or function()
				return {
					open = debugApi.isOpen == true,
					iris = debugApi.Iris ~= nil,
					cycles = debugApi.cycles or 0,
					error = debugApi.error,
					lastMs = debugApi.lastMs,
					hotkey = tostring(debugApi.hotkey),
				}
			end
			env.xNgotPanel = function(tab)
				debugApi.toggle(true)
				if type(debugApi.setTab) == "function" then pcall(debugApi.setTab, tab) end
				return debugApi.panel()
			end
			if _G ~= env then _G.xNgotPanel = env.xNgotPanel end
		end)
		__xNgotBoot.info("panel debug Iris đã gắn · RightShift bật/tắt · _G.xNgotDebug.openPanel() / _G.xNgotPanel()")
	else
		__xNgotBoot.warn("gắn panel lỗi")
	end
	return ok
end

