sections_localai_v2 = [(
 'local-ai-v2', 'GUIDES', 'HƯỚNG DẪN', 'Cross: integrated offline intelligence', 'Cross: tích hợp xử lý offline', '35',
 r'''# Cross: integrated offline intelligence

The existing Cross chat in Dynamic Island is the only assistant interface; **there is no additional Local AI tab**. Offline rule-based V2 capabilities run behind Cross. This is not an LLM: it recognizes selected Vietnamese (with or without accents) and English patterns, not every free-form sentence. AI processing does not require an external model or AI key. Existing online music and other network features remain independent.

## Everyday use

Open Cross as before and ask `bật Main Auto Farm`, `giải thích Main Auto Farm`, `mở tab Main`, `chẩn đoán`, or `fps ping`. Ordinary controls still use Cross's existing control support and confirmation. Say `có` / `yes` or `không` / `no`. Targets must be registered, unlocked, unambiguous and still valid; the UI permission switch and `AIControl=false` remain effective. Explaining describes the real control type, not unknown script-specific behavior. Diagnostics reports availability and errors observed by Cross or Local AI, not all failures; it does not modify source. FPS/Ping are sampled from existing metrics; no RAM is guessed. Alerts check every 15 seconds, at most one per minute, while Cross is enabled.

## Automatic learning and local data

Cross automatically learns eligible confirmed commands and preferences, just as before. No additional learning settings or UI are required. Its file remains `xNgotLibrary/AI/xNgotCrossAI_user_<UserId>.json`. The integrated engine also uses its existing separate `xNgotLibrary/AI/LocalAI_v2_user_<UserId>.json` for its own macros, music favorites and history, and previous V2 data. On a new installation, its local persistence is enabled automatically when filesystem support exists. An existing V2 memory setting is respected; invalid or externally changed files are protected from overwriting. If filesystem access fails, data may last only for the session. Files are local plain JSON, not encrypted; filtering is imperfect, so **do not enter secrets**. No online sync is performed by AI memory. Individual old V2 phrases remain recognized when they do not conflict with Cross's learned commands.

## Shell and Vietnamese replies

Open **Shell** inside Cross, type a request and press Send or Enter. It calls the same Cross handler as Chat: supported actions really run only after the same permission checks and confirmations. The scrollable activity log automatically jumps to the newest line when new activity arrives or Shell reopens. It mirrors actual Cross messages and responses, including pending confirmations and reported errors; it does not invent operating-system commands or claim completion before it is reported. Use **Chat** to return. Shell is not Windows PowerShell and cannot execute arbitrary Lua or OS commands. The last 80 wrapped lines are kept in session memory and cleared with Cross chat/window shutdown. Potential secrets and URLs are hidden from the log on a best-effort basis, not guaranteed; avoid entering them. Chat and Shell use the same assistant and confirmation state.

Cross chooses Vietnamese or English based on recognizable words in the request; Vietnamese with and without accents is supported. Ambiguous short replies generally retain the previous language. Not every phrase or error from third-party callbacks can be translated automatically.

## Several actions

For a one-time sequence, say `bật Main Auto Farm rồi tắt Main Auto Farm`. Each step needs a separate confirmation; `tạm dừng macro`, `tiếp tục macro`, and `hủy macro` control it. Steps already completed are not undone. The sequence supports registered Toggle/Section and Buttons whose author explicitly sets `AIAllowMacro=true`. Blocked/sensitive names are filtered on a best-effort basis; callbacks run original code and cannot be guaranteed harmless. Normal single-action Cross controls retain their existing wider support.

Optionally use `tạo macro tên: bật Main Auto Farm; tắt Main Auto Farm`, `chạy macro tên`, `danh sách macro`, or `xóa macro tên`. These are optional chat requests, not setup needed for ordinary usage. Matching is rule-based and unsupported formats are not executed.

## Local character movement

Cross or Shell accepts `speed 32`, `reset speed`, `fly`, `fly speed 50`, `disable fly`, `noclip`, `disable noclip`, or `stop movement`. Vietnamese equivalents include `tốc độ 32`, `đặt lại tốc độ`, `bật bay`, `tốc độ bay 50`, `tắt bay`, `bật noclip`, `tắt noclip` and `dừng tất cả di chuyển`. Starting a feature or changing a speed requires confirmation; stopping does not. Speeds are whole numbers from 4 to 100. Only your own current character is affected; nothing is persisted across sessions, and these are not executable macro steps. `AiPermission("Body", false)` immediately revokes and stops movement, and `Free` remains disabled. Movement permission defaults on but every activation requires confirmation.

While flying, use the normal movement controls and aim the camera up/down; Space or jump rises, Ctrl/C descends on desktop. Flight is client-side using the local character and may not work with every rig, executor, mobile control scheme, server-authoritative game, or anti-cheat. Stopping flight may cause falling. Noclip tracks original collision values and attempts to restore them when stopped; another script changing the same properties can interfere. Cross stops and cleans up when the character is removed or dies, when Cross is disabled, or when the window is destroyed. Speed restoration is conditional if the game changed it; reapply manually after respawning. Test only where you are permitted to use these capabilities.

## Music

Existing Cross music search/play remains unchanged and may use the internet. Favorites and playlists in the integrated engine use downloaded files: `favorite gentle song`, `thêm gentle song vào playlist chill`, `phát playlist chill`, `bài tiếp playlist chill`, `danh sách yêu thích`, `danh sách playlist`, `lịch sử nhạc`. Disable Music Auto before playlist playback; a local audio asset API is required. Playlist advancement is manual. Cache metadata and history can be incomplete or ambiguous, and requesting playback does not guarantee the client can decode the audio. The player can still independently access network resources.

Internal modules are available through `Window.LocalAI`; lifecycle cleanup runs with the window. Local JSON is not an encryption or privacy guarantee. Mock tests cannot replace a real Roblox/Delta test.
''',
 r'''# Cross: tích hợp xử lý offline

Người dùng chỉ dùng **khung chat Cross hiện có trong Dynamic Island**, không có tab Local AI mới. Các khả năng V2 chạy phía sau Cross. Đây là xử lý theo luật, không phải LLM: chỉ nhận diện một số mẫu tiếng Việt có/không dấu và tiếng Anh, không hiểu mọi câu tự do. Phần AI không cần model ngoài hay API key. Nhạc online và các chức năng mạng cũ hoạt động riêng.

## Dùng hằng ngày

Mở Cross như cũ và thử `bật Main Auto Farm`, `giải thích Main Auto Farm`, `mở tab Main`, `chẩn đoán` hoặc `fps ping`. Các lệnh control thông thường vẫn dùng Cross cũ và yêu cầu xác nhận. Trả lời `có` / `yes` hoặc `không` / `no`. Control phải được đăng ký, không bị khóa, không trùng và còn tồn tại; quyền UI và `AIControl=false` vẫn có hiệu lực. Giải thích dựa trên loại control thực, không đoán công dụng riêng của script. Chẩn đoán chỉ báo tình trạng và lỗi Cross/Local AI quan sát được, không kiểm tra toàn bộ lỗi và không sửa source. FPS/Ping lấy từ số đo sẵn có, không bịa RAM. Cảnh báo kiểm tra mỗi 15 giây, tối đa một lần mỗi phút khi Cross bật.

## Tự học và dữ liệu local

Cross tự học câu hợp lệ sau xác nhận và sở thích như trước, không cần thêm cài đặt hay giao diện quản lý. File cũ vẫn là `xNgotLibrary/AI/xNgotCrossAI_user_<UserId>.json`. Engine tích hợp vẫn dùng file riêng `xNgotLibrary/AI/LocalAI_v2_user_<UserId>.json` cho macro, yêu thích/lịch sử nhạc và dữ liệu V2 trước đó. Cài mới sẽ tự bật lưu local nếu executor hỗ trợ filesystem; lựa chọn bộ nhớ V2 có sẵn vẫn được giữ. File lỗi hoặc bị đổi từ bên ngoài được bảo vệ, không ghi đè. Nếu không lưu được, dữ liệu có thể chỉ tồn tại trong phiên. File là JSON local không mã hóa; bộ lọc không hoàn hảo nên **đừng nhập bí mật**. Bộ nhớ AI không đồng bộ online. Các câu V2 cũ vẫn được nhận diện nếu không trùng lệnh đã học của Cross.

## Shell và phản hồi tiếng Việt

Trong Cross, mở **Shell**, nhập yêu cầu rồi bấm Gửi hoặc Enter. Shell gọi cùng bộ xử lý với Chat: thao tác được hỗ trợ thực sự chạy sau khi qua cùng bước kiểm tra quyền và xác nhận. Nhật ký có thể cuộn và tự kéo xuống dòng mới nhất khi có hoạt động mới hoặc mở lại Shell. Nhật ký hiển thị tin nhắn, xác nhận đang chờ và lỗi mà Cross thực sự trả lời; không giả lập lệnh hệ điều hành hay báo hoàn thành trước khi có kết quả. Bấm **Chat** để quay lại. Shell không phải Windows PowerShell và không chạy Lua hay lệnh hệ điều hành tùy ý. Tối đa 80 dòng sau khi xuống dòng được giữ trong phiên và xóa cùng chat Cross/khi đóng. Bộ lọc ẩn bí mật hoặc URL trong nhật ký chỉ là cố gắng, không bảo đảm; không nên nhập bí mật. Chat và Shell dùng chung trợ lý và trạng thái xác nhận.

Cross chọn trả lời tiếng Việt hoặc tiếng Anh theo từ nhận diện được trong câu hỏi; hỗ trợ tiếng Việt có/không dấu. Câu ngắn không rõ ngôn ngữ thường giữ ngôn ngữ trước đó. Không phải mọi câu hay lỗi từ callback bên thứ ba đều dịch tự động.

## Nhiều thao tác

Có thể nói `bật Main Auto Farm rồi tắt Main Auto Farm` mà không cần tạo macro trước. Mỗi bước cần xác nhận riêng; nói `tạm dừng macro`, `tiếp tục macro` hoặc `hủy macro`. Các bước đã thực hiện không tự hoàn tác. Chuỗi hỗ trợ Toggle/Section và Button được tác giả cấp `AIAllowMacro=true`. Tên nhạy cảm được lọc theo danh sách giới hạn; callback chạy code gốc nên không thể bảo đảm an toàn tuyệt đối. Lệnh đơn của Cross vẫn hỗ trợ nhiều loại control hơn.

Nếu muốn lưu lại, có thể nói `tạo macro tên: bật Main Auto Farm; tắt Main Auto Farm`, `chạy macro tên`, `danh sách macro` hoặc `xóa macro tên`. Đây chỉ là lựa chọn qua chat, không phải bước cài đặt khi dùng bình thường. Câu ngoài mẫu có thể không được nhận diện và không được tự chạy.

## Di chuyển nhân vật local

Nhập trong Cross hoặc Shell: `tốc độ 32`, `đặt lại tốc độ`, `bật bay`, `tốc độ bay 50`, `tắt bay`, `bật noclip`, `tắt noclip` hoặc `dừng tất cả di chuyển`. Tiếng Anh có `speed 32`, `reset speed`, `fly`, `fly speed 50`, `disable fly`, `noclip`, `disable noclip`, `stop movement`. Bật hoặc thay đổi tốc độ phải xác nhận; lệnh dừng không cần xác nhận. Tốc độ là số nguyên từ 4 đến 100. Chỉ tác động nhân vật hiện tại của bạn; không lưu qua phiên và không đưa các lệnh này vào macro. `AiPermission("Body", false)` thu hồi quyền và dừng ngay; `Free` vẫn tắt. Quyền di chuyển mặc định bật nhưng từng lần kích hoạt vẫn cần xác nhận.

Khi bay, dùng điều khiển di chuyển bình thường và hướng camera lên/xuống; Space hoặc nút nhảy để lên, Ctrl/C trên máy tính để xuống. Đây là hiệu ứng phía client, có thể không hoạt động với mọi rig, executor, cách điều khiển mobile, game do server quyết định hoặc anti-cheat. Tắt bay có thể khiến nhân vật rơi. Noclip ghi lại và cố khôi phục va chạm khi dừng; script khác sửa cùng thuộc tính có thể gây xung đột. Cross dừng và dọn khi nhân vật bị xóa/chết, Cross bị tắt hoặc cửa sổ bị đóng. Tốc độ chỉ được khôi phục nếu game chưa đổi giá trị; cần bật lại sau hồi sinh. Chỉ sử dụng tại nơi bạn được phép.

## Nhạc

Tìm/phát nhạc Cross cũ không thay đổi và có thể dùng mạng. Yêu thích và playlist mới dùng file đã tải: `favorite gentle song`, `thêm gentle song vào playlist chill`, `phát playlist chill`, `bài tiếp playlist chill`, `danh sách yêu thích`, `danh sách playlist`, `lịch sử nhạc`. Tắt Music Auto trước khi phát playlist; executor cần API nạp audio local. Chuyển bài playlist thủ công. Metadata cache/lịch sử có thể thiếu hoặc trùng; yêu cầu phát không bảo đảm client giải mã được audio. Player cũ vẫn có thể truy cập mạng độc lập.

Module nội bộ vẫn ở `Window.LocalAI` và được dọn khi đóng cửa sổ. JSON local không phải cơ chế mã hóa. Test mock không thay thế test Roblox/Delta thực tế.
''')]
