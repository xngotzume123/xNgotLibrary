--[[ xngot-studio · src/modules/40_window/120_el_button.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_button
     role   : Tab:Button
     source : main 2.txt L12489-12631 · 143 dòng · delta +0
--]]
				function Tab:Button(data)
					data = data or {}
					local Button = {}

					local ButtonData = {
						Title = data.Title or "Button",
						Desc = data.Desc,
						Locked = data.Locked or false,
						Callback = type(data.Callback) == "function" and data.Callback or function() end
					}

					local newButton = Templates.Button:Clone()
					newButton.Name = ButtonData.Title
					newButton.Parent = parentElement

					newButton.Frame.Title.Text = ButtonData.Title

					if ButtonData.Desc and ButtonData.Desc ~= "" then
						newButton.Frame.Description.Visible = true
						newButton.Frame.Description.Text = ButtonData.Desc
					end

					if ButtonData.Locked then

						newButton.UIStroke.Color = Color3.fromRGB(47, 47, 58)
						newButton.BackgroundColor3 = Color3.fromRGB(32, 35, 40)

						newButton.Frame.Title.TextColor3 = Color3.fromRGB(75, 77, 83)
						newButton.Frame.Title.ClickIcon.ImageColor3 = Color3.fromRGB(75, 77, 83)

						newButton.Frame.Description.TextColor3 = Color3.fromRGB(75, 77, 83)
					end

					newButton.Visible = true

					local function GetRandomGradient()
						local gradient = {}
						for _, g in ipairs(newButton.Frame:GetChildren()) do
							if g:IsA("UIGradient") then
								g.Enabled = false
								table.insert(gradient, g)
							end
						end
						local selectedGrad = gradient[math.random(1, #gradient)]
						selectedGrad.Enabled = true
						return selectedGrad
					end

					GetRandomGradient()

					local function resetButtonPress()
						if ButtonData.Locked or not newButton.Parent then return end
						Tween(newButton.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newButton.Frame.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newButton.Frame.Title.ClickIcon, {ImageColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newButton.Frame.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newButton.Frame, {BackgroundTransparency = 1}, TweenConfigs.Global)
					end
					newButton.MouseEnter:Connect(function()
						if not ButtonData.Locked and not isTouchInput() then Tween(newButton.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global) end
					end)
					BindPressFeedback(newButton, function()
						if ButtonData.Locked then return end
						GetRandomGradient()
						Tween(newButton.UIStroke, {Color = UISettings.AccentColor}, TweenConfigs.Global)
						Tween(newButton.Frame.Title, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
						Tween(newButton.Frame.Title.ClickIcon, {ImageColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
						Tween(newButton.Frame.Description, {TextColor3 = Color3.fromRGB(255,255,255)}, TweenConfigs.Global)
						Tween(newButton.Frame, {BackgroundTransparency = 0}, TweenConfigs.Global)
					end, resetButtonPress)
					BindSafeActivate(newButton, function()
						resetButtonPress()
						if not ButtonData.Locked then ButtonData.Callback() end
					end)

					newTab.ChildAdded:Connect(function()
						if #GetCurrentElementObjects() > 0 then
							SetEmptyTabNotice(false)
						else
							SetEmptyTabNotice(true)
						end
					end)

					newTab.ChildRemoved:Connect(function()
						if #GetCurrentElementObjects() > 0 then
							SetEmptyTabNotice(false)
						else
							SetEmptyTabNotice(true)
						end
					end)

					function Button:SetTitle(newText)
						ButtonData.Title = tostring(newText or "Button")
						newButton.Name = ButtonData.Title
						newButton.Frame.Title.Text = ButtonData.Title
					end

					function Button:SetDesc(newDesc)
						ButtonData.Desc = tostring(newDesc or "")
						newButton.Frame.Description.Text = ButtonData.Desc
						newButton.Frame.Description.Visible = ButtonData.Desc ~= ""
					end

					function Button:Lock()
						resetButtonPress()
						ButtonData.Locked = true
						Tween(newButton, {BackgroundColor3 = Color3.fromRGB(32, 35, 40)}, TweenConfigs.Global)
						Tween(newButton.UIStroke, {Color = Color3.fromRGB(47, 47, 58)}, TweenConfigs.Global)
						Tween(newButton.Frame.Title, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
						Tween(newButton.Frame.Title.ClickIcon, {ImageColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
						Tween(newButton.Frame.Description, {TextColor3 = Color3.fromRGB(75, 77, 83)}, TweenConfigs.Global)
					end

					function Button:Unlock()
						ButtonData.Locked = false
						Tween(newButton, {BackgroundColor3 = Color3.fromRGB(42, 45, 52)}, TweenConfigs.Global)
						Tween(newButton.UIStroke, {Color = Color3.fromRGB(60, 60, 74)}, TweenConfigs.Global)
						Tween(newButton.Frame.Title, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newButton.Frame.Title.ClickIcon, {ImageColor3 = UISettings.TextColor}, TweenConfigs.Global)
						Tween(newButton.Frame.Description, {TextColor3 = UISettings.TextColor}, TweenConfigs.Global)
					end

					function Button:Destroy()
						newButton:Destroy()
					end

					return Button
				end

