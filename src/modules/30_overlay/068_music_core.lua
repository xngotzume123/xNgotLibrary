--[[ xngot-studio · src/modules/30_overlay/068_music_core.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.music_core
     role   : Bảng Music: downloadState, Progress, Sync
     source : main 2.txt L6022-6277 · 256 dòng · delta +1
--]]
		    local Music = {
		        Playing = false,
		        Index = 1,
		        Volume = 60,
		        Tempo = 1,
		        Position = 0,
		        Clock = 0,
		        Phrase = 0,
		        Auto = true,
		        ShowIsland = true,
		        Shuffle = false,
		        RepeatOne = false,
		        Fails = 0,
		        Loading = false,
		        Levels = { 0, 0, 0, 0, 0 },
		        Listeners = {},
		    }

		    do
		        local TRACKS = {
		            { Name = "Lo-fi Chill A", Mood = "Lo-fi / Chill", Id = 9043887091, A = rgb(88, 86, 214), B = rgb(191, 90, 242) },
		            { Name = "Relaxed Scene", Mood = "Relaxing", Id = 1848354536, A = rgb(64, 200, 224), B = rgb(10, 132, 255) },
		            { Name = "Chill Jazz", Mood = "Jazz / Lounge", Id = 1845341094, A = rgb(255, 159, 10), B = rgb(255, 55, 95) },
		            { Name = "Soft Music", Mood = "Soft / Ambient", Id = 1837429944, A = rgb(64, 200, 224), B = rgb(48, 209, 88) },
		            { Name = "Piano Bar Jazz", Mood = "Piano / Jazz", Id = 1841979451, A = rgb(191, 90, 242), B = rgb(88, 86, 214) },
		            { Name = "Smooth Vibes", Mood = "Smooth Chill", Id = 9044565954, A = rgb(48, 209, 88), B = rgb(64, 200, 224) },
		            { Name = "Sunday In Bed", Mood = "Lo-fi / Relax", Id = 9047104336, A = rgb(255, 159, 10), B = rgb(191, 90, 242) },
		            { Name = "Light Dreamer", Mood = "Dreamy", Id = 9047107124, A = rgb(10, 132, 255), B = rgb(191, 90, 242) },
		            { Name = "Paradise Falls", Mood = "Cinematic", Id = 1837879082, A = rgb(48, 209, 88), B = rgb(10, 132, 255) },
		            { Name = "Upbeat Electronica", Mood = "Electronic", Id = 1837849285, A = rgb(255, 55, 95), B = rgb(255, 159, 10) },
		        }

		        Music.Tracks = TRACKS

		        local group = new("SoundGroup", { Name = "BoncutiPlaylistGroup", Volume = 1, Parent = SoundService })
		        Music.Reverb = new("ReverbSoundEffect", {
		            DecayTime = 1.5,
		            Density = 0.5,
		            Diffusion = 0.65,
		            DryLevel = -1,
		            WetLevel = -12,
		            Parent = group,
		        })
		        Music.Eq = new("EqualizerSoundEffect", { LowGain = 1, MidGain = 0, HighGain = -1, Parent = group })

		        local currentSound = new("Sound", {
		            Name = "BoncutiPlaylistAudio",
		            SoundId = "rbxassetid://" .. TRACKS[1].Id,
		            Volume = Music.Volume / 100,
		            PlaybackSpeed = Music.Tempo,
		            Looped = false,
		            SoundGroup = group,
		            Parent = SoundService,
		        })

		        local loadToken = 0
		        local function broadcast()
		            for _, listener in ipairs(Music.Listeners) do
		                pcall(listener)
		            end
		        end
		        Music.Broadcast = broadcast

		        local TextWidthCache = {}
		        local function measure(text, size, font)
		            if TextService == nil then return nil end
		            font = font or "Gotham"
		            local key = tostring(size) .. "|" .. tostring(font) .. "|" .. tostring(text)
		            if TextWidthCache[key] ~= nil then return TextWidthCache[key] end
		            local ok, bounds = pcall(function()
		                local enumFont = Enum.Font[font] or Enum.Font.Gotham
		                return TextService:GetTextSize(text, size, enumFont, Vector2.new(4000, 400))
		            end)
		            local width = ok and bounds and bounds.X or nil
		            TextWidthCache[key] = width
		            return width
		        end

		        local function fitText(value, box, fallbackWidth, font, sizeOverride)
		            local raw = tostring(value or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
		            if raw == "" then return "" end
		            local width = fallbackWidth
		            local size = sizeOverride or 12
		            if box ~= nil then
		                local okSize, current = pcall(function() return box.TextSize end)
		                if okSize and type(current) == "number" and current > 0 then size = current end
		                local okAbs, abs = pcall(function() return box.AbsoluteSize.X end)
		                if okAbs and type(abs) == "number" and abs > 24 then width = abs - 6 end
		            end
		            width = math.max(tonumber(width) or 120, 24)
		            local natural = measure(raw, size, font)
		            if natural and natural <= width then return raw end
		            -- FIX(dynamic-island-utf8): cat theo KY TU utf8, khong cat theo byte (tranh lam hong dau tieng Viet khi rut gon ten bai)
		            local charCount = utf8.len(raw) or #raw
		            local function prefixChars(count)
		                if count >= charCount then return raw end
		                if count <= 0 then return "" end
		                local okPos, pos = pcall(function() return utf8.offset(raw, count + 1) end)
		                if okPos and type(pos) == "number" then return raw:sub(1, pos - 1) end
		                return raw:sub(1, count)
		            end
		            local limit = charCount
		            while limit > 2 do
		                local cut = prefixChars(limit - 1):gsub("%s+$", "") .. "…"
		                local span = measure(cut, size, font)
		                if span and span <= width then return cut end
		                limit = limit - 1
		            end

		            local budget = math.max(math.floor(width / 7), 6)
		            if charCount > budget then return prefixChars(budget - 1):gsub("%s+$", "") .. "…" end
		            return raw
		        end

		        Isl.fitText = fitText
		        Isl.measureText = measure

		        local function applyMedia(track, state)
		            track = track or {}
		            local downloading = state == "download"
		            Media.ArtGradient.Color = ColorSequence.new(track.A or Static.Blue, track.B or Static.Purple)
		            Media.Title.Text = fitText(track.Name or "Đang tải nhạc", Media.Title, 131, "GothamMedium")
		            Media.Sub.Text = fitText(downloading and "Đang tải mp3…" or (track.Mood or ""), Media.Sub, 131, "Gotham")
		            for _, bar in ipairs(Media.Bars) do
		                bar.BackgroundColor3 = track.B or Static.Purple
		                bar.Visible = not downloading
		            end
		            if Media.BarsFrame then
		                Media.BarsFrame.Visible = not downloading
		            end
		            if Media.Art then
		                Media.Art.Visible = not downloading
		            end
		            if Media.DlFrame then
		                Media.DlFrame.Visible = downloading
		            end
		            if Media.DlTrack then
		                Media.DlTrack.Visible = downloading
		            end
		            Media.IsDownload = downloading

		            if Media.Cover then
		                local asset = track.CoverAsset
		                if type(asset) == "string" and asset ~= "" and not downloading then
		                    Media.Cover.Image = asset
		                    Media.Cover.Visible = true
		                    Media.Letter.Visible = false
		                else
		                    Media.Cover.Image = ""
		                    Media.Cover.Visible = false
		                    Media.Letter.Visible = true
		                    if not downloading and track and CrossAIMusic and type(CrossAIMusic.thumbAsset) == "function" then
		                        local wanted = tostring(track.Id or track.Url or track.Name or "")
		                        task.spawn(function()
		                            local okCover, cover = pcall(CrossAIMusic.thumbAsset, track)
		                            if not okCover or type(cover) ~= "string" or cover == "" then return end
		                            track.CoverAsset = cover
		                            local cur = TRACKS[Music.Index]
		                            if cur and tostring(cur.Id or cur.Url or cur.Name or "") == wanted then
		                                Media.Cover.Image = cover
		                                Media.Cover.Visible = true
		                                Media.Letter.Visible = false
		                            end
		                        end)
		                    end
		                end
		            end
		        end

		        function Music.setDownloadState(percent, title)
		            local track = TRACKS[Music.Index] or {}
		            local alpha = math.clamp(tonumber(percent) or 0, 0, 1)
		            local shown = {
		                A = track.A or Static.Blue,
		                B = track.B or Static.Purple,
		                Name = title or track.Name,
		                Mood = "Đang tải mp3…",
		            }
		            applyMedia(shown, "download")
		            if Media.DlFill then
		                Media.DlFill.Size = UDim2.new(alpha, 0, 1, 0)
		            end
		            if Media.Title then
		                Media.Title.Text = fitText(alpha >= 1 and "Đang phát…" or shown.Name, Media.Title, 131, "GothamMedium")
		            end
		            if Media.DlIcon then
		                Media.DlIcon.Text = alpha >= 1 and "✓" or "↓"
		            end
		        end

		        function Music.Progress()
		            local length = currentSound.TimeLength
		            if length <= 0 then
		                return 0
		            end
		            return math.clamp(currentSound.TimePosition / length, 0, 1)
		        end

		        function Music.Sync()
		            local track = TRACKS[Music.Index]
		            Music.Position = currentSound.TimePosition
		            if Music.Playing and Music.ShowIsland then
		                Activities.Music = {
		                    Title = track.Name,
		                    Color = track.B,
		                    Media = true,
		                    Short = function()
		                        return "♪"
		                    end,
		                    Value = function()
		                        return track.Name
		                    end,
		                    Ring = Music.Progress,
		                    RingMode = "fill",
		                }
		            else
		                Activities.Music = nil
		            end
		            applyMedia(track)
		            refreshActivity()
		        end

		        local function waitAndPlay(token, id)
		            task.spawn(function()
		                local deadline = os.clock() + 12
		                while gui.Parent and token == loadToken and currentSound.SoundId == id and not currentSound.IsLoaded and os.clock() < deadline do
		                    task.wait(0.1)
		                end
		                if token ~= loadToken or currentSound.SoundId ~= id or not gui.Parent then
		                    return
		                end
		                if currentSound.IsLoaded then
		                    currentSound.Volume = 0
		                    currentSound.PlaybackSpeed = Music.Tempo
		                    currentSound:Play()
		                    tween(currentSound, 0.8, { Volume = Music.Volume / 100 }, Enum.EasingStyle.Sine)
		                    Music.Playing = true
		                    Music.Fails = 0
		                    Music.Sync()
		                    broadcast()
		                else
		                    Music.Playing = false
		                    Music.Fails = Music.Fails + 1
		                    Music.Sync()
		                    broadcast()
		                    notify("Không thể tải nhạc", "Âm thanh này có thể bị giới hạn quyền truy cập trong trải nghiệm hiện tại.", "warn", 3)
		                    if Music.Auto and Music.Fails < 3 then
		                        task.wait(0.8)
		                        if token == loadToken and gui.Parent then
		                            Music.Next(1)
		                        end
		                    end
		                end
		            end)
		        end

