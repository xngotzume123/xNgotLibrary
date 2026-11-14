--[[ xngot-studio · src/modules/30_overlay/070_engine_open.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.open
     role   : Tạo CrossAIMusic: CFG, Sources, Util, request, Llm
     source : main 2.txt L6278-6559 · 282 dòng · delta +1
--]]
		local function __xNgotCreateAIMusicEngine(HsIn)
		local CrossAIMusic = {}
		CrossAIMusic.__factory = true

		local CFG = {
			ApiBase        = "https://ymp-api.ymp-api.workers.dev",
			PowBase        = "https://p.savenow.to",
			PowReferer     = "https://en.loader.to/",
			PowApiKey      = "dfcb6d76f2f6a9894gjkege8a4ab232222",
			Folder         = "xNgotLibrary/Music",
			CoversFolder   = "xNgotLibrary/Music/Covers",
			TopN           = 12,
			SearchTimeout  = 12,
			PowTimeout     = 25,
			DownloadTimeout= 200,
			Retries        = 2,

			PreferShort    = 600,

			RaceTracks     = 2,

			Sources        = { "youtube", "soundcloud", "audius" },

			MaxTrackSeconds = 1200,
		}
		CrossAIMusic.Config = CFG

		CrossAIMusic.Sources = {
			{ id = "youtube",    label = "YouTube",    domain = "youtube.com",    canStream = false },
			{ id = "soundcloud", label = "SoundCloud", domain = "soundcloud.com", canStream = false },
			{ id = "tiktok",     label = "TikTok",     domain = "tiktok.com",     canStream = false },
			{ id = "audius",     label = "Audius",     domain = "audius.co",      canStream = true  },
			{ id = "audiomack",  label = "Audiomack",  domain = "audiomack.com",  canStream = false },
			{ id = "mixcloud",   label = "Mixcloud",   domain = "mixcloud.com",   canStream = false },
		}

		local Hs = HsIn
		if not Hs then pcall(function() Hs = game:GetService("HttpService") end) end

		local function md5dec(t) end

		local function trim(s) return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")) end

		local function stripAccent(s)
			s = tostring(s or "")
			s = s:gsub("à", "a"):gsub("á", "a"):gsub("ạ", "a"):gsub("ả", "a"):gsub("ã", "a")
			s = s:gsub("â", "a"):gsub("ầ", "a"):gsub("ấ", "a"):gsub("ậ", "a"):gsub("ẩ", "a"):gsub("ẫ", "a")
			s = s:gsub("ă", "a"):gsub("ằ", "a"):gsub("ắ", "a"):gsub("ặ", "a"):gsub("ẳ", "a"):gsub("ẵ", "a")
			s = s:gsub("è", "e"):gsub("é", "e"):gsub("ẹ", "e"):gsub("ẻ", "e"):gsub("ẽ", "e")
			s = s:gsub("ê", "e"):gsub("ề", "e"):gsub("ế", "e"):gsub("ệ", "e"):gsub("ể", "e"):gsub("ễ", "e")
			s = s:gsub("ì", "i"):gsub("í", "i"):gsub("ị", "i"):gsub("ỉ", "i"):gsub("ĩ", "i")
			s = s:gsub("ò", "o"):gsub("ó", "o"):gsub("ọ", "o"):gsub("ỏ", "o"):gsub("õ", "o")
			s = s:gsub("ô", "o"):gsub("ồ", "o"):gsub("ố", "o"):gsub("ộ", "o"):gsub("ổ", "o"):gsub("ỗ", "o")
			s = s:gsub("ơ", "o"):gsub("ờ", "o"):gsub("ớ", "o"):gsub("ợ", "o"):gsub("ở", "o"):gsub("ỡ", "o")
			s = s:gsub("ù", "u"):gsub("ú", "u"):gsub("ụ", "u"):gsub("ủ", "u"):gsub("ũ", "u")
			s = s:gsub("ư", "u"):gsub("ừ", "u"):gsub("ứ", "u"):gsub("ự", "u"):gsub("ử", "u"):gsub("ữ", "u")
			s = s:gsub("ỳ", "y"):gsub("ý", "y"):gsub("ỵ", "y"):gsub("ỷ", "y"):gsub("ỹ", "y")
			s = s:gsub("đ", "d"):gsub("Đ", "D")
			s = s:gsub("À", "A"):gsub("Á", "A"):gsub("Ạ", "A"):gsub("Ả", "A"):gsub("Ã", "A"):gsub("Â", "A"):gsub("Ă", "A")
			s = s:gsub("È", "E"):gsub("É", "E"):gsub("Ẹ", "E"):gsub("Ẻ", "E"):gsub("Ẽ", "E"):gsub("Ê", "E")
			s = s:gsub("Ì", "I"):gsub("Í", "I"):gsub("Ị", "I"):gsub("Ỉ", "I"):gsub("Ĩ", "I")
			s = s:gsub("Ò", "O"):gsub("Ó", "O"):gsub("Ọ", "O"):gsub("Ỏ", "O"):gsub("Õ", "O"):gsub("Ô", "O"):gsub("Ơ", "O")
			s = s:gsub("Ù", "U"):gsub("Ú", "U"):gsub("Ụ", "U"):gsub("Ủ", "U"):gsub("Ũ", "U"):gsub("Ư", "U")
			s = s:gsub("Ỳ", "Y"):gsub("Ý", "Y"):gsub("Ỵ", "Y"):gsub("Ỷ", "Y"):gsub("Ỹ", "Y")
			return s
		end

		local function norm(s)
			s = stripAccent(s):lower()
			s = s:gsub("[%p%c]", " ")
			s = s:gsub("%s+", " ")
			return trim(s)
		end

		local function words(normalized)
			local out, seen = {}, {}
			for w in normalized:gmatch("[%w]+") do
				if #w > 1 and not seen[w] then
					seen[w] = true
					out[#out + 1] = w
				end
			end
			return out
		end

		local function sanitizeName(text)
			local out = tostring(text or ""):gsub("[%c]", " ")
			out = out:gsub('[<>:"/\\|%?%*]', " ")
			out = out:gsub("[%[%]%(%){}#%%&,;]", " ")
			out = out:gsub("%s+", " ")
			out = trim(out)
			if #out > 80 then out = trim(out:sub(1, 80)) end
			return out
		end

		CrossAIMusic.Util = {
			trim = trim, stripAccent = stripAccent, norm = norm, words = words, sanitizeName = sanitizeName,
		}

		local function getHttp()
			if Hs then return Hs end
			pcall(function() Hs = game:GetService("HttpService") end)
			return Hs
		end

		local function jsonDecode(text)
			local hs = getHttp()
			if not hs or type(text) ~= "string" or #text == 0 then return nil end
			local ok, data = pcall(function() return hs:JSONDecode(text) end)
			if ok then return data end
			return nil
		end

		local function urlEncode(s)
			local hs = getHttp()
			local ok, out = pcall(function() return hs:UrlEncode(tostring(s)) end)
			if ok and type(out) == "string" then return out end
			return (tostring(s):gsub("[^%w%-%._~]", function(c)
				return string.format("%%02X", string.byte(c))
			end))
		end

		local function httpGet(url)
			local ok, data = pcall(function() return game:HttpGet(url) end)
			if ok and type(data) == "string" and #data > 0 then return data end
			local hs = getHttp()
			if hs then
				ok, data = pcall(function() return hs:GetAsync(url) end)
				if ok and type(data) == "string" and #data > 0 then return data end
			end
			return nil
		end

		function CrossAIMusic.request(url, method, headers, body, timeout)
			local raw
			pcall(function()
				raw = request or http_request or syn_request
					or (syn and syn.request)
					or (http and http.request)
					or (fluxus and fluxus.request)
			end)
			if raw then
				local ok, res = pcall(raw, {
					Url = url, Method = method or "GET", Headers = headers,
					Body = body, Timeout = timeout or 15, Redirects = false,
				})
				if ok and type(res) == "table" then return res end
			end

			local hs = getHttp()
			if hs then
				local ok, res = pcall(function()
					local opts = { Url = url, Method = method or "GET" }
					if body then opts.Body = body end
					return hs:RequestAsync(opts)
				end)
				if ok and type(res) == "table" then return res end
			end
			return nil
		end

		local Llm = {
			enabled = false,
			mode = "hybrid",
			lastAt = 0,
			lastPlan = nil,
			lastPrompt = nil,
			lastError = nil,
			okCount = 0,
			failCount = 0,
			busy = false,
			cache = {},
		}
		CrossAIMusic.Llm = Llm

		local LLM_CACHE_TTL = 600

		function CrossAIMusic.llmAvailable()
			return false
		end

		function CrossAIMusic.llmEnabled()
			return false
		end

		function CrossAIMusic.llmSetEnabled(on)
			Llm.enabled = false

			CFG.LlmMode = Llm.enabled and "hybrid" or "off"
			return Llm.enabled
		end

		function CrossAIMusic.applyLlmPlan(plan, extra)
			if type(plan) ~= "table" or type(extra) ~= "table" then return plan end

			local pieces = {}
			local base = trim(tostring(plan.query or ""))
			if base ~= "" then pieces[#pieces + 1] = base end

			local q = trim(tostring(extra.query or ""))
			if q ~= "" and q:lower() ~= base:lower() then pieces[#pieces + 1] = q end

			if q ~= "" then plan.query = q end
			if extra.artist ~= "" then
				plan.llmArtist = extra.artist
				if plan.query:lower():find(extra.artist:lower(), 1, true) == nil then
					plan.query = trim(plan.query .. " " .. extra.artist)
				end
			end
			if extra.genre ~= "" and not plan.tags.genre then plan.tags.genre = extra.genre end
			if extra.mood ~= "" and not plan.tags.mood then plan.tags.mood = extra.mood end
			if extra.reason ~= "" then plan.llmReason = extra.reason end
			plan.fromLlm = true
			return plan
		end

		function CrossAIMusic.llmStatus()
			return { enabled = false, removed = true, mode = "local", ok = 0, fail = 0 }
		end

		local function llmCall(_prompt, _system)
			return nil, "off"
		end

		function CrossAIMusic.llmPlan(prompt, plan)
			if not CrossAIMusic.llmEnabled() then return nil end
			prompt = trim(tostring(prompt or ""))
			if prompt == "" then return nil end

			local key = prompt:lower()
			local hit = Llm.cache[key]
			if hit and os.time() - hit.at < LLM_CACHE_TTL then return hit.plan end

			local ask = string.format(
				'Người dùng nói: "%s". Hãy tách thành JSON đúng schema: ' ..
				'{"query":"từ khóa tìm nhạc ngắn (giữ nguyên tên bài nếu có)","genre":"thể loại hoặc rỗng",' ..
				'"mood":"cảm xúc hoặc rỗng","artist":"ca sĩ hoặc rỗng","reason":"1 câu tiếng Việt ngắn"}. ' ..
				'Chỉ trả JSON, không giải thích, không markdown.', prompt)

			local text = llmCall(ask, "Bạn là bộ tách yêu cầu nhạc. Chỉ trả về JSON hợp lệ, không giải thích.")
			if not text then return nil end

			local json = extractJson(text)
			local data = json and jsonDecode(json)
			if type(data) ~= "table" then
				Llm.lastError = "LLM trả về không phải JSON"
				return nil
			end

			local merged = {
				query = trim(tostring(data.query or "")),
				genre = trim(tostring(data.genre or "")),
				mood = trim(tostring(data.mood or "")),
				artist = trim(tostring(data.artist or "")),
				reason = trim(tostring(data.reason or "")),
			}
			if merged.query == "" and merged.genre == "" and merged.mood == "" then return nil end

			Llm.cache[key] = { plan = merged, at = os.time() }
			return merged
		end

		function CrossAIMusic.llmSay(prompt, context)
			if not CrossAIMusic.llmEnabled() or not CFG.LlmReply then return nil end
			local ask = string.format(
				'Người dùng: "%s". %sTrả lời như một trợ lý âm nhạc thân thiện, tiếng Việt, tối đa 2 câu, ' ..
				'không markdown, không lan man.',
				tostring(prompt or ""), (context and (tostring(context) .. " ")) or "")
			return llmCall(ask, "Bạn là Cross AI, trợ lý âm nhạc trong một script Roblox. Trả lời tiếng Việt, thân thiện, ngắn.")
		end

		local K256 = {
			0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
			0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
			0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
			0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
			0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
			0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
			0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
			0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
		}

