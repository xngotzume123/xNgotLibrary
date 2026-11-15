--[[ xngot-studio · src/modules/30_overlay/108_remote.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.remote
     role   : Remote: dựng catalog từ engine, bảng hàng, refresh
     source : main 2.txt L8178-8420 · 243 dòng · delta -1
--]]
			Remote.Rows = {}
			Remote.Labels = {}

			for index, item in ipairs(results) do
				local cover = Covers[(index - 1) % #Covers + 1]

				if Engine and type(Engine.enrich) == "function" then
					pcall(function() Engine.enrich(item) end)
				end

				local row = Engine and type(Engine.rowData) == "function"
					and Engine.rowData(item, index)
					or { Index = index, Title = tostring(item.name or "Unknown"), Artist = tostring(item.author or ""),
						Duration = tostring(item.duration or ""), Thumbnail = tostring(item.thumbnail or ""),
						Source = tostring(item.source or ""), Value = "#" .. index }

				local desc = row.Artist
				if row.Duration ~= "" then
					desc = (desc ~= "" and (desc .. " · " .. row.Duration) or row.Duration)
				end
				if row.Source ~= "" then
					desc = desc ~= "" and (desc .. " · " .. row.Source) or row.Source
				end

				Remote.Rows[index] = {
					Index = index,
					Value = row.Value,
					Title = row.Title,
					Artist = row.Artist,
					Duration = row.Duration,
					Source = row.Source,
					Thumbnail = row.Thumbnail,
					CoverAsset = item.coverAsset or item.CoverAsset,
					Desc = desc,
				}
				Remote.Labels[row.Value] = Engine and type(Engine.rowLabel) == "function"
					and Engine.rowLabel(item, index)
					or (tostring(index) .. ". " .. row.Title)

				TRACKS[#TRACKS + 1] = {
					Name = item.name,
					Artist = item.author or "",
					Mood = desc,
					Remote = true,
					Source = item.source,
					Duration = item.duration,
					Thumbnail = item.thumbnail,
					thumbnail = item.thumbnail,
					CoverAsset = item.coverAsset or item.CoverAsset,
					Url = item.url,
					Id = item.id,
					Asset = item.asset,
					DirectId = item.id,
					CachedPath = item.path,
					FileName = item.fileName,
					Downloaded = item.downloaded == true,
					Desc = desc,
					Value = row.Value,
					Row = Remote.Rows[index],
					A = cover[1],
					B = cover[2],
				}
			end

			if Music.Playing then
				Music.Playing = false
				Music.Loading = false
				pcall(function() currentSound:Stop() end)
				Music.Position = 0
				Music.Clock = 0
			end
			if #TRACKS > 0 then
				if Music.Index < 1 then Music.Index = 1 end
				if Music.Index > #TRACKS then Music.Index = #TRACKS end
			end
			pcall(function() Music.Sync() end)

			Remote.Count = #results
			Remote.Plan = plan
			Remote.State = #results > 0 and "ready" or "empty"

			local coverOn = true
			pcall(function()
				local cfgApi = _G.xNgotMusicConfig
				if cfgApi and type(cfgApi.Get) == "function" then coverOn = cfgApi:Get("coverArt") ~= false end
			end)
			if coverOn and Engine and type(Engine.prefetchCovers) == "function" then
				pcall(function()
					Engine.prefetchCovers(results, function(item, asset)
						for i, track in ipairs(TRACKS) do
							if track.Remote and item and track.Url == item.url and track.Id == item.id then
								track.CoverAsset = asset
								if Remote.Rows[i] then Remote.Rows[i].CoverAsset = asset end
								break
							end
						end
						Remote.Notify()
					end)
				end)
			end
		end

		Remote.Say = function(state, payload)
			local vi = Settings.Language ~= "en"
			local fn = Remote.Engine and Remote.Engine.say or (CrossAIMusic and CrossAIMusic.say)
			if type(fn) == "function" then
				local ok, res = pcall(fn, state, payload, vi)
				if ok and type(res) == "table" then return res end
			end
			return nil
		end

		Music.Covers = Covers

		Music.AddTrack = function(track)
			if type(track) ~= "table" then return nil end
			TRACKS[#TRACKS + 1] = track
			return #TRACKS
		end

		Music.PlayAsset = function(track)
			if type(track) ~= "table" then return nil end
			local index = Music.AddTrack(track)
			if not index then return nil end

			loadToken = loadToken + 1
			Music.Index = index
			currentSound:Stop()
			currentSound.SoundId = track.Asset or ""
			currentSound.TimePosition = 0
			currentSound.PlaybackSpeed = Music.Tempo
			currentSound.Volume = Music.Volume / 100
			Music.Position = 0
			Music.Clock = 0
			Music.Phrase = 0
			Music.Loading = false
			Music.Playing = true
			Music.Sync()
			broadcast()
			if track.Asset then
				waitAndPlay(loadToken, track.Asset)
			end
			return index
		end

		Remote.Load = function()
		if Remote.Busy then
			 
			notify("Music search", "A search is already running - please wait...", "warn", 2.5, true)
			return
			end
			local Engine = Remote.Engine
			if not Engine then
				notify("Music", (Settings.Language == "en") and "Music AI is not ready yet"
					or "AI tìm nhạc chưa sẵn sàng", "warn", 3, true)
				return
			end

			Remote.Busy = true
			Remote.State = "searching"
			Remote.Notify()
			 
			if Remote.Query and Remote.Query ~= "" then
				notify("Music search", string.format("Searching for \"%s\"...", tostring(Remote.Query)), "info", 3, true)
			end

			task.spawn(function()
				local prompt = Remote.Query
				if not prompt or prompt == "" then
					 
					 
					local loaded = 0
					local okLoaded, result = pcall(function() return Remote.LoadDownloaded() end)
					if okLoaded then loaded = tonumber(result) or 0 end
					Remote.Busy = false
					if loaded <= 0 then
						Remote.State = "localempty"
						Remote.Notify()
					end
					return
				end

				local plan = Engine.parse(prompt)

				local results = Engine.search(plan, function(state, payload)
					if state == "searching" then
						Remote.State = "searching"
						Remote.Notify()
					elseif state == "ai" then
						Remote.State = "searching"
						Remote.Notify()
					elseif state == "error" then
						Remote.State = "failed"
						Remote.Error = tostring(payload and payload.reason or "unknown")
						Remote.Notify()
					end
				end, prompt)

				Remote.Busy = false
				if not gui.Parent then
					return
				end

				if #results == 0 then
					if Remote.State ~= "failed" then Remote.State = "empty" end
					Remote.Notify()
					local msg = Remote.Say("none", { query = plan.query })
					notify(
						(Settings.Language == "en") and "Music search" or "Tìm nhạc",
						(msg and msg.text) or ("Không có kết quả cho: " .. tostring(plan.query)),
						"warn", 4, true
					)
					return
				end

				applyResults(results, plan)
				Remote.CatalogSource = "search"
				Remote.Notify()

				local found = Remote.Say("found", { count = #results, query = plan.query })
				notify(
					(Settings.Language == "en") and "Music found" or "Đã tìm thấy nhạc",
					string.format(
						(Settings.Language == "en") and "%d tracks · \"%s\"" or "%d bài · \"%s\"",
						#results, tostring(plan.query)
					) .. ((found and found.text) and (" — " .. found.text) or ""),
					"success", 3, true
				)
			end)
		end

		Remote.Search = function(prompt)
			Remote.Query = tostring(prompt or "")
			Remote.State = "idle"
			Remote.Error = nil
			Remote.Load()
		end

		 
		Remote.DownloadedFiles = {}
		Remote.DownloadedStats = nil
		Remote.CatalogSource = nil

