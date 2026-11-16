--[[ xngot-studio · src/modules/30_overlay/104_engine_resolve.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.resolve
     role   : resolve(), rowLabel/rowValue/rowData, say(), enrich()
     source : main 2.txt L7915-8177 · 263 dòng · delta +0
--]]
		function CrossAIMusic.resolve(prompt, onState)
			onState = onState or function() end
			local plan = CrossAIMusic.parse(prompt)
			onState("parse", { plan = plan })

			local results = CrossAIMusic.search(plan, function(state, payload)
				if state == "ai_wait" then
				local secs = tonumber(payload.waitFor) or 45
				return { text = t(string.format("AI trực tuyến đang chờ hạn mức miễn phí (%d giây) — mình dùng AI offline trước nhé.", secs),
					string.format("Online AI cooling down (%ds) — using offline AI.", secs)), mood = "think" }
			end

			if state == "error" then onState("error", { stage = "search", payload = payload }) end
			end, prompt)
			if #results == 0 then return nil end

			local limit = math.min(#results, math.max(1, CFG.RaceTracks or 1))
			local finished, won = 0, false
			local bestAsset, bestTrack, bestPath

			for rank = 1, limit do
				local track = results[rank]
				task.spawn(function()
					if won then
						finished = finished + 1
						return
					end
					onState("trying", { track = track, rank = rank })
					local ok, asset, path = pcall(CrossAIMusic.assetFor, track, function(state, payload)
						if not won then
							onState("download", { state = state, track = track, rank = rank, payload = payload })
						end
					end)
					finished = finished + 1
					if ok and type(asset) == "string" and asset ~= "" and not won then
						won = true
						bestAsset, bestTrack, bestPath = asset, track, path
					end
				end)
			end

			local waited = 0
			while not won and finished < limit and waited < CFG.DownloadTimeout do
				task.wait(0.1)
				waited = waited + 0.1
			end

			if won then
				bestTrack.asset = bestAsset
				bestTrack.path = bestPath
				onState("ready", { track = bestTrack })
				return bestAsset, bestTrack
			end

			onState("error", { stage = "download", payload = { reason = "tất cả kết quả đều thất bại" } })
			return nil
		end

		function CrossAIMusic.rowLabel(track, index)
			index = tonumber(index) or 1
			local title = trim(track.name or track.Name or "Unknown")
			local who = trim(track.author or track.Artist or "")
			if #title > 52 then title = trim(title:sub(1, 52)) .. "…" end
			if who ~= "" then
				if #who > 26 then who = trim(who:sub(1, 26)) .. "…" end
				return string.format("%02d. %s — %s", index, title, who)
			end
			return string.format("%02d. %s", index, title)
		end

		function CrossAIMusic.rowValue(track, index)
			index = tonumber(index) or 1
			local src = trim(track.source or track.Source or "yt")
			local id = trim(track.id or track.Id or track.url or track.Url or "")
			if id == "" then id = tostring(index) end

			return string.format("#%02d %s:%s", index, src, id)
		end

		function CrossAIMusic.rowData(track, index)
			track = track or {}
			index = tonumber(index) or 1
			local secs = CrossAIMusic.durationSeconds(track.duration or track.Duration or "")
			local durText = ""
			if secs > 0 then
				durText = string.format("%d:%02d", math.floor(secs / 60), secs % 60)
			elseif track.duration and tostring(track.duration) ~= "" then
				durText = tostring(track.duration)
			end

			local artist = trim(track.author or track.Artist or "")
			local src = tostring(track.source or track.Source or ""):upper()
			if src == "YOUTUBE" then src = "YT" end

			return {
				Index = index,
				Title = trim(track.name or track.Name or "Unknown"),
				Artist = artist,
				Duration = durText,
				Thumbnail = tostring(track.thumbnail or track.Thumbnail or ""),
				Source = src,
				Value = CrossAIMusic.rowValue(track, index),
			}
		end

		function CrossAIMusic.say(state, payload, vi)
			payload = payload or {}
			vi = vi ~= false
			local function t(viText, enText) return vi and viText or enText end

			if state == "thinking" then
				local q = trim(payload.query or "")
				if q ~= "" then
					return { text = t("Đang tìm cho bạn: " .. q .. " …", "Searching for: " .. q .. " …"), mood = "think" }
				end
				return { text = t("Đang nghe yêu cầu của bạn…", "Reading your request…"), mood = "think" }
			end

			if state == "searching" then
				return { text = t("Đang lùng nhạc trên nhiều nguồn…", "Searching across sources…"), mood = "think" }
			end

			if state == "found" then
				local n = tonumber(payload.count) or 0
				return { text = t(string.format("Tìm được %d bài. Bạn chọn bài nào?", n),
					string.format("Found %d tracks. Which one?", n)), mood = "happy" }
			end

			if state == "none" then
				local q = trim(payload.query or "")
				if q ~= "" then
					return { text = t("Không thấy bài nào khớp \"" .. q .. "\". Bạn thử mô tả khác xem, ví dụ: \"lofi buổi tối\" hay \"nhạc buồn piano\".",
						"No match for \"" .. q .. "\". Try a different description."), mood = "sad" }
				end
				return { text = t("Không thấy bài nào phù hợp. Bạn mô tả rõ hơn giúp mình nhé.",
					"No matching track. Could you describe it more?"), mood = "sad" }
			end

			if state == "error" then
				return { text = t("Mạng hoặc nguồn nhạc đang lỗi, mình thử lại sau nhé.", "Network or source error, try again later."), mood = "sad" }
			end

			if state == "trying" then
				local rank = tonumber(payload.rank) or 1
				local name = trim((payload.track and payload.track.name) or "")
				if name ~= "" then
					return { text = t(string.format("Thử tải bài %d: %s (%d%%)", rank, name, tonumber(payload.percent) or 0),
						string.format("Downloading #%d: %s", rank, name)), mood = "think" }
				end
				return { text = t(string.format("Đang thử bài số %d…", rank), string.format("Trying track #%d…", rank)), mood = "think" }
			end

			if state == "progress" then
				local pct = math.floor((tonumber(payload.percent) or 0) * 100 + 0.5)
				return { text = t(string.format("Đang tải… %d%%", pct), string.format("Downloading… %d%%", pct)), mood = "think" }
			end

			if state == "retry" then
				return { text = t("Bài đó lỗi, mình thử lại bài gần giống nhé…", "That one failed, trying another…"), mood = "think" }
			end

			if state == "ready" then
				local name = trim(payload.name or "")
				local who = trim(payload.author or "")
				if who ~= "" then
					return { text = t("Đang phát: " .. name .. " — " .. who, "Now playing: " .. name .. " — " .. who), mood = "happy" }
				end
				return { text = t("Đang phát: " .. name, "Now playing: " .. name), mood = "happy" }
			end

			return nil
		end

		function CrossAIMusic.enrich(track)
			if type(track) ~= "table" then return track end

			if not track.CoverAsset and track.thumbnail and track.thumbnail ~= "" then
				pcall(function() CrossAIMusic.coverAsset(track) end)
			end

			if (not track.name or track.name == "" or track.name == "Unknown") or (not track.author or track.author == "") then
				local key = tostring(track.source or track.Source or "youtube") .. ":" .. tostring(track.id or track.Id or track.url or track.Url or "track")
				local title = track.name or track.Name
				local data = readExisting(CrossAIMusic.cacheCandidates(key, title))
				if data then
					local id3 = readID3(data)
					if id3 then
						if (not track.name or track.name == "" or track.name == "Unknown") and id3.title then
							track.name = id3.title
						end
						if (not track.author or track.author == "") and id3.artist then
							track.author = id3.artist
						end
						if id3.album and (not track.album or track.album == "") then track.album = id3.album end
					end
				end
			end

			local bits = {}
			if track.author and track.author ~= "" then bits[#bits + 1] = track.author end
			if track.album and track.album ~= "" and track.album ~= track.author then bits[#bits + 1] = track.album end
			local secs = CrossAIMusic.durationSeconds(track.duration or "")
			if secs <= 0 and track.durationSec then secs = track.durationSec end
			if secs > 0 then
				bits[#bits + 1] = string.format("%d:%02d", math.floor(secs / 60), secs % 60)
			end
			track.desc = table.concat(bits, " · ")

			local srcLabel = tostring(track.source or ""):upper()
			if srcLabel == "YOUTUBE" then srcLabel = "YT" end
			track.sourceLabel = srcLabel
			return track
		end

		return CrossAIMusic
		end

		local Remote = {
			Folder = "xNgotLibrary/Music",
			State = "idle",
			Count = 0,
			Busy = false,
			Listeners = {},
			Query = "",
			Plan = nil,
			Progress = 0,
			Error = nil,
			Rows = {},
			Labels = {},
		}
		Music.Remote = Remote

		local Http
		pcall(function()
			Http = game:GetService("HttpService")
		end)

		local Covers = {
			{ rgb(255, 55, 95), rgb(255, 159, 10) },
			{ rgb(10, 132, 255), rgb(191, 90, 242) },
			{ rgb(48, 209, 88), rgb(64, 200, 224) },
			{ rgb(191, 90, 242), rgb(255, 55, 95) },
			{ rgb(255, 159, 10), rgb(255, 214, 10) },
			{ rgb(64, 200, 224), rgb(88, 86, 214) },
		}

		Remote.Supported = function()
			return type(writefile) == "function"
				and (type(getcustomasset) == "function" or type(getsynasset) == "function")
		end

		Remote.Notify = function()
			for _, listener in ipairs(Remote.Listeners) do
				pcall(listener)
			end
		end

		local function applyResults(results, plan)
			while #TRACKS > 0 do
				table.remove(TRACKS, #TRACKS)
			end

			local Engine = Remote.Engine or CrossAIMusic
