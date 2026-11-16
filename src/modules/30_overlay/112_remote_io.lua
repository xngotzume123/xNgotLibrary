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

		local nextPrefetch = nil
		local prefetchBusy = false
		local attemptedToken = nil

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
		            if not track then return end
		            if not track.Remote then
		                waitAndPlay(token, currentSound.SoundId)
		                return
		            end
		            local job = nextPrefetch
		            if job and job.track == track and job.pending then
		                Music.Loading = true
		                task.spawn(function()
		                    local deadline = os.clock() + (tonumber(Remote.Engine.Config.DownloadTimeout) or 200)
		                    while job.pending and token == loadToken and gui.Parent and os.clock() < deadline do task.wait(0.1) end
		                    if token ~= loadToken or not gui.Parent then return end
		                    if track.Asset then currentSound.SoundId = track.Asset; waitAndPlay(token, track.Asset)
		                    else fetchRemote(token, track) end
		                end)
		            elseif track.Asset then
		                currentSound.SoundId = track.Asset
		                waitAndPlay(token, track.Asset)
		            else
		                fetchRemote(token, track)
		            end
		        end

        -- Stable identities let the automatic queue avoid recently played variants.
        local recent = {}
        local function identity(track)
            if not track then return "" end
            local name = tostring(track.Name or ""):lower():gsub("[%p%c]", " "):gsub("%s+", " ")
            name = name:gsub("official music video", ""):gsub("official video", ""):gsub("official audio", ""):gsub("lyric video", ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
            return name ~= "" and name or (tostring(track.Source) .. "|" .. tostring(track.Id))
        end
        local function rememberTrack(track)
            local key = identity(track)
            if key == "" then return end
            for i=#recent,1,-1 do if recent[i] == key then table.remove(recent,i) end end
            recent[#recent+1] = key
            if #recent > 30 then table.remove(recent,1) end
        end
        local function pickAutomatic(allowRecent)
            local currentTrack = TRACKS[Music.Index]
            local pool, current = {}, identity(currentTrack)
            local plan = currentTrack and currentTrack.Remote and Remote.Plan or nil
            if plan and plan.query == "__downloaded__" then plan = nil end
            for i, track in ipairs(TRACKS) do
                local key = identity(track)
                local seen = false
                for _, prior in ipairs(recent) do if prior == key then seen = true; break end end
                local relevant = true
                if plan and Remote.Engine and type(Remote.Engine.isRelevant) == "function" then
                    relevant = Remote.Engine.isRelevant({name=track.Name,author=track.Artist}, plan)
                end
                if i ~= Music.Index and key ~= current and relevant and (allowRecent or not seen) then pool[#pool+1] = i end
            end
            return #pool > 0 and pool[math.random(1,#pool)] or nil
        end
        rememberTrack(TRACKS[Music.Index])
		        function Music.Select(index, play)
		            Music.Index = (index - 1) % #TRACKS + 1
		            local track = TRACKS[Music.Index]
                    if play then rememberTrack(track) end
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
                    local nextIndex = pickAutomatic(false) or pickAutomatic(true)
                    if nextIndex then Music.Select(nextIndex, true) end
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

        local function nextAutomatic()
            rememberTrack(TRACKS[Music.Index])
            local idx = pickAutomatic(false)
            if idx then Music.Select(idx, true); return end
            local current, token = TRACKS[Music.Index], loadToken
            local plan = current and current.Remote and Remote.Plan or nil
            local engine = Remote.Engine
            if not (plan and plan.query ~= "__downloaded__" and engine and type(engine.search) == "function" and type(engine.parse) == "function") then
                local fallback = pickAutomatic(true)
                if fallback then Music.Select(fallback,true) else Music.Playing=false; Music.Sync(); broadcast() end
                return
            end
            if Remote.Busy then Music.Playing=false; Music.Sync(); broadcast(); return end
            task.spawn(function()
                local request = plan.artist or (plan.tags and (plan.tags.genre or plan.tags.mood)) or plan.query
                local ok, results = pcall(function()
                    local nextPlan = engine.parse(request)
                    return engine.search(nextPlan, function() end, request)
                end)
                if not gui.Parent or token ~= loadToken or not Music.Playing or not Music.Auto or Music.RepeatOne
                    or Remote.Busy or Remote.Plan ~= plan or TRACKS[Music.Index] ~= current then return end
                local options = {}
                if ok and type(results)=="table" then
                    for _, item in ipairs(results) do
                        if engine.isRelevant and engine.isRelevant(item, engine.parse(request)) then
                            local cover = Covers[(#TRACKS % #Covers) + 1]
                            local track = {Name=item.name,Artist=item.author or "",Remote=true,Source=item.source,Id=item.id,Url=item.url,
                                Duration=item.duration,Thumbnail=item.thumbnail,DirectId=item.id,Downloaded=false,
                                A=cover[1], B=cover[2]}
                            local key=identity(track); local found=false
                            for _, prior in ipairs(recent) do if prior==key then found=true; break end end
                            for _, existing in ipairs(TRACKS) do if identity(existing)==key or (existing.Source==item.source and tostring(existing.Id)==tostring(item.id)) then found=true; break end end
                            if not found then options[#options+1]=track end
                        end
                    end
                end
                if #options > 0 then
                    local track = options[math.random(1,#options)]
                    local index = #TRACKS + 1
                    TRACKS[index] = track
                    local value = "#" .. tostring(index)
                    track.Value = value
                    Remote.Rows = Remote.Rows or {}
                    Remote.Labels = Remote.Labels or {}
                    Remote.Rows[index] = {Index=index, Value=value, Title=track.Name, Artist=track.Artist,
                        Duration=track.Duration or "", Source=track.Source or "", Thumbnail=track.Thumbnail or "",
                        Desc=track.Artist or ""}
                    Remote.Labels[value] = tostring(index) .. ". " .. tostring(track.Name)
                    Remote.Count = #TRACKS
                    if Remote.Notify then pcall(Remote.Notify) end
                    Music.Select(index, true)
                else
                    local fallback=pickAutomatic(true)
                    if fallback then Music.Select(fallback,true) else
                        Music.Playing=false; Music.Sync(); broadcast()
                        notify(Settings.Language == "en" and "Music" or "Nhạc", Settings.Language == "en" and "No new related track found." or "Không tìm thấy bài liên quan mới.", "warn", 3, true)
                    end
                end
            end)
        end
		        currentSound.Ended:Connect(function()
		            if not Music.Playing then
		                return
		            end
		            if Music.RepeatOne then
		                Music.Select(Music.Index, true)
		            elseif Music.Auto then
		                local job = nextPrefetch
		                if Remote.Engine.Config.PrefetchNext ~= false and job and job.token == loadToken and job.current == TRACKS[Music.Index]
		                    and job.shuffle == Music.Shuffle and TRACKS[job.index] == job.track then
		                    Music.Select(job.index, true)
		                else
                    nextAutomatic()
		                end
		            else
		                Music.Playing = false
		                Music.Position = 0
		                Music.Sync()
		                broadcast()
		            end
		        end)

		        Music.Sync()

		        task.spawn(function()
		            while gui.Parent do
		                task.wait(0.5)
		            if Music.Playing and Music.Auto and not Music.RepeatOne and not Music.Loading and #TRACKS > 1
		                and Remote.Engine.Config.PrefetchNext ~= false and currentSound.TimeLength > 0
		                and currentSound.TimePosition >= currentSound.TimeLength * 0.5
		                and attemptedToken ~= loadToken and not prefetchBusy then
                    local nextIndex = pickAutomatic(false)
                    if not nextIndex then attemptedToken = loadToken; continue end
		                local candidate = TRACKS[nextIndex]
		                local job = { token = loadToken, current = TRACKS[Music.Index], index = nextIndex,
		                    track = candidate, shuffle = Music.Shuffle, pending = true }
		                nextPrefetch, attemptedToken, prefetchBusy = job, loadToken, true
		                notify(Settings.Language == "en" and "Up next" or "Bài tiếp theo",
		                    tostring(candidate.Name or "Track") .. (Settings.Language == "en" and " · preparing" or " · đang chuẩn bị"), "info", 3, true)
		                task.spawn(function()
		                    local ok, asset, path = pcall(function()
		                        if candidate.Asset then return candidate.Asset, candidate.CachedPath end
		                        if not candidate.Remote then return "rbxassetid://" .. tostring(candidate.Id) end
		                        if candidate.CachedPath then
		                            local getter = getcustomasset or getsynasset
		                            if type(getter) == "function" and (type(isfile) ~= "function" or isfile(candidate.CachedPath)) then
		                                local got, cached = pcall(getter, candidate.CachedPath)
		                                if got and type(cached) == "string" and cached ~= "" then return cached, candidate.CachedPath end
		                            end
		                        end
		                        if not Remote.Supported() then return nil end
		                        local lookup = { id = candidate.Id, url = candidate.Url, source = candidate.Source or "youtube", name = candidate.Name }
		                        if lookup.source == "audius" and lookup.id then
		                            lookup.directUrl = "https://api.audius.co/v1/tracks/" .. tostring(lookup.id):gsub("^audius:", "") .. "/stream"
		                        end
		                        return Remote.Engine.assetFor(lookup, function() end)
		                    end)
		                    if ok and type(asset) == "string" and asset ~= "" then
		                        if candidate.Remote then candidate.Asset = asset end
		                        if type(path) == "string" and path ~= "" then
		                            candidate.CachedPath, candidate.Downloaded = path, true
		                            candidate.FileName = path:match("([^/]+)$") or candidate.FileName
		                            if Remote.Engine.writeDownloadedMeta then
		                                pcall(Remote.Engine.writeDownloadedMeta, path, { Title = candidate.Name, Artist = candidate.Artist,
		                                    Duration = candidate.Duration, Thumbnail = candidate.Thumbnail, Source = candidate.Source, Url = candidate.Url, Id = candidate.Id })
		                            end
		                        end
		                        local sound
		                        pcall(function()
		                            sound = Instance.new("Sound")
		                            sound.SoundId = asset
		                            sound.Parent = SoundService
		                            game:GetService("ContentProvider"):PreloadAsync({sound})
		                        end)
		                        if sound then pcall(function() sound:Destroy() end) end
		                    end
		                    job.pending, prefetchBusy = false, false
		                end)
		            end
		            end
		        end)

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

