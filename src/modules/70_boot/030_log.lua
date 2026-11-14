--[[ xngot-studio · src/modules/70_boot/030_log.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.log
     role   : __xNgotBoot.log/info/warn/error/recordError
     source : main 2.txt L26078-26101 · 24 dòng · delta +0
--]]
function __xNgotBoot.log(level, message)
	local line = bootSafe(message)
	__xNgotBoot.Log[#__xNgotBoot.Log + 1] = string.format("[%s] %s", bootSafe(level), line)
	local logApi = _G.xNgotLog
	if logApi and type(logApi[level]) == "function" then
		pcall(logApi[level], "boot", line)
	else
		pcall(print, "[xNgotStudio] [" .. bootSafe(level) .. "] " .. line)
	end
	return line
end

function __xNgotBoot.info(message) return __xNgotBoot.log("info", message) end
function __xNgotBoot.warn(message) return __xNgotBoot.log("warn", message) end
function __xNgotBoot.error(message) return __xNgotBoot.log("error", message) end

function __xNgotBoot.recordError(phase, reason)
	local message = "[" .. bootSafe(phase) .. "] " .. bootSafe(reason)
	bootEnv().xNgotStudioLastStartupError = message
	__xNgotBoot.Stage = "error:" .. bootSafe(phase)
	__xNgotBoot.error(message)
	return message
end

