# xNgot Library — Hướng dẫn sử dụng

> Dành cho người **dùng thư viện để làm hub / menu cho script Roblox**.
> Bản tiếng Anh: [`LIBRARY.en.md`](LIBRARY.en.md) · Giới thiệu & ủng hộ: [`../README.md`](../README.md)

Bạn không cần biết gì về Lua nâng cao. Chỉ cần biết khai báo **bảng** (table) — phần còn lại
thư viện lo hết: vẽ giao diện, kéo thả, hiệu ứng, lưu cài đặt, thông báo, nhạc.

---

## 1. Bắt đầu trong 30 giây

```lua
local LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "My Hub", Icon = "sparkles" })
local Tab = Window:Tab({ Title = "Trang chính", Icon = "house" })

Tab:Button({ Title = "Xin chào", Callback = function()
    LIB:Notify({ Title = "Chào bạn", Content = "Thư viện đã chạy", Kind = "success" })
end })
```

Chạy là có cửa sổ. Đọc tiếp khi cần thêm chức năng.

---

## 2. Nạp thư viện

### 2.1. Cách thường dùng

```lua
local LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()
```

Nạp xong, thư viện mở sẵn một **cửa sổ demo** để bạn xem giao diện. Khi bạn tạo cửa sổ riêng
(`LIB:CreateWindow`), cửa sổ demo tự đóng.

### 2.2. Chỉ lấy thư viện, không mở gì cả

Đặt cờ **trước** dòng nạp:

```lua
getgenv().xNgotLibraryOnly = true

local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()
local Window = LIB:CreateWindow({ Title = "Hub của tôi" })
```

Lúc này không có cửa sổ demo, không có `_G.Window`, chỉ có `LIB` cho bạn dùng.

### 2.3. Bản nhẹ

Đổi `dist/main.lua` → `dist/main.min.lua`. Nhẹ hơn khoảng 25%, API y hệt.

### 2.4. Nạp từ file có sẵn (không cần mạng)

```lua
local LIB = loadstring(readfile("xNgotLibrary.lua"))()
```

> Nhớ có cặp ngoặc `()` ở cuối. Thiếu nó bạn đang cầm một *hàm*, chưa phải thư viện.

---

## 3. Tạo cửa sổ

```lua
local Window = LIB:CreateWindow({
    Title = "My Hub",              -- tiêu đề cửa sổ (cũng là tên trên bảng nổi)
    Icon = "sparkles",             -- icon cạnh tiêu đề
    Version = "v1.0.0",            -- chữ nhỏ cạnh tiêu đề
    Size = UDim2.fromOffset(620, 440),
    ToggleKey = Enum.KeyCode.RightShift,
})
```

Mọi trường đều tuỳ chọn — bỏ trống thì dùng mặc định.

| Trường | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `Title` | string | `"NgotStudio"` | tiêu đề cửa sổ |
| `Icon` | string | `"layout-dashboard"` | tên icon (mục 14) |
| `Version` | string | `"v1.0"` | chữ hiện cạnh tiêu đề |
| `Author` | string | `"v1.0"` | dòng phụ dưới tiêu đề |
| `Folder` | string | `"xNgotLibrary/Config"` | thư mục lưu cài đặt |
| `Size` | UDim2 | `580×420` | kích thước lúc mở |
| `ToggleKey` | Enum.KeyCode | `RightShift` | phím ẩn/hiện |
| `ToggleButtonPlatform` | `"PC"` / `"Mobile"` / `"Both"` | `"Both"` | nút nổi hiện trên thiết bị nào |
| `LiveSearchDropdown` | boolean | `false` | danh sách chọn lọc ngay khi gõ |
| `AutoSave` | boolean | `true` | tự lưu khi người dùng đổi giá trị |
| `FileSaveName` | string | `"NgotStudio_Config.json"` | tên tệp cài đặt |
| `SettingsUI` | boolean | `true` | `false` = **không có tab Settings và không có bảng nổi** |
| `SettingsTitle` / `SettingsIcon` | string | `"Settings Ui"` / `"settings"` | đổi tên tab cài đặt |
| `Loading` | table | — | màn hình chờ: `Text`, `Steps` (danh sách), `Duration` (giây) |
| `KeySystem` | table / `false` | `false` | khoá bằng key — xem mục 4 |
| `AdminInfo` | table / `false` | `false` | thẻ tác giả: `{ Name, Bio, Avatar }` |

---

## 4. Khoá cửa sổ bằng key

```lua
KeySystem = {
    Enabled = true,
    Title = "Nhập key",
    Subtitle = "Key lấy ở Discord",
    Note = "Liên hệ tác giả để lấy key",
    Keys = { "XNGOT-2026", "VIP-2026" },   -- nhiều key cũng được
    CaseSensitive = false,                  -- không phân biệt hoa thường
    GetKeyUrl = "https://discord.gg/...",   -- nút "Lấy key"
}
```

- Key đúng thì được nhớ vào `xNgotLibrary/Keys/key.txt`; lần sau vào thẳng.
- `Window.KeyUnlocked` cho biết người dùng đã qua cổng chưa.
- Muốn bắt nhập lại: `Window:ForgetSavedKey()`.

---

## 5. Tab và thành phần

### 5.1. Tạo tab

```lua
local Tab = Window:Tab({ Title = "Main", Icon = "house" })
```

- `Title` của tab là **tên nhóm cài đặt** — đổi tên tab là mất cài đặt cũ của tab đó.
- Trong **cùng một tab**, `Title` của các thành phần phải **khác nhau** (trùng là ghi đè lên nhau).

### 5.2. Quy tắc chung

1. Mọi thành phần nhận bảng `data`: `Title`, `Desc`, `Locked` và các trường riêng.
2. `Callback` được gọi **ngay khi tạo** (một lần, với giá trị ban đầu) rồi mỗi lần đổi.
   Đừng giả định nó chỉ chạy khi người dùng bấm.
3. Thành phần trả về object có `:Destroy()`, thường thêm `:Set`, `:SetTitle`, `:SetDesc`, `:Lock`, `:Unlock`.
4. `Locked = true` ⇒ hiện nhưng bấm không được (khoá mềm).

### 5.3. Khung nhóm — `Section`

```lua
local Sec = Tab:Section({ Title = "Cơ bản", Default = true })
Sec:SetTitle("Mới")   Sec:SetOpen(true)   Sec:Toggle()   Sec:Destroy()
```

| Trường | Kiểu | Mặc định |
|---|---|---|
| `Title` | string | `"Section"` |
| `Default` | boolean | `false` (mở sẵn?) |
| `TextXAlignment` | Enum | `Left` |

### 5.4. Công tắc — `Toggle`

```lua
local esp = Tab:Toggle({
    Title = "ESP",
    Desc = "Hiện khung người chơi",
    Default = false,
    Callback = function(on) print("ESP:", on) end,
})

esp:Set(true)   -- bật từ code (có gọi Callback)
print(esp.State) -- đọc trạng thái
```

| Trường | Kiểu | Mặc định |
|---|---|---|
| `Title` / `Desc` / `Icon` | string | — |
| `Default` (hoặc `Value`) | boolean | `false` |
| `Callback` | function(state) | — |

### 5.5. Thanh kéo — `Slider`

```lua
local s = Tab:Slider({
    Title = "Tốc độ",
    Value = { Min = 16, Max = 200, Default = 50 },
    Step = 2,
    Callback = function(v) getgenv().Speed = v end,
})
s:Set(100)
```

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `Value = { Min, Max, Default }` | table | `Min` 0, `Max` 100 nếu bỏ trống |
| `Step` | number | bước nhảy, mặc định `1` |
| `Default` | number | dùng thay `Value.Default` cũng được |

### 5.6. Ô nhập — `Input`

```lua
local nick = Tab:Input({ Title = "Tên", Placeholder = "Nhập tên…", Default = "xNgot" })
print(nick.Text)          -- đọc
nick:Set("Mới")           -- ghi
nick:SetPlaceholder("…")
```

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `Placeholder` | string | chữ mờ khi trống |
| `Default` / `Text` | string | giá trị ban đầu |
| `MultiLine` | boolean | ô nhiều dòng |
| `ClearTextOnFocus` | boolean | xoá chữ khi bấm vào |

### 5.7. Danh sách chọn — `Dropdown`

```lua
local src = Tab:Dropdown({
    Title = "Nguồn nhạc",
    Values = { "youtube", "soundcloud", "audius" },
    Default = "youtube",
    Callback = function(v) print("chọn:", v) end,
})
src:Refresh({ "a", "b", "c" })   -- đổi danh sách
src:Select("b")                  -- chọn từ code

-- chọn nhiều:
local tags = Tab:Dropdown({
    Title = "Thể loại", Multi = true, AllowNone = true,
    Values = { "lofi", "jazz", "chill" }, Default = { "lofi" },
    Callback = function(list) print("đã chọn " .. #list .. " mục") end,
})
```

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `Values` | mảng string | danh sách mục |
| `Value` / `Default` | string / table | mục chọn sẵn |
| `Multi` | boolean | chọn nhiều ⇒ `Callback` nhận **bảng** |
| `AllowNone` | boolean | thêm mục "None" |

### 5.8. Bảng màu — `Colorpicker`

```lua
local c = Tab:Colorpicker({
    Title = "Màu nhấn",
    Default = Color3.fromRGB(10, 132, 255),
    Callback = function(color) print(color) end,
})
c:Set(Color3.new(1, 0, 0))
print(c:Get())
```

### 5.9. Đoạn văn, khối code, nút bấm

```lua
Tab:Paragraph({ Title = "Giới thiệu", Desc = "Chữ mô tả, hỗ trợ RichText." })

local code = Tab:Code({ Title = "Ví dụ", Code = "print('xin chào')" })
code:SetCode("print(2)")

local btn = Tab:Button({ Title = "Chạy", Desc = "bấm để chạy", Callback = function() end })
btn:SetTitle("Chạy lại")   btn:Lock()   btn:Unlock()
```

### 5.10. Hộp thoại — `Window:Dialog`

```lua
Window:Dialog({
    Title = "Xác nhận",
    Content = "Xoá toàn bộ cài đặt?",
    Icon = "triangle-alert",
    Buttons = {
        { Title = "Huỷ" },                                        -- không Callback = chỉ đóng
        { Title = "Xoá", Callback = function() Window:DeleteConfig() end },
    },
})
```

### 5.11. Thẻ tác giả và Discord

```lua
Tab:InfoNguyenNhat({ Title = "Tác giả", Name = "xNgot", Bio = "…", Avatar = 1234567890 })
Tab:Discord({ Title = "Discord", InviteCode = "abcd1234" })
```

`Info`: `SetName`, `SetBio`, `SetAvatar(id)` · `Discord`: `SetInvite(link, code)`.

---

## 6. Thông báo — `LIB:Notify`

```lua
local n = LIB:Notify({
    Title = "Đã lưu",
    Content = "Cài đặt của bạn đã được ghi lại",
    Kind = "success",     -- info / success / warn / error
    Duration = 4,         -- giây
})
n.Close()                 -- đóng sớm nếu muốn
```

| Trường | Mặc định | Ghi chú |
|---|---|---|
| `Title` | `"Notification"` | |
| `Content` | `""` | |
| `Kind` | `"info"` | info · success · warn · error |
| `Icon` | `"info"` | đặt `circle-check` ⇒ success, `triangle-alert` ⇒ warn |
| `Duration` | `5` | tối thiểu `0.1` giây |
| `Native` | `false` | `true` = luôn dùng thẻ ở góc màn hình |

Nếu bảng nổi đang bật, thông báo sẽ hiện **trên bảng nổi** cho gọn màn hình.

---

## 7. Tự lưu cài đặt

- Mỗi tab là một nhóm, mỗi thành phần là một mục trong nhóm đó.
- Lần mở sau, giá trị **đã lưu** được ưu tiên hơn `Default`.
- `AutoSave = true` ⇒ đổi là tự ghi, bạn không phải làm gì.
- Đổi `Title` của thành phần = mất giá trị đã lưu của thành phần đó (vì khoá lưu đổi theo tên).

Làm tay khi cần:

```lua
Window:SaveConfig()          -- ghi ngay
print(Window:GetConfigPath())-- xem lưu ở đâu
Window:DeleteConfig()        -- xoá sạch cài đặt
```

---

## 8. Bảng nổi

Bảng nổi là thanh điều khiển nhỏ nằm trên màn hình (thông báo, nhạc, hẹn giờ, trợ lý AI).
Nó **chỉ tồn tại khi `SettingsUI = true`** (mặc định).

```lua
local Island = Window:GetDynamicIsland()      -- nil nếu không có bảng nổi
if Island then
    Island:Notify("Tiêu đề", "Nội dung", "info", 4)
end
```

> Tên hàm giữ nguyên `GetDynamicIsland` / `DynamicIsland` như bản phát hành gốc để script cũ
> không phải sửa. Trong tài liệu mình gọi nó là **bảng nổi**.

### 8.1. Thông báo và hoạt động

| Hàm | Việc |
|---|---|
| `Island:Notify(title, message, kind?, duration?)` | thông báo trên bảng nổi |
| `Island:GameplayActivity(title, message, duration?, kind?)` | thanh hoạt động có đếm giây |
| `Island:Enable(true/false)` | bật/tắt bảng nổi |
| `Island:Set(khoá, giá trị)` | đổi cài đặt (xem 8.6) |
| `Island:State()` | trạng thái hiện tại |

### 8.2. Mở rộng / thu gọn

| Hàm | Việc |
|---|---|
| `Island:Expand(page?)` | mở rộng: `"Home"`, `"Music"`, `"Cross"`, `"Timer"`, `"Stopwatch"`, `"Download"` |
| `Island:Collapse()` | thu về thanh gọn |
| `Island:Theme(1–7)` / `Island:Accent(1–6)` | đổi bảng màu / màu nhấn |
| `Island:SetLanguage("vi" / "en")` | đổi ngôn ngữ bảng nổi |

### 8.3. Hẹn giờ và đồng hồ bấm giây

```lua
Island:Timer(300)        -- hẹn giờ 5 phút
Island:ExtendTimer(60)   -- cộng thêm 1 phút
Island:StopTimer()

Island:WatchToggle()  Island:WatchLap()  Island:WatchReset()
```

### 8.4. Nhạc

```lua
Island:MusicSearch("lofi chill buổi tối")   -- tìm bằng mô tả
Island:Expand("Music")
Island:MusicSelect(1, true)                 -- chọn bài đầu và phát
Island:PlayMusic()                          -- phát / dừng
Island:NextMusic(1)                         -- bài kế tiếp
Island:MusicVolume(65)                      -- 0–100
Island:MusicSpeed(1.0)                      -- 0.5–2
```

| Nhóm | Hàm |
|---|---|
| Tìm kiếm | `MusicSearch(prompt)`, `MusicSearchState()`, `MusicRows()` |
| Chọn bài | `MusicSelectValue(value, play?)`, `MusicSelect(index, play?)`, `MusicCatalog()` |
| Phát | `PlayMusic()`, `NextMusic(n?)`, `MusicPlayTrack(id, url, source)` |
| Âm thanh | `MusicVolume(0–100)`, `MusicSpeed(0.5–2)`, `MusicMode("Auto"/"Shuffle"/"RepeatOne"/"ShowIsland", bool)` |
| Tệp đã tải | `MusicFiles(sizes?)`, `MusicStorage()`, `MusicPlayFile(path)`, `MusicDeleteFile(path)`, `MusicClearDownloaded()`, `MusicLoadDownloaded()` |
| Tải trực tiếp | `MusicDownloadOne(id, url, source)`, `DemoDownload()` |
| AI học gu nhạc | `MusicAiLearn(title, good)` |
| Sự kiện | `OnMusicChanged(fn)`, `OnMusicCatalogChanged(fn)` |

### 8.5. Trợ lý AI

```lua
Island:AiEnable(true)
Island:AiAsk("mở trang nhạc")     -- hiểu cả tiếng Việt và tiếng Anh
Island:AiOpen()
Island:AiClear()
Island:AiPermission("Ui", true)   -- Ui / Body / Free / Key
```

### 8.6. Cài đặt bảng nổi — `Island:Set`

```lua
Island:Set("Duration", 6)    -- thông báo hiện 6 giây
Island:Set("Ring", false)    -- tắt vòng tiến trình (nhẹ máy)
Island:Set("Fps", true)      -- hiện FPS
Island:Set("Clock", true)    -- hiện đồng hồ
```

Các khoá hay dùng: `Language`, `Theme`, `Accent`, `Duration`, `Ring`, `RimLight`, `Fps`,
`Ping`, `Clock`, `Expand`, `ShowIsland`, `Toast`, `Bubble`.

### 8.7. Tắt hẳn bảng nổi

```lua
Island:Destroy()
```

---

## 9. Cấu hình nhạc — `_G.xNgotMusicConfig`

```lua
_G.xNgotMusicConfig:Set("topN", 15)
print(_G.xNgotMusicConfig:Get("topN"))
```

| Hàm | Việc |
|---|---|
| `Get(key)` / `Set(key, value)` | đọc / ghi một khoá |
| `Preset(name)` | áp bộ cài sẵn (xem 9.2) |
| `Presets()` | danh sách preset |
| `Apply()` | áp toàn bộ xuống engine |
| `OnChange(fn)` | nghe thay đổi |
| `Schema()` | xem toàn bộ khoá và giới hạn |

### 9.1. Các khoá chính

| Khoá | Mặc định | Ý nghĩa |
|---|---|---|
| `topN` | `12` | số kết quả mỗi lần tìm (1–40) |
| `sources` | youtube, soundcloud, audius | nguồn tìm nhạc |
| `searchTimeout` | `12` | giây tối đa một lượt tìm |
| `preferShort` | `600` | ưu tiên bài ngắn hơn N giây (0 = tắt) |
| `folder` | `xNgotLibrary/Music` | nơi lưu nhạc đã tải |
| `raceTracks` | `2` | số bài tải song song |
| `downloadTimeout` | `200` | giây chờ tải xong |
| `retries` | `2` | số lần thử lại khi lỗi |
| `renameFiles` | `true` | đặt tên tệp theo tên bài |
| `aiLearn` | `true` | AI tự học từ bài bạn bỏ qua |
| `coverArt` | `true` | hiện ảnh bìa |
| `compactRows` | `false` | thẻ nhạc 1 dòng cho gọn |
| `notifyOnSearch` | `true` | báo khi tìm xong |
| `debug` | `false` | ghi log chi tiết |

### 9.2. Preset

| Preset | Hợp với |
|---|---|
| `fast` | mạng chậm, cần kết quả nhanh |
| `quality` | máy khoẻ, muốn nhiều lựa chọn và chất lượng cao |
| `lowdata` | 3G / máy yếu, ít kết quả, không ảnh bìa |
| `vietnamese` | ưu tiên nhạc Việt (SoundCloud trước) |

```lua
_G.xNgotMusicConfig:Preset("lowdata")
```

---

## 10. Đổi giao diện

Người dùng bấm trong tab **Settings Ui** là đủ. Nếu bạn muốn đổi từ code:

```lua
Window:SetUISettings({ AccentColor = Color3.fromRGB(255, 55, 132), Enabled = true }, true)

Window:ApplyUIPreset("Default")     -- bộ giao diện dựng sẵn
Window:ResetUISize(true)            -- về kích thước mặc định
Window:UseOriginalUI(true)          -- trả về giao diện gốc
```

| Nhóm | Hàm |
|---|---|
| Đọc / ghi | `GetUISettings()`, `SetUISettings(tbl, save?)`, `SaveUISettings()` |
| Kích thước | `SetUISize(w, h, save?)`, `GetUISize()`, `ResetUISize(save?)` |
| Preset | `ApplyUIPreset(name)`, `GetUIPresets()` |
| Hồ sơ riêng | `SaveUIProfile(name)`, `LoadUIProfile(name)`, `DeleteUIProfile(name)`, `GetUIProfileNames()` |
| Xuất / nhập | `ExportUISettings()`, `ImportUISettings(json, save?)` |
| Khác | `GetUIOverrides()`, `ClearUIOverride(key, save?)`, `OpenUISettings()`, `SetUILanguage()` |

---

## 11. Các hàm điều khiển cửa sổ

| Gọi | Việc |
|---|---|
| `Window:Show()` / `Hide()` / `Toggle(state?)` | hiện / ẩn / đảo trạng thái |
| `Window:Destroy()` | đóng và dọn sạch |
| `Window:SetToggleKey(Enum.KeyCode.X)` | đổi phím tắt |
| `Window:SetToggleButtonPlatform("PC" / "Mobile" / "Both")` | nút nổi hiện trên thiết bị nào |
| `Window:EditOpenButton({ Icon = "x", Size = UDim2.fromOffset(44, 44) })` | sửa nút nổi |
| `Window:SelectTab("Main")` hoặc `SelectTab(2)` | chuyển tab |
| `Window:Divider()` | vạch ngăn cách |
| `Window:GetConfigPath()` / `SaveConfig()` / `DeleteConfig()` | tệp cài đặt |
| `Window:ForgetSavedKey()` | xoá key đã nhớ |

---

## 12. Cờ và biến toàn cục

| Tên | Tác dụng |
|---|---|
| `getgenv().xNgotLibraryOnly = true` | không tự mở cửa sổ demo (đặt trước khi nạp) |
| `getgenv().xNgotMusic = { topN = 10 }` | cấu hình nhạc trước khi engine khởi động |
| `_G.xNgotMusicConfig` | cấu hình nhạc (mục 9) |
| `_G.CrossAIMusic` | engine nhạc: `parse`, `search`, `download`, `assetFor`… |
| `_G.xNgotMusicDoctor()` | tự kiểm tra môi trường (xem 13) |
| `_G.xNgotLog` | log của thư viện |
| `_G.Window` | cửa sổ demo (chỉ khi không dùng `xNgotLibraryOnly`) |

---

## 13. Gỡ lỗi

**Nhạc không phát?** Chạy:

```lua
local report = _G.xNgotMusicDoctor()
print(report.fails, report.warns)
```

Nó kiểm tra `writefile`, `readfile`, `makefolder`, `getcustomasset`, `request`, engine, parser…
Dòng nào `fail` là nguyên nhân.

**Xem log:**

```lua
_G.xNgotLog.info("tag", "nội dung")
print(_G.xNgotLog:export())     -- toàn bộ log dạng text
_G.xNgotLog.clear()
```

**Panel debug:** bấm **RightShift** hoặc `_G.xNgotDebug.openPanel()`.

---

## 14. Icon

`Icon = "<tên-icon>"`. Có sẵn hơn 1.500 icon, viết theo tên, ví dụ:

```
house · music-2 · sparkles · settings · bell · search · download · trash-2 · play · pause
skip-forward · skip-back · volume-2 · clock · timer · activity · cpu · wifi · user · key
shield · layout-dashboard · wrench · info · circle-check · triangle-alert · sliders-horizontal
```

Gõ sai tên **không gây lỗi** — chỉ là icon không hiện. Cứ thử tên bạn đoán, phần lớn tên
tiếng Anh thông thường đều có.

---

## 15. Ví dụ hoàn chỉnh

### 15.1. Hub tối giản

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "Demo", Icon = "music-2" })
local Tab = Window:Tab({ Title = "Main", Icon = "house" })

Tab:Section({ Title = "Cơ bản", Default = true })
Tab:Toggle({ Title = "Bật", Default = true, Callback = print })
Tab:Slider({ Title = "Tốc độ", Value = { Min = 16, Max = 200, Default = 50 }, Callback = print })
Tab:Button({ Title = "Thông báo", Callback = function()
    LIB:Notify({ Title = "Xin chào", Content = "từ thư viện", Kind = "success" })
end })
```

### 15.2. Hub có nhạc

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "Music Hub", Icon = "sparkles" })
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

Tab:Button({ Title = "Dung lượng đã tải", Callback = function()
    local s = Island:MusicStorage()
    LIB:Notify({ Title = "Bộ nhớ", Content = string.format("%d bài", s.Count or 0) })
end })
```

---

## 16. Câu hỏi thường gặp

| Câu hỏi | Trả lời |
|---|---|
| Không thấy bảng nổi? | `SettingsUI = false` thì không có bảng nổi. Bật lại rồi tạo cửa sổ mới. |
| `Window.DynamicIsland` là `nil`? | Xem `Window.DynamicIslandError`, thường do executor thiếu quyền dựng GUI. |
| Thêm 2 thành phần trùng tên bị đè? | Đúng — đổi `Title` cho khác nhau. |
| `Callback` chạy ngay khi tạo? | Đúng, một lần với giá trị ban đầu. |
| Đổi màu / font toàn bộ? | `Window:SetUISettings{...}` hoặc `Window:ApplyUIPreset("...")`. |
| Máy yếu? | `_G.xNgotMusicConfig:Preset("lowdata")` + `Island:Set("Ring", false)`. |
| Cài đặt mất khi thoát game? | Không — nằm trong `xNgotLibrary/Config/`. |
| Tạo nhiều cửa sổ cùng lúc? | Được, mỗi `CreateWindow` trả về object riêng. |
| Muốn phát hành cho người có key? | Thêm `KeySystem` khi tạo cửa sổ (mục 4). |

---

<p align="center">
Thư viện miễn phí — nếu thấy hữu ích, bạn có thể
<a href="../README.md#-ủng-hộ-tác-giả">ủng hộ tác giả một ly cà phê</a> ☕
</p>
