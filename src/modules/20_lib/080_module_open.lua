--[[ xngot-studio · src/modules/20_lib/080_module_open.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.module_open
     role   : Mở module 3e: bảng NgotStudio_MODULES + closure + IconModule
     source : main 2.txt L2467-2470 · 4 dòng · delta +1
--]]
NgotStudio_MODULES[NgotStudio["3e"]] = {
	Closure = function()
		local script = NgotStudio["3e"];local LIB = {}
		local IconModule = require(script.IconModule)
