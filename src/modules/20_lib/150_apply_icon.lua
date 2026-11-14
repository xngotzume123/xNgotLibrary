--[[ xngot-studio · src/modules/20_lib/150_apply_icon.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.icon
     role   : ApplyIcon(): gán icon hoặc ảnh cho ImageLabel
     source : main 2.txt L2745-2768 · 24 dòng · delta +0
--]]
		local function ApplyIcon(target, iconValue)
			if not target then return false end
			local value = tostring(iconValue or "")

			target.ImageRectOffset = Vector2.new(0, 0)
			target.ImageRectSize = Vector2.new(0, 0)

			if value == "" then
				target.Image = ""
				return false
			end

			local iconData = IconModule.Icon(value)
			if iconData then
				target.Image = iconData[1] or ""
				target.ImageRectOffset = iconData[2].ImageRectPosition or Vector2.new(0, 0)
				target.ImageRectSize = iconData[2].ImageRectSize or Vector2.new(0, 0)
				return true
			end

			target.Image = value
			return true
		end

