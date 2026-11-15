--[[ xngot-studio · src/modules/40_window/180_el_input.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_input
     role   : Tab:Input
     source : main 2.txt L13316-13489 · 174 dòng · delta +0
--]]
				function Tab:Input(data)
					data = data or {}
					local Input = {
						Title = data.Title or "Input",
						Desc = data.Desc,
						Placeholder = data.Placeholder or "",
						Default = data.Default or data.Value or "",
						Text = data.Default or data.Value or "",
						ClearTextOnFocus = data.ClearTextOnFocus or false,
						Locked = data.Locked or false,
						MultiLine = data.MultiLine or false,
						Callback = type(data.Callback) == "function" and data.Callback or function() end
					}

                    local name = Input.Title
                    if CONFIGLOADED and CONFIG[NAMETAB][name] ~= nil then
                        Input.Default = CONFIG[NAMETAB][name]
                    elseif not CONFIGLOADED or CONFIG[NAMETAB][name] == nil then
                        CONFIG[NAMETAB][name] = Input.Default
                    end
                    Input.Text = tostring(Input.Default or "")
                    Input.Default = Input.Text

					local newInput = Templates.TextBox:Clone()
					newInput.Name = Input.Title
					newInput.Parent = parentElement
					newInput.Title.Text = Input.Title
					if Input.Desc and Input.Desc ~= "" then
						newInput.Description.Text = Input.Desc
						newInput.Description.Visible = true
					else
						newInput.Description.Visible = false
					end

					if Input.Locked then

						newInput.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newInput.BackgroundColor3 = Color3.fromRGB(32, 35, 40)

						newInput.Title.TextColor3 = Color3.fromRGB(75, 77, 83)
						newInput.Description.TextColor3 = Color3.fromRGB(75, 77, 83)

						newInput.BoxFrame.Frame.BackgroundColor3 = Color3.fromRGB(32, 35, 40)
						newInput.BoxFrame.Frame.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newInput.BoxFrame.Frame.TextBox.TextColor3 = Color3.fromRGB(75, 77, 83)
						newInput.BoxFrame.Frame.TextBox.PlaceholderColor3 = Color3.fromRGB(75, 77, 83)

						newInput.BoxFrame.Frame.TextBox.Active = false
						newInput.BoxFrame.Frame.TextBox.Interactable = false
						newInput.BoxFrame.Frame.TextBox.TextEditable = false
					end

					newInput.BoxFrame.Frame.TextBox.Text = Input.Default
					newInput.BoxFrame.Frame.TextBox.PlaceholderText = Input.Placeholder
					newInput.BoxFrame.Frame.TextBox.MultiLine = Input.MultiLine

					if Input.MultiLine then
						newInput.BoxFrame.Frame.TextBox.AutomaticSize = Enum.AutomaticSize.Y
					else
						newInput.BoxFrame.Frame.TextBox.AutomaticSize = Enum.AutomaticSize.None
					end

					newInput.BoxFrame.Frame.TextBox.ClearTextOnFocus = Input.ClearTextOnFocus

					newInput.Visible = true

					newInput.BoxFrame.Frame.TextBox.MouseEnter:Connect(function()
						if not Input.Locked and not isTouchInput() then
							Tween(newInput.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
						end
					end)

					newInput.BoxFrame.Frame.TextBox.MouseLeave:Connect(function()
						if not Input.Locked then
							Tween(newInput.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						end
					end)

					newInput.BoxFrame.Frame.TextBox.Focused:Connect(function()
						if not Input.Locked then
							Tween(newInput.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
							Tween(newInput.BoxFrame.Frame.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
						end
					end)

					newInput.BoxFrame.Frame.TextBox.FocusLost:Connect(function()
						if not Input.Locked then
							Tween(newInput.BoxFrame.Frame.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
							Input.Text = newInput.BoxFrame.Frame.TextBox.Text
							Input.Callback(Input.Text)
                            CONFIG[NAMETAB][name] = Input.Text
						    SAVECONFIG()
						end
					end)

					function Input:Set(newText)
						newText = tostring(newText or "")
						newInput.BoxFrame.Frame.TextBox.Text = newText
						Input.Text = newText
						Input.Callback(newText)
                        CONFIG[NAMETAB][name] = newText
                        SAVECONFIG()
					end

					function Input:SetTitle(newText)
						Input.Title = tostring(newText or "Input")
						newInput.Title.Text = Input.Title
						newInput.Name = Input.Title
					end

					function Input:SetDesc(newDesc)
						Input.Desc = tostring(newDesc or "")
						newInput.Description.Text = Input.Desc
						newInput.Description.Visible = Input.Desc ~= ""
					end

					function Input:SetPlaceholder(newText)
						Input.Placeholder = tostring(newText or "")
						newInput.BoxFrame.Frame.TextBox.PlaceholderText = Input.Placeholder
					end

					function Input:Lock()
						Input.Locked = true

						Tween(newInput.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)
						Tween(newInput, {BackgroundColor3 = Color3.fromRGB(32, 35, 40)}, TweenConfigs.Global)

						Tween(newInput.Title, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
						Tween(newInput.Description, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)

						Tween(newInput.BoxFrame.Frame, {BackgroundColor3 = Color3.fromRGB(32, 35, 40)}, TweenConfigs.Global)
						Tween(newInput.BoxFrame.Frame.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)

						Tween(newInput.BoxFrame.Frame.TextBox, {
							TextColor3 = Color3.fromRGB(75, 77, 83),
							PlaceholderColor3 = Color3.fromRGB(75, 77, 83)
						}, TweenConfigs.Global)

						newInput.BoxFrame.Frame.TextBox.Active = false
						newInput.BoxFrame.Frame.TextBox.Interactable = false
						newInput.BoxFrame.Frame.TextBox.TextEditable = false
					end

					function Input:Unlock()
						Input.Locked = false

						Tween(newInput.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newInput, {BackgroundColor3 = Color3.fromRGB(42, 45, 52)}, TweenConfigs.Global)

						Tween(newInput.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newInput.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)

						Tween(newInput.BoxFrame.Frame, {BackgroundColor3 = Color3.fromRGB(42, 45, 52)}, TweenConfigs.Global)
						Tween(newInput.BoxFrame.Frame.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)

						Tween(newInput.BoxFrame.Frame.TextBox, {
							TextColor3 = UISettings.TextColor,
							PlaceholderColor3 = Color3.fromRGB(139, 139, 139)
						}, TweenConfigs.Global)

						newInput.BoxFrame.Frame.TextBox.Active = true
						newInput.BoxFrame.Frame.TextBox.Interactable = true
						newInput.BoxFrame.Frame.TextBox.TextEditable = true
					end

					function Input:Destroy()
						newInput:Destroy()
					end

					Input.Callback(Input.Default)

					return Input
				end

