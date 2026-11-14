--[[ xngot-studio · src/modules/40_window/030_value_helpers.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.values
     role   : clampNumber/colorToHex/colorFrom/font helpers
     source : main 2.txt L11211-11381 · 171 dòng · delta +0
--]]
			local function clampNumber(value, minimum, maximum, fallback)
				value = tonumber(value)
				if value == nil then return fallback end
				return math.clamp(value, minimum, maximum)
			end

			local function colorToHex(color)
				if typeof(color) ~= "Color3" then return "#FFFFFF" end
				return string.format("#%02X%02X%02X",
					math.floor(color.R * 255 + 0.5),
					math.floor(color.G * 255 + 0.5),
					math.floor(color.B * 255 + 0.5)
				)
			end

			local function colorFrom(value, fallback)
				if typeof(value) == "Color3" then return value end
				if type(value) == "table" then
					local r = tonumber(value.R or value.r or value[1])
					local g = tonumber(value.G or value.g or value[2])
					local b = tonumber(value.B or value.b or value[3])
					if r and g and b then
						if math.max(r, g, b) <= 1 then return Color3.new(r, g, b) end
						return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
					end
				end
				if type(value) == "string" then
					local hex = value:gsub("#", ""):gsub("0x", "")
					if #hex == 6 and hex:match("^[%x]+$") then
						return Color3.fromRGB(
							tonumber(hex:sub(1, 2), 16),
							tonumber(hex:sub(3, 4), 16),
							tonumber(hex:sub(5, 6), 16)
						)
					end
				end
				return fallback
			end

			local FONT_MAP = {
				Gotham = Enum.Font.Gotham,
				GothamMedium = Enum.Font.GothamMedium,
				GothamBold = Enum.Font.GothamBold,
				SourceSans = Enum.Font.SourceSans,
				SourceSansSemibold = Enum.Font.SourceSansSemibold,
				SourceSansBold = Enum.Font.SourceSansBold,
				Arial = Enum.Font.Arial,
				ArialBold = Enum.Font.ArialBold,
				Code = Enum.Font.Code,
				Cartoon = Enum.Font.Cartoon,
				SciFi = Enum.Font.SciFi,
			}

			local function normalizeFontSelection(value)
				value = tostring(value or "Original")
				if value == "GothamMedium" or value == "GothamBold" then return "Gotham" end
				if value == "SourceSansSemibold" or value == "SourceSansBold" then return "SourceSans" end
				if value == "ArialBold" then return "Arial" end
				if value == "Original" or value == "Gotham" or value == "SourceSans" or value == "Arial" or value == "Code" or value == "Cartoon" or value == "SciFi" then
					return value
				end
				return "Original"
			end

			local function fontForBase(baseFont, family)
				family = normalizeFontSelection(family)
				if family == "Original" then return baseFont end
				if family == "Code" or family == "Cartoon" or family == "SciFi" then
					return FONT_MAP[family] or baseFont
				end

				local baseName = tostring(baseFont or "")
				local bold = string.find(baseName, "Bold", 1, true) ~= nil or string.find(baseName, "Black", 1, true) ~= nil
				local medium = bold or string.find(baseName, "Medium", 1, true) ~= nil or string.find(baseName, "Semibold", 1, true) ~= nil

				if family == "Gotham" then
					if bold then return Enum.Font.GothamBold end
					if medium then return Enum.Font.GothamMedium end
					return Enum.Font.Gotham
				elseif family == "SourceSans" then
					if bold then return Enum.Font.SourceSansBold end
					if medium then return Enum.Font.SourceSansSemibold end
					return Enum.Font.SourceSans
				elseif family == "Arial" then
					return bold and Enum.Font.ArialBold or Enum.Font.Arial
				end
				return baseFont
			end

			local originalWindowSize = Window.Size
			local originalWindowWidth = tonumber(Window.Size.X.Offset) or 0
			local originalWindowHeight = tonumber(Window.Size.Y.Offset) or 0
			if originalWindowWidth <= 0 then originalWindowWidth = math.max(420, math.floor(newWindow.AbsoluteSize.X + 0.5)) end
			if originalWindowHeight <= 0 then originalWindowHeight = math.max(300, math.floor(newWindow.AbsoluteSize.Y + 0.5)) end
			originalWindowWidth = math.clamp(originalWindowWidth, 420, 1000)
			originalWindowHeight = math.clamp(originalWindowHeight, 300, 800)
			local windowSizeRuntimeSetter = nil

			local UI_DEFAULTS = {
				Enabled = false,
				Preset = "Default",
				Font = "Original",
				TextScale = 1,
				UIScale = 1,
				WindowWidth = originalWindowWidth,
				WindowHeight = originalWindowHeight,
				WindowOpacity = 100,
				BoxOpacity = 100,
				BackgroundMode = "Color",
				BackgroundColor = Color3.fromRGB(37, 40, 47),
				SurfaceColor = Color3.fromRGB(32, 35, 41),
				AccentColor = Color3.fromRGB(10, 135, 213),
				TextColor = Color3.fromRGB(197, 204, 219),
				MutedTextColor = Color3.fromRGB(150, 155, 165),
				BackgroundImage = "",
				BackgroundImageTransparency = 25,
				BackgroundImageScale = "Crop",
				Blur = 0,
				CornerRadius = 10,
				AnimationSpeed = 1,
				ReduceMotion = false,
				LiquidGlassStrength = 55,
				ShowFloatingButtonText = true,
			}

			local UI_PRESETS = {
				Default = {},
				Midnight = {
					BackgroundColor = Color3.fromRGB(15, 18, 25), SurfaceColor = Color3.fromRGB(22, 27, 38),
					AccentColor = Color3.fromRGB(88, 166, 255), TextColor = Color3.fromRGB(232, 237, 247),
					MutedTextColor = Color3.fromRGB(142, 153, 174), WindowOpacity = 100, BoxOpacity = 96,
					CornerRadius = 12, Blur = 0, BackgroundMode = "Color",
				},
				OLED = {
					BackgroundColor = Color3.fromRGB(0, 0, 0), SurfaceColor = Color3.fromRGB(10, 10, 12),
					AccentColor = Color3.fromRGB(0, 170, 255), TextColor = Color3.fromRGB(245, 245, 247),
					MutedTextColor = Color3.fromRGB(145, 145, 150), WindowOpacity = 100, BoxOpacity = 100,
					CornerRadius = 10, Blur = 0, BackgroundMode = "Color",
				},
				Light = {
					BackgroundColor = Color3.fromRGB(242, 244, 248), SurfaceColor = Color3.fromRGB(255, 255, 255),
					AccentColor = Color3.fromRGB(0, 122, 255), TextColor = Color3.fromRGB(28, 30, 34),
					MutedTextColor = Color3.fromRGB(94, 99, 110), WindowOpacity = 100, BoxOpacity = 96,
					CornerRadius = 12, Blur = 0, BackgroundMode = "Color",
				},
				Ocean = {
					BackgroundColor = Color3.fromRGB(12, 24, 36), SurfaceColor = Color3.fromRGB(18, 38, 52),
					AccentColor = Color3.fromRGB(0, 188, 212), TextColor = Color3.fromRGB(224, 247, 250),
					MutedTextColor = Color3.fromRGB(128, 177, 188), WindowOpacity = 98, BoxOpacity = 92,
					CornerRadius = 14, Blur = 4, BackgroundMode = "Color",
				},
				Violet = {
					BackgroundColor = Color3.fromRGB(27, 20, 40), SurfaceColor = Color3.fromRGB(39, 29, 58),
					AccentColor = Color3.fromRGB(168, 85, 247), TextColor = Color3.fromRGB(245, 238, 255),
					MutedTextColor = Color3.fromRGB(177, 157, 199), WindowOpacity = 98, BoxOpacity = 92,
					CornerRadius = 14, Blur = 4, BackgroundMode = "Color",
				},
				Rose = {
					BackgroundColor = Color3.fromRGB(21, 21, 21), SurfaceColor = Color3.fromRGB(31, 31, 31),
					AccentColor = Color3.fromRGB(183, 243, 74), TextColor = Color3.fromRGB(243, 243, 238),
					MutedTextColor = Color3.fromRGB(134, 134, 128), WindowOpacity = 100, BoxOpacity = 96,
					CornerRadius = 12, Blur = 0, BackgroundMode = "Color",
				},
				["Liquid Glass"] = {
					BackgroundColor = Color3.fromRGB(22, 25, 31), SurfaceColor = Color3.fromRGB(47, 53, 63),
					AccentColor = Color3.fromRGB(0, 122, 255), TextColor = Color3.fromRGB(245, 247, 252),
					MutedTextColor = Color3.fromRGB(183, 190, 203), WindowOpacity = 72, BoxOpacity = 58,
					CornerRadius = 18, Blur = 18, BackgroundMode = "Liquid Glass", LiquidGlassStrength = 62,
				},
			}

