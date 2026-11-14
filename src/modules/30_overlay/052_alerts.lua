--[[ xngot-studio · src/modules/30_overlay/052_alerts.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.alerts
     role   : Hàng đợi cảnh báo: KINDS, Isl.*, notify(), History
     source : main 2.txt L4759-5092 · 334 dòng · delta +0
--]]
		    local KINDS = {
		        success = { Static.Green, "✓" },
		        info = { Static.Blue, "i" },
		        warn = { Static.Orange, "!" },
		        error = { Static.Red, "×" },
		    }

		    local Island = {
		        Queue = {},
		        Busy = false,
		        Alerting = false,
		        Skip = false,
		        Live = nil,
		        Key = nil,
		        Pin = nil,
		        Expanded = false,
		        Pressing = false,
		        HoldDone = false,
		        PressToken = 0,
		    }

		    Isl.groupShown = Isl.groupShown or {}

		    function Isl.showGroup(group, visible, duration)
		        if not group then return end
		        visible = visible and true or false
		        Isl.groupShown[group] = visible
		        local target = visible and 0 or 1
		        local current = tonumber(group.GroupTransparency) or 0
		        if math.abs(current - target) < 0.02 then
		            group.GroupTransparency = target
		            return
		        end
		        tween(group, duration or 0.25, { GroupTransparency = target })
		    end

		    function Isl.onlyGroup(visibleGroup, duration)
		        for _, group in ipairs({ Isl.idleGroup, Isl.liveGroup, Media.Group, Isl.alertGroup }) do
		            if group then
		                Isl.showGroup(group, group == visibleGroup, duration)
		            end
		        end
		    end

		    function Isl.setIslandMode(mode, width, height)
		        if mode == "expand" then
		            Spr.springIslandW:Set(width or ISLAND.ExpandW)
		            Spr.springIslandH:Set(height or ISLAND.ExpandH)
		            Spr.springIslandR:Set(ISLAND.ExpandR)
		        elseif mode == "alert" then
		            Spr.springIslandW:Set(width)
		            Spr.springIslandH:Set(ISLAND.AlertH)
		            Spr.springIslandR:Set(ISLAND.AlertH / 2)
		        elseif mode == "media" then
		            Spr.springIslandW:Set(ISLAND.MediaW)
		            Spr.springIslandH:Set(ISLAND.MediaH)
		            Spr.springIslandR:Set(ISLAND.MediaH / 2)
		        elseif mode == "live" then
		            Spr.springIslandW:Set(ISLAND.LiveW)
		            Spr.springIslandH:Set(ISLAND.H)
		            Spr.springIslandR:Set(ISLAND.H / 2)
		        else
		            Spr.springIslandW:Set(ISLAND.IdleW)
		            Spr.springIslandH:Set(ISLAND.H)
		            Spr.springIslandR:Set(ISLAND.H / 2)
		        end
		    end

		    local settleToken = 0

		    function Isl.settleIsland()
		        settleToken = settleToken + 1
		        local token = settleToken
		        task.defer(function()
		            if token == settleToken then
		                Isl.settleIslandNow()
		            end
		        end)
		    end

		    function Isl.settleIslandNow()
		        if Island.Expanded then
		            if Fwd.islandSync then
		                Fwd.islandSync()
		            end
		            return
		        end
		        local live = Island.Live
		        if live and live.Ring then
		            Ring.ringShow(live.Color, live.Ring, live.RingMode)
		        elseif not Island.Alerting then
		            Ring.ringHide()
		        end
		        if Island.Alerting then
		            Isl.onlyGroup(Isl.alertGroup, 0.12)
		        elseif live then
		            local media = live.Media and true or false
		            Isl.setIslandMode(media and "media" or "live")
		            Isl.onlyGroup(media and Media.Group or Isl.liveGroup, 0.28)
		        else
		            Isl.setIslandMode("idle")
		            Isl.onlyGroup(Isl.idleGroup, 0.28)
		        end
		        if Fwd.islandSync then
		            Fwd.islandSync()
		        end
		    end

		    function Isl.pop(amount)
		        Spr.springIslandHover:Set(1 + (amount or 0.05))
		        task.delay(0.1, function()
		            Spr.springIslandHover:Set(1)
		        end)
		    end

		    function Isl.effects(kind, color)
		        Spr.springAlertIcon:Snap(0.3)
		        Spr.springAlertIcon:Set(1)
		        Isl.alertPulseStroke.Color = color
		        Isl.alertPulseStroke.Transparency = 0.15
		        Isl.alertPulse.Size = UDim2.fromOffset(26, 26)
		        tween(Isl.alertPulse, 0.7, { Size = UDim2.fromOffset(58, 58) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		        tween(Isl.alertPulseStroke, 0.7, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		        Isl.alertGlow.BackgroundTransparency = 0.5
		        tween(Isl.alertGlow, 0.9, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		        if kind == "error" then
		            task.spawn(function()
		                for _, dx in ipairs({ 7, -6, 5, -4, 2, 0 }) do
		                    Media.Content.Position = UDim2.fromOffset(dx, 0)
		                    task.wait(0.045)
		                end
		            end)
		        elseif kind == "warn" then
		            task.spawn(function()
		                for _, angle in ipairs({ -16, 13, -9, 5, 0 }) do
		                    Isl.alertIcon.Rotation = angle
		                    task.wait(0.06)
		                end
		            end)
		        end
		    end

		    Isl.mediaText = { Title = ISLAND.MediaW - 81, Sub = ISLAND.MediaW - 81 }
		    Isl.liveText = { Title = math.floor(ISLAND.LiveW * 0.5) - 26, Value = math.floor(ISLAND.LiveW * 0.5) - 8 }

		    function Isl.pushAlert(title, message, kind, duration)
		        title = tostring(title or ""):gsub("%s+$", "")
		        message = tostring(message or ""):gsub("%s+$", "")
		        local last = Island.Queue[#Island.Queue]
		        if last and last.title == title then
		            last.message = message
		            last.kind = kind or last.kind
		            last.duration = duration or last.duration
		            return false
		        end
		        if Island.Alerting and Island.Current and Island.Current.title == title then
		            Isl.alertMessage.Text = translate(message)
		            return false
		        end
		        local item = { title = title, message = message, kind = kind or "info", duration = duration }
		        Island.Queue[#Island.Queue + 1] = item
		        return true
		    end

		    function Isl.measureAlert(title, message)
		        local titleWidth, messageWidth = 0, 0
		        local ok, sizes = pcall(function()
		            return TextService:GetTextSize(title, 14, Enum.Font.GothamSemibold, Vector2.new(1000, 40)).X,
		                TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(1000, 40)).X
		        end)
		        if ok then
		            titleWidth, messageWidth = sizes, select(2, pcall(function()
		                return TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(1000, 40)).X
		            end))
		        end
		        titleWidth = tonumber(titleWidth) or 0
		        messageWidth = tonumber(messageWidth) or 0
		        local wanted = math.max(titleWidth, messageWidth) + 78
		        wanted = math.max(wanted, 230)
		        return math.min(wanted, 330)
		    end

		    function Isl.playAlert(item)
		        local style = KINDS[item.kind] or KINDS.info
		        if Island.Expanded and Isl.collapse then
		            Isl.collapse(true, true)
		        end
		        local waiting = #Island.Queue
		        Isl.alertIcon.BackgroundColor3 = style[1]
		        Isl.alertGlow.BackgroundColor3 = style[1]
		        Isl.alertGlyph.Text = style[2]
		        Island.Current = item
		        local alertW = Isl.measureAlert(item.title, item.message)
		        Isl.alertWidth = alertW
		        local titleBox = alertW - 44 - 16
		        if type(Isl.fitText) == "function" then
		            Isl.alertTitle.Text = Isl.fitText(translate(item.title), nil, titleBox, "GothamSemibold", 13)
		            Isl.alertMessage.Text = Isl.fitText(translate(item.message), nil, titleBox, "Gotham", 12)
		        else
		            Isl.alertTitle.Text = translate(item.title)
		            Isl.alertMessage.Text = translate(item.message)
		        end

		        Island.Alerting = true
		        Island.Skip = false
		        Isl.alertBadge.Visible = waiting > 0
		        Isl.alertBadgeText.Text = "+" .. waiting
		        Isl.bubbleTo(0)
		        tween(Isl.tint, 0.35, { BackgroundColor3 = style[1], BackgroundTransparency = 0 })
		        Isl.showGroup(Isl.idleGroup, false, 0.12)
		        Isl.showGroup(Isl.liveGroup, false, 0.12)
		        Isl.showGroup(Media.Group, false, 0.12)
		        Isl.showGroup(Isl.alertGroup, false, 0.12)
		        Isl.setIslandMode("alert", alertW + (waiting > 0 and 34 or 0))
		        Isl.pop(0.06)
		        playSound(item.kind)
		        task.wait(0.14)
		        Isl.showGroup(Isl.alertGroup, true, 0.28)
		        Isl.effects(item.kind, style[1])

		        local hold = item.duration
		        local started = os.clock()
		        Ring.ringShow(style[1], function()
		            if hold then
		                return 1 - (os.clock() - started) / hold
		            end
		            return 1
		        end)
		        while not Island.Skip and (not hold or os.clock() - started < hold) do
		            local pending = #Island.Queue
		            if Isl.alertBadge.Visible ~= (pending > 0) then
		                Isl.alertBadge.Visible = pending > 0
		            end
		            if pending > 0 then
		                local label = "+" .. pending
		                if Isl.alertBadgeText.Text ~= label then
		                    Isl.alertBadgeText.Text = label
		                end
		            end
		            task.wait(0.03)
		        end
		        Isl.alertBadge.Visible = false

		        Island.Alerting = false
		        Ring.ringHide()
		        Isl.showGroup(Isl.alertGroup, false, 0.16)
		        task.wait(0.32)
		    end

		    function Isl.runQueue()
		        if Island.Busy then
		            return
		        end
		        if Island.Expanded then
		            if Isl.drainToToast then
		                Isl.drainToToast()
		            end
		            return
		        end
		        Island.Busy = true
		        task.spawn(function()
		            while #Island.Queue > 0 do
		                local item = table.remove(Island.Queue, 1)
		                Isl.playAlert(item)
		            end
		            Isl.settleIsland()
		            Island.Busy = false
		            if #Island.Queue > 0 then
		                Isl.runQueue()
		            end
		        end)
		    end

		    local History = {}

		    local function notify(title, message, kind, duration, localOnly)
		        if History.Add then
		            History.Add(title, message, kind or "info")
		        end
		        if not localOnly and Fwd.discordForward then
		            pcall(Fwd.discordForward, title, message, kind or "info")
		        end
		        if #Island.Queue >= 4 then
		            table.remove(Island.Queue, 1)
		        end

		        local added = Isl.pushAlert(title, message, kind or "info",
		            Settings.AutoHide and (duration or Settings.Duration) or nil)
		        if added then
		            Isl.runQueue()
		        end
		    end

		    Isl.islandHit.MouseEnter:Connect(function()
		        Spr.springIslandHover:Set(1.05)
		    end)
		    Isl.islandHit.MouseLeave:Connect(function()
		        Spr.springIslandHover:Set(1)
		    end)
		    Isl.islandHit.MouseButton1Down:Connect(function()
		        Spr.springIslandHover:Set(0.94)
		    end)
		    Isl.islandHit.MouseButton1Up:Connect(function()
		        Spr.springIslandHover:Set(UserInputService.MouseEnabled and 1.05 or 1)
		    end)
		    Isl.islandHit.MouseButton1Click:Connect(function()
		        if not State.Ready then
		            return
		        end
		        if Island.HoldDone then
		            Island.HoldDone = false
		            return
		        end
		        if Island.Alerting then
		            Island.Skip = true
		        else
		            Fwd.setWindow(not State.Open)
		        end
		    end)

		    task.spawn(function()
		        while gui.Parent do
		            if Settings.Breathe then
		                tween(Isl.idleDot, 1, { BackgroundTransparency = 0.65 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		                task.wait(1)
		                tween(Isl.idleDot, 1, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		                task.wait(1)
		            else
		                tween(Isl.idleDot, 0.3, { BackgroundTransparency = 0 })
		                task.wait(0.5)
		            end
		        end
		    end)

