--[[ xngot-studio · src/modules/40_window/070_set_ui_setting.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.set_ui_setting
     role   : setUISetting + queueUISettingsSave
     source : main 2.txt L11874-11919 · 46 dòng · delta +0
--]]
			function Window:SaveConfig()
				CONFIG.__NgotUISettings = serializeUISettings(UISettings)
				return WRITECONFIG(true)
			end

			local function queueUISettingsSave()
				if settingsBuilding or not Window.AutoSave then return end
				uiSaveToken += 1
				local token = uiSaveToken
				task.delay(0.4, function()
					if token == uiSaveToken and not themeDestroyed then storeUISettings(false) end
				end)
			end

			local function setUISetting(key, value)
				if settingsBuilding then return end
				key = tostring(key or "")

				restoreOverrideKey(key)

				if key == "Font" then
					value = normalizeFontSelection(value)
					UISettings.Font = value
					if value == "Original" then
						setOverride(key, false)
					else
						setOverride(key, true)
					end
				elseif key == "BackgroundColor" or key == "SurfaceColor" or key == "AccentColor" or key == "TextColor" or key == "MutedTextColor" then
					UISettings[key] = colorFrom(value, UISettings[key])
					setOverride(key, true)
				else
					UISettings[key] = value
					setOverride(key, true)
				end

				UISettings.Preset = hasUIOverrides() and "Custom" or "Default"
				if settingsControls.Preset and type(settingsControls.Preset.Select) == "function" then
					settingsBuilding = true
					pcall(settingsControls.Preset.Select, settingsControls.Preset, UISettings.Preset)
					settingsBuilding = false
				end
				applyUITheme()
				queueUISettingsSave()
			end

