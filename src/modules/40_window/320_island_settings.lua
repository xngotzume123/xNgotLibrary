--[[ xngot-studio · src/modules/40_window/320_island_settings.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.island_settings
     role   : Bảng mặc định __NgotIslandSettings + helper đổi setting
     source : main 2.txt L16427-16814 · 388 dòng · delta +0
--]]
				local islandSettings = type(CONFIG.__NgotIslandSettings) == "table" and CONFIG.__NgotIslandSettings or {}
				CONFIG.__NgotIslandSettings = islandSettings
				if LIB.ActiveDynamicIsland then
					pcall(LIB.ActiveDynamicIsland.Destroy, LIB.ActiveDynamicIsland)
					LIB.ActiveDynamicIsland = nil
				end
				local created, islandAPI = xpcall(function()
					return createIntegratedDynamicIsland(Gui, Window)
				end, function(err)
					if debug and type(debug.traceback) == "function" then
						return debug.traceback(tostring(err), 2)
					end
					return tostring(err)
				end)
				if created and type(islandAPI) == "table" then
					Window.DynamicIsland = islandAPI
					if not startupGatePassed then startupGateIslandHeld = true; pcall(function() islandAPI:Enable(false) end) end
			do
				local function getApi()
					return Window and Window.DynamicIsland or nil
				end

				local function cfg(key, fallback)
					local api = _G.xNgotMusicConfig
					if api and type(api.Get) == "function" then
						local v = api:Get(key)
						if v ~= nil then return v end
					end
					return fallback
				end

				local function debugLog(...)
					if cfg("debug", false) then
						warn("[xNgotUI] " .. table.concat({ ... }, " "))
					end
				end

				local notifyGate = {}
				local function throttledNotify(channel, title, text, kind, duration)
					local now = os.clock()
					local last = notifyGate[channel]
					if last and now - last < 3 then return false end
					notifyGate[channel] = now
					if type(notify) == "function" then
						pcall(notify, title, text, kind or "info", duration or 3, true)
						return true
					end
					return false
				end
				_G.xNgotThrottledNotify = throttledNotify

				local searchQueue = { pending = nil, running = false }
				local function queueSearch(prompt)
					searchQueue.pending = tostring(prompt or "")
					if searchQueue.running then return end
					searchQueue.running = true
					task.spawn(function()
						while searchQueue.pending do
							local nextPrompt = searchQueue.pending
							searchQueue.pending = nil
							local api = getApi()
							if api and type(api.MusicSearch) == "function" then
								debugLog("search:", nextPrompt)
								pcall(function() api:MusicSearch(nextPrompt) end)
							end
							task.wait(0.35)
						end
						searchQueue.running = false
					end)
				end
				_G.xNgotQueueMusicSearch = queueSearch

				local coverQueue, coverRunning = {}, false
				local COVER_BUDGET = 2

				local function pumpCovers()
					if coverRunning then return end
					coverRunning = true
					task.spawn(function()
						while #coverQueue > 0 do
							local batch = {}
							for _ = 1, COVER_BUDGET do
								local item = table.remove(coverQueue, 1)
								if not item then break end
								batch[#batch + 1] = item
							end
							for _, item in ipairs(batch) do
								task.spawn(function()
									local engine = _G.CrossAIMusic
									if engine and type(engine.thumbAsset) == "function" then
										local ok, asset = pcall(engine.thumbAsset, item.track)
										if ok and type(asset) == "string" and asset ~= "" then
											item.track.CoverAsset = asset
										end
									end
								end)
							end
							task.wait(0.15)
						end
						coverRunning = false
					end)
				end

				local function prefetch(tracks)
					if cfg("coverArt", true) ~= true then return end
					for _, track in ipairs(tracks or {}) do
						coverQueue[#coverQueue + 1] = { track = track }
					end
					pumpCovers()
				end

				local function tooltip(button, text)
					if not button or not text or text == "" then return end
					pcall(function()
						if button:FindFirstChild("xNgotTip") then return end
						local tip = Instance.new("TextLabel")
						tip.Name = "xNgotTip"
						tip.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
						tip.BackgroundTransparency = 0.05
						tip.TextColor3 = Color3.fromRGB(230, 234, 242)
						tip.Font = Enum.Font.GothamMedium
						tip.TextSize = 12
						tip.TextWrapped = true
						tip.TextXAlignment = Enum.TextXAlignment.Left
						tip.Visible = false
						tip.ZIndex = 50
						tip.Size = UDim2.fromOffset(230, 34)
						tip.Position = UDim2.new(1, 8, 0, 0)
						tip.Text = tostring(text)
						local c = Instance.new("UICorner", tip)
						c.CornerRadius = UDim.new(0, 6)
						tip.Parent = button
						button.MouseEnter:Connect(function() tip.Visible = true end)
						button.MouseLeave:Connect(function() tip.Visible = false end)
					end)
				end
				_G.xNgotMusicTooltip = tooltip

				local lastCatalogCount = -1
				local function onCatalogChanged()
					local api = getApi()
					if not api or type(api.MusicCatalog) ~= "function" then return end
					local catalog = api:MusicCatalog()
					if #catalog == lastCatalogCount then return end
					lastCatalogCount = #catalog
					debugLog("catalog:", tostring(#catalog))

					pcall(function()
						local list = {}
						for _, item in ipairs(catalog) do
							if item.Thumbnail and item.Thumbnail ~= "" and (item.CoverAsset or "") == "" then
								list[#list + 1] = {
									name = item.Name,
									thumbnail = item.Thumbnail,
									source = item.Source or "",
									id = item.Value or item.Name,
								}
							end
						end
						if #list > 0 then prefetch(list) end
					end)
				end

				local function boot()
					local api = getApi()
					if not api then return false end
					if type(api.MusicAiOnline) == "function" then
						pcall(function()
							local st = api:MusicAiOnlineState()
							debugLog("ai:", tostring(st and st.mode))
						end)
					end
					if type(api.OnMusicCatalogChanged) == "function" then
						pcall(function() api:OnMusicCatalogChanged(function()
							task.defer(onCatalogChanged)
						end) end)
					end
					_G.xNgotUIReady = true
					return true
				end

				if not boot() then

					task.spawn(function()
						for _ = 1, 20 do
							task.wait(0.5)
							if boot() then return end
						end
						warn("[xNgotUI] không tìm thấy Window.DynamicIsland sau 10s")
					end)
				end

				local function attach()
					local api = getApi()
					if not api then return false end
					api.MusicQueue = function(_, prompt) queueSearch(prompt) end
					api.MusicPreset = function(_, name)
						local c = _G.xNgotMusicConfig
						return c and c:Preset(name) or false
					end
					api.MusicConfig = function()
						local c = _G.xNgotMusicConfig
						return c and c:Get() or {}
					end
					return true
				end
				if not attach() then
					task.spawn(function()
						for _ = 1, 20 do
							task.wait(0.5)
							if attach() then return end
						end
					end)
				end
			end
			do
				local function has(fn)
					local ok, value = pcall(function() return _G[fn] end)
					return ok and type(value) == "function"
				end

				local function folderExists(path)
					if not has("isfolder") then return nil end
					local ok, res = pcall(isfolder, path)
					return ok and res == true
				end

				local function fileCount(folder)
					if not has("listfiles") then return nil end
					local ok, list = pcall(listfiles, folder)
					if not ok or type(list) ~= "table" then return nil end
					local n = 0
					for _, f in ipairs(list) do
						if tostring(f):lower():match("%.mp3$") then n = n + 1 end
					end
					return n
				end

				function _G.xNgotMusicDoctor()
					local engine = _G.CrossAIMusic
					local api = _G.xNgotMusicConfig
					local island = (Window and Window.DynamicIsland) or nil

					local report = {
						version = "xNgot Audio v4",
						checks = {},
					}

					local function add(name, status, detail)
						report.checks[#report.checks + 1] = { name = name, status = status, detail = detail }
					end

					add("writefile", has("writefile") and "ok" or "fail",
						"required to cache mp3 files")
					add("readfile", has("readfile") and "ok" or "warn", "read back cache files (ID3)")
					add("isfile", has("isfile") and "ok" or "warn", "check cache")
					add("makefolder", has("makefolder") and "ok" or "warn", "create the music folder")
					add("listfiles", has("listfiles") and "ok" or "warn", "count files in cache")
					local assetFn = has("getcustomasset") and "getcustomasset"
						or (has("getsynasset") and "getsynasset") or nil
					add("getcustomasset", assetFn and "ok" or "fail", "required to play mp3 files")
					add("request/POST", (has("request") or has("http_request") or has("syn_request"))
						and "ok" or "warn", "PoW music download; falls back to HttpService")

					if engine then
						local st = type(engine.llmStatus) == "function" and engine.llmStatus() or { mode = "local" }
						add("engine", "ok", "Config.Folder = " .. tostring(engine.Config and engine.Config.Folder))
						add("parser offline", engine.parse and "ok" or "fail",
							engine.parse and ("\"" .. tostring(engine.parse("nhạc lofi buổi tối").query) .. "\"") or "")
						add("PoW/SHA-256", engine.sha256 and "ok" or "fail",
							engine.sha256 and engine.sha256("abc"):sub(1, 8) or "")
						add("AI local", st.mode == "local" and "ok" or "warn",
							"offline, no network needed - learns from skipped tracks")
					else
						add("engine", "fail", "CrossAIMusic is not initialized")
					end

					if api then
						local c = api:Get()
						add("config", "ok", string.format("topN=%s · raceTracks=%s · sources=%d",
							tostring(c.topN), tostring(c.raceTracks), #(c.sources or {})))
					else
						add("config", "fail", "_G.xNgotMusicConfig is missing")
					end

					local need = { "MusicSearch", "MusicCatalog", "MusicSelectValue", "MusicQueue", "MusicPreset" }
					local missing = {}
					for _, fn in ipairs(need) do
						if not island or type(island[fn]) ~= "function" then missing[#missing + 1] = fn end
					end
					add("Island API", #missing == 0 and "ok" or "warn",
						#missing == 0 and "complete" or ("missing: " .. table.concat(missing, ", ")))

					local folder = engine and engine.Config and engine.Config.Folder or "xNgotLibrary/Music"
					add("cache folder", folderExists(folder) == false and "not created yet (will be created)" or "ok", folder)
					local n = fileCount(folder)
					add("cached mp3 files", n and "ok" or "n/a", n and (tostring(n) .. " tracks") or "executor does not support listfiles")

					local fails, warns = 0, 0
					print("=========== xNgot Audio - DIAGNOSTICS ===========")
					for _, c in ipairs(report.checks) do
						local icon = c.status == "ok" and "[ OK ]" or (c.status == "fail" and "[FAIL]" or "[ !! ]")
						if c.status == "fail" then fails = fails + 1
						elseif c.status ~= "ok" then warns = warns + 1 end
						print(string.format("%s %-18s %s", icon, c.name, tostring(c.detail or "")))
					end
					print(string.format("---- %d errors, %d warnings ----", fails, warns))
					if fails > 0 then
						print("Hint: missing writefile/getcustomasset -> music cannot play (switch executor).")
					end
					print("==============================================")
					report.fails, report.warns = fails, warns
					return report
				end

				local function attach()
					local island = Window and Window.DynamicIsland
					if not island then return false end
					island.MusicDoctor = function() return _G.xNgotMusicDoctor() end
					return true
				end
				if not attach() then
					task.spawn(function()
						for _ = 1, 20 do
							task.wait(0.5)
							if attach() then return end
						end
					end)
				end
			end
					LIB.ActiveDynamicIsland = islandAPI
				else
					Window.DynamicIslandError = tostring(islandAPI)
					LIB.LastDynamicIslandError = Window.DynamicIslandError
					local environment = type(getgenv) == "function" and getgenv() or _G
					environment.xNgotStudioLastStartupError = Window.DynamicIslandError
					warn("[xNgotStudio] Dynamic Island startup failed: " .. Window.DynamicIslandError)
					local partial = Gui:FindFirstChild("xNgotStudio_FullDynamicIsland")
					if partial then partial:Destroy() end
				end

				local function islandCall(method, ...)
					local api = Window.DynamicIsland
					if not api then return false end
					local fn = api[method]
					if type(fn) ~= "function" then return false end
					local ok, result = pcall(fn, api, ...)
					if not ok then warn("[NgotStudio/Island] " .. method .. ": " .. tostring(result)) end
					return ok
				end

				local function changeIsland(key, value, method)
					islandSettings[key] = value
					if method == "Enable" then
						islandCall("Enable", value)
					elseif method == "Theme" or method == "Accent" then
						islandCall(method, value)
					else
						islandCall("Set", key, value)
					end
					SAVECONFIG()
				end

				local defaults = {
					Enabled = true, Fps = false, Ping = false, Clock = false,
					Expand = true, Split = true, RimLight = true, Ring = true,
					Breathe = true, AutoHide = true, Sound = true,
					Reverb = true, Language = "en", Accent = 1, Theme = 1,
					Volume = 40, Duration = 2.5, Blur = false,
				}
				for key, defaultValue in pairs(defaults) do
					if islandSettings[key] == nil then islandSettings[key] = defaultValue end
				end
				-- Tat auto bat FPS/Ping: config cu da luu true thi tat 1 lan (migration), tu lan sau nguoi dung bat thu cong se duoc nho.
				if islandSettings.__fpsPingAutoOffV1 ~= true then
					islandSettings.Fps = false
					islandSettings.Ping = false
					islandSettings.__fpsPingAutoOffV1 = true
					pcall(SAVECONFIG)
				end
				islandSettings.Language = "en"

				for key, value in pairs(islandSettings) do
					if key == "Enabled" then islandCall("Enable", value)
					elseif key == "Theme" or key == "Accent" then islandCall(key, value)
					elseif defaults[key] ~= nil then islandCall("Set", key, value) end
				end

