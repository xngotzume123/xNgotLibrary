# xNgot Library — Hướng dẫn sử dụng


---

# Một giao diện, vô vàn ý tưởng.

xNgot Library là thư viện UI Roblox giúp bạn tạo script hub với cửa sổ, các điều khiển, tự lưu cài đặt, thông báo và Dynamic Island tích hợp. Tài liệu này mô tả **bản build trong workspace**, bao gồm màn hình key Ophyn đã tích hợp.

> **Lưu ý phiên bản:** Tài liệu dành cho bản test đã cập nhật. Nhánh `main` và link raw trên GitHub có thể vẫn là bản cũ cho đến khi bạn đưa các file mới lên repo.

## Bạn có thể tạo gì?

- **Một hub hoàn chỉnh** với tab, công tắc, thanh kéo, ô nhập và hộp thoại.
- **Màn hình key** với key local, PandaAuth, Jnkie, Platoboost hoặc validator riêng.
- **Bảng nổi** cho thông báo, hẹn giờ và nhạc.
- **Giao diện cá nhân** với preset, màu, font và profile có thể lưu.

## Bắt đầu từ đâu?

1. Nạp file `main.lua` trong workspace và tạo cửa sổ.
2. Thêm tab cùng các thành phần cần thiết.
3. Cấu hình key system nếu hub của bạn cần khóa.
4. Dùng API bảng nổi và theme khi cần.

> **Bảo mật phía client:** key local và secret nhúng trong script đều có thể bị đọc. Muốn xác thực thực sự, hãy thiết kế kiểm tra trên máy chủ đáng tin cậy.

---

# Cài đặt

Đặt file `main.lua` đã cập nhật vào workspace của executor. Kiểm tra executor có hỗ trợ `readfile` và `loadstring`. File trong thư mục Downloads của điện thoại không tự nằm trong workspace của executor.

## Nạp từ file local

```lua
getgenv().xNgotLibraryOnly = true

local source = readfile("main.lua")
local chunk, err = loadstring(source)
assert(chunk, err)
local LIB = chunk()
```

Đặt `xNgotLibraryOnly` **trước** khi nạp để chỉ lấy thư viện, không tự mở demo. Nếu không đặt cờ, file thường sẽ mở demo. Khi dùng `loadstring(readfile(...))()`, đừng quên `()` cuối.

## Nạp từ GitHub

Sau khi cập nhật `dist/main.lua` trên repo, bạn có thể dùng link raw:

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"
))()
```

> Link raw luôn lấy nội dung đang được đăng trên GitHub, không phải file test trong workspace. Các thay đổi chỉ xuất hiện sau khi bạn commit và push file mới.

## Build từ source

```bash
python3 src/build.py --release --minify
```

Lệnh tạo `dist/main.lua` và `dist/main.min.lua` chỉ một dòng sau credit. Wrapper một dòng cần `loadstring`, dựng lại mã light khi chạy; nếu cần, dùng `main.min.light.lua` trong ZIP hoặc build với `--minify light`. Compile thành công không thay thế test trong Roblox.

---

# Cửa sổ và tab

Tạo cửa sổ từ thư viện rồi thêm tab. Ví dụ giả sử bạn đã nạp `LIB` ở chế độ library-only.

```lua
local Window = LIB:CreateWindow({
    Title = "My Hub",
    Icon = "sparkles",
    Version = "v1.0.0",
    Size = UDim2.fromOffset(620, 440),
    ToggleKey = Enum.KeyCode.RightShift,
    Folder = "MyHub",
    FileSaveName = "settings.json",
    AutoSave = true,
})

local Main = Window:Tab({ Title = "Main", Icon = "house" })
Main:Button({ Title = "Xin chào", Callback = function()
    print("Xin chào từ xNgot")
end })
```

## Tùy chọn cửa sổ

| Tùy chọn | Ý nghĩa |
| --- | --- |
| `Title`, `Icon`, `Version` | Tên cửa sổ, tên icon, phiên bản; `Author` ưu tiên hơn `Version`. |
| `Size`, `ToggleKey` | Kích thước ban đầu và phím tắt. |
| `Folder`, `FileSaveName`, `AutoSave` | Nơi lưu cấu hình và chế độ tự lưu. |
| `SettingsUI` | Mặc định `true`; `false` bỏ Settings và Dynamic Island tích hợp. |
| `Loading` | Cấu hình loader; `false` tắt loader nếu không bật khóa key. |
| `KeySystem` | Cấu hình key; xem mục key system. |
| `AdminInfo` | Thông tin tác giả tùy chỉnh, hoặc `false` để tắt. |

## Điều khiển cửa sổ

```lua
Window:SelectTab("Main")
Window:Hide()
Window:Show()
Window:Toggle()
Window:SetToggleKey(Enum.KeyCode.RightShift)
-- Window:Destroy() -- đóng và dọn dẹp
```

Khi tạo cửa sổ xNgot mới, cửa sổ xNgot đang hoạt động sẽ được thay thế kể cả khi khác tên. Thư viện dọn cửa sổ, Island, màn hình key và kết nối liên quan; không chủ đích xóa giao diện khác của game.

Cửa sổ và bảng nổi chờ đến khi màn hình key hoàn tất. Nếu đóng màn hình key trước khi xác thực, cửa sổ sẽ được đóng thay vì tự mở khóa.

---

# Thành phần UI

Trên thiết bị cảm ứng, điều khiển giữ kích thước hiển thị như cũ và xử lý chạm để giảm nhấn lộn. Slider nhận chạm hoặc kéo ngang; vuốt dọc được xem là cuộn. Dropdown chọn một mục sẽ đóng sau khi chạm chọn, còn chọn nhiều mục vẫn mở. Màu của mục đã chọn là trạng thái lựa chọn, không phải hiệu ứng nhấn bị kẹt.

Thêm thành phần vào tab bằng `Tab:Button`, `Tab:Toggle`, `Tab:Slider`, `Tab:Input`, `Tab:Dropdown`, `Tab:Colorpicker`, `Tab:Section`, `Tab:Paragraph`, `Tab:Code`, `Tab:Discord` và `Tab:InfoNguyenNhat`.

## Nút và nội dung

```lua
Main:Section({ Title = "Cơ bản", Default = true })
Main:Paragraph({ Title = "Chào bạn", Desc = "Chọn một tính năng bên dưới." })
Main:Button({ Title = "Làm mới", Callback = function()
    print("Làm mới")
end })
local sample = Main:Code({ Title = "Ví dụ", Code = "print('hello')" })
sample:SetCode("print('updated')")
```

## Thành phần có trạng thái

```lua
local toggle = Main:Toggle({
    Title = "Bật", Default = false,
    Callback = function(on) print("Bật:", on) end,
})
local slider = Main:Slider({
    Title = "Tốc độ", Value = { Min = 1, Max = 100, Default = 25 }, Step = 1,
    Callback = function(value) print(value) end,
})
local input = Main:Input({ Title = "Tên", Placeholder = "Nhập tên" })
toggle:Set(true)
slider:Set(50)
input:Set("xNgot")
```

> Callback của toggle, slider, input, dropdown và bảng màu có thể chạy ngay lúc tạo với giá trị mặc định hoặc giá trị đã lưu, không chỉ khi người dùng bấm.

## Danh sách và bảng màu

```lua
local menu = Main:Dropdown({
    Title = "Chế độ", Values = { "Default", "Fast", "Quiet" }, Value = "Default",
    Callback = function(value) print(value) end,
})
menu:Refresh({ "Default", "Fast", "Quiet" })
menu:Select("Fast")

Main:Colorpicker({
    Title = "Màu nhấn", Default = Color3.fromRGB(10, 135, 213),
    Callback = function(color) print(color) end,
})
```

Đặt `Title` khác nhau trong cùng một tab vì tên được dùng làm khóa lưu cấu hình. `Multi = true` bật chọn nhiều, `AllowNone = true` cho phép không chọn. Nhiều thành phần có `:SetTitle`, `:SetDesc`, `:Lock`, `:Unlock` và `:Destroy`; hãy kiểm tra từng thành phần trước khi dùng.

---

# Thông báo và hộp thoại

Dùng `LIB:Notify` để báo trạng thái, hoặc `Window:Dialog` khi cần người dùng lựa chọn.

```lua
LIB:Notify({
    Title = "Đã lưu", Content = "Cài đặt của bạn đã sẵn sàng.",
    Kind = "success", Icon = "circle-check", Duration = 4,
})

Window:Dialog({
    Title = "Đặt lại cài đặt?", Content = "Cấu hình đã lưu sẽ bị xóa.",
    Icon = "triangle-alert",
    Buttons = {
        { Title = "Hủy" },
        { Title = "Đặt lại", Callback = function() Window:DeleteConfig() end },
    },
})
```

`Kind` hỗ trợ `info`, `success`, `warn`, `error` cho thông báo trên island. `Native = true` yêu cầu thông báo thường thay vì chuyển sang island đang bật. Thông báo native có thể đóng bằng `:Close()` trên object trả về.

---

# Key system

Bản cập nhật nhúng giao diện Ophyn và adapter xác thực. Bật bằng `KeySystem` trong `LIB:CreateWindow`, hoặc dùng `getgenv().xNgotLoaderConfig.keySystem` cho demo. Màu, font, góc bo và icon mặc định lấy theo cài đặt UI xNgot đã lưu.

## Các chế độ

| Chế độ | Cấu hình |
| --- | --- |
| Local | `Key = "..."` hoặc `Keys = { "...", "..." }` |
| PandaAuth | `API = { { Type = "panda", ServiceId = "..." } }` |
| Jnkie | `API = { { Type = "jnkie", Service = "...", Identifier = "..." } }` |
| Platoboost | `API = { { Type = "platoboost", ServiceId = 123, Secret = "..." } }` |
| Custom | `Key = function(key) ... end` hoặc `API` với `Type = "custom"` |
| Keyless | `Keyless = { enabled = true }` |

Khi cấu hình nhiều validator, key chỉ cần hợp lệ với **một trong số đó**. Đừng để key local demo cùng provider production nếu bạn không chủ đích tạo đường vào dự phòng. Nếu không cấu hình key/provider, hệ thống không tự chấp nhận key mẫu.

## Tùy chọn chính

Hỗ trợ `Enabled`, `Key` / `Keys`, `CaseSensitive`, `SaveKey`, `KeyFile`, `URL` / `GetKeyUrl`, `API`, `GetMethods`, `Keyless` và `Ophyn`. Key đã lưu vẫn được kiểm tra lại trước khi vào. `Style = "Legacy"` chọn giao diện key xNgot cũ, chỉ hỗ trợ local key.

> Adapter và UI đã tích hợp, nhưng xác thực thật với provider chưa được kiểm tra do chưa có thông tin tài khoản. PandaAuth và Jnkie tải rồi chạy SDK tương ứng trong lúc sử dụng.

---

# Key local và keyless

## Key local cơ bản

```lua
local Window = LIB:CreateWindow({
    Title = "My Hub", Icon = "sparkles",
    KeySystem = {
        Enabled = true,
        Keys = { "DEMO-KEY", "VIP-KEY" },
        CaseSensitive = false,
        SaveKey = true,
        KeyFile = "xNgotLibrary/Keys/key.txt",
        GetKeyUrl = "https://example.com/get-key",
    },
})
```

Key local mặc định không phân biệt hoa/thường. Key gửi đến provider được giữ nguyên. Dùng `SaveKey = false` khi muốn test màn hình nhập key mỗi lần.

```lua
print(Window.KeyUnlocked)
Window:ForgetSavedKey()
```

Demo đi kèm mặc định dùng key `XNGOT-2026`. Key đã lưu có thể được kiểm tra tự động; dùng `SaveKey = false` để test nhập tay.

## Chế độ keyless

```lua
KeySystem = {
    Enabled = true,
    Keyless = { enabled = true, showcard = true, autoconfirm = false },
}
```

`autoconfirm = true` cho tự tiếp tục. Keyless chủ động bỏ xác thực, không phải chế độ kiểm soát truy cập.

---

# Cấu hình provider

Đây là các bảng `KeySystem`. Thay giá trị mẫu bằng thông tin chính xác trên dashboard của provider. Không thêm key demo local nếu bạn không muốn key đó cũng được chấp nhận.

## PandaAuth

```lua
KeySystem = {
    Enabled = true, SaveKey = true,
    API = { { Type = "panda", ServiceId = "SERVICE_ID_CUA_BAN" } },
}
```

## Jnkie

```lua
KeySystem = {
    Enabled = true, SaveKey = true,
    API = { { Type = "jnkie", Service = "TEN_SERVICE",
              Identifier = "USER_IDENTIFIER", Provider = "Mixed" } },
}
```

## Platoboost

```lua
KeySystem = {
    Enabled = true, SaveKey = true,
    API = { { Type = "platoboost", ServiceId = 12345, Secret = "SECRET_CUA_BAN" } },
}
```

> Script phía client không phải nơi an toàn để giữ secret. Kết nối, SDK và request tùy thuộc provider và executor. Hãy test cả key hợp lệ lẫn key sai với dịch vụ thật trước khi phát hành.

---

# Custom và giao diện

Adapter tùy chỉnh nhận key và context chứa các trường trong entry, cùng `ctx.Request` nếu executor hỗ trợ.

```lua
KeySystem = {
    Enabled = true,
    API = {{
        Type = "custom", ServiceId = "my-service",
        CheckKey = function(key, ctx)
            if key == "demo" then return true end
            return false, "Key không hợp lệ"
        end,
        GetKeyLink = function(ctx)
            return "https://example.com/get-key"
        end,
    }},
}
```

Ví dụ trên cố ý kiểm tra local, không phải xác thực server an toàn. Bạn cũng có thể dùng `Key = function(key) return true_or_false, reason end`.

## Tùy chỉnh màn hình

```lua
KeySystem = {
    Enabled = true, Keys = { "DEMO" },
    Ophyn = {
        Title = "My Hub", Description = "Key System", Intro = true,
        discord_link = "discord.gg/example", Discord = true,
        Informations = true,
    },
}
```

`Ophyn` chuyển các tùy chọn đến giao diện tích hợp. Đặt `SyncTheme = false` và chọn `Theme` để dùng bảng màu Ophyn riêng; `SyncFont = false` dùng font gốc của Ophyn. `ChangeTheme = true` chủ động cho phép đổi khỏi bảng màu đồng bộ. `Logo` tùy chỉnh thay cho icon cửa sổ.

---

# Dynamic Island

Bảng nổi tích hợp xuất hiện khi bật `SettingsUI`. Hãy kiểm tra `nil` khi Settings bị tắt hoặc island không khởi tạo được.

```lua
local Island = Window:GetDynamicIsland()
if Island then
    Island:Notify("Xin chào", "Hub đã sẵn sàng", "success", 4)
    Island:GameplayActivity("Đang chạy", "Đang xử lý", 5, "info")
    Island:Expand("Music")
end
```

## Hẹn giờ và hiển thị

```lua
if Island then
    Island:Timer(300)
    Island:ExtendTimer(60)
    Island:StopTimer()
    Island:WatchToggle()
    Island:Set("Fps", true)
    Island:Set("Ping", true)
    Island:Enable(true)
end
```

Các hàm khác gồm `Collapse`, `WatchLap`, `WatchReset`, `Theme`, `Accent` và `State`. Dashboard trong Settings hiển thị lịch sử FPS và ping khác màu, thao tác server và Job ID. Island chờ màn hình key và quá trình dựng menu hoàn tất mới hiện.

Giao diện hiện tại chỉ có tiếng Anh; `SetLanguage` hiện không chuyển giao diện sang tiếng Việt.

---

# Nhạc và cấu hình

Engine nhạc tích hợp hỗ trợ tìm kiếm và quản lý bài đã tải qua island. Khả năng sử dụng phụ thuộc kết nối, API executor và dịch vụ bên ngoài.

```lua
local Island = Window:GetDynamicIsland()
if Island then
    Island:MusicSearch("lofi chill")
    Island:Expand("Music")
    Island:MusicVolume(65)
end
```

Tìm kiếm chạy bất đồng bộ; khi có kết quả hãy chọn bài trong player hoặc dùng `MusicSelectValue`. `PlayMusic()` chỉ đảo trạng thái bài hiện tại, không chờ kết quả tìm.

## Preset

```lua
_G.xNgotMusicConfig:Preset("lowdata")
_G.xNgotMusicConfig:Set("topN", 8)
print(_G.xNgotMusicConfig:Get("topN"))
```

Chọn **Music region** và **Music platform** trong cài đặt Island. Auto ưu tiên quốc gia do Roblox cung cấp, sau đó dùng locale; chọn Global để bỏ ưu tiên vùng. Có Việt Nam, Mỹ, Hàn Quốc và Nhật Bản. Đây là thêm từ khóa khu vực khi tìm, không phải bộ lọc xác minh ngôn ngữ hay quốc tịch. Giao diện hỗ trợ YouTube, SoundCloud, Audius; kết quả và tải nhạc phụ thuộc dịch vụ bên ngoài.

Khi bật Auto play, trình phát chọn ngẫu nhiên bài phù hợp chưa phát gần đây. Với bài từ tìm kiếm/trợ lý, ưu tiên bài khớp câu tìm hiện tại. Khi hết lựa chọn mới, máy có thể tìm online bài liên quan rồi quay lại bài phù hợp đã nghe nếu không tìm được; nếu không có bài phù hợp thì dừng. Repeat One được ưu tiên; nút Next/Previous thủ công vẫn hoạt động. Việc đối chiếu dựa trên chữ trong tên/nghệ sĩ/thể loại, có thể bỏ sót bài đúng hoặc chọn nhầm—hãy xem kết quả và viết rõ câu tìm khi cần. Truy vấn gốc được thử trước, từ khóa vùng chỉ là biến thể bổ sung.

Khi bật **Preload next track** cùng Auto, lúc phát đến 50% trình phát có thể tải trước một bài phù hợp chưa nghe trong danh sách. Nếu chưa xong hoặc tải lỗi, trình phát xử lý bình thường; không đảm bảo chuyển bài không trễ. Tìm online và tải trước dùng mạng/bộ nhớ. Kết quả kém liên quan bị lọc thay vì tự tải; cache mới có mã nguồn và ID để tránh trùng, nhưng provider vẫn có thể trả nhầm âm thanh. File cũ còn trong danh sách đã tải. Tự nhận vùng không dùng dịch vụ tra IP bên thứ ba.

```lua
_G.xNgotMusicConfig:Set("region", "VN") -- auto, global, VN, US, KR, JP
_G.xNgotMusicConfig:Set("sources", {"youtube"}) -- hoặc soundcloud, audius
_G.xNgotMusicConfig:Set("prefetchNext", true)
```

Các preset: `fast`, `quality`, `lowdata`, `vietnamese`. Các hàm khác gồm `MusicCatalog`, `MusicRows`, `MusicSelect`, `MusicSelectValue`, `NextMusic`, `MusicSpeed`, `MusicFiles`, `MusicPlayFile`, `MusicDeleteFile` và `MusicClearDownloaded`.

## Kiểm tra hỗ trợ

```lua
local report = _G.xNgotMusicDoctor()
for _, check in ipairs(report.checks) do
    print(check.status, check.name, check.detail)
end
```

Doctor chỉ là gợi ý chẩn đoán, không chứng minh tính năng hoạt động: global và mạng của mỗi executor có thể khác nhau. Hãy xem từng mục và test phát nhạc trực tiếp.

---

# Giao diện và lưu trữ

Người dùng có thể đổi giao diện trong Settings UI, hoặc script điều khiển theme và profile.

```lua
Window:SetUISettings({
    AccentColor = Color3.fromRGB(10, 135, 213),
    CornerRadius = 12,
}, true)
Window:ApplyUIPreset("Midnight", true)
Window:SaveUIProfile("My theme")
```

Dùng `GetUISettings`, `GetUIPresets`, `UseOriginalUI`, `ExportUISettings`, `ImportUISettings`, `LoadUIProfile` và `DeleteUIProfile` để quản lý giao diện. Màn hình key đọc theme xNgot đã lưu khi khởi động; theme Ophyn riêng có thể ghi đè chế độ đồng bộ.

## File cấu hình

```lua
print(Window:GetConfigPath())
Window:SaveConfig()
-- Window:DeleteConfig() -- xóa cấu hình UI/thành phần đã lưu
```

Cấu hình được nhóm theo `Title` của tab và thành phần. Đổi tên sẽ đổi khóa lưu tương ứng. Việc lưu phụ thuộc API file của executor; file key là file riêng với cấu hình cửa sổ.

---

# Xử lý sự cố

## `failed to read file`

Kiểm tra file nằm trong **workspace của executor**, không chỉ trong Downloads. Tên trong `readfile("main.lua")` phải trùng chính xác, kể cả đuôi file.

## `Out of local registers ... limit 200`

Đây là lỗi biên dịch nên bảng debug bên trong script chưa thể chạy. Dùng bản cập nhật đã được kiểm tra bằng Luau cũ với giới hạn 200 registers. Nếu vẫn lỗi, chụp chính xác thông báo và tên file.

## Không thấy menu hoặc màn hình key

- Kiểm tra `xNgotLibraryOnly`: nếu là `true`, bạn phải tự gọi `LIB:CreateWindow(...)`.
- Key đã lưu có thể được kiểm tra tự động. Đặt `SaveKey = false` để test nhập tay.
- Màn hình key có thể chờ asset; bản tích hợp có timeout preload.
- Đóng màn hình key trước khi xác thực sẽ đóng cửa sổ.
- Kiểm tra executor có tạo UI và tải asset Roblox được không; gửi log nếu có.

## Provider từ chối key

Kiểm tra service ID, trạng thái provider, mạng và HTTP của executor. Test cả key đúng và key sai. Tài liệu này chưa xác minh xác thực với tài khoản của bạn.

## Nhạc không phát

Chạy `_G.xNgotMusicDoctor()` và xem `checks`; kiểm tra thêm file, custom asset và luồng phát thực tế. Một dòng cảnh báo chưa đủ để kết luận nguyên nhân.

---

# Tham khảo API

Danh mục nhanh các điểm gọi thường dùng trong bản này.

## Library và cửa sổ

| API | Công dụng |
| --- | --- |
| `LIB:CreateWindow(options)` | Tạo cửa sổ. |
| `LIB:Notify(options)` | Hiện thông báo. |
| `Window:Tab(options)` | Thêm tab. |
| `Window:Show()`, `Hide()`, `Toggle()` | Điều khiển hiển thị. |
| `Window:SelectTab(name)` | Chọn tab. |
| `Window:Dialog(options)` | Hiện hộp thoại. |
| `Window:GetDynamicIsland()` | Trả về API island hoặc `nil`. |
| `Window:SaveConfig()`, `DeleteConfig()`, `GetConfigPath()` | Quản lý cấu hình. |
| `Window:ForgetSavedKey()` | Xóa key đã lưu nếu executor hỗ trợ. |
| `Window:Destroy()` | Đóng cửa sổ. |

## Thành phần

Tạo `Section`, `Button`, `Toggle`, `Slider`, `Input`, `Dropdown`, `Colorpicker`, `Paragraph`, `Code`, `Discord` và `InfoNguyenNhat` trên tab. Ví dụ tên icon: `house`, `sparkles`, `music-2`, `key-round`, `settings`, `triangle-alert`.

## Global quan trọng

| Global | Công dụng |
| --- | --- |
| `getgenv().xNgotLibraryOnly` | Bỏ tự mở demo. |
| `getgenv().xNgotLoaderConfig` | Ghi đè cài đặt loader demo trước khi nạp. |
| `_G.xNgotMusicConfig` | API cấu hình nhạc. |
| `_G.xNgotMusicDoctor()` | Trả về chẩn đoán nhạc. |
| `_G.xNgotStudio` | Trạng thái khởi động demo, nếu đã chạy. |

## Credit

xNgot Library: Nguyễn Minh Nhật (xNgot Zume). Giao diện và engine key: [Ophyn UI](https://github.com/snowdevlol/OphynUI). UI cửa sổ phát triển từ [Wind UI](https://github.com/Footagesus/WindUI).

---

# Ví dụ hub hoàn chỉnh

Đây là **một script hoàn chỉnh**, không phải các đoạn rời. Trước tiên đặt `main.lua` **mới** vào workspace của executor. Ví dụ không mở demo, không phụ thuộc GitHub và chưa bật key; xem mục Key system nếu cần khóa.

```lua
getgenv().xNgotLibraryOnly = true
local chunk, err = loadstring(readfile("main.lua"))
assert(chunk, err)
local LIB = chunk()

local Window = LIB:CreateWindow({
    Title = "Hub của tôi", Author = "Ví dụ", Icon = "sparkles",
    Size = UDim2.fromOffset(580, 420),
    Folder = "MyHub", FileSaveName = "settings.json",
    AutoSave = true, SettingsUI = true, Loading = false,
})
local Main = Window:Tab({ Title = "Main", Icon = "house" })
Main:Section({ Title = "Điều khiển", Default = true })
local status = Main:Paragraph({ Title = "Trạng thái", Desc = "Sẵn sàng" })
local enabled = Main:Toggle({
    Title = "Bật tính năng", Default = false,
    Callback = function(value) status:SetDesc(value and "Đã bật" or "Đã tắt") end,
})
Main:Slider({
    Title = "Giá trị", Value = { Min = 0, Max = 100, Default = 25 }, Step = 5,
    Callback = function(value) print("Giá trị:", value) end,
})
Main:Input({ Title = "Tên", Placeholder = "Nhập nội dung",
    Callback = function(text) print("Tên:", text) end,
})
Main:Dropdown({ Title = "Chế độ", Values = {"Normal", "Fast"}, Value = "Normal",
    Callback = function(value) print("Chế độ:", value) end,
})
Main:Button({ Title = "Thử thông báo", Callback = function()
    LIB:Notify({ Title = "xNgot", Content = "Xin chào!", Kind = "success", Duration = 3 })
end })
Window:SelectTab("Main")
```

## Khi chạy sẽ xảy ra gì?

1. Chế độ library-only trả về `LIB`, không chạy demo đi kèm.
2. `CreateWindow` thay cửa sổ xNgot đang hoạt động; không chủ đích xóa UI khác của game.
3. `Window:Tab` trả về tab; `Section` trở thành nơi chứa các control tạo sau đó trên tab.
4. Callback của control có trạng thái có thể chạy ngay với mặc định hoặc dữ liệu đã lưu. Tạo các đối tượng được callback dùng, như `status`, **trước** control.
5. `SettingsUI = true` tạo tab Settings và Island nếu khởi tạo thành công. `Loading = false` tắt loader khi không bật key gate.

> Ví dụ chưa được kiểm chứng trên mọi game/executor Roblox. API của executor có thể khác nhau.

---

# Chi tiết từng control

Các hàm tạo bên dưới được gọi trên `Tab`. Đặt `Title` **khác nhau trong cùng tab**, vì control có trạng thái dùng tên ban đầu làm khóa lưu cấu hình. `SetTitle` sau đó không tự chuyển khóa cũ sang tên mới.

| Thành phần | Tùy chọn | Callback / cách hoạt động |
| --- | --- | --- |
| `Button` | `Title`, `Desc`, `Locked`, `Callback` | Chạy khi nhấn. Bản này không đọc `Icon` cho Button. |
| `Toggle` | `Title`, `Desc`, `Default` hoặc `Value`, `Icon`, `Locked`, `Callback` | Boolean; callback chạy lúc tạo và khi `:Set`. Tránh đặt `Default` và `Value` trái nhau. |
| `Slider` | `Title`, `Desc`, `Value = {Min, Max, Default}`, `Step`, `Locked`, `Callback` | Số; giới hạn theo khoảng và bước; callback chạy lúc tạo và thay đổi. `:Set` trả giá trị hoặc `nil` nếu ngoài khoảng. |
| `Input` | `Title`, `Desc`, `Placeholder`, `Default` / `Value`, `ClearTextOnFocus`, `MultiLine`, `NoSave`, `Locked`, `Callback` | Chuỗi; callback chạy lúc tạo, mất focus và `:Set`. |
| `Dropdown` | `Title`, `Desc`, `Values`, `Value` / `Default`, `Multi`, `AllowNone`, `Locked`, `Callback` | Chọn một trả chuỗi; chọn nhiều trả bảng; callback có thể chạy khi tạo. |
| `Colorpicker` | `Title`, `Desc`, `Default` / `Value`, `Locked`, `Callback` | Callback nhận `Color3`; `:Get()` lấy màu hiện tại; callback chạy lúc tạo. |
| `Section` | `Title`, `Default`, `TextXAlignment` | Nhóm thu gọn; trở thành container cho control tạo tiếp trên tab đó. |
| `Paragraph` | `Title`, `Desc`, `RichText` | Nội dung chữ, không tương tác. |
| `Code` | `Title`, `Code` | Hiển thị code, không thực thi. |
| `Discord` | `Name`, `Desc`, `Avatar`, `InviteLink`, `InviteCode` | Thẻ mời; copy/tham gia tùy executor. |
| `InfoNguyenNhat` | `Name`, `Bio`, `Avatar`, `Badges` | Thẻ thông tin. |

## Các hàm của object trả về

| Object | Hàm |
| --- | --- |
| Button | `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Toggle | `Set`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Slider | `Set`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Input | `Set`, `Get`, `SetTitle`, `SetDesc`, `SetPlaceholder`, `Lock`, `Unlock`, `Destroy` |
| Dropdown | `Select`, `Refresh`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Colorpicker | `Set`, `Get`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Section | `SetTitle`, `SetOpen`, `Toggle`, `Destroy` |
| Paragraph | `SetTitle`, `SetDesc`, `Destroy` |
| Code | `SetTitle`, `SetCode`, `Destroy` |
| Discord | `SetInvite`, `Destroy` |
| InfoNguyenNhat | `SetName`, `SetBio`, `SetAvatar`, `Destroy` |

## Chọn một hoặc nhiều

```lua
local picker = Main:Dropdown({
    Title = "Mục tiêu", Values = {"A", "B", "C"},
    Multi = true, AllowNone = true, Value = {"A"},
    Callback = function(values)
        for _, value in ipairs(values) do print(value) end
    end,
})
picker:Select({"B"}) -- đảo trạng thái mục B khi chọn nhiều
picker:Refresh({"A", "B", "C", "D"}) -- dựng lại và reset lựa chọn
```

`Refresh` reset lựa chọn; gọi `Select` sau đó nếu cần. `AllowNone` khác nhau giữa chọn một và nhiều; khi chọn một, callback cho None nhận chuỗi rỗng. Chỉ chọn giá trị có trong danh sách. Màu được giữ ở mục đã chọn thể hiện trạng thái lựa chọn, không phải hiệu ứng nhấn bị kẹt.

## Nhóm và nội dung

```lua
local section = Main:Section({Title = "Tùy chọn", Default = true})
Main:Paragraph({Title = "Gợi ý", Desc = "<b>Chữ đậm</b>", RichText = true})
section:SetOpen(false)
section:SetOpen(true)
local card = Main:InfoNguyenNhat({Name = "Developer", Bio = "Xin chào", Badges = {"Dev"}})
card:SetBio("Đã cập nhật")
```

`Section` không phải tab mới; tiếp tục gọi `Main:Button(...)` v.v. Muốn bắt đầu nhóm khác, tạo section khác trên cùng tab.

---

# API cửa sổ và lưu trữ

## Vòng đời và điều hướng

| Hàm | Công dụng |
| --- | --- |
| `Window:Tab({Title, Icon})` | Tạo tab. |
| `SelectTab(nameOrIndex)` | Chọn theo tên hoặc số thứ tự tab người dùng; trả boolean. |
| `Show()`, `Hide()`, `Toggle(state)` | Hiện/ẩn; key gate có thể chặn mở trước khi xác thực xong. |
| `SetToggleKey(key)` | Nhận `Enum.KeyCode` hoặc tên phím, trả phím hiện tại. |
| `SetToggleButtonPlatform("Both" hoặc "Mobile")` | Chọn nền tảng cho nút nổi; giá trị khác được đưa về Both. |
| `GetToggleButtonPlatform()` | Lấy cài đặt hiện tại. |
| `EditOpenButton(options)` | Chỉnh nút nổi, trả về GUI object. |
| `Divider()`, `OpenUISettings()` | Thêm đường phân cách sidebar / mở tab Settings. |
| `Dialog(options)` | Mở hộp thoại; object trả về có `:Close()`. |
| `Destroy()` | Dọn cửa sổ, gọi lại an toàn. Tạo cửa sổ xNgot mới sẽ thay cửa sổ cũ. |

```lua
Window:SetToggleKey(Enum.KeyCode.RightShift)
Window:SetToggleButtonPlatform("Mobile")
Window:EditOpenButton({Title = "Mở", Icon = "house", ShowText = true})
Window:Hide()
```

`EditOpenButton` còn nhận `OpenIcon`, `Size`, `Position`, `BackgroundColor3`, `TextColor3`, `IconColor3`, `OpenIconColor3`, `CornerRadius`.

## Lưu cấu hình

| Hàm | Công dụng |
| --- | --- |
| `GetConfigPath()` | Trả đường dẫn thực tế theo `Folder` và `FileSaveName`. |
| `SaveConfig()` | Chủ động ghi, gồm UI settings; trả kết quả thành công. |
| `DeleteConfig()` | Xóa file nếu executor hỗ trợ; trả kết quả/lỗi. Không tự reset control đang nằm trong bộ nhớ. |
| `ForgetSavedKey()` | Có khi key gate thiết lập hàm; xóa key đã lưu nếu được hỗ trợ. |

`AutoSave = false` tắt ghi tự động; `SaveConfig()` vẫn chủ động thử ghi. Dữ liệu lưu local, không mã hóa, phụ thuộc API file của executor. Mặc định config ở `xNgotLibrary/Config/<FileSaveName>`; file config cũ hợp lệ ở gốc được sao chép khi cần, không xóa bản cũ. `Folder` do script tự chỉ định vẫn được giữ, có thể nằm ngoài thư mục mẹ. Mặc định key, AI và nhạc nằm trong `xNgotLibrary/Keys`, `xNgotLibrary/AI` và `xNgotLibrary/Music` (ảnh ở `Music/Covers`); đường dẫn tùy chỉnh hoặc dịch vụ ngoài có thể khác. File không được bảo vệ E2E: script khác hoặc người có quyền workspace executor có thể đọc/sửa. `DeleteConfig` không xóa nhạc đã tải hay key được lưu riêng.

## API giao diện

`SetUISettings(table, save)` khởi đầu từ mặc định và áp các trường đã đưa vào; đây **không phải** thao tác vá từng trường lên toàn bộ cài đặt trước đó. Khi muốn giữ, hãy truyền bảng đầy đủ. `save = false` bỏ qua yêu cầu lưu tương ứng.

```lua
local settings = Window:GetUISettings()
settings.AccentColor = Color3.fromRGB(0, 170, 255)
settings.Overrides = nil -- tự xác định các trường cần override
Window:SetUISettings(settings, true)
Window:SetUISize(580, 420, true)
print(Window:ExportUISettings())
```

Các helper khác thuộc Settings gồm `GetUILanguage`, `SetUILanguage` (hiện chỉ tiếng Anh) và `RefreshAdminAvatar` (khi thẻ admin được tạo). Các hàm khác: `GetUIOverrides`, `ClearUIOverride(key, save)`, `GetUIPresets`, `ApplyUIPreset(name, save)`, `UseOriginalUI(save)`, `GetUISize`, `ResetUISize(save)`, `SaveUISettings`, `ImportUISettings(json, save)`, `ResetUISettings(save)`, `SaveUIProfile(name)`, `LoadUIProfile(name, save)`, `GetUIProfileNames`, `DeleteUIProfile(name)`. Profile/export có version; profile cũ có thể bị từ chối. Hãy dùng `GetUIPresets()` để lấy tên thật.

`SetUISize` giới hạn rộng 420–1000, cao 300–800. UI bản này hiện chỉ tiếng Anh; hàm thuộc phần Settings như `GetUILanguage` có thể không tồn tại khi `SettingsUI = false`.

---

# API Dynamic Island

Dùng `local island = Window:GetDynamicIsland()` và kiểm tra `if island then ... end`. Bridge được tạo khi bật `SettingsUI` và khởi tạo thành công. Island chỉ hiện sau khi menu và loader/key gate hoàn tất; `Enable(true)` không vượt qua key gate.

## Hiển thị và hoạt động

| Hàm | Cách hoạt động |
| --- | --- |
| `Notify(title, message, kind, duration)` | Thông báo; trả `false` khi island tắt. |
| `GameplayActivity(title, message, duration, kind)` | Hoạt động tạm thời, thời lượng giới hạn 3–30 giây. |
| `Enable(boolean)` | Bật hoặc ẩn island. |
| `Expand(page)`, `Collapse()` | Mở trang hoặc thu gọn. Trang thường dùng: `Home`, `Music`, `Cross`. |
| `Set("Fps" / "Ping" / "Clock", boolean)` | Bật/tắt hoạt động. Một số key đã có trong Settings cũng có thể chỉnh bằng tên. |
| `Theme(index)`, `Accent(index)` | Chọn bảng màu/màu nhấn bằng chỉ số, có giới hạn. |
| `State()` | Trả bảng `Cross`, `Playing`, `MusicIndex`, `FPS`, `Ping`, `Timer`, `Island`. |
| `Destroy()` | Dọn island; dùng `Window:Destroy()` để dọn toàn bộ cửa sổ. |

`Window:NotifyIsland(title, message, kind, duration)` và `Window:IslandActivity(title, message, duration, kind)` là bridge trả false nếu island không sẵn sàng. Chú ý thứ tự **kind và duration** khác nhau giữa hai hàm.

## Hẹn giờ và đồng hồ bấm giờ

```lua
local island = Window:GetDynamicIsland()
if island then
    island:Timer(120)       -- 1–86400 giây
    island:ExtendTimer(30)
    island:StopTimer()
    island:WatchToggle()    -- chạy/tạm dừng
    island:WatchLap()
    island:WatchReset()
end
```

## Trợ lý Cross

Vào **Settings → Open Dynamic Island Settings → Cross AI Assistant**, bật **Enable Cross AI**, nhập lệnh như `next song` hoặc `hẹn giờ 60 giây` rồi nhấn **Send to Cross AI**. Câu trả lời hiện trong mục này. **Open Cross AI on Island** mở giao diện trên đảo (cần bật island trước); **Clear Cross AI chat** xóa hội thoại trong phiên. Ô nhập không ghi vào config cửa sổ, nhưng lệnh tìm nhạc có thể gửi đến dịch vụ tìm kiếm bên thứ ba; không nhập thông tin bí mật. Đây là trợ lý local theo quy tắc, không phải chatbot AI online tổng quát.

`AiState()` trả bảng `Enabled`, `Thinking`, `Reply`, `Version`, `Pending` (câu trả lời mới nhất, không phải toàn bộ lịch sử). `AiAsk` có thể yield khi xử lý nhạc; dùng task khi cần.

`AiEnable(boolean)`, `AiOpen()`, `AiAsk(text)`, `AiClear()` và `AiPermission(name, boolean)` điều khiển trợ lý local. Có thể cấu hình quyền `Ui`, `Key` và `Body`. `Body` mặc định bật cho các lệnh di chuyển nhân vật local sau xác nhận; `AiPermission("Body", false)` dừng ngay các lệnh đó. `Free` vẫn bị khóa tắt. `MusicAiLearn(title, good)` ghi nhận phản hồi nếu engine hỗ trợ; `DemoDownload()` chỉ mô phỏng tiến trình, không tải file thật. `MusicAiOnline(true)` không bật AI online ở bản này; `MusicAiOnlineState()` báo removed/local. Không nên hiểu tính năng này là gọi một AI online.

`SetLanguage` / `Set("Language", ...)` hiện ép về tiếng Anh. Nút đổi ngôn ngữ tài liệu là độc lập với ngôn ngữ UI thư viện.

---

# API và cấu hình nhạc

Tìm/tải nhạc phụ thuộc dịch vụ bên thứ ba, kết nối và executor. Roblox cũng có thể hạn chế phát âm thanh. Luau compiler pass không đảm bảo provider hay Delta chạy được.

## Tìm và phát

```lua
local island = Window:GetDynamicIsland()
if island then
    local disconnect = island:OnMusicCatalogChanged(function()
        local rows, state = island:MusicRows()
        print("Trạng thái:", state, "số bài:", #rows)
    end)
    island:MusicSearch("nhac viet chill")
    -- Tìm bất đồng bộ; gọi disconnect() khi không cần theo dõi nữa.
end
```

`MusicSearch` trả `true` không đảm bảo việc tìm đã bắt đầu (ví dụ đang bận) hoặc đã có kết quả. Dùng `MusicSearchState()` hoặc theo dõi thay đổi catalog. Khi có kết quả, `MusicRows()` trả `rows, state`; `MusicCatalog()` trả `catalog, state, supported`. `MusicSelectValue(value, play)` chọn theo Value/tên và trả boolean. `MusicSelect(index, play)` chọn theo index; không gọi khi danh sách rỗng. `MusicPlayTrack(id, url, source)` thêm/chọn bài ngoài và trả boolean, không chứng minh phát thành công. `MusicDownloadOne` có thể chờ, trả asset string hoặc `false`.

| Điều khiển | Ý nghĩa |
| --- | --- |
| `PlayMusic()` | Đảo phát/tạm dừng, không phải luôn luôn phát. |
| `NextMusic(1)` / `NextMusic(-1)` | Bài tiếp / trước. |
| `MusicVolume(n)` | Âm lượng 0–100. |
| `MusicSpeed(n)` | Tốc độ thực tế 0.7–1.4; player có giới hạn riêng. |
| `MusicMode(name, boolean)` | `Auto`, `Shuffle`, `RepeatOne`, `ShowIsland`. |
| `OnMusicChanged(fn)` | Đăng ký theo dõi; hàm trả về dùng để hủy theo dõi. |
| `MusicQueue(prompt)`, `MusicPreset(name)`, `MusicConfig()` | Helper do tích hợp Settings/Island gắn vào khi có. |

## File đã tải

`MusicFiles(includeSizes)` trả `files, stats`; `MusicStorage()` trả stats. `MusicLoadDownloaded()` thay catalog hiện tại bằng file local và trả số lượng. `MusicPlayFile(path)` cho biết có chọn được bài hay không. `MusicDeleteFile(path)` và `MusicClearDownloaded()` xóa file local; hàm sau trả số thành công và thất bại. Hãy xác nhận trước khi xóa.

```lua
if island then
    local files, stats = island:MusicFiles(true)
    print("Số file:", #files, "dung lượng:", stats.TotalText)
    if files[1] then island:MusicPlayFile(files[1].Path) end
end
```

## Cấu hình

Đặt trước khi load bằng `getgenv().xNgotMusic = {...}` hoặc lúc chạy qua `_G.xNgotMusicConfig:Set(key, value)`. API có `Get(key)`, `Get()`, `Schema()`, `Apply()`, `OnChange(fn)`, `Preset(name)`, `Presets()`; `OnChange` trả hàm hủy theo dõi. Preset: `fast`, `quality`, `lowdata`, `vietnamese`.

| Key | Mặc định | Phạm vi / ghi chú |
| --- | --- | --- |
| `topN` | 12 | 1–40 kết quả |
| `sources` | youtube, soundcloud, audius | Bảng ID nguồn; UI cho chọn All hoặc một trong ba. Nguồn khác phụ thuộc dịch vụ. |
| `region` | `auto` | `auto`, `global`, `VN`, `US`, `KR`, `JP`; ưu tiên qua từ khóa, không xác minh ngôn ngữ. |
| `prefetchNext` | true | Chuẩn bị bài tiếp trong danh sách tại 50% khi bật Auto, tắt RepeatOne và có hơn một bài. |
| `searchTimeout` | 12 | 2–60 giây |
| `preferShort` | 600 | 0–7200 giây; 0 tắt ưu tiên |
| `folder` | `xNgotLibrary/Music` | Thư mục cache local |
| `raceTracks` | 2 | 1–4 bài thử song song trong resolve |
| `downloadTimeout` | 200 | 20–600 giây |
| `retries` | 2 | 0–5 |
| `renameFiles`, `aiLearn`, `coverArt` | true | Boolean |
| `compactRows`, `debug` | false | Boolean |
| `showSource`, `notifyOnSearch` | true | Boolean |
| `aiBrain` | `local` | Bản này không bật mô hình online. |

Auto ưu tiên quốc gia Roblox nếu có, dự phòng locale; vùng chưa hỗ trợ/không rõ chuyển về global. Preload dùng mạng và bộ nhớ, không đảm bảo chuyển bài không trễ. Nếu preload lỗi sẽ tải theo luồng bình thường. Một số key có trong schema nhưng hiệu lực thực tế tùy source hiện tại; hãy kiểm tra trong môi trường của bạn.

Để chẩn đoán, gọi `_G.xNgotMusicDoctor()` khi có và xem từng check. Cảnh báo không tự chứng minh một nguyên nhân cụ thể. Test riêng tìm kiếm, tải, API file, `getcustomasset`/`getsynasset` và phát âm thanh.

---

# Loader và vòng đời key

## Cấu hình khởi động

```lua
local Window = LIB:CreateWindow({
    Title = "My Hub", Icon = "sparkles",
    Loading = {Title = "My Hub", Text = "Đang mở", Steps = {"Chuẩn bị", "Sắp xong"}, Duration = 2},
    KeySystem = {Enabled = true, Keys = {"DEMO-KEY"}, SaveKey = false},
})
```

Khi `KeySystem.Enabled = true` và `Style` không phải `Legacy`, luồng Ophyn tích hợp xử lý key gate. Loader không dùng Ophyn/legacy đọc `Loading.Title`, `Text`, `Steps`, `Duration`; thời gian hiện thực tế có thể lâu hơn thời lượng cấu hình. `Loading = false` tắt loader không-key, không tắt key gate đã bật. Hãy xác định đúng luồng đang test trước khi chờ một animation cụ thể.

## Thứ tự và key lưu

Cửa sổ được dựng trong lúc khởi động, nhưng menu và Island chờ gate vượt qua. Key đã lưu được kiểm tra lại. Nếu đóng UI key mà chưa chấp nhận, cửa sổ sẽ bị hủy. Dùng `SaveKey = false` hoặc gọi `Window:ForgetSavedKey()` khi có để test nhập lại. Lưu file cần API filesystem của executor.

## Provider và độ tin cậy

Key/validator local chạy phía client nên người dùng có thể sửa. Provider cần network/request và service cấu hình đúng. PandaAuth/Jnkie nạp SDK từ xa; secret Platoboost đặt ở client có thể bị đọc. Nhiều validator nghĩa là **một validator thành công là đủ**. Code và SDK bên ngoài có thể đổi; trước khi phát hành hãy test key đúng, sai và trường hợp lỗi mạng bằng tài khoản thật. Không nhúng secret thật vào ví dụ.

Để tùy chỉnh UI, dùng `KeySystem.Ophyn`, ví dụ `SyncTheme = false`, `SyncFont = false`, `Theme`, `Logo`, `Title`, `Description`. Những option thực sự hỗ trợ là của vendor được nhúng, không mặc định mọi option upstream tương lai đều chạy.

---

# Build, test và xuất bản

## Cấu trúc dự án

| Đường dẫn | Công dụng |
| --- | --- |
| `src/modules/` | Source Luau chia module theo thứ tự; nguồn chính của thư viện. |
| `src/manifest.json` | Thứ tự module, hash và metadata cân bằng block. |
| `src/profiles/`, `src/stubs/` | Profile dev/release và module thay thế. |
| `src/build.py`, `src/minify.py` | Công cụ build, minify single/light/compact/full. |
| `dist/main.lua`, `dist/main.min.lua` | Bản release sinh ra; đưa vào repo/ZIP khi cần. |
| `docs/site/content.py`, `details.py` | Nội dung song ngữ. |
| `docs/site/template.html` | Giao diện HTML độc lập, CSS/JS/SVG inline. |
| `docs/site/build.py` | Sinh HTML và manual Markdown từ nội dung. |
| `.github/workflows/pages.yml` | Workflow Pages bằng GitHub Actions. |

## Lệnh build

```bash
python3 src/build.py --check
python3 src/build.py --release --check
python3 src/build.py --release --minify light
python3 -m pip install -r docs/site/requirements.txt
python3 docs/site/build.py
```

Manifest kiểm tra hash và độ cân bằng block của module. Khi sửa module, cập nhật metadata thay vì chỉ sửa `dist`. Bản single là wrapper một dòng cần loadstring, khôi phục mã light có xuống dòng khi chạy. Bản light giữ xuống dòng trực tiếp; compact rất dài có thể gây vấn đề cho executor cũ. Compile thành công chỉ kiểm tra cú pháp/giới hạn register, không chứng minh chạy đúng trong Roblox.

## Checklist trước khi phát hành

1. Test khởi động, key đúng/sai, đóng/mở và thay UI xNgot cũ bằng UI mới.
2. Trên mobile test chạm và cuộn, kéo slider, thả ngoài nút, dropdown, toggle, input; test cả chuột desktop.
3. Test tìm/tải nhạc với dịch vụ thật, file local, tự chuyển/preload và lỗi mạng.
4. Kiểm tra lưu/đọc/xóa config và các API executor trên thiết bị đích.
5. Build hai bản release; cập nhật `dist/`, `docs/` trong repo rồi commit/push. ZIP local hoặc đăng Pages không tự cập nhật script raw trên GitHub.
6. Chọn GitHub Actions làm nguồn Pages trong Settings repo và chờ workflow thành công. `https://xngotzume123.github.io/xNgotLibrary/` chỉ là URL dự kiến sau khi đăng; dùng URL thực tế GitHub cung cấp.

Có thể mở `docs/index.html` để xem local nếu repo private hoặc chưa truy cập được. Điều hướng song ngữ cần JavaScript. Trang không cần font, script hay icon bên ngoài.

---

# Hướng dẫn control: bắt đầu tại đây

Mỗi trang control là một **đoạn nối thêm**, không phải script riêng. Hãy ghép đoạn khởi tạo dưới đây với một hoặc nhiều ví dụ ở các trang tiếp theo rồi chạy. Đặt `main.lua` mới trong workspace của executor; cần `readfile` và `loadstring`.

```lua
getgenv().xNgotLibraryOnly = true
local chunk, err = loadstring(readfile("main.lua"))
assert(chunk, err)
local LIB = chunk()
local Window = LIB:CreateWindow({
    Title = "Control examples", Folder = "ControlExamples",
    FileSaveName = "settings.json", AutoSave = true,
    SettingsUI = true, Loading = false,
})
local Tab = Window:Tab({ Title = "Main", Icon = "house" })
Window:SelectTab("Main")
```

## Trước khi tạo control

- `Tab:Section()` đổi vùng chứa cho các control tạo **sau đó**; tạo section khác để đổi vùng. `Section:_Use("Button", {...})` chỉ định vùng chứa cụ thể. Xóa section hiện tại sẽ đưa vùng chứa về tab.
- Toggle, Slider, Input, Dropdown và Colorpicker gọi callback ngay khi tạo, với giá trị mặc định hoặc đã khôi phục. Hãy tạo đối tượng phụ thuộc trước; đừng dùng biến local đang được gán từ chính constructor của nó bên trong callback.
- Giá trị lưu theo tên tab và **Title ban đầu** của control, không theo `Flag`. Đặt Title duy nhất trong mỗi tab. Đổi tên sau đó không tự chuyển key lưu. `AutoSave` và API file ảnh hưởng việc lưu; xem mục Window & storage.
- `Lock()` khóa tương tác người dùng; setter bằng code vẫn có thể cập nhật và gọi callback. `Destroy()` xóa control khỏi giao diện.
- `AIControl = false` loại control khỏi danh sách trợ lý local. Hành động UI đã xác nhận gọi callback gốc; xem Cross AI: điều khiển UI.
- Mobile giữ kích thước gốc. Kéo slider theo chiều ngang; vuốt dọc dùng để cuộn. Vẫn cần test thực tế trong Roblox/executor.

---

# Section

Nhóm control trong một vùng có thể thu gọn.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local group = Tab:Section({ Title = "Actions", Default = true })
Tab:Button({ Title = "Inside Actions", Callback = function() print("Pressed") end })
group:SetOpen(true)
-- group:_Use("Toggle", { Title = "Extra", Callback = function(v) print(v) end })
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title` | string | `Section` | Tiêu đề |
| `Default` | boolean | `false` | Mở sẵn |
| `TextXAlignment` | string | `Left` | Left, Center hoặc Right |

## Đối tượng trả về

`SetTitle(text)`, `SetOpen(boolean)` (returns state), `Toggle()` (returns state), `Destroy()`, `_Use(methodName, options)`

## Lưu ý

Control tạo sau qua `Tab` nằm trong section mới nhất, không tự quay về tab. `_Use` không đổi vùng chứa mặc định lâu dài.

---

# Button

Thực hiện hành động khi nhấn.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local button = Tab:Button({
    Title = "Say hello", Desc = "Run an action",
    Callback = function() print("Hello!") end,
})
-- button:Lock()  -- button:Unlock()
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title` | string | `Button` | Nhãn |
| `Desc` | string | `nil` | Mô tả tùy chọn |
| `Locked` | boolean | `false` | Khóa tương tác |
| `Callback` | function() | `no-op` | Chạy khi nhấn |

## Đối tượng trả về

`SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Lưu ý

Callback không nhận tham số.

---

# Toggle

Bật hoặc tắt một tính năng.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local toggle = Tab:Toggle({
    Title = "Auto action", Desc = "Example switch", Default = false, Icon = "zap",
    Callback = function(enabled) print("Auto action:", enabled) end,
})
toggle:Set(true)
-- toggle:Set() -- invert
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title` | string | `Toggle` | Nhãn và key lưu ban đầu |
| `Desc` | string | `nil` | Mô tả tùy chọn |
| `Default / Value` | boolean | `false` | Trạng thái đầu; nên chỉ dùng Default |
| `Icon` | string | `nil` | Tên icon tùy chọn |
| `Locked` | boolean | `false` | Khóa tương tác |
| `Callback` | function(boolean) | `no-op` | Nhận trạng thái mới |

## Đối tượng trả về

`Set(boolean)` or `Set()` to invert, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Lưu ý

Callback chạy khi tạo và sau Set; trạng thái đã lưu có thể ghi đè Default. Tránh truyền đồng thời Default=false và Value=true vì biểu thức fallback có thể chọn Value.

---

# Slider

Chọn số trong một khoảng.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local slider = Tab:Slider({
    Title = "Speed", Value = { Min = 0, Max = 100, Default = 25 }, Step = 5,
    Callback = function(value) print("Speed:", value) end,
})
slider:Set(40)
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Slider / nil` | Nhãn và mô tả |
| `Value.Min / Max` | number | `0 / 100` | Giới hạn khoảng |
| `Value.Default` | number | `Min` | Giá trị đầu; cũng hỗ trợ Default ở ngoài |
| `Step` | number | `1` | Bước dương khi thay đổi |
| `Locked` | boolean | `false` | Khóa tương tác |
| `Callback` | function(number) | `no-op` | Nhận số |

## Đối tượng trả về

`Set(number)`, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Lưu ý

Giá trị được giới hạn trong khoảng; Step không hợp lệ hoặc không dương trở về 1. Callback cũng chạy khi tạo và Set.

---

# Input

Nhận văn bản, có thể nhiều dòng.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local input = Tab:Input({
    Title = "Nickname", Placeholder = "Enter a name", Default = "Guest",
    Callback = function(text) print("Nickname:", text) end,
})
input:Set("Player")
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Input / nil` | Nhãn và mô tả |
| `Placeholder` | string | `empty` | Gợi ý trong ô nhập |
| `Default / Value` | string | `empty` | Nội dung ban đầu |
| `ClearTextOnFocus` | boolean | `false` | Xóa khi focus |
| `NoSave` | boolean | `false` | Không khôi phục hoặc lưu input này vào config |
| `MultiLine` | boolean | `false` | Cho phép nhiều dòng |
| `Locked` | boolean | `false` | Khóa tương tác |
| `Callback` | function(string) | `no-op` | Nhận chuỗi |

## Đối tượng trả về

`Set(text)`, `Get()` (current TextBox text, even while focused), `SetTitle(text)`, `SetDesc(text)`, `SetPlaceholder(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Lưu ý

Callback chạy khi tạo, khi mất focus và sau Set; không chạy theo từng ký tự. `NoSave=true` ngăn input đọc/ghi config; không xóa giá trị đã lưu trước đó.

---

# Dropdown

Chọn một hoặc nhiều mục.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local mode = Tab:Dropdown({
    Title = "Mode", Values = {"Normal", "Fast"}, Value = "Normal",
    Callback = function(value) print("Mode:", value) end,
})
mode:Select("Fast")
local colors = Tab:Dropdown({
    Title = "Colors", Values = {"Red", "Blue", "Green"},
    Multi = true, AllowNone = true, Value = {"Red"},
    Callback = function(values) print("Selected:", table.concat(values, ", ")) end,
})
colors:Select({"Blue", "Green"})
-- mode:Refresh({"Normal", "Fast", "Slow"})
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Dropdown / nil` | Nhãn và mô tả |
| `Values` | array of strings | `{}` | Danh sách lựa chọn |
| `Value / Default` | string or array | `nil` | Lựa chọn ban đầu |
| `Multi` | boolean | `false` | Cho phép chọn nhiều |
| `AllowNone` | boolean | `false` | Cho phép không chọn |
| `Locked` | boolean | `false` | Khóa tương tác |
| `Callback` | function(value) | `no-op` | Một mục: string hoặc nil; nhiều mục: mảng |

## Đối tượng trả về

`Select(value)` (returns selected value or nil), `Refresh(values)` (returns selection), `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Lưu ý

Callback chạy khi tạo và Select. Với multi, Select đảo trạng thái từng mục được truyền, không thay toàn bộ lựa chọn. Một lựa chọn với AllowNone biểu diễn None bằng chuỗi rỗng trong callback; multi nhận mảng. Refresh đặt lại lựa chọn và lưu nhưng không gọi Callback. Multi với AllowNone=false chọn mục đầu nếu ban đầu chưa chọn.

---

# Colorpicker

Chọn màu và nhận giá trị Color3.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local color = Tab:Colorpicker({
    Title = "Accent example", Default = "#66AAFF",
    Callback = function(value) print("Color:", value) end,
})
color:Set(Color3.fromRGB(255, 120, 80))
print(color:Get())
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Color / empty` | Nhãn và mô tả |
| `Default / Value` | Color3, hex string or RGB table | `white` | Màu ban đầu |
| `Locked` | boolean | `false` | Khóa tương tác |
| `Callback` | function(Color3) | `no-op` | Nhận Color3 |

## Đối tượng trả về

`Set(value)`, `Get()` → Color3, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Lưu ý

Nhận Color3, `#RRGGBB` hoặc bảng RGB. Đầu vào không hợp lệ trở về trắng. Callback chạy khi tạo và Set; ví dụ này không tự đổi theme toàn UI.

---

# Paragraph

Hiển thị tiêu đề và nội dung.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local status = Tab:Paragraph({ Title = "Status", Desc = "Ready" })
status:SetDesc("Running")
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title` | string | `Paragraph` | Tiêu đề |
| `Desc` | string | `nil` | Nội dung |
| `RichText` | boolean | `false` | Cho phép tag Roblox RichText |

## Đối tượng trả về

`SetTitle(text)`, `SetDesc(text)`, `Destroy()`

## Lưu ý

Đây là phần hiển thị, không phải control lưu giá trị.

---

# Code

Hiển thị khối code trong cửa sổ.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local code = Tab:Code({ Title = "Example", Code = 'print("Hello")' })
code:SetCode('print("Updated")')
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Title` | string | `Code` | Tiêu đề |
| `Code` | string | `empty` | Nội dung code |

## Đối tượng trả về

`SetTitle(text)`, `SetCode(text)`, `Destroy()`

## Lưu ý

Chỉ hiển thị văn bản; không thực thi đoạn đó.

---

# Discord & InfoNguyenNhat

Hiển thị thẻ cộng đồng và hồ sơ.

Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.

```lua
local discord = Tab:Discord({ Name = "Community", Desc = "Join us", InviteLink = "discord.gg/example" })
local info = Tab:InfoNguyenNhat({ Name = "Developer", Bio = "Building a hub" })
info:SetBio("Welcome!")
-- discord:SetInvite("discord.gg/example", "example")
```

## Tùy chọn

| Tên | Kiểu | Mặc định | Ý nghĩa |
| --- | --- | --- | --- |
| `Discord.Avatar` | string | `rbxassetid://0` | Asset avatar |
| `Discord.Name / Desc` | string | `Discord Server / empty` | Tên và mô tả server |
| `Discord.InviteLink / InviteCode` | string | `discord.gg/xxxxxxx / nil` | Link mời và code tùy chọn |
| `Info.Avatar / Name / Bio` | string | `rbxassetid://0 / Nguyen Nhat / empty` | Thông tin hồ sơ |
| `Info.Badges` | table | `{}` | Danh sách badge |

## Đối tượng trả về

Discord: `SetInvite(link, code)`, `Destroy()`. Info: `SetAvatar(id)`, `SetName(text)`, `SetBio(text)`, `Destroy()`, `Info.AddSocialIcon(icon, copyValue, order)` (dot call).

## Lưu ý

Hoạt động của invite, avatar và mạng phụ thuộc executor/dịch vụ; ví dụ link chỉ là placeholder.

---

# Cross AI: điều khiển UI

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

---

# Cross tự ghi nhớ

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

---

# Cross: tích hợp xử lý offline

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
