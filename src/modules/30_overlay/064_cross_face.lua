--[[ xngot-studio · src/modules/30_overlay/064_cross_face.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.cross_face
     role   : Mặt AI: shell, face, pose, renderLine, cử động
     source : main 2.txt L5359-6021 · 663 dòng · delta +0
--]]
		    do
		        local HEAD = rgb(17, 19, 27)
		        local PINK = rgb(255, 112, 146)
		        local DROP = rgb(120, 200, 255)
		        local SHADE = rgb(6, 7, 10)
		        local HEART = rgb(255, 96, 128)

		        local NEUTRAL = {
		            eyeW = 1, eyeH = 1, lidB = 0, lidT = 0, tilt = 0, browY = 0, browTilt = 0, browA = 0,
		            smile = 0.35, mouthW = 0.34, open = 0, cheek = 0, shade = 0, heart = 0, sweat = 0,
		            gx = 0, gy = 0, winkR = 0, markA = 0,
		        }

		        local MOODS = {
		            neutral = {},
		            happy = { lidB = 0.58, smile = 0.95, cheek = 0.55, mouthW = 0.38 },
		            joy = { lidB = 0.62, smile = 1, cheek = 0.85, mouthW = 0.46, open = 0.38 },
		            think = { gx = 0.9, gy = -0.9, smile = 0, browA = 0.85, browY = 0.6, browTilt = -8, mouthW = 0.2, eyeH = 0.92, mark = "…" },
		            sad = { lidT = 0.34, tilt = -17, smile = -0.85, browA = 0.9, browTilt = -15, browY = 0.1, mouthW = 0.26, eyeH = 0.95 },
		            angry = { lidT = 0.36, tilt = 17, smile = -0.55, browA = 0.9, browTilt = 16, browY = -0.4, mouthW = 0.3 },
		            surprised = { eyeW = 1.2, eyeH = 1.32, open = 0.85, mouthW = 0.2, browA = 0.9, browY = 1, smile = 0, mark = "!" },
		            love = { lidB = 0.5, smile = 0.95, cheek = 0.95, heart = 1, mouthW = 0.38 },
		            sleepy = { lidT = 0.62, smile = 0.1, mouthW = 0.2, browA = 0, mark = "z" },
		            wink = { lidB = 0.15, winkR = 0.8, smile = 0.95, cheek = 0.4, mouthW = 0.4 },
		            cool = { shade = 1, smile = 0.75, mouthW = 0.38 },
		            sweat = { lidT = 0.2, smile = -0.4, sweat = 1, mouthW = 0.3, browA = 0.85, browTilt = 11 },
		            confused = { gx = -0.7, smile = -0.2, browA = 0.9, browTilt = 13, mouthW = 0.22, mark = "?" },
		            listen = { eyeW = 1.1, eyeH = 1.14, smile = 0.25, browA = 0.55, browY = 0.7 },
		        }

		        for key, value in pairs(NEUTRAL) do
		            Cross.Pose[key] = value
		            Cross.Target[key] = value
		        end
		        Cross.Pose.open = 0

		        local blink = { Next = 2, Start = -10, Value = 0 }
		        local wander = { Next = 1, X = 0, Y = 0, CX = 0, CY = 0 }
		        local openSmooth = 0
		        local clock = 0
		        local lastAccent
		        local glow = Static.White

		        function Cross.setMood(name, hold)
		            local def = MOODS[name] or MOODS.neutral
		            Cross.Mood = MOODS[name] and name or "neutral"
		            for key, value in pairs(NEUTRAL) do
		                local target = def[key]
		                Cross.Target[key] = target ~= nil and target or value
		            end
		            Cross.MarkText = def.mark or Cross.MarkText
		            Cross.Target.markA = def.mark and 1 or 0
		            Cross.MoodUntil = hold and hold > 0 and os.clock() + hold or 0
		        end

		        function Cross.speak(seconds)
		            Cross.SpeakUntil = os.clock() + math.clamp(seconds, 0.6, 7)
		        end

		        local function prefix(source, count)
		            local length = utf8.len(source)
		            if not length then
		                return string.sub(source, 1, count)
		            end
		            if count >= length then
		                return source
		            end
		            if count <= 0 then
		                return ""
		            end
		            return string.sub(source, 1, utf8.offset(source, count + 1) - 1)
		        end
		        Cross.prefix = prefix

		        function Cross.length(source)
		            return utf8.len(source) or #source
		        end

		        function Cross.say(role, value)
		            local previous = Cross.Bubble.Entry
		            if previous then
		                previous.Shown = previous.Text
		            end
		            local entry = { Role = role, Text = value, Shown = role == "cross" and "" or value, At = os.clock() }
		            table.insert(Cross.Chat, entry)
		            if #Cross.Chat > 60 then
		                table.remove(Cross.Chat, 1)
		            end
		            Cross.ChatVersion = Cross.ChatVersion + 1
		            if role == "cross" then
		                Cross.Bubble.Full = value
		                Cross.Bubble.Count = 0
		                Cross.Bubble.Shown = ""
		                Cross.Bubble.Entry = entry
		                Cross.speak(Cross.length(value) / Cross.Bubble.Rate + 0.4)
		            else
		                Cross.Echo = value
		            end
		            return entry
		        end

		        local function hex(color)
		            return string.format("%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
		        end

		        local function escape(source)
		            source = string.gsub(source, "&", "&amp;")
		            source = string.gsub(source, "<", "&lt;")
		            source = string.gsub(source, ">", "&gt;")
		            return source
		        end
		        Cross.escape = escape

		        local COLORS = {
		            prompt = "EEEDF0",
		            cmd = "FFEB64",
		            arg = "64DCE6",
		            out = "C8D3E6",
		            ok = "50FA7B",
		            warn = "FFC46B",
		            err = "FF6B6B",
		            dim = "7C8CA8",
		        }
		        Cross.ShellColors = COLORS

		        function Cross.renderLine(line, cursor)
		            local parts = {}
		            local left = line.Shown or math.huge
		            for _, segment in ipairs(line.Segs) do
		                if left <= 0 then
		                    break
		                end
		                local value = segment[1]
		                local length = Cross.length(value)
		                if length > left then
		                    value = prefix(value, left)
		                    left = 0
		                else
		                    left = left - length
		                end
		                parts[#parts + 1] = string.format('<font color="#%s">%s</font>', segment[2], escape(value))
		            end
		            if cursor then
		                parts[#parts + 1] = '<font color="#EEEDF0">_</font>'
		            end
		            return table.concat(parts)
		        end

		        function Cross.shellAdd(segments, typed)
		            local line = { Segs = segments, Shown = typed and 0 or nil }
		            table.insert(Cross.Shell.Lines, line)
		            if #Cross.Shell.Lines > 80 then
		                table.remove(Cross.Shell.Lines, 1)
		            end
		            Cross.Shell.Version = Cross.Shell.Version + 1
		            return line
		        end

		        function Cross.shellTouch()
		            Cross.Shell.Version = Cross.Shell.Version + 1
		        end

		        function Cross.shellText(kind, value)
		            local width = 46
		            local color = COLORS[kind] or COLORS.out
		            local first = true
		            local words = {}
		            for word in string.gmatch(value, "%S+") do
		                words[#words + 1] = word
		            end
		            local current = ""
		            local function flush()
		                Cross.shellAdd({ { (first and "" or "  ") .. current, color } })
		                first = false
		                current = ""
		            end
		            for _, word in ipairs(words) do
		                if current == "" then
		                    current = word
		                elseif Cross.length(current) + 1 + Cross.length(word) > width then
		                    flush()
		                    current = word
		                else
		                    current = current .. " " .. word
		                end
		            end
		            if current ~= "" then
		                flush()
		            end
		        end

		        -- Mirror actual Cross messages only; no simulated command or shell execution.
		        do
		            local say = Cross.say
		            function Cross.say(role, value)
		                local entry = say(role, value)
		                pcall(function()
		                    local text = tostring(value or "")
		                    local low = text:lower()
		                    local sensitive = low:find("password",1,true) or low:find("token",1,true) or low:find("secret",1,true)
		                        or low:find("api key",1,true) or low:find("mat khau",1,true) or low:find("mật khẩu",1,true)
		                        or low:find("cookie",1,true) or low:find("https://",1,true) or low:find("http://",1,true) or low:find("@",1,true)
		                    if sensitive then text = Cross.Lang == "en" and "[Potentially sensitive content hidden]" or "[Đã ẩn nội dung có thể nhạy cảm]" end
		                    text = text:sub(1, 500)
		                    Cross.shellText(role == "user" and "cmd" or "out", (role == "user" and "> " or "Cross: ") .. text)
		                end)
		                return entry
		            end
		        end

		        local function makeLabel(parent, props)
		            props.BackgroundTransparency = 1
		            props.BorderSizePixel = 0
		            props.Parent = parent
		            return new("TextLabel", props)
		        end

		        local codeFace = Fonts.Medium
		        pcall(function()
		            codeFace = Font.fromEnum(Enum.Font.Code)
		        end)

		        function Cross.buildShell(parent, props)
		            local rows = props.Rows or 8
		            local textSize = props.TextSize or 11
		            local lineHeight = props.LineHeight or 14
		            local frame = box({
		                Name = "CrossShell",
		                Position = props.Position,
		                Size = props.Size,
		                BackgroundColor3 = rgb(1, 36, 86),
		                ClipsDescendants = true,
		                ZIndex = props.ZIndex or 5,
		                Parent = parent,
		            })
		            corner(props.Radius or 10, frame)
		            stroke(frame, Static.White, 0.86, 1)
		            local header = makeLabel(frame, {
		                Name = "Header",
		                Position = UDim2.fromOffset(10, 5),
		                Size = UDim2.new(1, -20, 0, 14),
		                Text = "Cross · Activity log",
		                FontFace = codeFace,
		                TextSize = 10,
		                TextColor3 = rgb(138, 160, 200),
		                TextXAlignment = Enum.TextXAlignment.Left,
		                TextTruncate = Enum.TextTruncate.AtEnd,
		                ZIndex = (props.ZIndex or 5) + 1,
		            })
		            header:SetAttribute("BoncutiRaw", true)
		            local scroll = new("ScrollingFrame", {
		                Name = "Log", Position = UDim2.fromOffset(10, 22), Size = UDim2.new(1, -20, 1, -25),
		                BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		                CanvasSize = UDim2.fromOffset(0, 0), ScrollingDirection = Enum.ScrollingDirection.Y,
		                ZIndex = (props.ZIndex or 5) + 1, Parent = frame,
		            })
		            local labels = {}
		            for index = 1, 80 do
		                local label = makeLabel(scroll, {
		                    Name = "Line" .. index,
		                    Position = UDim2.fromOffset(0, (index - 1) * lineHeight),
		                    Size = UDim2.new(1, -4, 0, lineHeight),
		                    Text = "", FontFace = codeFace, TextSize = textSize,
		                    TextColor3 = rgb(238, 237, 240), TextXAlignment = Enum.TextXAlignment.Left,
		                    TextTruncate = Enum.TextTruncate.AtEnd, RichText = true,
		                    ZIndex = (props.ZIndex or 5) + 2,
		                })
		                label:SetAttribute("BoncutiRaw", true)
		                labels[index] = label
		            end
		            local shell = { Frame = frame, Scroll = scroll, Labels = labels, Rows = rows, Version = -1, Cursor = false, Active = props.Active }
		            function shell.Refresh(force, cursor)
		                if not force and shell.Version == Cross.Shell.Version and shell.Cursor == cursor then return end
		                -- New content and reopening the shell follow the newest line. A cursor blink alone must not interrupt manual scrolling.
		                local follow = force or shell.Version ~= Cross.Shell.Version
		                shell.Version = Cross.Shell.Version; shell.Cursor = cursor
		                local lines = Cross.Shell.Lines
		                local total = #lines
		                scroll.CanvasSize = UDim2.fromOffset(0, total * lineHeight)
		                for index = 1, 80 do
		                    local line, label = lines[index], labels[index]
		                    local value = line and Cross.renderLine(line, cursor and index == total) or ""
		                    if label.Text ~= value then label.Text = value end
		                end
		                if follow then
		                    scroll.CanvasPosition = Vector2.new(0, total * lineHeight)
		                    local version = shell.Version
		                    task.defer(function()
		                        if scroll.Parent and shell.Version == version and Cross.Shell.Version == version then
		                            scroll.CanvasPosition = Vector2.new(0, #Cross.Shell.Lines * lineHeight)
		                        end
		                    end)
		                end
		            end
		            table.insert(Cross.Shells, shell)
		            return shell
		        end

		        function Cross.buildFace(parent, size, position, props)
		            props = props or {}
		            local S = size
		            local z = props.ZIndex or 3
		            local root = new("Frame", {
		                Name = "CrossFace",
		                Position = position,
		                Size = UDim2.fromOffset(S, S),
		                BackgroundTransparency = 1,
		                ZIndex = z,
		                Parent = parent,
		            })
		            local head = box({
		                Name = "Head",
		                AnchorPoint = Vector2.new(0.5, 0.5),
		                Position = UDim2.fromScale(0.5, 0.5),
		                Size = UDim2.fromScale(1, 1),
		                BackgroundColor3 = HEAD,
		                ZIndex = z,
		                Parent = root,
		            })
		            corner(S * 0.3, head)
		            local scale = new("UIScale", { Parent = head })
		            local rim = stroke(head, P.Accent, 0.4, 1.5)
		            local face = { Root = root, Head = head, Scale = scale, Rim = rim, Eyes = {}, Brows = {}, Cheeks = {}, Hearts = {}, Lens = {}, Glints = {}, Active = props.Active, Size = S }

		            for index = 1, 2 do
		                local cheek = box({
		                    AnchorPoint = Vector2.new(0.5, 0.5),
		                    Size = UDim2.fromOffset(S * 0.17, S * 0.09),
		                    BackgroundColor3 = PINK,
		                    BackgroundTransparency = 1,
		                    ZIndex = z + 1,
		                    Parent = head,
		                })
		                corner(S, cheek)
		                face.Cheeks[index] = cheek
		            end

		            for index = 1, 2 do
		                local eye = box({
		                    Name = "Eye" .. index,
		                    AnchorPoint = Vector2.new(0.5, 0.5),
		                    Size = UDim2.fromOffset(S * 0.15, S * 0.2),
		                    BackgroundColor3 = Static.White,
		                    ClipsDescendants = true,
		                    ZIndex = z + 2,
		                    Parent = head,
		                })
		                local round = corner(S * 0.075, eye)
		                local lidTop = box({
		                    AnchorPoint = Vector2.new(0.5, 1),
		                    Size = UDim2.fromOffset(S * 0.36, S * 0.2),
		                    BackgroundColor3 = HEAD,
		                    ZIndex = z + 3,
		                    Parent = eye,
		                })
		                local lidBottom = box({
		                    AnchorPoint = Vector2.new(0.5, 0),
		                    Size = UDim2.fromOffset(S * 0.26, S * 0.24),
		                    BackgroundColor3 = HEAD,
		                    ZIndex = z + 3,
		                    Parent = eye,
		                })
		                new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = lidBottom })
		                face.Eyes[index] = { Eye = eye, Round = round, LidTop = lidTop, LidBottom = lidBottom }

		                local brow = box({
		                    AnchorPoint = Vector2.new(0.5, 0.5),
		                    Size = UDim2.fromOffset(S * 0.2, 3),
		                    BackgroundColor3 = Static.White,
		                    BackgroundTransparency = 1,
		                    ZIndex = z + 2,
		                    Parent = head,
		                })
		                corner(2, brow)
		                face.Brows[index] = brow

		                local lens = box({
		                    AnchorPoint = Vector2.new(0.5, 0.5),
		                    Size = UDim2.fromOffset(S * 0.3, S * 0.15),
		                    BackgroundColor3 = SHADE,
		                    BackgroundTransparency = 1,
		                    ZIndex = z + 5,
		                    Parent = head,
		                })
		                corner(S * 0.05, lens)
		                local lensLine = stroke(lens, Static.White, 1, 1.5)
		                local glint = box({
		                    AnchorPoint = Vector2.new(0.5, 0.5),
		                    Position = UDim2.fromScale(0.3, 0.38),
		                    Size = UDim2.fromOffset(S * 0.1, 2),
		                    BackgroundColor3 = Static.White,
		                    BackgroundTransparency = 1,
		                    Rotation = -28,
		                    ZIndex = z + 6,
		                    Parent = lens,
		                })
		                face.Lens[index] = { Lens = lens, Line = lensLine }
		                face.Glints[index] = glint

		                local heart = makeLabel(head, {
		                    AnchorPoint = Vector2.new(0.5, 0.5),
		                    Size = UDim2.fromOffset(S * 0.3, S * 0.3),
		                    Text = "♥",
		                    FontFace = Fonts.Bold,
		                    TextSize = math.floor(S * 0.24),
		                    TextColor3 = HEART,
		                    TextTransparency = 1,
		                    ZIndex = z + 6,
		                })
		                heart:SetAttribute("BoncutiRaw", true)
		                face.Hearts[index] = heart
		            end

		            face.Bridge = box({
		                AnchorPoint = Vector2.new(0.5, 0.5),
		                Size = UDim2.fromOffset(S * 0.1, 3),
		                BackgroundColor3 = SHADE,
		                BackgroundTransparency = 1,
		                ZIndex = z + 5,
		                Parent = head,
		            })

		            face.MouthClip = new("Frame", {
		                Name = "Mouth",
		                AnchorPoint = Vector2.new(0.5, 0),
		                BackgroundTransparency = 1,
		                ClipsDescendants = true,
		                ZIndex = z + 2,
		                Parent = head,
		            })
		            face.MouthRing = new("Frame", {
		                BackgroundTransparency = 1,
		                ZIndex = z + 2,
		                Parent = face.MouthClip,
		            })
		            new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = face.MouthRing })
		            face.MouthLine = new("UIStroke", {
		                Color = Static.White,
		                Thickness = math.max(2, S * 0.035),
		                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		                Parent = face.MouthRing,
		            })
		            face.Open = box({
		                AnchorPoint = Vector2.new(0.5, 0),
		                BackgroundColor3 = Static.White,
		                BackgroundTransparency = 1,
		                ZIndex = z + 2,
		                Parent = head,
		            })
		            new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = face.Open })

		            face.Sweat = box({
		                AnchorPoint = Vector2.new(0.5, 0),
		                Size = UDim2.fromOffset(S * 0.07, S * 0.11),
		                BackgroundColor3 = DROP,
		                BackgroundTransparency = 1,
		                ZIndex = z + 4,
		                Parent = head,
		            })
		            corner(S, face.Sweat)

		            face.Mark = makeLabel(head, {
		                AnchorPoint = Vector2.new(0.5, 0.5),
		                Position = UDim2.fromScale(0.84, 0.16),
		                Size = UDim2.fromOffset(S * 0.3, S * 0.3),
		                Text = "",
		                FontFace = Fonts.Bold,
		                TextSize = math.floor(S * 0.22),
		                TextColor3 = Static.White,
		                TextTransparency = 1,
		                ZIndex = z + 6,
		            })
		            face.Mark:SetAttribute("BoncutiRaw", true)

		            local gloss = box({
		                Name = "Shine",
		                Size = UDim2.fromScale(1, 1),
		                BackgroundColor3 = Static.White,
		                ZIndex = z + 7,
		                Parent = head,
		            })
		            corner(S * 0.3, gloss)
		            new("UIGradient", {
		                Transparency = NumberSequence.new({
		                    NumberSequenceKeypoint.new(0, 0.86),
		                    NumberSequenceKeypoint.new(0.5, 1),
		                    NumberSequenceKeypoint.new(1, 1),
		                }),
		                Rotation = 90,
		                Parent = gloss,
		            })

		            table.insert(Cross.Faces, face)
		            return face
		        end

		        local function applyFace(face, pose, now, wx, wy, blinkValue, open)
		            local S = face.Size
		            face.Scale.Scale = 1 + math.sin(now * 1.8) * 0.012
		            local baseW, baseH = S * 0.15, S * 0.2
		            local gap = S * 0.17
		            local eyeY = S * 0.4
		            local eyeW = baseW * pose.eyeW
		            for index = 1, 2 do
		                local side = index == 1 and -1 or 1
		                local part = face.Eyes[index]
		                local wink = index == 2 and pose.winkR or 0
		                local height = math.max(baseH * pose.eyeH * (1 - 0.94 * blinkValue), 2)
		                local cx = S / 2 + side * gap + (pose.gx + wx) * S * 0.05
		                local cy = eyeY + (pose.gy + wy) * S * 0.045
		                part.Eye.Position = UDim2.fromOffset(cx, cy)
		                part.Eye.Size = UDim2.fromOffset(eyeW, height)
		                part.Eye.BackgroundColor3 = glow
		                part.Eye.BackgroundTransparency = math.clamp(pose.heart * 1.2, 0, 1)
		                part.Round.CornerRadius = UDim.new(0, eyeW / 2)
		                part.LidTop.Size = UDim2.fromOffset(eyeW * 2.4, height)
		                part.LidTop.Position = UDim2.fromOffset(eyeW / 2, height * pose.lidT)
		                part.LidTop.Rotation = -side * pose.tilt
		                local bottom = math.clamp(pose.lidB + wink, 0, 1)
		                part.LidBottom.Size = UDim2.fromOffset(eyeW * 1.7, height * 1.25)
		                part.LidBottom.Position = UDim2.fromOffset(eyeW / 2, height * (1 - bottom * 0.9))

		                local brow = face.Brows[index]
		                brow.BackgroundColor3 = glow
		                brow.BackgroundTransparency = 1 - pose.browA
		                brow.Size = UDim2.fromOffset(eyeW * 1.35, 3)
		                brow.Position = UDim2.fromOffset(cx, cy - baseH * pose.eyeH / 2 - 7 - pose.browY * 5)
		                brow.Rotation = -side * pose.browTilt

		                local cheek = face.Cheeks[index]
		                cheek.Position = UDim2.fromOffset(S / 2 + side * (gap + S * 0.07), S * 0.6)
		                cheek.BackgroundTransparency = 1 - 0.5 * pose.cheek

		                local lens = face.Lens[index]
		                lens.Lens.Position = UDim2.fromOffset(cx, cy)
		                lens.Lens.Size = UDim2.fromOffset(eyeW * 2.2, math.max(baseH * 0.78, S * 0.14))
		                lens.Lens.BackgroundTransparency = 1 - pose.shade
		                lens.Line.Color = glow
		                lens.Line.Transparency = 1 - 0.65 * pose.shade
		                face.Glints[index].BackgroundTransparency = 1 - 0.55 * pose.shade

		                local heart = face.Hearts[index]
		                heart.Position = UDim2.fromOffset(cx, cy)
		                heart.TextColor3 = HEART
		                heart.TextTransparency = 1 - pose.heart
		                heart.TextSize = math.floor(S * 0.24 * (1 + 0.1 * math.sin(now * 8)))
		            end
		            face.Bridge.Position = UDim2.fromOffset(S / 2 + (pose.gx + wx) * S * 0.05, eyeY + (pose.gy + wy) * S * 0.045)
		            face.Bridge.BackgroundTransparency = 1 - pose.shade

		            local mouthY = S * 0.66
		            local mouthW = S * pose.mouthW
		            local thick = math.max(2, S * 0.035)
		            local deep = thick + math.abs(pose.smile) * S * 0.09
		            face.MouthClip.Position = UDim2.fromOffset(S / 2, mouthY - deep / 2)
		            face.MouthClip.Size = UDim2.fromOffset(mouthW, deep)
		            local ringHeight = math.max(2 * (deep - thick), 0.5)
		            face.MouthRing.Size = UDim2.fromOffset(math.max(mouthW - 2 * thick, 1), ringHeight)
		            face.MouthRing.Position = UDim2.fromOffset(thick, pose.smile >= 0 and -(deep - thick) or thick)
		            face.MouthLine.Color = glow
		            face.MouthLine.Transparency = math.clamp(open * 4, 0, 1)

		            local openHeight = S * 0.025 + open * S * 0.2
		            local openWidth = mouthW * (0.5 + 0.35 * open)
		            face.Open.Size = UDim2.fromOffset(openWidth, openHeight)
		            face.Open.Position = UDim2.fromOffset(S / 2, mouthY - S * 0.02)
		            face.Open.BackgroundColor3 = glow
		            face.Open.BackgroundTransparency = 1 - math.clamp(open * 5, 0, 1)

		            local drip = (now * 0.55) % 1
		            face.Sweat.Position = UDim2.fromOffset(S * 0.8, S * 0.12 + drip * S * 0.16)
		            face.Sweat.BackgroundTransparency = 1 - pose.sweat * (1 - drip * drip) * 0.9

		            face.Mark.Text = Cross.MarkText
		            face.Mark.TextColor3 = glow
		            face.Mark.TextTransparency = 1 - pose.markA
		            face.Mark.Position = UDim2.fromScale(0.84, 0.16 + (Cross.MarkText == "z" and math.sin(now * 2.2) * 0.04 or 0))
		        end

		        Hooks.Register(function(dt)
		            clock = clock + dt
		            local now = os.clock()
		            if Cross.MoodUntil > 0 and now >= Cross.MoodUntil then
		                Cross.setMood(Cross.Idle or "neutral")
		            end
		            local alpha = 1 - math.exp(-dt * 11)
		            local pose, target = Cross.Pose, Cross.Target
		            for key, value in pairs(target) do
		                pose[key] = pose[key] + (value - pose[key]) * alpha
		            end

		            local anyActive = false
		            for _, face in ipairs(Cross.Faces) do
		                if face.Active and face.Active() then
		                    anyActive = true
		                end
		            end
		            local anyShell = false
		            for _, shell in ipairs(Cross.Shells) do
		                if shell.Active and shell.Active() then
		                    anyShell = true
		                end
		            end

		            local bubble = Cross.Bubble
		            if Cross.Thinking then
		                local dots = string.rep(".", 1 + math.floor(now * 3) % 3)
		                if bubble.Shown ~= dots then
		                    bubble.Shown = dots
		                end
		            elseif bubble.Full ~= "" and bubble.Count < Cross.length(bubble.Full) then
		                bubble.Count = bubble.Count + dt * bubble.Rate
		                local shown = prefix(bubble.Full, math.floor(bubble.Count))
		                if shown ~= bubble.Shown then
		                    bubble.Shown = shown
		                    if bubble.Entry then
		                        bubble.Entry.Shown = shown
		                        Cross.ChatVersion = Cross.ChatVersion + 1
		                    end
		                end
		            elseif bubble.Entry and bubble.Entry.Shown ~= bubble.Entry.Text then
		                bubble.Shown = bubble.Full
		                bubble.Entry.Shown = bubble.Entry.Text
		                Cross.ChatVersion = Cross.ChatVersion + 1
		            end

		            if anyShell then
		                local cursor = math.floor(now * 2) % 2 == 0
		                for _, shell in ipairs(Cross.Shells) do
		                    if shell.Active and shell.Active() then
		                        shell.Refresh(false, cursor)
		                    end
		                end
		            end

		            if not anyActive then
		                return
		            end

		            if now >= blink.Next then
		                blink.Start = now
		                blink.Next = now + 2.2 + math.random() * 3.2
		                if math.random() < 0.18 then
		                    blink.Next = now + 0.32
		                end
		            end
		            local since = now - blink.Start
		            blink.Value = since >= 0 and since < 0.17 and math.sin(math.pi * since / 0.17) or 0

		            if now >= wander.Next then
		                wander.Next = now + 1.3 + math.random() * 2.2
		                wander.X = (math.random() - 0.5) * 1.1
		                wander.Y = (math.random() - 0.5) * 0.7
		            end
		            local calm = Cross.Mood == "neutral" or Cross.Mood == "happy" or Cross.Mood == "cool" or Cross.Mood == "listen"
		            local fade = 1 - math.exp(-dt * 5)
		            wander.CX = wander.CX + ((calm and wander.X or 0) - wander.CX) * fade
		            wander.CY = wander.CY + ((calm and wander.Y or 0) - wander.CY) * fade

		            local speaking = now < Cross.SpeakUntil
		            local goal = Cross.Target.open
		            if speaking then
		                local talk = 0.2 + 0.5 * math.abs(math.sin(now * 9.5)) * (0.55 + 0.45 * math.sin(now * 2.7 + 1))
		                goal = math.max(goal, talk)
		            end
		            openSmooth = openSmooth + (goal - openSmooth) * (1 - math.exp(-dt * 22))

		            local accent = P.Accent
		            if accent ~= lastAccent then
		                lastAccent = accent
		                glow = Color3.new(accent.R + (1 - accent.R) * 0.74, accent.G + (1 - accent.G) * 0.74, accent.B + (1 - accent.B) * 0.74)
		            end

		            local anyFace = false
		            for _, face in ipairs(Cross.Faces) do
		                if face.Active and face.Active() and face.Root and face.Root.Visible then
		                    anyFace = true
		                    face.Rim.Color = accent
		                    applyFace(face, pose, now, wander.CX, wander.CY, blink.Value, openSmooth)
		                end
		            end
		            Cross.AnyFace = anyFace
		        end, 2)

		        Cross.setMood("neutral")
		    end

