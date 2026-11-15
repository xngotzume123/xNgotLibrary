--[[ xngot-studio · src/modules/30_overlay/120_quick_actions.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.quick
     role   : Nút hành động nhanh + View.bars
     source : main 2.txt L9068-9263 · 196 dòng · delta +0
--]]
		        local quick = {
		            {
		                Text = "Cửa sổ",
		                Color = Static.Blue,
		                Active = function()
		                    return State.Open
		                end,
		                Sub = function()
		                    return translate(State.Open and "Đang mở" or "Đã đóng")
		                end,
		                Click = function()
		                    Fwd.setWindow(not State.Open)
		                end,
		            },
		            {
		                Text = "Hẹn giờ",
		                Color = Static.Orange,
		                Active = function()
		                    return Activities.Timer ~= nil
		                end,
		                Sub = function()
		                    return Activities.Timer and Activities.Timer.Value() or "0:30"
		                end,
		                Click = function()
		                    if Activities.Timer then
		                        stopTimer()
		                    else
		                        startTimer(30)
		                    end
		                end,
		            },
		            {
		                Text = "Bấm giờ",
		                Color = Static.Purple,
		                Active = function()
		                    return Activities.Stopwatch ~= nil
		                end,
		                Sub = function()
		                    return Activities.Stopwatch and Activities.Stopwatch.Short() or "0:00"
		                end,
		                Click = function()
		                    stopwatchToggle()
		                end,
		            },
		            {
		                Text = "Âm nhạc",
		                Color = Static.Green,
		                Active = function()
		                    return Music.Playing
		                end,
		                Sub = function()
		                    return translate(Music.Playing and "Đang phát" or "Đã dừng")
		                end,
		                Click = function()
		                    Music.Toggle()
		                end,
		            },
		        }
		        for index, def in ipairs(quick) do
		            local button = box({
		                Class = "TextButton",
		                Position = UDim2.fromOffset(18 + (index - 1) * 78, 92),
		                Size = UDim2.fromOffset(70, 50),
		                BackgroundColor3 = Static.White,
		                BackgroundTransparency = 0.88,
		                AutoButtonColor = false,
		                Text = "",
		                ZIndex = 5,
		                Parent = home,
		            })
		            corner(16, button)
		            stroke(button, Static.White, 0.92, 1)
		            shine(button, 16, 0.9)
		            local caption = label(button, {
		                Position = UDim2.fromOffset(0, 9),
		                Size = UDim2.new(1, 0, 0, 16),
		                Text = def.Text,
		                FontFace = Fonts.Semibold,
		                TextSize = 11,
		                TextXAlignment = Enum.TextXAlignment.Center,
		                TextTruncate = Enum.TextTruncate.AtEnd,
		                ZIndex = 6,
		            })
		            local sub = raw(label(button, {
		                Position = UDim2.fromOffset(0, 27),
		                Size = UDim2.new(1, 0, 0, 14),
		                Text = "",
		                FontFace = Fonts.Medium,
		                TextSize = 10,
		                TextColor3 = Static.LightGray,
		                TextXAlignment = Enum.TextXAlignment.Center,
		                ZIndex = 6,
		            }))
		            pressable(button)
		            button.MouseButton1Click:Connect(touch(def.Click))
		            View.Quick[index] = { Button = button, Caption = caption, Sub = sub, Def = def, On = false }
		        end

		        local music = makePage("Music")
		        View.art = box({
		            AnchorPoint = Vector2.new(0.5, 0.5),
		            Position = UDim2.fromOffset(43, 41),
		            Size = UDim2.fromOffset(54, 54),
		            BackgroundColor3 = Static.White,
		            Parent = music,
		        })
		        corner(14, View.art)
		        View.artGradient = new("UIGradient", { Color = Media.ArtGradient.Color, Rotation = 45, Parent = View.art })
		         
		        View.artCover = new("ImageLabel", {
		            Name = "Cover", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		            Image = "", ScaleType = Enum.ScaleType.Crop, Visible = false, ZIndex = 3, Parent = View.art,
		        })
		        corner(14, View.artCover)
		        local artScale = new("UIScale", { Parent = View.art })
		        View.artSpring = Spring.new(0.86, 180, 15, function(value)
		            artScale.Scale = value
		        end, 0.001)
		        raw(label(View.art, {
		            Size = UDim2.fromScale(1, 1),
		            Text = "♪",
		            FontFace = Fonts.Bold,
		            TextSize = 24,
		            TextXAlignment = Enum.TextXAlignment.Center,
		        }))
		        local artGloss = box({
		            Position = UDim2.fromOffset(1, 1),
		            Size = UDim2.new(1, -2, 0.5, 0),
		            BackgroundColor3 = Static.White,
		            Parent = View.art,
		        })
		        corner(13, artGloss)
		        new("UIGradient", { Transparency = NumberSequence.new(0.62, 1), Rotation = 90, Parent = artGloss })
		        View.title = raw(label(music, {
		            Position = UDim2.fromOffset(82, 20),
		            Size = UDim2.fromOffset(190, 20),
		            Text = "",
		            FontFace = Fonts.Semibold,
		            TextSize = 16,
		            TextTruncate = Enum.TextTruncate.AtEnd,
		        }))
		        View.mood = raw(label(music, {
		            Position = UDim2.fromOffset(82, 42),
		            Size = UDim2.fromOffset(190, 16),
		            Text = "",
		            FontFace = Fonts.Regular,
		            TextSize = 12,
		            TextColor3 = Static.LightGray,
		            TextTruncate = Enum.TextTruncate.AtEnd,
		        }))
		        View.bars = {}
		        local barsFrame = new("Frame", {
		            Position = UDim2.fromOffset(PAGE_W - 16 - 23, 30),
		            Size = UDim2.fromOffset(23, 18),
		            BackgroundTransparency = 1,
		            Parent = music,
		        })
		        for index = 1, 5 do
		            local bar = box({
		                AnchorPoint = Vector2.new(0, 1),
		                Position = UDim2.new(0, (index - 1) * 5, 1, 0),
		                Size = UDim2.fromOffset(3, 4),
		                BackgroundColor3 = Static.Green,
		                Parent = barsFrame,
		            })
		            corner(2, bar)
		            View.bars[index] = bar
		        end
		        View.rail, View.fill, View.knob = rail(music, 16, 80, 308, 5, Static.White, 11)
		        View.elapsed = raw(label(music, {
		            Position = UDim2.fromOffset(16, 92),
		            Size = UDim2.fromOffset(70, 14),
		            Text = "0:00",
		            FontFace = Fonts.Medium,
		            TextSize = 11,
		            TextColor3 = Static.LightGray,
		        }))
		        View.total = raw(label(music, {
		            Position = UDim2.fromOffset(PAGE_W - 16 - 70, 92),
		            Size = UDim2.fromOffset(70, 14),
		            Text = "-:--",
		            FontFace = Fonts.Medium,
		            TextSize = 11,
		            TextColor3 = Static.LightGray,
		            TextXAlignment = Enum.TextXAlignment.Right,
		        }))
		        View.railHit = new("TextButton", {
		            Position = UDim2.fromOffset(10, 68),
		            Size = UDim2.fromOffset(320, 28),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            Text = "",
		            ZIndex = 6,
		            Parent = music,
		        })

