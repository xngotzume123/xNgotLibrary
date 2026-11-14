--[[ xngot-studio · src/modules/30_overlay/148_cross_control.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.cross_control
     role   : refreshIslandScale, Cross.setEnabled/ask/clearChat/shutdown
     source : main 2.txt L10444-10784 · 341 dòng · delta +0
--]]
		local function refreshIslandScale()
    local currentCamera = workspace.CurrentCamera or camera
    local viewport = currentCamera and currentCamera.ViewportSize or Vector2.new(800, 600)
    islandState.Base = math.clamp(viewport.X / 430, 0.6, 1)
    Isl.layoutIsland()
end

refreshIslandScale()
track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshIslandScale))

Fwd.setWindow = function(open)
    if not __hostWindow then return end
    if open then
        if type(__hostWindow.Show) == "function" then __hostWindow:Show() end
    elseif type(__hostWindow.Hide) == "function" then
        __hostWindow:Hide()
    end
    State.Open = open and true or false
end

function Cross.releaseFocus()
    for _, field in ipairs(Cross.Inputs) do
        if field and field.Parent then
            pcall(function() field:ReleaseFocus() end)
        end
    end
end

function Cross.setEnabled(on)
    Cross.Enabled = on and true or false
    if Cross.Enabled then
        if not Cross.Chat[1] then
            Cross.say("cross", Settings.Language == "en"
                and "Hi! I'm Cross. You can ask me to play music, skip tracks or set a timer."
                or "Chào bạn! Mình là Cross. Bạn có thể nhờ mình mở nhạc, chuyển bài hoặc hẹn giờ.")
        end
        Cross.setMood("happy", 2)
        Activities.Cross = {
            Title = "Cross",
            Color = Static.Purple,
            Value = function() return Settings.Language == "en" and "Ready" or "Sẵn sàng" end,
            Short = function() return "Cross" end,
        }
    else
        Activities.Cross = nil
        Cross.releaseFocus()
    end
    refreshActivity()
end

local function __askNorm(text)
    local raw = string.lower(tostring(text or ""))
    local map = {
        ["à"]="a",["á"]="a",["ạ"]="a",["ả"]="a",["ã"]="a",["â"]="a",["ầ"]="a",["ấ"]="a",["ậ"]="a",["ẩ"]="a",["ẫ"]="a",
        ["ă"]="a",["ằ"]="a",["ắ"]="a",["ặ"]="a",["ẳ"]="a",["ẵ"]="a",
        ["è"]="e",["é"]="e",["ẹ"]="e",["ẻ"]="e",["ẽ"]="e",["ê"]="e",["ề"]="e",["ế"]="e",["ệ"]="e",["ể"]="e",["ễ"]="e",
        ["ì"]="i",["í"]="i",["ị"]="i",["ỉ"]="i",["ĩ"]="i",
        ["ò"]="o",["ó"]="o",["ọ"]="o",["ỏ"]="o",["õ"]="o",["ô"]="o",["ồ"]="o",["ố"]="o",["ộ"]="o",["ổ"]="o",["ỗ"]="o",
        ["ơ"]="o",["ờ"]="o",["ớ"]="o",["ợ"]="o",["ở"]="o",["ỡ"]="o",
        ["ù"]="u",["ú"]="u",["ụ"]="u",["ủ"]="u",["ũ"]="u",["ư"]="u",["ừ"]="u",["ứ"]="u",["ự"]="u",["ử"]="u",["ữ"]="u",
        ["ỳ"]="y",["ý"]="y",["ỵ"]="y",["ỷ"]="y",["ỹ"]="y",["đ"]="d",
    }
    for key, value in pairs(map) do raw = raw:gsub(key, value) end
    return (raw:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function __has(text, ...)
    for _, word in ipairs({ ... }) do
        if text:find(word, 1, true) then return true end
    end
    return false
end

function Cross.ask(prompt)
    prompt = tostring(prompt or "")
    if prompt == "" then return end
    if not Cross.Enabled then Cross.setEnabled(true) end
    Cross.say("user", prompt)
			do
				local Engine = Music.Remote and Music.Remote.Engine
				local nrm = (CrossAIMusic and CrossAIMusic.Util and CrossAIMusic.Util.norm(prompt)) or ""

				local isControl = false
				for _, w in ipairs({
					"next", "chuyen bai", "bai tiep", "previous", "bai truoc",
					"pause", "tam dung", "dung hen gio", "hen gio",
					"volume", "am luong", "tang am", "giam am", "stop nhac", "tat nhac",
				}) do
					if nrm:find(w, 1, true) then
						isControl = true
						break
					end
				end

				local hasTag = false
				if CrossAIMusic and CrossAIMusic.Lexicon then
					for key in pairs(CrossAIMusic.Lexicon) do
						if nrm:find(key, 1, true) then
							hasTag = true
							break
						end
					end
				end

				local asksSearch = nrm:find("tim nhac", 1, true) or nrm:find("tim bai", 1, true)
					or nrm:find("phat nhac", 1, true) or nrm:find("mo nhac", 1, true)
					or nrm:find("nghe nhac", 1, true) or nrm:find("play music", 1, true)
					or nrm:find("find music", 1, true) or nrm:find("search music", 1, true)
					or nrm:find("bat nhac", 1, true) or nrm:find("bai hat", 1, true)
					or prompt:find("https://", 1, true) or prompt:find("http://", 1, true)

				if Engine and (hasTag or asksSearch) and not isControl then
					local vi = crossPromptIsVi(prompt)
					local plan = Engine.parse(prompt)

					if prompt:find("https://", 1, true) or prompt:find("http://", 1, true) then
						plan.query = prompt:match("https?://%S+") or prompt
					end

					local function say(state, payload)
						local sayFn = Engine.say or (CrossAIMusic and CrossAIMusic.say)
						if type(sayFn) ~= "function" then return end
						local ok, res = pcall(sayFn, state, payload, vi)
						if ok and type(res) == "table" and res.text then
							Cross.say("cross", res.text)
							if res.mood then Cross.setMood(res.mood, 4) end
						end
					end

					Cross.Thinking = true
					Cross.setMood("think", 6)
					say("thinking", { query = plan.query })

					local okRun, asset, track = pcall(function()
						return Engine.resolve(prompt, function(state, payload)
							payload = payload or {}
							if state == "parse" then
								Cross.setMood("think", 6)
							elseif state == "searching" then
								Cross.Echo = vi and "đang tìm…" or "searching…"
							elseif state == "trying" then
								Cross.setMood("think", 6)
								Cross.Echo = (vi and "thử bài " or "try #") .. tostring(payload.rank or 1)
							elseif state == "download" then
								local inner = payload.payload or {}
								if type(inner.percent) == "number" then
									Cross.Echo = string.format("%d%%", math.floor(inner.percent * 100 + 0.5))
								end
							end
						end)
					end)

					Cross.Thinking = false
					Cross.Echo = ""

					if okRun and type(asset) == "string" and asset ~= "" and type(track) == "table" then
						local covers = Music.Covers or { { Static.Purple, Static.Blue } }
						local cover = covers[(Music.Index % #covers) + 1]

						local row = (CrossAIMusic and type(CrossAIMusic.rowData) == "function")
							and CrossAIMusic.rowData(track, #Music.Tracks + 1) or nil
						local desc, value = "", nil
						if row then
							desc, value = row.Artist, row.Value
							if row.Duration ~= "" then
								desc = (desc ~= "" and (desc .. " · " .. row.Duration) or row.Duration)
							end
						end

						local coverAsset = track.CoverAsset
						if not coverAsset and CrossAIMusic and type(CrossAIMusic.thumbAsset) == "function" then
							local okCover, got = pcall(CrossAIMusic.thumbAsset, track)
							if okCover then coverAsset = got end
						end

						local index = Music.PlayAsset({
							Name = track.name,
							Artist = track.author or "",
							Mood = desc,
							Desc = desc,
							Value = value,
							Remote = true,
							Source = track.source,
							Duration = track.duration,
							Thumbnail = track.thumbnail,
							CoverAsset = coverAsset,
							Url = track.url,
							Id = track.id,
							Asset = asset,
							A = cover[1],
							B = cover[2],
						})

						Cross.setMood("happy", 3)
						say("ready", { name = track.name, author = track.author })
						notify("Cross AI",
							(vi and "Đã thêm vào danh sách: " or "Added to list: ") .. tostring(track.name),
							"success", 3, true)
						if index and Island.Expanded and Isl.expand then
							Isl.expand("Music")
						end
					else
						Cross.setMood("sad", 4)
						local okSay, none = pcall(function()
							return Engine.say("none", { query = plan.query }, vi)
						end)
						if okSay and type(none) == "table" and none.text then
							Cross.say("cross", none.text)
						else
							Cross.say("cross", vi
								and "Mình không tìm/tải được bài phù hợp. Thử mô tả khác nhé (vd: \"nhạc lofi buổi tối\")."
								or "I could not find or download a matching track. Try another description.")
						end
					end
					return
				end
			end

    local lower = __askNorm(prompt)
    local vi = crossPromptIsVi(prompt)
    local response

    local seconds = lower:match("timer%s+(%d+)") or lower:match("hen gio%s+(%d+)") or lower:match("(%d+)%s*giay")
    local minutes = lower:match("(%d+)%s*phut")

    if __has(lower, "chuyen bai", "bai tiep", "next", "skip") then
        Music.Next(1)
        response = vi and "Đã chuyển bài tiếp theo." or "Skipped to the next song."
    elseif __has(lower, "bai truoc", "previous", "quay lai") then
        Music.Next(-1)
        response = vi and "Đã trở về bài trước." or "Playing the previous track."
    elseif __has(lower, "tam dung", "dung nhac", "pause", "stop nhac") then
        if Music.Playing then Music.Toggle() end
        response = vi and "Đã tạm dừng nhạc." or "Music paused."
    elseif __has(lower, "dung hen gio", "huy hen gio", "stop timer") then
        stopTimer()
        response = vi and "Đã dừng hẹn giờ." or "Timer stopped."
    elseif __has(lower, "to hon", "lon hon", "tang am", "volume up", "to tieng") then
        Music.SetVolume(math.min(100, (Music.Volume or 50) + 10))
        response = vi and ("Âm lượng " .. tostring(Music.Volume) .. "%.") or ("Volume " .. tostring(Music.Volume) .. "%.")
    elseif __has(lower, "nho hon", "giam am", "volume down", "nho tieng") then
        Music.SetVolume(math.max(0, (Music.Volume or 50) - 10))
        response = vi and ("Âm lượng " .. tostring(Music.Volume) .. "%.") or ("Volume " .. tostring(Music.Volume) .. "%.")
    elseif seconds and __has(lower, "gio", "timer", "hen") then
        seconds = math.clamp(tonumber(seconds) or 60, 1, 86400)
        startTimer(seconds)
        response = (vi and "Đã đặt hẹn giờ " or "Timer set for ") .. tostring(seconds) .. (vi and " giây." or " seconds.")
    elseif minutes and __has(lower, "gio", "timer", "hen") then
        local total = math.clamp(tonumber(minutes) * 60, 1, 86400)
        startTimer(total)
        response = (vi and "Đã đặt hẹn giờ " or "Timer set for ") .. tostring(minutes) .. (vi and " phút." or " minutes.")
    elseif __has(lower, "mo nhac", "phat nhac", "bat nhac", "play") then
        if not Music.Playing then Music.Toggle() end
        response = vi and "Đã bật nhạc." or "Playing music."
    else
        local wantsSong = __has(lower, "tim", "mo", "phat", "nhac", "bai hat", "nghe", "play", "song")
        local track = Music.Tracks and Music.Tracks[Music.Index]
        local search = _G.xNgotQueueMusicSearch
        if wantsSong and search and not __has(lower, "mo ta", "help", "huong dan") then
            local ok = pcall(search, prompt)
            if ok then
                response = vi and "Đang tìm bài bạn muốn nghe…" or "Looking for that song…"
            end
        end
        if not response and wantsSong and track then
            response = vi and ("Đang phát: " .. tostring(track.Name)) or ("Now playing: " .. tostring(track.Name))
        end
        if not response then
            response = vi
                and "Mình mở/tạm dừng nhạc, chuyển bài, đổi âm lượng, đặt hẹn giờ. Thử: mở nhạc lofi chill, hẹn giờ 90 giây."
                or "I can play/pause music, skip tracks, change volume and set timers. Try: play lofi chill, timer 90."
        end
    end
    Cross.say("cross", response)
    Cross.setMood("happy", 2)
end

local __crossAskBase = Cross.ask
function Cross.ask(prompt)
    prompt = tostring(prompt or "")
    if prompt == "" then return end
    __crossAskBase(prompt)

    local vi = crossPromptIsVi(prompt)
    local nrm = (CrossAIMusic and CrossAIMusic.Util and CrossAIMusic.Util.norm and CrossAIMusic.Util.norm(prompt))
        or string.lower(prompt)
    if nrm:find("script", 1, true) then
        Cross.say("cross", vi
            and "Mình đã bỏ Script Hub — bản này chỉ còn nhạc + trợ lý."
            or "Script Hub was removed — this build only has music + assistant.")
        return
    end
end

do
    local previousExpand = Isl.expand
    Isl.expand = function(page)
        if page == "Cross" then
            local ok = pcall(previousExpand, "Cross")
            pcall(function() Fwd.crossOpen("chat") end)
            return ok
        end
        return previousExpand(page)
    end
    Fwd.islandExpand = Isl.expand
end

function Cross.clearChat()
    table.clear(Cross.Chat)
    Cross.ChatVersion += 1
    Cross.Bubble.Full = ""
    Cross.Bubble.Shown = ""
    Cross.Bubble.Entry = nil
    Cross.Echo = ""
end

function Cross.shutdown()
    Cross.setEnabled(false)
    Cross.clearChat()
end

task.spawn(function()
    -- FILE-MANAGER: khi load script thi nap danh sach NHAC DA TAI truoc.
    -- Khong con tu tim nhac moi "lofi chill" o lan khoi dong nay.
    if Music.Remote and type(Music.Remote.LoadDownloaded) == "function" then
        local ok, err = pcall(Music.Remote.LoadDownloaded)
        if not ok then warn("[xNgotStudio] Music downloaded: " .. tostring(err)) end
    elseif Music.Remote and type(Music.Remote.Load) == "function" then
        local ok, err = pcall(Music.Remote.Load)
        if not ok then warn("[xNgotStudio] Music AI: " .. tostring(err)) end
    end
end)

		local env = type(getgenv) == "function" and getgenv() or _G
		local previous = env.__xNgotStudioFullDynamic
		if previous and type(previous.Destroy) == "function" then pcall(previous.Destroy, previous) end
		State.Ready = true
		blur.Size = 0
		Spr.springIslandY:Set(ISLAND.Top)
		Isl.settleIsland()
		Cross.Lang = Settings.Language
