--[[ xngot-studio · src/modules/30_overlay/044_ring.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.ring
     role   : Vòng tiến trình: vẽ mask, glow, ringShow/ringHide
     source : main 2.txt L4053-4710 · 658 dòng · delta +0
--]]
		    function Ring.layoutGlow(radius)
		        radius = math.max(tonumber(radius) or 15, 0)
		        for index, glow in ipairs(Ring.Glow) do
		            local spread = Ring.GlowSpread[index]
		            glow.Size = UDim2.new(1, spread * 2, 1, spread * 2)
		            local holder = Ring.GlowCorner[index]
		            if holder then
		                holder.CornerRadius = UDim.new(0, radius + spread)
		            end
		        end
		    end
		    Ring.layoutGlow(15)

		    do
		        local track_ = new("Frame", {
		            Size = UDim2.fromScale(1, 1),
		            BackgroundTransparency = 1,
		            Parent = Ring.Holder,
		        })
		        new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track_ })
		        Ring.TrackStroke = new("UIStroke", {
		            Thickness = ISLAND.Ring,
		            Color = Static.White,
		            Transparency = 1,
		            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		            Parent = track_,
		        })

		        for index = 1, 5 do
		            local clip = new("Frame", {
		                BackgroundTransparency = 1,
		                ClipsDescendants = true,
		                Parent = Ring.Holder,
		            })
		            local full = new("Frame", { BackgroundTransparency = 1, Parent = clip })
		            new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = full })
		            local line = new("UIStroke", {
		                Thickness = ISLAND.Ring,
		                Color = Static.White,
		                Transparency = 1,
		                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		                Parent = full,
		            })
		            local vertical = index == 2 or index == 4
		            local mask = new("UIGradient", { Rotation = vertical and 90 or 0, Parent = line })
		            Ring.Segments[index] = { Clip = clip, Full = full, Line = line, Mask = mask }
		        end
		    end

		    Isl.islandFrame = new("Frame", {
		        Name = "DynamicIsland",
		        AnchorPoint = Vector2.new(0.5, 0),
		        Position = UDim2.new(0.5, 0, 0, -70),
		        Size = UDim2.fromOffset(ISLAND.IdleW, ISLAND.H),
		        BackgroundColor3 = Static.White,
		        BorderSizePixel = 0,
		        ClipsDescendants = true,
		        ZIndex = 50,
		        Parent = gui,
		    })
		    Isl.islandCorner = corner(15, Isl.islandFrame)
		    new("UIGradient", {
		        Color = ColorSequence.new(rgb(30, 30, 35), rgb(2, 2, 4)),
		        Rotation = 90,
		        Parent = Isl.islandFrame,
		    })
		    Isl.islandRim = stroke(Isl.islandFrame, Static.White, 0, 1)
		    Isl.rimGradient = new("UIGradient", {
		        Transparency = NumberSequence.new({
		            NumberSequenceKeypoint.new(0, 0.58),
		            NumberSequenceKeypoint.new(0.2, 0.9),
		            NumberSequenceKeypoint.new(0.5, 0.97),
		            NumberSequenceKeypoint.new(0.8, 0.9),
		            NumberSequenceKeypoint.new(1, 0.58),
		        }),
		        Rotation = 90,
		        Parent = Isl.islandRim,
		    })
		    Isl.islandScale = new("UIScale", { Parent = Isl.islandFrame })

		    Media.Content = new("CanvasGroup", {
		        Name = "Content",
		        BackgroundTransparency = 1,
		        Size = UDim2.fromScale(1, 1),
		        Parent = Isl.islandFrame,
		    })
		    Media.ContentCorner = corner(15, Media.Content)

		    Isl.tint = box({
		        AnchorPoint = Vector2.new(0, 1),
		        Position = UDim2.fromScale(0, 1),
		        Size = UDim2.fromScale(1, 0.9),
		        BackgroundColor3 = Static.Blue,
		        BackgroundTransparency = 1,
		        Parent = Media.Content,
		    })
		    new("UIGradient", {
		        Transparency = NumberSequence.new(1, 0.66),
		        Rotation = 90,
		        Parent = Isl.tint,
		    })
		    Isl.gloss = box({
		        Size = UDim2.fromScale(1, 0.52),
		        BackgroundColor3 = Static.White,
		        Parent = Media.Content,
		    })
		    new("UIGradient", {
		        Transparency = NumberSequence.new(0.86, 1),
		        Rotation = 90,
		        Parent = Isl.gloss,
		    })

		    Media.Shine = box({
		        Size = UDim2.fromScale(1, 1),
		        BackgroundColor3 = Static.White,
		        Parent = Media.Content,
		    })
		    Media.ShineGradient = new("UIGradient", {
		        Transparency = NumberSequence.new({
		            NumberSequenceKeypoint.new(0, 1),
		            NumberSequenceKeypoint.new(0.4, 1),
		            NumberSequenceKeypoint.new(0.5, 0.84),
		            NumberSequenceKeypoint.new(0.6, 1),
		            NumberSequenceKeypoint.new(1, 1),
		        }),
		        Rotation = 20,
		        Offset = Vector2.new(-1, 0),
		        Parent = Media.Shine,
		    })

		    function Isl.layoutIsland()
		        local scale = islandState.Base * islandState.Hover
		        local shift = -(ISLAND.Bubble + ISLAND.Gap) / 2 * math.clamp(islandState.Bubble, 0, 1) * islandState.Base
		        islandState.X = shift
		        Isl.islandFrame.Size = UDim2.fromOffset(islandState.W, islandState.H)
		        Isl.islandFrame.Position = UDim2.new(0.5, shift, 0, islandState.Y)
		        Isl.islandCorner.CornerRadius = UDim.new(0, math.max(islandState.R, 0))
		        if Ring.layoutGlow then
		            Ring.layoutGlow(math.max(islandState.R, 0))
		        end
		        Media.ContentCorner.CornerRadius = Isl.islandCorner.CornerRadius
		        Isl.islandScale.Scale = scale
		        Ring.Holder.Size = UDim2.fromOffset(islandState.W, islandState.H)
		        Ring.Holder.Position = UDim2.new(0.5, shift, 0, islandState.Y)
		        Ring.Scale.Scale = scale
		        Ring.Dirty = true
		        if Fwd.islandLayout then
		            Fwd.islandLayout(scale, shift)
		        end
		    end

		    Spr.springIslandW = Spring.new(ISLAND.IdleW, 300, 24, function(value)
		        islandState.W = value
		        islandState.Dirty = true
		    end, 0.05)

		    Spr.springIslandH = Spring.new(ISLAND.H, 340, 26, function(value)
		        islandState.H = value
		        islandState.Dirty = true
		    end, 0.05)

		    Spr.springIslandR = Spring.new(15, 300, 30, function(value)
		        islandState.R = value
		        islandState.Dirty = true
		    end, 0.05)

		    Spr.springIslandY = Spring.new(-70, 240, 20, function(value)
		        islandState.Y = value
		        islandState.Dirty = true
		    end, 0.05)

		    Spr.springIslandHover = Spring.new(1, 420, 26, function(value)
		        islandState.Hover = value
		        islandState.Dirty = true
		    end, 0.0005)

		    Spr.springBubble = Spring.new(0, 240, 15, function(value)
		        islandState.Bubble = value
		        islandState.Dirty = true
		    end, 0.002)

		    function Isl.bubbleTo(target)
		        Spr.springBubble.Damping = target > 0 and 14 or 30
		        Spr.springBubble:Set(target)
		    end

		    Isl.idleGroup = new("CanvasGroup", {
		        Name = "Idle",
		        BackgroundTransparency = 1,
		        Size = UDim2.fromScale(1, 1),
		        Parent = Media.Content,
		    })
		    new("UIListLayout", {
		        FillDirection = Enum.FillDirection.Horizontal,
		        HorizontalAlignment = Enum.HorizontalAlignment.Center,
		        VerticalAlignment = Enum.VerticalAlignment.Center,
		        SortOrder = Enum.SortOrder.LayoutOrder,
		        Padding = UDim.new(0, 6),
		        Parent = Isl.idleGroup,
		    })
		    Isl.idleDot = box({
		        Size = UDim2.fromOffset(7, 7),
		        BackgroundColor3 = Static.Green,
		        LayoutOrder = 1,
		        Parent = Isl.idleGroup,
		    })
		    corner(4, Isl.idleDot)
		    text({
		        Text = "xNgọtStudio",
		        FontFace = Fonts.Semibold,
		        TextSize = 12,
		        TextColor3 = Static.White,
		        AutomaticSize = Enum.AutomaticSize.X,
		        Size = UDim2.fromOffset(0, 14),
		        LayoutOrder = 2,
		        Parent = Isl.idleGroup,
		    })

		    Isl.liveGroup = new("CanvasGroup", {
		        Name = "Live",
		        BackgroundTransparency = 1,
		        GroupTransparency = 1,
		        Size = UDim2.fromScale(1, 1),
		        Parent = Media.Content,
		    })
		    Isl.liveDot = box({
		        Position = UDim2.fromOffset(12, 11),
		        Size = UDim2.fromOffset(8, 8),
		        BackgroundColor3 = Static.Orange,
		        Parent = Isl.liveGroup,
		    })
		    corner(4, Isl.liveDot)
		    Isl.liveTitle = text({
		        Position = UDim2.fromOffset(26, 0),
		        Size = UDim2.new(0.5, -26, 1, 0),
		        Text = "",
		        FontFace = Fonts.Medium,
		        TextSize = 11,
		        TextColor3 = Static.LightGray,
		        TextXAlignment = Enum.TextXAlignment.Left,
		        TextTruncate = Enum.TextTruncate.AtEnd, -- FIX(dynamic-island-bubble): phong thu khi fitText chua san sang
		        Parent = Isl.liveGroup,
		    })
		    Isl.liveValue = text({
		        AnchorPoint = Vector2.new(1, 0),
		        Position = UDim2.new(1, -13, 0, 0),
		        Size = UDim2.new(0.5, -8, 1, 0),
		        Text = "",
		        FontFace = Fonts.Semibold,
		        TextSize = 12,
		        TextColor3 = Static.White,
		        TextXAlignment = Enum.TextXAlignment.Right,
		        TextTruncate = Enum.TextTruncate.AtEnd, -- FIX(dynamic-island-bubble): phong thu khi fitText chua san sang
		        Parent = Isl.liveGroup,
		    })

		    Isl.alertGroup = new("CanvasGroup", {
		        Name = "Alert",
		        BackgroundTransparency = 1,
		        GroupTransparency = 1,
		        Size = UDim2.fromScale(1, 1),
		        Parent = Media.Content,
		    })
		    Isl.alertGlow = box({
		        Size = UDim2.fromScale(1, 1),
		        BackgroundColor3 = Static.Blue,
		        Parent = Isl.alertGroup,
		    })
		    new("UIGradient", {
		        Transparency = NumberSequence.new({
		            NumberSequenceKeypoint.new(0, 0.7),
		            NumberSequenceKeypoint.new(0.6, 1),
		            NumberSequenceKeypoint.new(1, 1),
		        }),
		        Parent = Isl.alertGlow,
		    })
		    Isl.alertIcon = box({
		        AnchorPoint = Vector2.new(0, 0.5),
		        Position = UDim2.new(0, 10, 0.5, 0),
		        Size = UDim2.fromOffset(26, 26),
		        BackgroundColor3 = Static.Blue,
		        Parent = Isl.alertGroup,
		    })
		    corner(13, Isl.alertIcon)
		    Isl.alertGlyph = text({
		        Size = UDim2.fromScale(1, 1),
		        Text = "i",
		        FontFace = Fonts.Bold,
		        TextSize = 14,
		        TextColor3 = Static.White,
		        Parent = Isl.alertIcon,
		    })
		    Isl.alertTitle = text({
		        AnchorPoint = Vector2.new(0, 0.5),
		        Position = UDim2.new(0, 44, 0.5, -8),
		        Size = UDim2.new(1, -56, 0, 16),
		        Text = "",
		        FontFace = Fonts.Semibold,
		        TextSize = 13,
		        TextColor3 = Static.White,
		        TextXAlignment = Enum.TextXAlignment.Left,
		        TextTruncate = Enum.TextTruncate.AtEnd,
		        TextScaled = false,
		        Parent = Isl.alertGroup,
		    })
		    Isl.alertMessage = text({
		        AnchorPoint = Vector2.new(0, 0.5),
		        Position = UDim2.new(0, 44, 0.5, 9),
		        Size = UDim2.new(1, -56, 0, 14),
		        Text = "",
		        FontFace = Fonts.Regular,
		        TextSize = 12,
		        TextColor3 = Static.LightGray,
		        TextXAlignment = Enum.TextXAlignment.Left,
		        TextTruncate = Enum.TextTruncate.AtEnd,
		        TextScaled = false,
		        Parent = Isl.alertGroup,
		    })
		    Isl.alertIconScale = new("UIScale", { Parent = Isl.alertIcon })
		    Isl.alertPulse = new("Frame", {
		        AnchorPoint = Vector2.new(0.5, 0.5),
		        Position = UDim2.new(0, 23, 0.5, 0),
		        Size = UDim2.fromOffset(26, 26),
		        BackgroundTransparency = 1,
		        BorderSizePixel = 0,
		        Parent = Isl.alertGroup,
		    })
		    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Isl.alertPulse })
		    Isl.alertPulseStroke = new("UIStroke", {
		        Color = Static.Blue,
		        Thickness = 2,
		        Transparency = 1,
		        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		        Parent = Isl.alertPulse,
		    })
		    Isl.alertBadge = box({
		        AnchorPoint = Vector2.new(1, 0),
		        Position = UDim2.new(1, -12, 0, 7),
		        Size = UDim2.fromOffset(26, 15),
		        BackgroundColor3 = Static.White,
		        BackgroundTransparency = 0.82,
		        Visible = false,
		        Parent = Isl.alertGroup,
		    })
		    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Isl.alertBadge })
		    Isl.alertBadgeText = text({
		        Size = UDim2.fromScale(1, 1),
		        Text = "",
		        FontFace = Fonts.Semibold,
		        TextSize = 10,
		        TextColor3 = Static.White,
		        Parent = Isl.alertBadge,
		    })
		    Isl.alertBadgeText:SetAttribute("BoncutiRaw", true)
		    Spr.springAlertIcon = Spring.new(1, 420, 17, function(value)
		        Isl.alertIconScale.Scale = math.max(value, 0.05)
		    end, 0.001)

		    Media.Group = new("CanvasGroup", {
		        Name = "Media",
		        BackgroundTransparency = 1,
		        GroupTransparency = 1,
		        Size = UDim2.fromScale(1, 1),
		        Parent = Media.Content,
		    })
		    Media.Art = box({
		        Position = UDim2.fromOffset(6, 6),
		        Size = UDim2.fromOffset(26, 26),
		        BackgroundColor3 = Static.White,
		        Parent = Media.Group,
		    })
		    corner(8, Media.Art)
		    Media.Cover = new("ImageLabel", {
		        Name = "Cover",
		        Size = UDim2.fromScale(1, 1),
		        BackgroundTransparency = 1,
		        Image = "",
		        ScaleType = Enum.ScaleType.Crop,
		        Visible = false,
		        ZIndex = 5,
		        Parent = Media.Art,
		    })
		    corner(8, Media.Cover)
		    Media.ArtGradient = new("UIGradient", {
		        Color = ColorSequence.new(Static.Blue, Static.Purple),
		        Rotation = 45,
		        Parent = Media.Art,
		    })
		    Media.Letter = text({
		        Size = UDim2.fromScale(1, 1),
		        Text = "♪",
		        FontFace = Fonts.Bold,
		        TextSize = 13,
		        TextColor3 = Static.White,
		        Parent = Media.Art,
		    })
		    Media.Title = text({
		        Position = UDim2.fromOffset(40, 5),
		        Size = UDim2.new(1, -78, 0, 15),
		        Text = "",
		        FontFace = Fonts.Semibold,
		        TextSize = 12,
		        TextColor3 = Static.White,
		        TextXAlignment = Enum.TextXAlignment.Left,
		        TextTruncate = Enum.TextTruncate.AtEnd,
		        TextScaled = false,
		        Parent = Media.Group,
		    })
		    Media.Sub = text({
		        Position = UDim2.fromOffset(40, 20),
		        Size = UDim2.new(1, -78, 0, 12),
		        Text = "",
		        FontFace = Fonts.Regular,
		        TextSize = 10,
		        TextColor3 = Static.LightGray,
		        TextXAlignment = Enum.TextXAlignment.Left,
		        TextTruncate = Enum.TextTruncate.AtEnd,
		        TextScaled = false,
		        Parent = Media.Group,
		    })
		    Media.BarsFrame = new("Frame", {
		        AnchorPoint = Vector2.new(1, 0.5),
		        Position = UDim2.new(1, -14, 0.5, 0),
		        Size = UDim2.fromOffset(23, 18),
		        BackgroundTransparency = 1,
		        Parent = Media.Group,
		    })
		    Media.DlFrame = new("Frame", {
		        Position = UDim2.fromOffset(6, 6),
		        Size = UDim2.fromOffset(26, 26),
		        BackgroundColor3 = Static.Blue,
		        Visible = false,
		        Parent = Media.Group,
		    })
		    corner(8, Media.DlFrame)
		    Media.DlIcon = text({
		        Size = UDim2.fromScale(1, 1),
		        Text = "↓",
		        FontFace = Fonts.Bold,
		        TextSize = 15,
		        TextColor3 = Static.White,
		        Parent = Media.DlFrame,
		    })
		    Media.DlTrack = new("Frame", {
		        Position = UDim2.new(0, 40, 1, -9),
		        Size = UDim2.new(1, -54, 0, 3),
		        BackgroundColor3 = Static.White,
		        BackgroundTransparency = 0.78,
		        Visible = false,
		        Parent = Media.Group,
		    })
		    corner(2, Media.DlTrack)
		    Media.DlFill = new("Frame", {
		        Size = UDim2.new(0, 0, 1, 0),
		        BackgroundColor3 = Static.White,
		        BackgroundTransparency = 0.05,
		        Parent = Media.DlTrack,
		    })
		    corner(2, Media.DlFill)

		    Media.Bars = {}
		    for index = 1, 5 do
		        local bar = box({
		            AnchorPoint = Vector2.new(0, 1),
		            Position = UDim2.new(0, (index - 1) * 5, 1, 0),
		            Size = UDim2.fromOffset(3, 4),
		            BackgroundColor3 = Static.Green,
		            Parent = Media.BarsFrame,
		        })
		        corner(2, bar)
		        Media.Bars[index] = bar
		    end

		    Isl.islandHit = new("TextButton", {
		        Size = UDim2.fromScale(1, 1),
		        BackgroundTransparency = 1,
		        Text = "",
		        ZIndex = 60,
		        Parent = Isl.islandFrame,
		    })

		    Isl.bubble = new("Frame", {
		        Name = "IslandBubble",
		        AnchorPoint = Vector2.new(0.5, 0.5),
		        Position = UDim2.new(0.5, 0, 0, -70),
		        Size = UDim2.fromOffset(ISLAND.Bubble, ISLAND.Bubble),
		        BackgroundColor3 = Static.White,
		        BorderSizePixel = 0,
		        Visible = false,
		        ZIndex = 50,
		        Parent = gui,
		    })
		    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Isl.bubble })
		    new("UIGradient", {
		        Color = ColorSequence.new(rgb(30, 30, 35), rgb(2, 2, 4)),
		        Rotation = 90,
		        Parent = Isl.bubble,
		    })
		    Isl.bubbleRing = stroke(Isl.bubble, Static.Green, 0.1, 1.5)
		    Isl.bubbleScale = new("UIScale", { Scale = 0.01, Parent = Isl.bubble })
		    Isl.bubbleText = text({
		        Size = UDim2.fromScale(1, 1),
		        Text = "",
		        FontFace = Fonts.Semibold,
		        TextSize = 10,
		        TextTruncate = Enum.TextTruncate.AtEnd, -- FIX(dynamic-island-bubble): khong de text tran khoi bubble 30px
		        TextColor3 = Static.White,
		        ZIndex = 51,
		        Parent = Isl.bubble,
		    })
		    Isl.bubbleText:SetAttribute("BoncutiRaw", true)
		    Isl.bubbleHit = new("TextButton", {
		        Size = UDim2.fromScale(1, 1),
		        BackgroundTransparency = 1,
		        Text = "",
		        ZIndex = 60,
		        Parent = Isl.bubble,
		    })

		    function Ring.ringMask(t, after)
		        if t <= 0.002 then
		            return NumberSequence.new(after and 0 or 1)
		        elseif t >= 0.998 then
		            return NumberSequence.new(after and 1 or 0)
		        end
		        local high = math.min(t + 0.002, 1)
		        if after then
		            return NumberSequence.new({
		                NumberSequenceKeypoint.new(0, 1),
		                NumberSequenceKeypoint.new(t, 1),
		                NumberSequenceKeypoint.new(high, 0),
		                NumberSequenceKeypoint.new(1, 0),
		            })
		        end
		        return NumberSequence.new({
		            NumberSequenceKeypoint.new(0, 0),
		            NumberSequenceKeypoint.new(t, 0),
		            NumberSequenceKeypoint.new(high, 1),
		            NumberSequenceKeypoint.new(1, 1),
		        })
		    end

		    function Ring.updateRing()
		        local width = islandState.W
		        local height = islandState.H
		        local radius = height / 2
		        local straight = math.max(width - height, 0)
		        local half = straight / 2
		        local arc = math.pi * radius
		        local total = half * 2 + arc * 2 + straight
		        local fill = Ring.Mode == "fill"
		        local used = (fill and Ring.Progress or 1 - Ring.Progress) * total
		        local margin = ISLAND.Ring + 2

		        local starts = { 0, half, half + arc, half + arc + straight, half + arc * 2 + straight }
		        local lengths = { half, arc, straight, arc, half }
		        local boxes = {
		            { width / 2, -margin, half, radius + margin },
		            { width - radius, -margin, radius + margin, height + margin * 2 },
		            { radius, radius, straight, radius + margin },
		            { -margin, -margin, radius + margin, height + margin * 2 },
		            { radius, -margin, half, radius + margin },
		        }

		        for index = 1, 5 do
		            local segment = Ring.Segments[index]
		            local length = lengths[index]
		            local f
		            if length > 0.01 then
		                f = math.clamp((used - starts[index]) / length, 0, 1)
		            else
		                f = fill and 0 or 1
		            end
		            local hidden = (fill and f <= 0) or (not fill and f >= 1)
		            segment.Clip.Visible = not hidden
		            if not hidden then
		                local b = boxes[index]
		                segment.Clip.Position = UDim2.fromOffset(b[1], b[2])
		                segment.Clip.Size = UDim2.fromOffset(b[3], b[4])
		                segment.Full.Position = UDim2.fromOffset(-b[1], -b[2])
		                segment.Full.Size = UDim2.fromOffset(width, height)

		                local threshold, after
		                if index == 1 then
		                    threshold = (width / 2 + f * half) / width
		                    after = true
		                elseif index == 2 then
		                    threshold = radius * (1 - math.cos(f * math.pi)) / height
		                    after = true
		                elseif index == 3 then
		                    threshold = (width - radius - f * straight) / width
		                    after = false
		                elseif index == 4 then
		                    threshold = radius * (1 + math.cos(f * math.pi)) / height
		                    after = false
		                else
		                    threshold = (radius + f * half) / width
		                    after = true
		                end
		                if fill then
		                    after = not after
		                end
		                segment.Mask.Transparency = Ring.ringMask(threshold, after)
		            end
		        end
		    end

		    function Ring.ringGlow(color)
		        for index, glow in ipairs(Ring.Glow) do
		            tween(glow, 0.35, {
		                BackgroundColor3 = color or Static.Black,
		                BackgroundTransparency = (color and Ring.GlowLit or Ring.GlowBase)[index],
		            })
		        end
		    end

		    function Ring.ringShow(color, source, mode)
		        if not Settings.Ring then
		            return
		        end
		        Ring.Token = Ring.Token + 1
		        Ring.Source = source
		        Ring.Mode = mode or "drain"
		        Ring.Progress = math.clamp(source and source() or 1, 0, 1)
		        if not Ring.Visible then
		            for _, segment in ipairs(Ring.Segments) do
		                segment.Line.Color = color
		            end
		            Ring.TrackStroke.Color = color
		        end
		        Ring.Visible = true
		        Ring.ringGlow(color)
		        for _, segment in ipairs(Ring.Segments) do
		            tween(segment.Line, 0.3, { Color = color, Transparency = 0 })
		        end
		        tween(Ring.TrackStroke, 0.3, { Color = color, Transparency = 0.86 })
		        Ring.updateRing()
		    end

		    function Ring.ringHide()
		        if not Ring.Visible then
		            return
		        end
		        Ring.Source = nil
		        Ring.Token = Ring.Token + 1
		        local token = Ring.Token
		        for _, segment in ipairs(Ring.Segments) do
		            tween(segment.Line, 0.25, { Transparency = 1 })
		        end
		        tween(Ring.TrackStroke, 0.25, { Transparency = 1 })
		        Ring.ringGlow(nil)
		        task.delay(0.32, function()
		            if Ring.Token == token then
		                Ring.Visible = false
		            end
		        end)
		    end

