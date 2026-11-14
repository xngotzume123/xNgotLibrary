# Thư viện xNgot Library — Hướng dẫn sử dụng

> Tài liệu dành cho **người viết script dùng lại thư viện**.
> Bản tiếng Anh: [`LIBRARY.en.md`](LIBRARY.en.md) · Tổng quan repo: [`../README.md`](../README.md)

Thư viện gồm 5 khối, dùng được độc lập:

| Khối | Bạn nhận được | Toàn cục |
|---|---|---|
| **UI** | Cửa sổ, Tab, 11 loại element, Settings tab, KeySystem | `LIB` (giá trị trả về) |
| **Bảng nổi** | Bảng điều khiển nổi: thông báo, hoạt động, nhạc, Cross AI, hẹn giờ | `Window.DynamicIsland` |
| **Engine nhạc** | Tìm / chấm điểm / tải nhạc từ YouTube, SoundCloud, Audius | `_G.CrossAIMusic` |
| **Cấu hình nhạc** | 16 khoá cấu hình có schema, 4 preset | `_G.xNgotMusicConfig` |
| **Log / debug** | `Log`, `DevTools`, `Debug` (bản release thay bằng stub) | `_G.xNgotLog`, `_G.xNgotDevTools` |

---

## 1. Nạp thư viện

### 1.1. Chế độ mặc định (mở luôn hub xNgot Library)

```lua
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()
```

Chạy xong, script tự mở cửa sổ **xNgot Library** và tạo `_G.Window`.
Thích hợp khi bạn chỉ muốn dùng hub có sẵn.

### 1.2. Chế độ library-only (khuyến nghị khi làm hub riêng)

Đặt cờ **trước** khi load:

```lua
getgenv().xNgotLibraryOnly = true

local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()
local Window = LIB:CreateWindow({ Title = "Hub của tôi" })
```

Ở chế độ này:

- **không** tự mở hub xNgot Library, **không** có `_G.Window`;
- `LIB` vẫn đầy đủ chức năng, bạn tự tạo cửa sổ của mình;
- bảng nổi **chỉ** được tạo khi `SettingsUI = true` (mặc định);
- muốn mở hub gốc bất cứ lúc nào: `LIB.OpenXNgotHub()`.

### 1.3. Bản minify

Cùng API, chỉ khác đường dẫn — nhẹ hơn ~25%:

```lua
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.min.lua"))()
```

### 1.4. Nạp từ file local (không cần mạng)

```lua
local code = readfile("xNgotStudio.lua")
local LIB = loadstring(code)()
```

> Thứ tự bắt buộc: `loadstring` → gọi hàm → nhận bảng `LIB`. Nếu quên `()`, bạn cầm một
> function chứ không phải thư viện.

---

## 2. Bảng toàn cục

Sau khi nạp, các tên sau tồn tại (một số chỉ ở chế độ mặc định):

| Tên | Kiểu | Khi nào có | Dùng để |
|---|---|---|---|
| `LIB` | table | luôn | API gốc của thư viện |
| `LIB.Version` | string | luôn | `"3.0.0"` |
| `LIB.OpenXNgotHub()` | function | luôn | mở hub xNgot Library |
| `LIB.ActiveDynamicIsland` | table? | sau khi tạo cửa sổ | bảng nổi đang hoạt động |
| `LIB.LastDynamicIslandError` | string? | khi tạo bảng nổi lỗi | thông báo lỗi |
| `LIB.ShowStartupError(err)` | function | luôn | hiện lỗi khởi động dạng hộp thoại |
| `_G.Window` | table? | chỉ chế độ mặc định | cửa sổ hub gốc |
| `_G.xNgotPanel` | function? | chế độ mặc định | bật/tắt panel debug |
| `_G.xNgotLog` | table | luôn | xem mục 12 |
| `_G.xNgotDevTools` | table | bản dev | xem mục 12 |
| `_G.xNgotDebug` | table | luôn | panel/export log |
| `_G.xNgotDebugBridge` | table | bản dev | cầu nối debug |
| `_G.xNgotMusicConfig` | table | luôn | cấu hình nhạc (mục 10) |
| `_G.CrossAIMusic` | table | luôn | engine nhạc (mục 11) |
| `_G.Music` / `_G.xNgotMusicEngine` | table | luôn | alias engine |
| `_G.xNgotMusicDoctor` | function | luôn | tự chẩn đoán môi trường |
| `_G.__xNgotEmbeddedLibrary` | table | luôn | chính `LIB` (dùng cho loader) |

`getgenv().xNgotStudio` là handle nội bộ của hub gốc — đừng dựa vào nó trong hub riêng.

---

## 3. `LIB:CreateWindow(options)`

Tạo cửa sổ và **trả về object `Window`**. Mọi option đều tuỳ chọn.

```lua
local Window = LIB:CreateWindow({
    Title = "My Hub",
    Icon = "sparkles",
    Version = "v1.0.0",
    Folder = "MyHub",
    Size = UDim2.fromOffset(620, 440),
    ToggleKey = Enum.KeyCode.RightShift,
    ToggleButtonPlatform = "Both",
    AutoSave = true,
    FileSaveName = "MyHub_Config.json",
    SettingsUI = true,
    Loading = { Text = "Đang tải", Duration = 1.4, Steps = { "UI", "Icon", "Xong" } },
})
```

### 3.1. Bảng option

| Option | Kiểu | Mặc định | Ghi chú |
|---|---|---|---|
| `Title` | string | `"NgotStudio"` | tiêu đề cửa sổ + tên trong bảng nổi |
| `Icon` | string | `"layout-dashboard"` | tên icon (mục 14) |
| `Version` | string | `"v1.0"` | hiện cạnh tiêu đề |
| `Author` | string | `"v1.0"` | dòng phụ |
| `Folder` | string | `"xNgotLibrary/Config"` | thư mục lưu config |
| `Size` | UDim2 | `580×420` | kích thước ban đầu |
| `ToggleKey` | Enum.KeyCode | `RightShift` | phím bật/tắt cửa sổ |
| `ToggleButtonPlatform` | `"PC"` / `"Mobile"` / `"Both"` | `"Both"` | nền tảng hiện nút nổi |
| `LiveSearchDropdown` | boolean | `false` | lọc ngay khi gõ trong dropdown |
| `AutoSave` | boolean | `true` | tự lưu `CONFIG` khi đổi giá trị |
| `FileSaveName` | string | `"NgotStudio_Config.json"` | tên file config |
| `SettingsUI` | boolean | `true` | **`false` ⇒ không có tab Settings và không có bảng nổi** |
| `SettingsTitle` / `SettingsIcon` | string | `"Settings Ui"` / `"settings"` | tuỳ biến tab Settings |
| `Loading` | table | `{Duration = 1.6}` | màn hình chờ: `Text`, `Steps` (mảng), `Duration` (giây) |
| `KeySystem` | table / `false` | `false` | xem 3.2 |
| `AdminInfo` | table / `false` | `false` | thẻ admin: `{Name, Bio, Avatar}` |

### 3.2. KeySystem (cửa sổ khoá)

```lua
KeySystem = {
    Enabled = true,
    Title = "Key System",
    Subtitle = "Nhập key để tiếp tục",
    Note = "Lấy key ở Discord",
    Key = "XNGOT-2026",                 -- một key đơn
    Keys = { "XNGOT-2026", "VIP-2026" },-- hoặc nhiều key
    CaseSensitive = false,
    GetKey = "https://discord.gg/...",  -- link nút "Get Key"
    GetKeyUrl = "https://...",
    KeyFile = "xNgotLibrary/Keys/key.txt", -- nơi nhớ key đã nhập
}
```

- Key đã nhập đúng được ghi vào `KeyFile`; lần sau vào thẳng.
- `Window.KeyUnlocked` = `true/false` cho biết đã qua cổng chưa.
- Xoá key đã nhớ: `Window:ForgetSavedKey()` (xoá file `KeyFile`).

> Cổng khoá cũng bật khi `Loading` khác `nil` — tức là màn hình chờ dùng chung cơ chế
> "startup gate" với KeySystem.

---

## 4. Object `Window`

### 4.1. Thuộc tính

| Thuộc tính | Kiểu | Ý nghĩa |
|---|---|---|
| `Window.Title`, `.Icon`, `.Version` | string | bản sao option |
| `Window.DynamicIsland` | table? | bảng nổi của cửa sổ này (`nil` nếu `SettingsUI = false`) |
| `Window.DynamicIslandError` | string? | lỗi khi tạo bảng nổi |
| `Window.Size` | UDim2 | kích thước hiện tại |
| `Window.ToggleKey` | Enum.KeyCode | phím tắt |
| `Window.ConfigPath` | string | đường dẫn file config |
| `Window.KeySystem` | table? | cấu hình key |
| `Window.KeyUnlocked` | boolean | đã mở khoá chưa |
| `Window.Visible` | boolean | cửa sổ đang hiện |

### 4.2. Phương thức — hiển thị

| Gọi | Việc |
|---|---|
| `Window:Show()` / `Window:Hide()` / `Window:Toggle(state?)` | hiện / ẩn / đảo trạng thái |
| `Window:Destroy()` | đóng, dọn GUI, ngắt kết nối |
| `Window:SetToggleKey(Enum.KeyCode.X)` | đổi phím tắt |
| `Window:SetToggleButtonPlatform("PC"\|"Mobile"\|"Both")` | đổi nền tảng nút nổi |
| `Window:GetToggleButtonPlatform()` | đọc lại |
| `Window:EditOpenButton({ Icon = "x", Size = UDim2.fromOffset(44,44) })` | sửa nút nổi |

### 4.3. Phương thức — Tab & nội dung

| Gọi | Việc |
|---|---|
| `Window:Tab({ Title, Icon })` → `Tab` | tạo tab mới |
| `Window:SelectTab("Main")` hoặc `SelectTab(2)` | chuyển tab theo tên / số thứ tự |
| `Window:Divider()` | vạch ngăn cách trong tab hiện tại |
| `Window:Dialog({ Title, Content, Icon, Buttons })` | hộp thoại (xem 6.10) |

### 4.4. Phương thức — cấu hình

| Gọi | Việc |
|---|---|
| `Window:SaveConfig()` | ghi `CONFIG` xuống `ConfigPath` |
| `Window:DeleteConfig()` | xoá file config |
| `Window:GetConfigPath()` | đường dẫn file |
| `Window:ForgetSavedKey()` | xoá key đã nhớ |

### 4.5. Phương thức — giao diện (UI settings)

| Gọi | Việc |
|---|---|
| `Window:GetUISettings()` | bảng cài đặt giao diện hiện tại |
| `Window:SetUISettings(tbl, save?)` | áp cài đặt (màu, opacity, blur, font…) |
| `Window:GetUIOverrides()` / `ClearUIOverride(key, save?)` | các khoá đã bị ghi đè |
| `Window:SetUISize(w, h, save?)` / `GetUISize()` / `ResetUISize(save?)` | kích thước |
| `Window:ApplyUIPreset("Default"\|...)` / `GetUIPresets()` | preset giao diện |
| `Window:UseOriginalUI(save?)` | trả giao diện về mặc định gốc |
| `Window:ExportUISettings()` / `ImportUISettings(json, save?)` | xuất / nhập JSON |
| `Window:SaveUISettings()` | lưu ngay |
| `Window:GetUIProfileNames()` / `SaveUIProfile(name)` / `LoadUIProfile(name, save?)` / `DeleteUIProfile(name)` | profile giao diện |
| `Window:OpenUISettings()` | mở tab Settings |
| `Window:GetUILanguage()` / `SetUILanguage()` | ngôn ngữ UI (bản này chỉ `"en"`) |
| `Window:RefreshAdminAvatar()` | tải lại avatar thẻ admin |

Ví dụ đổi màu nhấn từ code:

```lua
Window:SetUISettings({ AccentColor = Color3.fromRGB(255, 55, 132), Enabled = true }, true)
```

### 4.6. Phương thức — bảng nổi

| Gọi | Việc |
|---|---|
| `Window:GetDynamicIsland()` | trả API bảng nổi (hoặc `nil`) |
| `Window:NotifyIsland(title, message, kind?, duration?)` | gửi thông báo lên bảng nổi |
| `Window:IslandActivity(title, message, duration?, kind?)` | hiện thanh hoạt động |

---

## 5. `Tab` và element

### 5.1. Tạo tab

```lua
local Tab = Window:Tab({ Title = "Main", Icon = "house" })
```

- Mỗi tab tự tạo một nhánh `CONFIG[Title]` để lưu giá trị element.
- **Trong cùng một tab, `Title` của các element phải khác nhau** — trùng tên là trùng khoá
  lưu, element sau ghi đè element trước.
- `Icon`: tên icon (xem mục 14).

### 5.2. Quy tắc chung của element

1. Mọi element nhận bảng `data` gồm: `Title`, `Desc`, `Locked` (+ trường riêng từng loại).
2. `Callback(value)` được gọi **một lần ngay khi tạo** với giá trị khởi tạo, rồi mỗi lần đổi.
3. Mọi element trả về object có ít nhất `:Destroy()`; phần lớn có thêm `:Set`, `:SetTitle`,
   `:SetDesc`, `:Lock`, `:Unlock`.
4. `Locked = true` ⇒ element hiện nhưng không bấm được (khoá mềm).

### 5.3. `Tab:Section(data)`

Nhóm các element bên dưới nó.

| Trường | Kiểu | Mặc định | Ghi chú |
|---|---|---|---|
| `Title` | string | `"Section"` | |
| `Default` | boolean | `false` | mở sẵn hay đóng |
| `TextXAlignment` | Enum | `Left` | căn tiêu đề |

```lua
local Sec = Tab:Section({ Title = "Cơ bản", Default = true })
Sec:SetTitle("Mới")  Sec:SetOpen(true)  Sec:Toggle()  Sec:Destroy()
-- thêm element vào section đang mở:
Sec:_Use("Button", { Title = "Nút trong section" })
```

### 5.4. `Tab:Toggle(data)`

| Trường | Kiểu | Mặc định |
|---|---|---|
| `Title` / `Desc` / `Icon` | string | — |
| `Default` (hoặc `Value`) | boolean | `false` |
| `Callback` | function(state) | — |

```lua
local esp = Tab:Toggle({ Title = "ESP", Default = false, Callback = function(on) print(on) end })
esp:Set(true)     -- đổi trạng thái + gọi Callback
esp.State         -- đọc trực tiếp
```

### 5.5. `Tab:Slider(data)`

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `Value = { Min, Max, Default }` | table | `Min` 0, `Max` 100 |
| `Default` | number | dùng thay `Value.Default` cũng được |
| `Step` | number | bước nhảy, mặc định 1 |

```lua
local s = Tab:Slider({ Title = "Tốc độ", Value = { Min = 16, Max = 200, Default = 50 }, Step = 2,
    Callback = function(v) getgenv().Speed = v end })
s:Set(100)
```

### 5.6. `Tab:Input(data)`

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `Placeholder` | string | chữ mờ |
| `Default` / `Text` | string | giá trị đầu |
| `MultiLine` | boolean | ô nhiều dòng |
| `ClearTextOnFocus` | boolean | xoá khi bấm vào |

```lua
local nick = Tab:Input({ Title = "Tên", Placeholder = "Nhập tên…", Default = "xNgot" })
print(nick.Text)          nick:Set("Mới")   nick:SetPlaceholder("…")
```

### 5.7. `Tab:Dropdown(data)`

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `Values` | mảng string/table | danh sách chọn |
| `Value` / `Default` | string / table | giá trị đầu |
| `Multi` | boolean | chọn nhiều ⇒ Callback nhận **bảng** |
| `AllowNone` | boolean | thêm mục `"None"` |

```lua
local src = Tab:Dropdown({ Title = "Nguồn", Values = { "youtube", "soundcloud" }, Default = "youtube",
    Callback = function(v) print(v) end })
src:Refresh({ "a", "b", "c" })   src:Select("b")

local tags = Tab:Dropdown({ Title = "Thể loại", Multi = true, Values = { "lofi", "jazz" },
    Default = { "lofi" }, Callback = function(list) print(#list) end })
```

### 5.8. `Tab:Colorpicker(data)`

```lua
local c = Tab:Colorpicker({ Title = "Màu nhấn", Default = Color3.fromRGB(10,132,255),
    Callback = function(color) print(color) end })
c:Set(Color3.new(1,0,0))   print(c:Get())
```

### 5.9. `Tab:Paragraph`, `Tab:Code`, `Tab:Button`

```lua
Tab:Paragraph({ Title = "Giới thiệu", Desc = "Chữ mô tả, có RichText." })
local p = Tab:Paragraph({ Title = "A", Desc = "B" }); p:SetTitle("A2"); p:SetDesc("B2")

local code = Tab:Code({ Title = "Ví dụ", Code = "print('hi')" }); code:SetCode("print(2)")
-- cũng có Code:SetTitle(...)

local btn = Tab:Button({ Title = "Chạy", Desc = "bấm để chạy", Callback = function() end })
btn:SetTitle("Chạy lại"); btn:SetDesc("…"); btn:Lock(); btn:Unlock()
```

### 5.10. `Window:Dialog(data)`

```lua
Window:Dialog({
    Title = "Xác nhận",
    Content = "Xoá toàn bộ cấu hình?",
    Icon = "triangle-alert",
    Buttons = {
        { Title = "Huỷ" },                              -- không Callback = chỉ đóng
        { Title = "Xoá", Callback = function() Window:DeleteConfig() end },
    },
})
```

### 5.11. `Tab:InfoNguyenNhat(data)` và `Tab:Discord(data)`

```lua
Tab:InfoNguyenNhat({ Title = "Tác giả", Name = "xNgot", Bio = "…", Avatar = 1234567890 })
Tab:Discord({ Title = "Discord", InviteCode = "abcd1234" })
```

`Info`: `SetName`, `SetBio`, `SetAvatar(id)` · `Discord`: `SetInvite(link, code)`.

---

## 6. Tự lưu cấu hình (`CONFIG`)

- Mỗi tab = `CONFIG["<tên tab>"]`; mỗi element = `CONFIG["<tên tab>"]["<Title element>"]`.
- Khi cửa sổ tạo element, giá trị **đã lưu** được ưu tiên hơn `Default`.
- `AutoSave = true` ⇒ đổi giá trị là ghi file (có debounce), không cần gọi tay.
- Đổi tên `Title` của element = mất giá trị đã lưu của element đó.
- Muốn đọc/ghi tay: `Window:SaveConfig()`, `Window:GetConfigPath()`; đọc file bằng
  `readfile(Window:GetConfigPath())` rồi `HttpService:JSONDecode`.

---

## 7. `LIB:Notify(data)`

Thông báo dạng thẻ. Nếu bảng nổi đang bật, thông báo được **đẩy lên bảng nổi** (trừ khi
`Native = true`).

| Trường | Kiểu | Mặc định | Ghi chú |
|---|---|---|---|
| `Title` | string | `"Notification"` | |
| `Content` | string | `""` | |
| `Icon` | string | `"info"` | `"circle-check"`/`"check"` ⇒ success, `"triangle-alert"` ⇒ warn |
| `Kind` | `"info"`/`"success"`/`"warn"`/`"error"` | `"info"` | |
| `Duration` | number (giây) | `5` | tối thiểu `0.1` |
| `Native` | boolean | `false` | `true` ⇒ luôn dùng thẻ góc màn hình |

```lua
local n = LIB:Notify({ Title = "Xong", Content = "Đã lưu", Kind = "success", Duration = 4 })
n.Close()   -- đóng sớm
```

---

## 8. API bảng nổi

```lua
local Island = Window:GetDynamicIsland()
if Island then Island:Notify("Tiêu đề", "Nội dung", "info", 4) end
```

`nil` khi `SettingsUI = false` hoặc tạo bảng nổi lỗi (xem `Window.DynamicIslandError`).

### 8.1. Thông báo & hoạt động

| Hàm | Việc |
|---|---|
| `Island:Notify(title, message, kind?, duration?)` | thông báo trên bảng nổi, trả `false` nếu đang tắt |
| `Island:GameplayActivity(title, message, duration?, kind?)` | thanh hoạt động có đếm giây |
| `Island:Enable(bool)` | bật/tắt bảng nổi |
| `Island:Set(key, value)` | đổi cài đặt (xem 8.5) |
| `Island:State()` | `{ Cross, Playing, MusicIndex, FPS, Ping, Timer, Island }` |

### 8.2. Mở rộng / thu gọn

| Hàm | Việc |
|---|---|
| `Island:Expand(page?)` | mở rộng; `page` = `"Home"`, `"Music"`, `"Cross"`, `"Timer"`, `"Stopwatch"`, `"Download"` |
| `Island:Collapse()` | thu về thanh gọn |
| `Island:Theme(n)` / `Island:Accent(n)` | đổi bảng màu (1–7) / màu nhấn (1–6) |
| `Island:SetLanguage(lang)` | `"vi"` / `"en"` |

### 8.3. Timer & đồng hồ bấm giây

| Hàm | Việc |
|---|---|
| `Island:Timer(seconds)` | hẹn giờ (1–86400) |
| `Island:StopTimer()` / `Island:ExtendTimer(seconds)` | dừng / cộng thêm |
| `Island:WatchToggle()` / `WatchLap()` / `WatchReset()` | đồng hồ bấm giây |

### 8.4. Nhạc

| Hàm | Việc |
|---|---|
| `Island:MusicSearch(prompt)` | tìm bằng mô tả tự nhiên (`"lofi chill buổi tối"`) |
| `Island:MusicSearchState()` | trạng thái lượt tìm |
| `Island:MusicRows()` | danh sách hàng kết quả |
| `Island:MusicSelectValue(value, play?)` | chọn bài theo `value` của hàng |
| `Island:MusicSelect(index, play?)` | chọn theo thứ tự |
| `Island:MusicCatalog()` / `OnMusicCatalogChanged(fn)` | catalog + listener |
| `Island:OnMusicChanged(fn)` | listener đổi bài / trạng thái |
| `Island:PlayMusic()` / `NextMusic(n?)` | phát–dừng / bài kế (± n) |
| `Island:MusicVolume(0–100)` / `MusicSpeed(0.5–2)` | âm lượng / tốc độ |
| `Island:MusicMode("Auto"\|"Shuffle"\|"RepeatOne"\|"ShowIsland", bool)` | chế độ phát |
| `Island:MusicFiles(includeSizes?)` → `files, stats` | file đã tải |
| `Island:MusicStorage()` → `stats` | dung lượng cache |
| `Island:MusicPlayFile(path)` / `MusicDeleteFile(path)` / `MusicClearDownloaded()` | thao tác file |
| `Island:MusicPlayTrack(id, url, source)` / `MusicDownloadOne(id, url, source)` | phát / tải trực tiếp |
| `Island:MusicLoadDownloaded()` | nạp danh sách đã tải |
| `Island:MusicAiLearn(title, good)` | dạy AI thích/không thích 1 bài |
| `Island:DemoDownload()` | chạy hiệu ứng tải mẫu |

### 8.5. Cross AI

| Hàm | Việc |
|---|---|
| `Island:AiEnable(bool)` | bật/tắt trợ lý |
| `Island:AiAsk(prompt)` | hỏi (hiểu cả tiếng Việt và tiếng Anh) |
| `Island:AiOpen()` | mở trang Cross |
| `Island:AiClear()` | xoá hội thoại |
| `Island:AiPermission(name, bool)` | `name` ∈ `Ui`, `Body`, `Free`, `Key` |
| `Island:MusicAiOnline(bool)` / `MusicAiOnlineState()` | bật/tắt chế độ AI online |

### 8.6. Cài đặt bảng nổi (`Island:Set`)

Các khoá hay dùng: `Language`, `Theme`, `Accent`, `Duration`, `Ring`, `RimLight`, `Fps`,
`Ping`, `Clock`, `Expand`, `ShowIsland`, `Toast`, `Bubble`…

```lua
Island:Set("Duration", 6)     -- thông báo hiện 6 giây
Island:Set("Ring", false)     -- tắt vòng tiến trình (nhẹ máy)
Island:Set("Fps", true)       -- hiện FPS trên thanh gọn
```

### 8.7. Sự kiện & huỷ

```lua
Island:OnMusicChanged(function(state) print("đổi bài", state) end)
Island:Destroy()   -- xoá bảng nổi, ngắt mọi kết nối
```

---

## 9. Cấu hình nhạc `_G.xNgotMusicConfig`

```lua
local cfg = _G.xNgotMusicConfig
cfg:Set("topN", 15)
print(cfg:Get("topN"))
```

| Hàm | Việc |
|---|---|
| `Get(key)` | đọc 1 khoá |
| `Set(key, value)` | ghi (kiểm tra schema + áp xuống engine) |
| `Schema()` | bảng schema đầy đủ |
| `Apply()` | áp toàn bộ xuống engine |
| `OnChange(fn)` | nghe thay đổi |
| `Preset(name)` → `ok, err` | áp preset |
| `Presets()` | danh sách preset |

### 9.1. 16 khoá

| Khoá | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `topN` | number 1–40 | `12` | số kết quả trả về |
| `sources` | table | `{youtube,soundcloud,audius}` | nguồn tìm |
| `searchTimeout` | number 2–60 | `12` | giây tối đa 1 lượt tìm |
| `preferShort` | number 0–7200 | `600` | ưu tiên bài ≤ N giây (0 = tắt) |
| `folder` | string | `"xNgotLibrary/Music"` | thư mục cache mp3 |
| `raceTracks` | number 1–4 | `2` | số bài tải song song |
| `downloadTimeout` | number 20–600 | `200` | giây chờ chuyển mã |
| `retries` | number 0–5 | `2` | số lần thử lại |
| `renameFiles` | boolean | `true` | đặt tên file theo tên bài |
| `aiBrain` | string | `"local"` | bộ não AI (offline) |
| `aiLearn` | boolean | `true` | AI tự học từ bài bị bỏ qua |
| `coverArt` | boolean | `true` | hiện ảnh bìa |
| `compactRows` | boolean | `false` | thẻ nhạc 1 dòng |
| `showSource` | boolean | `true` | hiện nhãn nguồn |
| `notifyOnSearch` | boolean | `true` | báo khi tìm xong |
| `debug` | boolean | `false` | log ra console |

### 9.2. Preset

| Preset | Tác dụng |
|---|---|
| `fast` | nhanh: `raceTracks 2`, `topN 8`, `searchTimeout 8`, nguồn YT + Audius |
| `quality` | chất lượng: tải tuần tự, `topN 20`, `searchTimeout 20`, đủ 3 nguồn |
| `lowdata` | tiết kiệm: `topN 6`, chỉ YouTube, tắt ảnh bìa |
| `vietnamese` | nhạc Việt: SoundCloud trước, `topN 15`, `preferShort 420` |

```lua
_G.xNgotMusicConfig:Preset("lowdata")
```

---

## 10. Engine nhạc `_G.CrossAIMusic`

Dùng khi bạn muốn tự vẽ UI nhưng tận dụng phần tìm/tải.

| Nhóm | Hàm |
|---|---|
| **Phân tích** | `parse(prompt)` → plan, `durationSeconds(text)`, `normalizeRow(row, src)`, `queryVariants(plan, prompt)` |
| **Tìm & chấm điểm** | `search(plan, callback, prompt)`, `score(track, plan)`, `learn(title, good)` |
| **Tải** | `download(url, onProgress)`, `fetchFile(key, urls, onProgress, title)`, `resolve(prompt, onState)`, `assetFor(track, onProgress)` |
| **File** | `listDownloaded(sizes?)`, `downloadedStats(sizes?)`, `deleteDownloaded(path)`, `clearDownloaded()`, `saveBytes(key, data, title)` |
| **Metadata** | `readDownloadedMeta(path)`, `writeDownloadedMeta(path, meta)`, `renameFiles(bool)`, `isRenameEnabled()` |
| **Ảnh bìa** | `thumbAsset(track)`, `coverAsset(track)`, `prefetchCovers(list, onOne)` |
| **Hàng hiển thị** | `rowLabel(track, i)`, `rowValue(track, i)`, `rowData(track, i)`, `enrich(track)` |
| **PoW / HTTP** | `request(url, method, headers, body, timeout)`, `getPowToken()` |
| **LLM (tuỳ chọn)** | `llmAvailable()`, `llmEnabled()`, `llmSetEnabled(bool)`, `llmStatus()`, `llmPlan(prompt, plan)`, `llmSay(prompt, ctx)`, `applyLlmPlan(plan, extra)` |

```lua
local plan = _G.CrossAIMusic.parse("nhạc lofi nhẹ cho buổi tối")
_G.CrossAIMusic.search(plan, function(state, rows)
    for i, row in ipairs(rows or {}) do print(i, row.Title, row.Source) end
end, "nhạc lofi nhẹ cho buổi tối")
```

### 10.1. Tự chẩn đoán

```lua
local report = _G.xNgotMusicDoctor()
-- report.items: { { name = "writefile", status = "ok"|"fail"|"warn", detail = "..." }, ... }
-- report.fails, report.warns, report.ok
```

Kiểm tra: `writefile/readfile/isfile/makefolder/listfiles/getcustomasset`, `request`,
engine, parser, PoW-SHA256, config, bảng nổi API.

---

## 11. Log, Debug, DevTools

```lua
_G.xNgotLog.info("tag", "nội dung", { extra = 1 })   -- mức: trace debug info warn error
_G.xNgotLog:filter("warn")                            -- lọc
_G.xNgotLog:export()                                  -- chuỗi text toàn bộ log
_G.xNgotLog.clear()
```

| Đối tượng | Hàm chính |
|---|---|
| `Log` (`_G.xNgotLog`) | `add`, `trace/debug/info/warn/error`, `filter`, `tags`, `stats`, `countsByTag`, `export`, `download`, `onEntry`, `hookConsole`, `measure`, `apiCall`, `clear`, `level`, `format` |
| `DevTools` (`_G.xNgotDevTools`) | `note`, `vars`, `executors`, `run(code)`, `add`, `check`, `selftest`, `report` |
| `Debug` (`_G.xNgotDebug`) | `getLogPanel()`, `exportLog()`, `openPanel()`, `closePanel()`, `toggle()`, `report()`, `mode()` |

> Bản `--release` thay `DevTools`, hook HTTP, bridge và panel bằng stub rỗng:
> `_G.xNgotLog` vẫn có, `_G.xNgotDevTools` vẫn tồn tại nhưng `selftest()` trả về
> `{ passed = 0, skipped = true }`.

---

## 12. Loader & chế độ

| Cờ / biến | Tác dụng |
|---|---|
| `getgenv().xNgotLibraryOnly = true` | không tự mở hub gốc |
| `getgenv().xNgotMusic = { topN = 10, ... }` | cấu hình nhạc trước khi engine dựng |
| `getgenv().xNgotLoaderConfig` | bảng option của loader (`localFile`, `remoteUrl`, `title`…) |
| `__xNgotBoot.start()` | mở hub gốc theo cách thủ công |
| `__xNgotBoot.performance()` / `lowPower(bool)` | đọc hiệu năng / chế độ nhẹ |
| `__xNgotBoot.Stage` | `"ready"` khi xong |

Loader tự dò nguồn theo thứ tự: **thư viện nhúng → file local (`main.lua`) → URL remote**,
lần lượt thử cho tới khi tạo được cửa sổ.

---

## 13. Icon

`Icon = "<tên-icon>"` dùng tên icon, ví dụ:

```
house · music-2 · sparkles · settings · bell · search · download · trash-2 · play · pause
skip-forward · skip-back · volume-2 · clock · timer · activity · cpu · wifi · user · key
shield · layout-dashboard · wrench · info · circle-check · triangle-alert · sliders-horizontal
```

Bộ đầy đủ 1.548 icon nằm ở `src/modules/50_lucide/040_icons_*.lua` trong repo.
Icon sai tên không gây lỗi — chỉ không hiện hình.

---

## 14. Ví dụ hoàn chỉnh

### 14.1. Hub tối giản

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "Demo", Icon = "music-2", Author = "v1.0" })
local Tab = Window:Tab({ Title = "Main", Icon = "house" })

Tab:Section({ Title = "Cơ bản", Default = true })
Tab:Toggle({ Title = "Bật", Default = true, Callback = print })
Tab:Slider({ Title = "Tốc độ", Value = { Min = 16, Max = 200, Default = 50 }, Callback = print })
Tab:Button({ Title = "Thông báo", Callback = function()
    LIB:Notify({ Title = "Xin chào", Content = "từ thư viện", Kind = "success" })
end })
```

### 14.2. Hub + bảng nổi + nhạc

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()
local Window = LIB:CreateWindow({ Title = "Music Hub", Icon = "sparkles", SettingsUI = true })
local Island = Window:GetDynamicIsland()

local Tab = Window:Tab({ Title = "Music", Icon = "music-2" })
Tab:Section({ Title = "Tìm nhạc", Default = true })

local q = Tab:Input({ Title = "Mô tả", Default = "lofi chill buổi tối" })
Tab:Button({ Title = "Tìm", Callback = function()
    Island:MusicSearch(q.Text)
    Island:Expand("Music")
end })
Tab:Button({ Title = "Phát / dừng", Callback = function() Island:PlayMusic() end })
Tab:Slider({ Title = "Âm lượng", Value = { Min = 0, Max = 100, Default = 60 },
    Callback = function(v) Island:MusicVolume(v) end })
Tab:Button({ Title = "Cache", Callback = function()
    local s = Island:MusicStorage()
    LIB:Notify({ Title = "Cache", Content = string.format("%d file · %s", s.Count or 0, tostring(s.TotalText)) })
end })
```

---

## 15. FAQ

| Câu hỏi | Trả lời |
|---|---|
| Không thấy bảng nổi? | `SettingsUI = false` ⇒ không có bảng nổi. Bật lại rồi tạo lại cửa sổ. |
| `Window.DynamicIsland` là `nil`? | Xem `Window.DynamicIslandError`; thường do lỗi khi dựng GUI (thiếu quyền executor). |
| Element trùng tên bị đè? | `CONFIG[tab][Title]` — đổi `Title` cho khác nhau. |
| `Callback` chạy ngay khi tạo? | Đúng, chạy 1 lần với giá trị khởi tạo. Đừng giả định nó là "chỉ khi người dùng bấm". |
| Đổi màu/font toàn bộ UI? | `Window:SetUISettings{...}` hoặc `Window:ApplyUIPreset("...")`. |
| Tắt tiếng báo khi tìm nhạc? | `_G.xNgotMusicConfig:Set("notifyOnSearch", false)` |
| Máy yếu, giật? | `_G.xNgotMusicConfig:Preset("lowdata")` + `Island:Set("Ring", false)` |
| Dùng nhiều cửa sổ cùng lúc? | Được — mỗi `CreateWindow` trả về object riêng; bảng nổi là cái của cửa sổ tạo sau. |
| Lỗi `attempt to index nil` ở `Island:` | Chưa kiểm tra `Island` có tồn tại. Luôn `if Island then ... end`. |
| Nhạc không phát? | Chạy `_G.xNgotMusicDoctor()` xem mục nào `fail`. |
