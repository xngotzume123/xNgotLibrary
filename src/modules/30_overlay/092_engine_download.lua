--[[ xngot-studio · src/modules/30_overlay/092_engine_download.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.download
     role   : Token PoW, powHeaders, getPowToken, download()
     source : main 2.txt L7195-7329 · 135 dòng · delta +0
--]]
		local tokenCache = { token = nil, expires = 0, busy = false }

		local function powHeaders(bearer, withJson)
			local h = {
				["accept"] = "*/*",
				["accept-language"] = "vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7",
				["referer"] = CFG.PowReferer,
				["sec-ch-ua"] = '"Chromium";v="137", "Not/A)Brand";v="24"',
				["sec-ch-ua-mobile"] = "?1",
				["sec-ch-ua-platform"] = '"Android"',
				["sec-fetch-dest"] = "empty",
				["sec-fetch-mode"] = "cors",
				["sec-fetch-site"] = "cross-site",
			}
			if withJson then h["content-type"] = "application/json" end
			if bearer then h["authorization"] = "Bearer " .. tostring(bearer) end
			return h
		end

		function CrossAIMusic.getPowToken()
			if tokenCache.token and os.time() < tokenCache.expires - 30 then
				return tokenCache.token
			end
			if tokenCache.busy then
				local t0 = os.clock()
				while tokenCache.busy and os.clock() - t0 < 20 do task.wait(0.1) end
				if tokenCache.token and os.time() < tokenCache.expires - 30 then
					return tokenCache.token
				end
			end

			tokenCache.busy = true
			local ok, token, expires = pcall(function()
				local chRes = CrossAIMusic.request(CFG.PowBase .. "/api/pow/challenge", "GET", powHeaders(nil, false), nil, CFG.PowTimeout)
				local chBody = chRes and chRes.Body
				if not chBody then chBody = httpGet(CFG.PowBase .. "/api/pow/challenge") end
				local ch = jsonDecode(tostring(chBody or ""))
				if type(ch) ~= "table" or ch.salt == nil or ch.difficulty == nil
					or ch.expires_at == nil or ch.signature == nil then
					return nil
				end

				local nonce = solvePow(ch.salt, ch.difficulty)
				if not nonce then return nil end

				local hs = getHttp()
				local body = hs:JSONEncode({
					salt = ch.salt, difficulty = ch.difficulty,
					expires_at = ch.expires_at, signature = ch.signature, nonce = nonce,
				})
				local vRes = CrossAIMusic.request(CFG.PowBase .. "/api/pow/verify", "POST", powHeaders(nil, true), body, CFG.PowTimeout)
				local v = jsonDecode(tostring(vRes and vRes.Body or ""))
				if type(v) ~= "table" or v.success ~= true or type(v.token) ~= "string" then return nil end
				return v.token, tonumber(v.expires_at) or tonumber(ch.expires_at) or (os.time() + 300)
			end)
			tokenCache.busy = false

			if ok and type(token) == "string" then
				tokenCache.token = token
				tokenCache.expires = tonumber(expires) or (os.time() + 300)
				return token
			end
			return nil
		end

		function CrossAIMusic.download(url, onProgress)
			onProgress = onProgress or function() end
			local started = os.clock()

			for attempt = 1, CFG.Retries + 1 do
				onProgress("pow", { attempt = attempt })
				local token = CrossAIMusic.getPowToken()

				if token then
					local submitUrl = CFG.PowBase .. "/api/v2/download?format=mp3"
						.. "&url=" .. urlEncode(url)
						.. "&apikey=" .. urlEncode(CFG.PowApiKey)

					local res = CrossAIMusic.request(submitUrl, "GET", powHeaders(token, false), nil, CFG.PowTimeout)
					local data = jsonDecode(tostring(res and res.Body or ""))

					if type(data) == "table" and data.success ~= false and type(data.progress_url) == "string" then
						onProgress("queue", { progressUrl = data.progress_url })
						task.wait(0.6)

						local done, stuck = nil, 0
						while os.clock() - started < CFG.DownloadTimeout do
							local pRes = CrossAIMusic.request(data.progress_url, "GET", powHeaders(token, false), nil, CFG.PowTimeout)
							local p = jsonDecode(tostring(pRes and pRes.Body or ""))
							if type(p) == "table" then
								if p.progress == 1000 and type(p.download_url) == "string" then
									done = p
									break
								end
								if p.progress == 1000 then
									stuck = stuck + 1
									if stuck >= 2 then break end
								else
									local pct = tonumber(p.progress)
									if pct then onProgress("progress", { percent = math.clamp(pct / 1000, 0, 1) }) end
								end
							end

							local span = os.clock() - started
							task.wait(span < 6 and 0.5 or (span < 30 and 0.9 or 1.6))
						end

						if done then
							local candidates = { done.download_url }
							if type(done.alternative_download_urls) == "table" then
								for _, alt in ipairs(done.alternative_download_urls) do
									if #candidates >= 4 then break end
									if type(alt) == "table" and type(alt.url) == "string" and alt.url ~= done.download_url then
										candidates[#candidates + 1] = alt.url
									end
								end
							end
							onProgress("done", { urls = candidates })
							return candidates
						end
					end
				else
					onProgress("pow", { attempt = attempt, failed = true })
				end

				if attempt <= CFG.Retries then
					onProgress("retry", { attempt = attempt })
					task.wait(2)
				end
			end

			onProgress("error", { reason = "pow/download failed" })
			return nil
		end

