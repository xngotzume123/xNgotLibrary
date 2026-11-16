"""Documentation for automatic per-account local memory."""
sections_learning = [(
 'cross-learning', 'GUIDES', 'HƯỚNG DẪN', 'Cross automatic memory', 'Cross tự ghi nhớ', '34',
 r'''# Cross automatic memory

Cross remembers eligible confirmed UI requests automatically; there is no Learning section or setup switch in Settings. It is a local rule-based lookup and frequency counter, **not model training** or an online chatbot. It cannot infer every unfamiliar sentence.

## How it learns

1. Enable Cross in **Settings → Open Dynamic Island Settings → Cross AI Assistant**.
2. Ask for an existing control, for example `bật Show FPS`. Cross proposes an action; review the name and tab, then answer `có`/`yes` or `không`/`no`.
3. A successful confirmed UI operation increases that control's use counter, up to 80 distinct controls. For eligible toggle, section and button phrases, Cross may save the phrase and its specific action (up to 80 learned phrases). Cancellation, expiry, blocked permissions or failed actions do not teach it.
4. If Cross cannot match an action-like request, it may ask you to clarify the control and action. Give the existing tab and control name, for example `bật Main Auto Farm`, then confirm. If the direction agrees and the phrase is eligible, Cross remembers the first phrase for later use. It will **still ask before acting** on a learned phrase.

For safety, automatic phrase learning is limited to short phrases without numbers, quotes, URLs or certain sensitive terms; these checks are imperfect. It only saves phrases for toggle, section and button actions, not arbitrary input text or code. It stores a normalized phrase and its mapped control/action; slider, dropdown, input, color and other controls can still be operated with confirmation and counted, but their value or arbitrary input is not automatically saved as a learned phrase. Manual clicks outside Cross are not counted.

Duplicate names require the tab; a renamed, deleted, locked or duplicated target cannot be automatically run from an old mapping. Some existing music and timer chat commands remain immediate, rather than going through UI confirmation. Send `gợi ý` / `preferences` to see frequently confirmed controls; these are suggestions, not automatic actions.

## Storage and privacy

The executor stores `xNgotLibrary/AI/xNgotCrossAI_user_<UserId>.json` in its workspace. This is local to the account and executor/device, not online synchronization. The legacy root file is read if the new file does not exist; the original is not deleted. Existing compatible learned phrases remain available; older files with remembering turned off are now read with automatic remembering on. Counts store tab, control name, type and frequency, not values. They may still reveal information if a control name itself contains personal data.

The JSON is **plain text**, and can be read or altered by other scripts or anyone with workspace access. The phrase filter cannot reliably detect all personal data, so do not put passwords, keys or private information in Cross requests. Full chat history is not saved by this feature. The file can be removed manually in the executor workspace if needed; there is no Learning management section in the UI.

`isfile`, `readfile`, `writefile` and Roblox `HttpService` JSON support are required. If unavailable or a write fails, the assistant reports that learning is **session only**; it is not guaranteed to survive restart. An invalid, unreadable, oversized or wrong-user file is not silently overwritten. Back it up and inspect it before manually removing it. None of this prevents another script from directly calling the library API.

Developers can inspect `island:AiLearningState()` for the local path and error status. The former `AiSetRemember(false)` switch cannot disable automatic learning in this build. Previously provided learning APIs remain for compatibility, but no setup or management controls are shown in Settings.
''',
 r'''# Cross tự ghi nhớ

Cross tự ghi nhớ các yêu cầu UI phù hợp sau khi được xác nhận; không còn mục Learning hay nút cài đặt việc học. Đây là tra cứu local và đếm tần suất theo quy tắc, **không phải huấn luyện mô hình** hay chatbot online. Nó không thể tự hiểu mọi câu chưa biết.

## Cách học

1. Bật Cross tại **Settings → Open Dynamic Island Settings → Cross AI Assistant**.
2. Yêu cầu control đã có, ví dụ `bật Show FPS`. Cross đề xuất hành động; đọc tên và tab rồi trả lời `có`/`yes` hoặc `không`/`no`.
3. Thao tác UI được xác nhận và gọi thành công sẽ tăng số lần dùng control, tối đa 80 control khác nhau. Với câu phù hợp dành cho toggle, section hoặc button, Cross có thể lưu câu và hành động tương ứng, tối đa 80 câu. Hủy, hết hạn, bị khóa quyền hoặc thao tác lỗi thì không học.
4. Nếu chưa khớp một câu có ý định thao tác, Cross có thể hỏi lại tên chức năng và hành động. Hãy ghi rõ tab và control có sẵn, ví dụ `bật Main Auto Farm`, rồi xác nhận. Nếu hướng bật/tắt khớp và câu đủ điều kiện, Cross ghi nhớ cách gọi ban đầu. Lần sau dùng câu đó, AI **vẫn hỏi trước khi thao tác**.

Để hạn chế dữ liệu nhạy cảm, chỉ một số câu ngắn không chứa số, dấu ngoặc kép, URL hoặc từ nhạy cảm được tự lưu; bộ lọc không hoàn hảo. Việc tự học câu chỉ áp dụng cho toggle, section và button, không lưu nội dung input/code tùy ý. File lưu câu đã chuẩn hóa và control/hành động tương ứng; slider, dropdown, input, color và control khác vẫn thao tác được sau xác nhận và được đếm lượt dùng, nhưng giá trị hoặc nội dung nhập tùy ý không được tự lưu thành câu học. Các lần bấm UI trực tiếp ngoài Cross không được đếm.

Tên trùng cần chỉ rõ tab; mục đổi tên, bị xóa, khóa hoặc trùng không thể tự chạy qua mapping cũ. Một số lệnh nhạc/hẹn giờ có sẵn vẫn chạy ngay, không qua xác nhận control UI. Gửi `gợi ý` / `preferences` để xem các control thường được xác nhận; Cross chỉ gợi ý, không tự bật.

## Lưu trữ và riêng tư

File `xNgotLibrary/AI/xNgotCrossAI_user_<UserId>.json` nằm trong workspace executor, riêng theo tài khoản và thiết bị/executor, không đồng bộ online. Nếu chưa có file mới, Cross đọc file cũ ở thư mục gốc và không tự xóa file cũ. Câu đã học tương thích từ bản trước vẫn có thể dùng; file cũ đang tắt ghi nhớ sẽ được đọc với chế độ tự ghi nhớ bật. Bộ đếm lưu tab, tên, loại control và số lần, không lưu giá trị. Tuy vậy, nếu chính tên control chứa dữ liệu cá nhân thì tên đó có thể bị lưu.

JSON là **văn bản thường**; script khác hoặc người có quyền vào workspace có thể đọc/sửa. Bộ lọc câu không nhận diện được mọi thông tin cá nhân, nên không nhập mật khẩu, key hay nội dung riêng tư vào yêu cầu Cross. Tính năng này không lưu toàn bộ lịch sử chat. Nếu cần, bạn có thể tự xóa file trong workspace executor; UI không có mục quản lý Learning.

Cần `isfile`, `readfile`, `writefile` và JSON của Roblox `HttpService`. Nếu thiếu hoặc ghi lỗi, trợ lý báo chỉ ghi nhớ **trong phiên**, không chắc còn sau khi chạy lại. File sai định dạng, không đọc được, quá lớn hoặc thuộc UserId khác không bị tự ghi đè; hãy sao lưu và kiểm tra trước khi tự xóa. Việc này không ngăn script khác gọi trực tiếp API thư viện.

Người viết script có thể xem đường dẫn và lỗi bằng `island:AiLearningState()`. Công tắc API cũ `AiSetRemember(false)` không tắt tự ghi nhớ trong bản này. Các API học cũ vẫn giữ để tương thích, nhưng không có control cài đặt/quản lý trong Settings.
'''
)]
