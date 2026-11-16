--[[ xngot-studio · src/modules/30_overlay/084_engine_score.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.score
     role   : score() xếp hạng track + learn() học từ lựa chọn
     source : main 2.txt L6917-7029 · 113 dòng · delta +0
--]]
		function CrossAIMusic.score(track, plan)
			track = track or {}
			plan = plan or { tags = {}, weight = {} }
			plan.tags = plan.tags or {}
			plan.weight = plan.weight or {}
			local score = 0
			local text = norm(tostring(track.name or track.title or "") .. " " .. tostring(track.author or track.artist or "") .. " " .. tostring(track.text or ""))

			for tag, canon in pairs(plan.tags) do
				if canon and canon ~= "" and text:find(norm(canon), 1, true) then
					score = score + 3 * (plan.weight[tag] or 1)
				end
			end

			if plan.explicitTitle and plan.explicitTitle ~= "" then
				local hit, total = 0, 0
				for w in plan.explicitTitle:gmatch("%S+") do
					total = total + 1
					if text:find(w, 1, true) then hit = hit + 1 end
				end
				if total > 0 then score = score + (hit / total) * 8 end
			end

			local wantsLong = plan.tags.ctx == "long"
			local penalty = 0
			if text:find("1 hour", 1, true) or text:find("10 hours", 1, true)
				or text:find("1hour", 1, true) or text:find("hours", 1, true) then
				penalty = 6
			elseif text:find(" mix", 1, true) or text:find("playlist", 1, true)
				or text:find("compilation", 1, true) or text:find("medley", 1, true) then
				penalty = 4
			end
			if not wantsLong then score = score - penalty end

			local secs = CrossAIMusic.durationSeconds(track.duration)
			if secs > 0 and not wantsLong then
				if secs > 2700 then score = score - 16
				elseif secs > 1200 then score = score - 11
				elseif secs > 600 then score = score - 6
				elseif secs > 480 then score = score - 2
				elseif secs >= 90 and secs <= 480 then score = score + 2
				elseif secs < 45 then score = score - 2 end
			end

			if plan.artist and plan.artist ~= "" then
				local artistText = text
				local artistWords = norm(plan.artist)
				local hitArtist = 0
				local totalArtist = 0
				for w in artistWords:gmatch("%S+") do
					totalArtist = totalArtist + 1
					if #w > 2 and artistText:find(w, 1, true) then hitArtist = hitArtist + 1 end
				end
				if totalArtist > 0 then
					local ratio = hitArtist / totalArtist
					score = score + ratio * 12
					if ratio == 0 then score = score - 6 end
				end
			end

			if plan.tags.genre and plan.tags.genre ~= "" then
				local wanted = norm(plan.tags.genre)
				local got = text
				if wanted ~= "" and got:find(wanted, 1, true) then
					score = score + 5
				elseif (plan.tags.genre == "lofi" or plan.tags.genre == "ambient") and got:find("remix", 1, true) then
					score = score - 5
				end
			end

			if plan.tags.ctx == "gaming" then
				local got = text
				if got:find("gaming", 1, true) or got:find("epic", 1, true) or got:find("battle", 1, true) then
					score = score + 3
				end
			end

			if CrossAIMusic._banned then
				for _, word in ipairs(CrossAIMusic._banned) do
					if norm(track.text or ""):find(word, 1, true) then
						score = score - 25
						break
					end
				end
			end

			score = score + (SOURCE_BIAS[track.source] or 0.7)
			if track.directUrl then score = score + 0.5 end
			if track.thumbnail ~= "" then score = score + 0.2 end
			return score
		end

        -- A source ranking bias alone must never make an unrelated result eligible.
        function CrossAIMusic.isRelevant(track, plan)
            if type(track) ~= "table" or type(plan) ~= "table" then return false end
            local title = norm(track.name or track.title or "")
            local text = norm((track.name or track.title or "") .. " " .. (track.author or track.artist or ""))
            if title == "" or title == "unknown" then return false end
            local function ratio(phrase, haystack)
                local hit, total = 0, 0
                local hay = {}; for w in haystack:gmatch("%w+") do hay[w] = true end
                for w in norm(phrase):gmatch("%w+") do
                    if #w > 1 then total += 1; if hay[w] then hit += 1 end end
                end
                return total > 0 and hit / total or 0
            end
            if plan.explicitTitle and plan.explicitTitle ~= "" then
                if ratio(plan.explicitTitle, text) < 0.67 then return false end
            elseif plan.artist and plan.artist ~= "" then
                if ratio(plan.artist, text) < 0.67 then return false end
            else
                local tags = plan.tags or {}
                local term = tags.genre or tags.mood
                if term and ratio(term, text) < 0.5 then return false end
                if not term and ratio(plan.query or "", text) < 0.5 then return false end
            end
            if plan.artist and plan.artist ~= "" and ratio(plan.artist, text) < 0.5 then return false end
            return true
        end

		function CrossAIMusic.learn(title, good)
			CrossAIMusic._banned = CrossAIMusic._banned or {}
			if type(title) ~= "string" or title == "" then return end
			local words = {}
			for w in norm(title):gmatch("%S+") do
				if #w > 3 then words[#words + 1] = w end
			end
			if good == false then
				for index = 1, math.min(#words, 3) do
					local word = words[index]
					local exists = false
					for _, item in ipairs(CrossAIMusic._banned) do
						if item == word then exists = true end
					end
					if not exists then CrossAIMusic._banned[#CrossAIMusic._banned + 1] = word end
				end
				if #CrossAIMusic._banned > 40 then table.remove(CrossAIMusic._banned, 1) end
			end
			return CrossAIMusic._banned
		end

