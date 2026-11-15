--[[ xngot-studio · src/modules/40_window/230_toggle_key.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.toggle_key
     role   : SetToggleKey/SetToggleButtonPlatform/EditOpenButton
     source : main 2.txt L14310-14366 · 57 dòng · delta +0
--]]
			function Window:SetToggleKey(newKey)
				local resolved = newKey
				if type(newKey) == "string" then
					resolved = Enum.KeyCode[newKey]
				end
				if resolved then Window.ToggleKey = resolved end
				return Window.ToggleKey
			end

			 
			 
			function Window:SetToggleButtonPlatform(platform)
				local normalized = tostring(platform or "Both")
				if normalized ~= "Mobile" and normalized ~= "Both" then normalized = "Both" end
				Window.ToggleButtonPlatform = normalized
				 
				 
				if normalized == "Mobile" and not UIS.TouchEnabled then
					newFloatingIcon.Visible = false
				elseif newWindow.Visible == false then
					newFloatingIcon.Visible = true
				end
				return Window.ToggleButtonPlatform
			end

			function Window:GetToggleButtonPlatform()
				return Window.ToggleButtonPlatform
			end

			local oldFloatingSize = newFloatingIcon.Size
			function Window:EditOpenButton(data)
				data = data or {}
				if data.Title ~= nil then
					newFloatingIcon.TextLabel.Text = tostring(data.Title)
				end
				if data.Icon ~= nil then
					ApplyIcon(newFloatingIcon.Icon, data.Icon)
				end
				if data.OpenIcon ~= nil then
					ApplyIcon(newFloatingIcon.Open, data.OpenIcon)
				end
				if data.Size then
					newFloatingIcon.Size = data.Size
					oldFloatingSize = data.Size
				end
				if data.Position then newFloatingIcon.Position = data.Position end
				if data.BackgroundColor3 then newFloatingIcon.BackgroundColor3 = data.BackgroundColor3 end
				if data.TextColor3 then newFloatingIcon.TextLabel.TextColor3 = data.TextColor3 end
				if data.IconColor3 then newFloatingIcon.Icon.ImageColor3 = data.IconColor3 end
				if data.OpenIconColor3 then newFloatingIcon.Open.ImageColor3 = data.OpenIconColor3 end
				if data.ShowText ~= nil then newFloatingIcon.TextLabel.Visible = data.ShowText == true end
				if data.CornerRadius and newFloatingIcon:FindFirstChildOfClass("UICorner") then
					newFloatingIcon:FindFirstChildOfClass("UICorner").CornerRadius = data.CornerRadius
				end
				return newFloatingIcon
			end

