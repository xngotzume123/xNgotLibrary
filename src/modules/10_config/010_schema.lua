--[[ xngot-studio · src/modules/10_config/010_schema.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/10_config · cấu hình nhạc toàn cục _G.xNgotMusicConfig
     module : config.schema
     role   : Bảng schema cho _G.xNgotMusicConfig (kiểu, min/max, mặc định)
     source : main 2.txt L20-59 · 40 dòng · delta +0
--]]
local ConfigSchema = {
	topN = { type = "number", min = 1, max = 40, default = 12,
		desc = "Số kết quả trả về cho dropdown" },
	sources = { type = "table", default = { "youtube", "soundcloud", "audius" },
		desc = "Nguồn tìm nhạc (youtube / soundcloud / audius / tiktok / audiomack)" },
	searchTimeout = { type = "number", min = 2, max = 60, default = 12,
		desc = "Giây tối đa cho 1 lượt tìm" },
	preferShort = { type = "number", min = 0, max = 7200, default = 600,
		desc = "Ưu tiên bài <= N giây (0 = tắt)" },

	folder = { type = "string", default = "xNgotLibrary/Music",
		desc = "Thư mục cache mp3" },
	raceTracks = { type = "number", min = 1, max = 4, default = 2,
		desc = "Số bài tải SONG SONG (1 = tuần tự, nhẹ mạng)" },
	downloadTimeout = { type = "number", min = 20, max = 600, default = 200,
		desc = "Giây tối đa chờ loader.to chuyển mã" },
	retries = { type = "number", min = 0, max = 5, default = 2,
		desc = "Số lần thử lại khi lỗi" },
	renameFiles = { type = "boolean", default = true,
		desc = "Đặt tên file theo TÊN BÀI (false = chỉ hash)" },

	aiBrain = { type = "string", default = "local",
		desc = "Bộ não AI: local (offline, không cần mạng)" },
	aiLearn = { type = "boolean", default = true,
		desc = "AI tự học: ghi nhớ bài bị bỏ qua để lần sau lọc tốt hơn" },

	coverArt = { type = "boolean", default = true,
		desc = "Hiện ảnh bìa trong dropdown + Dynamic Island" },
	compactRows = { type = "boolean", default = false,
		desc = "Thẻ nhạc gọn (1 dòng chữ thay vì 2)" },
	showSource = { type = "boolean", default = true,
		desc = "Hiện nhãn nguồn (YT / SC / AU) trên thẻ" },
	notifyOnSearch = { type = "boolean", default = true,
		desc = "Hiện thông báo mỗi lần tìm xong" },
	debug = { type = "boolean", default = false,
		desc = "In log ra console để gỡ lỗi" },
}

local Config = {}
