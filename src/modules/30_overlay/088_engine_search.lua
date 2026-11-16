--[[ xngot-studio · src/modules/30_overlay/088_engine_search.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.search
     role   : queryVariants/searchOne/search (đa nguồn)
     source : main 2.txt L7030-7194 · 165 dòng · delta +0
--]]
		local detectedRegion = ""
		pcall(function()
			local loc = game:GetService("LocalizationService")
			local locale = ""
			pcall(function() locale = tostring(loc.RobloxLocaleId or "") end)
			local suffix = locale:match("[-_]([%a][%a])$")
			if suffix then detectedRegion = suffix:upper()
			elseif locale:lower():match("^vi") then detectedRegion = "VN" end
			task.spawn(function()
				local ok, code = pcall(function() return loc:GetCountryRegionForPlayerAsync(game:GetService("Players").LocalPlayer) end)
				if ok and type(code) == "string" and code:match("^%a%a$") then detectedRegion = code:upper() end
			end)
		end)
		local regionTerms = { VN = "nhac viet nam", US = "american music", KR = "kpop korean music", JP = "japanese music" }
		function CrossAIMusic.searchRegion()
			local region = tostring(CFG.Region or "auto"):upper()
			if region == "AUTO" then region = detectedRegion end
			if region == "GLOBAL" then return "" end
			return regionTerms[region] and region or ""
		end

		function CrossAIMusic.queryVariants(plan, prompt)
			local raw = tostring((prompt or plan.raw or "")):gsub("^%s+", ""):gsub("%s+$", "")
			local main = tostring(plan.query or "")
			local out, seen = {}, {}

			local function add(q)
				q = trim(tostring(q or ""):gsub("%s+", " "))
				if q == "" or seen[q:lower()] then return end
				if #q > 90 then q = trim(q:sub(1, 90)) end
				seen[q:lower()] = true
				out[#out + 1] = q
			end

			add(main)

			if plan.vietnam or (plan.tags and plan.tags.ctx == "vietnam") then
				add(main .. " viet nam")
			end

			local flat = trim(norm(main))
			if flat ~= "" and flat ~= main:lower() then add(flat) end

			if raw ~= "" and raw ~= main then add(raw) end

			local title = plan.explicitTitle
			if title and title ~= "" and title ~= main then add(title) end
			if title and title ~= "" and plan.tags and plan.tags.genre then add(title .. " " .. plan.tags.genre) end
			if title and title ~= "" then
				local plain = trim(norm(title))
				if plain ~= "" and plain ~= title:lower() then add(plain) end
			end

			if plan.artist and plan.artist ~= "" then
				add(plan.artist .. " " .. (title or plan.tags.genre or ""))
				if title and title ~= "" then add(title .. " " .. plan.artist) end
			end

			if plan.vietnam or (plan.tags and plan.tags.ctx == "vietnam") then
				add(main .. " viet nam")
			end

			plan.weak = plan.weak ~= false

			local region = CrossAIMusic.searchRegion()
			local term = regionTerms[region]
            if term and #out == 1 then add(main .. " " .. term) end
			local trimmed, unique = {}, {}
			for i = 1, math.min(#out, 3) do
				local q = (term and i > 1 and not out[i]:lower():find(term:lower(), 1, true)) and trim(out[i] .. " " .. term) or out[i]
				if not unique[q:lower()] then trimmed[#trimmed + 1] = q; unique[q:lower()] = true end
			end
			plan.region = region
			return trimmed
		end

		local function searchOne(sourceId, query, page)
			local url = CFG.ApiBase .. "/search/" .. sourceId .. "/" .. urlEncode(query)
			if page and page > 1 then url = url .. "?page=" .. tostring(page) end

			local body = httpGet(url)
			if not body then
				local res = CrossAIMusic.request(url, "GET", { ["accept"] = "application/json" }, nil, CFG.SearchTimeout)
				body = res and res.Body
			end
			if not body or type(body) ~= "string" then return nil, "network" end

			local low = body:lower()
			if low:find("too many requests", 1, true) then return nil, "rate" end
			if low:find("no results", 1, true) or low:find("not found", 1, true) then return nil, "empty" end

			local data = jsonDecode(body)
			if type(data) ~= "table" then return nil, "decode" end
			local rows = data.results or data
			if type(rows) ~= "table" then return nil, "shape" end

			local out = {}
			for _, r in ipairs(rows) do
				local t = CrossAIMusic.normalizeRow(r, sourceId)
				if t then out[#out + 1] = t end
			end
			if #out == 0 then return nil, "empty" end
			return out
		end

		function CrossAIMusic.search(plan, callback, prompt)
			callback = callback or function() end
			if type(plan) == "string" then plan = CrossAIMusic.parse(plan) end

			local variants = CrossAIMusic.queryVariants(plan, prompt)
			if #variants == 0 then variants = { plan.query } end
			callback("searching", { query = variants[1], sources = plan.sources, variants = variants })

			local collected, errors, seenIds = {}, {}, {}
			local jobs = 0
			local function push(list)
				if type(list) ~= "table" then return end
				for _, t in ipairs(list) do
					local key = tostring(t.source) .. "|" .. tostring(t.id)
					if not seenIds[key] then
						seenIds[key] = true
						collected[#collected + 1] = t
					end
				end
			end

			local sources = plan.sources or { "youtube" }
			if #sources == 0 then
				callback("error", { reason = "no source" })
				return {}
			end

			for _, q in ipairs(variants) do
				for _, src in ipairs(sources) do
					jobs = jobs + 1
					task.spawn(function()
						local ok, list, err = pcall(searchOne, src, q, 1)
						if ok and list then
							push(list)
						else
							errors[#errors + 1] = src .. ":" .. tostring(err or "error")
						end
						jobs = jobs - 1
					end)
				end
			end

			local waited = 0
			local minWait = 3.5
			local hardWait = 6.5
			while jobs > 0 and waited < CFG.SearchTimeout + 3 do
				if waited > minWait and #collected >= 6 then break end
				if waited > hardWait and #collected > 0 then break end
				task.wait(0.1)
				waited = waited + 0.1
			end

			if #collected == 0 then
				plan.weak = true
				local rescue = CrossAIMusic.queryVariants(plan, plan.query)
				for _, q in ipairs(rescue) do
					for _, src in ipairs(sources) do
						local ok, list = pcall(searchOne, src, q, 2)
						if ok then push(list) end
					end
				end
			end

			if #collected == 0 then
				callback("error", { reason = table.concat(errors, ", ") })
				return {}
			end

			local maxSecs = CFG.MaxTrackSeconds or 0
			if maxSecs > 0 then
				local shortList = {}
				for _, t in ipairs(collected) do
					local secs = CrossAIMusic.durationSeconds(t.duration)
					if secs > 0 and secs <= maxSecs then shortList[#shortList + 1] = t end
				end
				if #shortList >= 3 then collected = shortList end
			end

            local relevant = {}
            for _, t in ipairs(collected) do
                if CrossAIMusic.isRelevant(t, plan) then
                    t._score = CrossAIMusic.score(t, plan)
                    relevant[#relevant + 1] = t
                end
            end
            collected = relevant
            if #collected == 0 then
                callback("error", {reason = "no sufficiently related results"})
                return {}
            end
			table.sort(collected, function(a, b) return a._score > b._score end)

			local top = {}
			for i = 1, math.min(#collected, plan.limit or CFG.TopN) do top[i] = collected[i] end

			callback("done", { plan = plan, results = top, total = #collected })
			return top
		end

