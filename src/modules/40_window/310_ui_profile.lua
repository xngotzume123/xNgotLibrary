--[[ xngot-studio · src/modules/40_window/310_ui_profile.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.ui_profile
     role   : Lưu/đọc/xoá profile giao diện + import/export JSON
     source : main 2.txt L16288-16426 · 139 dòng · delta +0
--]]
				local profileName = "My Theme"
				local selectedProfile = nil
				SettingsTab:Input({
					Title = "Profile Name", Placeholder = "My Theme", Default = profileName,
					Callback = function(value) profileName = tostring(value or "") end,
				})
				local function profileValues()
					local values = Window:GetUIProfileNames()
					if #values == 0 then return { "None" } end
					return values
				end
				local profileDropdown = SettingsTab:Dropdown({
					Title = "Saved Profiles", Values = profileValues(), Value = "None", AllowNone = true,
					Callback = function(value)
						selectedProfile = value ~= "" and value ~= "None" and value or nil
					end,
				})
				SettingsTab:Button({
					Title = "Save Profile", Desc = "Save the current UI appearance as a named profile.",
					Callback = function()
						local ok, err = Window:SaveUIProfile(profileName)
						profileDropdown:Refresh(profileValues())
						if ok then profileDropdown:Select(profileName) end
						LIB:Notify({ Title = "UI Profile", Content = ok and ("Saved: " .. profileName) or tostring(err), Icon = ok and "circle-check" or "triangle-alert", Duration = 3 })
					end,
				})
				SettingsTab:Button({
					Title = "Load Profile", Desc = "Apply the selected saved profile.",
					Callback = function()
						if not selectedProfile then return end
						local ok, err = Window:LoadUIProfile(selectedProfile, true)
						LIB:Notify({ Title = "UI Profile", Content = ok and ("Loaded: " .. selectedProfile) or tostring(err), Icon = ok and "circle-check" or "triangle-alert", Duration = 3 })
					end,
				})
				SettingsTab:Button({
					Title = "Delete Profile", Desc = "Delete the selected UI profile.",
					Callback = function()
						if not selectedProfile then return end
						local deleted = Window:DeleteUIProfile(selectedProfile)
						if deleted then selectedProfile = nil; profileDropdown:Refresh(profileValues()) end
					end,
				})

				local importJSON = ""
				SettingsTab:Button({
					Title = "Copy UI JSON", Desc = "Copy current UI settings as JSON.",
					Callback = function()
						local json = Window:ExportUISettings()
						if json and CopyText(json) then
							LIB:Notify({ Title = "Settings Ui", Content = "UI JSON copied.", Icon = "copy", Duration = 2.5 })
						end
					end,
				})
				SettingsTab:Input({
					Title = "Import UI JSON", Desc = "Paste exported UI JSON, then press Import.", Placeholder = "{ ... }", MultiLine = true,
					Callback = function(value) importJSON = tostring(value or "") end,
				})
				SettingsTab:Button({
					Title = "Import JSON",
					Callback = function()
						local ok, err = Window:ImportUISettings(importJSON, true)
						LIB:Notify({ Title = "Settings Ui", Content = ok and "UI settings imported." or tostring(err), Icon = ok and "circle-check" or "triangle-alert", Duration = 3 })
					end,
				})
				SettingsTab:Button({
					Title = "Copy Config Path", Desc = Window:GetConfigPath(),
					Callback = function() CopyText(Window:GetConfigPath()) end,
				})
				SettingsTab:Button({
					Title = "Reset UI Settings", Desc = "Restore NgotStudio default appearance.",
					Callback = function()
						Window:Dialog({
							Title = "Reset UI Settings", Content = "Reset all UI/UX customization to defaults?", Icon = "rotate-ccw",
							Buttons = {
								{ Title = "Cancel" },
								{ Title = "Reset", Callback = function()
									Window:ResetUISettings(true)
									LIB:Notify({ Title = "Settings Ui", Content = "UI settings reset.", Icon = "circle-check", Duration = 2.5 })
								end },
							},
						})
					end,
				})
				SettingsTab:Button({
					Title = "Delete Config File", Desc = "Delete the saved config from the executor filesystem.",
					Callback = function()
						Window:Dialog({
							Title = "Delete Config", Content = "Delete the saved config file? Current runtime values stay active until re-execute.", Icon = "trash-2",
							Buttons = {
								{ Title = "Cancel" },
								{ Title = "Delete", Callback = function()
									local ok, err = Window:DeleteConfig()
									LIB:Notify({ Title = "Config", Content = ok and "Config file deleted." or tostring(err), Icon = ok and "circle-check" or "triangle-alert", Duration = 3 })
								end },
							},
						})
					end,
				})

				syncSettingsControls = function()
					if not Window.SettingsUI then return end
					local previous = settingsBuilding
					settingsBuilding = true
					local function setControl(key, method, value)
						local control = settingsControls[key]
						if control and type(control[method]) == "function" then
							pcall(control[method], control, value)
						end
					end
					if UISettings.Preset then setControl("Preset", "Select", UISettings.Preset) end
					setControl("Font", "Select", UISettings.Font)
					setControl("TextScale", "Set", UISettings.TextScale)
					setControl("UIScale", "Set", UISettings.UIScale)
					setControl("WindowWidth", "Set", UISettings.WindowWidth)
					setControl("WindowHeight", "Set", UISettings.WindowHeight)
					setControl("CornerRadius", "Set", UISettings.CornerRadius)
					setControl("AccentColor", "Set", UISettings.AccentColor)
					setControl("TextColor", "Set", UISettings.TextColor)
					setControl("MutedTextColor", "Set", UISettings.MutedTextColor)
					setControl("BackgroundMode", "Select", UISettings.BackgroundMode)
					setControl("BackgroundColor", "Set", UISettings.BackgroundColor)
					setControl("SurfaceColor", "Set", UISettings.SurfaceColor)
					setControl("WindowOpacity", "Set", UISettings.WindowOpacity)
					setControl("BoxOpacity", "Set", UISettings.BoxOpacity)
					setControl("BackgroundImage", "Set", UISettings.BackgroundImage)
					setControl("BackgroundImageScale", "Select", UISettings.BackgroundImageScale)
					setControl("BackgroundImageTransparency", "Set", UISettings.BackgroundImageTransparency)
					setControl("Blur", "Set", UISettings.Blur)
					setControl("LiquidGlassStrength", "Set", UISettings.LiquidGlassStrength)
					setControl("AnimationSpeed", "Set", UISettings.AnimationSpeed)
					setControl("ReduceMotion", "Set", UISettings.ReduceMotion)
					setControl("ShowFloatingButtonText", "Set", UISettings.ShowFloatingButtonText)
					settingsBuilding = previous
				end

				settingsBuilding = false
				applyUITheme()
				CONFIG.__NgotUISettings = serializeUISettings(UISettings)

