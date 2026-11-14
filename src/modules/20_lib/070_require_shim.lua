--[[ xngot-studio · src/modules/20_lib/070_require_shim.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.require
     role   : Shim require() nội bộ: NgotStudio_MODULES + require gốc
     source : main 2.txt L2453-2466 · 14 dòng · delta +0
--]]
local NgotStudio_REQUIRE = require;
local NgotStudio_MODULES = {};
local function require(Module:ModuleScript)
	local ModuleState = NgotStudio_MODULES[Module];
	if ModuleState then
		if not ModuleState.Required then
			ModuleState.Required = true;
			ModuleState.Value = ModuleState.Closure();
		end
		return ModuleState.Value;
	end;
	return NgotStudio_REQUIRE(Module);
end

