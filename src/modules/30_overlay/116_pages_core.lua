--[[ xngot-studio · src/modules/30_overlay/116_pages_core.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.pages
     role   : PAGE_ORDER, View, helper vẽ (label/pressable/action/icon)
     source : main 2.txt L8774-9067 · 294 dòng · delta +1
--]]
		    do
		        local PAGE_ORDER = { "Home", "Music", "Cross", "Timer", "Stopwatch", "Download" }
		        local PAGE_TITLES = { Home = "Tổng quan", Music = "Âm nhạc", Timer = "Hẹn giờ", Stopwatch = "Bấm giờ", Download = "Tải xuống", Cross = "Cross" }
		        local PAGE_W = ISLAND.ExpandW
		        local PAGE_H = ISLAND.ExpandH
		        local DOCK_Y = PAGE_H - 40
		        local SWIPE = 44
		        local IDLE_COLLAPSE = 20
		        local View = {
		            Pages = {},
		            Tabs = {},
		            Updaters = {},
		            Quick = {},
		            Current = "Home",
		            Touched = 0,
		            Shown = {},
		            BubbleText = "",
		            BubbleAt = 0,
		            Toasts = {},
		            ToastBusy = false,
		            ToastSkip = false,
		            ToastToken = 0,
		            Gesture = nil,
		            SeekStamp = 0,
		            TickAt = 0,
		            DockLang = "",
		            Inset = 36,
		        }
		        pcall(function()
		            View.Inset = game:GetService("GuiService"):GetGuiInset().Y
		        end)

		        local function pageIndex(key)
		            for index, name in ipairs(PAGE_ORDER) do
		                if name == key then
		                    return index
		                end
		            end
		            return 1
		        end

		        View.group = new("CanvasGroup", {
		            Name = "Expanded",
		            AnchorPoint = Vector2.new(0.5, 0),
		            Position = UDim2.new(0.5, 0, 0, 0),
		            Size = UDim2.fromOffset(PAGE_W, PAGE_H),
		            BackgroundTransparency = 1,
		            GroupTransparency = 1,
		            Visible = false,
		            Parent = Media.Content,
		        })
		        View.sink = new("TextButton", {
		            Name = "Sink",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            AutoButtonColor = false,
		            Text = "",
		            ZIndex = 1,
		            Parent = View.group,
		        })

		        local function fmt(seconds)
		            seconds = math.max(0, seconds)
		            return string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
		        end

		        local function put(label, value)
		            if label.Text ~= value then
		                label.Text = value
		            end
		        end

		        local function label(parent, props)
		            props.TextScaled = false
		            props.Parent = parent
		            props.TextColor3 = props.TextColor3 or Static.White
		            props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
		            return text(props)
		        end

		        local function raw(item)
		            item:SetAttribute("BoncutiRaw", true)
		            return item
		        end

		        local function makePage(key)
		            local page = new("CanvasGroup", {
		                Name = key,
		                Size = UDim2.fromScale(1, 1),
		                BackgroundTransparency = 1,
		                GroupTransparency = 1,
		                Visible = false,
		                ZIndex = 2,
		                Parent = View.group,
		            })
		            View.Pages[key] = page
		            return page
		        end

		        local function pressable(button)
		            local scale = new("UIScale", { Parent = button })
		            local spring = Spring.new(1, 600, 30, function(value)
		                scale.Scale = value
		            end, 0.001)
		            button.MouseButton1Down:Connect(function()
		                spring:Set(0.92)
		            end)
		            button.MouseButton1Up:Connect(function()
		                spring:Set(1)
		            end)
		            button.MouseLeave:Connect(function()
		                spring:Set(1)
		            end)
		            return spring
		        end

		        local function touch(callback)
		            return function()
		                View.Touched = os.clock()
		                playSound("click")
		                callback()
		            end
		        end

		        local function shine(parent, radius, amount)
		            local gloss = box({
		                Name = "Shine",
		                Size = UDim2.fromScale(1, 1),
		                BackgroundColor3 = Static.White,
		                ZIndex = 4,
		                Parent = parent,
		            })
		            corner(radius, gloss)
		            new("UIGradient", {
		                Transparency = NumberSequence.new({
		                    NumberSequenceKeypoint.new(0, amount or 0.84),
		                    NumberSequenceKeypoint.new(0.55, 1),
		                    NumberSequenceKeypoint.new(1, 1),
		                }),
		                Rotation = 90,
		                Parent = gloss,
		            })
		            return gloss
		        end

		        local function action(parent, x, y, w, h, caption, color, callback)
		            local radius = math.floor(h / 2.4)
		            local button = box({
		                Class = "TextButton",
		                Position = UDim2.fromOffset(x, y),
		                Size = UDim2.fromOffset(w, h),
		                BackgroundColor3 = color or Static.White,
		                BackgroundTransparency = color and 0 or 0.88,
		                AutoButtonColor = false,
		                Text = translate(caption),
		                FontFace = Fonts.Semibold,
		                TextSize = 13,
		                TextColor3 = Static.White,
		                ZIndex = 5,
		                Parent = parent,
		            })
		            corner(radius, button)
		            stroke(button, Static.White, color and 0.8 or 0.9, 1)
		            shine(button, radius, color and 0.82 or 0.9)
		            pressable(button)
		            button.MouseButton1Click:Connect(touch(callback))
		            return button
		        end

		        local function icon(parent, kind, x, y, size, color)
		            local holder = new("Frame", {
		                Name = "Icon",
		                AnchorPoint = Vector2.new(0.5, 0.5),
		                Position = UDim2.fromOffset(x, y),
		                Size = UDim2.fromOffset(size, size),
		                BackgroundTransparency = 1,
		                ZIndex = 6,
		                Parent = parent,
		            })
		            local function add(px, py, pw, ph, radius)
		                local part = new("Frame", {
		                    Position = UDim2.fromOffset(px, py),
		                    Size = UDim2.fromOffset(pw, ph),
		                    BackgroundColor3 = color,
		                    BorderSizePixel = 0,
		                    ZIndex = 6,
		                    Parent = holder,
		                })
		                if radius then
		                    new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = part })
		                end
		            end
		            local function wedge(origin, width, height, mirrored)
		                local steps = math.max(6, math.floor(width * 1.5 + 0.5))
		                local step = width / steps
		                for index = 0, steps - 1 do
		                    local along = (index + 0.5) / steps
		                    local tall = math.max(height * (mirrored and along or (1 - along)), 1)
		                    add(origin + index * step, (size - tall) / 2, step + 0.5, tall)
		                end
		            end
		            if kind == "play" then
		                wedge(size * 0.24, size * 0.68, size * 0.8, false)
		            elseif kind == "pause" then
		                local bar = size * 0.22
		                add(size * 0.2, size * 0.12, bar, size * 0.76, bar * 0.45)
		                add(size * 0.58, size * 0.12, bar, size * 0.76, bar * 0.45)
		            elseif kind == "next" then
		                wedge(size * 0.1, size * 0.52, size * 0.64, false)
		                add(size * 0.68, size * 0.18, size * 0.14, size * 0.64, 1)
		            elseif kind == "prev" then
		                add(size * 0.18, size * 0.18, size * 0.14, size * 0.64, 1)
		                wedge(size * 0.38, size * 0.52, size * 0.64, true)
		            end
		            return holder
		        end

		        local function rail(parent, x, y, w, h, color, knob)
		            local track_ = box({
		                Position = UDim2.fromOffset(x, y),
		                Size = UDim2.fromOffset(w, h),
		                BackgroundColor3 = Static.White,
		                BackgroundTransparency = 0.82,
		                Parent = parent,
		            })
		            corner(h / 2, track_)
		            local fill = box({
		                Size = UDim2.new(0, 0, 1, 0),
		                BackgroundColor3 = color,
		                Parent = track_,
		            })
		            corner(h / 2, fill)
		            local dot
		            if knob then
		                dot = box({
		                    AnchorPoint = Vector2.new(0.5, 0.5),
		                    Position = UDim2.new(1, 0, 0.5, 0),
		                    Size = UDim2.fromOffset(knob, knob),
		                    BackgroundColor3 = Static.White,
		                    ZIndex = 3,
		                    Parent = fill,
		                })
		                corner(knob / 2, dot)
		            end
		            return track_, fill, dot
		        end

		        local home = makePage("Home")
		        View.clock = raw(label(home, {
		            Position = UDim2.fromOffset(20, 12),
		            Size = UDim2.fromOffset(170, 46),
		            Text = "--:--",
		            FontFace = Fonts.Bold,
		            TextSize = 40,
		        }))
		        View.date = raw(label(home, {
		            Position = UDim2.fromOffset(22, 58),
		            Size = UDim2.fromOffset(170, 16),
		            Text = "",
		            FontFace = Fonts.Medium,
		            TextSize = 12,
		            TextColor3 = Static.LightGray,
		        }))

		        local function badge(parent, x, y)
		            local frame = box({
		                Position = UDim2.fromOffset(x, y),
		                Size = UDim2.fromOffset(106, 26),
		                BackgroundColor3 = Static.White,
		                BackgroundTransparency = 0.88,
		                Parent = parent,
		            })
		            corner(13, frame)
		            stroke(frame, Static.White, 0.92, 1)
		            local dot = box({
		                Position = UDim2.fromOffset(11, 10),
		                Size = UDim2.fromOffset(6, 6),
		                BackgroundColor3 = Static.Green,
		                Parent = frame,
		            })
		            corner(3, dot)
		            local value = raw(label(frame, {
		                Position = UDim2.fromOffset(24, 0),
		                Size = UDim2.new(1, -30, 1, 0),
		                Text = "",
		                FontFace = Fonts.Semibold,
		                TextSize = 12,
		            }))
		            return dot, value
		        end
		        View.fpsDot, View.fpsText = badge(home, 216, 16)
		        View.pingDot, View.pingText = badge(home, 216, 48)

