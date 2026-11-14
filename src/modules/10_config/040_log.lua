--[[ xngot-studio · src/modules/10_config/040_log.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/10_config · cấu hình nhạc toàn cục _G.xNgotMusicConfig
     module : config.log
     role   : Log riêng của lớp cấu hình (xoay vòng 120 dòng)
     source : main 2.txt L105-110 · 6 dòng · delta +0
--]]
local function log(...)
	if Config.debug then
		warn("[xNgotMusic] " .. table.concat({ ... }, " "))
	end
end

