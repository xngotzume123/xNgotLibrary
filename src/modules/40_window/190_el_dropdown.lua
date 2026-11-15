--[[ xngot-studio · src/modules/40_window/190_el_dropdown.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_dropdown
     role   : Tab:Dropdown
     source : main 2.txt L13518-13960 · 443 dòng · delta +0
--]]
				function Tab:Dropdown(data)
					data = data or {}
					local Dropdown = {
						Title = data.Title or "Dropdown",
						Desc = data.Desc,

						Multi = data.Multi or false,
						Values = data.Values or {},
						Value = data.Value ~= nil and data.Value or data.Default,

						AllowNone = data.AllowNone or false,
						Locked = data.Locked or false,
						Callback = type(data.Callback) == "function" and data.Callback or function() end
					}

					if not Dropdown.Multi and Dropdown.AllowNone then
						Dropdown.Values = {"None", unpack(Dropdown.Values)}
					end

                    local name = Dropdown.Title
                    if CONFIGLOADED and CONFIG[NAMETAB][name] ~= nil then
                        Dropdown.Value = CONFIG[NAMETAB][name]
                    elseif not CONFIGLOADED or CONFIG[NAMETAB][name] == nil then
                        CONFIG[NAMETAB][name] = Dropdown.Value
                    end

                    if Dropdown.Multi then
                        if type(Dropdown.Value) == "string" then
                            Dropdown.Value = {Dropdown.Value}
                        elseif type(Dropdown.Value) ~= "table" then
                            Dropdown.Value = {}
                        end
                    elseif Dropdown.AllowNone and (Dropdown.Value == "" or Dropdown.Value == nil) then
                        Dropdown.Value = "None"
                    end

                    if Dropdown.Multi and not Dropdown.AllowNone and #Dropdown.Value == 0 then
                        for _, candidate in ipairs(Dropdown.Values) do
                            if type(candidate) == "string" then
                                Dropdown.Value = {candidate}
                                CONFIG[NAMETAB][name] = Dropdown.Value
                                break
                            end
                        end
                    end

					local selected = nil

					local newDropdown = Templates.Dropdown:Clone()
					local dropdownFolder = Templates.DropdownList:Clone()
					dropdownFolder.Name = Dropdown.Title
					dropdownFolder.Parent = newWindow.DropdownSelection.Dropdowns

					newDropdown.Parent = parentElement
					newDropdown.Name = Dropdown.Title
					newDropdown.Title.Text = Dropdown.Title

					if Dropdown.Desc and Dropdown.Desc ~= "" then
						newDropdown.Description.Visible = true
						newDropdown.Description.Text = Dropdown.Desc
					else
						newDropdown.Description.Visible = false
					end

					if Dropdown.Locked then

						newDropdown.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newDropdown.BackgroundColor3 = Color3.fromRGB(32, 35, 40)

						newDropdown.Title.TextColor3 = Color3.fromRGB(75, 77, 83)
						newDropdown.Description.TextColor3 = Color3.fromRGB(75, 77, 83)
						newDropdown.Title.ClickIcon.ImageColor3 = Color3.fromRGB(75, 77, 83)

						newDropdown.Title.BoxFrame.Trigger.BackgroundColor3 = Color3.fromRGB(32, 35, 40)
						newDropdown.Title.BoxFrame.Trigger.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newDropdown.Title.BoxFrame.Trigger.Title.TextColor3 = Color3.fromRGB(75, 77, 83)

						newDropdown.Active = false
						newDropdown.Interactable = false
					end

					newDropdown.Visible = true

					local function SelectValue(multi, newvalue)
						if not multi then
							if type(newvalue) ~= "string" then return nil end
							local targetButton = dropdownFolder.DropdownItems:FindFirstChild(newvalue)
							local targetbuttonSearch = dropdownFolder.DropdownItemsSearch:FindFirstChild(newvalue)
							if not targetButton or not targetbuttonSearch then return nil end

							selected = newvalue
							Dropdown.Value = selected
							local prettyLabel = Window._MusicTriggerLabels and Window._MusicTriggerLabels[selected]
							newDropdown.Title.BoxFrame.Trigger.Title.Text = prettyLabel or selected

							for _,otherButton in dropdownFolder.DropdownItems:GetChildren() do
								if otherButton:IsA("GuiButton") and otherButton.Name ~= newvalue then
									Tween(otherButton.Frame.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(otherButton.Frame.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(otherButton.Frame, {BackgroundTransparency = 1}, TweenConfigs.Global)
									Tween(otherButton.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
								end
							end
							for _,otherButton in dropdownFolder.DropdownItemsSearch:GetChildren() do
								if otherButton:IsA("GuiButton") and otherButton.Name ~= newvalue then
									Tween(otherButton.Frame.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(otherButton.Frame.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(otherButton.Frame, {BackgroundTransparency = 1}, TweenConfigs.Global)
									Tween(otherButton.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
								end
							end

							Tween(targetButton.Frame.Title, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
							Tween(targetButton.Frame.Description, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
							Tween(targetButton.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
							Tween(targetButton.Frame, {BackgroundTransparency = 0}, TweenConfigs.Global)

							Tween(targetbuttonSearch.Frame.Title, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
							Tween(targetbuttonSearch.Frame.Description, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
							Tween(targetbuttonSearch.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
							Tween(targetbuttonSearch.Frame, {BackgroundTransparency = 0}, TweenConfigs.Global)
                            if selected == "None" then return "" end
							return selected
						elseif multi then
							if type(newvalue) ~= "table" then newvalue = {newvalue} end
							selected = type(selected) == "table" and selected or {}
							for _, newSelected in newvalue do
								if type(newSelected) ~= "string" then continue end
								local targetButton = dropdownFolder.DropdownItems:FindFirstChild(newSelected)
								local targetbuttonSearch = dropdownFolder.DropdownItemsSearch:FindFirstChild(newSelected)
								if not targetButton or not targetbuttonSearch then continue end

								local idx = table.find(selected, newSelected)
								if idx then

									if not Dropdown.AllowNone and #selected == 1 then continue end

									table.remove(selected, idx)

									Tween(targetButton.Frame.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(targetButton.Frame.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(targetButton.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
									Tween(targetButton.Frame, {BackgroundTransparency = 1}, TweenConfigs.Global)

									Tween(targetbuttonSearch.Frame.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(targetbuttonSearch.Frame.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
									Tween(targetbuttonSearch.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
									Tween(targetbuttonSearch.Frame, {BackgroundTransparency = 1}, TweenConfigs.Global)
								else

									table.insert(selected, newSelected)

									Tween(targetButton.Frame.Title, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
									Tween(targetButton.Frame.Description, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
									Tween(targetButton.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
									Tween(targetButton.Frame, {BackgroundTransparency = 0}, TweenConfigs.Global)

									Tween(targetbuttonSearch.Frame.Title, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
									Tween(targetbuttonSearch.Frame.Description, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
									Tween(targetbuttonSearch.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
									Tween(targetbuttonSearch.Frame, {BackgroundTransparency = 0}, TweenConfigs.Global)
								end
							end

							Dropdown.Value = selected
							newDropdown.Title.BoxFrame.Trigger.Title.Text = TableToString(selected)
							return selected
						end
					end

					local function AddButtons(buttonListUnfiltered, refresh)
						buttonListUnfiltered = type(buttonListUnfiltered) == "table" and buttonListUnfiltered or {}
						local seen = {}
						local buttonList = {}

						for i, value in buttonListUnfiltered do
							if typeof(value) == "string" then
								if not seen[value] then
									seen[value] = 1
									table.insert(buttonList, value)
								else
									seen[value] = seen[value] + 1
									table.insert(buttonList, value.." ("..seen[value]..")")
								end
							end
						end

						if refresh then
							Dropdown.Values = buttonList

							for _,oldButton in dropdownFolder.DropdownItems:GetChildren() do
								if oldButton:IsA("GuiButton") then
									oldButton:Destroy()
								end
							end
							for _,oldButton in dropdownFolder.DropdownItemsSearch:GetChildren() do
								if oldButton:IsA("GuiButton") then
									oldButton:Destroy()
								end
							end
						end

						if not Dropdown.Multi then
							if refresh then
								selected = nil
								newDropdown.Title.BoxFrame.Trigger.Title.Text = ""
							end

							for _, buttonName in buttonList do
								local newDropdownButton = AddDropdownButton(buttonName, dropdownFolder.DropdownItems)
								local newDropdownButtonSearch = AddDropdownButton(buttonName, dropdownFolder.DropdownItemsSearch)
								if Window._MusicRowDecorate then
									pcall(Window._MusicRowDecorate, buttonName, newDropdownButton)
									pcall(Window._MusicRowDecorate, buttonName, newDropdownButtonSearch)
								end

								newDropdownButton.Visible = true
								newDropdownButtonSearch.Visible = true

								if selected == buttonName then
									newDropdownButton.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButton.Frame.Description.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButton.UIStroke.Color = UISettings.AccentColor
									newDropdownButton.Frame.BackgroundTransparency = 0
									newDropdownButton.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)

									newDropdownButtonSearch.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButtonSearch.Frame.Description.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButtonSearch.UIStroke.Color = UISettings.AccentColor
									newDropdownButtonSearch.Frame.BackgroundTransparency = 0
									newDropdownButtonSearch.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)
								end

								BindSafeActivate(newDropdownButton, function()
									if not Dropdown.Locked then
										local value = SelectValue(false, buttonName)
										if value then
											if isTouchInput() then task.defer(function() if DropdownState and SelectedDropdown == Dropdown.Title then DropdownPopup(false) end end) end
											Dropdown.Callback(value)
                                            CONFIG[NAMETAB][name] = Dropdown.Value
						                    SAVECONFIG()
										end
									end
								end)

								BindSafeActivate(newDropdownButtonSearch, function()
									if not Dropdown.Locked then
										local value = SelectValue(false, buttonName)
										if value then
											if isTouchInput() then task.defer(function() if DropdownState and SelectedDropdown == Dropdown.Title then DropdownPopup(false) end end) end
											Dropdown.Callback(value)
                                            CONFIG[NAMETAB][name] = Dropdown.Value
						                    SAVECONFIG()
										end
									end
								end)
							end
						elseif Dropdown.Multi then

							if refresh then
								selected = {}
								newDropdown.Title.BoxFrame.Trigger.Title.Text = TableToString(selected)
							end

							for _, buttonName in buttonList do
								local newDropdownButton = AddDropdownButton(buttonName, dropdownFolder.DropdownItems)
								local newDropdownButtonSearch = AddDropdownButton(buttonName, dropdownFolder.DropdownItemsSearch)
								if Window._MusicRowDecorate then
									pcall(Window._MusicRowDecorate, buttonName, newDropdownButton)
									pcall(Window._MusicRowDecorate, buttonName, newDropdownButtonSearch)
								end

								newDropdownButton.Visible = true
								newDropdownButtonSearch.Visible = true

								if table.find(selected, buttonName) then
									newDropdownButton.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButton.Frame.Description.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButton.UIStroke.Color = UISettings.AccentColor
									newDropdownButton.Frame.BackgroundTransparency = 0
									newDropdownButton.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)

									newDropdownButtonSearch.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButtonSearch.Frame.Description.TextColor3 = Color3.fromRGB(255,255,255)
									newDropdownButtonSearch.UIStroke.Color = UISettings.AccentColor
									newDropdownButtonSearch.Frame.BackgroundTransparency = 0
									newDropdownButtonSearch.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)
								end

								BindSafeActivate(newDropdownButton, function()
									if not Dropdown.Locked then
										local value = SelectValue(true, {buttonName})
										if value then
											Dropdown.Callback(value)
                                            CONFIG[NAMETAB][name] = Dropdown.Value
						                    SAVECONFIG()
										end
									end
								end)

								BindSafeActivate(newDropdownButtonSearch, function()
									if not Dropdown.Locked then
										local value = SelectValue(true, {buttonName})
										if value then
											Dropdown.Callback(value)
                                            CONFIG[NAMETAB][name] = Dropdown.Value
						                    SAVECONFIG()
										end
									end
								end)
							end
						end
					end

					if not Dropdown.Multi then

						selected = Dropdown.Value or nil
						newDropdown.Title.BoxFrame.Trigger.Title.Text = selected

						AddButtons(Dropdown.Values)
					elseif Dropdown.Multi then

						newDropdown.Title.ClickIcon.Image = "rbxassetid://91415671397056"

						if type(Dropdown.Value) == "string" then
							Dropdown.Value = {Dropdown.Value}
						end
						selected = Dropdown.Value or {}
						newDropdown.Title.BoxFrame.Trigger.Title.Text = TableToString(selected)

						AddButtons(Dropdown.Values)
					end

					BindSafeActivate(newDropdown.Title.BoxFrame.Trigger, function()
						if not Dropdown.Locked then DropdownPopup(nil, Dropdown.Title) end
					end)

					function Dropdown:SetTitle(newText)
						local oldTitle = Dropdown.Title
						Dropdown.Title = tostring(newText or "Dropdown")
						newDropdown.Title.Text = Dropdown.Title
						newDropdown.Name = Dropdown.Title
						dropdownFolder.Name = Dropdown.Title
						if SelectedDropdown == oldTitle then
							SelectedDropdown = Dropdown.Title
							newWindow.DropdownSelection.TopBar.Title.Text = Dropdown.Title
						end
					end

					function Dropdown:SetDesc(newDesc)
						Dropdown.Desc = tostring(newDesc or "")
						newDropdown.Description.Text = Dropdown.Desc
						newDropdown.Description.Visible = Dropdown.Desc ~= ""
					end

					function Dropdown:Refresh(newvals)
						local values = type(newvals) == "table" and newvals or {}
						if not Dropdown.Multi and Dropdown.AllowNone then
							local withNone = {"None"}
							for _, value in ipairs(values) do if value ~= "None" then table.insert(withNone, value) end end
							values = withNone
						end
						AddButtons(values, true)

						if Dropdown.Multi then
							Dropdown.Value = {}
							selected = Dropdown.Value
							if not Dropdown.AllowNone and #Dropdown.Values > 0 then
								SelectValue(true, {Dropdown.Values[1]})
							end
						elseif Dropdown.AllowNone then
							SelectValue(false, "None")
						else
							Dropdown.Value = nil
							selected = nil
						end

						CONFIG[NAMETAB][name] = Dropdown.Value
						SAVECONFIG()
						return Dropdown.Value
					end

					function Dropdown:Select(newval)
						local value = SelectValue(Dropdown.Multi, newval)
						if value == nil then return nil end
						Dropdown.Callback(value)
                        CONFIG[NAMETAB][name] = Dropdown.Value
						SAVECONFIG()
						return value
					end

					function Dropdown:Lock()
						Dropdown.Locked = true
						Tween(newDropdown.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)
						Tween(newDropdown, {BackgroundColor3 = Color3.fromRGB(32, 35, 40)}, TweenConfigs.Global)

						Tween(newDropdown.Title, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
						Tween(newDropdown.Description, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
						Tween(newDropdown.Title.ClickIcon, {ImageColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)

						Tween(newDropdown.Title.BoxFrame.Trigger, {BackgroundColor3 = Color3.fromRGB(32, 35, 40)}, TweenConfigs.Global)
						Tween(newDropdown.Title.BoxFrame.Trigger.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)
						Tween(newDropdown.Title.BoxFrame.Trigger.Title, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)

						newDropdown.Active = false
						newDropdown.Interactable = false
					end

					function Dropdown:Unlock()
						Dropdown.Locked = false
						Tween(newDropdown.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newDropdown, {BackgroundColor3 = Color3.fromRGB(42, 45, 52)}, TweenConfigs.Global)

						Tween(newDropdown.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newDropdown.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newDropdown.Title.ClickIcon, {ImageColor3 = UISettings.TextColor}, TweenConfigs.Global)

						Tween(newDropdown.Title.BoxFrame.Trigger, {BackgroundColor3 = Color3.fromRGB(42, 45, 52)}, TweenConfigs.Global)
						Tween(newDropdown.Title.BoxFrame.Trigger.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newDropdown.Title.BoxFrame.Trigger.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)

						newDropdown.Active = true
						newDropdown.Interactable = true
					end

					function Dropdown:Destroy()
						if SelectedDropdown == Dropdown.Title then
							SelectedDropdown = nil
							DropdownState = false
							newWindow.DropdownSelection.Visible = false
							newWindow.DarkOverlay.Visible = false
						end
						newDropdown:Destroy()
						if dropdownFolder then dropdownFolder:Destroy() end
					end

                    if (not Dropdown.Multi and Dropdown.AllowNone) and Dropdown.Value == "None" then
                        Dropdown.Callback("")
                    else
                        Dropdown.Callback(Dropdown.Value)
                    end

					return Dropdown
				end

