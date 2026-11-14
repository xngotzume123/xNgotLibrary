--[[ xngot-studio · src/modules/40_window/330_island_tab.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.island_tab
     role   : Tab bảng nổi: toggle/slider theme/ngôn ngữ
     source : main 2.txt L16815-17059 · 245 dòng · delta +0
--]]
				local IslandTab = Window:Tab({ Title = "Dynamic Island", Icon = "audio-lines", __System = true })
				Window.DynamicIslandTab = IslandTab
				if Window.DynamicIslandError then
					IslandTab:Paragraph({Title = "Dynamic Island startup error", Desc = Window.DynamicIslandError})
				end
				SettingsTab:Section({ Title = "Dynamic Island", Default = true })
				SettingsTab:Paragraph({Title = "Integrated Dynamic Island", Desc = "Music, Cross AI, alerts and timers are built into this library. No second UI library is loaded."})
				SettingsTab:Button({Title = "Open Dynamic Island Settings", Icon = "audio-lines", Callback = function() Window:SelectTab("Dynamic Island") end})
				IslandTab:Paragraph({Title = "Dynamic Island v3", Desc = "All controls are native to NgotStudio UI. Tap the island to toggle the window; hold for island controls."})

				local function addToggle(title, key, desc)
					IslandTab:Toggle({Title = title, Desc = desc or "", Default = islandSettings[key], Callback = function(value)
						changeIsland(key, value, key == "Enabled" and "Enable" or nil)
					end})
				end
				local function addSlider(title, key, minV, maxV)
					IslandTab:Slider({Title = title, Value = {Min = minV, Max = maxV, Default = islandSettings[key]}, Callback = function(value)
						changeIsland(key, tonumber(value) or minV)
					end})
				end

				IslandTab:Section({Title = "Display", Default = true})
				addToggle("Enable Dynamic Island", "Enabled")
				addToggle("Show FPS", "Fps")
				addToggle("Show Clock", "Clock")
				addToggle("Auto Hide Notifications", "AutoHide")
				addToggle("Expand on Interaction", "Expand")
				addSlider("Notification Duration", "Duration", 1, 12)
				IslandTab:Button({Title = "Send Test Notification", Callback = function()
					Window:NotifyIsland("xNgot Library", "Notification sent from the built-in library", "success", 3.5)
				end})

				IslandTab:Section({Title = "Appearance", Default = false})
				local themeLabels = {"Dark", "Light", "Midnight", "Ocean", "Forest", "Coffee", "Sakura"}
				IslandTab:Dropdown({Title = "Island Theme", Values = themeLabels, Value = themeLabels[islandSettings.Theme] or "Dark", Callback = function(v)
					local i = table.find(themeLabels, v) or 1
					changeIsland("Theme", i, "Theme")
				end})
				local accentLabels = {"Blue", "Purple", "Pink", "Orange", "Green", "Cyan"}
				IslandTab:Dropdown({Title = "Island Accent", Values = accentLabels, Value = accentLabels[islandSettings.Accent] or "Blue", Callback = function(v)
						local i = table.find(accentLabels, v) or 1
						changeIsland("Accent", i, "Accent")
					end})

				IslandTab:Section({Title = "Sound", Default = false})
				addToggle("UI Sound", "Sound")
				addSlider("Sound Volume", "Volume", 0, 100)

				IslandTab:Section({Title = "Music", Default = true})
				do
				local musicOptionIndexes = {}
				local musicOptionForIndex = {}
				local changingMusicOption = false
				local refreshMusicOptions
				local songSelector = IslandTab:Dropdown({
					Title = "Select Track",
					Desc = "Tracks from your music library; select one to play it instantly.",
					Values = {"Loading track list..."},
					Value = "Loading track list...",
					Callback = function(label)
						if changingMusicOption then return end
						local trackIndex = musicOptionIndexes[label]
						if trackIndex and islandCall("MusicSelect", trackIndex, true) then
							islandSettings.SelectedMusicValue = label
							SAVECONFIG()
						end
					end,
				})
				Window._MusicRowDecorate = function(value, button)
					local rows = Window._MusicRowsByValue
					local row = rows and rows[value]
					if not row or type(row) ~= "table" then return end

					local okKind = false
					pcall(function() okKind = button:IsA("ImageButton") or button:IsA("TextButton") end)
					if not okKind and type(button) ~= "table" then return end
					if not button.Frame then return end
					pcall(function()
						local frame = button.Frame
						if not frame or frame:GetAttribute("MusicRow") then return end
						frame:SetAttribute("MusicRow", true)

						local meta = {}
						if row.Artist ~= "" then table.insert(meta, row.Artist) end
						if row.Duration ~= "" then table.insert(meta, row.Duration) end
						if row.Source ~= "" then table.insert(meta, row.Source) end
						local metaText = table.concat(meta, " · ")

						frame.Title.Text = row.Title
						frame.Title.TextTruncate = Enum.TextTruncate.AtEnd
						frame.Description.Text = metaText
						frame.Description.Visible = metaText ~= ""
						frame.Description.TextSize = 13
						frame.Description.TextXAlignment = Enum.TextXAlignment.Left
						for _, child in ipairs(frame:GetChildren()) do
						if child:IsA("UIPadding") then child.PaddingLeft = UDim.new(0, 48) end
					end

						local holder = Instance.new("Frame")
						holder.Name = "MusicThumb"
						holder.AnchorPoint = Vector2.new(0, 0.5)
						holder.Position = UDim2.new(0, 10, 0.5, 0)
						holder.Size = UDim2.fromOffset(28, 28)
						holder.BackgroundColor3 = Color3.fromRGB(72, 76, 88)
						holder.BorderSizePixel = 0
						holder.ZIndex = 3
						holder.Parent = button
						local round = Instance.new("UICorner", holder)
						round.CornerRadius = UDim.new(0, 7)

						local asset = row.CoverAsset
						if type(asset) == "string" and asset ~= "" then
							local img = Instance.new("ImageLabel")
							img.Name = "Cover"
							img.BackgroundTransparency = 1
							img.Size = UDim2.fromScale(1, 1)
							img.ScaleType = Enum.ScaleType.Crop
							img.Image = asset
							img.ZIndex = 4
							img.Parent = holder
							local imgRound = Instance.new("UICorner", img)
							imgRound.CornerRadius = UDim.new(0, 7)
						else
							local note = Instance.new("TextLabel")
							note.BackgroundTransparency = 1
							note.Size = UDim2.fromScale(1, 1)
							note.Font = Enum.Font.GothamBold
							note.TextSize = 14
							note.TextColor3 = Color3.fromRGB(255, 255, 255)
							note.Text = "♪"
							note.ZIndex = 4
							note.Parent = holder
						end
					end)
				end

				refreshMusicOptions = function()
					local api = Window.DynamicIsland
					if not api or type(api.MusicCatalog) ~= "function" then return end
					local catalog, state = api:MusicCatalog()
					local rowsApi = type(api.MusicRows) == "function" and select(1, api:MusicRows()) or nil

					local choices, byValue, byIndex, byValueRow, seen = {}, {}, {}, {}, {}
					for _, track in ipairs(catalog) do
						local row = (rowsApi and rowsApi[track.Index]) or track.Row or {}
						local title = tostring(row.Title or track.Name or "Unknown track")
						local artist = tostring(row.Artist or track.Artist or "")
						local duration = tostring(row.Duration or track.Duration or "")
						local source = tostring(row.Source or "")
						local label = tostring(row.Value or track.Value or "")
						if label == "" then
							label = string.format("%02d. %s", track.Index, title)
						end
						local base, dup = label, 2
						while seen[label] do
							label = base .. " (" .. dup .. ")"
							dup = dup + 1
						end
						seen[label] = true
						choices[#choices + 1] = label
						byValue[label] = track.Index
						byIndex[track.Index] = label
						byValueRow[label] = {
							Title = title,
							Artist = artist,
							Duration = duration,
							Source = source,
							CoverAsset = tostring(row.CoverAsset or track.CoverAsset or ""),
							Thumbnail = tostring(row.Thumbnail or track.Thumbnail or ""),
						}
					end

					if #choices == 0 then
						choices = {
							state == "failed" and "Network error, no music found"
								or state == "localempty" and "No downloaded music yet — search and download your first track"
								or state == "empty" and "No track matched"
								or "Music AI is searching...",
						}
					end

					musicOptionIndexes = byValue
					musicOptionForIndex = byIndex
					Window._MusicRowsByValue = byValueRow

					Window._MusicTriggerLabels = Window._MusicTriggerLabels or {}
					for value, info in pairs(byValueRow) do
						local bits = { info.Title }
						if info.Artist ~= "" then bits[#bits + 1] = info.Artist end
						if info.Duration ~= "" then bits[#bits + 1] = info.Duration end
						Window._MusicTriggerLabels[value] = table.concat(bits, " · ")
					end

					changingMusicOption = true
					songSelector:Refresh(choices)

					local function prettyTrigger()
						local labels = Window._MusicTriggerLabels
						local value = songSelector.Value
						local text = value and labels and labels[value]
						if not text then return end
						local title = songSelector.Title
						local box = title and title.BoxFrame
						local trigger = box and box.Trigger
						if trigger and trigger.Title then trigger.Title.Text = text end
					end
					Window._MusicPrettyTrigger = prettyTrigger
					task.defer(prettyTrigger)
					if #catalog > 0 then
						local currentChoice = musicOptionForIndex[api:State().MusicIndex]
						local savedChoice = islandSettings.SelectedMusicValue or islandSettings.SelectedMusicSong
						local selected = currentChoice or (byValue[savedChoice] and savedChoice) or choices[1]
						songSelector:Select(selected)
						if not api:State().Playing then
							api:MusicSelect(byValue[selected], false)
						end
					else
						songSelector:Select(choices[1])
					end
					changingMusicOption = false
				end
				Window._RefreshMusicLanguage = refreshMusicOptions
				if Window.DynamicIsland then
					Window.DynamicIsland:OnMusicCatalogChanged(function()
						task.defer(refreshMusicOptions)
					end)
					Window.DynamicIsland:OnMusicChanged(function()
						if changingMusicOption then return end
						local api = Window.DynamicIsland
						if not api then return end
						local state = api:State()
						local nextSong = musicOptionForIndex[state.MusicIndex]
						if nextSong and songSelector.Value ~= nextSong then
							changingMusicOption = true
							songSelector:Select(nextSong)
							changingMusicOption = false
						end
					end)
					refreshMusicOptions()
				end
				end
				IslandTab:Button({Title = "Play / Pause", Callback = function() islandCall("PlayMusic") end})
				IslandTab:Button({Title = "Next Track", Callback = function() islandCall("NextMusic", 1) end})
				IslandTab:Button({Title = "Previous Track", Callback = function() islandCall("NextMusic", -1) end})
				IslandTab:Slider({Title = "Volume", Value = {Min = 0, Max = 100, Default = 40}, Callback = function(v) islandCall("MusicVolume", v) end})
