sections = [
 ('start','START HERE','BẮT ĐẦU','Introduction','Giới thiệu','01',r'''# Your interface, made simpler.

xNgot Library is a Roblox UI library for building script hubs: windows, controls, saved settings, notifications and a built-in Dynamic Island. This guide covers the **local build from this workspace**, including the integrated Ophyn key screen.

> **Version note:** These pages describe the updated test build. The GitHub `main` branch and raw download URL may still serve an older build until you upload the updated files.

## What you can build

- **A complete hub** with tabs, toggles, sliders, inputs and dialogs.
- **A key gate** with local keys, PandaAuth, Jnkie, Platoboost or a custom validator.
- **A floating companion** for notifications, timers and music.
- **A personal look** with UI presets, colors, fonts and saved profiles.

## Your first steps

1. Load the local `main.lua` and create a window.
2. Add a tab and some controls.
3. Configure a key system only if your hub needs one.
4. Use the floating panel and theme APIs as needed.

> **Client-side security:** local keys and any secrets embedded in a client script can be extracted. Use a trusted server-side design for real authorization.
''',r'''# Một giao diện, vô vàn ý tưởng.

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
'''),
 ('install','START HERE','BẮT ĐẦU','Installation','Cài đặt','02',r'''# Installation

Place the updated `main.lua` in your executor's workspace. Test that `readfile` and `loadstring` are supported. Downloading into the device's Downloads folder does not automatically put the file in the executor workspace.

## Load from a local file

```lua
getgenv().xNgotLibraryOnly = true

local source = readfile("main.lua")
local chunk, err = loadstring(source)
assert(chunk, err)
local LIB = chunk()
```

Set `xNgotLibraryOnly` **before** loading to get the library without opening the demo. Without it, the file normally starts the demo. Keep the final `()` when using `loadstring(readfile(...))()`.

## Load from GitHub

After updating `dist/main.lua` in your repository, your raw URL can be used:

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"
))()
```

> The raw URL points to what is actually published on GitHub, not the local test file. It will not contain these changes until that file is committed and pushed.

## Build from source

```bash
python3 src/build.py --release --minify
```

This produces `dist/main.lua` and one-line-after-credit `dist/main.min.lua`. The one-line wrapper requires `loadstring` and reconstructs light minified source at runtime; use `main.min.light.lua` from the release ZIP or rebuild with `--minify light` if needed. Successful compiler checks do not replace Roblox testing.
''',r'''# Cài đặt

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
'''),
 ('window','BUILD A HUB','TẠO HUB','Windows & tabs','Cửa sổ và tab','03',r'''# Windows & tabs

Create a window from the library, then add a tab. The example assumes `LIB` has already been loaded in library-only mode.

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
Main:Button({ Title = "Hello", Callback = function()
    print("Hello from xNgot")
end })
```

## Window options

| Option | Description |
| --- | --- |
| `Title`, `Icon`, `Version` | Window title, icon name and version text. `Author` takes precedence over `Version`. |
| `Size`, `ToggleKey` | Initial size and keyboard shortcut. |
| `Folder`, `FileSaveName`, `AutoSave` | Configuration location and autosave behavior. |
| `SettingsUI` | Defaults to `true`; `false` removes Settings and the integrated island. |
| `Loading` | Loader configuration; `false` disables it when no key gate is enabled. |
| `KeySystem` | Key gate settings; see the key system section. |
| `AdminInfo` | Custom author information, or `false` to disable it. |

## Control the window

```lua
Window:SelectTab("Main")
Window:Hide()
Window:Show()
Window:Toggle()
Window:SetToggleKey(Enum.KeyCode.RightShift)
-- Window:Destroy() -- closes and cleans up
```

Creating another xNgot window replaces the previous active xNgot window, even if the title differs. Its window, island, key screen and associated connections are cleaned up; unrelated game interfaces are not intentionally removed.

The window and island are held until the key screen completes. If the user closes the key screen before authentication, the window is destroyed rather than unlocked.
''',r'''# Cửa sổ và tab

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
'''),
 ('controls','BUILD A HUB','TẠO HUB','UI components','Thành phần UI','04',r'''# UI components

On touch devices, controls retain their original visual size while touch handling reduces accidental taps. Slider taps and horizontal drags adjust the value; vertical swipes are treated as scrolling. Single-select dropdowns close after a touch selection, while multi-select stays open. The selection highlight indicates the selected value, not a stuck press.

Add elements to a tab using `Tab:Button`, `Tab:Toggle`, `Tab:Slider`, `Tab:Input`, `Tab:Dropdown`, `Tab:Colorpicker`, `Tab:Section`, `Tab:Paragraph`, `Tab:Code`, `Tab:Discord` and `Tab:InfoNguyenNhat`.

## Buttons and text

```lua
Main:Section({ Title = "General", Default = true })
Main:Paragraph({ Title = "Welcome", Desc = "Choose an option below." })
Main:Button({ Title = "Refresh", Callback = function()
    print("Refresh")
end })
local sample = Main:Code({ Title = "Example", Code = "print('hello')" })
sample:SetCode("print('updated')")
```

## State controls

```lua
local toggle = Main:Toggle({
    Title = "Enabled", Default = false,
    Callback = function(on) print("Enabled:", on) end,
})
local slider = Main:Slider({
    Title = "Speed", Value = { Min = 1, Max = 100, Default = 25 }, Step = 1,
    Callback = function(value) print(value) end,
})
local input = Main:Input({ Title = "Name", Placeholder = "Type a name" })
toggle:Set(true)
slider:Set(50)
input:Set("xNgot")
```

> Toggle, slider, input, dropdown and color-picker callbacks can run during creation with an initial or saved value. Do not assume callbacks only run after a click.

## Dropdown and color

```lua
local menu = Main:Dropdown({
    Title = "Mode", Values = { "Default", "Fast", "Quiet" }, Value = "Default",
    Callback = function(value) print(value) end,
})
menu:Refresh({ "Default", "Fast", "Quiet" })
menu:Select("Fast")

Main:Colorpicker({
    Title = "Accent", Default = Color3.fromRGB(10, 135, 213),
    Callback = function(color) print(color) end,
})
```

Use distinct element titles within each tab: titles are used as configuration keys. `Multi = true` enables a multi-select dropdown; `AllowNone = true` permits no selection. Many controls also expose `:SetTitle`, `:SetDesc`, `:Lock`, `:Unlock` and `:Destroy`; check the specific component before relying on a method.
''',r'''# Thành phần UI

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
'''),
 ('feedback','BUILD A HUB','TẠO HUB','Notifications & dialogs','Thông báo và hộp thoại','05',r'''# Notifications & dialogs

Use `LIB:Notify` for feedback or `Window:Dialog` when a choice is required.

```lua
LIB:Notify({
    Title = "Saved", Content = "Your settings are ready.",
    Kind = "success", Icon = "circle-check", Duration = 4,
})

Window:Dialog({
    Title = "Reset settings?", Content = "This will delete the saved configuration.",
    Icon = "triangle-alert",
    Buttons = {
        { Title = "Cancel" },
        { Title = "Reset", Callback = function() Window:DeleteConfig() end },
    },
})
```

`Kind` supports `info`, `success`, `warn` and `error` for island notifications. `Native = true` requests the regular notification instead of routing to an enabled island. A native notification can be closed with the returned object's `:Close()`.
''',r'''# Thông báo và hộp thoại

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
'''),
 ('key-overview','KEY SYSTEM','KEY SYSTEM','How it works','Cách hoạt động','06',r'''# Key system

The updated build embeds the Ophyn interface and adapters. Enable the gate via `KeySystem` in `LIB:CreateWindow`, or use `getgenv().xNgotLoaderConfig.keySystem` for the bundled demo. Its colors, font, rounded corners and window icon follow saved xNgot UI settings by default.

## Supported modes

| Mode | Configuration |
| --- | --- |
| Local | `Key = "..."` or `Keys = { "...", "..." }` |
| PandaAuth | `API = { { Type = "panda", ServiceId = "..." } }` |
| Jnkie | `API = { { Type = "jnkie", Service = "...", Identifier = "..." } }` |
| Platoboost | `API = { { Type = "platoboost", ServiceId = 123, Secret = "..." } }` |
| Custom | `Key = function(key) ... end` or an `API` entry with `Type = "custom"` |
| Keyless | `Keyless = { enabled = true }` |

When multiple validators are configured, **any one** can accept the key. Avoid leaving a demo local key alongside a production provider unless a fallback is intentional. If no key/provider is configured, the gate does not silently accept an example key.

## Key options

`Enabled`, `Key` / `Keys`, `CaseSensitive`, `SaveKey`, `KeyFile`, `URL` / `GetKeyUrl`, `API`, `GetMethods`, `Keyless`, and `Ophyn` are supported. Saved keys are checked again before access. `Style = "Legacy"` selects the older xNgot gate; it only supports local keys.

> Provider adapters and the key UI are integrated, but live provider authentication has not been tested without account credentials. PandaAuth and Jnkie download and execute their respective SDKs at runtime.
''',r'''# Key system

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
'''),
 ('key-local','KEY SYSTEM','KEY SYSTEM','Local keys & keyless','Key local và keyless','07',r'''# Local keys & keyless

## Basic local key

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

Local keys default to case-insensitive matching. Provider keys are passed to the provider unchanged. `SaveKey = false` is useful for testing the screen each time.

```lua
print(Window.KeyUnlocked)
Window:ForgetSavedKey()
```

For the bundled demo, the default key is `XNGOT-2026`. A previously saved key may automatically be checked; configure `SaveKey = false` to test manual entry.

## Keyless mode

```lua
KeySystem = {
    Enabled = true,
    Keyless = { enabled = true, showcard = true, autoconfirm = false },
}
```

`autoconfirm = true` continues automatically. Keyless intentionally skips validation; it does not provide access control.
''',r'''# Key local và keyless

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
'''),
 ('providers','KEY SYSTEM','KEY SYSTEM','Provider setup','Cấu hình provider','08',r'''# Provider setup

These are `KeySystem` tables. Replace sample values with the exact values from your provider dashboard. Do not add demo local keys unless you want them accepted too.

## PandaAuth

```lua
KeySystem = {
    Enabled = true, SaveKey = true,
    API = { { Type = "panda", ServiceId = "YOUR_SERVICE_ID" } },
}
```

## Jnkie

```lua
KeySystem = {
    Enabled = true, SaveKey = true,
    API = { { Type = "jnkie", Service = "SERVICE_NAME",
              Identifier = "USER_IDENTIFIER", Provider = "Mixed" } },
}
```

## Platoboost

```lua
KeySystem = {
    Enabled = true, SaveKey = true,
    API = { { Type = "platoboost", ServiceId = 12345, Secret = "YOUR_SECRET" } },
}
```

> A client script is not a safe place to store a secret. Provider reachability, SDK compatibility and request support depend on the executor and provider. Check both successful and rejected keys with a real test service before release.
''',r'''# Cấu hình provider

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
'''),
 ('key-custom','KEY SYSTEM','KEY SYSTEM','Custom & appearance','Custom và giao diện','09',r'''# Custom & appearance

A custom adapter receives the entered key and a context containing the entry's fields plus `ctx.Request` when available.

```lua
KeySystem = {
    Enabled = true,
    API = {{
        Type = "custom", ServiceId = "my-service",
        CheckKey = function(key, ctx)
            if key == "demo" then return true end
            return false, "Invalid key"
        end,
        GetKeyLink = function(ctx)
            return "https://example.com/get-key"
        end,
    }},
}
```

The example is intentionally local, not a secure server validator. A simpler `Key = function(key) return true_or_false, reason end` is also supported.

## Customize the gate

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

`Ophyn` options are forwarded to the embedded interface. Set `SyncTheme = false` and choose `Theme` for a separate Ophyn palette; `SyncFont = false` uses its original font. Explicit `ChangeTheme = true` allows the user to switch away from the synchronized palette. A custom `Logo` overrides the window icon.
''',r'''# Custom và giao diện

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
'''),
 ('island','EXPLORE','KHÁM PHÁ','Dynamic Island','Dynamic Island','10',r'''# Dynamic Island

The integrated island is available when `SettingsUI` is enabled. Guard against `nil` when it is disabled or could not initialize.

```lua
local Island = Window:GetDynamicIsland()
if Island then
    Island:Notify("Welcome", "Your hub is ready", "success", 4)
    Island:GameplayActivity("Working", "Processing", 5, "info")
    Island:Expand("Music")
end
```

## Timer and display

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

Other methods include `Collapse`, `WatchLap`, `WatchReset`, `Theme`, `Accent` and `State`. The Settings UI dashboard shows distinct FPS and ping histories, server actions and Job ID. The island remains hidden until the key screen and menu initialization finish.

The current UI language implementation is English-only; `SetLanguage` does not currently switch the interface to Vietnamese.
''',r'''# Dynamic Island

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
'''),
 ('music','EXPLORE','KHÁM PHÁ','Music & configuration','Nhạc và cấu hình','11',r'''# Music & configuration

The built-in music engine supports searching and managing downloaded tracks through the island. Availability depends on network access, supported executor APIs and the external services.

```lua
local Island = Window:GetDynamicIsland()
if Island then
    Island:MusicSearch("lofi chill")
    Island:Expand("Music")
    Island:MusicVolume(65)
end
```

Search runs asynchronously; after results appear, choose a track in the player or use `MusicSelectValue`. `PlayMusic()` toggles the current track and does not wait for search results.

## Presets

```lua
_G.xNgotMusicConfig:Preset("lowdata")
_G.xNgotMusicConfig:Set("topN", 8)
print(_G.xNgotMusicConfig:Get("topN"))
```

Use **Music region** and **Music platform** in the island settings. Auto region uses Roblox country when available, then its locale; choose Global to disable regional preference. Vietnam, United States, Korea and Japan are supported. This adds regional search terms, so results are not a verified country/language filter. Platforms in the UI are YouTube, SoundCloud and Audius; search and downloads depend on external services.

With Auto play, the player randomly selects an eligible track it has not recently played. For a searched/assistant track, it prefers candidates matching the current query. When those are exhausted it can search online for related results, then falls back to an eligible older track; if none is suitable, it stops. Repeat One takes priority; manual Next and Previous retain their controls. Matching uses title/artist/genre text heuristics and may reject a valid song or accept a wrong one—review search results, and refine your query when needed. The search first tries the unmodified query, with regional terms as additional variants.

With **Preload next track** and Auto enabled, an eligible unplayed item from the current list can be downloaded/preloaded at 50%. If preparation fails or is incomplete, normal loading is used; gapless playback is not guaranteed. Online searches and preloads use network and storage. The search filters weakly related results rather than automatically downloading them; source-qualified cache keys prevent collisions, but providers can still return the wrong audio. Previously cached files remain available in the downloaded list. Region detection does not use a third-party IP lookup.

```lua
_G.xNgotMusicConfig:Set("region", "VN") -- auto, global, VN, US, KR, JP
_G.xNgotMusicConfig:Set("sources", {"youtube"}) -- or soundcloud, audius
_G.xNgotMusicConfig:Set("prefetchNext", true)
```

Available presets: `fast`, `quality`, `lowdata`, `vietnamese`. Other island methods include `MusicCatalog`, `MusicRows`, `MusicSelect`, `MusicSelectValue`, `NextMusic`, `MusicSpeed`, `MusicFiles`, `MusicPlayFile`, `MusicDeleteFile` and `MusicClearDownloaded`.

## Diagnose support

```lua
local report = _G.xNgotMusicDoctor()
for _, check in ipairs(report.checks) do
    print(check.status, check.name, check.detail)
end
```

The doctor is a diagnostic hint, not proof that a feature works: executor globals and network behavior vary. Check each reported item and test playback directly.
''',r'''# Nhạc và cấu hình

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
'''),
 ('appearance','EXPLORE','KHÁM PHÁ','Appearance & storage','Giao diện và lưu trữ','12',r'''# Appearance & storage

Users can adjust appearance in Settings UI, or your script can control the theme and profiles.

```lua
Window:SetUISettings({
    AccentColor = Color3.fromRGB(10, 135, 213),
    CornerRadius = 12,
}, true)
Window:ApplyUIPreset("Midnight", true)
Window:SaveUIProfile("My theme")
```

Use `GetUISettings`, `GetUIPresets`, `UseOriginalUI`, `ExportUISettings`, `ImportUISettings`, `LoadUIProfile` and `DeleteUIProfile` to manage appearance. The gate reads saved xNgot theme settings when it starts; selecting an independent Ophyn theme can override that synchronization.

## Configuration files

```lua
print(Window:GetConfigPath())
Window:SaveConfig()
-- Window:DeleteConfig() -- deletes saved UI/component settings
```

The configuration is grouped by tab and component titles. Changing a title changes the associated key. Saving depends on executor file APIs; the key file is separate from the window configuration.
''',r'''# Giao diện và lưu trữ

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
'''),
 ('troubleshoot','REFERENCE','THAM KHẢO','Troubleshooting','Xử lý sự cố','13',r'''# Troubleshooting

## `failed to read file`

Check the file is in the executor's **workspace**, not only the device Downloads folder. The name in `readfile("main.lua")` must match exactly, including the extension.

## `Out of local registers ... limit 200`

This is a compile-time error, so in-script debug UI cannot run. Use the updated build, which was checked with an older 200-register Luau compiler. If it persists, capture the exact error and file name.

## The menu or key screen does not appear

- Check `xNgotLibraryOnly`: when `true`, load the library and call `LIB:CreateWindow(...)` yourself.
- A saved key may auto-validate. Set `SaveKey = false` to test manual entry.
- The key screen may wait for assets; the integrated build includes a preload timeout.
- If the user closes the gate before validation, the window is closed.
- Verify that the executor can create UI and load Roblox assets; share any debug log.

## A provider rejects a key

Check service identifiers, provider status, internet access and executor HTTP support. Test a known valid and invalid key. Provider authentication has not been verified with your account by this documentation build.

## Music does not play

Run `_G.xNgotMusicDoctor()` and inspect `checks`; also test file access, custom assets and the actual playback flow. A warning alone does not identify the cause.
''',r'''# Xử lý sự cố

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
'''),
 ('reference','REFERENCE','THAM KHẢO','API reference','Tham khảo API','14',r'''# API reference

A compact index of the most useful entry points in this build.

## Library and window

| API | Purpose |
| --- | --- |
| `LIB:CreateWindow(options)` | Create a window. |
| `LIB:Notify(options)` | Show a notification. |
| `Window:Tab(options)` | Add a tab. |
| `Window:Show()`, `Hide()`, `Toggle()` | Control visibility. |
| `Window:SelectTab(name)` | Select a tab. |
| `Window:Dialog(options)` | Show a dialog. |
| `Window:GetDynamicIsland()` | Return the island API or `nil`. |
| `Window:SaveConfig()`, `DeleteConfig()`, `GetConfigPath()` | Manage configuration. |
| `Window:ForgetSavedKey()` | Remove a saved gate key when supported. |
| `Window:Destroy()` | Destroy the window. |

## Components

`Section`, `Button`, `Toggle`, `Slider`, `Input`, `Dropdown`, `Colorpicker`, `Paragraph`, `Code`, `Discord` and `InfoNguyenNhat` are created on a tab. Use icon names such as `house`, `sparkles`, `music-2`, `key-round`, `settings` or `triangle-alert`.

## Important globals

| Global | Use |
| --- | --- |
| `getgenv().xNgotLibraryOnly` | Skip automatic demo startup. |
| `getgenv().xNgotLoaderConfig` | Override bundled demo loader settings before loading. |
| `_G.xNgotMusicConfig` | Music config API. |
| `_G.xNgotMusicDoctor()` | Return music diagnostics. |
| `_G.xNgotStudio` | Demo boot state, when started. |

## Credits

xNgot Library: Nguyễn Minh Nhật (xNgot Zume). Key-system interface and engine: [Ophyn UI](https://github.com/snowdevlol/OphynUI). Window UI originates from [Wind UI](https://github.com/Footagesus/WindUI).
''',r'''# Tham khảo API

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
''')
]

from details import sections_detail
sections.extend(sections_detail)
from controls import sections_controls
sections.extend(sections_controls)
from ai_guide import sections_ai
sections.extend(sections_ai)
from learning_guide import sections_learning
sections.extend(sections_learning)
