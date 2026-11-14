--[[ xngot-studio · src/modules/40_window/100_tab_open.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.tab_open
     role   : Window:Tab — khung tab mới, TabData, Tab:_Use, parentElement
     source : main 2.txt L12336-12421 · 86 dòng · delta +1
--]]
			function Window:Tab(data)
				data = data or {}
				local Tab = {}
				local TabData = {
					Title = data.Title or ("Tab " .. tostring(#UserTabIndexList + 1)),
					Icon = data.Icon or "circle",
					System = data.__System == true,
				}

                local NAMETAB = TabData.Title
                if type(CONFIG[NAMETAB]) ~= "table" then
                    CONFIG[NAMETAB] = {}
                end

				local newTabButton = Templates.TabButton:Clone()
				newTabButton.Name = TabData.Title

				newTabButton.Parent = newWindow.TabButtons.Lists
				newTabButton.Visible = true

				newTabButton.TextLabel.Text = TabData.Title
				ApplyIcon(newTabButton.ImageButton, TabData.Icon)

				local newTab = Templates.Tab:Clone()
				newTab.Name = TabData.Title

				newTab.Parent = newWindow.Tabs
				newTab.Visible = false

				AddTabToList(TabData.Title, newTab, newTabButton, true, TabData.System)
				newTabButton.LayoutOrder = TabData.System and 100000 or (#UserTabIndexList * 10)

				if selected == TabData.Title then
					newTab.Visible = true

					newTabButton.TextLabel.Position =  UDim2.new(0, 57,0.5, 0)
					newTabButton.TextLabel.Size = UDim2.new(0, 88,0, 16)
					newTabButton.TextLabel.TextTransparency = 0

					newTabButton.ImageButton.Position = UDim2.new(0,25,0,18)
					newTabButton.ImageButton.ImageTransparency = 0

					newTabButton.Bar.Size = UDim2.new(0, 5,0, 25)
					newTabButton.Bar.BackgroundTransparency = 0
				else

					newTabButton.TextLabel.Position =  UDim2.new(0, 42,0.5, 0)
					newTabButton.TextLabel.Size = UDim2.new(0, 103,0, 16)
					newTabButton.TextLabel.TextTransparency = 0.5

					newTabButton.ImageButton.Position = UDim2.new(0,12,0,18)
					newTabButton.ImageButton.ImageTransparency = 0.5

					newTabButton.Bar.Size = UDim2.new(0, 5,0, 0)
					newTabButton.Bar.BackgroundTransparency = 1
				end

				newTabButton.MouseButton1Click:Connect(function()
					SelectTab(TabData.Title)
				end)

				local function GetCurrentElementObjects()
					local objects = {}
					for _,v in pairs(newTab:GetChildren()) do
						if v:IsA("GuiObject") then
							table.insert(objects, v)
						end
					end
					return objects
				end

				local parentElement = newTab
				Tab._Container = newTab
				function Tab:_Use(methodName, elementData, targetParent)
					local method = Tab[methodName]
					if type(method) ~= "function" then
						error("Unknown NgotStudio tab method: " .. tostring(methodName), 2)
					end
					local previousParent = parentElement
					parentElement = targetParent or newTab
					local ok, result = pcall(method, Tab, elementData)
					parentElement = previousParent
					if not ok then error(result, 2) end
					return result
				end

