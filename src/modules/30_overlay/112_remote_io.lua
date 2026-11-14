--[[ xngot-studio · src/modules/30_overlay/112_remote_io.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.remote_io
     role   : Nạp nhạc đã tải, phát/dừng, next/shuffle/repeat
     source : main 2.txt L8421-8773 · 353 dòng · delta -1
--]]
		Remote.ScanDownloaded = function(includeSizes)
			local Engine = Remote.Engine or CrossAIMusic
			if Engine and type(Engine.listDownloaded) == "function" then
				local files, stats = Engine.listDownloaded(includeSizes == true)
				files = type(files) == "table" and files or {}
				stats = type(stats) == "table" and stats or {}
				Remote.DownloadedFiles = files
				Remote.DownloadedStats = stats
				return files, stats
			end
			local files, stats = {}, {
				Folder = Remote.Folder, Count = 0, TotalBytes = 0, TotalText = "0 B",
				Mp3Text = "0 B", CoversText = "0 B", CoversCount = 0, Supported = false,
			}
			Remote.DownloadedFiles, Remote.DownloadedStats = files, stats
			return files, stats
		end

		Remote.LoadDownloaded = function()
			-- METADATA: quet kem noi dung file (true) de doc ID3 + anh bia + sidecar, thay vi chi lay ten file/hash.
			local files = Remote.ScanDownloaded(true)
			if #files == 0 then
				if Remote.CatalogSource == "downloaded" then
					for i = #TRACKS, 1, -1 do
						if TRACKS[i].Downloaded then table.remove(TRACKS, i) end
					end
					Remote.Rows, Remote.Labels = {}, {}
					if Music.Playing then
						Music.Playing = false
						Music.Loading = false
						pcall(function() currentSound:Stop() end)
					end
					if #TRACKS > 0 then
						Music.Index = math.clamp(Music.Index, 1, #TRACKS)
						pcall(function() Music.Sync() end)
					end
				end
				Remote.State = "localempty"
				Remote.Count = 0
				Remote.Error = nil
				Remote.Notify()
				return 0
			end
			local items = {}
			for index, file in ipairs(files) do
				items[index] = {
					name = file.Title, author = file.Artist or "", duration = file.Duration or "", thumbnail = file.Thumbnail or "",
					coverAsset = file.CoverAsset, album = file.Album or "",
					source = "local", url = "", id = file.Path,
					path = file.Path, fileName = file.FileName, downloaded = true,
				}
			end
			applyResults(items, { query = "__downloaded__" })
			Remote.CatalogSource = "downloaded"
			Remote.State = "ready"
			Remote.Query = ""
			Remote.Error = nil
			Remote.Notify()
			return #files
		end

		local function fetchRemote(token, track)
			if not Remote.Supported() then
				Music.Playing = false
				Music.Loading = false
				Music.Sync()
				broadcast()
				notify("Music unavailable",
					"Executor requires writefile and getcustomasset/getsynasset to play PoW MP3",
					"warn", 4)
				return
			end

			-- FILE-MANAGER: bai da tai (CachedPath) thi phat thang tu file local, khong tai lai va khong tao Download activity.
			if track.CachedPath and type(track.CachedPath) == "string" and track.CachedPath ~= "" then
				if type(isfile) == "function" and not isfile(track.CachedPath) then
					Music.Playing = false
					Music.Loading = false
					Music.Sync()
					broadcast()
					notify((Settings.Language == "en") and "File missing" or "File da bi xoa",
						tostring(track.FileName or track.Name or ""), "warn", 3, true)
					return
				end
				local getter = getcustomasset or getsynasset
				if type(getter) == "function" then
					local okAsset, asset = pcall(getter, track.CachedPath)
					if okAsset and type(asset) == "string" and asset ~= "" then
						Music.Loading = false
						currentSound.SoundId = asset
						waitAndPlay(token, asset)
						return
					end
				end
			end

			Remote.Progress = 0
			Remote.Label = tostring(track.Name or track.Title or track.Id or "Download")
			Remote.FileName = tostring(track.FileName or (Remote.Label .. ".mp3"))
			local function downloadLabel()
				return Remote.Label
			end
			if type(Music.setDownloadState) == "function" then
				pcall(Music.setDownloadState, 0, Remote.Label)
			end
			Activities.Download = {
				Title = "Download",
				Label = Remote.Label,
				FileName = Remote.FileName,
				Color = Static.Blue,
				Value = function()
					return string.format("%d%%", math.floor((Remote.Progress or 0) * 100 + 0.5))
				end,
				Short = function()
					-- FIX(dynamic-island-bubble): Short chi dung cho bubble 30px nen CHI duoc tra ve gia tri ngan ("0%".."100%").
					-- Ten bai day du da co Media.Title (trong pill) va Label/FileName/Sub (trang Download) phuc vu, khong tra ve o day.
					return string.format("%d%%", math.floor((Remote.Progress or 0) * 100 + 0.5))
				end,
				Sub = downloadLabel,
				Ring = function() return Remote.Progress or 0 end,
				RingMode = "fill",
			}
			refreshActivity()

			task.spawn(function()
				Music.Loading = true
				broadcast()

				local lookup = {
					id = track.Id,
					url = track.Url,
					source = track.Source or "youtube",
					directUrl = nil,
				}
				if lookup.source == "audius" and lookup.id then
					lookup.directUrl = "https://api.audius.co/v1/tracks/"
						.. tostring(lookup.id):gsub("^audius:", "") .. "/stream"
				end

				local ok, asset, savedPath = pcall(function()
					return Remote.Engine.assetFor(lookup, function(state, payload)
						if state == "progress" and payload and payload.percent then
							Remote.Progress = payload.percent
							if type(Music.setDownloadState) == "function" then
								pcall(Music.setDownloadState, payload.percent, Remote.Label)
							end
						end
						if state == "cache" and payload and payload.path then
							Remote.FileName = tostring(payload.path):match("([^/]+)$") or Remote.FileName
						end
					end)
				end)

				Activities.Download = nil
				if type(Music.clearDownloadState) == "function" then
					pcall(Music.clearDownloadState)
				end
				refreshActivity()

				if token ~= loadToken or not gui.Parent then
					return
				end
				Music.Loading = false

				if ok and type(asset) == "string" and asset ~= "" then
					-- METADATA: luu ten/ca si/anh bia (URL) cua bai vua tai kem duong dan file de lan load sau dung metadata that.
					if type(savedPath) == "string" and savedPath ~= "" and Remote.Engine and type(Remote.Engine.writeDownloadedMeta) == "function" then
						pcall(Remote.Engine.writeDownloadedMeta, savedPath, {
							Title = track.Name, Artist = track.Artist, Duration = track.Duration,
							Thumbnail = track.Thumbnail, Source = track.Source, Url = track.Url, Id = track.Id,
						})
						track.CachedPath = savedPath
						track.FileName = tostring(savedPath):match("([^/]+)$") or track.FileName
						track.Downloaded = true
					end
					currentSound.SoundId = asset
					waitAndPlay(token, asset)
				else
					Music.Playing = false
					Music.Fails = Music.Fails + 1
					Music.Sync()
					broadcast()
					local fail = Remote.Say("error", {})
					notify(
						(Settings.Language == "en") and "Cannot download track" or "Không tải được bài",
						(fail and fail.text) or "Kiểm tra kết nối hoặc executor",
						"warn", 4, true
					)
					if Music.Auto and Music.Fails < 3 then
						task.wait(0.8)
						if token == loadToken and gui.Parent then
							Music.Next(1)
						end
					end
				end
			end)
		end

		CrossAIMusic = __xNgotCreateAIMusicEngine(Http)
		Remote.Engine = CrossAIMusic
		Remote.Folder = CrossAIMusic.Config.Folder

		pcall(function()
			if Settings then Settings.MusicAiOnline = false end
		end)

		_G.CrossAIMusic = CrossAIMusic
		_G.xNgotMusicEngine = CrossAIMusic

		pcall(function()
			local api = _G.xNgotMusicConfig
			if api and type(api.Apply) == "function" then api.Apply() end
		end)

		        local function startLoad(token, track)
		            if track.Remote then
		                fetchRemote(token, track)
		            else
		                waitAndPlay(token, currentSound.SoundId)
		            end
		        end

		        function Music.Select(index, play)
		            Music.Index = (index - 1) % #TRACKS + 1
		            local track = TRACKS[Music.Index]
		            loadToken = loadToken + 1
		            currentSound:Stop()
		            Music.Playing = play and true or false
		            Music.Loading = false
		            Music.Position = 0
		            Music.Clock = 0
		            Music.Phrase = 0
		            currentSound.SoundId = track.Remote and "" or ("rbxassetid://" .. track.Id)
		            currentSound.TimePosition = 0
		            currentSound.PlaybackSpeed = Music.Tempo
		            currentSound.Volume = Music.Volume / 100
		            Music.Sync()
		            broadcast()
		            if play then
		                startLoad(loadToken, track)
		            end
		        end

		        function Music.Toggle()
		            if Music.Playing then
		                loadToken = loadToken + 1
		                Music.Playing = false
		                Music.Loading = false
		                tween(currentSound, 0.2, { Volume = 0 })
		                task.delay(0.22, function()
		                    if not Music.Playing then
		                        currentSound:Pause()
		                    end
		                end)
		                Music.Sync()
		                broadcast()
		                return
		            end
		            if currentSound.IsLoaded and currentSound.TimePosition > 0 then
		                currentSound.Volume = 0
		                currentSound.PlaybackSpeed = Music.Tempo
		                currentSound:Resume()
		                tween(currentSound, 0.6, { Volume = Music.Volume / 100 }, Enum.EasingStyle.Sine)
		                Music.Playing = true
		                Music.Sync()
		                broadcast()
		            else
		                loadToken = loadToken + 1
		                Music.Playing = true
		                Music.Sync()
		                startLoad(loadToken, TRACKS[Music.Index])
		            end
		        end

		        function Music.Next(direction)
		            if Music.Shuffle and direction > 0 and #TRACKS > 1 then
		                local nextIndex = Music.Index
		                while nextIndex == Music.Index do
		                    nextIndex = math.random(1, #TRACKS)
		                end
		                Music.Select(nextIndex, true)
		            else
		                Music.Select(Music.Index + direction, true)
		            end
		        end

		        function Music.SetVolume(value)
		            Music.Volume = math.clamp(value, 0, 100)
		            currentSound.Volume = Music.Volume / 100
		        end

		        function Music.SetTempo(value)
		            Music.Tempo = math.clamp(value, 0.7, 1.4)
		            currentSound.PlaybackSpeed = Music.Tempo
		        end

		        function Music.Seek(alpha)
		            local length = currentSound.TimeLength
		            if length > 0 then
		                currentSound.TimePosition = math.clamp(alpha, 0, 1) * length
		                Music.Position = currentSound.TimePosition
		            end
		        end

		        function Music.Duration()
		            return math.max(0, currentSound.TimeLength)
		        end

		        currentSound.Ended:Connect(function()
		            if not Music.Playing then
		                return
		            end
		            if Music.RepeatOne then
		                Music.Select(Music.Index, true)
		            elseif Music.Auto then
		                Music.Next(1)
		            else
		                Music.Playing = false
		                Music.Position = 0
		                Music.Sync()
		                broadcast()
		            end
		        end)

		        Music.Sync()

		        Hooks.Register(function(dt)
		            if not Music.Playing then return end
		            local levels = Music.Levels
		            local loudness = Music.Playing and math.clamp(currentSound.PlaybackLoudness / 850, 0, 1) or 0
		            for index = 1, 5 do
		                local wave = 0.18 + 0.82 * math.abs(math.sin(os.clock() * (3.2 + index * 0.83) + index * 1.4))
		                local target = Music.Playing and math.clamp(loudness * wave + 0.04, 0, 1) or 0
		                levels[index] = levels[index] + (target - levels[index]) * math.clamp(dt * 10, 0, 1)
		            end
		            Music.Position = currentSound.TimePosition
		            if Music.Playing and Island.Live and Island.Live.Media then
		                for index, bar in ipairs(Media.Bars) do
		                    local level = math.clamp(levels[index] + 0.08, 0, 1)
		                    bar.Size = UDim2.fromOffset(3, 3 + 15 * level)
		                end
		            end
		        end, 2)

		        gui.Destroying:Connect(function()
		            pcall(function()
		                currentSound:Stop()
		                currentSound:Destroy()
		                group:Destroy()
		            end)
		        end)
		    end

