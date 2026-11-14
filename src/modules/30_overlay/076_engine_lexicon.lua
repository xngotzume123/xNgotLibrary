--[[ xngot-studio · src/modules/30_overlay/076_engine_lexicon.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : engine.lexicon
     role   : LEXICON + put() + STOP: từ điển phân tích prompt
     source : main 2.txt L6665-6768 · 104 dòng · delta +0
--]]
		local LEXICON = {}
		local function put(group, canonical, list)
			for _, w in ipairs(list) do LEXICON[norm(w)] = { tag = group, canon = canonical } end
		end

		put("genre", "lofi", { "lofi", "lo-fi", "lo fi", "chillhop", "nhac nhe" })
		put("genre", "chill", { "chill", "chillout", "thu gian", "thư giãn", "relax", "thu thai", "thư thái" })
		put("genre", "jazz", { "jazz", "jazzy", "nhac jazz" })
		put("genre", "piano", { "piano", "dan piano", "đàn piano" })
		put("genre", "acoustic", { "acoustic", "moc", "mộc", "guitar" })
		put("genre", "edm", { "edm", "electronic", "dien tu", "điện tử", "house", "techno", "remix", "vinahouse" })
		put("genre", "hiphop", { "hiphop", "hip hop", "rap", "trap", "drill" })
		put("genre", "rock", { "rock", "metal", "punk" })
		put("genre", "pop", { "pop", "nhac pop", "vpop", "usuk", "us uk" })
		put("genre", "ballad", { "ballad", "buon", "buồn", "sad", "tam trang", "tâm trạng", "that tinh", "thất tình" })
		put("genre", "classical", { "classical", "co dien", "cổ điển", "orchestra", "giao huong", "giao hưởng" })
		put("genre", "latin", { "latin", "salsa", "bossa", "bossa nova" })
		put("genre", "kpop", { "kpop", "k-pop", "nhac han", "nhạc hàn" })
		put("genre", "anime", { "anime", "ost anime", "nhac nhat", "nhạc nhật", "jpop" })
		put("genre", "country", { "country", "folk", "dan ca", "dân ca" })
		put("genre", "ambient", { "ambient", "khong loi", "không lời", "instrumental", "nhac nen", "nhạc nền" })
		put("genre", "cinematic", { "cinematic", "epic", "hung trang", "hùng tráng", "trailer" })
		put("genre", "game", { "game", "8bit", "chiptune", "retro", "roblox" })

		put("mood", "happy", { "vui", "happy", "vui ve", "vui vẻ", "phan khich", "phấn khích", "upbeat", "sang khoai", "sảng khoái" })
		put("mood", "sad", { "buon", "buồn", "sad", "co don", "cô đơn", "alone", "u sau", "u sầu" })
		put("mood", "focus", { "hoc bai", "học bài", "tap trung", "tập trung", "focus", "study", "lam viec", "làm việc", "work" })
		put("mood", "sleep", { "ngu", "ngủ", "ru ngu", "ru ngủ", "sleep", "mat ngu", "mất ngủ", "insomnia" })
		put("mood", "chill", { "thu gian", "thư giãn", "chill", "nhe nhang", "nhẹ nhàng", "em diu", "êm dịu", "soft" })
		put("mood", "hype", { "soi dong", "sôi động", "chay", "cháy", "hype", "mau lua", "máu lửa", "workout", "gym", "tap the duc" })
		put("mood", "romantic", { "lang man", "lãng mạn", "romantic", "tinh yeu", "tình yêu", "love" })
		put("mood", "dark", { "dark", "toi tam", "tăm tối", "u am", "u ám", "horror", "dang so", "đáng sợ" })
		put("mood", "cafe", { "cafe", "cà phê", "quan cafe", "quán cà phê", "buoi sang", "buổi sáng", "morning", "sang som", "sáng sớm" })
		put("mood", "rain", { "mua", "mưa", "rain", "rainy", "dem mua", "đêm mưa" })
		put("mood", "night", { "buoi toi", "buổi tối", "toi nay", "tối nay", "buoi dem", "buổi đêm",
			"dem", "đêm", "night", "evening", "midnight", "nua dem", "nửa đêm", "khuya" })
		put("mood", "drive", { "lai xe", "lái xe", "drive", "phuot", "phượt", "roadtrip", "xe" })
		put("mood", "party", { "tiec", "tiệc", "party", "club", "bar", "nhay", "nhảy" })

		put("ctx", "short", { "ngan", "ngắn", "short", "duoi 3 phut", "dưới 3 phút" })
		put("ctx", "long", { "dai", "dài", "long", "nhieu gio", "nhiều giờ", "mix", "playlist dai" })
		put("ctx", "vietnam", { "viet", "việt", "vpop", "nhac viet", "nhạc việt", "nhac tre", "nhạc trẻ" })
		put("genre", "bolero", { "bolero", "nhac vang", "nhạc vàng", "tru tinh", "trữ tình", "nhac tru tinh", "nhạc trữ tình", "nhac song", "nhạc sống", "ho quang", "hồ quảng" })
		put("mood", "romantic", { "lang man", "lãng mạn", "tinh cam", "tình cảm", "yeu", "yêu", "nho", "nhớ" })
		put("ctx", "english", { "english", "us-uk", "usuk", "nhac my", "nhạc mỹ", "quoc te", "quốc tế" })
		put("ctx", "looptrack", { "lap lai", "lặp lại", "repeat", "loop" })

		put("ctx", "gaming", { "choi game", "chơi game", "gaming", "tryhard", "rank", "dang rank", "đang rank",
			"lien quan", "liên quân", "valorant", "lol", "minecraft", "blox fruits", "pvp", "speedrun" })
		put("ctx", "code", { "code", "lap trinh", "lập trình", "coding", "dev", "debug", "type code", "viet code", "viết code" })
		put("mood", "calm", { "binh yen", "bình yên", "an yen", "an yên", "peaceful", "calm", "tinh lang", "tĩnh lặng", "nhe nhang" })
		put("mood", "nostalgia", { "hoai niem", "hoài niệm", "xua", "xưa", "ky uc", "ký ức", "memory", "nostalgic", "8x", "9x" })
		put("mood", "motivated", { "truyen cam hung", "truyền cảm hứng", "dong luc", "động lực", "motivation", "inspire", "chay deadline" })
		put("mood", "heartbreak", { "that tinh", "thất tình", "chia tay", "breakup", "bi bo roi", "bị bỏ rơi", "co don" })
		put("mood", "sunny", { "nang", "nắng", "troi nang", "trời nắng", "summer", "mua he", "mùa hè", "bien", "biển" })
		put("mood", "coffee", { "ca phe", "cà phê", "cafe", "highlands", "phuc long", "quan ca phe" })
		put("mood", "focus", { "deadline", "thi", "ôn thi", "on thi", "chay deadline", "nang suat", "năng suất" })
		put("genre", "phonk", { "phonk", "drift phonk", "sigma" })
		put("genre", "indie", { "indie", "indie viet", "nhac indie", "nhạc indie" })
		put("genre", "rap-viet", { "rap viet", "rap việt", "rap vn", "nhac rap viet" })
		put("genre", "remix-viet", { "remix viet", "remix việt", "vinahouse", "vina house", "nonstop viet" })
		put("genre", "kpop-dance", { "kpop dance", "nhay kpop", "nhảy kpop", "dance cover" })
		put("genre", "citypop", { "city pop", "citypop", "thanh thi", "thành thị" })
		put("artist", "son-tung-mtp", { "son tung", "sơn tùng", "son tung mtp", "sơn tùng mtp" })
		put("artist", "mono", { "mono", "mono viet" })
		put("artist", "hoang-dung", { "hoang dung", "hoàng dũng" })
		put("artist", "vu-cat-tuong", { "vu", "vũ", "vu cat tuong", "vũ cát tường" })
		put("artist", "my-tam", { "my tam", "mỹ tâm" })
		put("artist", "binz", { "binz" })
		put("artist", "den-vau", { "den vau", "đen vâu", "den" })
		put("artist", "justatee", { "justatee", "justa tee" })
		put("artist", "taylor-swift", { "taylor swift", "taylor", "swiftie" })
		put("artist", "lofi-girl", { "lofi girl", "lofigirl" })
		put("artist", "weeknd", { "the weeknd", "weeknd", "abel" })
		put("artist", "billie-eilish", { "billie eilish", "billie", "eilish" })
		put("artist", "ed-sheeran", { "ed sheeran", "ed" })
		put("artist", "chill-nation", { "chill nation" })
		put("artist", "newjeans", { "newjeans", "new jeans", "nj" })
		put("artist", "bts", { "bts", "bangtan" })
		put("artist", "blackpink", { "blackpink", "black pink", "bp" })
		put("artist", "adele", { "adele" })
		put("artist", "eminem", { "eminem", "slim shady" })
		put("artist", "daft-punk", { "daft punk" })
		put("artist", "hans-zimmer", { "hans zimmer" })
		put("artist", "lofi-records", { "chilledcow", "lofi records" })

		CrossAIMusic.Lexicon = LEXICON

		local STOP = {}
		for _, w in ipairs({
			"toi", "tôi", "minh", "mình", "ban", "bạn", "muon", "muốn", "can", "cần", "hay", "hãy",
			"giup", "giúp", "cho", "và", "va", "cua", "của", "mot", "một", "bai", "bài", "hat", "hát",
			"nhac", "nhạc", "nghe", "mo", "mở", "phat", "phát", "tim", "tìm", "kiem", "kiếm",
			"play", "some", "please", "me", "song", "songs", "music", "track", "tracks", "a", "an", "the",
			"for", "with", "and", "or", "to", "in", "on", "of", "that", "this", "like", "want", "need",
			"gi", "gì", "nao", "nào", "duoc", "được", "roi", "rồi", "nhe", "nhé", "nha",
			"luc", "lúc", "khi", "trong", "ngoai", "giua", "buoi", "buổi", "chieu", "chiều",
			"trua", "sang", "som", "sớm", "muon", "muộn", "de", "để", "voi", "với", "o", "ở",
			"tai", "tại", "nay", "kia", "do", "đó", "thi", "thì", "cung", "cũng", "se", "sẽ",
			"dang", "đang", "vua", "vừa", "rat", "rất", "qua", "quá", "lam", "làm", "di", "đi",
			"chut", "chút", "vao", "vào", "ra", "len", "lên", "xuong", "xuống",
			"study", "work", "gym", "any", "good", "best", "vibe", "vibes",
		}) do STOP[norm(w)] = true end

