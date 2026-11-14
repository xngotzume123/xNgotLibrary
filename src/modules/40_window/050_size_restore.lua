--[[ xngot-studio · src/modules/40_window/050_size_restore.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.size
     role   : Kích thước cửa sổ, restoreOriginalUI, accent, ảnh nền
     source : main 2.txt L11586-11736 · 151 dòng · delta +0
--]]
			local function getDesiredWindowSize()
				if not UIOverrides.WindowWidth and not UIOverrides.WindowHeight then
					return originalWindowSize
				end
				local width = UIOverrides.WindowWidth and UISettings.WindowWidth or originalWindowWidth
				local height = UIOverrides.WindowHeight and UISettings.WindowHeight or originalWindowHeight
				return UDim2.fromOffset(
					math.floor(math.clamp(tonumber(width) or originalWindowWidth, 420, 1000) + 0.5),
					math.floor(math.clamp(tonumber(height) or originalWindowHeight, 300, 800) + 0.5)
				)
			end

			local function applyWindowSizeOverrides()
				local desired = getDesiredWindowSize()
				Window.Size = desired
				if type(windowSizeRuntimeSetter) == "function" then
					windowSizeRuntimeSetter(desired)
				elseif newWindow and newWindow.Parent then
					newWindow.Size = desired
				end
				return desired
			end

			local function restoreOriginalUI()
				if themeDestroyed then return end
				Window.Size = originalWindowSize
				if type(windowSizeRuntimeSetter) == "function" then
					windowSizeRuntimeSetter(originalWindowSize)
				elseif newWindow and newWindow.Parent then
					newWindow.Size = originalWindowSize
				end
				for instance in pairs(themeBase) do
					restoreThemeObject(instance)
				end
				backgroundLayer.Visible = false
				backgroundLayer.Image = ""
				backgroundLayer.ImageTransparency = 1
				liquidGradient.Parent = nil
				liquidStroke.Transparency = 1
				uiScale.Scale = 1
				floatingScale.Scale = 1
				if floatingText and floatingTextOriginalVisible ~= nil then
					floatingText.Visible = floatingTextOriginalVisible
				end
				restoreThemeObject(newFloatingIcon)
				TweenConfigs.Global.Duration = BASE_TWEEN.Global
				TweenConfigs.Notification.Duration = BASE_TWEEN.Notification
				TweenConfigs.PopupOpen.Duration = BASE_TWEEN.PopupOpen
				TweenConfigs.PopupClose.Duration = BASE_TWEEN.PopupClose
				liquidBlur.Size = 0
				liquidBlur.Enabled = false
			end

			local function restoreOverrideKey(key)
				key = tostring(key or "")

				if key == "WindowWidth" or key == "WindowHeight" then
					applyWindowSizeOverrides()
				elseif key == "BackgroundColor" then
					local base = themeBase[newWindow]
					if base and base.BackgroundColor3 ~= nil then newWindow.BackgroundColor3 = base.BackgroundColor3 end
				elseif key == "WindowOpacity" then
					local base = themeBase[newWindow]
					if base and base.BackgroundTransparency ~= nil then newWindow.BackgroundTransparency = base.BackgroundTransparency end
				elseif key == "BackgroundMode" then
					local base = themeBase[newWindow]
					if base and base.BackgroundTransparency ~= nil then newWindow.BackgroundTransparency = base.BackgroundTransparency end
					backgroundLayer.Visible = false
					backgroundLayer.Image = ""
					liquidGradient.Parent = nil
					liquidStroke.Transparency = 1
					liquidBlur.Size = 0
					liquidBlur.Enabled = false
				elseif key == "BackgroundImage" then
					backgroundLayer.Image = ""
				elseif key == "BackgroundImageTransparency" then
					backgroundLayer.ImageTransparency = 1
				elseif key == "BackgroundImageScale" then
					backgroundLayer.ScaleType = Enum.ScaleType.Crop
				elseif key == "UIScale" then
					uiScale.Scale = 1
					floatingScale.Scale = 1
				elseif key == "ShowFloatingButtonText" then
					if floatingText and floatingTextOriginalVisible ~= nil then floatingText.Visible = floatingTextOriginalVisible end
				elseif key == "AnimationSpeed" or key == "ReduceMotion" then
					TweenConfigs.Global.Duration = BASE_TWEEN.Global
					TweenConfigs.Notification.Duration = BASE_TWEEN.Notification
					TweenConfigs.PopupOpen.Duration = BASE_TWEEN.PopupOpen
					TweenConfigs.PopupClose.Duration = BASE_TWEEN.PopupClose
				elseif key == "Blur" then
					liquidBlur.Size = 0
					liquidBlur.Enabled = false
				end

				for instance, base in pairs(themeBase) do
					if instance and instance.Parent and base then
						if key == "Font" and (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
							if base.Font ~= nil then instance.Font = base.Font end
						elseif key == "TextScale" and (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
							if base.TextSize ~= nil then instance.TextSize = base.TextSize end
						elseif key == "SurfaceColor" and instance:IsA("GuiObject") and instance ~= newWindow then
							if base.BackgroundColor3 ~= nil then instance.BackgroundColor3 = base.BackgroundColor3 end
						elseif key == "AccentColor" then
							if instance:IsA("GuiObject") and instance ~= newWindow and base.BackgroundColor3 ~= nil then instance.BackgroundColor3 = base.BackgroundColor3 end
							if (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) and base.ImageColor3 ~= nil then instance.ImageColor3 = base.ImageColor3 end
							if instance:IsA("UIStroke") and base.Color ~= nil then instance.Color = base.Color end
						elseif key == "TextColor" then
							if (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) and base.TextColor3 ~= nil then instance.TextColor3 = base.TextColor3 end
							if (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) and base.ImageColor3 ~= nil then instance.ImageColor3 = base.ImageColor3 end
						elseif key == "MutedTextColor" and (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
							if base.TextColor3 ~= nil then instance.TextColor3 = base.TextColor3 end
						elseif key == "BoxOpacity" and instance:IsA("GuiObject") and instance ~= newWindow then
							if base.BackgroundTransparency ~= nil then instance.BackgroundTransparency = base.BackgroundTransparency end
						elseif key == "CornerRadius" and instance:IsA("UICorner") then
							if base.CornerRadius ~= nil then instance.CornerRadius = base.CornerRadius end
						end
					end
				end
			end

			local function isAccentColor(color)
				if typeof(color) ~= "Color3" then return false end
				local h, s, v = color:ToHSV()
				return h >= 0.50 and h <= 0.67 and s >= 0.40 and v >= 0.45
			end

			local function imageScaleType(name)
				if name == "Fit" then return Enum.ScaleType.Fit end
				if name == "Stretch" then return Enum.ScaleType.Stretch end
				if name == "Tile" then return Enum.ScaleType.Tile end
				return Enum.ScaleType.Crop
			end

			local function resolveBackgroundImage(value)
				value = tostring(value or "")
				if value == "" then return "" end
				if tonumber(value) then return "rbxassetid://" .. value end
				return value
			end

			local function blendColor(baseColor, targetColor, amount)
				if typeof(baseColor) ~= "Color3" or typeof(targetColor) ~= "Color3" then return baseColor end
				return baseColor:Lerp(targetColor, math.clamp(amount or 0.65, 0, 1))
			end

			local function opacityFromBase(baseTransparency, opacityPercent)
				baseTransparency = tonumber(baseTransparency) or 0
				local opacity = math.clamp((tonumber(opacityPercent) or 100) / 100, 0, 1)
				return 1 - ((1 - baseTransparency) * opacity)
			end

