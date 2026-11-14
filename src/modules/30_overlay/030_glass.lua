--[[ xngot-studio · src/modules/30_overlay/030_glass.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.glass
     role   : Glass (kính mờ) + Search (chỉ mục tìm kiếm)
     source : main 2.txt L3499-3788 · 290 dòng · delta +0
--]]
		    local Glass = {}
		    local Search = { Index = {}, Open = false, Count = 0 }

		    function Search.Add(row, kind, title, desc, action)
		        Search.Count = Search.Count + 1
		        table.insert(Search.Index, {
		            Row = row,
		            Kind = kind,
		            Title = title,
		            Desc = desc,
		            Action = action,
		            Order = Search.Count,
		        })
		    end

		    function Glass.Skin(frame, transparency, tint)
		        frame.BackgroundTransparency = transparency
		        new("UIGradient", {
		            Color = ColorSequence.new({
		                ColorSequenceKeypoint.new(0, Static.White),
		                ColorSequenceKeypoint.new(0.42, rgb(238, 241, 250)),
		                ColorSequenceKeypoint.new(1, tint or rgb(204, 210, 228)),
		            }),
		            Rotation = 90,
		            Parent = frame,
		        })
		        local rim = new("UIStroke", {
		            Color = Static.White,
		            Thickness = 1,
		            Transparency = 0,
		            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		            Parent = frame,
		        })
		        new("UIGradient", {
		            Transparency = NumberSequence.new({
		                NumberSequenceKeypoint.new(0, 0.2),
		                NumberSequenceKeypoint.new(0.3, 0.82),
		                NumberSequenceKeypoint.new(0.7, 0.93),
		                NumberSequenceKeypoint.new(1, 0.42),
		            }),
		            Rotation = 55,
		            Parent = rim,
		        })
		        return rim
		    end

		    function Glass.Band(parent, height)
		        local band = new("Frame", {
		            Name = "GlassBand",
		            Size = UDim2.new(1, 0, 0, height),
		            BackgroundColor3 = Static.White,
		            BorderSizePixel = 0,
		            ZIndex = 0,
		            Parent = parent,
		        })
		        new("UIGradient", {
		            Transparency = NumberSequence.new(0.84, 1),
		            Rotation = 90,
		            Parent = band,
		        })
		        return band
		    end

		    function Glass.Rim(parent, radius)
		        local rim = new("Frame", {
		            Name = "GlassRim",
		            Position = UDim2.fromOffset(2, 2),
		            Size = UDim2.new(1, -4, 1, -4),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            ZIndex = 30,
		            Parent = parent,
		        })
		        new("UICorner", { CornerRadius = UDim.new(0, math.max(radius - 2, 2)), Parent = rim })
		        local line = new("UIStroke", {
		            Color = Static.White,
		            Thickness = 1.5,
		            Transparency = 0,
		            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		            Parent = rim,
		        })
		        local gradient = new("UIGradient", {
		            Transparency = NumberSequence.new({
		                NumberSequenceKeypoint.new(0, 0.12),
		                NumberSequenceKeypoint.new(0.3, 0.88),
		                NumberSequenceKeypoint.new(0.62, 0.94),
		                NumberSequenceKeypoint.new(1, 0.32),
		            }),
		            Rotation = 45,
		            Parent = line,
		        })
		        return rim, gradient
		    end

		    function Glass.Mark(parent, size, fresh)
		        local tile = new("Frame", {
		            Name = "Mark",
		            Size = UDim2.fromOffset(size, size),
		            BackgroundColor3 = Static.White,
		            BorderSizePixel = 0,
		            Parent = parent,
		        })
		        local radius = math.floor(size * 0.3)
		        new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = tile })
		        new("UIGradient", {
		            Color = fresh and ColorSequence.new({
		                ColorSequenceKeypoint.new(0, rgb(98, 162, 255)),
		                ColorSequenceKeypoint.new(0.5, rgb(104, 92, 240)),
		                ColorSequenceKeypoint.new(1, rgb(58, 36, 140)),
		            }) or ColorSequence.new(rgb(118, 192, 255), rgb(158, 100, 255)),
		            Rotation = fresh and 55 or 38,
		            Parent = tile,
		        })
		        new("UIStroke", {
		            Color = Static.White,
		            Thickness = 1,
		            Transparency = 0.72,
		            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		            Parent = tile,
		        })
		        local gloss = new("Frame", {
		            Position = UDim2.fromOffset(1, 1),
		            Size = UDim2.new(1, -2, 0.52, 0),
		            BackgroundColor3 = Static.White,
		            BorderSizePixel = 0,
		            Parent = tile,
		        })
		        new("UICorner", { CornerRadius = UDim.new(0, math.max(radius - 1, 2)), Parent = gloss })
		        new("UIGradient", {
		            Transparency = NumberSequence.new(0.55, 1),
		            Rotation = 90,
		            Parent = gloss,
		        })
		        if fresh then
		            local stemWidth = size * 0.12
		            local stem = new("Frame", {
		                Position = UDim2.fromOffset(size * 0.3, size * 0.17),
		                Size = UDim2.fromOffset(stemWidth, size * 0.64),
		                BackgroundColor3 = Static.White,
		                BorderSizePixel = 0,
		                Parent = tile,
		            })
		            new("UICorner", { CornerRadius = UDim.new(0, stemWidth / 2), Parent = stem })
		            local bowl = new("Frame", {
		                Position = UDim2.fromOffset(size * 0.42, size * 0.49),
		                Size = UDim2.fromOffset(size * 0.2, size * 0.2),
		                BackgroundTransparency = 1,
		                BorderSizePixel = 0,
		                Parent = tile,
		            })
		            new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bowl })
		            new("UIStroke", {
		                Color = Static.White,
		                Thickness = stemWidth,
		                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		                Parent = bowl,
		            })
		            local spark = new("Frame", {
		                AnchorPoint = Vector2.new(0.5, 0.5),
		                Position = UDim2.fromOffset(size * 0.74, size * 0.25),
		                Size = UDim2.fromOffset(size * 0.11, size * 0.11),
		                BackgroundColor3 = rgb(120, 230, 255),
		                BorderSizePixel = 0,
		                Parent = tile,
		            })
		            new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spark })
		            return tile
		        end
		        local thickness = math.max(2, size * 0.075)
		        local ring = new("Frame", {
		            AnchorPoint = Vector2.new(0.5, 0.5),
		            Position = UDim2.fromScale(0.5, 0.5),
		            Size = UDim2.fromOffset(size * 0.5, size * 0.5),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            Parent = tile,
		        })
		        new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ring })
		        new("UIStroke", {
		            Color = Static.White,
		            Thickness = thickness,
		            Transparency = 0.35,
		            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		            Parent = ring,
		        })
		        local core = new("Frame", {
		            AnchorPoint = Vector2.new(0.5, 0.5),
		            Position = UDim2.fromScale(0.5, 0.5),
		            Size = UDim2.fromOffset(size * 0.14, size * 0.14),
		            BackgroundColor3 = Static.White,
		            BorderSizePixel = 0,
		            Parent = tile,
		        })
		        new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = core })
		        local orbit = size * 0.25 + thickness / 2
		        local satellite = new("Frame", {
		            AnchorPoint = Vector2.new(0.5, 0.5),
		            Position = UDim2.new(0.5, orbit * 0.7071, 0.5, -orbit * 0.7071),
		            Size = UDim2.fromOffset(size * 0.17, size * 0.17),
		            BackgroundColor3 = Static.White,
		            BorderSizePixel = 0,
		            Parent = tile,
		        })
		        new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = satellite })
		        return tile
		    end

		    function Glass.Decorate(parent, radius)
		        local layer = new("Frame", {
		            Name = "GlassLayer",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundTransparency = 1,
		            BorderSizePixel = 0,
		            ZIndex = 0,
		            Parent = parent,
		        })
		        local sheen = new("Frame", {
		            Name = "Sheen",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundColor3 = Static.White,
		            BorderSizePixel = 0,
		            Parent = layer,
		        })
		        Glass.Sheen = new("UIGradient", {
		            Transparency = NumberSequence.new({
		                NumberSequenceKeypoint.new(0, 1),
		                NumberSequenceKeypoint.new(0.32, 1),
		                NumberSequenceKeypoint.new(0.45, 0.93),
		                NumberSequenceKeypoint.new(0.52, 0.88),
		                NumberSequenceKeypoint.new(0.6, 0.94),
		                NumberSequenceKeypoint.new(0.72, 1),
		                NumberSequenceKeypoint.new(1, 1),
		            }),
		            Rotation = 28,
		            Parent = sheen,
		        })
		        Glass.Band(layer, 120)
		        local caustic = new("Frame", {
		            Name = "Caustic",
		            Size = UDim2.fromScale(1, 1),
		            BackgroundColor3 = Static.White,
		            BorderSizePixel = 0,
		            Parent = layer,
		        })
		        Glass.Caustic = new("UIGradient", {
		            Transparency = NumberSequence.new({
		                NumberSequenceKeypoint.new(0, 1),
		                NumberSequenceKeypoint.new(0.16, 1),
		                NumberSequenceKeypoint.new(0.34, 0.96),
		                NumberSequenceKeypoint.new(0.42, 0.91),
		                NumberSequenceKeypoint.new(0.5, 0.96),
		                NumberSequenceKeypoint.new(0.68, 1),
		                NumberSequenceKeypoint.new(1, 1),
		            }),
		            Rotation = -34,
		            Parent = caustic,
		        })
		        local depth = new("Frame", {
		            Name = "Depth",
		            AnchorPoint = Vector2.new(0, 1),
		            Position = UDim2.fromScale(0, 1),
		            Size = UDim2.new(1, 0, 0, 150),
		            BackgroundColor3 = Static.Black,
		            BorderSizePixel = 0,
		            Parent = layer,
		        })
		        new("UIGradient", {
		            Transparency = NumberSequence.new(1, 0.92),
		            Rotation = 90,
		            Parent = depth,
		        })
		        local _, rimGradient = Glass.Rim(parent, radius)
		        Glass.RimGradient = rimGradient
		        Glass.Layer = layer
		    end

		    function Glass.Step()
		        if not Glass.Layer or not Glass.Layer.Parent then
		            return
		        end
		        local clock = os.clock()
		        Glass.Sheen.Offset = Vector2.new(math.sin(clock * 0.3) * 0.5, 0)
		        if Glass.Caustic then
		            Glass.Caustic.Offset = Vector2.new(math.cos(clock * 0.21 + 1.3) * 0.55, math.sin(clock * 0.17) * 0.2)
		        end
		        if Glass.RimGradient then
		            Glass.RimGradient.Rotation = 45 + math.sin(clock * 0.5) * 32
		        end
		    end

