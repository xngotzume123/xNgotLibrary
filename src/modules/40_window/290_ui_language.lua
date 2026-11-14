--[[ xngot-studio · src/modules/40_window/290_ui_language.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.ui_language
     role   : GetUILanguage / SetUILanguage
     source : main 2.txt L16104-16129 · 26 dòng · delta +0
--]]
				function Window:GetUILanguage() return "en" end
				function Window:SetUILanguage()
					if self.DynamicIsland and type(self.DynamicIsland.SetLanguage) == "function" then
						pcall(self.DynamicIsland.SetLanguage, self.DynamicIsland, "en")
					end
					return "en"
				end

				SettingsTab:Section({ Title = "Theme & Appearance", Default = true })
				local presetNames = Window:GetUIPresets()
				local presetDropdown
				presetDropdown = SettingsTab:Dropdown({
					Title = "Theme Preset",
					Desc = "Default restores the exact original UI. Presets intentionally change multiple appearance settings; individual controls below change only themselves.",
					Values = presetNames,
					Value = table.find(presetNames, UISettings.Preset) and UISettings.Preset or "Default",
					Callback = function(value)
						if settingsBuilding then return end
						applyPreset(value, true)
					end,
				})
				settingsControls.Preset = presetDropdown

				settingsControls.Font = SettingsTab:Dropdown({
					Title = "Font Family",
					Desc = "Changes only the font family and preserves the original Regular / Medium / Bold hierarchy.",
