--[[ xngot-studio · src/modules/40_window/170_el_slider.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_slider
     role   : Tab:Slider
     source : main 2.txt L13073-13315 · 243 dòng · delta +0
--]]
				function Tab:Slider(data)
					data = data or {}
					data.Value = data.Value or {}
					local Slider = {
						Title = data.Title or "Slider",
						Desc = data.Desc,
						Step = data.Step or 1,
						Value = {
							Min = data.Value.Min or 0,
							Max = data.Value.Max or 100,
							Default = nil,
						},

						Locked = data.Locked,
						Callback = type(data.Callback) == "function" and data.Callback or function() end
					}
					Slider.Value.Default = data.Value.Default ~= nil and data.Value.Default or (data.Default ~= nil and data.Default or Slider.Value.Min)

					local increment = tonumber(Slider.Step) or 1
					if increment <= 0 then increment = 1 end

                    local name = Slider.Title
                    if CONFIGLOADED and CONFIG[NAMETAB][name] ~= nil then
                        Slider.Value.Default = tonumber(CONFIG[NAMETAB][name]) or Slider.Value.Default
                    elseif not CONFIGLOADED or CONFIG[NAMETAB][name] == nil then
                        CONFIG[NAMETAB][name] = Slider.Value.Default
                    end
                    Slider.Value.Min = tonumber(Slider.Value.Min) or 0
                    Slider.Value.Max = tonumber(Slider.Value.Max) or 100
                    if Slider.Value.Max < Slider.Value.Min then
                        Slider.Value.Min, Slider.Value.Max = Slider.Value.Max, Slider.Value.Min
                    end
                    Slider.Value.Default = math.clamp(tonumber(Slider.Value.Default) or Slider.Value.Min, Slider.Value.Min, Slider.Value.Max)

					local newSlider = Templates.Slider:Clone()
					newSlider.Parent = parentElement
					newSlider.Name = Slider.Title
					newSlider.Title.Text = Slider.Title
					if Slider.Desc and Slider.Desc ~= "" then
						newSlider.Description.Visible = true
						newSlider.Description.Text = Slider.Desc
					end
					newSlider.Visible = true

					local function GetRandomGradient()
						local gradient = {}
						for _, g in ipairs(newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient:GetChildren()) do
							if g:IsA("UIGradient") then
								g.Enabled = false
								table.insert(gradient, g)
							end
						end
						local selectedGrad = gradient[math.random(1, #gradient)]
						selectedGrad.Enabled = true
						return selectedGrad
					end

					newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient.Size = UDim2.new(0, newSlider.SliderFrame.Frame.Slider.AbsoluteSize.X, 1, 0)
					newSlider.SliderFrame.Frame.Slider:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
						newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient.Size = UDim2.new(0, newSlider.SliderFrame.Frame.Slider.AbsoluteSize.X, 1, 0)
					end)

					local lastprop = nil
					newSlider.SliderFrame.Frame.Slider.Fill:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
						if newSlider.SliderFrame.Frame.Slider.Fill.AbsoluteSize.X <= 3 then
							lastprop = newSlider.SliderFrame.Frame.Slider.Fill.AbsoluteSize.X

						end
						if lastprop and newSlider.SliderFrame.Frame.Slider.Fill.AbsoluteSize.X > lastprop then
							GetRandomGradient()
							lastprop = nil
						end
					end)

					GetRandomGradient()

					if Slider.Locked then

						newSlider.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newSlider.BackgroundColor3 = Color3.fromRGB(32, 35, 40)

						newSlider.Title.TextColor3 = Color3.fromRGB(75, 77, 83)
						newSlider.Description.TextColor3 = Color3.fromRGB(75, 77, 83)

						newSlider.SliderFrame.Frame.Slider.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newSlider.SliderFrame.Frame.Slider.BackgroundTransparency = 0.5
						newSlider.SliderFrame.Frame.Slider.Fill.UIStroke.Transparency = 0.5
						newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient.BackgroundTransparency = 0.5
						newSlider.SliderFrame.Frame.ValueText.TextTransparency = 0.6
					end

					local Trigger = newSlider.SliderFrame.Frame.Slider.Trigger
					local Label = newSlider.SliderFrame.Frame.ValueText
					local Fill = newSlider.SliderFrame.Frame.Slider.Fill

					local default = Slider.Value.Default
					local min = Slider.Value.Min
					local max = Slider.Value.Max
					local increment = increment or 1

					local perc = Slider.Value.Default
					local Percent
					local MouseDown = false

					local Hovering = false

					local function convertValueToScale(value)
						if max == min then return 0 end
						return math.clamp((value - min) / (max - min), 0, 1)
					end

					Label.Text = tostring(default) or tostring(min)

					Fill.Size = UDim2.fromScale(convertValueToScale(default), 1)

					local activeInput, dragMode, startX, startY = nil, nil, 0, 0
					local inputChangedConnection, inputEndedConnection, focusLostConnection
					local sliderDisposed = false
					local function applyPosition(x)
						if Slider.Locked or sliderDisposed then return end
						local bar = newSlider.SliderFrame.Frame.Slider
						local width = math.max(bar.AbsoluteSize.X, 1)
						Percent = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
						local value = math.clamp(math.round((min + Percent * (max - min)) / increment) * increment, min, max)
						if value == perc then return end
						perc = value
						Tween(Fill, {Size = UDim2.fromScale(convertValueToScale(value), 1)}, TweenConfigs.Global)
						Label.Text = tostring(value)
						Slider.Value = value
						CONFIG[NAMETAB][name] = value
						task.spawn(Slider.Callback, value)
					end
					local function finishDrag(save)
						local wasDragging = MouseDown
						MouseDown, activeInput, dragMode = false, nil, nil
						Hovering = false
						if not Slider.Locked and newSlider.Parent then Tween(newSlider.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global) end
						if wasDragging and save and not sliderDisposed then SAVECONFIG() end
					end

					local function Update(value)
						value = tonumber(value)
						if value == nil or value > max or value < min then
							return nil
						end

						local roundedValue = math.round(value / increment) * increment
						perc = math.clamp(roundedValue, min, max)

						Tween(Fill, {Size = UDim2.fromScale(convertValueToScale(perc), 1) }, TweenConfigs.Global)

						Label.Text = tostring(perc)
						Slider.Value = perc
						task.spawn(Slider.Callback, perc)
                        CONFIG[NAMETAB][name] = perc
						SAVECONFIG()
						return perc
					end

					Trigger.MouseEnter:Connect(function()
						if isTouchInput() then return end
						Hovering = true
						if not Slider.Locked then Tween(newSlider.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global) end
					end)
					Trigger.MouseLeave:Connect(function()
						Hovering = false
						if not Slider.Locked and not MouseDown then Tween(newSlider.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global) end
					end)
					Trigger.InputBegan:Connect(function(input)
						if Slider.Locked or activeInput then return end
						local kind = input.UserInputType
						if kind ~= Enum.UserInputType.Touch and kind ~= Enum.UserInputType.MouseButton1 then return end
						activeInput, MouseDown = input, true
						startX, startY = input.Position.X, input.Position.Y
						dragMode = kind == Enum.UserInputType.Touch and "pending" or "mouse"
						Tween(newSlider.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
						if dragMode == "mouse" then applyPosition(startX) end
					end)
					inputChangedConnection = UIS.InputChanged:Connect(function(input)
						if not activeInput or Slider.Locked then return end
						if activeInput.UserInputType == Enum.UserInputType.Touch then
							if input ~= activeInput then return end
							local dx, dy = input.Position.X - startX, input.Position.Y - startY
							if dragMode == "pending" and (math.abs(dx) > 8 or math.abs(dy) > 8) then
								dragMode = math.abs(dx) > math.abs(dy) and "horizontal" or "scroll"
							end
							if dragMode == "horizontal" then applyPosition(input.Position.X) end
						elseif input.UserInputType == Enum.UserInputType.MouseMovement then
							applyPosition(input.Position.X)
						end
					end)
					inputEndedConnection = UIS.InputEnded:Connect(function(input)
						if not activeInput then return end
						local isTouch = activeInput.UserInputType == Enum.UserInputType.Touch
						if (isTouch and input ~= activeInput) or (not isTouch and input.UserInputType ~= Enum.UserInputType.MouseButton1) then return end
						if isTouch and dragMode == "pending" and input.UserInputState ~= Enum.UserInputState.Cancel then
							local dx, dy = input.Position.X - startX, input.Position.Y - startY
							if dx * dx + dy * dy <= 144 then applyPosition(input.Position.X) end
						end
						finishDrag(dragMode ~= "scroll")
					end)
					focusLostConnection = UIS.WindowFocusReleased:Connect(function() finishDrag(false) end)
					local function disposeSlider()
						if sliderDisposed then return end
						sliderDisposed = true
						finishDrag(false)
						if inputChangedConnection then inputChangedConnection:Disconnect() end
						if inputEndedConnection then inputEndedConnection:Disconnect() end
						if focusLostConnection then focusLostConnection:Disconnect() end
					end
					newSlider.Destroying:Connect(disposeSlider)

					function Slider:SetTitle(newText)
						Slider.Title = tostring(newText or "Slider")
						newSlider.Title.Text = Slider.Title
						newSlider.Name = Slider.Title
					end

					function Slider:SetDesc(newDesc)
						Slider.Desc = tostring(newDesc or "")
						newSlider.Description.Text = Slider.Desc
						newSlider.Description.Visible = Slider.Desc ~= ""
					end

					function Slider:Set(value)
						return Update(value)
					end

					function Slider:Lock()
						Slider.Locked = true
						finishDrag(false)
						Tween(newSlider, {BackgroundColor3 = Color3.fromRGB(32, 35, 40)}, TweenConfigs.Global)
						Tween(newSlider.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)
						Tween(newSlider.Title, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
						Tween(newSlider.Description, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)

						Tween(newSlider.SliderFrame.Frame.Slider.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.Slider, {BackgroundTransparency = 0.5}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.Slider.Fill.UIStroke, {Transparency = 0.5}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient, {BackgroundTransparency = 0.5}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.ValueText, {TextTransparency = 0.6}, TweenConfigs.Global)
					end

					function Slider:Unlock()
						Slider.Locked = false

						Tween(newSlider, {BackgroundColor3 = Color3.fromRGB(42, 45, 52)}, TweenConfigs.Global)
						Tween(newSlider.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newSlider.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newSlider.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)

						Tween(newSlider.SliderFrame.Frame.Slider.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.Slider, {BackgroundTransparency = 0}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.Slider.Fill.UIStroke, {Transparency = 0}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient, {BackgroundTransparency = 0}, TweenConfigs.Global)
						Tween(newSlider.SliderFrame.Frame.ValueText, {TextTransparency = 0}, TweenConfigs.Global)
					end

					function Slider:Destroy()
						disposeSlider()
						newSlider:Destroy()
					end

					Slider.Callback(default)

					Slider._AIInstance = newSlider
					return Slider
				end

