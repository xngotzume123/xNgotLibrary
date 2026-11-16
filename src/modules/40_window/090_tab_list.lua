--[[ xngot-studio · src/modules/40_window/090_tab_list.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.tab_list
     role   : AddTabToList, DropdownPopup, SelectTab (nội bộ)
     source : main 2.txt L12167-12335 · 169 dòng · delta +0
--]]
			local function AddTabToList(name: string, tab: ScrollingFrame, tabbtn: GuiButton, hasicon: boolean, isSystem: boolean)
				local entry = {
					Name = name,
					TabObject = tab,
					TabButton = tabbtn,
					HasIcon = hasicon,
					System = isSystem == true,
				}
				TabLists[name] = entry
				table.insert(TabIndexList, entry)
				if not entry.System then
					table.insert(UserTabIndexList, entry)
				end
			end

			local SelectedDropdown = nil
			local DropdownState = false
			local dropdownTransition = 0
			local function DropdownPopup(state, name, target)
				local opening = state == nil and not DropdownState or state == true
				if opening and name then
					local folder = target or newWindow.DropdownSelection.Dropdowns:FindFirstChild(name)
					if not folder then return end
					SelectedDropdown = folder
					for _, item in newWindow.DropdownSelection.Dropdowns:GetChildren() do
						if item:IsA("Folder") then
							item:FindFirstChild("DropdownItems").Visible = false
							item:FindFirstChild("DropdownItemsSearch").Visible = false
						end
					end
					newWindow.DropdownSelection.TopBar.BoxFrame.Frame.TextBox.Text = ""
					newWindow.DropdownSelection.TopBar.Title.Text = name
					folder:FindFirstChild("DropdownItems").Visible = true
					folder:FindFirstChild("DropdownItemsSearch").Visible = false
				end
				dropdownTransition = dropdownTransition + 1
				local token = dropdownTransition
				DropdownState = opening
				if opening then
					newWindow.DropdownSelection.Size = UDim2.new(0.728, 0, 0.684, 0)
					newWindow.DarkOverlay.BackgroundTransparency = 1
					newWindow.DropdownSelection.Visible = true
					newWindow.DarkOverlay.Visible = true
					Tween(newWindow.DarkOverlay, {BackgroundTransparency = 0.6}, TweenConfigs.PopupOpen)
				else
					newWindow.DropdownSelection.Size = UDim2.new(0, 0, 0, 0)
					local tw = Tween(newWindow.DarkOverlay, {BackgroundTransparency = 1}, TweenConfigs.PopupClose)
					tw.Completed:Wait()
					if token == dropdownTransition and not DropdownState then
						newWindow.DropdownSelection.Visible = false
						newWindow.DarkOverlay.Visible = false
					end
				end
			end

			local function SelectTab(tabName)
				for tablistname, tab in pairs(TabLists) do

					if tablistname ~= tabName then
						tab.TabObject.Visible = false

						Tween(tab.TabButton.TextLabel, {Position = UDim2.new(0, 42,0.5, 0), Size = UDim2.new(0, 103,0, 16), TextTransparency = 0.5}, TweenConfigs.Global)
						Tween(tab.TabButton.ImageButton, {Position = UDim2.new(0,12,0,18), ImageTransparency = 0.5}, TweenConfigs.Global)
						Tween(tab.TabButton.Bar, {Size = UDim2.new(0, 5,0, 0), BackgroundTransparency = 1}, TweenConfigs.Global)
					elseif tablistname == tabName then
						selected = tabName
						tab.TabObject.Visible = true

						Tween(tab.TabButton.TextLabel, {Position = UDim2.new(0, 57,0.5, 0), Size = UDim2.new(0, 88,0, 16), TextTransparency = 0}, TweenConfigs.Global)
						Tween(tab.TabButton.ImageButton, {Position = UDim2.new(0,25,0,18), ImageTransparency = 0}, TweenConfigs.Global)
						Tween(tab.TabButton.Bar, {Size = UDim2.new(0, 5,0, 25), BackgroundTransparency = 0}, TweenConfigs.Global)

						local objectCount = 0
						for _, obj in ipairs(tab.TabObject:GetChildren()) do
							if obj:IsA("GuiObject") then
								objectCount = objectCount + 1
							end
						end
						if objectCount == 0 then
							SetEmptyTabNotice(true)
						else
							SetEmptyTabNotice(false)
						end
					end
				end
			end

			newWindow.DropdownSelection.TopBar.Close.MouseButton1Click:Connect(function() DropdownPopup(false) end)

			local textbox = newWindow.DropdownSelection.TopBar.BoxFrame.Frame.TextBox

			textbox:GetPropertyChangedSignal("Text"):Connect(function()
				if not Window.LiveSearchDropdown then return end
				local currentFolder = SelectedDropdown
				if string.gsub(textbox.Text, " ", "") ~= "" then
					if not currentFolder then return end
					currentFolder:FindFirstChild("DropdownItems").Visible = false
					currentFolder:FindFirstChild("DropdownItemsSearch").Visible = true

					for _,button in currentFolder:FindFirstChild("DropdownItemsSearch"):GetChildren() do
						if button:IsA("GuiButton") then
							if string.find(button.Name:lower(), textbox.Text:lower(), 1, true) then
								button.Visible = true
							else
								button.Visible = false
							end
						end

					end
				else
					currentFolder:FindFirstChild("DropdownItems").Visible = true
					currentFolder:FindFirstChild("DropdownItemsSearch").Visible = false
				end
			end)

			textbox.FocusLost:Connect(function()
				if Window.LiveSearchDropdown then return end
				local currentFolder = SelectedDropdown
				if string.gsub(textbox.Text, " ", "") ~= "" then
					if not currentFolder then return end
					currentFolder:FindFirstChild("DropdownItems").Visible = false
					currentFolder:FindFirstChild("DropdownItemsSearch").Visible = true

					for _,button in currentFolder:FindFirstChild("DropdownItemsSearch"):GetChildren() do
						if button:IsA("GuiButton") then
							if string.find(button.Name:lower(), textbox.Text:lower(), 1, true) then
								button.Visible = true
							else
								button.Visible = false
							end
						end

					end
				else
					currentFolder:FindFirstChild("DropdownItems").Visible = true
					currentFolder:FindFirstChild("DropdownItemsSearch").Visible = false
				end
			end)

