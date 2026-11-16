"""In-depth bilingual reference pages; based on the current source modules."""
sections_detail = [
('full-example','GUIDES','HƯỚNG DẪN','Complete hub example','Ví dụ hub hoàn chỉnh','15',r'''# Complete hub example

This is a single script, not a set of independent snippets. Put the **updated** `main.lua` in the executor workspace first. The example does not use the demo boot and does not depend on GitHub. It deliberately has no key gate; see the key pages to add one.

```lua
getgenv().xNgotLibraryOnly = true
local chunk, err = loadstring(readfile("main.lua"))
assert(chunk, err)
local LIB = chunk()

local Window = LIB:CreateWindow({
    Title = "My Hub", Author = "Example", Icon = "sparkles",
    Size = UDim2.fromOffset(580, 420),
    Folder = "MyHub", FileSaveName = "settings.json",
    AutoSave = true, SettingsUI = true, Loading = false,
})
local Main = Window:Tab({ Title = "Main", Icon = "house" })
Main:Section({ Title = "Controls", Default = true })
local status = Main:Paragraph({ Title = "Status", Desc = "Ready" })
local enabled = Main:Toggle({
    Title = "Enabled", Default = false,
    Callback = function(value) status:SetDesc(value and "Enabled" or "Disabled") end,
})
Main:Slider({
    Title = "Amount", Value = { Min = 0, Max = 100, Default = 25 }, Step = 5,
    Callback = function(value) print("Amount:", value) end,
})
Main:Input({ Title = "Name", Placeholder = "Enter text",
    Callback = function(text) print("Name:", text) end,
})
Main:Dropdown({ Title = "Mode", Values = {"Normal", "Fast"}, Value = "Normal",
    Callback = function(value) print("Mode:", value) end,
})
Main:Button({ Title = "Test notification", Callback = function()
    LIB:Notify({ Title = "xNgot", Content = "Hello!", Kind = "success", Duration = 3 })
end })
Window:SelectTab("Main")
```

## What happens on startup

1. Library-only mode returns `LIB` instead of running the bundled demo.
2. `CreateWindow` replaces the previous active xNgot window; it does not intentionally remove unrelated game UI.
3. `Window:Tab` returns a tab. `Section` becomes the container for later controls on that tab.
4. State callbacks can run immediately with default or restored values. Build dependencies such as `status` **before** callbacks that use them.
5. `SettingsUI = true` creates Settings and, if initialization succeeds, the integrated island. `Loading = false` disables the loader when there is no enabled key gate.

> This code has not been validated in every Roblox experience or executor. The library uses executor APIs, which differ across environments.
''',r'''# Ví dụ hub hoàn chỉnh

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
'''),
('component-reference','DETAILED REFERENCE','THAM KHẢO CHI TIẾT','Component reference','Chi tiết từng control','16',r'''# Component reference

All constructors below are called on a `Tab`. Their `Title` values should be unique within a tab because stateful controls use the original title as a config key. Renaming a control later does **not** migrate that key.

| Constructor | Options | Callback / behavior |
| --- | --- | --- |
| `Button` | `Title`, `Desc`, `Locked`, `Callback` | Invoked on activation. This build does not read an `Icon` option for Button. |
| `Toggle` | `Title`, `Desc`, `Default` or `Value`, `Icon`, `Locked`, `Callback` | Boolean; callback fires at creation and on `:Set`. Avoid specifying conflicting `Default` and `Value`. |
| `Slider` | `Title`, `Desc`, `Value = {Min, Max, Default}`, `Step`, `Locked`, `Callback` | Number; clamped, stepped; callbacks at initialization and changes. `:Set` returns the value or `nil` if outside bounds. |
| `Input` | `Title`, `Desc`, `Placeholder`, `Default` / `Value`, `ClearTextOnFocus`, `MultiLine`, `Locked`, `Callback` | String; callback on initialization, focus loss, and `:Set`. |
| `Dropdown` | `Title`, `Desc`, `Values`, `Value` / `Default`, `Multi`, `AllowNone`, `Locked`, `Callback` | A string for single-select, table for multi-select; callback may fire at creation. |
| `Colorpicker` | `Title`, `Desc`, `Default` / `Value`, `Locked`, `Callback` | Emits `Color3`; `:Get()` returns current value; initial callback runs. |
| `Section` | `Title`, `Default`, `TextXAlignment` | Adds a collapsible group and makes it the parent for subsequent controls created through that tab. |
| `Paragraph` | `Title`, `Desc`, `RichText` | Noninteractive text. |
| `Code` | `Title`, `Code` | Displays code; it does not execute it. |
| `Discord` | `Name`, `Desc`, `Avatar`, `InviteLink`, `InviteCode` | Card for an invite; clipboard and joining depend on executor capabilities. |
| `InfoNguyenNhat` | `Name`, `Bio`, `Avatar`, `Badges` | Profile card. |

## Returned object methods

| Object | Methods |
| --- | --- |
| Button | `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Toggle | `Set`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Slider | `Set`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Input | `Set`, `SetTitle`, `SetDesc`, `SetPlaceholder`, `Lock`, `Unlock`, `Destroy` |
| Dropdown | `Select`, `Refresh`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Colorpicker | `Set`, `Get`, `SetTitle`, `SetDesc`, `Lock`, `Unlock`, `Destroy` |
| Section | `SetTitle`, `SetOpen`, `Toggle`, `Destroy` |
| Paragraph | `SetTitle`, `SetDesc`, `Destroy` |
| Code | `SetTitle`, `SetCode`, `Destroy` |
| Discord | `SetInvite`, `Destroy` |
| InfoNguyenNhat | `SetName`, `SetBio`, `SetAvatar`, `Destroy` |

## Single and multiple choice

```lua
local picker = Main:Dropdown({
    Title = "Targets", Values = {"A", "B", "C"},
    Multi = true, AllowNone = true, Value = {"A"},
    Callback = function(values)
        for _, value in ipairs(values) do print(value) end
    end,
})
picker:Select({"B"}) -- toggles the given item in multi-select
picker:Refresh({"A", "B", "C", "D"}) -- rebuilds choices and resets selection
```

`Refresh` resets the selection; call `Select` after refresh if needed. `AllowNone` applies differently to single and multi-select; a single-select None callback uses an empty string. Use existing values only. For mobile the selected option's persistent color represents selection, not a stuck press.

## Grouping and text

```lua
local section = Main:Section({Title = "Options", Default = true})
Main:Paragraph({Title = "Hint", Desc = "<b>Bold</b>", RichText = true})
section:SetOpen(false)
section:SetOpen(true)
local card = Main:InfoNguyenNhat({Name = "Developer", Bio = "Hello", Badges = {"Dev"}})
card:SetBio("Updated")
```

`Section` is not a separate tab object; continue using `Main:Button(...)` etc. To start a different group, create another section on the tab.
''',r'''# Chi tiết từng control

Các hàm tạo bên dưới được gọi trên `Tab`. Đặt `Title` **khác nhau trong cùng tab**, vì control có trạng thái dùng tên ban đầu làm khóa lưu cấu hình. `SetTitle` sau đó không tự chuyển khóa cũ sang tên mới.

| Thành phần | Tùy chọn | Callback / cách hoạt động |
| --- | --- | --- |
| `Button` | `Title`, `Desc`, `Locked`, `Callback` | Chạy khi nhấn. Bản này không đọc `Icon` cho Button. |
| `Toggle` | `Title`, `Desc`, `Default` hoặc `Value`, `Icon`, `Locked`, `Callback` | Boolean; callback chạy lúc tạo và khi `:Set`. Tránh đặt `Default` và `Value` trái nhau. |
| `Slider` | `Title`, `Desc`, `Value = {Min, Max, Default}`, `Step`, `Locked`, `Callback` | Số; giới hạn theo khoảng và bước; callback chạy lúc tạo và thay đổi. `:Set` trả giá trị hoặc `nil` nếu ngoài khoảng. |
| `Input` | `Title`, `Desc`, `Placeholder`, `Default` / `Value`, `ClearTextOnFocus`, `MultiLine`, `Locked`, `Callback` | Chuỗi; callback chạy lúc tạo, mất focus và `:Set`. |
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
| Input | `Set`, `SetTitle`, `SetDesc`, `SetPlaceholder`, `Lock`, `Unlock`, `Destroy` |
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
'''),
('window-reference','DETAILED REFERENCE','THAM KHẢO CHI TIẾT','Window and storage APIs','API cửa sổ và lưu trữ','17',r'''# Window and storage APIs

## Window lifecycle and navigation

| Method | Meaning |
| --- | --- |
| `Window:Tab({Title, Icon})` | Create a tab. |
| `SelectTab(nameOrIndex)` | Select a tab by title or user-tab index; returns boolean. |
| `Show()`, `Hide()`, `Toggle(state)` | Show/hide; the key gate can prevent opening until passed. |
| `SetToggleKey(key)` | Accepts an `Enum.KeyCode` or its name; returns current key. |
| `SetToggleButtonPlatform("Both" or "Mobile")` | Controls availability of floating open button; other values normalize to Both. |
| `GetToggleButtonPlatform()` | Returns current setting. |
| `EditOpenButton(options)` | Edits floating button and returns its GUI object. |
| `Divider()`, `OpenUISettings()` | Add sidebar divider / select settings tab. |
| `Dialog(options)` | Show modal; returned dialog has `:Close()`. |
| `Destroy()` | Idempotent cleanup. Creating another xNgot window replaces this window. |

```lua
Window:SetToggleKey(Enum.KeyCode.RightShift)
Window:SetToggleButtonPlatform("Mobile")
Window:EditOpenButton({Title = "Open", Icon = "house", ShowText = true})
Window:Hide()
```

`EditOpenButton` also accepts `OpenIcon`, `Size`, `Position`, `BackgroundColor3`, `TextColor3`, `IconColor3`, `OpenIconColor3`, `CornerRadius`.

## Config persistence

| Method | Meaning |
| --- | --- |
| `GetConfigPath()` | Returns the resolved path based on `Folder` and `FileSaveName`. |
| `SaveConfig()` | Forces a write and includes current UI settings; returns success. |
| `DeleteConfig()` | Deletes the file if supported; returns success/error. It does not reset already-loaded in-memory controls. |
| `ForgetSavedKey()` | Available when a key gate sets it up; deletes saved key if supported. |

With `AutoSave = false`, automatic writes are disabled; explicit `SaveConfig()` still attempts a write. Saved data is local, not encrypted, and depends on executor filesystem functions. `DeleteConfig` does not delete downloaded music or the separately stored key.

## Appearance APIs

`SetUISettings(table, save)` starts from defaults and applies the supplied fields; it is **not** an incremental patch over all previous settings. Pass a complete settings table when preserving prior settings. `save = false` skips the corresponding save request.

```lua
local settings = Window:GetUISettings()
settings.AccentColor = Color3.fromRGB(0, 170, 255)
settings.Overrides = nil -- derive overrides from supplied fields
Window:SetUISettings(settings, true)
Window:SetUISize(580, 420, true)
print(Window:ExportUISettings())
```

Additional Settings-only helpers include `GetUILanguage`, `SetUILanguage` (currently English-only) and `RefreshAdminAvatar` (when the admin card is built). Other methods: `GetUIOverrides`, `ClearUIOverride(key, save)`, `GetUIPresets`, `ApplyUIPreset(name, save)`, `UseOriginalUI(save)`, `GetUISize`, `ResetUISize(save)`, `SaveUISettings`, `ImportUISettings(json, save)`, `ResetUISettings(save)`, `SaveUIProfile(name)`, `LoadUIProfile(name, save)`, `GetUIProfileNames`, `DeleteUIProfile(name)`. Profiles and exports use the current versioned format; legacy profiles can be rejected. Query `GetUIPresets()` rather than assuming names.

`SetUISize` clamps width to 420–1000 and height to 300–800. UI language is English-only in this build; methods under Settings such as `GetUILanguage` are not necessarily available with `SettingsUI = false`.
''',r'''# API cửa sổ và lưu trữ

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

`AutoSave = false` tắt ghi tự động; `SaveConfig()` vẫn chủ động thử ghi. Dữ liệu lưu local, không mã hóa, phụ thuộc API file của executor. `DeleteConfig` không xóa nhạc đã tải hay key được lưu riêng.

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
'''),
('island-reference','DETAILED REFERENCE','THAM KHẢO CHI TIẾT','Island API reference','API Dynamic Island','18',r'''# Dynamic Island API

Use `local island = Window:GetDynamicIsland()` and check `if island then ... end`. The bridge is created when `SettingsUI` is enabled and initialization succeeds. Display waits for the menu and startup/key gate. Calling `Enable(true)` does not bypass that gate.

## Display and activity

| Method | Behavior |
| --- | --- |
| `Notify(title, message, kind, duration)` | Island notice; returns `false` when disabled. |
| `GameplayActivity(title, message, duration, kind)` | Temporary activity, duration clamped to 3–30 seconds. |
| `Enable(boolean)` | Enable or hide the island. |
| `Expand(page)`, `Collapse()` | Open a page or close the expanded view. Common pages: `Home`, `Music`, `Cross`. |
| `Set("Fps" / "Ping" / "Clock", boolean)` | Toggle activity. Other existing Settings keys may be set by name. |
| `Theme(index)`, `Accent(index)` | Set palette/accent by numeric index, clamped. |
| `State()` | Table with `Cross`, `Playing`, `MusicIndex`, `FPS`, `Ping`, `Timer`, `Island`. |
| `Destroy()` | Shut down this island; use `Window:Destroy()` for full window cleanup. |

`Window:NotifyIsland(title, message, kind, duration)` and `Window:IslandActivity(title, message, duration, kind)` are safe bridge helpers that return false if the island is unavailable. Notice that the order of **kind and duration** differs between the two methods.

## Timers and stopwatch

```lua
local island = Window:GetDynamicIsland()
if island then
    island:Timer(120)       -- 1–86400 seconds
    island:ExtendTimer(30)
    island:StopTimer()
    island:WatchToggle()    -- start/pause
    island:WatchLap()
    island:WatchReset()
end
```

## Cross assistant

`AiEnable(boolean)`, `AiOpen()`, `AiAsk(text)`, `AiClear()` and `AiPermission(name, boolean)` control the local assistant. `Ui` and `Key` permissions can be configured; `Body` and `Free` are forced off by the implementation. `MusicAiLearn(title, good)` records feedback when supported; `DemoDownload()` displays simulated progress rather than downloading a real file. `MusicAiOnline(true)` does not enable an online model in this build; `MusicAiOnlineState()` reports removed/local. Do not assume it calls an external AI service.

`SetLanguage` / `Set("Language", ...)` currently force English. The documentation language switch is independent of the library UI language.
''',r'''# API Dynamic Island

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

`AiEnable(boolean)`, `AiOpen()`, `AiAsk(text)`, `AiClear()` và `AiPermission(name, boolean)` điều khiển trợ lý local. Có thể cấu hình quyền `Ui` và `Key`; `Body` và `Free` bị khóa tắt trong source. `MusicAiLearn(title, good)` ghi nhận phản hồi nếu engine hỗ trợ; `DemoDownload()` chỉ mô phỏng tiến trình, không tải file thật. `MusicAiOnline(true)` không bật AI online ở bản này; `MusicAiOnlineState()` báo removed/local. Không nên hiểu tính năng này là gọi một AI online.

`SetLanguage` / `Set("Language", ...)` hiện ép về tiếng Anh. Nút đổi ngôn ngữ tài liệu là độc lập với ngôn ngữ UI thư viện.
'''),
('music-reference','DETAILED REFERENCE','THAM KHẢO CHI TIẾT','Music API and settings','API và cấu hình nhạc','19',r'''# Music API and settings

Search and download depend on third-party services, network access and executor support. Audio playback may also be restricted by Roblox. No actual provider or Delta runtime is guaranteed by a Luau compiler check.

## Search and play

```lua
local island = Window:GetDynamicIsland()
if island then
    local disconnect = island:OnMusicCatalogChanged(function()
        local rows, state = island:MusicRows()
        print("Catalog state:", state, "rows:", #rows)
    end)
    island:MusicSearch("nhac viet chill")
    -- The search is asynchronous; call disconnect() when no longer needed.
end
```

`MusicSearch` returning `true` does not guarantee the search started (for example, it may already be busy) or that results are ready. Check `MusicSearchState()` or subscribe to catalog changes. Once results exist, `MusicRows()` returns `rows, state`; `MusicCatalog()` returns `catalog, state, supported`. `MusicSelectValue(value, play)` selects a result by row Value/name and returns a boolean. `MusicSelect(index, play)` uses the track index; avoid calling it for an empty list. `MusicPlayTrack(id, url, source)` queues/selects an external track and returns a boolean, not playback confirmation. `MusicDownloadOne` may yield and returns an asset string or `false`.

| Control | Meaning |
| --- | --- |
| `PlayMusic()` | Toggles play/pause, not an unconditional play. |
| `NextMusic(1)` / `NextMusic(-1)` | Next / previous. |
| `MusicVolume(n)` | Volume 0–100. |
| `MusicSpeed(n)` | Effective music tempo 0.7–1.4; the player applies its own clamp. |
| `MusicMode(name, boolean)` | `Auto`, `Shuffle`, `RepeatOne`, `ShowIsland`. |
| `OnMusicChanged(fn)` | Subscribe; returned function unsubscribes. |
| `MusicQueue(prompt)`, `MusicPreset(name)`, `MusicConfig()` | Helpers attached by Settings/Island integration when available. |

## Downloaded files

`MusicFiles(includeSizes)` returns `files, stats`; `MusicStorage()` returns stats. `MusicLoadDownloaded()` reloads the current catalog from local cache and returns a count. `MusicPlayFile(path)` returns whether a matching item was selected. `MusicDeleteFile(path)` and `MusicClearDownloaded()` delete local files; the latter returns deleted and failed counts. Ask before destructive actions.

```lua
if island then
    local files, stats = island:MusicFiles(true)
    print("Files:", #files, "storage:", stats.TotalText)
    if files[1] then island:MusicPlayFile(files[1].Path) end
end
```

## Configuration

Set before loading using `getgenv().xNgotMusic = {...}` or at runtime through `_G.xNgotMusicConfig:Set(key, value)`. `Get(key)`, `Get()`, `Schema()`, `Apply()`, `OnChange(fn)`, `Preset(name)`, `Presets()` are available. `OnChange` returns an unsubscribe function. Supported presets: `fast`, `quality`, `lowdata`, `vietnamese`.

| Key | Default | Range / note |
| --- | --- | --- |
| `topN` | 12 | 1–40 results |
| `sources` | youtube, soundcloud, audius | Table of source IDs; UI exposes All or one of these. Other engine sources depend on service support. |
| `region` | `auto` | `auto`, `global`, `VN`, `US`, `KR`, `JP`; preference via query terms, not verified language. |
| `prefetchNext` | true | At 50%, prepare next item from current list when Auto is on and RepeatOne off; needs >1 track. |
| `searchTimeout` | 12 | 2–60 seconds |
| `preferShort` | 600 | 0–7200 seconds; 0 disables preference |
| `folder` | `xNgotLibrary/Music` | Local cache directory |
| `raceTracks` | 2 | 1–4, parallel track attempts in resolve |
| `downloadTimeout` | 200 | 20–600 seconds |
| `retries` | 2 | 0–5 |
| `renameFiles`, `aiLearn`, `coverArt` | true | Boolean |
| `compactRows`, `debug` | false | Boolean |
| `showSource`, `notifyOnSearch` | true | Boolean |
| `aiBrain` | `local` | Online model is not enabled in this build. |

Region Auto uses Roblox country if available and locale as fallback; unsupported/unknown regions become global. Preload uses network and storage and cannot guarantee a gapless transition. Prefetch failure falls back to regular loading. Some settings are exposed in the schema even where their effect is limited by the current code; inspect behavior in your target environment.

For diagnostics call `_G.xNgotMusicDoctor()` when available, then inspect the returned checks. A warning is not proof of a particular fault. Test search, download, file support, `getcustomasset`/`getsynasset` and playback separately.
''',r'''# API và cấu hình nhạc

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
'''),
('loader-reference','DETAILED REFERENCE','THAM KHẢO CHI TIẾT','Loader and key lifecycle','Loader và vòng đời key','20',r'''# Loader and key lifecycle

## Configure startup

```lua
local Window = LIB:CreateWindow({
    Title = "My Hub", Icon = "sparkles",
    Loading = {Title = "My Hub", Text = "Starting", Steps = {"Prepare", "Almost ready"}, Duration = 2},
    KeySystem = {Enabled = true, Keys = {"DEMO-KEY"}, SaveKey = false},
})
```

When `KeySystem.Enabled = true` and `Style` is not `Legacy`, the embedded Ophyn flow handles the gate. The non-Ophyn/legacy loader uses `Loading.Title`, `Text`, `Steps` and `Duration`; its effective display can be longer than the configured duration. `Loading = false` disables the non-key loader, not an enabled key gate. Confirm which flow you are testing before expecting a particular animation.

## Ordering and saved keys

The window is constructed while startup proceeds, but the menu and island are held until the gate passes. Saved keys are rechecked. Closing the key UI without acceptance destroys the window. Use `SaveKey = false` or call `Window:ForgetSavedKey()` when available to retest input. Saving needs executor filesystem APIs.

## Providers and trust

Local values/functions are evaluated client-side and can be changed by the user. Providers require working network/request primitives and a properly configured service. PandaAuth and Jnkie load remote SDK code; Platoboost client-side secrets can be extracted. Multiple validators accept **any** successful validator. The code and SDK links can change externally; verify valid, invalid and network-failure cases with real credentials before release. Never hardcode a real secret into an example.

For UI overrides, use `KeySystem.Ophyn`, such as `SyncTheme = false`, `SyncFont = false`, `Theme`, `Logo`, `Title`, `Description`. The source integrates Ophyn; the exact set of supported options is the bundled vendor implementation, not a promise that all future upstream options work.
''',r'''# Loader và vòng đời key

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
'''),
('maintain','MAINTENANCE','BẢO TRÌ','Build, test and publish','Build, test và xuất bản','21',r'''# Build, test and publish

## Project layout

| Path | Purpose |
| --- | --- |
| `src/modules/` | Ordered Luau source modules, the source of truth for the library. |
| `src/manifest.json` | Module ordering, hashes and block metadata. |
| `src/profiles/`, `src/stubs/` | Development/release build profiles and replacement modules. |
| `src/build.py`, `src/minify.py` | Build and single/light/compact/full minification tools. |
| `dist/main.lua`, `dist/main.min.lua` | Generated release artifacts; include them in a repository or archive if needed. |
| `docs/site/content.py`, `details.py` | Bilingual content. |
| `docs/site/template.html` | Standalone HTML UI, inline CSS/JS/SVG. |
| `docs/site/build.py` | Builds HTML and Markdown manuals from the content. |
| `.github/workflows/pages.yml` | GitHub Actions Pages workflow. |

## Build commands

```bash
python3 src/build.py --check
python3 src/build.py --release --check
python3 src/build.py --release --minify light
python3 -m pip install -r docs/site/requirements.txt
python3 docs/site/build.py
```

The source manifest validates module hashes and block balance. Update its metadata when changing modules, rather than editing generated `dist` alone. Single is a one-line wrapper requiring loadstring; it reconstructs light source with newlines at runtime. Light keeps newlines directly; very long compact output can be problematic for older executors. A successful compile checks syntax/register limits, not actual Roblox behavior.

## Release checklist

1. Test startup, key success/failure, close/reopen and replacement of an existing xNgot window.
2. On mobile, test tap vs scroll, slider drag, releasing outside, dropdown, toggle and text input; also test desktop mouse.
3. Test music search and download against real services, local files, auto-next/prefetch and errors.
4. Review config save/read/delete and the executor APIs available on the target device.
5. Build both release artifacts; update the repo's `dist/` and `docs/`, commit and push. A local ZIP or Pages publication does not update the raw GitHub script by itself.
6. Enable GitHub Pages with GitHub Actions in repository settings and wait for a successful workflow. The expected Pages URL is `https://xngotzume123.github.io/xNgotLibrary/` only after publishing; GitHub's actual URL is authoritative.

For private or inaccessible repositories, local preview can still open `docs/index.html`. JS is required for the bilingual navigation. No external fonts, scripts or icons are needed for the site.
''',r'''# Build, test và xuất bản

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
''')
]
