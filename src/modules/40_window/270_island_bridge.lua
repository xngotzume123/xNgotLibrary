--[[ xngot-studio · src/modules/40_window/270_island_bridge.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.island_bridge
     role   : GetDynamicIsland / NotifyIsland / IslandActivity
     source : main 2.txt L15114-15149 · 36 dòng · delta +1
--]]
			function Window:GetDynamicIsland()
				return self.DynamicIsland
			end

			function Window:NotifyIsland(title, message, kind, duration)
				local api = self.DynamicIsland
				if not api or type(api.Notify) ~= "function" then return false end
				local ok, result = pcall(api.Notify, api, title, message, kind, duration)
				return ok and result == true
			end

			function Window:IslandActivity(title, message, duration, kind)
				local api = self.DynamicIsland
				if not api or type(api.GameplayActivity) ~= "function" then return false end
				local ok, result = pcall(api.GameplayActivity, api, title, message, duration, kind)
				return ok and result == true
			end

			if Window.SettingsUI then
				settingsBuilding = true
				CONFIG[Window.SettingsTitle] = {}
				local settingsDivider = Templates.Divider:Clone()
				settingsDivider.Name = "SettingsUiDivider"
				settingsDivider.LayoutOrder = 99999
				settingsDivider.Parent = newWindow.TabButtons.Lists
				settingsDivider.Visible = true
				local SettingsTab = Window:Tab({ Title = Window.SettingsTitle, Icon = Window.SettingsIcon, __System = true })
				Window.SettingsTab = SettingsTab

				 
				 
				 
				 
				 
				 
				 
