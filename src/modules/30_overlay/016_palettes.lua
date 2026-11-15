--[[ xngot-studio · src/modules/30_overlay/016_palettes.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.palettes
     role   : Bảng màu Static/Palettes/Accents + Settings mặc định
     source : main 2.txt L2831-2952 · 122 dòng · delta +0
--]]
		    local Static = {
		        White = Color3.new(1, 1, 1),
		        Black = Color3.new(0, 0, 0),
		        Blue = rgb(10, 132, 255),
		        Green = rgb(48, 209, 88),
		        Orange = rgb(255, 159, 10),
		        Red = rgb(255, 69, 58),
		        Purple = rgb(191, 90, 242),
		        Gray = rgb(142, 142, 147),
		        LightGray = rgb(174, 174, 178),
		        TrafficRed = rgb(255, 95, 87),
		        TrafficYellow = rgb(254, 188, 46),
		        TrafficGreen = rgb(40, 200, 64),
		    }

		    local Palettes = {
		        {
		            Window = rgb(24, 24, 27),
		            Card = rgb(44, 44, 48),
		            Field = rgb(28, 28, 31),
		            Off = rgb(78, 78, 84),
		            Text = rgb(245, 245, 247),
		            Sub = rgb(152, 152, 160),
		            Line = rgb(255, 255, 255),
		            Seg = rgb(99, 99, 102),
		        },
		        {
		            Window = rgb(244, 244, 247),
		            Card = rgb(255, 255, 255),
		            Field = rgb(236, 236, 241),
		            Off = rgb(208, 208, 214),
		            Text = rgb(28, 28, 30),
		            Sub = rgb(110, 110, 118),
		            Line = rgb(0, 0, 0),
		            Seg = rgb(255, 255, 255),
		        },
		        {
		            Window = rgb(5, 5, 9),
		            Card = rgb(21, 21, 28),
		            Field = rgb(11, 11, 16),
		            Off = rgb(56, 57, 68),
		            Text = rgb(240, 242, 250),
		            Sub = rgb(128, 133, 152),
		            Line = rgb(255, 255, 255),
		            Seg = rgb(68, 70, 86),
		        },
		        {
		            Window = rgb(9, 24, 42),
		            Card = rgb(19, 44, 70),
		            Field = rgb(12, 31, 52),
		            Off = rgb(50, 78, 106),
		            Text = rgb(232, 244, 255),
		            Sub = rgb(128, 160, 192),
		            Line = rgb(255, 255, 255),
		            Seg = rgb(60, 94, 128),
		        },
		        {
		            Window = rgb(13, 28, 21),
		            Card = rgb(23, 49, 37),
		            Field = rgb(16, 36, 28),
		            Off = rgb(56, 88, 71),
		            Text = rgb(234, 249, 239),
		            Sub = rgb(132, 172, 149),
		            Line = rgb(255, 255, 255),
		            Seg = rgb(64, 104, 82),
		        },
		        {
		            Window = rgb(30, 22, 19),
		            Card = rgb(53, 41, 35),
		            Field = rgb(37, 28, 24),
		            Off = rgb(92, 76, 67),
		            Text = rgb(250, 240, 229),
		            Sub = rgb(178, 153, 136),
		            Line = rgb(255, 255, 255),
		            Seg = rgb(112, 92, 80),
		        },
		        {
		            Window = rgb(252, 237, 243),
		            Card = rgb(255, 250, 252),
		            Field = rgb(247, 225, 234),
		            Off = rgb(233, 204, 216),
		            Text = rgb(60, 27, 41),
		            Sub = rgb(152, 102, 125),
		            Line = rgb(0, 0, 0),
		            Seg = rgb(255, 255, 255),
		        },
		    }

		    local ThemeNames = { "Tối", "Sáng", "Nửa đêm", "Đại dương", "Rừng xanh", "Cà phê", "Sakura" }

		    local Accents = {
		        { "Xanh dương", rgb(10, 132, 255) },
		        { "Tím", rgb(191, 90, 242) },
		        { "Hồng", rgb(255, 55, 95) },
		        { "Cam", rgb(255, 159, 10) },
		        { "Xanh lá", rgb(48, 209, 88) },
		        { "Ngọc", rgb(64, 200, 224) },
		    }

		    local ScaleFactors = { 0.9, 1, 1.12 }
		    local KIND_ORDER = { "success", "info", "warn", "error" }

		    local Settings = {
		        Expand = true,
		        Split = true,
		        RimLight = true,
		        Theme = 1,
		        Language = "en",  
		        Accent = 1,
		        Blur = true,
		        BlurSize = 16,
		        Scale = 2,
		        Sound = true,
		        Volume = 40,
		        ToggleKey = Enum.KeyCode.RightShift,
		        Breathe = true,
		        AutoHide = true,
		        Duration = 2.5,
		        NotifyKind = 1,
		        Reverb = true,
		        Ring = true,
		    }
