--[[ xngot-studio · src/modules/40_window/240_dialog.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.dialog
     role   : Window:Dialog + nút xác nhận
     source : main 2.txt L14367-14508 · 142 dòng · delta +0
--]]
			function Window:Dialog(data)
				data = data or {}
				local Dialog = {
					Title = data.Title or "Dialog",
					Content = data.Content or "",
					Icon = data.Icon,
					Buttons = type(data.Buttons) == "table" and data.Buttons or {},

					Size = nil,
					PressDecreaseSize = UDim2.fromOffset(5,5)
				}

				local newDialog = Templates.DialogElements.Dialog:Clone()
				local newDialogDarkOverlay = Templates.DialogElements.DarkOverlayDialog:Clone()

				newDialog.Title.TextLabel.Text = Dialog.Title
				newDialog.Content.Visible = Dialog.Content ~= ""
				newDialog.Content.TextLabel.Text = Dialog.Content

				if Dialog.Icon then
					ApplyIcon(newDialog.Title.Icon, Dialog.Icon)
					newDialog.Title.Icon.Visible = true
				end

				newDialog.Parent = newWindow
				newDialogDarkOverlay.Parent = newWindow

				Dialog.Size = UDim2.fromOffset(newDialog.AbsoluteSize.X, newDialog.AbsoluteSize.Y)
				newDialogDarkOverlay.BackgroundTransparency = 1
				local dialogClosed = false
				local function CloseDialog()
					if dialogClosed then return end
					dialogClosed = true
					if newDialog and newDialog.Parent then newDialog:Destroy() end
					if newDialogDarkOverlay and newDialogDarkOverlay.Parent then
						local tw = Tween(newDialogDarkOverlay, {BackgroundTransparency = 1}, TweenConfigs.Global)
						tw.Completed:Wait()
						if newDialogDarkOverlay.Parent then newDialogDarkOverlay:Destroy() end
					end
				end
				function Dialog:Close() CloseDialog() end

				for _, button in Dialog.Buttons do
					if type(button) ~= "table" then continue end
					local buttonData = {
						Title = button.Title or "Button",
						Callback = type(button.Callback) == "function" and button.Callback or function() end
					}

					local newButton = Templates.DialogElements.DialogButton:Clone()
					local originalSize = newButton.Button.Size

					newButton.Button.Label.Text = buttonData.Title

					newButton.Button.MouseButton1Click:Connect(function()
						CloseDialog()
						local ok, err = pcall(buttonData.Callback)
						if not ok then warn("Dialog callback error: " .. tostring(err)) end
					end)

					newButton.Button.MouseButton1Down:Connect(function()
						Tween(newButton.Button, {Size = originalSize - Dialog.PressDecreaseSize}, TweenConfigs.Global)
					end)

					newButton.Button.MouseButton1Up:Connect(function()
						Tween(newButton.Button, {Size = originalSize}, TweenConfigs.Global)
					end)

					newButton.Button.MouseLeave:Connect(function()
						Tween(newButton.Button, {Size = originalSize}, TweenConfigs.Global)
					end)

					newButton.Parent = newDialog.Buttons
					newButton.Visible = true
				end

				Tween(newDialogDarkOverlay, {BackgroundTransparency = 0.6}, TweenConfigs.Global)

				newDialog.Visible = true
				newDialogDarkOverlay.Visible = true

				return Dialog
			end

			local oldWindowSize = Window.Size

			local oldWindowSizeMaximize = Window.Size
			local oldWindowPositionMaximize = newWindow.Position
			local maximizedWindow = false

			local windowDraggable = Draggable(newWindow.TopFrame, newWindow)
			local floatingDraggable = Draggable(newFloatingIcon, newFloatingIcon)
			local keybindConnection = nil

			local resizeHandle = Instance.new("ImageButton")
			resizeHandle.Name = "ResizeHandle"
			resizeHandle.BackgroundTransparency = 1
			resizeHandle.AutoButtonColor = false
			resizeHandle.ImageColor3 = Color3.fromRGB(150, 155, 165)
			resizeHandle.ImageTransparency = 0.6
			resizeHandle.Image = (IconModule.Icon("move-diagonal-2") and IconModule.Icon("move-diagonal-2")[1]) or ""
			resizeHandle.ImageRectOffset = (IconModule.Icon("move-diagonal-2") and IconModule.Icon("move-diagonal-2")[2].ImageRectPosition) or Vector2.new(0,0)
			resizeHandle.ImageRectSize = (IconModule.Icon("move-diagonal-2") and IconModule.Icon("move-diagonal-2")[2].ImageRectSize) or Vector2.new(0,0)
			resizeHandle.AnchorPoint = Vector2.new(1, 1)
			resizeHandle.Position = UDim2.new(1, -3, 1, -3)
			resizeHandle.Size = UDim2.new(0, 16, 0, 16)
			resizeHandle.ZIndex = 10
			resizeHandle.Parent = newWindow

			resizeHandle.MouseEnter:Connect(function()
				Tween(resizeHandle, {ImageTransparency = 0}, TweenConfigs.Global)
			end)
			resizeHandle.MouseLeave:Connect(function()
				Tween(resizeHandle, {ImageTransparency = 0.6}, TweenConfigs.Global)
			end)

			local windowResizable = Resizable(
				resizeHandle,
				newWindow,
				Vector2.new(420, 300),
				Vector2.new(1000, 800)
			)

			newWindow.Visible = true
			newWindow.Size = UDim2.fromOffset(0,0)

			local windowstate = newWindow.Visible
			local startupGatePassed = true  
			local startupGateFinished = true
			local startupMenuBuilt = false
			local timeout = false
			local windowDestroyed = false
			Window.__IslandReady = false
			local function releaseStartupIsland()
				if windowDestroyed or not startupMenuBuilt or not startupGateFinished then return end
				Window.__IslandReady = true
				local islandApi = Window.DynamicIsland
				if islandApi and type(islandApi.Enable) == "function" then
					pcall(islandApi.Enable, islandApi, islandApi.Enabled)
				end
			end

			windowSizeRuntimeSetter = function(size)
				if typeof(size) ~= "UDim2" then return end
				Window.Size = size
				oldWindowSize = size
				if maximizedWindow then
					oldWindowSizeMaximize = size
				elseif windowstate and newWindow and newWindow.Parent then
					newWindow.Size = size
				end
			end
