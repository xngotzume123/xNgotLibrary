--[[ xngot-studio · src/modules/30_overlay/040_island_consts.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.consts
     role   : Kích thước ISLAND, islandState, Media, Ring, layoutGlow
     source : main 2.txt L3994-4052 · 59 dòng · delta +0
--]]
		    local ISLAND = {
		        IdleW = 100,
		        LiveW = 158,
		        H = 30,
		        AlertH = 62,
		        Top = 8,
		        Ring = 2,
		        MediaW = 212,
		        MediaH = 38,
		        ExpandW = 340,
		        ExpandH = 192,
		        ExpandR = 38,
		        Gap = 8,
		        Bubble = 30,
		    }
		    local islandState = { W = ISLAND.IdleW, H = ISLAND.H, R = 15, Y = -70, X = 0, Bubble = 0, Base = 1, Hover = 1, Dirty = true }
		    local Media = {}

		    local Ring = {
		        Visible = false,
		        Dirty = true,
		        Progress = 1,
		        Source = nil,
		        Mode = "drain",
		        Token = 0,
		        Segments = {},
		    }

		    Ring.Holder = new("Frame", {
		        Name = "IslandRing",
		        AnchorPoint = Vector2.new(0.5, 0),
		        Position = UDim2.new(0.5, 0, 0, -70),
		        Size = UDim2.fromOffset(ISLAND.IdleW, ISLAND.H),
		        BackgroundTransparency = 1,
		        ZIndex = 49,
		        Parent = gui,
		    })
		    Ring.Scale = new("UIScale", { Parent = Ring.Holder })

		    Ring.Glow = {}
		    Ring.GlowSpread = { 2, 5, 9, 14, 20 }
		    Ring.GlowBase = { 0.80, 0.87, 0.915, 0.945, 0.965 }
		    Ring.GlowLit = { 0.66, 0.78, 0.86, 0.90, 0.94 }
		    for index, spread in ipairs(Ring.GlowSpread) do
		        local glow = new("Frame", {
		            Name = "IslandShadow" .. tostring(index),
		            AnchorPoint = Vector2.new(0.5, 0.5),
		            Position = UDim2.new(0.5, 0, 0.5, 0),
		            Size = UDim2.new(1, spread * 2, 1, spread * 2),
		            BackgroundColor3 = Static.Black,
		            BackgroundTransparency = Ring.GlowBase[index],
		            BorderSizePixel = 0,
		            ZIndex = 48,
		            Parent = Ring.Holder,
		        })
		        Ring.Glow[index] = glow
		        Ring.GlowCorner = Ring.GlowCorner or {}
		        Ring.GlowCorner[index] = corner(0, glow)
		    end
