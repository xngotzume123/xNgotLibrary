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

			local touchStarts = setmetatable({}, { __mode = "k" })
			local presses = setmetatable({}, { __mode = "k" })
			local touchConnections = {}
			local function isTouchInput()
				local ok, kind = pcall(function() return UIS:GetLastInputType() end)
				return ok and kind == Enum.UserInputType.Touch
			end
			local function BindSafeActivate(button, callback)
				button.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						touchStarts[input] = { x = input.Position.X, y = input.Position.Y, moved = false }
					end
				end)
				button.Activated:Connect(function(input)
					if input and input.UserInputType == Enum.UserInputType.Touch then
						local start = touchStarts[input]
						if not start or start.moved or input.UserInputState == Enum.UserInputState.Cancel then return end
						local dx, dy = input.Position.X - start.x, input.Position.Y - start.y
						if dx * dx + dy * dy > 144 then return end
					end
					callback()
				end)
			end
			local function BindPressFeedback(button, pressed, released)
				button.InputBegan:Connect(function(input)
					local kind = input.UserInputType
					if kind == Enum.UserInputType.Touch or kind == Enum.UserInputType.MouseButton1 then
						presses[input] = released
						pressed()
					end
				end)
				button.MouseLeave:Connect(function() released() end)
			end
			touchConnections[#touchConnections + 1] = UIS.InputChanged:Connect(function(input)
				local start = touchStarts[input]
				if start then
					local dx, dy = input.Position.X - start.x, input.Position.Y - start.y
					if dx * dx + dy * dy > 144 then start.moved = true end
				end
			end)
			touchConnections[#touchConnections + 1] = UIS.InputEnded:Connect(function(input)
				local release = presses[input]
				presses[input] = nil
				if release then pcall(release) end
				if touchStarts[input] then task.delay(0.5, function() touchStarts[input] = nil end) end
			end)
			touchConnections[#touchConnections + 1] = UIS.WindowFocusReleased:Connect(function()
				for key, release in pairs(presses) do pcall(release); presses[key] = nil end
				table.clear(touchStarts)
			end)
			local function touchCleanup()
				for _, connection in ipairs(touchConnections) do connection:Disconnect() end
				table.clear(touchConnections)
				for key, release in pairs(presses) do pcall(release); presses[key] = nil end
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

			 
			 
			 
			 
			local function SetEmptyTabNotice(visible)
				if not Tabs then return nil end
				local notice = Tabs:FindFirstChild("NoObjectFoundText")
				if not notice then
					local sourceTabs = oldWindow and oldWindow:FindFirstChild("Tabs")
					local sourceNotice = sourceTabs and sourceTabs:FindFirstChild("NoObjectFoundText")
					if sourceNotice then
						notice = sourceNotice:Clone()
					else
						notice = Instance.new("TextLabel")
						notice.Name = "NoObjectFoundText"
						notice.BackgroundTransparency = 1
						notice.BorderSizePixel = 0
						notice.TextWrapped = true
						notice.TextScaled = true
						notice.TextColor3 = Color3.fromRGB(135, 140, 150)
						notice.Text = "This tab is empty :("
						notice.AnchorPoint = Vector2.new(0.5, 0.5)
						notice.Position = UDim2.new(0.5, 0, 0.45, 0)
						notice.Size = UDim2.new(1, 0, 0, 16)
					end
					notice.Parent = Tabs
				end
				notice.Visible = visible == true
				return notice
			end

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

