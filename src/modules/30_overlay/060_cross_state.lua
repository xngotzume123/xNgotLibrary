--[[ xngot-studio · src/modules/30_overlay/060_cross_state.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.cross_state
     role   : Bảng Cross (AI chat) + state ban đầu
     source : main 2.txt L5335-5358 · 24 dòng · delta +0
--]]
		    local Cross = {
		        Enabled = false,
		        Mood = "neutral",
		        MoodUntil = 0,
		        SpeakUntil = 0,
		        Thinking = false,
		        Acting = false,
		        Lang = "vi",
		        Chat = {},
		        ChatVersion = 0,
		        Shell = { Lines = {}, Version = 0 },
		        Bubble = { Full = "", Shown = "", Count = 0, Rate = 54 },
		        Echo = "",
		        Faces = {},
		        Shells = {},
		        MarkText = "",
		        Pose = {},
		        Target = {},
		        Perm = { Ui = true, Body = false, Free = false, Key = true },
		        Busy = 0,
		        Idle = "neutral",
		        Inputs = {},
		    }

