"""Local Cross assistant guide in English and Vietnamese."""
sections_ai = [(
 'cross-control-guide', 'GUIDES', 'HƯỚNG DẪN', 'Cross AI: control your UI', 'Cross AI: điều khiển UI', '33',
 r'''# Cross AI: control your UI

Cross is a **local rule-based assistant**, not a general-purpose language model. It indexes the controls created by this xNgot window, including controls created later by your script. It does not scan other Roblox GUIs. Labels are matched by name; it cannot infer the purpose of arbitrary code from a label.

## Start and confirm

1. Open **Settings → Open Dynamic Island Settings → Cross AI Assistant** and turn on **Enable Cross AI**.
2. Enter a request and press **Send to Cross AI**. For example, `bật Show FPS`.
3. Read the proposed action, target name and tab. Reply `có`/`yes` or use **Confirm Cross AI action**; to reject, reply `không`/`no` or use **Cancel Cross AI action**.
4. Confirm within 60 seconds. An expired or canceled request does nothing. Locked or destroyed controls are refused; renamed targets need a new request. The control may also change while confirmation is pending.

You can use the Cross chat on the island too: open it with **Open Cross AI on Island**, then type the request and confirmation there.

## Example requests

| Request | Behavior |
| --- | --- |
| `danh sách chức năng` / `list controls` | List indexed controls, 15 per page; append `2` for the next page. |
| `bật Show FPS` | Propose enabling that toggle. |
| `tắt Main Auto Farm` | Propose disabling `Auto Farm` in tab `Main`, if it exists. |
| `đặt Sound Volume 40` | Propose a slider value; it is rounded to the slider step. |
| `chọn Mode "Fast"` | Propose a dropdown option. |
| `đổi Nickname "Hana"` | Propose an input value; quotes are required. |
| `đổi Accent #66AAFF` | Propose a Colorpicker value. |
| `bấm Rejoin` | Propose a button click. Buttons may have side effects; confirm only after reading the target. |

Names in examples must exist in your UI. If names are duplicated, include the tab name. Some Vietnamese aliases, such as `tốc độ` for `Speed`, are supported; this is not free-form AI and unfamiliar wording may not match. A name alone may propose a toggle/section's opposite state or a button action, but confirmation is still mandatory.

The assistant supports Section (open/close), Toggle, Button, Slider, Input, Dropdown (including adding/removing one multi-select option), and Colorpicker. Paragraph and Code can have their displayed text changed with a quoted value; Info changes its bio and Discord changes its invite link. Code content is displayed, not executed. Assistant-owned controls are excluded to avoid recursive actions. For single-choice dropdowns, select an existing option; multi-select `bỏ` / `remove` removes one selected option.

> Only AI-proposed **UI control changes** have the confirmation gate. Existing music/timer chat commands remain immediate; music searches may contact third-party services. A confirmed button runs its original callback, which may do anything the original script allows. Errors can happen after a callback has partially acted.

## Player and current session

Ask `What is my username?`, `player info`, `game name`, `place id`, `game id`, `job id`, `player count`, or `game info`. Cross reads the local player's Roblox `Name`, `DisplayName` and `UserId`; `PlaceId`, `GameId` (universe ID) and `JobId` come from the current Roblox session; player count and capacity come from `Players`. The game name is the **current place's** product name from `MarketplaceService`, which can differ from the overall experience name. That lookup may yield or fail; a missing value is reported as unavailable rather than guessed. An empty JobId, such as in some Studio sessions, is also unavailable. These replies do not teach or persist the identifiers in the Cross learning JSON; chat remains in the current session. Treat JobId as potentially sensitive if you do not want others to join or identify your server.

These are read-only replies and do not require UI confirmation. If an action is already awaiting confirmation, resolve it first. The assistant recognizes supported phrases, not every possible wording.

## Developer opt-out and API

Set `AIControl = false` on a control to keep it out of the assistant's index. `island:AiPermission("Ui", false)` disables UI listing and execution, including requests already pending. Exclude sensitive buttons or inputs whose callbacks should not be callable from chat.

```lua
Tab:Button({
    Title = "Sensitive action",
    AIControl = false,
    Callback = function() print("Run only through the UI") end,
})

local island = Window:GetDynamicIsland()
if island then
    island:AiEnable(true)
    island:AiAsk("bật Show FPS") -- proposes only
    print(island:AiState().Pending)
    island:AiAsk("no")            -- cancel, never execute
end
```

The input and chat history are not saved as a full log, but some confirmed command phrases and control names may be stored in local JSON automatically. Do not enter secrets. See Cross automatic memory. `AiAsk` can yield for music searches or game-name lookup; use a task when appropriate. The chat confirmation path is not an authorization boundary against other scripts using the library API directly.
''',
 r'''# Cross AI: điều khiển UI

Cross là **trợ lý local theo quy tắc**, không phải mô hình ngôn ngữ tổng quát. Nó lập danh sách control do cửa sổ xNgot này tạo, kể cả control được script thêm sau. Nó không quét GUI Roblox khác và không tự hiểu công dụng của code chỉ từ tên.

## Bắt đầu và xác nhận

1. Vào **Settings → Open Dynamic Island Settings → Cross AI Assistant**, bật **Enable Cross AI**.
2. Nhập lệnh rồi nhấn **Send to Cross AI**, ví dụ `bật Show FPS`.
3. Đọc hành động, tên control và tab. Trả lời `có`/`yes` hoặc nhấn **Confirm Cross AI action**; để từ chối, trả lời `không`/`no` hoặc nhấn **Cancel Cross AI action**.
4. Xác nhận trong 60 giây. Hết hạn hoặc hủy sẽ không thay đổi gì. Control bị khóa/đã xóa sẽ bị từ chối; nếu đổi tên, hãy ra lệnh lại. Trạng thái control có thể thay đổi trong lúc chờ.

Bạn cũng có thể dùng chat Cross trên đảo: nhấn **Open Cross AI on Island**, rồi nhập lệnh và câu xác nhận tại đó.

## Ví dụ lệnh

| Lệnh | Cách hoạt động |
| --- | --- |
| `danh sách chức năng` / `list controls` | Liệt kê control, 15 mục mỗi trang; thêm `2` để xem trang tiếp. |
| `bật Show FPS` | Đề xuất bật toggle đó. |
| `tắt Main Auto Farm` | Đề xuất tắt `Auto Farm` trong tab `Main`, nếu có. |
| `đặt Sound Volume 40` | Đề xuất giá trị slider, làm tròn theo Step. |
| `chọn Mode "Fast"` | Đề xuất lựa chọn dropdown. |
| `đổi Nickname "Hana"` | Đề xuất giá trị ô nhập; cần dấu ngoặc kép. |
| `đổi Accent #66AAFF` | Đề xuất màu cho Colorpicker. |
| `bấm Rejoin` | Đề xuất bấm nút. Nút có thể gây tác động khác; chỉ xác nhận sau khi đọc đúng mục. |

Tên ví dụ phải tồn tại trong UI của bạn. Nếu trùng tên, hãy thêm tên tab. Có một số từ đồng nghĩa như `tốc độ` cho `Speed`; đây không phải AI hiểu mọi cách diễn đạt, nên câu lạ có thể không khớp. Chỉ nhập tên cũng có thể đề xuất đảo trạng thái toggle/section hoặc bấm nút, nhưng vẫn phải xác nhận.

Hỗ trợ Section (mở/đóng), Toggle, Button, Slider, Input, Dropdown (thêm/bỏ một mục multi-select) và Colorpicker. Paragraph và Code có thể đổi nội dung hiển thị bằng chuỗi trong dấu ngoặc kép; Info đổi bio và Discord đổi link mời. Nội dung Code chỉ được hiển thị, không tự chạy. Control riêng của trợ lý được loại khỏi danh sách để tránh gọi lặp. Dropdown đơn chọn một mục có sẵn; với multi-select dùng `bỏ` / `remove` để bỏ một mục đang chọn.

> Chỉ các thay đổi **control UI do AI đề xuất** mới qua bước xác nhận. Lệnh chat nhạc/hẹn giờ có sẵn vẫn chạy ngay; tìm nhạc có thể gọi dịch vụ bên thứ ba. Khi xác nhận nút, callback gốc sẽ chạy và có thể làm mọi việc script cho phép. Nếu callback lỗi, một phần tác động có thể đã xảy ra.

## Người chơi và phiên hiện tại

Bạn có thể hỏi `tên tôi là gì`, `thông tin người chơi`, `tên game`, `place id`, `game id`, `job id`, `bao nhiêu người chơi` hoặc `thông tin game`. Cross đọc `Name`, `DisplayName` và `UserId` của người chơi local; `PlaceId`, `GameId` (UniverseId) và `JobId` lấy từ phiên Roblox hiện tại; số người và sức chứa lấy từ `Players`. Tên game là **tên place hiện tại** lấy qua `MarketplaceService`, có thể khác tên trải nghiệm tổng thể. Tra cứu tên có thể chờ hoặc thất bại; khi không lấy được, Cross báo không có thay vì đoán. JobId rỗng, ví dụ trong một số phiên Studio, cũng được báo không lấy được. Các câu trả lời này không dạy hay lưu ID vào JSON học của Cross; chat chỉ tồn tại trong phiên. Cẩn thận khi chia sẻ JobId nếu không muốn người khác nhận diện hoặc tham gia server.

Đây là thông tin chỉ đọc, không cần xác nhận UI. Nếu đang có hành động chờ xác nhận, hãy xử lý hành động đó trước. Cross nhận diện một số cách hỏi, không phải mọi câu tự do.

## Loại control và API cho người viết script

Đặt `AIControl = false` để control không xuất hiện trong danh sách AI. `island:AiPermission("Ui", false)` tắt liệt kê và điều khiển UI, kể cả yêu cầu đang chờ. Nên loại các nút hoặc ô nhập nhạy cảm mà bạn không muốn gọi qua chat.

```lua
Tab:Button({
    Title = "Sensitive action",
    AIControl = false,
    Callback = function() print("Chỉ chạy qua UI") end,
})

local island = Window:GetDynamicIsland()
if island then
    island:AiEnable(true)
    island:AiAsk("bật Show FPS") -- chỉ đề xuất
    print(island:AiState().Pending)
    island:AiAsk("no")            -- hủy, không chạy
end
```

Ô nhập và lịch sử chat không được lưu thành log đầy đủ, nhưng một số câu đã xác nhận và tên control có thể tự ghi vào JSON local. Đừng nhập thông tin bí mật; xem Cross tự ghi nhớ. `AiAsk` có thể yield khi tìm nhạc hoặc tra tên game; dùng task khi cần. Xác nhận trong chat không ngăn script khác trực tiếp gọi API của thư viện.
'''
)]
