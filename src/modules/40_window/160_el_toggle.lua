--[[ xngot-studio · src/modules/40_window/160_el_toggle.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_toggle
     role   : Tab:Toggle
     source : main 2.txt L12919-13072 · 154 dòng · delta +0
--]]
				function Tab:Toggle(data)
					data = data or {}
					local Toggle = {
						Title = data.Title or "Toggle",
						Desc = data.Desc,
						State = data.Default ~= nil and data.Default or (data.Value ~= nil and data.Value or false),
						Locked = data.Locked or false,
						Icon = data.Icon,
						Callback = type(data.Callback) == "function" and data.Callback or function() end
					}

                    local name = Toggle.Title
                    if CONFIGLOADED and CONFIG[NAMETAB][name] ~= nil then
                        Toggle.State = CONFIG[NAMETAB][name]
                    elseif not CONFIGLOADED or CONFIG[NAMETAB][name] == nil then
                        CONFIG[NAMETAB][name] = Toggle.State
                    end

					local newToggle = Templates.Toggle:Clone()
					newToggle.Name = Toggle.Title
					newToggle.Parent = parentElement
					newToggle.Title.Text = Toggle.Title

					if Toggle.Icon then ApplyIcon(newToggle.Title.Fill.Ball.Icon, Toggle.Icon) end

					if Toggle.Desc and Toggle.Desc ~= "" then
						newToggle.Description.Visible = true
						newToggle.Description.Text = Toggle.Desc
					end

					if Toggle.State == true then
						newToggle.Title.Fill.Ball.Position = UDim2.new(0.5, 0,0.5, 0)
						newToggle.Title.Fill.BackgroundColor3 = UISettings.AccentColor
						newToggle.Title.Fill.Ball.Icon.ImageTransparency = 0
					else
						newToggle.Title.Fill.Ball.Position = UDim2.new(0, 0,0.5, 0)
						newToggle.Title.Fill.BackgroundColor3 = Color3.fromRGB(53, 56, 62)
						newToggle.Title.Fill.Ball.Icon.ImageTransparency = 1
					end

					if Toggle.Locked then

						newToggle.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newToggle.BackgroundColor3 = Color3.fromRGB(32, 35, 40)

						newToggle.Title.TextColor3 = Color3.fromRGB(75, 77, 83)

						newToggle.Description.TextColor3 = Color3.fromRGB(75, 77, 83)

						newToggle.Title.Fill.BackgroundTransparency = 0.7
						newToggle.Title.Fill.Ball.BackgroundTransparency = 0.7
					end

					newToggle.Visible = true

					newToggle.Title.Fill.MouseEnter:Connect(function()
						if not Toggle.Locked then
							Tween(newToggle.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
						end
					end)

					newToggle.Title.Fill.MouseLeave:Connect(function()
						if not Toggle.Locked then
							Tween(newToggle.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)

							newToggle.BackgroundColor3 = Color3.fromRGB(42, 45, 52)
							Tween(newToggle.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
							Tween(newToggle.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						end
					end)

					local function AnimateSwitch(targetState)
						if targetState == true then
							Tween(newToggle.Title.Fill.Ball, {Position = UDim2.new(0.5, 0,0.5, 0)}, TweenConfigs.Global)
							Tween(newToggle.Title.Fill, {BackgroundColor3 = UISettings.AccentColor}, TweenConfigs.Global)

							Tween(newToggle.Title.Fill.Ball.Icon, {ImageTransparency = 0}, TweenConfigs.Global)
						elseif targetState == false then
							Tween(newToggle.Title.Fill.Ball, {Position = UDim2.new(0, 0,0.5, 0)}, TweenConfigs.Global)
							Tween(newToggle.Title.Fill, {BackgroundColor3 = Color3.fromRGB(53, 56, 62)}, TweenConfigs.Global)

							Tween(newToggle.Title.Fill.Ball.Icon, {ImageTransparency = 1}, TweenConfigs.Global)
						end
					end

					local function SetState(newState)
                        if newState == nil then
                            newState = not Toggle.State
                        else
                            newState = newState == true
                        end

                        AnimateSwitch(newState)

						Toggle.State = newState
						Toggle.Callback(Toggle.State)
                        CONFIG[NAMETAB][name] = Toggle.State
                        SAVECONFIG()

					end

					newToggle.Title.Fill.MouseButton1Click:Connect(function()
						if not Toggle.Locked then
							SetState()
						end
					end)

					function Toggle:SetTitle(newText)
						Toggle.Title = tostring(newText or "Toggle")
						newToggle.Name = Toggle.Title
						newToggle.Title.Text = Toggle.Title
					end

					function Toggle:SetDesc(newDesc)
						Toggle.Desc = tostring(newDesc or "")
						newToggle.Description.Text = Toggle.Desc
						newToggle.Description.Visible = Toggle.Desc ~= ""
					end

					function Toggle:Set(newState)
						SetState(newState)
					end

					function Toggle:Lock()
						Toggle.Locked = true
						Tween(newToggle, {BackgroundColor3 = Color3.fromRGB(32, 35, 40)}, TweenConfigs.Global)
						Tween(newToggle.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)
						Tween(newToggle.Title, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
						Tween(newToggle.Description, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)

						Tween(newToggle.Title.Fill, {BackgroundTransparency = 0.7}, TweenConfigs.Global)
						Tween(newToggle.Title.Fill.Ball, {BackgroundTransparency = 0.7}, TweenConfigs.Global)
					end

					function Toggle:Unlock()
						Toggle.Locked = false
						Tween(newToggle, {BackgroundColor3 = Color3.fromRGB(42, 45, 52)}, TweenConfigs.Global)
						Tween(newToggle.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newToggle.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newToggle.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)

						Tween(newToggle.Title.Fill, {BackgroundTransparency = 0}, TweenConfigs.Global)
						Tween(newToggle.Title.Fill.Ball, {BackgroundTransparency = 0}, TweenConfigs.Global)
					end

					function Toggle:Destroy()
						newToggle:Destroy()
					end

					Toggle.Callback(Toggle.State)

					return Toggle
				end

