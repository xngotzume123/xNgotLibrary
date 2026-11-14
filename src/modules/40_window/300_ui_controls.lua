--[[ xngot-studio · src/modules/40_window/300_ui_controls.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.ui_controls
     role   : Điều khiển UI: font, scale, kích thước, blur, opacity
     source : main 2.txt L16130-16287 · 158 dòng · delta +0
--]]
					Values = { "Original", "Gotham", "SourceSans", "Arial", "Code", "Cartoon", "SciFi" },
					Value = UISettings.Font,
					Callback = function(value) setUISetting("Font", value) end,
				})

				settingsControls.TextScale = SettingsTab:Slider({
					Title = "Text Scale", Desc = "Scale text without resizing the whole window.", Step = 0.05,
					Value = { Min = 0.7, Max = 1.5, Default = UISettings.TextScale },
					Callback = function(value) setUISetting("TextScale", value) end,
				})

				settingsControls.UIScale = SettingsTab:Slider({
					Title = "UI Scale (Zoom)", Desc = "Zoom the whole UI without changing the saved window width/height.", Step = 0.05,
					Value = { Min = 0.65, Max = 1.5, Default = UISettings.UIScale },
					Callback = function(value) setUISetting("UIScale", value) end,
				})

				SettingsTab:Section({ Title = "Window Size", Default = true })
				settingsControls.WindowWidth = SettingsTab:Slider({
					Title = "Window Width",
					Desc = "Changes only the window width. Original layout/style is preserved.",
					Step = 10,
					Value = { Min = 420, Max = 1000, Default = UISettings.WindowWidth },
					Callback = function(value)
						if settingsBuilding then return end
						value = math.floor((tonumber(value) or originalWindowWidth) + 0.5)
						if value == originalWindowWidth then
							Window:ClearUIOverride("WindowWidth", true)
						else
							setUISetting("WindowWidth", value)
						end
					end,
				})
				settingsControls.WindowHeight = SettingsTab:Slider({
					Title = "Window Height",
					Desc = "Changes only the window height. Original layout/style is preserved.",
					Step = 10,
					Value = { Min = 300, Max = 800, Default = UISettings.WindowHeight },
					Callback = function(value)
						if settingsBuilding then return end
						value = math.floor((tonumber(value) or originalWindowHeight) + 0.5)
						if value == originalWindowHeight then
							Window:ClearUIOverride("WindowHeight", true)
						else
							setUISetting("WindowHeight", value)
						end
					end,
				})
				SettingsTab:Button({
					Title = "Reset Window Size",
					Desc = "Restore the exact Size passed to CreateWindow without resetting other customizations.",
					Callback = function() Window:ResetUISize(true) end,
				})

				SettingsTab:Section({ Title = "Theme Details", Default = true })
				settingsControls.CornerRadius = SettingsTab:Slider({
					Title = "Corner Radius", Desc = "Global rounded corner amount.", Step = 1,
					Value = { Min = 0, Max = 28, Default = UISettings.CornerRadius },
					Callback = function(value) setUISetting("CornerRadius", value) end,
				})

				settingsControls.AccentColor = SettingsTab:Colorpicker({
					Title = "Accent Color", Desc = "Buttons, highlights and selected states.", Default = UISettings.AccentColor,
					Callback = function(value) setUISetting("AccentColor", value) end,
				})
				settingsControls.TextColor = SettingsTab:Colorpicker({
					Title = "Text Color", Default = UISettings.TextColor,
					Callback = function(value) setUISetting("TextColor", value) end,
				})
				settingsControls.MutedTextColor = SettingsTab:Colorpicker({
					Title = "Muted Text", Default = UISettings.MutedTextColor,
					Callback = function(value) setUISetting("MutedTextColor", value) end,
				})

				SettingsTab:Section({ Title = "Background & Glass", Default = true })
				settingsControls.BackgroundMode = SettingsTab:Dropdown({
					Title = "Background Mode", Values = { "Color", "Image", "Liquid Glass" }, Value = UISettings.BackgroundMode,
					Callback = function(value) setUISetting("BackgroundMode", value) end,
				})
				settingsControls.BackgroundColor = SettingsTab:Colorpicker({
					Title = "Background Color", Default = UISettings.BackgroundColor,
					Callback = function(value) setUISetting("BackgroundColor", value) end,
				})
				settingsControls.SurfaceColor = SettingsTab:Colorpicker({
					Title = "Box / Surface Color", Default = UISettings.SurfaceColor,
					Callback = function(value) setUISetting("SurfaceColor", value) end,
				})
				settingsControls.WindowOpacity = SettingsTab:Slider({
					Title = "Window Opacity", Desc = "100 = opaque, lower values = more transparent.", Step = 1,
					Value = { Min = 15, Max = 100, Default = UISettings.WindowOpacity },
					Callback = function(value) setUISetting("WindowOpacity", value) end,
				})
				settingsControls.BoxOpacity = SettingsTab:Slider({
					Title = "Box Opacity", Desc = "Opacity of cards, controls and panels.", Step = 1,
					Value = { Min = 10, Max = 100, Default = UISettings.BoxOpacity },
					Callback = function(value) setUISetting("BoxOpacity", value) end,
				})

				local backgroundImageValue = UISettings.BackgroundImage
				settingsControls.BackgroundImage = SettingsTab:Input({
					Title = "Background Image", Desc = "Asset ID or rbxassetid:// URL.", Placeholder = "rbxassetid://123456789",
					Default = backgroundImageValue,
					Callback = function(value)
						backgroundImageValue = tostring(value or "")
						setUISetting("BackgroundImage", backgroundImageValue)
					end,
				})
				settingsControls.BackgroundImageScale = SettingsTab:Dropdown({
					Title = "Image Scale", Values = { "Crop", "Fit", "Stretch", "Tile" }, Value = UISettings.BackgroundImageScale,
					Callback = function(value) setUISetting("BackgroundImageScale", value) end,
				})
				settingsControls.BackgroundImageTransparency = SettingsTab:Slider({
					Title = "Image Transparency", Step = 1,
					Value = { Min = 0, Max = 100, Default = UISettings.BackgroundImageTransparency },
					Callback = function(value) setUISetting("BackgroundImageTransparency", value) end,
				})
				settingsControls.Blur = SettingsTab:Slider({
					Title = "Glass Blur", Desc = "BlurEffect strength used by Liquid Glass.", Step = 1,
					Value = { Min = 0, Max = 32, Default = UISettings.Blur },
					Callback = function(value) setUISetting("Blur", value) end,
				})
				settingsControls.LiquidGlassStrength = SettingsTab:Slider({
					Title = "Liquid Glass Strength", Desc = "Controls panel translucency and highlight intensity.", Step = 1,
					Value = { Min = 0, Max = 100, Default = UISettings.LiquidGlassStrength },
					Callback = function(value) setUISetting("LiquidGlassStrength", value) end,
				})

				SettingsTab:Section({ Title = "Motion & Controls", Default = false })
				settingsControls.AnimationSpeed = SettingsTab:Slider({
					Title = "Animation Speed", Desc = "1.0 = normal. Higher = faster.", Step = 0.05,
					Value = { Min = 0.2, Max = 3, Default = UISettings.AnimationSpeed },
					Callback = function(value) setUISetting("AnimationSpeed", value) end,
				})
				settingsControls.ReduceMotion = SettingsTab:Toggle({
					Title = "Reduce Motion", Desc = "Makes most UI transitions nearly instant.", Default = UISettings.ReduceMotion,
					Callback = function(value) setUISetting("ReduceMotion", value == true) end,
				})
				settingsControls.ShowFloatingButtonText = SettingsTab:Toggle({
					Title = "Floating Button Text", Desc = "Show the window title on the floating open button.", Default = UISettings.ShowFloatingButtonText,
					Callback = function(value) setUISetting("ShowFloatingButtonText", value == true) end,
				})

				SettingsTab:Section({ Title = "Save Management", Default = false })
				SettingsTab:Toggle({
					Title = "Auto Save", Desc = "Automatically save element config and UI settings.", Default = Window.AutoSave,
					Callback = function(value)
						Window.AutoSave = value == true
						if Window.AutoSave and not settingsBuilding then storeUISettings(true) end
					end,
				})
				SettingsTab:Button({
					Title = "Save Now", Desc = "Immediately write all current settings to disk.",
					Callback = function()
						storeUISettings(true)
						LIB:Notify({ Title = "Settings Ui", Content = "Config saved.", Icon = "save", Duration = 2.5 })
					end,
				})

