--[[ xngot-studio · src/modules/30_overlay/136_view_show.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.view_show
     role   : View.show/nudge/step/tick/refresh + toast
     source : main 2.txt L9891-10148 · 258 dòng · delta +0
--]]
		        function View.show(key, instant, direction)
		            if not View.Pages[key] then
		                key = "Home"
		            end
		            local previous = View.Current
		            View.Current = key
		            View.Touched = os.clock()
		            local way = direction or (pageIndex(key) >= pageIndex(previous) and 1 or -1)
		            for name, page in pairs(View.Pages) do
		                if name == key then
		                    if instant then
		                        page.Visible = true
		                        page.GroupTransparency = 0
		                        page.Position = UDim2.fromOffset(0, 0)
		                    elseif previous ~= key or not page.Visible then
		                        page.Position = UDim2.fromOffset(way * 28, 0)
		                        page.Visible = true
		                        tween(page, 0.34, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		                    end
		                elseif page.Visible then
		                    if instant then
		                        page.GroupTransparency = 1
		                        page.Visible = false
		                    else
		                        tween(page, 0.16, { GroupTransparency = 1, Position = UDim2.fromOffset(-way * 20, 0) })
		                        task.delay(0.2, function()
		                            if View.Current ~= name then
		                                page.Visible = false
		                                page.Position = UDim2.fromOffset(0, 0)
		                            end
		                        end)
		                    end
		                end
		            end
		            View.layoutDock(instant)
		            View.tick(true)
		        end

		        function View.nudge(direction)
		            local page = View.Pages[View.Current]
		            if page then
		                page.Position = UDim2.fromOffset(-direction * 12, 0)
		                tween(page, 0.4, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		            end
		        end

		        function View.step(direction)
		            local list = View.available()
		            local at = 1
		            for index, key in ipairs(list) do
		                if key == View.Current then
		                    at = index
		                end
		            end
		            local target = list[at + direction]
		            View.Touched = os.clock()
		            if target then
		                playSound("click")
		                View.show(target, false, direction)
		            else
		                View.nudge(direction)
		            end
		        end

		        function View.tick(force)
		            local now = os.clock()
		            if not force and now - View.TickAt < (View.TickRate or 0.05) then
		                return
		            end
		            View.TickAt = now
		            if not Island.Expanded then
		                return
		            end
		            if View.DockLang ~= Settings.Language then
		                View.DockLang = Settings.Language
		                View.layoutDock(true)
		            end
		            local updater = View.Updaters[View.Current]
		            if updater then
		                updater()
		            end
		        end

		        View.Updaters.Home = function()
		            local stamp = os.clock()
		            if stamp - (View.HomeAt or 0) > 0.5 then
		                View.HomeAt = stamp
		                put(View.clock, os.date("%H:%M"))
		                put(View.date, os.date("%d/%m/%Y"))
		            end
		            local stamp2 = View.HomeAt or 0
		            if View.HomeMetricsAt ~= stamp2 then
		                View.HomeMetricsAt = stamp2
		                local fps = math.floor(Metrics.Fps + 0.5)
		                put(View.fpsText, fps .. " FPS")
		                local fpsColor = fps >= 50 and Static.Green or (fps >= 30 and Static.Orange or Static.Red)
		                if View.fpsDot.BackgroundColor3 ~= fpsColor then
		                    View.fpsDot.BackgroundColor3 = fpsColor
		                end
		                put(View.pingText, Metrics.Ping .. " ms")
		                local pingColor = Metrics.Ping < 90 and Static.Green or (Metrics.Ping < 180 and Static.Orange or Static.Red)
		                if View.pingDot.BackgroundColor3 ~= pingColor then
		                    View.pingDot.BackgroundColor3 = pingColor
		                end
		            end
		            for _, entry in ipairs(View.Quick) do
		                local on = entry.Def.Active() and true or false
		                put(entry.Sub, entry.Def.Sub())
		                if entry.On ~= on then
		                    entry.On = on
		                    tween(entry.Button, 0.25, {
		                        BackgroundColor3 = on and entry.Def.Color or Static.White,
		                        BackgroundTransparency = on and 0.06 or 0.88,
		                    })
		                    tween(entry.Sub, 0.25, { TextColor3 = on and Static.White or Static.LightGray })
		                end
		            end
		        end

		        View.Updaters.Music = function()
		            local track_ = Music.Tracks[Music.Index]
		            put(View.title, Media.Title.Text)
		            put(View.mood, Media.Sub.Text)
		            local gradient = Media.ArtGradient.Color
		            if View.Shown.Art ~= gradient then
		                View.Shown.Art = gradient
		                View.artGradient.Color = gradient
		            end
		            local coverImage = Media.Cover and Media.Cover.Image or ""
		            if View.Shown.Cover ~= coverImage then
		                View.Shown.Cover = coverImage
		                if View.artCover then
		                    View.artCover.Image = coverImage
		                    View.artCover.Visible = coverImage ~= ""
		                end
		            end
		            local color = track_ and track_.B or Static.White
		            if View.Shown.Fill ~= color then
		                View.Shown.Fill = color
		                View.fill.BackgroundColor3 = color
		                for _, bar in ipairs(View.bars) do
		                    bar.BackgroundColor3 = color
		                end
		            end
		            View.fill.Size = UDim2.new(Music.Progress(), 0, 1, 0)
		            put(View.elapsed, fmt(Music.Position))
		            local length = Music.Duration()
		            put(View.total, length > 0 and fmt(length) or "-:--")
		            local playing = Music.Playing and true or false
		            if View.Shown.Playing ~= playing then
		                View.Shown.Playing = playing
		                View.artSpring:Set(playing and 1 or 0.86)
		                View.playSpring:Snap(0.84)
		                View.playSpring:Set(1)
		            end
		            if View.playIcon.Visible == playing then
		                View.playIcon.Visible = not playing
		                View.pauseIcon.Visible = playing
		            end
		            for index, bar in ipairs(View.bars) do
		                bar.Size = UDim2.fromOffset(3, 3 + 14 * math.clamp(Music.Levels[index] + 0.06, 0, 1))
		            end
		        end

		        View.Updaters.Timer = function()
		            local timer = Activities.Timer
		            if timer then
		                put(View.timerBig, timer.Value())
		                View.timerFill.Size = UDim2.new(math.clamp(timer.Ring(), 0, 1), 0, 1, 0)
		            end
		        end

		        View.Updaters.Stopwatch = function()
		            local watch = Activities.Stopwatch
		            if watch then
		                put(View.watchBig, watch.Value())
		                local running = watch.Title == "Bấm giờ"
		                put(View.watchTitle, translate(watch.Title))
		                put(View.watchToggle, translate(running and "Tạm ngừng" or "Tiếp tục"))
		                local lap = watch.Lap
		                put(View.watchLap, lap and (translate("Vòng") .. " " .. lap.Index .. "  ·  " .. lap.Text) or "")
		            end
		        end

		        View.Updaters.Download = function()
		            local load = Activities.Download
		            if load then
		                put(View.loadBig, load.Value())
		                local label = load.FileName or load.Label or load.Title
		                if label and label ~= "" and View.Shown.LoadName ~= label then
		                    View.Shown.LoadName = label
		                    put(View.loadName, tostring(label))
		                end
		                View.loadFill.Size = UDim2.new(math.clamp(downloadValue, 0, 1), 0, 1, 0)
		            end
		        end

		        function View.refresh()
		            local list = View.available()
		            local found = false
		            for _, key in ipairs(list) do
		                if key == View.Current then
		                    found = true
		                end
		            end
		            if not found then
		                View.show("Home")
		            else
		                View.layoutDock()
		            end
		        end

		        function View.clearToasts()
		            View.Toasts = {}
		            View.ToastToken = View.ToastToken + 1
		            View.ToastSkip = false
		            View.toast.Visible = false
		            View.toast.Position = UDim2.fromOffset(12, -60)
		        end

		        function View.toastRun()
		            if View.ToastBusy then
		                return
		            end
		            View.ToastBusy = true
		            local token = View.ToastToken
		            task.spawn(function()
		                while #View.Toasts > 0 and Island.Expanded and token == View.ToastToken do
		                    local item = table.remove(View.Toasts, 1)
		                    local style = KINDS[item.kind] or KINDS.info
		                    View.toastIcon.BackgroundColor3 = style[1]
		                    View.toastGlyph.Text = style[2]
		                    View.toastTitle.Text = translate(item.title)
		                    View.toastMessage.Text = translate(item.message)
		                    View.ToastSkip = false
		                    View.toast.Position = UDim2.fromOffset(12, -60)
		                    View.toast.Visible = true
		                    playSound(item.kind)
		                    tween(View.toast, 0.4, { Position = UDim2.fromOffset(12, 14) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		                    local hold = math.clamp(item.duration or 2.6, 1.8, 4)
		                    local started = os.clock()
		                    while Island.Expanded and token == View.ToastToken and not View.ToastSkip and os.clock() - started < hold do
		                        task.wait(0.05)
		                    end
		                    if Island.Expanded and token == View.ToastToken then
		                        tween(View.toast, 0.26, { Position = UDim2.fromOffset(12, -60) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		                        task.wait(0.28)
		                        View.toast.Visible = false
		                    end
		                    View.ToastSkip = false
		                end
		                View.ToastBusy = false
		                if #View.Toasts > 0 and Island.Expanded then
		                    View.toastRun()
		                end
		            end)
		        end

