--[[ xngot-studio · src/modules/40_window/250_toggle_window.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.toggle_window
     role   : toggleButtonAllowed, ToggleWindow, Show/Hide/Toggle
     source : main 2.txt L14509-14597 · 89 dòng · delta +0
--]]
			local function toggleButtonAllowed()
				return Window.ToggleButtonPlatform ~= "Mobile" or UIS.TouchEnabled
			end

			local function ToggleWindow(state)
				if windowDestroyed then return end
				if state == true then
					oldFloatingSize = newFloatingIcon.Size

					newWindow.Size = UDim2.fromOffset(0,0)
					newWindow.Visible = true
					do local dropShadow = newWindow:FindFirstChild("DropShadow") if dropShadow then pcall(function() dropShadow.Visible = true end) end end

					Tween(newFloatingIcon, {Size = UDim2.new(0,0,0,0)}, TweenConfigs.Global)
					Tween(newWindow, {Size = oldWindowSize}, TweenConfigs.Global)
						.Completed:Wait()
					newWindow.Tabs.Visible = true
					newWindow.TabButtons.Visible = true

					newFloatingIcon.Visible = false
					windowstate = true
				elseif state == false then
					oldWindowSize = newWindow.Size

					newFloatingIcon.Size = UDim2.fromOffset(0,0)
					newFloatingIcon.Visible = toggleButtonAllowed()

					newWindow.Tabs.Visible = false
					newWindow.TabButtons.Visible = false
					do local dropShadow = newWindow:FindFirstChild("DropShadow") if dropShadow then pcall(function() dropShadow.Visible = false end) end end

					Tween(newFloatingIcon, {Size = oldFloatingSize}, TweenConfigs.Global)
					Tween(newWindow, {Size = UDim2.fromOffset(0,0)}, TweenConfigs.Global)
						.Completed:Wait()
					newWindow.Visible = false
					windowstate = false
				else
					if windowstate then
						oldWindowSize = newWindow.Size

						newFloatingIcon.Size = UDim2.fromOffset(0,0)
						newFloatingIcon.Visible = toggleButtonAllowed()

						newWindow.Tabs.Visible = false
						newWindow.TabButtons.Visible = false
						do local dropShadow = newWindow:FindFirstChild("DropShadow") if dropShadow then pcall(function() dropShadow.Visible = false end) end end

						Tween(newFloatingIcon, {Size = oldFloatingSize}, TweenConfigs.Global)
						Tween(newWindow, {Size = UDim2.fromOffset(0,0)}, TweenConfigs.Global)
							.Completed:Wait()
						newWindow.Visible = false

						windowstate = false
					else
						oldFloatingSize = newFloatingIcon.Size

						newWindow.Size = UDim2.fromOffset(0,0)
						newWindow.Visible = true

						do local dropShadow = newWindow:FindFirstChild("DropShadow") if dropShadow then pcall(function() dropShadow.Visible = true end) end end

						Tween(newFloatingIcon, {Size = UDim2.new(0,0,0,0)}, TweenConfigs.Global)
						Tween(newWindow, {Size = oldWindowSize}, TweenConfigs.Global)
							.Completed:Wait()
						newWindow.Tabs.Visible = true
						newWindow.TabButtons.Visible = true

						newFloatingIcon.Visible = false

						windowstate = true
					end
				end
			end

			function Window:Show()
				if not startupGatePassed then return end
				if not windowstate then ToggleWindow(true) end
			end

			function Window:Hide()
				if not startupGatePassed then return end
				if windowstate then ToggleWindow(false) end
			end

			function Window:Toggle(state)
				if not startupGatePassed then return end
				ToggleWindow(state)
			end

