--[[ xngot-studio · src/modules/40_window/020_config_io.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.config_io
     role   : WRITECONFIG/SAVECONFIG + Window:SaveConfig/GetConfigPath
     source : main 2.txt L11153-11210 · 58 dòng · delta +0
--]]
			local function WRITECONFIG(force)
				if (not force and not Window.AutoSave) or not canWriteConfig then return false end
				local success, err = pcall(function()
					writefile(Window.ConfigPath, HttpService:JSONEncode(CONFIG))
				end)
				if not success then
					warn("Failed to save config '" .. Window.ConfigPath .. "': " .. tostring(err))
				end
				return success
			end

			local function SAVECONFIG()
				return WRITECONFIG(false)
			end

			function Window:SaveConfig()
				return WRITECONFIG(true)
			end

			function Window:GetConfigPath()
				return Window.ConfigPath
			end

			local windowFolder = Instance.new("Folder")
			windowFolder.Parent = Gui
			Gui.Name = Window.Title

			local newFloatingIcon = oldFloatingIcon:Clone()
			newFloatingIcon.Parent = windowFolder
			newFloatingIcon.TextLabel.Text = Window.Title
			newFloatingIcon.Visible = false
			ApplyIcon(newFloatingIcon.Icon, Window.Icon)

			local newWindow = oldWindow:Clone()
			local mainFrame = newWindow
			local TopFrame = mainFrame.TopFrame
			local TabButtons = mainFrame.TabButtons
			local Tabs = mainFrame.Tabs

			newWindow.Name = Window.Title
			TopFrame.TextLabel.Text = Window.Title .. " - " .. Window.Version
			ApplyIcon(TopFrame.Icon, Window.Icon)

			newWindow.Size = Window.Size
			newWindow.Visible = false
			newWindow.Parent = windowFolder

			table.insert(Windows, newWindow)

			local Lighting = game:GetService("Lighting")
			local themeBase = setmetatable({}, { __mode = "k" })
			local themeDestroyed = false
			local themeApplyToken = 0
			local uiSaveToken = 0
			local settingsControls = {}
			local settingsBuilding = false
			local syncSettingsControls = function() end

