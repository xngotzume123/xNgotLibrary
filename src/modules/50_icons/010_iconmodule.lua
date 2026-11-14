--[[ xngot-studio · src/modules/50_icons/010_iconmodule.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/50_icons · bộ icon dựng sẵn (16 spritesheet, 1.548 icon)
     module : icons.iconmodule
     role   : Module 3f: IconModule.Icon()/SetIconsType()
     source : main 2.txt L17285-17314 · 30 dòng · delta +0
--]]
NgotStudio_MODULES[NgotStudio["3f"]] = {
	Closure = function()
		local script = NgotStudio["3f"];

		local Icons = {
			["lucide"] = require(script.Lucide),
		}

		local IconModule = {
			IconsType = "lucide"
		}

		function IconModule.SetIconsType(iconType)
			IconModule.IconsType = iconType
		end

		function IconModule.Icon(Icon, Type)
			local iconType = Icons[Type or IconModule.IconsType]
			if not iconType or type(iconType.Icons) ~= "table" or type(Icon) ~= "string" then return nil end
			local iconData = iconType.Icons[Icon]
			if iconData then
				return { iconType.Spritesheets[tostring(iconData.Image)], iconData }
			end
			return nil
		end

		return IconModule

	end;
};
