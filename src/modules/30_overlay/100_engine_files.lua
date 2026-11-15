--[[ xngot-studio · src/modules/30_overlay/100_engine_files.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.files
     role   : File manager engine: liệt kê/xoá/thống kê mp3 đã tải
     source : main 2.txt L7586-7914 · 329 dòng · delta +0
--]]
		local function dlFormatBytes(bytes)
			bytes = tonumber(bytes) or 0
			if bytes < 1024 then return string.format("%d B", bytes) end
			if bytes < 1024 * 1024 then return string.format("%.1f KB", bytes / 1024) end
			if bytes < 1024 * 1024 * 1024 then return string.format("%.2f MB", bytes / (1024 * 1024)) end
			return string.format("%.2f GB", bytes / (1024 * 1024 * 1024))
		end
		CrossAIMusic.formatBytes = dlFormatBytes

		local function dlFileName(path)
			local normalized = tostring(path or ""):gsub("\\", "/")
			return normalized:match("([^/]+)$") or normalized
		end

		local function dlTitleFromFileName(fileName)
			local base = tostring(fileName or ""):gsub("%.mp3$", ""):gsub("%.MP3$", "")
			base = base:gsub("%s%[%x+%]$", "")
			base = trim(base)
			if base == "" then return "Bai da tai" end
			if base:match("^%x+$") and #base <= 12 then return "Bai da tai " .. base end
			return base
		end

		local function dlMetaPath(path)
			return tostring(path or "") .. ".json"
		end

		function CrossAIMusic.readDownloadedMeta(path)
			local metaPath = dlMetaPath(path)
			if type(isfile) == "function" and not isfile(metaPath) then return nil end
			if type(readfile) ~= "function" then return nil end
			local ok, data = pcall(readfile, metaPath)
			if not ok or type(data) ~= "string" or data == "" then return nil end
			local decoded = jsonDecode(data)
			return type(decoded) == "table" and decoded or nil
		end

		function CrossAIMusic.writeDownloadedMeta(path, meta)
			if type(path) ~= "string" or path == "" or type(writefile) ~= "function" then return false end
			local hs = getHttp()
			if not hs then return false end
			local src = type(meta) == "table" and meta or {}
			local clean = {
				Title = tostring(src.Title or src.title or src.Name or src.name or ""),
				Artist = tostring(src.Artist or src.artist or src.Author or src.author or ""),
				Album = tostring(src.Album or src.album or ""),
				Duration = tostring(src.Duration or src.duration or ""),
				Thumbnail = tostring(src.Thumbnail or src.thumbnail or ""),
				Source = tostring(src.Source or src.source or ""),
				Url = tostring(src.Url or src.url or ""),
				Id = tostring(src.Id or src.id or ""),
				SavedAt = os.time and os.time() or 0,
			}
			if clean.Title == "" and clean.Artist == "" and clean.Thumbnail == "" then return false end
			local ok, encoded = pcall(function() return hs:JSONEncode(clean) end)
			if not ok or type(encoded) ~= "string" then return false end
			local okWrite = pcall(writefile, dlMetaPath(path), encoded)
			return okWrite == true
		end

		local function dlEmbeddedCoverAsset(path, info)
			if type(info) ~= "table" or type(info.cover) ~= "string" or #info.cover <= 200 then return nil end
			if type(writefile) ~= "function" then return nil end
			local getter = getcustomasset or getsynasset
			if type(getter) ~= "function" then return nil end
			ensureFolder(CFG.CoversFolder)
			local ext = info.coverExt or ".jpg"
			if ext ~= ".jpg" and ext ~= ".png" then ext = ".jpg" end
			local coverPath = string.format("%s/%s_id3%s", CFG.CoversFolder, hashOf(path), ext)
			if type(isfile) == "function" and isfile(coverPath) then
				local okAsset, asset = pcall(getter, coverPath)
				if okAsset and type(asset) == "string" and asset ~= "" then return asset, coverPath end
			end
			if not pcall(writefile, coverPath, info.cover) then return nil end
			local okAsset, asset = pcall(getter, coverPath)
			if okAsset and type(asset) == "string" and asset ~= "" then return asset, coverPath end
			return nil, coverPath
		end

		function CrossAIMusic.listDownloaded(includeSizes)
			local stats = {
				Folder = CFG.Folder, CoversFolder = CFG.CoversFolder,
				Count = 0, Mp3Bytes = 0, Mp3Text = "0 B",
				CoversCount = 0, CoversBytes = 0, CoversText = "0 B",
				TotalBytes = 0, TotalText = "0 B",
				SizesKnown = false, Supported = type(listfiles) == "function",
			}
			if type(listfiles) ~= "function" then
				return {}, stats
			end
			ensureFolder()
			ensureFolder(CFG.CoversFolder)
			local files = {}
			local mp3Bytes, sizesKnown = 0, includeSizes == true and type(readfile) == "function"
			local okList, list = pcall(listfiles, CFG.Folder)
			if okList and type(list) == "table" then
				for _, rawPath in ipairs(list) do
					local path = tostring(rawPath)
					local fileName = dlFileName(path)
					if fileName:lower():sub(-4) == ".mp3" then
						local entry = {
							Path = path, FileName = fileName,
							Title = dlTitleFromFileName(fileName), Artist = "", Album = "",
							Duration = "", Thumbnail = "", CoverAsset = nil, CoverPath = nil, HasMeta = false,
							Size = nil, SizeText = "",
						}
						if includeSizes and type(readfile) == "function" then
							local okData, data = pcall(readfile, path)
							if okData and type(data) == "string" then
								entry.Size = #data
								entry.SizeText = dlFormatBytes(#data)
								mp3Bytes = mp3Bytes + #data
								 
								local info = readID3(data)
								if type(info) == "table" then
									if info.title and info.title ~= "" then entry.Title = info.title; entry.HasMeta = true end
									if info.artist and info.artist ~= "" then entry.Artist = info.artist; entry.HasMeta = true end
									if info.album and info.album ~= "" then entry.Album = info.album; entry.HasMeta = true end
									local coverAsset, coverPath = dlEmbeddedCoverAsset(path, info)
									if coverAsset then entry.CoverAsset = coverAsset; entry.HasMeta = true end
									if coverPath then entry.CoverPath = coverPath end
								end
							else
								sizesKnown = false
							end
						end
						 
						local sidecar = CrossAIMusic.readDownloadedMeta(path)
						if type(sidecar) == "table" then
							entry.HasMeta = true
							local sTitle = tostring(sidecar.Title or sidecar.title or "")
							local sArtist = tostring(sidecar.Artist or sidecar.artist or "")
							local sAlbum = tostring(sidecar.Album or sidecar.album or "")
							local sDuration = tostring(sidecar.Duration or sidecar.duration or "")
							local sThumb = tostring(sidecar.Thumbnail or sidecar.thumbnail or "")
							if sTitle ~= "" then entry.Title = sTitle end
							if sArtist ~= "" then entry.Artist = sArtist end
							if sAlbum ~= "" then entry.Album = sAlbum end
							if sDuration ~= "" then entry.Duration = sDuration end
							if sThumb ~= "" then entry.Thumbnail = sThumb end
						end
						files[#files + 1] = entry
					end
				end
			end
			table.sort(files, function(a, b)
				local ta, tb = tostring(a.Title):lower(), tostring(b.Title):lower()
				if ta == tb then return tostring(a.FileName):lower() < tostring(b.FileName):lower() end
				return ta < tb
			end)
			local coversCount, coversBytes = 0, 0
			local okCovers, coverList = pcall(listfiles, CFG.CoversFolder)
			if okCovers and type(coverList) == "table" then
				for _, rawPath in ipairs(coverList) do
					local name = dlFileName(rawPath):lower()
					if name:sub(-4) == ".jpg" or name:sub(-4) == ".png" or name:sub(-5) == ".jpeg" then
						coversCount = coversCount + 1
						if includeSizes and type(readfile) == "function" then
							local okData, data = pcall(readfile, tostring(rawPath))
							if okData and type(data) == "string" then coversBytes = coversBytes + #data end
						end
					end
				end
			end
			stats.Count = #files
			stats.Mp3Bytes = mp3Bytes
			stats.CoversCount = coversCount
			stats.CoversBytes = coversBytes
			stats.TotalBytes = mp3Bytes + coversBytes
			stats.SizesKnown = sizesKnown
			stats.Mp3Text = sizesKnown and dlFormatBytes(mp3Bytes) or (tostring(#files) .. " bai")
			stats.CoversText = sizesKnown and dlFormatBytes(coversBytes) or (tostring(coversCount) .. " file")
			stats.TotalText = sizesKnown and dlFormatBytes(mp3Bytes + coversBytes) or "Chua quet dung luong"
			return files, stats
		end

		function CrossAIMusic.downloadedStats(includeSizes)
			local _, stats = CrossAIMusic.listDownloaded(includeSizes == true)
			return stats
		end

		function CrossAIMusic.deleteDownloaded(path)
			if type(delfile) ~= "function" then return false, "Executor khong ho tro delfile" end
			local raw = tostring(path or "")
			local normalized = raw:gsub("\\", "/")
			local prefix = tostring(CFG.Folder):gsub("\\", "/") .. "/"
			if normalized:sub(1, #prefix) ~= prefix then return false, "Duong dan nam ngoai thu muc nhac" end
			local rest = normalized:sub(#prefix + 1)
			if rest == "" or rest:find("/", 1, true) then return false, "Chi xoa file mp3 truc tiep trong thu muc nhac" end
			if rest:lower():sub(-4) ~= ".mp3" then return false, "Chi xoa duoc file .mp3" end
			if type(isfile) == "function" and not isfile(raw) then return false, "File khong con ton tai" end
			local ok, err = pcall(delfile, raw)
			if not ok then return false, tostring(err) end
			 
			pcall(delfile, raw .. ".json")
			for _, ext in ipairs({ ".jpg", ".png" }) do
				local coverPath = string.format("%s/%s_id3%s", CFG.CoversFolder, hashOf(raw), ext)
				if type(isfile) ~= "function" or isfile(coverPath) then pcall(delfile, coverPath) end
			end
			return true
		end

		function CrossAIMusic.clearDownloaded()
			local files = CrossAIMusic.listDownloaded(false)
			local deleted, failed = 0, 0
			for _, file in ipairs(files) do
				local ok = CrossAIMusic.deleteDownloaded(file.Path)
				if ok then deleted = deleted + 1 else failed = failed + 1 end
			end
			return deleted, failed
		end

		local function raceUrls(urls, onProgress)
			local list = urls or {}
			if #list == 0 then return nil end

			if #list == 1 then
				return httpGet(list[1])
			end

			local done, winner = false, nil
			local pending = #list

			for index, url in ipairs(list) do
				task.spawn(function()
					local data = httpGet(url)
					pending = pending - 1
					if not done and looksLikeAudio(data) then
						done = true
						winner = data
						if onProgress then onProgress("winner", { index = index, url = url }) end
					end
				end)
			end

			local waited = 0
			while not done and pending > 0 and waited < 240 do
				task.wait(0.2)
				waited = waited + 0.2
			end
			return winner
		end
		CrossAIMusic.raceUrls = raceUrls

		function CrossAIMusic.fetchFile(key, urls, onProgress, title)
			onProgress = onProgress or function() end

			if type(writefile) ~= "function" then
				onProgress("error", { reason = "executor thiếu writefile" })
				return nil
			end
			local getter = getcustomasset or getsynasset
			if type(getter) ~= "function" then
				onProgress("error", { reason = "executor thiếu getcustomasset/getsynasset" })
				return nil
			end

			local candidates = CrossAIMusic.cacheCandidates(key, title)
			for _, path in ipairs(candidates) do
				if type(isfile) == "function" and isfile(path) then
					local okAsset, asset = pcall(getter, path)
					if okAsset and type(asset) == "string" and asset ~= "" then
						onProgress("cache", { path = path })
						return asset, path
					end
				end
			end

			ensureFolder()

			local list = urls or {}
			onProgress("fetch", { url = list[1], count = #list })

			local data = raceUrls(list, onProgress)
			if looksLikeAudio(data) then
				local asset, path = CrossAIMusic.saveBytes(key, data, title)
				if asset then return asset, path end
			end

			onProgress("error", { reason = "không tải được file mp3" })
			return nil
		end

		function CrossAIMusic.assetFor(track, onProgress)
			onProgress = onProgress or function() end
			local urls = nil

			if track.directUrl and track.source == "audius" then
				local res = CrossAIMusic.request(track.directUrl, "GET", { ["accept"] = "application/json" }, nil, 20)
				if res then
					if res.StatusCode == 200 and type(res.Body) == "string" and res.Body:sub(1, 1) == "{" then
						local info = jsonDecode(res.Body)
						if type(info) == "table" and type(info.data) == "string" and info.data ~= "" then
							urls = { info.data }
						end
					elseif res.StatusCode == 200 and type(res.Body) == "string" and #res.Body > 1024 then
						urls = { track.directUrl }
						track._inline = res.Body
					elseif res.StatusCode and res.StatusCode >= 300 and res.StatusCode < 400 and type(res.Headers) == "table" then
						local loc = res.Headers.Location or res.Headers.location
						if type(loc) == "string" and loc ~= "" then urls = { loc } end
					end
				end

				if not urls then urls = { track.directUrl } end
			end

			if not urls then
				local target = track.url or track.Url
				if not target or target == "" then
					target = "https://youtu.be/" .. tostring(track.id or track.Id)
				end
				urls = CrossAIMusic.download(target, onProgress)
			end

			if not urls then return nil end

			local key = track.id or track.Id or track.url or track.Url or "track"
			local title = track.name or track.Name or track.title

			if track._inline and type(writefile) == "function" then
				local asset, path = CrossAIMusic.saveBytes(key, track._inline, title)
				track._inline = nil
				if asset then return asset, path end
			end

			return CrossAIMusic.fetchFile(key, urls, onProgress, title)
		end

