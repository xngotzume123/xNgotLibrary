--[[ xngot-studio · src/modules/30_overlay/152_api.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.api
     role   : API công khai của island: Notify/Music*/Ai*/Expand/State/Destroy
     source : main 2.txt L10785-11080 · 296 dòng · delta -1
--]]
		local API = {Version="3.0.0", Enabled=true, Settings=Settings, OriginalUI=true, Root=gui}
		function API:Notify(title, message, kind, duration)
		    if not self.Enabled then return false end
		    notify(tostring(title or "xNgotStudio"),tostring(message or ""),kind or "info",duration or Settings.Duration,true)
		    return true
		end
		local gameplayActivityGeneration = 0
		function API:GameplayActivity(title, message, duration, kind)
		    if not self.Enabled then return false end
		    gameplayActivityGeneration += 1
		    local generation = gameplayActivityGeneration
		    local text = tostring(message or "")
		    local shade = kind == "success" and Static.Green or Static.Blue
		    Activities.Gameplay = {
		        Title = tostring(title or "Auto Farm"),
		        Color = shade,
		        Value = function() return text end,
		        Short = function() return text end,
		    }
		    refreshActivity()
		    task.delay(math.clamp(tonumber(duration) or 11, 3, 30), function()
		        if gameplayActivityGeneration ~= generation then return end
		        Activities.Gameplay = nil
		        if gui.Parent then refreshActivity() end
		    end)
		    return true
		end
		function API:Enable(on)
		    self.Enabled = on and true or false
		    gui.Visible = self.Enabled and (not __hostWindow or __hostWindow.__IslandReady == true)
		    Ring.Holder.Visible = self.Enabled
		    if not self.Enabled then
		        if Isl.collapse then Isl.collapse(true,true) end
		    else
		        Isl.settleIsland()
		    end
		end
		function API:Set(name,value)
		    if name == "Fps" then setFpsActivity(value and true or false)
		    elseif name == "Ping" then setPingActivity(value and true or false)
		    elseif name == "Clock" then setClockActivity(value and true or false)
		    elseif name == "Language" then
		        Settings.Language = "en"  
		        Cross.Lang = "en"
		        Fwd.applyLanguage()
		        Fwd.applyLanguage()
		    elseif Settings[name] ~= nil then
		        Settings[name] = value
		        if name == "Ring" then
		            if not value then Ring.ringHide() else Isl.settleIsland() end
		        elseif name == "Split" then
		            if Fwd.islandSync then Fwd.islandSync() end
		        elseif name == "Expand" and not value then
		            if Isl.collapse then Isl.collapse(true,true) end
		        elseif name == "Reverb" and sfxReverb then sfxReverb.Enabled = value end
		    end
		end
		function API:Theme(n) applyTheme(math.clamp(math.floor(tonumber(n) or 1),1,#Palettes)) end
		function API:Accent(n) applyAccent(math.clamp(math.floor(tonumber(n) or 1),1,#Accents)) end
		function API:MusicSelect(n, play)
		    Music.Select(math.clamp(math.floor(tonumber(n) or 1),1,#Music.Tracks), play ~= false)
		end
		function API:MusicCatalog()
		    local catalog = {}
		    for index, track in ipairs(Music.Tracks) do
		        if track.Remote then
		            catalog[#catalog + 1] = {
		                Index = index,
		                Name = track.Name,
		                Artist = track.Artist or "",
		                Genre = track.Mood or "",
		                Desc = track.Desc or track.Mood or "",
		                Duration = track.Duration or "",
		                Thumbnail = track.Thumbnail or "",
		                Value = track.Value or "",
		                CoverAsset = track.CoverAsset or "",
		                Row = track.Row,
		            }
		        end
		    end
		    return catalog, Music.Remote.State, Music.Remote.Supported()
		end
		function API:OnMusicCatalogChanged(callback)
		    if type(callback) ~= "function" then return function() end end
		    table.insert(Music.Remote.Listeners, callback)
		    return function()
		        local index = table.find(Music.Remote.Listeners, callback)
		        if index then table.remove(Music.Remote.Listeners, index) end
		    end
		end
		function API:OnMusicChanged(callback)
		    if type(callback) ~= "function" then return function() end end
		    table.insert(Music.Listeners, callback)
		    return function()
		        local index = table.find(Music.Listeners, callback)
		        if index then table.remove(Music.Listeners, index) end
		    end
		end
		function API:DemoDownload()
		    if Activities.Download then return end
		    downloadValue = 0
		    Activities.Download = {Title="Download",Label="Demo · xngot_pack.zip",FileName="xngot_pack.zip",Color=Static.Blue,
		    Value=function()return string.format("%d%%",math.floor(downloadValue*100+0.5))end,
		    Short=function()return string.format("%d%%",math.floor(downloadValue*100+0.5))end,
		    Ring=function()return downloadValue end,RingMode="fill"}
		    refreshActivity()
		    task.spawn(function()
		        local started=os.clock()
		        while gui.Parent and os.clock()-started<4.5 do
		            local alpha=math.clamp((os.clock()-started)/4.5,0,1)
		            downloadValue=alpha*alpha*(3-2*alpha)
		            task.wait(0.05)
		        end
		        downloadValue=1
		        Activities.Download=nil
		        refreshActivity()
		        notify("Download complete","Demo progress finished","success",2.8,true)
		    end)
		end
		function API:Expand(page) if not self.Enabled then return end Isl.expand(page or "Home") end
		function API:Collapse() Isl.collapse(false,false) end
		function API:Timer(seconds) startTimer(math.clamp(tonumber(seconds) or 60,1,86400)) end
		function API:StopTimer() stopTimer() end
		function API:ExtendTimer(seconds) extendTimer(tonumber(seconds) or 30) end
		function API:WatchToggle() stopwatchToggle() end
		function API:WatchLap() stopwatchLap() end
		function API:WatchReset() stopwatchReset() end
		function API:PlayMusic() Music.Toggle() end
		function API:NextMusic(n) Music.Next(tonumber(n) or 1) end
		function API:MusicVolume(n) Music.SetVolume(math.clamp(tonumber(n) or 40,0,100)) end
		function API:MusicSpeed(n) Music.SetTempo(math.clamp(tonumber(n) or 1,0.5,2)) end
		function API:MusicMode(name,value)
		    if name == "Auto" or name == "Shuffle" or name == "RepeatOne" or name == "ShowIsland" then Music[name] = value and true or false; Music.Sync() end
		end
		function API:AiEnable(on) Cross.setEnabled(on and true or false, false) end
		function API:AiAsk(prompt) Cross.ask(tostring(prompt or "")) end
		function API:MusicSearch(prompt)
		if not (Music.Remote and Music.Remote.Search) then
			notify("Music search", "Music search is not ready yet", "warn", 3, true)
			return false
		end
			Music.Remote.Search(tostring(prompt or ""))
			return true
		end
		function API:MusicSearchState()
			local remote = Music.Remote
			if not remote then return "idle", "", 0 end
			return remote.State, tostring(remote.Query or ""), remote.Count or 0
		end

		function API:MusicSelectValue(value, play)
			if type(value) ~= "string" or value == "" then return false end
			local wanted = tostring(value)
			for index, track in ipairs(Music.Tracks) do
				if track.Remote and (track.Value == wanted or tostring(track.Name or "") == wanted) then
					Music.Select(index, play ~= false)
					return true
				end
			end
			return false
		end

		function API:MusicRows()
			local remote = Music.Remote
			if not remote then return {}, "idle" end
			return remote.Rows or {}, remote.State
		end

		 
		function API:MusicFiles(includeSizes)
			local remote = Music.Remote
			if not remote or type(remote.ScanDownloaded) ~= "function" then
				return {}, { Count = 0, TotalBytes = 0, TotalText = "0 B", Mp3Text = "0 B", CoversText = "0 B", CoversCount = 0, Folder = "xNgotLibrary/Music", Supported = false }
			end
			local files, stats = remote.ScanDownloaded(includeSizes == true)
			return files or {}, stats or {}
		end

		function API:MusicStorage()
			local _, stats = self:MusicFiles(true)
			return stats
		end

		function API:MusicLoadDownloaded()
			if not (Music.Remote and type(Music.Remote.LoadDownloaded) == "function") then return 0 end
			return Music.Remote.LoadDownloaded() or 0
		end

		function API:MusicPlayFile(path)
			if not self.Enabled then return false end
			local wanted = tostring(path or "")
			if wanted == "" then return false end
			local function findAndPlay()
				for index, track in ipairs(Music.Tracks) do
					if track.CachedPath == wanted or track.FileName == wanted then
						Music.Select(index, true)
						return true
					end
				end
				return false
			end
			if findAndPlay() then return true end
			self:MusicLoadDownloaded()
			return findAndPlay()
		end

		function API:MusicDeleteFile(path)
			local engine = Music.Remote and Music.Remote.Engine
			if not engine or type(engine.deleteDownloaded) ~= "function" then return false, "Engine chua san sang" end
			local ok, err = engine.deleteDownloaded(tostring(path or ""))
			return ok, err
		end

		function API:MusicClearDownloaded()
			local engine = Music.Remote and Music.Remote.Engine
			if not engine or type(engine.clearDownloaded) ~= "function" then return 0, 0 end
			local deleted, failed = engine.clearDownloaded()
			return deleted or 0, failed or 0
		end

		function API:MusicAiOnline(_on)
			return false
		end
		function API:MusicAiOnlineState()
			return { enabled = false, removed = true, mode = "local", brain = "local" }
		end
		function API:MusicAiLearn(title, good)
			local engine = Music.Remote and Music.Remote.Engine
			if not engine or type(engine.learn) ~= "function" then return false end
			engine.learn(title, good)
			return true
		end

		function API:MusicPlayTrack(id, url, source)
			if not self.Enabled then return false end
			local track = {
				Id = tostring(id or ""),
				Url = tostring(url or ""),
				Source = tostring(source or "youtube"),
			}
			if track.Id == "" and track.Url == "" then return false end

			local covers = Music.Covers or { { Static.Purple, Static.Blue } }
			local cover = covers[(Music.Index % #covers) + 1]
			Music.AddTrack({
				Name = (Settings.Language == "en") and "External track" or "Bài ngoài",
				Artist = track.Source,
				Mood = track.Source,
				Remote = true,
				Source = track.Source,
				Url = track.Url,
				Id = track.Id,
				A = cover[1],
				B = cover[2],
			})
			local index = #Music.Tracks
			Music.Select(index, true)
			return true
		end

		function API:MusicDownloadOne(id, url, source)
			local engine = Music.Remote and Music.Remote.Engine
			if not engine then return false end
			local track = { id = tostring(id or ""), url = tostring(url or ""), source = tostring(source or "youtube") }
			if track.source == "audius" then
				track.directUrl = "https://api.audius.co/v1/tracks/"
					.. tostring(track.id):gsub("^audius:", "") .. "/stream"
			end
			local ok, asset = pcall(function() return engine.assetFor(track, function() end) end)
			if ok and type(asset) == "string" and asset ~= "" then return asset end
			return false
		end

		function API:AiPermission(name,on)
		    if name == "Body" or name == "Free" then Cross.Perm[name] = false; return false end
		    if name == "Ui" or name == "Key" then Cross.Perm[name] = on and true or false end
		end
		function API:AiState()
		    local reply = ""
		    for i = #Cross.Chat, 1, -1 do
		        if Cross.Chat[i].Role == "cross" then reply = tostring(Cross.Chat[i].Text or ""); break end
		    end
		    return {Enabled = Cross.Enabled == true, Thinking = Cross.Thinking == true,
		        Reply = reply, Version = Cross.ChatVersion, Pending = Cross.Pending ~= nil}
		end
		function API:AiTeach(phrase, command) return Cross.Teach(phrase, command) end
		function API:AiForgetPhrase(phrase) return Cross.ForgetPhrase(phrase) end
		function API:AiLearningState() return Cross.Learning.State() end
		function API:AiLearningList() return Cross.Learning.List() end
		function API:AiLearningPreferences() return Cross.Learning.Preferences() end
		function API:AiSetRemember(on) return Cross.Learning.SetRemember(on) end
		function API:AiLearningClear()
            local ok, message = Cross.Learning.Clear()
            if ok then Cross.Pending = nil end
            return ok, message
        end
		function API:AiClear() Cross.clearChat() end
		function API:AiOpen() if not Cross.Enabled then Cross.setEnabled(true,false) end self:Expand("Cross") end
		function API:SetLanguage(lang) self:Set("Language",lang) end
		function API:State()
		    return {Cross=Cross.Enabled,Playing=Music.Playing,MusicIndex=Music.Index,FPS=math.floor(Metrics.Fps+0.5),Ping=Metrics.Ping,
		    Timer=Activities.Timer~=nil,Island=self.Enabled}
		end
		function API:Destroy()
		    self.Enabled = false
		    pcall(function() Cross.shutdown() end)
		    pcall(function() if Isl.collapse then Isl.collapse(true,true) end end)
		    if gui then pcall(gui.Destroy,gui) end
		    if env.__xNgotStudioFullDynamic == self then env.__xNgotStudioFullDynamic = nil end
		end
		env.__xNgotStudioFullDynamic = API
		return API

		end

