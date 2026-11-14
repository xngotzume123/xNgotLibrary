--[[ xngot-studio · src/modules/30_overlay/074_engine_crypto.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.crypto
     role   : SHA-256 + solvePow (proof-of-work) cho API nhạc
     source : main 2.txt L6560-6664 · 105 dòng · delta +0
--]]
		local function shr(x, n) return math.floor(x / 2 ^ n) % 2 ^ 32 end
		local function rotr32(x, n)
			n = n % 32
			local low = x % 2 ^ n
			return (x - low) / 2 ^ n + low * 2 ^ (32 - n)
		end
		local function band(a, b)
			local res, bit = 0, 1
			for _ = 1, 32 do
				local ai, bi = a % 2, b % 2
				if ai == 1 and bi == 1 then res = res + bit end
				a = (a - ai) / 2
				b = (b - bi) / 2
				bit = bit * 2
			end
			return res
		end
		local function bxor(a, b)
			local res, bit = 0, 1
			for _ = 1, 32 do
				local ai, bi = a % 2, b % 2
				if ai ~= bi then res = res + bit end
				a = (a - ai) / 2
				b = (b - bi) / 2
				bit = bit * 2
			end
			return res
		end
		local function addmod(...)
			local sum = 0
			for _, v in ipairs({ ... }) do sum = (sum + v) % 4294967296 end
			return sum
		end

		local function sha256hex(msg)
			msg = tostring(msg)
			local len = #msg
			local bytes = {}
			for i = 1, len do bytes[i] = string.byte(msg, i) end
			local bitLen = len * 8
			bytes[#bytes + 1] = 128
			while #bytes % 64 ~= 56 do bytes[#bytes + 1] = 0 end
			local hi = math.floor(bitLen / 4294967296)
			local lo = bitLen % 4294967296
			for i = 3, 0, -1 do bytes[#bytes + 1] = math.floor(hi / 2 ^ (8 * i)) % 256 end
			for i = 3, 0, -1 do bytes[#bytes + 1] = math.floor(lo / 2 ^ (8 * i)) % 256 end

			local h0, h1, h2, h3 = 1779033703, 3144134277, 1013904242, 2773480762
			local h4, h5, h6, h7 = 1359893119, 2600822924, 528734635, 1541459225

			for chunk = 1, #bytes, 64 do
				local w = {}
				for i = 0, 15 do
					local p = chunk + i * 4
					w[i + 1] = bytes[p] * 16777216 + bytes[p + 1] * 65536 + bytes[p + 2] * 256 + bytes[p + 3]
				end
				for i = 17, 64 do
					local s0 = bxor(bxor(rotr32(w[i - 15], 7), rotr32(w[i - 15], 18)), shr(w[i - 15], 3))
					local s1 = bxor(bxor(rotr32(w[i - 2], 17), rotr32(w[i - 2], 19)), shr(w[i - 2], 10))
					w[i] = addmod(w[i - 16], s0, w[i - 7], s1)
				end

				local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7

				for i = 1, 64 do
					local S1 = bxor(bxor(rotr32(e, 6), rotr32(e, 11)), rotr32(e, 25))
					local ch = bxor(band(e, f), band((4294967295 - e) % 4294967296, g))
					local t1 = addmod(h, S1, ch, K256[i], w[i])
					local S0 = bxor(bxor(rotr32(a, 2), rotr32(a, 13)), rotr32(a, 22))
					local maj = bxor(bxor(band(a, b), band(a, c)), band(b, c))
					local t2 = addmod(S0, maj)

					h = g; g = f; f = e
					e = addmod(d, t1)
					d = c; c = b; b = a
					a = addmod(t1, t2)
				end

				h0 = addmod(h0, a); h1 = addmod(h1, b); h2 = addmod(h2, c); h3 = addmod(h3, d)
				h4 = addmod(h4, e); h5 = addmod(h5, f); h6 = addmod(h6, g); h7 = addmod(h7, h)
			end

			return string.format("%08x%08x%08x%08x%08x%08x%08x%08x", h0, h1, h2, h3, h4, h5, h6, h7)
		end
		CrossAIMusic.sha256 = sha256hex

		local function solvePow(salt, difficulty)
			local prefix = string.rep("0", tonumber(difficulty) or 0)
			local base = tostring(salt) .. ":"
			local nonce = 0
			local slice = os.clock()
			while true do
				if sha256hex(base .. tostring(nonce)):sub(1, #prefix) == prefix then
					return tostring(nonce)
				end
				nonce = nonce + 1
				if os.clock() - slice > 0.003 then
					pcall(task.wait)
					slice = os.clock()
				end
				if nonce > 5e6 then return nil end
			end
		end
		CrossAIMusic.solvePow = solvePow

