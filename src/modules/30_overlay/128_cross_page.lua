--[[ xngot-studio · src/modules/30_overlay/128_cross_page.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.cross_page
     role   : Trang Cross: crossActive, crossSend, crossFocus, crossMode
     source : main 2.txt L9432-9824 · 393 dòng · delta +0
--]]
		        local function crossActive(mode)
		            return Island.Expanded and View.Current == "Cross" and View.CrossMode == mode
		        end

		        View.crossFace = Cross.buildFace(View.crossChat, 66, UDim2.fromOffset(12, 12), {
		            ZIndex = 4,
		            Active = function()
		                return crossActive("chat")
		            end,
		        })

		        View.crossBubble = box({
		            Name = "Bubble",
		            Position = UDim2.fromOffset(88, 12),
		            Size = UDim2.fromOffset(240, 68),
		            BackgroundColor3 = Static.White,
		            BackgroundTransparency = 0.9,
		            ZIndex = 4,
		            Parent = View.crossChat,
		        })
		        corner(14, View.crossBubble)
		        stroke(View.crossBubble, Static.White, 0.9, 1)
		        View.crossScroll = new("ScrollingFrame", {
		            Name = "BubbleScroll",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            ScrollBarThickness = 2,
		            CanvasSize = UDim2.new(0, 0, 0, 0),
		            AutomaticCanvasSize = Enum.AutomaticSize.Y,
		            ScrollingDirection = Enum.ScrollingDirection.Y,
		            ZIndex = 5,
		            Parent = View.crossBubble,
		        })
		        new("UIPadding", {
		            PaddingLeft = UDim.new(0, 10),
		            PaddingRight = UDim.new(0, 10),
		            PaddingTop = UDim.new(0, 7),
		            PaddingBottom = UDim.new(0, 7),
		            Parent = View.crossScroll,
		        })
		        View.crossText = raw(label(View.crossScroll, {
		            Size = UDim2.new(1, 0, 0, 0),
		            AutomaticSize = Enum.AutomaticSize.Y,
		            Text = "",
		            FontFace = Fonts.Medium,
		            TextSize = 12,
		            TextWrapped = true,
		            TextYAlignment = Enum.TextYAlignment.Top,
		            ZIndex = 6,
		        }))
		        View.crossScroll.InputBegan:Connect(function()
		            View.SeekStamp = os.clock()
		            View.Touched = os.clock()
		        end)

		        View.crossEcho = raw(label(View.crossChat, {
		            Position = UDim2.fromOffset(90, 84),
		            Size = UDim2.fromOffset(238, 20),
		            Text = "",
		            FontFace = Fonts.Regular,
		            TextSize = 11,
		            TextColor3 = Static.LightGray,
		            TextTruncate = Enum.TextTruncate.AtEnd,
		            ZIndex = 5,
		        }))

		        View.crossShellBtn = action(View.crossChat, 12, 84, 68, 22, "Shell", nil, function()
		            View.crossMode("shell")
		        end)
		        View.crossShellBtn.TextSize = 11

		        View.crossStop = action(View.crossChat, 272, 84, 56, 22, "Dừng", Static.Red, function()
		            if Cross.Body then
		                Cross.Body.stop("button")
		            end
		        end)
		        View.crossStop.TextSize = 11
		        View.crossStop.Visible = false

		        View.crossField = box({
		            Name = "Field",
		            Position = UDim2.fromOffset(12, 112),
		            Size = UDim2.fromOffset(264, 32),
		            BackgroundColor3 = Static.White,
		            BackgroundTransparency = 0.9,
		            ZIndex = 4,
		            Parent = View.crossChat,
		        })
		        corner(16, View.crossField)
		        View.crossFieldLine = stroke(View.crossField, Static.White, 0.88, 1)
		        View.crossBox = new("TextBox", {
		            Name = "Input",
		            Position = UDim2.fromOffset(14, 0),
		            Size = UDim2.new(1, -28, 1, 0),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            ClearTextOnFocus = false,
		            Text = "",
		            PlaceholderText = translate("Nhắn cho Cross…"),
		            PlaceholderColor3 = Static.Gray,
		            FontFace = Fonts.Regular,
		            TextSize = 13,
		            TextColor3 = Static.White,
		            TextXAlignment = Enum.TextXAlignment.Left,
		            TextTruncate = Enum.TextTruncate.AtEnd,
		            ZIndex = 6,
		            Parent = View.crossField,
		        })
		        raw(View.crossBox)
		        table.insert(Cross.Inputs, View.crossBox)

		        local function crossSend()
		            local value = View.crossBox.Text
		            View.crossBox.Text = ""
		            if value ~= "" then
		                Cross.ask(value)
		            end
		        end

		        function View.crossFocus()
		            local field = View.crossBox
		            if not Island.Expanded or View.Current ~= "Cross" or View.CrossMode ~= "chat" then
		                return
		            end
		            pcall(function()
		                field:CaptureFocus()
		            end)
		            task.defer(function()
		                if #field.Text <= 1 then
		                    field.Text = ""
		                end
		            end)
		        end

		        View.crossBox.Focused:Connect(function()
		            View.Touched = os.clock()
		            tween(View.crossFieldLine, 0.2, { Color = P.Accent, Transparency = 0.1 })
		        end)
		        View.crossBox.FocusLost:Connect(function(enterPressed)
		            View.Touched = os.clock()
		            tween(View.crossFieldLine, 0.2, { Color = Static.White, Transparency = 0.88 })
		            if enterPressed then
		                crossSend()
		                task.delay(0.05, View.crossFocus)
		            end
		        end)
		        View.crossBox:GetPropertyChangedSignal("Text"):Connect(function()
		            View.Touched = os.clock()
		        end)
		        View.crossBox.InputBegan:Connect(function()
		            View.SeekStamp = os.clock()
		        end)

		        View.crossSend = action(View.crossChat, 282, 112, 46, 32, "Gửi", Static.Blue, function()
		            crossSend()
		            View.crossFocus()
		        end)

		        View.crossShell = Cross.buildShell(View.crossTerm, {
		            Position = UDim2.fromOffset(12, 12),
		            Size = UDim2.fromOffset(316, 94),
		            Rows = 4,
		            Radius = 12,
		            ZIndex = 3,
		            Active = function()
		                return crossActive("shell")
		            end,
		        })
		        View.crossChatBtn = action(View.crossTerm, 262, 15, 58, 18, "Chat", nil, function()
		            View.crossMode("chat")
		        end)
		        View.crossChatBtn.TextSize = 11
		        View.crossChatBtn.ZIndex = 8

		        -- The shell sends the same natural-language commands as chat; it is not an OS shell.
		        View.crossShellField = box({
		            Name = "ShellField", Position = UDim2.fromOffset(12, 112), Size = UDim2.fromOffset(264, 32),
		            BackgroundColor3 = Static.White, BackgroundTransparency = 0.9, ZIndex = 4, Parent = View.crossTerm,
		        })
		        corner(16, View.crossShellField)
		        View.crossShellBox = new("TextBox", {
		            Name = "ShellInput", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 1, 0),
		            BackgroundTransparency = 1, BorderSizePixel = 0, ClearTextOnFocus = false, Text = "",
		            PlaceholderText = translate("Nhắn cho Cross…"), PlaceholderColor3 = Static.Gray,
		            FontFace = Fonts.Regular, TextSize = 13, TextColor3 = Static.White,
		            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		            ZIndex = 6, Parent = View.crossShellField,
		        })
		        raw(View.crossShellBox)
		        table.insert(Cross.Inputs, View.crossShellBox)
		        local function crossShellSend()
		            local value = View.crossShellBox.Text
		            View.crossShellBox.Text = ""
		            if value == "" then return end
		            if #value > 500 then
		                Cross.say("cross", Cross.Lang == "en" and "Request too long (maximum 500 bytes)." or "Yêu cầu quá dài (tối đa 500 byte).")
		                return
		            end
		            Cross.ask(value)
		        end
		        View.crossShellBox.FocusLost:Connect(function(enterPressed)
		            View.Touched = os.clock()
		            if enterPressed then crossShellSend() end
		        end)
		        View.crossShellBox.InputBegan:Connect(function() View.SeekStamp = os.clock(); View.Touched = os.clock() end)
		        View.crossShellSend = action(View.crossTerm, 282, 112, 46, 32, "Gửi", Static.Blue, crossShellSend)

		        function View.crossMode(mode, instant)
		            if View.CrossMode == mode and not instant then
		                return
		            end
		            View.CrossMode = mode
		            local chat = mode == "chat"
		            local keep, show = View.crossTerm, View.crossChat
		            if not chat then
		                keep, show = View.crossChat, View.crossTerm
		            end
		            if instant then
		                show.Visible = true
		                show.GroupTransparency = 0
		                keep.GroupTransparency = 1
		                keep.Visible = false
		            else
		                show.Visible = true
		                tween(show, 0.26, { GroupTransparency = 0 })
		                tween(keep, 0.16, { GroupTransparency = 1 })
		                task.delay(0.2, function()
		                    if View.CrossMode == mode then
		                        keep.Visible = false
		                    end
		                end)
		            end
		            if not chat then
		                View.crossShell.Refresh(true, false)
		                pcall(function() View.crossBox:ReleaseFocus() end)
		            else
		                pcall(function() View.crossShellBox:ReleaseFocus() end)
		            end
		            View.Touched = os.clock()
		        end

		        View.Updaters.Cross = function()
		            local bubble = Cross.Bubble
		            local shown = bubble.Shown
		            if shown == "" then
		                shown = Settings.Language == "en" and "I'm Cross. Type something, or ask 'what can you do'!" or "Mình là Cross. Nhắn gì đó, hoặc hỏi 'bạn làm được gì' nhé!"
		            end
		            if View.crossText.Text ~= shown then
		                View.crossText.Text = shown
		                View.crossScroll.CanvasPosition = Vector2.new(0, 100000)
		            end
		            put(View.crossEcho, Cross.Echo ~= "" and ("› " .. Cross.Echo) or "")
		            local moving = Cross.Body and Cross.Body.Active and true or false
		            if View.crossStop.Visible ~= moving then
		                View.crossStop.Visible = moving
		                View.crossEcho.Size = UDim2.fromOffset(moving and 176 or 238, 20)
		            end
		            local focused = false
		            pcall(function()
		                focused = View.crossBox:IsFocused() or View.crossShellBox:IsFocused()
		            end)
		            if focused or Cross.Busy > 0 or os.clock() < Cross.SpeakUntil then
		                View.Touched = os.clock()
		            end
		        end

		        Fwd.crossOpen = function(mode, focus)
		            task.spawn(function()
		                local tries = 0
		                while (Island.Alerting or Island.Busy or not State.Ready) and tries < 60 do
		                    task.wait(0.05)
		                    tries = tries + 1
		                end
		                if not Island.Expanded then
		                    Isl.expand("Cross")
		                end
		                if Island.Expanded then
		                    if View.Current ~= "Cross" then
		                        View.show("Cross")
		                    end
		                    View.crossMode("chat")
		                    View.Touched = os.clock()
		                    if focus then
		                        task.wait(0.3)
		                        View.crossFocus()
		                    end
		                end
		            end)
		        end

		        Fwd.crossSync = function()
		            if Island.Expanded then
		                View.refresh()
		            end
		        end

		        View.grabber = box({
		            Name = "Grabber",
		            Position = UDim2.fromOffset(PAGE_W / 2 - 18, 6),
		            Size = UDim2.fromOffset(36, 4),
		            BackgroundColor3 = Static.White,
		            BackgroundTransparency = 0.72,
		            ZIndex = 3,
		            Parent = View.group,
		        })
		        corner(2, View.grabber)
		        View.grabHit = new("TextButton", {
		            Name = "Grab",
		            AnchorPoint = Vector2.new(0.5, 0),
		            Position = UDim2.fromOffset(PAGE_W / 2, 0),
		            Size = UDim2.fromOffset(84, 22),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            Text = "",
		            ZIndex = 8,
		            Parent = View.group,
		        })

		        View.dock = box({
		            Name = "Dock",
		            AnchorPoint = Vector2.new(0.5, 0),
		            Position = UDim2.fromOffset(PAGE_W / 2, DOCK_Y),
		            Size = UDim2.fromOffset(200, 30),
		            BackgroundColor3 = Static.White,
		            BackgroundTransparency = 0.9,
		            ZIndex = 4,
		            Parent = View.group,
		        })
		        corner(15, View.dock)
		        stroke(View.dock, Static.White, 0.9, 1)
		        View.thumb = box({
		            Name = "Thumb",
		            Position = UDim2.fromOffset(3, 3),
		            Size = UDim2.fromOffset(40, 24),
		            BackgroundColor3 = Static.White,
		            BackgroundTransparency = 0.78,
		            ZIndex = 5,
		            Parent = View.dock,
		        })
		        corner(12, View.thumb)
		        shine(View.thumb, 12, 0.7)
		        for _, key in ipairs(PAGE_ORDER) do
		            local tab = box({
		                Class = "TextButton",
		                Name = key,
		                Position = UDim2.fromOffset(3, 3),
		                Size = UDim2.fromOffset(40, 24),
		                BackgroundTransparency = 1,
		                AutoButtonColor = false,
		                Text = translate(PAGE_TITLES[key]),
		                FontFace = Fonts.Semibold,
		                TextSize = 11,
		                TextColor3 = Static.LightGray,
		                Visible = false,
		                ZIndex = 6,
		                Parent = View.dock,
		            })
		            tab.MouseButton1Click:Connect(function()
		                View.Touched = os.clock()
		                playSound("click")
		                View.show(key)
		            end)
		            View.Tabs[key] = tab
		        end

		        View.toast = box({
		            Name = "Toast",
		            Position = UDim2.fromOffset(12, -60),
		            Size = UDim2.fromOffset(PAGE_W - 24, 46),
		            BackgroundColor3 = rgb(30, 30, 36),
		            Visible = false,
		            ZIndex = 9,
		            Parent = View.group,
		        })
		        corner(23, View.toast)
		        stroke(View.toast, Static.White, 0.86, 1)
		        shine(View.toast, 23, 0.9)
		        View.toastIcon = box({
		            Position = UDim2.fromOffset(9, 9),
		            Size = UDim2.fromOffset(28, 28),
		            BackgroundColor3 = Static.Blue,
		            ZIndex = 10,
		            Parent = View.toast,
		        })
		        corner(14, View.toastIcon)
		        View.toastGlyph = raw(label(View.toastIcon, {
		            Size = UDim2.fromScale(1, 1),
		            Text = "i",
		            FontFace = Fonts.Bold,
		            TextSize = 15,
		            TextXAlignment = Enum.TextXAlignment.Center,
		            ZIndex = 11,
		        }))
		        View.toastTitle = raw(label(View.toast, {
		            Position = UDim2.fromOffset(48, 6),
		            Size = UDim2.new(1, -62, 0, 18),
		            Text = "",
		            FontFace = Fonts.Semibold,
		            TextSize = 13,
		            TextTruncate = Enum.TextTruncate.AtEnd,
		            ZIndex = 10,
		        }))
		        View.toastMessage = raw(label(View.toast, {
		            Position = UDim2.fromOffset(48, 25),
		            Size = UDim2.new(1, -62, 0, 14),
		            Text = "",
		            FontFace = Fonts.Regular,
		            TextSize = 11,
		            TextColor3 = Static.LightGray,
		            TextTruncate = Enum.TextTruncate.AtEnd,
		            ZIndex = 10,
		        }))
		        View.toastHit = new("TextButton", {
		            Name = "ToastHit",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            Text = "",
		            ZIndex = 12,
		            Parent = View.toast,
		        })
		        View.toastHit.MouseButton1Click:Connect(function()
		            View.ToastSkip = true
		        end)

