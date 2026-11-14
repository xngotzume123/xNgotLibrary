--[[ xngot-studio · src/modules/40_window/060_theme_apply.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.theme_apply
     role   : applyThemeToObject/applyUITheme/schedule/store
     source : main 2.txt L11737-11873 · 137 dòng · delta +0
--]]
			local function applyThemeToObject(instance)
				if not UISettings.Enabled or not hasUIOverrides() then return end
				if not instance or not instance.Parent then return end
				if instance == backgroundLayer or instance == liquidGradient or instance == liquidStroke or instance == uiScale or instance == floatingScale then return end
				if string.sub(instance.Name, 1, 15) == "NgotStudioTheme" or instance.Name == "NgotStudioColorPreview" then return end

				local base = captureThemeBase(instance)
				local lowerName = string.lower(instance.Name or "")

				if instance:IsA("GuiObject") and instance ~= newWindow then
					if base.BackgroundTransparency ~= nil and base.BackgroundTransparency < 0.98 then
						if UIOverrides.SurfaceColor and not string.find(lowerName, "overlay", 1, true) and not isAccentColor(base.BackgroundColor3) then
							instance.BackgroundColor3 = blendColor(base.BackgroundColor3, UISettings.SurfaceColor, 0.62)
						end
						if UIOverrides.AccentColor and isAccentColor(base.BackgroundColor3) then
							instance.BackgroundColor3 = UISettings.AccentColor
						end
						if UIOverrides.BoxOpacity and not string.find(lowerName, "overlay", 1, true) then
							instance.BackgroundTransparency = opacityFromBase(base.BackgroundTransparency, UISettings.BoxOpacity)
						end
					end
				end

				if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
					if UIOverrides.Font then instance.Font = fontForBase(base.Font or instance.Font, UISettings.Font) end
					if UIOverrides.TextScale then instance.TextSize = math.max(8, (base.TextSize or instance.TextSize) * UISettings.TextScale) end
					if UIOverrides.TextColor and (base.TextTransparency or 0) < 0.28 then
						instance.TextColor3 = UISettings.TextColor
					elseif UIOverrides.MutedTextColor and (base.TextTransparency or 0) >= 0.28 then
						instance.TextColor3 = UISettings.MutedTextColor
					end
				end

				if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
					if UIOverrides.AccentColor and isAccentColor(base.ImageColor3) then
						instance.ImageColor3 = UISettings.AccentColor
					elseif UIOverrides.TextColor and base.ImageColor3 and base.ImageColor3.R > 0.45 and base.ImageColor3.G > 0.45 and base.ImageColor3.B > 0.45 then
						instance.ImageColor3 = blendColor(base.ImageColor3, UISettings.TextColor, 0.75)
					end
				end

				if instance:IsA("UIStroke") then
					if UIOverrides.AccentColor and isAccentColor(base.Color) then instance.Color = UISettings.AccentColor end
				end

				if instance:IsA("UICorner") and base.CornerRadius and UIOverrides.CornerRadius then

					if base.CornerRadius.Scale < 0.4 then instance.CornerRadius = UDim.new(0, UISettings.CornerRadius) end
				end
			end

			local function applyUITheme()
				if themeDestroyed or not newWindow or not newWindow.Parent then return end
				UISettings.Enabled = hasUIOverrides()
				if not UISettings.Enabled then return end

				local liquid = UIOverrides.BackgroundMode and UISettings.BackgroundMode == "Liquid Glass"
				local imageMode = UIOverrides.BackgroundMode and UISettings.BackgroundMode == "Image"

				if UIOverrides.WindowWidth or UIOverrides.WindowHeight then applyWindowSizeOverrides() end
				if UIOverrides.BackgroundColor then newWindow.BackgroundColor3 = UISettings.BackgroundColor end
				if UIOverrides.WindowOpacity then
					local rootBase = captureThemeBase(newWindow)
					newWindow.BackgroundTransparency = opacityFromBase(rootBase.BackgroundTransparency, UISettings.WindowOpacity)
				end

				backgroundLayer.Visible = false
				liquidGradient.Parent = nil
				liquidStroke.Transparency = 1
				liquidBlur.Size = 0
				liquidBlur.Enabled = false

				if imageMode then
					backgroundLayer.Image = resolveBackgroundImage(UISettings.BackgroundImage)
					backgroundLayer.ScaleType = imageScaleType(UISettings.BackgroundImageScale)
					backgroundLayer.ImageTransparency = math.clamp(UISettings.BackgroundImageTransparency / 100, 0, 1)
					backgroundLayer.Visible = backgroundLayer.Image ~= ""
					if backgroundLayer.Visible then newWindow.BackgroundTransparency = 1 end
				elseif liquid then
					local strength = math.clamp(UISettings.LiquidGlassStrength / 100, 0, 1)
					local rootBase = captureThemeBase(newWindow)
					newWindow.BackgroundTransparency = math.max(newWindow.BackgroundTransparency, opacityFromBase(rootBase.BackgroundTransparency, 94 - 18 * strength))
					liquidGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
						ColorSequenceKeypoint.new(0.55, rootBase.BackgroundColor3 or Color3.fromRGB(37,40,47)),
						ColorSequenceKeypoint.new(1, UIOverrides.AccentColor and UISettings.AccentColor or Color3.fromRGB(120,170,255)),
					})
					liquidGradient.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.90 - 0.10 * strength),
						NumberSequenceKeypoint.new(0.55, 0.96),
						NumberSequenceKeypoint.new(1, 0.91 - 0.08 * strength),
					})
					liquidGradient.Parent = newWindow
					liquidStroke.Color = Color3.fromRGB(236,243,255)
					liquidStroke.Transparency = math.clamp(0.92 - 0.18 * strength, 0.68, 0.94)
					if UIOverrides.Blur then
						liquidBlur.Size = UISettings.Blur
						liquidBlur.Enabled = UISettings.Blur > 0 and newWindow.Visible
					end
				end

				if UIOverrides.UIScale then
					uiScale.Scale = UISettings.UIScale
					floatingScale.Scale = UISettings.UIScale
				end
				if UIOverrides.ShowFloatingButtonText and floatingText then
					floatingText.Visible = UISettings.ShowFloatingButtonText
				end

				if UIOverrides.AnimationSpeed or UIOverrides.ReduceMotion then
					local speed = UIOverrides.AnimationSpeed and math.max(UISettings.AnimationSpeed, 0.2) or 1
					if UIOverrides.ReduceMotion and UISettings.ReduceMotion then speed = 100 end
					TweenConfigs.Global.Duration = math.max(0.01, BASE_TWEEN.Global / speed)
					TweenConfigs.Notification.Duration = math.max(0.01, BASE_TWEEN.Notification / speed)
					TweenConfigs.PopupOpen.Duration = math.max(0.01, BASE_TWEEN.PopupOpen / speed)
					TweenConfigs.PopupClose.Duration = math.max(0.01, BASE_TWEEN.PopupClose / speed)
				end

				for _, descendant in ipairs(newWindow:GetDescendants()) do applyThemeToObject(descendant) end
				for _, descendant in ipairs(newFloatingIcon:GetDescendants()) do applyThemeToObject(descendant) end
				applyThemeToObject(newFloatingIcon)
			end

			local function scheduleThemeApply()
				themeApplyToken += 1
				local token = themeApplyToken
				task.delay(0.03, function()
					if token == themeApplyToken and not themeDestroyed then applyUITheme() end
				end)
			end

			local function storeUISettings(force)
				CONFIG.__NgotUISettings = serializeUISettings(UISettings)
				if force then return WRITECONFIG(true) end
				return SAVECONFIG()
			end

