--[[ xngot-studio · src/modules/40_window/080_settings_presets.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.settings_presets
     role   : applyPreset + API UI: SetUISettings/Export/Import/Profile
     source : main 2.txt L11920-12166 · 247 dòng · delta +0
--]]
			local function applyPreset(name, save)
				name = tostring(name or "Default")
				if name == "Default" then
					for key, value in pairs(UI_DEFAULTS) do UISettings[key] = value end
					UIOverrides = {}
					UISettings.Enabled = false
					UISettings.Preset = "Default"
					restoreOriginalUI()
					syncSettingsControls()
					if save ~= false then queueUISettingsSave() end
					return true
				end
				if name == "Custom" then
					UISettings.Enabled = hasUIOverrides()
					UISettings.Preset = "Custom"
					if save ~= false then queueUISettingsSave() end
					return true
				end
				local preset = UI_PRESETS[name]
				if not preset then return false end
				restoreOriginalUI()
				for key, value in pairs(UI_DEFAULTS) do UISettings[key] = value end
				UIOverrides = {}
				for key, value in pairs(preset) do UISettings[key] = value; UIOverrides[key] = true end
				UISettings.Enabled = hasUIOverrides()
				UISettings.Preset = name
				applyUITheme()
				syncSettingsControls()
				if save ~= false then queueUISettingsSave() end
				return true
			end

			function Window:SetUISize(width, height, save)
				width = math.floor(math.clamp(tonumber(width) or UISettings.WindowWidth, 420, 1000) + 0.5)
				height = math.floor(math.clamp(tonumber(height) or UISettings.WindowHeight, 300, 800) + 0.5)
				restoreOverrideKey("WindowWidth")
				restoreOverrideKey("WindowHeight")
				UISettings.WindowWidth = width
				UISettings.WindowHeight = height
				setOverride("WindowWidth", width ~= originalWindowWidth)
				setOverride("WindowHeight", height ~= originalWindowHeight)
				UISettings.Preset = hasUIOverrides() and "Custom" or "Default"
				applyWindowSizeOverrides()
				syncSettingsControls()
				if save ~= false then queueUISettingsSave() end
				return Window.Size
			end

			function Window:GetUISize()
				local size = getDesiredWindowSize()
				return size, UISettings.WindowWidth, UISettings.WindowHeight
			end

			function Window:ResetUISize(save)
				UIOverrides.WindowWidth = nil
				UIOverrides.WindowHeight = nil
				UISettings.WindowWidth = originalWindowWidth
				UISettings.WindowHeight = originalWindowHeight
				UISettings.Enabled = hasUIOverrides()
				UISettings.Preset = UISettings.Enabled and "Custom" or "Default"
				applyWindowSizeOverrides()
				syncSettingsControls()
				if save ~= false then queueUISettingsSave() end
				return Window.Size
			end

			function Window:GetUISettings()
				local result = copySettings(UISettings)
				result.Overrides = copyOverrides(UIOverrides)
				return result
			end

			function Window:GetUIOverrides()
				return copyOverrides(UIOverrides)
			end

			function Window:ClearUIOverride(key, save)
				key = tostring(key or "")
				UIOverrides[key] = nil
				if UI_DEFAULTS[key] ~= nil then UISettings[key] = UI_DEFAULTS[key] end
				restoreOverrideKey(key)
				UISettings.Enabled = hasUIOverrides()
				UISettings.Preset = UISettings.Enabled and "Custom" or "Default"
				applyUITheme()
				syncSettingsControls()
				if save ~= false then queueUISettingsSave() end
				return true
			end

			function Window:SetUISettings(settings, save)
				if type(settings) ~= "table" then return Window:GetUISettings() end
				if settings.Preset == "Default" or settings.Enabled == false then
					applyPreset("Default", save)
					return Window:GetUISettings()
				end
				restoreOriginalUI()
				for key, value in pairs(UI_DEFAULTS) do UISettings[key] = value end
				UIOverrides = {}
				mergeUISettings(settings)
				if type(settings.Overrides) == "table" then
					UIOverrides = copyOverrides(settings.Overrides)
				else
					for key in pairs(settings) do
						if UI_DEFAULTS[key] ~= nil and key ~= "Enabled" and key ~= "Preset" then UIOverrides[key] = true end
					end
				end
				UISettings.Preset = tostring(settings.Preset or "Custom")
				UISettings.Enabled = hasUIOverrides()
				applyUITheme()
				syncSettingsControls()
				if save ~= false then queueUISettingsSave() end
				return Window:GetUISettings()
			end

			function Window:ApplyUIPreset(name, save)
				return applyPreset(name, save)
			end

			function Window:UseOriginalUI(save)
				return applyPreset("Default", save)
			end

			function Window:GetUIPresets()
				local names = {}
				for name in pairs(UI_PRESETS) do table.insert(names, name) end
				table.sort(names)
				table.insert(names, "Custom")
				return names
			end

			function Window:SaveUISettings()
				return storeUISettings(true)
			end

			function Window:ExportUISettings()
				local ok, result = pcall(HttpService.JSONEncode, HttpService, serializeUISettings(UISettings))
				return ok and result or nil
			end

			function Window:ImportUISettings(json, save)
				if type(json) ~= "string" or json == "" then return false, "Empty JSON" end
				local ok, decoded = pcall(HttpService.JSONDecode, HttpService, json)
				if not ok or type(decoded) ~= "table" then return false, tostring(decoded) end
				local imported = decoded.UISettings or decoded
				restoreOriginalUI()
				for key, value in pairs(UI_DEFAULTS) do UISettings[key] = value end
				UIOverrides = {}
				mergeUISettings(imported)
				if type(imported.Overrides) == "table" then
					UIOverrides = copyOverrides(imported.Overrides)
				else
					UIOverrides = {}
					for key in pairs(imported) do
						if UI_DEFAULTS[key] ~= nil and key ~= "Enabled" and key ~= "Preset" then UIOverrides[key] = true end
					end
				end
				UISettings.Preset = "Custom"
				UISettings.Enabled = hasUIOverrides()
				applyUITheme()
				syncSettingsControls()
				if save ~= false then storeUISettings(true) end
				return true
			end

			function Window:ResetUISettings(save)
				restoreOriginalUI()
				for key, value in pairs(UI_DEFAULTS) do UISettings[key] = value end
				UIOverrides = {}
				UISettings.Enabled = false
				UISettings.Preset = "Default"
				syncSettingsControls()
				if save ~= false then storeUISettings(true) end
				return Window:GetUISettings()
			end

			function Window:GetUIProfileNames()
				local names = {}
				for name, profile in pairs(CONFIG.__NgotUIProfiles) do
					if type(name) == "string" and type(profile) == "table" then table.insert(names, name) end
				end
				table.sort(names)
				return names
			end

			function Window:SaveUIProfile(name)
				name = tostring(name or ""):match("^%s*(.-)%s*$")
				if name == "" then return false, "Profile name is empty" end
				CONFIG.__NgotUIProfiles[name] = serializeUISettings(UISettings)
				return WRITECONFIG(true)
			end

			function Window:LoadUIProfile(name, save)
				local profile = CONFIG.__NgotUIProfiles[tostring(name or "")]
				if type(profile) ~= "table" then return false, "Profile not found" end
				if profile.SettingsVersion ~= 3 then return false, "Legacy UI profile. Save it again with the current UI version." end
				restoreOriginalUI()
				for key, value in pairs(UI_DEFAULTS) do UISettings[key] = value end
				UIOverrides = {}
				mergeUISettings(profile)
				UIOverrides = type(profile.Overrides) == "table" and copyOverrides(profile.Overrides) or {}
				UISettings.Preset = tostring(profile.Preset or (hasUIOverrides() and "Custom" or "Default"))
				UISettings.Enabled = hasUIOverrides()
				applyUITheme()
				syncSettingsControls()
				if save ~= false then storeUISettings(true) end
				return true
			end

			function Window:DeleteUIProfile(name)
				name = tostring(name or "")
				if CONFIG.__NgotUIProfiles[name] == nil then return false end
				CONFIG.__NgotUIProfiles[name] = nil
				return WRITECONFIG(true)
			end

			function Window:DeleteConfig()
				if type(delfile) ~= "function" then return false, "delfile unavailable" end
				local exists = true
				if type(isfile) == "function" then
					local ok, result = pcall(isfile, Window.ConfigPath)
					exists = ok and result == true
				end
				if not exists then return true end
				local ok, err = pcall(delfile, Window.ConfigPath)
				return ok, err
			end

			local themeDescendantConnection = newWindow.DescendantAdded:Connect(function(descendant)
				task.defer(function()
					if UISettings.Enabled and not themeDestroyed and descendant and descendant.Parent then
						applyThemeToObject(descendant)
					end
				end)
			end)

			local themeVisibilityConnection = newWindow:GetPropertyChangedSignal("Visible"):Connect(function()
				if liquidBlur then
					liquidBlur.Enabled = UISettings.Enabled and UIOverrides.BackgroundMode and UISettings.BackgroundMode == "Liquid Glass" and UIOverrides.Blur and UISettings.Blur > 0 and newWindow.Visible
				end
			end)

			applyUITheme()

			local selected
			local TabLists = {}
			local TabIndexList = {}
			local UserTabIndexList = {}
