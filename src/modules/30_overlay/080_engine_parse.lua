--[[ xngot-studio · src/modules/30_overlay/080_engine_parse.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.parse
     role   : parse()/durationSeconds()/normalizeRow()
     source : main 2.txt L6769-6916 · 148 dòng · delta +0
--]]
		function CrossAIMusic.parse(prompt)
			local raw = trim(prompt)
			raw = raw:gsub("^%s*", ""):gsub("%s*$", "")
			local plan = {
				raw = raw, query = raw, tags = {}, weight = {},
				sources = { "youtube" }, limit = CFG.TopN,
			}
			if raw == "" then return plan end

			local n = norm(raw)
			local consumed, matched = {}, {}

			local phrases = {}
			for k, v in pairs(LEXICON) do
				phrases[#phrases + 1] = { key = k, data = v, size = #k:gsub("[^ ]", "") }
			end
			table.sort(phrases, function(a, b) return a.size > b.size end)

			for _, item in ipairs(phrases) do
				local key = item.key
				local init = 1
				while true do
					local s, e = n:find(key, init, true)
					if not s then break end
					local okLeft = (s == 1) or (n:sub(s - 1, s - 1) == " ")
					local okRight = (e == #n) or (n:sub(e + 1, e + 1) == " ")
					if okLeft and okRight then
						for i = s, e do consumed[i] = true end
						local tag, canon = item.data.tag, item.data.canon
						if not plan.tags[tag] then plan.tags[tag] = canon end
						plan.weight[tag] = (plan.weight[tag] or 0) + 1
						matched[canon] = true
					end
					init = e + 1
				end
			end

			plan.sources = CFG.Sources or { "youtube", "soundcloud", "audius" }

			if plan.tags.artist then
				local artistWords = plan.tags.artist:gsub("%-", " ")
				plan.artist = artistWords
			end
			if plan.tags.ctx == "gaming" then plan.limit = math.max(plan.limit or 12, 14) end

			if matched["short"] then plan.limit = 6 end
			if matched["long"] then plan.limit = 20 end

			local buf, i = {}, 1
			while i <= #n do
				if not consumed[i] then
					buf[#buf + 1] = n:sub(i, i)
					while i < #n and not consumed[i + 1] and n:sub(i + 1, i + 1) ~= " " do
						i = i + 1
						buf[#buf + 1] = n:sub(i, i)
					end
				end
				i = i + 1
			end
			local rest = trim(table.concat(buf):gsub("%s+", " "))

			local parts = {}
			for _, w in ipairs(words(rest)) do
				if not STOP[w] and LEXICON[w] == nil then parts[#parts + 1] = w end
			end

			local final = {}
			local kept = #parts > 0 and table.concat(parts, " ") or ""
			if kept ~= "" then final[#final + 1] = kept end
			if plan.tags.artist and plan.tags.artist ~= "" then
				local artistText = plan.tags.artist:gsub("%-", " ")
				if kept == "" or not kept:lower():find(artistText:lower(), 1, true) then
					final[#final + 1] = artistText
				end
			end
			if plan.tags.genre and plan.tags.genre ~= "" then final[#final + 1] = plan.tags.genre end
			if plan.tags.mood and plan.tags.mood ~= "" and plan.tags.mood ~= plan.tags.genre then
				local moodText = plan.tags.mood
				local already = false
				for _, piece in ipairs(final) do
					if piece:lower():find(moodText:lower(), 1, true) then already = true end
				end
				if not already then final[#final + 1] = moodText end
			end
			if plan.tags.ctx == "gaming" then final[#final + 1] = "gaming music" end
			if plan.tags.ctx == "code" then final[#final + 1] = "coding focus" end
			if final[1] == nil then
				local fb = {}
				for _, w in ipairs(words(n)) do
					if not STOP[w] then fb[#fb + 1] = w end
				end
				final[1] = #fb > 0 and table.concat(fb, " ") or n
			end

			plan.vietnam = matched["vietnam"] == true or matched["bolero"] == true
			plan.query = table.concat(final, " ")
			plan.explicitTitle = #parts > 0 and table.concat(parts, " ") or nil
			return plan
		end

		local SOURCE_BIAS = { youtube = 1.0, soundcloud = 0.92, audius = 0.9, tiktok = 0.85, audiomack = 0.8, mixcloud = 0.8 }

		function CrossAIMusic.durationSeconds(text)
			text = tostring(text or "")
			local h, m, s = text:match("^(%d+):(%d%d):(%d%d)$")
			if h then return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s) end
			local mm, ss = text:match("^(%d+):(%d%d)$")
			if mm then return tonumber(mm) * 60 + tonumber(ss) end
			return 0
		end

		function CrossAIMusic.normalizeRow(row, sourceId)
			if type(row) ~= "table" then return nil end
			local id = tostring(row.id or row.fileId or row.videoId or "")
			if id == "" then return nil end

			local thumb = row.thumbnail or row.cover or row.Thumbnail or row.image or ""
			if type(thumb) == "table" then
				thumb = thumb.url or (thumb.url_list and thumb.url_list[1]) or ""
			end

			local author = row.author or row.artist or row.uploader or row.channel or ""
			if type(author) == "table" then
				author = author.nickname or author.name or author.unique_id or ""
			end

			local url = row.url or row.share_url or row.permalink or ""
			local direct = row.directUrl or row.direct_url or row.audioUrl or row.audio_url or nil

			if sourceId == "audius" then
				local clean = id:gsub("^audius:", "")
				direct = direct or ("https://api.audius.co/v1/tracks/" .. urlEncode(clean) .. "/stream")
			end

			local dur = row.duration or row.durationText or "0:00"
			if type(dur) == "number" then
				dur = string.format("%d:%02d", math.floor(dur / 60), dur % 60)
			end

			return {
				id = id, source = sourceId,
				name = trim(tostring(row.name or row.title or row.track or "Unknown")),
				author = trim(tostring(author)),
				thumbnail = tostring(thumb), duration = tostring(dur),
				url = tostring(url), directUrl = direct, kind = row.kind or "track",
			}
		end

