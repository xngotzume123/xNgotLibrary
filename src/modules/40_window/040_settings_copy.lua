--[[ xngot-studio · src/modules/40_window/040_settings_copy.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.settings_copy
     role   : copy/serialize/merge UISettings + capture/restore theme
     source : main 2.txt L11382-11585 · 204 dòng · delta +0
--]]
			local function copySettings(source)
				local result = {}
				for key, value in pairs(source) do result[key] = value end
				return result
			end

			local UISettings = copySettings(UI_DEFAULTS)

			local UIOverrides = {}

			local function copyOverrides(source)
				local result = {}
				if type(source) == "table" then
					for key, value in pairs(source) do
						if value == true then result[key] = true end
					end
				end
				return result
			end

			local function hasUIOverrides()
				return next(UIOverrides) ~= nil
			end

			local function setOverride(key, enabled)
				if enabled == false then UIOverrides[key] = nil else UIOverrides[key] = true end
				UISettings.Enabled = hasUIOverrides()
			end

			local function serializeUISettings(settings)
				return {
					Enabled = settings.Enabled == true and hasUIOverrides(),
					SettingsVersion = 3,
					Overrides = copyOverrides(UIOverrides),
					Preset = settings.Preset,
					Font = settings.Font,
					TextScale = settings.TextScale,
					UIScale = settings.UIScale,
					WindowWidth = settings.WindowWidth,
					WindowHeight = settings.WindowHeight,
					WindowOpacity = settings.WindowOpacity,
					BoxOpacity = settings.BoxOpacity,
					BackgroundMode = settings.BackgroundMode,
					BackgroundColor = colorToHex(settings.BackgroundColor),
					SurfaceColor = colorToHex(settings.SurfaceColor),
					AccentColor = colorToHex(settings.AccentColor),
					TextColor = colorToHex(settings.TextColor),
					MutedTextColor = colorToHex(settings.MutedTextColor),
					BackgroundImage = settings.BackgroundImage,
					BackgroundImageTransparency = settings.BackgroundImageTransparency,
					BackgroundImageScale = settings.BackgroundImageScale,
					Blur = settings.Blur,
					CornerRadius = settings.CornerRadius,
					AnimationSpeed = settings.AnimationSpeed,
					ReduceMotion = settings.ReduceMotion,
					LiquidGlassStrength = settings.LiquidGlassStrength,
					ShowFloatingButtonText = settings.ShowFloatingButtonText,
				}
			end

			local function mergeUISettings(source)
				if type(source) ~= "table" then return end
				if source.Enabled ~= nil then UISettings.Enabled = source.Enabled == true end
				if type(source.Preset) == "string" then UISettings.Preset = source.Preset end
				if type(source.Font) == "string" then UISettings.Font = normalizeFontSelection(source.Font) end
				UISettings.TextScale = clampNumber(source.TextScale, 0.7, 1.5, UISettings.TextScale)
				UISettings.UIScale = clampNumber(source.UIScale, 0.65, 1.5, UISettings.UIScale)
				UISettings.WindowWidth = clampNumber(source.WindowWidth, 420, 1000, UISettings.WindowWidth)
				UISettings.WindowHeight = clampNumber(source.WindowHeight, 300, 800, UISettings.WindowHeight)
				UISettings.WindowOpacity = clampNumber(source.WindowOpacity, 15, 100, UISettings.WindowOpacity)
				UISettings.BoxOpacity = clampNumber(source.BoxOpacity, 10, 100, UISettings.BoxOpacity)
				if type(source.BackgroundMode) == "string" then UISettings.BackgroundMode = source.BackgroundMode end
				UISettings.BackgroundColor = colorFrom(source.BackgroundColor, UISettings.BackgroundColor)
				UISettings.SurfaceColor = colorFrom(source.SurfaceColor, UISettings.SurfaceColor)
				UISettings.AccentColor = colorFrom(source.AccentColor, UISettings.AccentColor)
				UISettings.TextColor = colorFrom(source.TextColor, UISettings.TextColor)
				UISettings.MutedTextColor = colorFrom(source.MutedTextColor, UISettings.MutedTextColor)
				if source.BackgroundImage ~= nil then UISettings.BackgroundImage = tostring(source.BackgroundImage or "") end
				UISettings.BackgroundImageTransparency = clampNumber(source.BackgroundImageTransparency, 0, 100, UISettings.BackgroundImageTransparency)
				if type(source.BackgroundImageScale) == "string" then UISettings.BackgroundImageScale = source.BackgroundImageScale end
				UISettings.Blur = clampNumber(source.Blur, 0, 32, UISettings.Blur)
				UISettings.CornerRadius = clampNumber(source.CornerRadius, 0, 28, UISettings.CornerRadius)
				UISettings.AnimationSpeed = clampNumber(source.AnimationSpeed, 0.2, 3, UISettings.AnimationSpeed)
				if source.ReduceMotion ~= nil then UISettings.ReduceMotion = source.ReduceMotion == true end
				UISettings.LiquidGlassStrength = clampNumber(source.LiquidGlassStrength, 0, 100, UISettings.LiquidGlassStrength)
				if source.ShowFloatingButtonText ~= nil then UISettings.ShowFloatingButtonText = source.ShowFloatingButtonText == true end
			end

			local savedUISettings = CONFIG.__NgotUISettings

			if type(savedUISettings) == "table" and savedUISettings.SettingsVersion == 3 and type(savedUISettings.Overrides) == "table" then
				mergeUISettings(savedUISettings)
				UIOverrides = copyOverrides(savedUISettings.Overrides)
				UISettings.Enabled = hasUIOverrides()
				if not UISettings.Enabled then UISettings.Preset = "Default" end
			else
				UIOverrides = {}
				UISettings.Enabled = false
				UISettings.Preset = "Default"
			end
			if type(CONFIG.__NgotUIProfiles) ~= "table" then CONFIG.__NgotUIProfiles = {} end

			local backgroundLayer = Instance.new("ImageLabel")
			backgroundLayer.Name = "NgotStudioThemeBackground"
			backgroundLayer.BackgroundTransparency = 1
			backgroundLayer.BorderSizePixel = 0
			backgroundLayer.Size = UDim2.fromScale(1, 1)
			backgroundLayer.Position = UDim2.fromScale(0, 0)
			backgroundLayer.Image = ""
			backgroundLayer.ImageTransparency = 1
			backgroundLayer.ScaleType = Enum.ScaleType.Crop
			backgroundLayer.ZIndex = 0
			backgroundLayer.Parent = newWindow
			local backgroundCorner = Instance.new("UICorner")
			backgroundCorner.Name = "NgotStudioThemeBackgroundCorner"
			backgroundCorner.CornerRadius = UDim.new(0, 10)
			backgroundCorner.Parent = backgroundLayer

			local liquidGradient = Instance.new("UIGradient")
			liquidGradient.Name = "NgotStudioThemeLiquidGradient"
			liquidGradient.Rotation = 135

			local liquidStroke = Instance.new("UIStroke")
			liquidStroke.Name = "NgotStudioThemeLiquidStroke"
			liquidStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			liquidStroke.Thickness = 1.2
			liquidStroke.Transparency = 1
			liquidStroke.Parent = newWindow

			local liquidBlur = Instance.new("BlurEffect")
			liquidBlur.Name = "NgotStudioLiquidGlass_" .. tostring(math.random(100000, 999999))
			liquidBlur.Size = 0
			liquidBlur.Enabled = false
			liquidBlur.Parent = Lighting

			local uiScale = newWindow:FindFirstChild("NgotStudioThemeScale") or Instance.new("UIScale")
			uiScale.Name = "NgotStudioThemeScale"
			uiScale.Parent = newWindow
			local floatingScale = newFloatingIcon:FindFirstChild("NgotStudioThemeScale") or Instance.new("UIScale")
			floatingScale.Name = "NgotStudioThemeScale"
			floatingScale.Parent = newFloatingIcon
			local floatingText = newFloatingIcon:FindFirstChild("TextLabel")
			local floatingTextOriginalVisible = floatingText and floatingText.Visible or nil

			local BASE_TWEEN = { Global = 0.25, Notification = 0.5, PopupOpen = 0.4, PopupClose = 0.4 }

			local function captureThemeBase(instance)
				if themeBase[instance] then return themeBase[instance] end
				local state = {}
				if instance:IsA("GuiObject") then
					state.BackgroundColor3 = instance.BackgroundColor3
					state.BackgroundTransparency = instance.BackgroundTransparency
				end
				if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
					state.TextColor3 = instance.TextColor3
					state.TextTransparency = instance.TextTransparency
					state.Font = instance.Font
					state.TextSize = instance.TextSize
				end
				if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
					state.ImageColor3 = instance.ImageColor3
					state.ImageTransparency = instance.ImageTransparency
				end
				if instance:IsA("UIStroke") then
					state.Color = instance.Color
					state.Transparency = instance.Transparency
					state.Thickness = instance.Thickness
				end
				if instance:IsA("UICorner") then state.CornerRadius = instance.CornerRadius end
				themeBase[instance] = state
				return state
			end

			local function restoreThemeObject(instance)
				local base = themeBase[instance]
				if not base or not instance or not instance.Parent then return end
				if instance:IsA("GuiObject") then
					if base.BackgroundColor3 ~= nil then instance.BackgroundColor3 = base.BackgroundColor3 end
					if base.BackgroundTransparency ~= nil then instance.BackgroundTransparency = base.BackgroundTransparency end
				end
				if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
					if base.TextColor3 ~= nil then instance.TextColor3 = base.TextColor3 end
					if base.TextTransparency ~= nil then instance.TextTransparency = base.TextTransparency end
					if base.Font ~= nil then instance.Font = base.Font end
					if base.TextSize ~= nil then instance.TextSize = base.TextSize end
				end
				if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
					if base.ImageColor3 ~= nil then instance.ImageColor3 = base.ImageColor3 end
					if base.ImageTransparency ~= nil then instance.ImageTransparency = base.ImageTransparency end
				end
				if instance:IsA("UIStroke") then
					if base.Color ~= nil then instance.Color = base.Color end
					if base.Transparency ~= nil then instance.Transparency = base.Transparency end
					if base.Thickness ~= nil then instance.Thickness = base.Thickness end
				end
				if instance:IsA("UICorner") and base.CornerRadius ~= nil then
					instance.CornerRadius = base.CornerRadius
				end
			end

			captureThemeBase(newWindow)
			captureThemeBase(newFloatingIcon)
			if newWindow:FindFirstChild("UICorner") then captureThemeBase(newWindow.UICorner) end

