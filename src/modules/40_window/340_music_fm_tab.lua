--[[ xngot-studio · src/modules/40_window/340_music_fm_tab.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.music_tab
     role   : Tab nhạc + AI prompt + file manager trong tab island
     source : main 2.txt L17060-17212 · 153 dòng · delta -2
--]]
				local aiMusicPrompt = ""
				IslandTab:Input({Title = "Music description (AI)",
					Placeholder = "e.g. chill lofi music for the evening",
					Callback = function(v) aiMusicPrompt = tostring(v or "") end})
				IslandTab:Button({Title = "Search with AI",
					Callback = function() islandCall("MusicSearch", aiMusicPrompt) end})

				local function cfgSet(key, value)
					local c = _G.xNgotMusicConfig
					if c and type(c.Set) == "function" then return c:Set(key, value) end
					return false
				end
				local musicConfig = _G.xNgotMusicConfig
				local regionLabels = { auto = "Auto", global = "Global", VN = "Vietnam", US = "United States", KR = "Korea", JP = "Japan" }
				local regionCodes = { Auto = "auto", Global = "global", Vietnam = "VN", ["United States"] = "US", Korea = "KR", Japan = "JP" }
				local initialRegion = musicConfig and musicConfig:Get("region") or "auto"
				IslandTab:Dropdown({Title = "Music region", Desc = "Auto uses Roblox region / locale. Region is a search preference, not a guaranteed language filter.",
					Values = {"Auto", "Global", "Vietnam", "United States", "Korea", "Japan"}, Value = regionLabels[initialRegion] or "Auto",
					Callback = function(label) cfgSet("region", regionCodes[tostring(label)] or "auto") end})
				local sourceLabels = { youtube = "YouTube", soundcloud = "SoundCloud", audius = "Audius" }
				local sourceCodes = { YouTube = "youtube", SoundCloud = "soundcloud", Audius = "audius" }
				local initialSources = musicConfig and musicConfig:Get("sources") or {}
				local initialSource = #initialSources == 1 and sourceLabels[initialSources[1]] or "All"
				IslandTab:Dropdown({Title = "Music platform", Desc = "All searches YouTube, SoundCloud and Audius. Availability depends on the search service.",
					Values = {"All", "YouTube", "SoundCloud", "Audius"}, Value = initialSource or "All",
					Callback = function(label)
						local code = sourceCodes[tostring(label)]
						cfgSet("sources", code and {code} or {"youtube", "soundcloud", "audius"})
					end})
				IslandTab:Toggle({Title = "Preload next track", Desc = "Prepare the next track from the current results at 50%; Auto play must be on.",
					Default = not musicConfig or musicConfig:Get("prefetchNext") ~= false,
					Callback = function(v) cfgSet("prefetchNext", v) end})
				IslandTab:Slider({Title = "Results per search", Value = {Min = 4, Max = 30, Default = 12},
					Callback = function(v) cfgSet("topN", v) end})
				IslandTab:Slider({Title = "Parallel downloads", Value = {Min = 1, Max = 4, Default = 2},
					Callback = function(v) cfgSet("raceTracks", v) end})
				IslandTab:Toggle({Title = "Cover art in lists", Default = true,
					Callback = function(v) cfgSet("coverArt", v) end})
				IslandTab:Dropdown({Title = "Quick preset", Values = {"Default", "Fast", "Quality", "Low data", "Vietnamese"},
					Value = "Default",
					Callback = function(label)
						local map = { Fast = "fast", Quality = "quality", ["Low data"] = "lowdata", Vietnamese = "vietnamese" }
						local name = map[tostring(label)]
						if name and _G.xNgotMusicConfig then _G.xNgotMusicConfig:Preset(name) end
					end})
				IslandTab:Button({Title = "Open Player in Island", Callback = function() islandCall("Expand", "Music") end})

				 
				IslandTab:Section({Title = "Storage & File Manager", Default = true})
				IslandTab:Paragraph({Title = "Downloaded music is loaded first", Desc = "Every time the script starts, Select Track is filled from the mp3 files already downloaded in the cache folder. The script no longer auto-searches new 'lofi chill' music; it only searches when you type a description in the Music section and press Search with AI."})
				local fmFiles, fmByLabel, fmSelectedPath, fmChanging = {}, {}, nil, false
				local fmStorage = IslandTab:Paragraph({Title = "Downloaded Music Storage", Desc = "Waiting to scan the cache folder..."})
				local fmSelector = IslandTab:Dropdown({
					Title = "Downloaded Music Files", Desc = "Select a file to play or delete it.",
					Values = {"No files yet"}, Value = "No files yet",
					Callback = function(label)
						if fmChanging then return end
						fmSelectedPath = fmByLabel[tostring(label or "")]
					end,
				})
				local function fmNotify(message, kind)
					pcall(function() Window:NotifyIsland("File Manager", tostring(message), kind or "info", 3) end)
				end
				local fmRefresh
				fmRefresh = function(withSizes)
					local api = Window.DynamicIsland
					if not api or type(api.MusicFiles) ~= "function" then
						fmStorage:SetDesc("Dynamic Island is not ready yet.")
						return
					end
					local files, stats = api:MusicFiles(withSizes ~= false)
					files = type(files) == "table" and files or {}
					stats = type(stats) == "table" and stats or {}
					fmFiles, fmByLabel = files, {}
					if stats.Supported == false then
						fmStorage:SetDesc("This executor does not support listfiles, so the music folder cannot be scanned. An executor with listfiles / readfile / delfile is required.")
					else
						fmStorage:SetDesc(string.format("%d tracks · Total %s · MP3 %s · Covers %s (%d files) · Folder: %s",
							tonumber(stats.Count) or #files, tostring(stats.TotalText or "0 B"), tostring(stats.Mp3Text or "0 B"),
							tostring(stats.CoversText or "0 B"), tonumber(stats.CoversCount) or 0, tostring(stats.Folder or "xNgotLibrary/Music")))
					end
					local labels, seen = {}, {}
					for index, file in ipairs(files) do
						local label = string.format("%02d. %s", index, tostring(file.Title or file.FileName or "Downloaded track"))
						if file.Artist and tostring(file.Artist) ~= "" then label = label .. " — " .. tostring(file.Artist) end
						if file.SizeText and file.SizeText ~= "" then label = label .. " · " .. file.SizeText end
						local base, dup = label, 2
						while seen[label] do label = base .. " (" .. dup .. ")"; dup = dup + 1 end
						seen[label] = true
						labels[#labels + 1] = label
						fmByLabel[label] = file.Path
					end
					if #labels == 0 then labels = {"No files yet"} end
					fmChanging = true
					fmSelector:Refresh(labels)
					if files[1] then
						fmSelector:Select(labels[1])
						fmSelectedPath = files[1].Path
					else
						fmSelectedPath = nil
					end
					fmChanging = false
				end
				IslandTab:Button({Title = "Rescan Storage & Files", Desc = "Re-read the cache folder and total up MP3 + cover sizes.", Callback = function()
					fmRefresh(true)
					fmNotify("Downloaded music folder rescanned", "success")
				end})
				IslandTab:Button({Title = "Load Downloaded into Select Track", Desc = "Replace the current track list with music downloaded on this device.", Callback = function()
					local api = Window.DynamicIsland
					local count = 0
					if api and type(api.MusicLoadDownloaded) == "function" then count = api:MusicLoadDownloaded() or 0 end
					fmRefresh(true)
					fmNotify(count > 0 and ("Loaded " .. count .. " downloaded tracks") or "No downloaded music files yet", count > 0 and "success" or "warn")
				end})
				IslandTab:Button({Title = "Play Selected File", Callback = function()
					if not fmSelectedPath then fmNotify("Select a file first", "warn"); return end
					local api = Window.DynamicIsland
					local ok = api and type(api.MusicPlayFile) == "function" and api:MusicPlayFile(fmSelectedPath)
					fmNotify(ok and "Playing the selected file" or "Could not play the selected file", ok and "success" or "warn")
				end})
				IslandTab:Button({Title = "Delete Selected File", Callback = function()
					if not fmSelectedPath then fmNotify("Select a file first", "warn"); return end
					local path = fmSelectedPath
					Window:Dialog({
						Title = "Delete Music File", Content = "Delete this file from the cache folder?\n" .. tostring(path), Icon = "trash-2",
						Buttons = {
							{ Title = "Cancel" },
							{ Title = "Delete", Callback = function()
								local api = Window.DynamicIsland
								local ok, err = false, "Dynamic Island is not ready yet"
								if api and type(api.MusicDeleteFile) == "function" then ok, err = api:MusicDeleteFile(path) end
								if ok then
									if api and type(api.MusicLoadDownloaded) == "function" then pcall(function() api:MusicLoadDownloaded() end) end
									fmNotify("Selected file deleted", "success")
								else
									fmNotify(tostring(err or "Could not delete the file"), "warn")
								end
								fmRefresh(true)
							end },
						},
					})
				end})
				IslandTab:Button({Title = "Delete All Downloaded Music", Desc = "Only deletes .mp3 files in the music cache folder; config is kept.", Callback = function()
					Window:Dialog({
						Title = "Delete All Downloaded Music", Content = string.format("Delete all %d downloaded mp3 files? Covers and config will be kept.", #fmFiles), Icon = "trash-2",
						Buttons = {
							{ Title = "Cancel" },
							{ Title = "Delete all", Callback = function()
								local api = Window.DynamicIsland
								local deleted, failed = 0, 0
								if api and type(api.MusicClearDownloaded) == "function" then deleted, failed = api:MusicClearDownloaded() end
								if api and type(api.MusicLoadDownloaded) == "function" then pcall(function() api:MusicLoadDownloaded() end) end
								fmRefresh(true)
								fmNotify(string.format("Deleted %d files, %d failed", deleted, failed), failed == 0 and "success" or "warn")
							end },
						},
					})
				end})
				task.spawn(function()
					for _ = 1, 10 do
						if Window.DynamicIsland and type(Window.DynamicIsland.MusicFiles) == "function" then break end
						task.wait(0.5)
					end
					fmRefresh(true)
				end)

				Window:SetUILanguage()

			end

			if windowDestroyed then return Window end
			WindowByTitle[Window.Title] = Window
			startupMenuBuilt = true
			releaseStartupIsland()
			return Window
		end

