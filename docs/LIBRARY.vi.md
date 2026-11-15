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
python3 src/build.py --release --minify light
```

Lệnh tạo `dist/main.lua` và `dist/main.min.lua`. Bản light giữ xuống dòng và đã qua kiểm tra bằng Luau cũ với giới hạn 200 registers. Vẫn cần executor Roblox để test lúc chạy.

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
Main:Button({ Title = "Làm mới", Icon = "refresh-cw", Callback = function()
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
    Island:PlayMusic()
end
```

## Preset

```lua
_G.xNgotMusicConfig:Preset("lowdata")
_G.xNgotMusicConfig:Set("topN", 8)
print(_G.xNgotMusicConfig:Get("topN"))
```

Chọn **Music region** và **Music platform** trong cài đặt Island. Auto ưu tiên quốc gia do Roblox cung cấp, sau đó dùng locale; chọn Global để bỏ ưu tiên vùng. Có Việt Nam, Mỹ, Hàn Quốc và Nhật Bản. Đây là thêm từ khóa khu vực khi tìm, không phải bộ lọc xác minh ngôn ngữ hay quốc tịch. Giao diện hỗ trợ YouTube, SoundCloud, Audius; kết quả và tải nhạc phụ thuộc dịch vụ bên ngoài.

Khi bật **Preload next track** và Auto play, lúc phát đến 50% trình phát chuẩn bị bài kế tiếp trong danh sách hiện tại và cố tải trước âm thanh. Shuffle chọn trước một bài; Repeat One được ưu tiên. Nếu chỉ có một bài thì bỏ qua tải trước. Nếu chưa tải xong hoặc tải lỗi, trình phát tiếp tục xử lý bình thường; không đảm bảo chuyển bài hoàn toàn không trễ. Tải trước dùng mạng và bộ nhớ. Tự nhận vùng không dùng dịch vụ tra IP bên thứ ba.

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
