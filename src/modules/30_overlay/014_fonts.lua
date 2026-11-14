--[[ xngot-studio · src/modules/30_overlay/014_fonts.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.fonts
     role   : VERSION, FAMILY font, bảng Fonts, rgb()
     source : main 2.txt L2817-2830 · 14 dòng · delta +0
--]]
		    local VERSION = "3.0.0"

		    local FAMILY = "rbxasset://fonts/families/GothamSSm.json"
		    local Fonts = {
		        Regular = Font.new(FAMILY, Enum.FontWeight.Regular),
		        Medium = Font.new(FAMILY, Enum.FontWeight.Medium),
		        Semibold = Font.new(FAMILY, Enum.FontWeight.SemiBold),
		        Bold = Font.new(FAMILY, Enum.FontWeight.Bold),
		    }

		    local function rgb(r, g, b)
		        return Color3.fromRGB(r, g, b)
		    end

