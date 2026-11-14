--[[ xngot-studio · src/modules/30_overlay/140_expand.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.expand
     role   : drainToToast, Isl.expand/collapse, xử lý input
     source : main 2.txt L10149-10347 · 199 dòng · delta +0
--]]
		        function Isl.drainToToast()
		            local moved = false
		            while #Island.Queue > 0 do
		                local item = table.remove(Island.Queue, 1)
		                if item.kind ~= "info" then
		                    if #View.Toasts >= 3 then
		                        table.remove(View.Toasts, 1)
		                    end
		                    table.insert(View.Toasts, item)
		                    moved = true
		                end
		            end
		            if moved then
		                View.toastRun()
		            end
		        end

		        function Isl.expand(page)
		            if Island.Expanded or Island.Alerting or Island.Busy or not State.Ready then
		                return
		            end
		            Island.Expanded = true
		            Island.Pressing = false
		            View.Touched = os.clock()
		            View.Gesture = nil
		            View.clearToasts()
		            View.group.Visible = true
		            local key = page
		            if not key then
		                key = Island.Key
		                if key ~= "Music" and key ~= "Timer" and key ~= "Stopwatch" and key ~= "Download" and key ~= "Cross" then
		                    key = "Home"
		                end
		            end
		            for _, pageGroup in pairs(View.Pages) do
		                pageGroup.Visible = false
		                pageGroup.GroupTransparency = 1
		                pageGroup.Position = UDim2.fromOffset(0, 0)
		            end
		            View.Current = "Home"
		            View.show(key, true)
		            if key == "Cross" then
		                View.crossMode("chat", true)
		            end
		            Ring.ringHide()
		            Isl.bubbleTo(0)
		            Isl.showGroup(Isl.idleGroup, false, 0.12)
		            Isl.showGroup(Isl.liveGroup, false, 0.12)
		            Isl.showGroup(Isl.alertGroup, false, 0.12)
		            Isl.showGroup(Media.Group, false, 0.12)
		            Isl.islandHit.Visible = false
		            Isl.setIslandMode("expand", PAGE_W, PAGE_H)
		            Isl.pop(0.035)
		            playSound("open")
		            local live = Island.Live
		            tween(Isl.tint, 0.4, {
		                BackgroundColor3 = live and live.Color or Static.Blue,
		                BackgroundTransparency = live and 0 or 0.5,
		            })
		            task.delay(0.1, function()
		                if Island.Expanded then
		                    Isl.showGroup(View.group, true, 0.32)
		                end
		            end)
		        end

		        function Isl.collapse(instant, quiet)
		            if not Island.Expanded then
		                return
		            end
		            Island.Expanded = false
		            Island.HoldDone = false
		            View.Gesture = nil
		            if Cross.releaseFocus then
		                Cross.releaseFocus()
		            end
		            View.clearToasts()
		            Isl.islandHit.Visible = true
		            if instant then
		                View.group.GroupTransparency = 1
		                View.group.Visible = false
		            else
		                Isl.showGroup(View.group, false, 0.14)
		                playSound("close")
		                task.delay(0.2, function()
		                    if not Island.Expanded then
		                        View.group.Visible = false
		                    end
		                end)
		            end
		            if not quiet then
		                Isl.settleIsland()
		            end
		            if #Island.Queue > 0 and not quiet then
		                Isl.runQueue()
		            end
		        end

		        Fwd.islandExpand = Isl.expand
		        Fwd.islandCollapse = Isl.collapse

		        View.grabHit.MouseButton1Click:Connect(function()
		            Isl.collapse()
		        end)

		        local function pointInside(x, y, margin)
		            local pos = Isl.islandFrame.AbsolutePosition
		            local size = Isl.islandFrame.AbsoluteSize
		            if x < pos.X - margin or x > pos.X + size.X + margin then
		                return false
		            end
		            local top, bottom = pos.Y - margin, pos.Y + size.Y + margin
		            return (y >= top and y <= bottom) or (y + View.Inset >= top and y + View.Inset <= bottom)
		        end

		        track(UserInputService.InputBegan:Connect(function(input, processed)
		            if not Island.Expanded then
		                return
		            end
		            local code = input.KeyCode
		            if code == Enum.KeyCode.Escape then
		                Isl.collapse()
		                return
		            end
		            if code == Enum.KeyCode.Left or code == Enum.KeyCode.Right then
		                if not processed then
		                    View.step(code == Enum.KeyCode.Right and 1 or -1)
		                end
		                return
		            end
		            local kind = input.UserInputType
		            if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
		                return
		            end
		            local point = input.Position
		            if point and not pointInside(point.X, point.Y, 10) then
		                Isl.collapse()
		                return
		            end
		            View.Touched = os.clock()
		            View.Gesture = point and { X = point.X, Y = point.Y, At = os.clock() } or nil
		        end))

		        track(UserInputService.InputChanged:Connect(function(input)
		            if not Island.Expanded or input.UserInputType ~= Enum.UserInputType.MouseMovement then
		                return
		            end
		            local now = os.clock()
		            local point = input.Position
		            if point and now - View.Touched > 0.4 and pointInside(point.X, point.Y, 10) then
		                View.Touched = now
		            end
		        end))

		        track(UserInputService.InputEnded:Connect(function(input)
		            local gesture = View.Gesture
		            local kind = input.UserInputType
		            if not gesture or (kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch) then
		                return
		            end
		            View.Gesture = nil
		            local point = input.Position
		            if not Island.Expanded or not point or View.SeekStamp >= gesture.At - 0.05 then
		                return
		            end
		            local dx, dy = point.X - gesture.X, point.Y - gesture.Y
		            local ax, ay = math.abs(dx), math.abs(dy)
		            local limit = SWIPE * islandState.Base
		            if ax > limit and ax > ay * 1.3 then
		                View.step(dx < 0 and 1 or -1)
		            elseif -dy > limit and ay > ax * 1.3 then
		                Isl.collapse()
		            end
		        end))

		        Isl.islandHit.MouseButton1Down:Connect(function()
		            Island.HoldDone = false
		            Island.Pressing = true
		            Island.PressToken = Island.PressToken + 1
		            local token = Island.PressToken
		            task.delay(0.4, function()
		                if Island.Pressing and Island.PressToken == token and Settings.Expand and State.Ready and not Island.Expanded then
		                    Island.HoldDone = true
		                    Isl.expand()
		                end
		            end)
		        end)
		        Isl.islandHit.MouseButton1Up:Connect(function()
		            Island.Pressing = false
		        end)
		        Isl.islandHit.MouseLeave:Connect(function()
		            Island.Pressing = false
		        end)
		        Isl.islandHit.MouseButton2Click:Connect(function()
		            if Settings.Expand and State.Ready then
		                Isl.expand()
		            end
		        end)

