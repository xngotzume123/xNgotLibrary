--[[ xngot-studio · src/modules/30_overlay/124_transport.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.transport
     role   : Nút play/next + seek bằng chuột/cảm ứng
     source : main 2.txt L9264-9431 · 168 dòng · delta +0
--]]
		        local function transport(x, size, filled, callback)
		            local button = box({
		                Class = "TextButton",
		                AnchorPoint = Vector2.new(0.5, 0.5),
		                Position = UDim2.fromOffset(x, 119),
		                Size = UDim2.fromOffset(size, size),
		                BackgroundColor3 = Static.White,
		                BackgroundTransparency = filled and 0 or 0.88,
		                AutoButtonColor = false,
		                Text = "",
		                ZIndex = 5,
		                Parent = music,
		            })
		            corner(size / 2, button)
		            if not filled then
		                stroke(button, Static.White, 0.9, 1)
		            end
		            local spring = pressable(button)
		            button.MouseButton1Click:Connect(touch(callback))
		            return button, spring
		        end
		        local prev = transport(108, 40, false, function()
		            Music.Next(-1)
		        end)
		        icon(prev, "prev", 20, 20, 18, Static.White)
		        local dark = rgb(18, 18, 22)
		        View.playButton, View.playSpring = transport(PAGE_W / 2, 50, true, function()
		            Music.Toggle()
		        end)
		        View.playIcon = icon(View.playButton, "play", 25, 25, 22, dark)
		        View.pauseIcon = icon(View.playButton, "pause", 25, 25, 22, dark)
		        View.pauseIcon.Visible = false
		        local nextButton = transport(PAGE_W - 108, 40, false, function()
		            Music.Next(1)
		        end)
		        icon(nextButton, "next", 20, 20, 18, Static.White)

		        local seeking = false
		        local function seekFromX(x)
		            local ratio = math.clamp((x - View.rail.AbsolutePosition.X) / math.max(View.rail.AbsoluteSize.X, 1), 0, 1)
		            Music.Seek(ratio)
		        end
		        View.railHit.InputBegan:Connect(function(input)
		            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		                seeking = true
		                View.SeekStamp = os.clock()
		                View.Touched = os.clock()
		                seekFromX(input.Position.X)
		            end
		        end)
		        track(UserInputService.InputChanged:Connect(function(input)
		            if seeking and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		                View.Touched = os.clock()
		                seekFromX(input.Position.X)
		            end
		        end))
		        track(UserInputService.InputEnded:Connect(function(input)
		            if seeking and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		                seeking = false
		            end
		        end))

		        local timerPage = makePage("Timer")
		        label(timerPage, {
		            Position = UDim2.fromOffset(22, 14),
		            Size = UDim2.fromOffset(200, 16),
		            Text = "Hẹn giờ",
		            FontFace = Fonts.Semibold,
		            TextSize = 12,
		            TextColor3 = Static.Orange,
		        })
		        View.timerBig = raw(label(timerPage, {
		            Position = UDim2.fromOffset(20, 28),
		            Size = UDim2.fromOffset(300, 54),
		            Text = "0:00",
		            FontFace = Fonts.Bold,
		            TextSize = 48,
		        }))
		        View.timerRail, View.timerFill = rail(timerPage, 18, 90, 304, 8, Static.Orange)
		        action(timerPage, 18, 104, 148, 38, "Dừng hẹn giờ", Static.Red, function()
		            stopTimer()
		        end)
		        action(timerPage, 174, 104, 148, 38, "+30s", nil, function()
		            extendTimer(30)
		        end)

		        local watchPage = makePage("Stopwatch")
		        View.watchTitle = label(watchPage, {
		            Position = UDim2.fromOffset(22, 14),
		            Size = UDim2.fromOffset(200, 16),
		            Text = "Bấm giờ",
		            FontFace = Fonts.Semibold,
		            TextSize = 12,
		            TextColor3 = Static.Purple,
		        })
		        View.watchBig = raw(label(watchPage, {
		            Position = UDim2.fromOffset(20, 28),
		            Size = UDim2.fromOffset(300, 54),
		            Text = "00:00.00",
		            FontFace = Fonts.Bold,
		            TextSize = 44,
		        }))
		        View.watchLap = raw(label(watchPage, {
		            Position = UDim2.fromOffset(22, 82),
		            Size = UDim2.fromOffset(296, 16),
		            Text = "",
		            FontFace = Fonts.Medium,
		            TextSize = 12,
		            TextColor3 = Static.LightGray,
		        }))
		        View.watchToggle = action(watchPage, 18, 104, 96, 38, "Tạm ngừng", Static.Purple, function()
		            stopwatchToggle()
		        end)
		        action(watchPage, 122, 104, 96, 38, "Vòng", nil, function()
		            stopwatchLap()
		        end)
		        action(watchPage, 226, 104, 96, 38, "Đặt lại", nil, function()
		            stopwatchReset()
		        end)

		        local loadPage = makePage("Download")
		        label(loadPage, {
		            Position = UDim2.fromOffset(22, 14),
		            Size = UDim2.fromOffset(200, 16),
		            Text = "Tải xuống",
		            FontFace = Fonts.Semibold,
		            TextSize = 12,
		            TextColor3 = Static.Blue,
		        })
		        View.loadBig = raw(label(loadPage, {
		            Position = UDim2.fromOffset(20, 28),
		            Size = UDim2.fromOffset(300, 54),
		            Text = "0%",
		            FontFace = Fonts.Bold,
		            TextSize = 48,
		        }))
		        View.loadName = raw(label(loadPage, {
		            Position = UDim2.fromOffset(22, 84),
		            Size = UDim2.fromOffset(296, 16),
		            Text = "Chưa có file",
		            FontFace = Fonts.Medium,
		            TextSize = 12,
		            TextColor3 = Static.LightGray,
		            TextWrapped = false,
		            TextTruncate = Enum.TextTruncate.AtEnd,
		            TextXAlignment = Enum.TextXAlignment.Left,
		        }))
		        View.loadRail, View.loadFill = rail(loadPage, 18, 108, 304, 8, Static.Blue)

		        local crossPage = makePage("Cross")
		        View.CrossMode = "chat"
		        View.crossChat = new("CanvasGroup", {
		            Name = "Chat",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundTransparency = 1,
		            ZIndex = 2,
		            Parent = crossPage,
		        })
		        View.crossTerm = new("CanvasGroup", {
		            Name = "Terminal",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundTransparency = 1,
		            GroupTransparency = 1,
		            Visible = false,
		            ZIndex = 2,
		            Parent = crossPage,
		        })

