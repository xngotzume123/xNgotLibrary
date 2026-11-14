--[[ xngot-studio · src/modules/30_overlay/056_activities.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.activities
     role   : Activity: timer, stopwatch, FPS, ping, đồng hồ
     source : main 2.txt L5093-5334 · 242 dòng · delta +0
--]]
		    local Activities = {}

	    local ACTIVITY_ORDER = { "Music", "Download", "Cross", "Timer", "Gameplay", "Stopwatch", "Fps", "Ping", "Clock" }
		    local downloadValue = 0
		    local liveShown = ""

		    local function refreshActivity()
		        local current, currentKey
		        if Island.Pin and Activities[Island.Pin] then
		            current, currentKey = Activities[Island.Pin], Island.Pin
		        else
		            Island.Pin = nil
		            for _, key in ipairs(ACTIVITY_ORDER) do
		                if Activities[key] then
		                    current, currentKey = Activities[key], key
		                    break
		                end
		            end
		        end
		        Island.Live = current
		        Island.Key = currentKey
		        if current then
		            tween(Isl.liveDot, 0.3, { BackgroundColor3 = current.Color })
		            local half = math.floor(ISLAND.LiveW * 0.5)
		            local fit = Isl.fitText
		            if type(fit) == "function" then
		                Isl.liveTitle.Text = fit(translate(current.Title), Isl.liveTitle, half - 30, "Gotham", 11)
		                liveShown = current.Value()
		                Isl.liveValue.Text = fit(translate(liveShown), Isl.liveValue, half - 10, "GothamMedium", 12)
		            else
		                Isl.liveTitle.Text = translate(current.Title)
		                liveShown = current.Value()
		                Isl.liveValue.Text = translate(liveShown)
		            end
		        end
		        if not Island.Busy then
		            if Island.Alerting then
		                task.delay(0.45, function()
		                    if not Island.Alerting and not Island.Busy then
		                        Isl.settleIsland()
		                    end
		                end)
		            else
		                Isl.settleIsland()
		            end
		        end
		        if Fwd.islandSync then
		            Fwd.islandSync()
		        end
		    end

		    local function startTimer(seconds)
		        local timer = {
		            Title = "Hẹn giờ",
		            Color = Static.Orange,
		            Finish = os.clock() + seconds,
		            Total = seconds,
		            RingMode = "drain",
		        }
		        timer.Value = function()
		            local remaining = math.max(0, math.ceil(timer.Finish - os.clock()))
		            return string.format("%d:%02d", math.floor(remaining / 60), remaining % 60)
		        end
		        timer.Short = timer.Value
		        timer.Ring = function()
		            return (timer.Finish - os.clock()) / timer.Total
		        end
		        Activities.Timer = timer
		        refreshActivity()
		        notify("Bắt đầu hẹn giờ", string.format("%d %s", seconds, translate("giây")), "info", 1.6)
		    end

		    local function extendTimer(extra)
		        local timer = Activities.Timer
		        if timer then
		            timer.Finish = timer.Finish + extra
		            timer.Total = timer.Total + extra
		        end
		    end

		    local function stopTimer()
		        if Activities.Timer then
		            Activities.Timer = nil
		            refreshActivity()
		            notify("Đã dừng hẹn giờ", "Hoạt động đã được gỡ khỏi đảo", "info", 1.6)
		        end
		    end

		    local stopwatchToggle, stopwatchLap, stopwatchReset

		    do
		        local Stopwatch = { Running = false, Elapsed = 0, Started = 0, Laps = 0 }

		        local function stopwatchElapsed()
		            if Stopwatch.Running then
		                return Stopwatch.Elapsed + os.clock() - Stopwatch.Started
		            end
		            return Stopwatch.Elapsed
		        end

		        local function stopwatchText()
		            local total = stopwatchElapsed()
		            return string.format("%02d:%02d.%02d", math.floor(total / 60), math.floor(total % 60), math.floor(total * 100 % 100))
		        end

		        function stopwatchToggle()
		            if Stopwatch.Running then
		                Stopwatch.Elapsed = stopwatchElapsed()
		                Stopwatch.Running = false
		                if Activities.Stopwatch then
		                    Activities.Stopwatch.Title = "Tạm dừng"
		                end
		            else
		                Stopwatch.Started = os.clock()
		                Stopwatch.Running = true
		                if not Activities.Stopwatch then
		                    Activities.Stopwatch = {
		                        Title = "Bấm giờ",
		                        Color = Static.Purple,
		                        Value = stopwatchText,
		                        Short = function()
		                            local total = stopwatchElapsed()
		                            return string.format("%d:%02d", math.floor(total / 60), math.floor(total % 60))
		                        end,
		                        Ring = function()
		                            return stopwatchElapsed() % 60 / 60
		                        end,
		                        RingMode = "fill",
		                    }
		                end
		                Activities.Stopwatch.Title = "Bấm giờ"
		            end
		            refreshActivity()
		        end

		        function stopwatchLap()
		            if Activities.Stopwatch then
		                Stopwatch.Laps = Stopwatch.Laps + 1
		                Activities.Stopwatch.Lap = { Index = Stopwatch.Laps, Text = stopwatchText() }
		                notify("Vòng " .. Stopwatch.Laps, stopwatchText(), "info", 1.8)
		            end
		        end

		        function stopwatchReset()
		            Stopwatch.Running = false
		            Stopwatch.Elapsed = 0
		            Stopwatch.Laps = 0
		            if Activities.Stopwatch then
		                Activities.Stopwatch = nil
		                refreshActivity()
		            end
		        end
		    end

		    local function setFpsActivity(on)
		        if on then
		            local value = function()
		                return string.format("%d", math.floor(Metrics.Fps + 0.5))
		            end
		            Activities.Fps = {
		                Title = "FPS",
		                Color = Static.Green,
		                Value = value,
		                Short = value,
		            }
		        else
		            Activities.Fps = nil
		        end
		        refreshActivity()
		    end

		    local function setPingActivity(on)
		        if on then
		            local value = function()
		                return string.format("%d ms", Metrics.Ping)
		            end
		            Activities.Ping = {
		                Title = "Ping",
		                Color = rgb(100, 210, 255),
		                Value = value,
		                Short = function()
		                    return string.format("%d", Metrics.Ping)
		                end,
		            }
		        else
		            Activities.Ping = nil
		        end
		        refreshActivity()
		    end

		    local function setClockActivity(on)
		        if on then
		            local value = function()
		                return os.date("%H:%M")
		            end
		            Activities.Clock = {
		                Title = "Đồng hồ",
		                Color = Static.Gray,
		                Value = value,
		                Short = value,
		            }
		        else
		            Activities.Clock = nil
		        end
		        refreshActivity()
		    end

		    task.spawn(function()
		        while gui.Parent do
		            local ok, ping = pcall(function()
		                return player:GetNetworkPing() * 1000
		            end)
		            if ok and type(ping) == "number" then
		                Metrics.Ping = math.clamp(math.floor(ping + 0.5), 0, 9999)
		            end
		            task.wait(2)
		        end
		    end)

		    task.spawn(function()
		        while gui.Parent do
		            local timer = Activities.Timer
		            if timer and os.clock() >= timer.Finish then
		                Activities.Timer = nil
		                refreshActivity()
		                notify("Hết giờ", "Hẹn giờ đã kết thúc", "warn", 3)
		            end
		            task.wait(0.2)
		        end
		    end)

		    Hooks.Register(function()
		        local live = Island.Live
		        if live then
		            local value = live.Value()
		            if value ~= liveShown then
		                liveShown = value
		                Isl.liveValue.Text = translate(value)
		            end
		        end
		    end, 3)

