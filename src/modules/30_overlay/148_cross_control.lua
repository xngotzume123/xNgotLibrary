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
        Cross.Pending = nil
        Cross.Clarify = nil
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
                        if Music.Remote then Music.Remote.Plan = plan end
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
do
    local upper = {
            ["À"]="à",["Á"]="á",["Ạ"]="ạ",["Ả"]="ả",["Ã"]="ã",["Â"]="â",["Ầ"]="ầ",["Ấ"]="ấ",["Ậ"]="ậ",["Ẩ"]="ẩ",["Ẫ"]="ẫ",["Ă"]="ă",["Ằ"]="ằ",["Ắ"]="ắ",["Ặ"]="ặ",["Ẳ"]="ẳ",["Ẵ"]="ẵ",
            ["È"]="è",["É"]="é",["Ẹ"]="ẹ",["Ẻ"]="ẻ",["Ẽ"]="ẽ",["Ê"]="ê",["Ề"]="ề",["Ế"]="ế",["Ệ"]="ệ",["Ể"]="ể",["Ễ"]="ễ",
            ["Ì"]="ì",["Í"]="í",["Ị"]="ị",["Ỉ"]="ỉ",["Ĩ"]="ĩ",["Ò"]="ò",["Ó"]="ó",["Ọ"]="ọ",["Ỏ"]="ỏ",["Õ"]="õ",["Ô"]="ô",["Ồ"]="ồ",["Ố"]="ố",["Ộ"]="ộ",["Ổ"]="ổ",["Ỗ"]="ỗ",["Ơ"]="ơ",["Ờ"]="ờ",["Ớ"]="ớ",["Ợ"]="ợ",["Ở"]="ở",["Ỡ"]="ỡ",
            ["Ù"]="ù",["Ú"]="ú",["Ụ"]="ụ",["Ủ"]="ủ",["Ũ"]="ũ",["Ư"]="ư",["Ừ"]="ừ",["Ứ"]="ứ",["Ự"]="ự",["Ử"]="ử",["Ữ"]="ữ",["Ỳ"]="ỳ",["Ý"]="ý",["Ỵ"]="ỵ",["Ỷ"]="ỷ",["Ỹ"]="ỹ",["Đ"]="đ",
    }
    local function normalize(text)
        text = tostring(text or "")
        for k,v in pairs(upper) do text = text:gsub(k,v) end
        text = __askNorm(text):gsub("[^%w]+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        return text
    end
    local function hasWord(text, word)
        return (" " .. text .. " "):find(" " .. word .. " ", 1, true) ~= nil
    end
    local function alive(entry)
        if type(entry) ~= "table" or type(entry.Object) ~= "table" then return false end
        local ok, result = pcall(function() return entry.Object._AIInstance:IsDescendantOf(entry.Root) end)
        return ok and result == true
    end
    local function locked(entry)
        local o = entry.Object
        if type(o._AIIsLocked) == "function" then return o:_AIIsLocked() end
        return o.Locked == true
    end
    local function controls()
        local entries = __hostWindow and __hostWindow._AIControls
        if type(entries) ~= "table" then return {} end
        for i = #entries, 1, -1 do if not alive(entries[i]) then table.remove(entries, i) end end
        return entries
    end
    local function aliases(text)
        for _, pair in ipairs({{"toc do", "speed"}, {"che do", "mode"}, {"am luong", "volume"}, {"am thanh", "sound"}, {"tu dong", "auto"}, {"mau", "color"}}) do
            text = text:gsub("%f[%w]" .. pair[1] .. "%f[%W]", pair[2])
        end
        return text
    end
    local function choose(text)
        text = aliases(text)
        local best, matches = -1, {}
        for _, entry in ipairs(controls()) do
            local title = aliases(normalize(entry.Title))
            local short = title:gsub("^enable%s+", ""):gsub("^show%s+", ""):gsub("^hien%s+", "")
            local score = 0
            if #title >= 2 and hasWord(text, title) then score = #title + 20
            elseif #short >= 2 and hasWord(text, short) then score = #short + 10 end
            if score > 0 then
                if hasWord(text, aliases(normalize(entry.Tab))) then score += 100 end
                if score > best then best, matches = score, {entry}
                elseif score == best then table.insert(matches, entry) end
            end
        end
        return matches
    end
    local function reply(text)
        Cross.say("cross", text)
        Cross.setMood("happy", 2)
    end
    local function quoted(text)
        return text:match('"(.-)"') or text:match("'(.-)'")
    end
    local function proposed(entry, text, raw, teaching)
        local kind, o = entry.Kind, entry.Object
        -- Interpret verbs outside the control title, e.g. "turn off Enable Dynamic Island".
        local actionText = " " .. text .. " "
        local title = normalize(entry.Title)
        local short = title:gsub("^enable%s+", ""):gsub("^show%s+", ""):gsub("^hien%s+", "")
        local at = actionText:find(" " .. title .. " ", 1, true)
        if at then actionText = actionText:sub(1, at) .. actionText:sub(at + #title + 1)
        elseif short ~= title then
            at = actionText:find(" " .. short .. " ", 1, true)
            if at then actionText = actionText:sub(1, at) .. actionText:sub(at + #short + 1) end
        end
        if hasWord(actionText,"dung bat") or hasWord(actionText,"khong bat") or hasWord(actionText,"do not enable") or hasWord(actionText,"dont enable") then
            return nil, "Lệnh phủ định không rõ; hãy nói rõ bật hay tắt."
        end
        local on = hasWord(actionText,"bat") or hasWord(actionText,"mo") or hasWord(actionText,"enable") or hasWord(actionText,"turn on") or hasWord(actionText,"open")
        local off = hasWord(actionText,"tat") or hasWord(actionText,"dong") or hasWord(actionText,"disable") or hasWord(actionText,"turn off") or hasWord(actionText,"close")
        if on and off then return nil, "Lệnh có cả bật và tắt; hãy nói rõ một hành động." end
        if kind == "Toggle" or kind == "Section" then
            if teaching and not on and not off then return nil, "Khi dạy, hãy ghi rõ bật hoặc tắt." end
            local desired = on and true or (off and false or not (o.State == true))
            if off then desired = false end
            if not teaching and (o.State == true) == desired then return nil, "Control đã ở trạng thái yêu cầu." end
            return {Value=desired, ExplicitDirection=on or off, Verb=desired and "bật/mở" or "tắt/đóng"}
        elseif kind == "Button" then
            return {Verb="bấm nút", Warning="Nút có thể chạy callback hoặc thay đổi dữ liệu."}
        elseif kind == "Slider" then
            local number
            for n in raw:gmatch("%-?%d+%.?%d*") do number=tonumber(n) end
            if not number then return nil, "Hãy nhập số, ví dụ: đặt " .. entry.Title .. " 50." end
            if number < entry.Min or number > entry.Max then return nil, "Giá trị phải trong khoảng " .. entry.Min .. "–" .. entry.Max .. "." end
            number = math.clamp(math.round(number / entry.Step) * entry.Step, entry.Min, entry.Max)
            return {Value=number, Verb="đặt thành " .. tostring(number)}
        elseif kind == "Dropdown" then
            local value = quoted(raw)
            local choices = {}
            for _, choice in ipairs(o.Values or {}) do
                if type(choice) == "string" and ((value and normalize(choice) == normalize(value)) or (not value and #normalize(choice)>=2 and hasWord(text,normalize(choice)))) then table.insert(choices, choice) end
            end
            if #choices ~= 1 then return nil, "Hãy ghi rõ một lựa chọn trong dấu ngoặc kép. Các lựa chọn: " .. table.concat(o.Values or {}, ", ") end
            local picked = choices[1]
            local remove = hasWord(text,"bo") or hasWord(text,"remove") or hasWord(text,"deselect")
            if o.Multi then
                local selected = type(o.Value) == "table" and table.find(o.Value,picked) ~= nil
                if not teaching and (remove and not selected or not remove and selected) then return nil, "Lựa chọn này đã ở trạng thái yêu cầu." end
                if not teaching and remove and not o.AllowNone and #o.Value <= 1 then return nil, "Dropdown này không cho bỏ lựa chọn cuối cùng." end
            end
            return {Value=picked, Remove=remove, Verb=(remove and "bỏ chọn " or "chọn ") .. picked}
        elseif kind == "Colorpicker" then
            local hex = raw:match("#(%x%x%x%x%x%x)")
            if not hex then return nil, "Hãy nhập màu dạng #RRGGBB, ví dụ #66AAFF." end
            return {Value="#" .. hex, Verb="đổi màu thành #" .. hex}
        elseif kind == "Input" or kind == "Paragraph" or kind == "Code" or kind == "InfoNguyenNhat" or kind == "Discord" then
            local value = quoted(raw)
            if not value then return nil, "Hãy đặt nội dung mới trong dấu ngoặc kép." end
            if kind == "Discord" then
                local code = value:match("discord%.gg/([%w%-_]+)") or value:match("discord%.com/invite/([%w%-_]+)")
                if not code then return nil, "Hãy cung cấp link mời discord.gg hoặc discord.com/invite hợp lệ." end
                return {Value=value, InviteCode=code, Verb="đổi link mời thành " .. value}
            end
            return {Value=value, Verb=(kind == "InfoNguyenNhat" and "đổi bio thành " or "đổi nội dung thành ") .. '"' .. value .. '"'}
        end
        return nil, "Control này chưa hỗ trợ thao tác."
    end
    local function execute(p)
        local entry, o = p.Entry, p.Entry.Object
        if Cross.Perm and Cross.Perm.Ui == false then return false, "Quyền điều khiển UI của Cross đang tắt." end
        if not alive(entry) then return false, "Control không còn tồn tại." end
        if entry.Title ~= p.Title or entry.Kind ~= p.Kind then return false, "Control đã đổi tên; hãy yêu cầu lại." end
        if locked(entry) then return false, "Control đang bị khóa." end
        local k = p.Kind
        if k == "Toggle" then o:Set(p.Value)
        elseif k == "Section" then o:SetOpen(p.Value)
        elseif k == "Button" then if o:_AIActivate() == false then return false,"Nút đang bị khóa." end
        elseif k == "Slider" then if o:Set(p.Value) == nil then return false,"Giá trị không hợp lệ." end
        elseif k == "Dropdown" then
            if not table.find(o.Values or {}, p.Value) then return false,"Danh sách đã đổi; hãy yêu cầu lại." end
            if o.Multi then
                local selected = type(o.Value) == "table" and table.find(o.Value,p.Value) ~= nil
                if p.Remove and not selected or not p.Remove and selected then return false,"Trạng thái đã đổi; hãy yêu cầu lại." end
                if p.Remove and not o.AllowNone and #o.Value <= 1 then return false,"Không thể bỏ mục cuối cùng." end
            end
            if o:Select(p.Value) == nil then return false,"Không chọn được mục này." end
        elseif k == "Colorpicker" or k == "Input" then o:Set(p.Value)
        elseif k == "Paragraph" then o:SetDesc(p.Value)
        elseif k == "Code" then o:SetCode(p.Value)
        elseif k == "InfoNguyenNhat" then o:SetBio(p.Value)
        elseif k == "Discord" then o:SetInvite(p.Value, p.InviteCode)
        else return false,"Control không hỗ trợ." end
        return true
    end
    -- Learn only short, non-sensitive phrases. Arbitrary input/code values are never auto-saved.
    local function safePhrase(raw)
        raw = tostring(raw or "")
        if #raw > 120 or raw:find("%d") or raw:find("[@/#:%._\"'\\]") then return nil end
        local text = normalize(raw)
        if #text < 4 or #text > 100 then return nil end
        local n=0; for _ in text:gmatch("%S+") do n+=1 end
        if n < 2 or n > 7 then return nil end
        for _, forbidden in ipairs({"pass", "password", "mat khau", "secret", "token", "key", "api", "email", "gmail", "tai khoan", "phone", "sdt", "code", "cai do", "cai nay", "that", "this"}) do
            if text:find(forbidden,1,true) then return nil end
        end
        return text
    end
    local function direction(text)
        local on = hasWord(text,"bat") or hasWord(text,"mo") or hasWord(text,"enable") or hasWord(text,"turn on") or hasWord(text,"open")
        local off = hasWord(text,"tat") or hasWord(text,"dong") or hasWord(text,"disable") or hasWord(text,"turn off") or hasWord(text,"close")
        local press = hasWord(text,"bam") or hasWord(text,"nhan") or hasWord(text,"click") or hasWord(text,"press")
        if (on and off) or (press and (on or off)) then return nil end
        return on and "on" or (off and "off" or (press and "press" or nil))
    end
    -- Runtime context is read on request and never added to learned command storage.
    local contextPlace, contextPlaceName
    local function contextAnswer(text)
        local function any(...)
            for _, word in ipairs({...}) do if hasWord(text, word) then return true end end
            return false
        end
        if any("bat", "tat", "bam", "nhan", "doi", "dat", "enable", "disable", "click", "press", "set", "change") then return nil end
        local playerInfo = any("thong tin nguoi choi", "thong tin tai khoan", "player info", "my profile")
        local gameInfo = any("thong tin game", "thong tin tro choi", "thong tin server", "game info", "server info", "session info")
        local playerName = playerInfo or any("ten toi", "toi ten", "ten cua toi", "ten minh", "minh ten", "ten cua minh", "ten nguoi choi", "ten nguoi dung", "username", "user name", "my name", "who am i", "toi la ai", "minh la ai", "what is my name")
        local displayName = playerInfo or any("ten hien thi", "display name", "displayname")
        local userId = playerInfo or any("userid", "user id", "id nguoi choi", "id nguoi dung", "id cua toi", "my user id", "my userid")
        local placeId = gameInfo or any("placeid", "place id", "id place", "id dia diem")
        local jobId = gameInfo or any("jobid", "job id", "server id", "id server", "id may chu", "id phien")
        local universeId = gameInfo or any("gameid", "game id", "universeid", "universe id", "id game", "id universe", "id tro choi")
        local playerCount = gameInfo or any("so nguoi choi", "so luong nguoi choi", "bao nhieu nguoi", "player count", "players online", "server players", "max players")
        local gameName = gameInfo or any("ten game", "game ten", "game nay ten", "ten cua game", "ten tro choi", "tro choi nay ten", "game name", "place name", "ten place", "ten dia diem", "what game am i playing", "what game is this")
        if not (playerName or displayName or userId or placeId or jobId or universeId or gameName or playerCount) then return nil end
        local english = any("what", "who", "my", "player info", "game info", "server info", "session info", "game name", "place name", "display name")
            or any("player count", "players online", "server players", "max players")
            or ((Settings and Settings.Language == "en") and not any("ten", "toi", "minh", "nguoi", "thong tin", "tro choi", "may chu"))
        local missing = english and "unavailable" or "không lấy được"
        local rows = {}
        local function clean(value, allowZero)
            if value == nil then return missing end
            value = tostring(value):gsub("[%c]", " "):gsub("^%s+", ""):gsub("%s+$", "")
            if value == "" or (value == "0" and not allowZero) then return missing end
            return value:sub(1, 180)
        end
        local function append(label, value, allowZero) rows[#rows+1] = label .. ": " .. clean(value, allowZero) end
        if playerName then append(english and "Username" or "Tên người chơi (username)", player and player.Name) end
        if displayName or playerName then append(english and "Display name" or "Tên hiển thị", player and player.DisplayName) end
        if userId then append("UserId", player and player.UserId) end
        local id, job, universe
        pcall(function() id=game.PlaceId; job=game.JobId; universe=game.GameId end)
        if gameName then
            local name
            if type(id)=="number" and id > 0 then
                if contextPlace==id and contextPlaceName then name=contextPlaceName else
                    local ok, product = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(id, Enum.InfoType.Asset) end)
                    if ok and type(product)=="table" and type(product.Name)=="string" and product.Name:match("%S") then
                        name=product.Name; contextPlace=id; contextPlaceName=name
                    end
                end
            end
            append(english and "Current place name" or "Tên game/địa điểm hiện tại", name)
        end
        if placeId then append("PlaceId", id) end
        if universeId then append("GameId (UniverseId)", universe) end
        if jobId then append("JobId", job) end
        if playerCount then
            local current, maximum
            pcall(function()
                local service=game:GetService("Players")
                current=#service:GetPlayers(); maximum=service.MaxPlayers
            end)
            append(english and "Players in server" or "Người chơi trong server", current, true)
            append(english and "Max players" or "Số người tối đa", maximum)
        end
        return table.concat(rows, " · ")
    end
    local function learnConfirmed(p)
        local learn = Cross.Learning
        if not learn then return end
        learn.Record(p.Entry)
        local kind = p.Kind
        if kind ~= "Toggle" and kind ~= "Section" and kind ~= "Button" then return end
        local candidate = p.AutoPhrase
        if not candidate then return end
        if (kind == "Toggle" or kind == "Section") and not p.ExplicitDirection then return end
        if kind == "Button" and not p.PressExplicit then return end
        local action = kind == "Button" and "bấm " or (p.Value and "bật " or "tắt ")
        local e = p.Entry
        local ok, reason = learn.Put({key=candidate,phrase=candidate,command=action .. e.Tab .. " " .. e.Title,tab=e.Tab,title=e.Title,kind=kind})
        if not ok then return " Chưa ghi nhớ câu này: " .. tostring(reason) end
    end
    local function offer(entry, text, raw, learned, clarification)
        if Cross.Perm and Cross.Perm.Ui == false then reply("Quyền điều khiển UI của Cross đang tắt."); return end
        if locked(entry) then reply("Control đang bị khóa: " .. entry.Title); return end
        local action, problem = proposed(entry,text,raw)
        if not action then reply(problem); return end
        action.Entry, action.Title, action.Kind, action.Expires = entry, entry.Title, entry.Kind, os.clock()+60
        local rawDirection = direction(text)
        action.PressExplicit = rawDirection == "press"
        if not learned then
            if clarification then
                local desired = (entry.Kind == "Button" and "press") or (action.Value == true and "on" or "off")
                if clarification.Direction == desired then action.AutoPhrase = clarification.Phrase end
            else
                action.AutoPhrase = safePhrase(raw)
            end
        end
        Cross.Pending = action
        reply((learned and "Theo câu đã học: " or "") .. "Bạn có muốn " .. action.Verb .. " — " .. entry.Title .. " (" .. entry.Tab .. ") không? " .. (action.Warning or "") .. " Trả lời Có/Yes hoặc Không/Cancel trong 60 giây.")
    end
    function Cross.Teach(phrase, command)
        if not Cross.Learning then return false, "Learning is not available." end
        if Cross.Pending then return false, "Hãy xử lý hoặc hủy yêu cầu đang chờ trước." end
        if Cross.Perm and Cross.Perm.Ui == false then return false, "Quyền điều khiển UI của Cross đang tắt." end
        phrase = tostring(phrase or ""):gsub("^%s+", ""):gsub("%s+$", "")
        command = tostring(command or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local key = normalize(phrase)
        if #key < 2 or #key > 120 or #phrase > 120 or #command == 0 or #command > 300 then return false, "Câu dạy hoặc lệnh không hợp lệ (tối đa 120/300 byte)." end
        local reserved={co=true,yes=true,ok=true,["dong y"]=true,["xac nhan"]=true,confirm=true,["co bat"]=true,["bat di"]=true,["co dong y"]=true,
            khong=true,no=true,huy=true,cancel=true,thoi=true,["khong bat"]=true,["khong dong y"]=true,
            ["danh sach chuc nang"]=true,["liet ke chuc nang"]=true,["list controls"]=true,["list features"]=true,["cac chuc nang"]=true,
            ["goi y"]=true,["so thich"]=true,preferences=true,suggestions=true,["danh sach da hoc"]=true,["learned phrases"]=true}
        if reserved[key] or key:match("^list controls %d+$") or key:match("^danh sach chuc nang %d+$") or key:match("^learned phrases %d+$") or key:match("^danh sach da hoc %d+$") then return false, "Câu này được dành cho lệnh hệ thống; hãy chọn câu khác." end
        local matches=choose(normalize(command))
        if #matches ~= 1 then return false, "Lệnh cần chỉ đúng một control; hãy ghi đủ tên tab và tên control." end
        local e=matches[1]
        local action,problem=proposed(e,normalize(command),command,true)
        if not action then return false, problem end
        local ok, status = Cross.Learning.Put({key=key,phrase=phrase,command=command,tab=e.Tab,title=e.Title,kind=e.Kind})
        if not ok then return false,status end
        return true, "Đã dạy: " .. phrase .. " → " .. action.Verb .. " — " .. e.Title .. " (" .. e.Tab .. "). " .. status
    end
    function Cross.ForgetPhrase(phrase)
        if not Cross.Learning then return false, "Learning is not available." end
        local ok, message = Cross.Learning.Forget(normalize(phrase))
        if ok then Cross.Pending = nil end
        return ok, message
    end
    function Cross.ask(prompt)
        prompt = tostring(prompt or "")
        if prompt == "" then return end
        local text = normalize(prompt)
        local yes = text == "co" or text == "yes" or text == "ok" or text == "dong y" or text == "xac nhan" or text == "confirm" or text == "co bat" or text == "bat di" or text == "co dong y"
        local no = text == "khong" or text == "no" or text == "huy" or text == "cancel" or text == "thoi" or text == "khong bat" or text == "khong dong y"
        if Cross.Pending then
            Cross.say("user", prompt)
            local p = Cross.Pending
            if os.clock() > p.Expires then Cross.Pending = nil; reply("Yêu cầu đã hết hạn. Hãy ra lệnh lại."); return end
            if no then Cross.Pending = nil; reply("Đã hủy, không thay đổi gì."); return end
            if not yes then reply("Đang chờ xác nhận. Trả lời Có/Yes hoặc Không/Cancel."); return end
            Cross.Pending = nil
            local ok, success, reason = pcall(execute, p)
            if not ok then reply("Lệnh gặp lỗi; callback có thể đã chạy một phần: " .. tostring(success)); return end
            if not success then reply(reason or "Không thực hiện được."); return end
            local learnNote = learnConfirmed(p) or ""
            local state = Cross.Learning and Cross.Learning.State()
            local notice = state and not state.Persistent and " Ghi nhớ chỉ trong phiên: không lưu được JSON." or ""
            reply("Đã thực hiện: " .. p.Verb .. " — " .. p.Title .. " (" .. p.Entry.Tab .. ")." .. learnNote .. notice)
            return
        end
        if Cross.Clarify and os.clock() > Cross.Clarify.Expires then Cross.Clarify = nil end
        if yes or no then
            Cross.say("user",prompt)
            if Cross.Clarify then
                if no then Cross.Clarify=nil; reply("Đã hủy yêu cầu làm rõ.")
                else reply("Hãy ghi tên chức năng và hành động cụ thể, hoặc trả lời Không để hủy.") end
            else reply("Không có yêu cầu nào đang chờ xác nhận.") end
            return
        end
        local isContext = text:find("ten",1,true) or text:find("name",1,true) or text:find("id",1,true)
            or text:find("info",1,true) or text:find("thong tin",1,true) or text:find("nguoi choi",1,true)
            or text:find("bao nhieu nguoi",1,true) or text:find("players",1,true) or text:find("player count",1,true) or text == "toi la ai" or text == "minh la ai" or text == "who am i" or text == "what game is this" or text == "what game am i playing"
        if isContext then
            local answer = contextAnswer(text)
            if answer then
                Cross.say("user", prompt)
                if not Cross.Enabled then Cross.setEnabled(true) end
                reply(answer)
                return
            end
        end
        if text == "goi y" or text == "so thich" or text == "preferences" or text == "suggestions" then
            Cross.say("user",prompt)
            if Cross.Perm and Cross.Perm.Ui == false then reply("Quyền điều khiển UI của Cross đang tắt."); return end
            local preferences = Cross.Learning and Cross.Learning.Preferences() or {}
            local names={}
            for i=1,math.min(#preferences,5) do local x=preferences[i]; table.insert(names,x.tab .. ": " .. x.title .. " (" .. x.count .. ")") end
            reply(#names == 0 and "Chưa có chức năng thường dùng được ghi nhận. Dùng và xác nhận một chức năng để bắt đầu." or ("Bạn thường dùng: " .. table.concat(names,"; ") .. ". Hãy ra lệnh nếu muốn dùng; vẫn cần xác nhận."))
            return
        end
        local learnedPage = text:match("^danh sach da hoc ?(%d*)$") or text:match("^learned phrases ?(%d*)$")
        if learnedPage ~= nil then
            Cross.say("user",prompt)
            if Cross.Perm and Cross.Perm.Ui == false then reply("Quyền điều khiển UI của Cross đang tắt."); return end
            local taught = Cross.Learning and Cross.Learning.List() or {}
            local names={}
            local pages=math.max(1,math.ceil(#taught/10)); local page=math.clamp(tonumber(learnedPage) or 1,1,pages)
            for i=(page-1)*10+1,math.min(#taught,page*10) do table.insert(names,taught[i].phrase .. " → " .. taught[i].command) end
            reply(#names == 0 and "Chưa có câu lệnh nào được dạy." or ("Câu đã học " .. page .. "/" .. pages .. ": " .. table.concat(names,"; ") .. (pages>1 and ". Dùng 'danh sách đã học " .. math.min(page+1,pages) .. "' để xem tiếp." or "")))
            return
        end
        local learned = Cross.Learning and Cross.Learning.Find(text)
        if learned then
            Cross.say("user",prompt)
            if not Cross.Enabled then Cross.setEnabled(true) end
            local matched={}
            for _, e in ipairs(controls()) do
                if e.Tab == learned.tab and e.Title == learned.title and e.Kind == learned.kind then table.insert(matched,e) end
            end
            if #matched ~= 1 then reply("Control đã học không còn hoặc bị trùng. Hãy yêu cầu lại bằng tên và tab hiện tại."); return end
            Cross.Clarify = nil
            offer(matched[1], normalize(learned.command), learned.command, true)
            return
        end
        local listPage = text:match("^danh sach chuc nang ?(%d*)$") or text:match("^liet ke chuc nang ?(%d*)$")
            or text:match("^list controls ?(%d*)$") or text:match("^list features ?(%d*)$")
        if text == "cac chuc nang" then listPage = "" end
        if listPage ~= nil then
            Cross.say("user",prompt)
            if Cross.Perm and Cross.Perm.Ui == false then reply("Quyền điều khiển UI của Cross đang tắt."); return end
            local entries, names = controls(), {}
            local pages = math.max(1, math.ceil(#entries / 15))
            local page = math.clamp(tonumber(listPage) or 1, 1, pages)
            for i = (page - 1)*15 + 1, math.min(#entries,page*15) do
                local e=entries[i]; table.insert(names, e.Tab .. ": " .. e.Title .. " [" .. e.Kind .. "]")
            end
            reply(#entries == 0 and "Chưa tìm thấy control nào trong cửa sổ xNgot." or ("Control " .. page .. "/" .. pages .. ": " .. table.concat(names,"; ") .. (pages > 1 and ". Dùng 'danh sách chức năng " .. math.min(page+1,pages) .. "' để xem tiếp." or "")))
            return
        end
        local matches = choose(text)
        if #matches == 0 then
            if Cross.Clarify then
                Cross.say("user",prompt)
                reply("Mình vẫn chưa tìm thấy control. Hãy ghi tên tab, tên chức năng và bật/tắt, hoặc trả lời Không để hủy.")
                return
            end
            local intent = direction(text)
            local knownMusic = hasWord(text,"nhac") or hasWord(text,"music") or hasWord(text,"song") or hasWord(text,"bai") or hasWord(text,"timer") or hasWord(text,"hen gio")
            if intent and not knownMusic and #controls() > 0 and not (Cross.Perm and Cross.Perm.Ui == false) then
                Cross.say("user",prompt)
                if not Cross.Enabled then Cross.setEnabled(true) end
                Cross.Clarify = {Phrase=safePhrase(prompt), Direction=intent, Expires=os.clock()+60}
                reply("Mình chưa rõ chức năng đó. Hãy nói rõ tên tab, tên chức năng và hành động; trả lời Không để hủy.")
                return
            end
            return __crossAskBase(prompt)
        end
        -- Preserve the existing play-music command instead of treating it as opening the Music section.
        if not Cross.Clarify and #matches == 1 and matches[1].Kind == "Section" and normalize(matches[1].Title) == "music"
            and not hasWord(text, "section") and not hasWord(text, "muc")
            and (hasWord(text, "nhac") or hasWord(text, "music"))
            and (hasWord(text, "play") or hasWord(text, "phat") or hasWord(text, "nghe") or hasWord(text, "mo") or hasWord(text, "bat")) then
            return __crossAskBase(prompt)
        end
        Cross.say("user",prompt)
        if not Cross.Enabled then Cross.setEnabled(true) end
        if #matches > 1 then
            local names={}; for _,e in ipairs(matches) do table.insert(names,e.Tab .. ": " .. e.Title) end
            reply("Có nhiều control trùng tên: " .. table.concat(names,"; ") .. ". Hãy ghi thêm tên tab."); return
        end
        local clarification = Cross.Clarify
        Cross.Clarify = nil
        offer(matches[1],text,prompt,false,clarification)
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
    Cross.Pending = nil
    Cross.Clarify = nil
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
