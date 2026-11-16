--[[ xngot-studio · src/modules/30_overlay/096_engine_audio.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.audio
     role   : Nhận dạng audio, đọc ID3, hash, cache, cover, saveBytes
     source : main 2.txt L7330-7585 · 256 dòng · delta +0
--]]
		local function looksLikeErrorPayload(s)
			if #s == 0 then return true end
			local low = s:sub(1, 64):lower()
			if low:sub(1, 1) == "{" then return true end
			if low:find("<!doctype", 1, true) or low:find("<html", 1, true) then return true end
			if low:find("api_key_required", 1, true) or low:find("error_code", 1, true) then return true end
			return false
		end

		local function looksLikeAudio(s)
			if type(s) ~= "string" or #s < 1024 then return false end
			local b1, b2, b3, b4 = s:byte(1, 4)
			if b1 == 0x49 and b2 == 0x44 and b3 == 0x33 then return true end
			if b1 == 0xFF and b2 and b2 >= 0xE0 then return true end
			if s:sub(5, 8) == "ftyp" then return true end
			if b1 == 0x4F and b2 == 0x67 and b3 == 0x67 and b4 == 0x53 then return true end
			if b1 == 0x1A and b2 == 0x45 and b3 == 0xDF and b4 == 0xA3 then return true end
			if b1 == 0x52 and b2 == 0x49 and b3 == 0x46 and b4 == 0x46 then return true end
			return false
		end
		CrossAIMusic.looksLikeAudio = looksLikeAudio

		local function readID3(data)
			if type(data) ~= "string" or #data < 64 then return nil end
			if data:sub(1, 3) ~= "ID3" then return nil end

			local version = data:byte(4) or 3
			local size = 0
			for i = 7, 10 do
				size = size * 128 + ((data:byte(i) or 0) % 128)
			end

			local limit = math.min(11 + size, #data)
			local pos = 11
			local info = {}

			local function decodeText(bytes, encoding)
				if encoding == 0 then
					return bytes
				elseif encoding == 3 then
					return bytes
				end

				local out = {}
				local step = 2
				local i = 1
				if #bytes % 2 == 1 then i = 1 end
				while i < #bytes do
					local lo = bytes:byte(i)
					local hi = bytes:byte(i + 1)
					local code = lo + hi * 256
					if code > 0 then out[#out + 1] = string.char(lo) end
					i = i + step
				end
				return table.concat(out)
			end

			while pos + 10 <= limit do
				local id = data:sub(pos, pos + 3)
				if not id:match("^[A-Z0-9]+$") then break end
				local fsize = 0
				for k = 0, 3 do
					fsize = fsize * 256 + (data:byte(pos + 4 + k) or 0)
				end
				local body = data:sub(pos + 10, pos + 9 + fsize)
				pos = pos + 10 + fsize
				if #body < 2 then break end

				if id == "TIT2" then
					info.title = decodeText(body:sub(2), body:byte(1))
				elseif id == "TPE1" then
					info.artist = decodeText(body:sub(2), body:byte(1))
				elseif id == "TALB" then
					info.album = decodeText(body:sub(2), body:byte(1))
				elseif id == "APIC" then
					local enc = body:byte(1)
					local mimeEnd = body:find("\0", 2, true)
					if mimeEnd then
						local mime = body:sub(2, mimeEnd - 1):lower()

						local p = mimeEnd + 1
						if body:byte(p) then p = p + 1 end
						local descEnd = body:find("\0", p, true)
						if descEnd then p = descEnd + 1 end
						local pic = body:sub(p)
						if #pic > 200 then
							local ext = ".jpg"
							if mime:find("png", 1, true) then ext = ".png" end
							info.cover = pic
							info.coverExt = ext
						end
					end
				end
			end

			for k, v in pairs(info) do
				if type(v) == "string" then
					info[k] = trim((v:gsub("%c", " ")))
				end
			end
			if info.title == "" then info.title = nil end
			if info.artist == "" then info.artist = nil end
			return info
		end
		CrossAIMusic.readID3 = readID3

		local function hashOf(text)
			return sha256hex(tostring(text)):sub(1, 10)
		end
		CrossAIMusic.hash = hashOf

        local function ensureFolder(folder)
            folder = tostring(folder or CFG.Folder):gsub("\\", "/")
            if type(makefolder) ~= "function" then return end
            local part = ""
            for name in folder:gmatch("[^/]+") do
                part = part == "" and name or (part .. "/" .. name)
                if type(isfolder) ~= "function" or not isfolder(part) then pcall(makefolder, part) end
            end
        end
		CrossAIMusic.ensureFolder = ensureFolder

		local renameEnabled = true
		function CrossAIMusic.renameFiles(on)
			renameEnabled = on ~= false
			return renameEnabled
		end
		function CrossAIMusic.isRenameEnabled() return renameEnabled end

		function CrossAIMusic.cacheCandidates(key, title)
			if not renameEnabled then title = nil end
			local out = {}
			local base = sanitizeName(title)
			if base ~= "" then

				out[#out + 1] = string.format("%s/%s [%s].mp3", CFG.Folder, base, string.sub(hashOf(key), 1, 8))
			end

			out[#out + 1] = string.format("%s/%s.mp3", CFG.Folder, hashOf(key))
			return out
		end

		function CrossAIMusic.cachePath(key, title)
			local list = CrossAIMusic.cacheCandidates(key, title)
			return list[1]
		end

		local function readExisting(candidates)
			for _, path in ipairs(candidates) do
				if type(isfile) == "function" and isfile(path) and type(readfile) == "function" then
					local ok, data = pcall(readfile, path)
					if ok and type(data) == "string" and #data > 1024 then
						return data, path
					end
				end
			end
			return nil
		end

		function CrossAIMusic.thumbAsset(track)
			if type(track) ~= "table" then return nil end
			return CrossAIMusic.coverAsset(track)
		end

		function CrossAIMusic.prefetchCovers(list, onOne)
			list = list or {}
			onOne = onOne or function() end
			for _, track in ipairs(list) do
				task.spawn(function()
					local ok, asset = pcall(CrossAIMusic.coverAsset, track)
					if ok and type(asset) == "string" and asset ~= "" then
						pcall(onOne, track, asset)
					end
				end)
			end
		end

		function CrossAIMusic.coverAsset(track)
			if type(track) ~= "table" then return nil end
			if track.CoverAsset then return track.CoverAsset end
			if type(writefile) ~= "function" then return nil end
			local getter = getcustomasset or getsynasset
			if type(getter) ~= "function" then return nil end

			local url = track.thumbnail
			if type(url) ~= "string" or url == "" or not url:match("^https?://") then return nil end

			ensureFolder(CFG.CoversFolder)
			local ext = url:match("%.png") and ".png" or ".jpg"
			local path = string.format("%s/%s%s", CFG.CoversFolder, hashOf(url), ext)

			if type(isfile) == "function" and isfile(path) then
				local okAsset, asset = pcall(getter, path)
				if okAsset and type(asset) == "string" and asset ~= "" then
					track.CoverAsset = asset
					return asset
				end
			end

			local data = httpGet(url)
			if type(data) == "string" and #data > 512 then
				local okWrite = pcall(writefile, path, data)
				if okWrite then
					local okAsset, asset = pcall(getter, path)
					if okAsset and type(asset) == "string" and asset ~= "" then
						track.CoverAsset = asset
						return asset
					end
				end
			end
			return nil
		end

		function CrossAIMusic.saveBytes(key, data, title)
			if type(data) ~= "string" or #data < 1024 then return nil end
			if not looksLikeAudio(data) then return nil end
			if type(writefile) ~= "function" then return nil end
			local getter = getcustomasset or getsynasset
			if type(getter) ~= "function" then return nil end

			ensureFolder()
			local candidates = CrossAIMusic.cacheCandidates(key, title)
			local path = candidates[1]
			if type(_G.xNgotLog) == "table" and type(_G.xNgotLog.debug) == "function" then
				_G.xNgotLog.debug("music", "lưu file: " .. tostring(path) .. " (" .. tostring(#data) .. " byte)")
				_G.xNgotLog.debug("music", "tên thật: " .. tostring(title or key))
			end
			if not pcall(writefile, path, data) then
				path = candidates[#candidates]
				if not pcall(writefile, path, data) then return nil end
			end

			local check = readExisting({ path })
			if check and #check ~= #data then

			end

			 
			pcall(function()
				local id3 = readID3(data)
				CrossAIMusic.writeDownloadedMeta(path, {
					Title = (id3 and id3.title) or title,
					Artist = (id3 and id3.artist) or "",
					Album = (id3 and id3.album) or "",
				})
			end)

			local okAsset, asset = pcall(getter, path)
			if okAsset and type(asset) == "string" and asset ~= "" then return asset, path end
			local altAsset = (customAsset == getcustomasset) and getsynasset or getcustomasset
			if type(altAsset) == "function" and altAsset ~= customAsset then
				local okAlt, alt = pcall(altAsset, path)
				if okAlt and type(alt) == "string" and alt ~= "" then return alt, path end
			end
			return nil
		end

		 
