"""Practical bilingual control guides, checked against src/modules/40_window."""
setup='''getgenv().xNgotLibraryOnly = true
local chunk, err = loadstring(readfile("main.lua"))
assert(chunk, err)
local LIB = chunk()
local Window = LIB:CreateWindow({
    Title = "Control examples", Folder = "ControlExamples",
    FileSaveName = "settings.json", AutoSave = true,
    SettingsUI = true, Loading = false,
})
local Tab = Window:Tab({ Title = "Main", Icon = "house" })
Window:SelectTab("Main")'''
intro_en='''# Control guides: start here

Each control page has a small **addition**, not a separate script. First paste and run this setup together with one or more examples on the following pages. Put the current `main.lua` in the executor workspace. `readfile` and `loadstring` are required.

```lua
%s
```

## Before you begin

- `Tab:Section()` changes the parent used by *subsequently created* controls; create another section to switch. `Section:_Use("Button", {...})` explicitly targets a section. Destroying the current section resets the parent to the tab.
- Toggle, Slider, Input, Dropdown and Colorpicker invoke their callback while being created, with the initial or restored value. Create dependencies before these controls; do not refer to a local that is still being assigned from its own constructor.
- Saved values are indexed by tab title and the control's original title, not by `Flag`. Use unique titles per tab. Renaming a control later does not migrate its saved key. `AutoSave` and filesystem support affect persistence; see Window & storage.
- `Lock()` blocks interaction; programmatic setters can still update values and trigger callbacks. `Destroy()` removes the visual control.
- Mobile retains its original dimensions. Drag sliders horizontally; vertical gestures are treated as scrolling. Actual executor behavior still needs Roblox testing.
''' % setup
intro_vi='''# Hướng dẫn control: bắt đầu tại đây

Mỗi trang control là một **đoạn nối thêm**, không phải script riêng. Hãy ghép đoạn khởi tạo dưới đây với một hoặc nhiều ví dụ ở các trang tiếp theo rồi chạy. Đặt `main.lua` mới trong workspace của executor; cần `readfile` và `loadstring`.

```lua
%s
```

## Trước khi tạo control

- `Tab:Section()` đổi vùng chứa cho các control tạo **sau đó**; tạo section khác để đổi vùng. `Section:_Use("Button", {...})` chỉ định vùng chứa cụ thể. Xóa section hiện tại sẽ đưa vùng chứa về tab.
- Toggle, Slider, Input, Dropdown và Colorpicker gọi callback ngay khi tạo, với giá trị mặc định hoặc đã khôi phục. Hãy tạo đối tượng phụ thuộc trước; đừng dùng biến local đang được gán từ chính constructor của nó bên trong callback.
- Giá trị lưu theo tên tab và **Title ban đầu** của control, không theo `Flag`. Đặt Title duy nhất trong mỗi tab. Đổi tên sau đó không tự chuyển key lưu. `AutoSave` và API file ảnh hưởng việc lưu; xem mục Window & storage.
- `Lock()` khóa tương tác người dùng; setter bằng code vẫn có thể cập nhật và gọi callback. `Destroy()` xóa control khỏi giao diện.
- Mobile giữ kích thước gốc. Kéo slider theo chiều ngang; vuốt dọc dùng để cuộn. Vẫn cần test thực tế trong Roblox/executor.
''' % setup
# title, English introduction, Vietnamese introduction, options (name/type/default/en/vi), methods, example, extra en, extra vi
pages=[
('section','Section','Group controls in a collapsible area.','Nhóm control trong một vùng có thể thu gọn.',[
('Title','string','Section','Heading','Tiêu đề'),('Default','boolean','false','Initially open','Mở sẵn'),('TextXAlignment','string','Left','Left, Center or Right','Left, Center hoặc Right')],
'`SetTitle(text)`, `SetOpen(boolean)` (returns state), `Toggle()` (returns state), `Destroy()`, `_Use(methodName, options)`', '''local group = Tab:Section({ Title = "Actions", Default = true })
Tab:Button({ Title = "Inside Actions", Callback = function() print("Pressed") end })
group:SetOpen(true)
-- group:_Use("Toggle", { Title = "Extra", Callback = function(v) print(v) end })''',
'Later `Tab` controls go into the most recently created section, not automatically back to the tab. `_Use` does not permanently change that parent.', 'Control tạo sau qua `Tab` nằm trong section mới nhất, không tự quay về tab. `_Use` không đổi vùng chứa mặc định lâu dài.'),
('button','Button','Execute an action on activation.','Thực hiện hành động khi nhấn.',[
('Title','string','Button','Label','Nhãn'),('Desc','string','nil','Optional description','Mô tả tùy chọn'),('Locked','boolean','false','Disable user activation','Khóa tương tác'),('Callback','function()','no-op','Runs when pressed','Chạy khi nhấn')],
'`SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`', '''local button = Tab:Button({
    Title = "Say hello", Desc = "Run an action",
    Callback = function() print("Hello!") end,
})
-- button:Lock()  -- button:Unlock()''','The callback receives no arguments.','Callback không nhận tham số.'),
('toggle','Toggle','Turn a feature on or off.','Bật hoặc tắt một tính năng.',[
('Title','string','Toggle','Label and original storage key','Nhãn và key lưu ban đầu'),('Desc','string','nil','Optional description','Mô tả tùy chọn'),('Default / Value','boolean','false','Initial state; prefer Default alone','Trạng thái đầu; nên chỉ dùng Default'),('Icon','string','nil','Optional icon name','Tên icon tùy chọn'),('Locked','boolean','false','Disable interaction','Khóa tương tác'),('Callback','function(boolean)','no-op','Receives new state','Nhận trạng thái mới')],
'`Set(boolean)` or `Set()` to invert, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`', '''local toggle = Tab:Toggle({
    Title = "Auto action", Desc = "Example switch", Default = false, Icon = "zap",
    Callback = function(enabled) print("Auto action:", enabled) end,
})
toggle:Set(true)
-- toggle:Set() -- invert''','The callback runs at creation and after Set. A saved state can override Default. Avoid supplying both Default=false and Value=true: the source fallback expression can choose Value.', 'Callback chạy khi tạo và sau Set; trạng thái đã lưu có thể ghi đè Default. Tránh truyền đồng thời Default=false và Value=true vì biểu thức fallback có thể chọn Value.'),
('slider','Slider','Choose a number in a range.','Chọn số trong một khoảng.',[
('Title / Desc','string','Slider / nil','Label and description','Nhãn và mô tả'),('Value.Min / Max','number','0 / 100','Range bounds','Giới hạn khoảng'),('Value.Default','number','Min','Initial number; top-level Default also supported','Giá trị đầu; cũng hỗ trợ Default ở ngoài'),('Step','number','1','Positive step for updates','Bước dương khi thay đổi'),('Locked','boolean','false','Disable interaction','Khóa tương tác'),('Callback','function(number)','no-op','Receives number','Nhận số')],
'`Set(number)`, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`', '''local slider = Tab:Slider({
    Title = "Speed", Value = { Min = 0, Max = 100, Default = 25 }, Step = 5,
    Callback = function(value) print("Speed:", value) end,
})
slider:Set(40)''','Values are clamped; invalid/non-positive Step falls back to 1. Callback also runs on creation and Set.', 'Giá trị được giới hạn trong khoảng; Step không hợp lệ hoặc không dương trở về 1. Callback cũng chạy khi tạo và Set.'),
('input','Input','Accept text, optionally multiline.','Nhận văn bản, có thể nhiều dòng.',[
('Title / Desc','string','Input / nil','Label and description','Nhãn và mô tả'),('Placeholder','string','empty','Hint in text box','Gợi ý trong ô nhập'),('Default / Value','string','empty','Initial text','Nội dung ban đầu'),('ClearTextOnFocus','boolean','false','Clear when focused','Xóa khi focus'),('MultiLine','boolean','false','Allow multiple lines','Cho phép nhiều dòng'),('Locked','boolean','false','Disable interaction','Khóa tương tác'),('Callback','function(string)','no-op','Receives text','Nhận chuỗi')],
'`Set(text)`, `SetTitle(text)`, `SetDesc(text)`, `SetPlaceholder(text)`, `Lock()`, `Unlock()`, `Destroy()`', '''local input = Tab:Input({
    Title = "Nickname", Placeholder = "Enter a name", Default = "Guest",
    Callback = function(text) print("Nickname:", text) end,
})
input:Set("Player")''','Callback runs at creation, on focus loss and after Set; it is not an every-keystroke callback.','Callback chạy khi tạo, khi mất focus và sau Set; không chạy theo từng ký tự.'),
('dropdown','Dropdown','Pick one or multiple options.','Chọn một hoặc nhiều mục.',[
('Title / Desc','string','Dropdown / nil','Label and description','Nhãn và mô tả'),('Values','array of strings','{}','Available items','Danh sách lựa chọn'),('Value / Default','string or array','nil','Initial selection','Lựa chọn ban đầu'),('Multi','boolean','false','Allow multiple selections','Cho phép chọn nhiều'),('AllowNone','boolean','false','Allow no selection','Cho phép không chọn'),('Locked','boolean','false','Disable interaction','Khóa tương tác'),('Callback','function(value)','no-op','Single: string or nil; multi: array','Một mục: string hoặc nil; nhiều mục: mảng')],
'`Select(value)` (returns selected value or nil), `Refresh(values)` (returns selection), `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`', '''local mode = Tab:Dropdown({
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
-- mode:Refresh({"Normal", "Fast", "Slow"})''','Callback runs on creation and Select. For multi-select, Select toggles each named item rather than replacing the entire selection. Single AllowNone represents None as an empty string in callbacks; multi receives an array. Refresh resets the selection and saves it but does not call Callback. With multi and AllowNone=false, the first option is used if no initial selection exists.', 'Callback chạy khi tạo và Select. Với multi, Select đảo trạng thái từng mục được truyền, không thay toàn bộ lựa chọn. Một lựa chọn với AllowNone biểu diễn None bằng chuỗi rỗng trong callback; multi nhận mảng. Refresh đặt lại lựa chọn và lưu nhưng không gọi Callback. Multi với AllowNone=false chọn mục đầu nếu ban đầu chưa chọn.'),
('colorpicker','Colorpicker','Pick and observe a Color3 value.','Chọn màu và nhận giá trị Color3.',[
('Title / Desc','string','Color / empty','Label and description','Nhãn và mô tả'),('Default / Value','Color3, hex string or RGB table','white','Initial color','Màu ban đầu'),('Locked','boolean','false','Disable interaction','Khóa tương tác'),('Callback','function(Color3)','no-op','Receives Color3','Nhận Color3')],
'`Set(value)`, `Get()` → Color3, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`', '''local color = Tab:Colorpicker({
    Title = "Accent example", Default = "#66AAFF",
    Callback = function(value) print("Color:", value) end,
})
color:Set(Color3.fromRGB(255, 120, 80))
print(color:Get())''','Accepts Color3, `#RRGGBB`, or an RGB table. Invalid input falls back to white. Callback runs on creation and Set; this example does not change the global UI theme.', 'Nhận Color3, `#RRGGBB` hoặc bảng RGB. Đầu vào không hợp lệ trở về trắng. Callback chạy khi tạo và Set; ví dụ này không tự đổi theme toàn UI.'),
('paragraph','Paragraph','Display a title and descriptive text.','Hiển thị tiêu đề và nội dung.',[
('Title','string','Paragraph','Heading','Tiêu đề'),('Desc','string','nil','Body','Nội dung'),('RichText','boolean','false','Interpret Roblox RichText tags','Cho phép tag Roblox RichText')],
'`SetTitle(text)`, `SetDesc(text)`, `Destroy()`', '''local status = Tab:Paragraph({ Title = "Status", Desc = "Ready" })
status:SetDesc("Running")''','This is a display element, not a persistent value control.','Đây là phần hiển thị, không phải control lưu giá trị.'),
('code','Code','Show a code block in the window.','Hiển thị khối code trong cửa sổ.',[
('Title','string','Code','Heading','Tiêu đề'),('Code','string','empty','Code content','Nội dung code')],
'`SetTitle(text)`, `SetCode(text)`, `Destroy()`', '''local code = Tab:Code({ Title = "Example", Code = 'print("Hello")' })
code:SetCode('print("Updated")')''','Displays text; it does not execute that text.','Chỉ hiển thị văn bản; không thực thi đoạn đó.'),
('community','Discord & InfoNguyenNhat','Display community and profile cards.','Hiển thị thẻ cộng đồng và hồ sơ.',[
('Discord.Avatar','string','rbxassetid://0','Avatar asset','Asset avatar'),('Discord.Name / Desc','string','Discord Server / empty','Server text','Tên và mô tả server'),('Discord.InviteLink / InviteCode','string','discord.gg/xxxxxxx / nil','Invite URL and optional code','Link mời và code tùy chọn'),('Info.Avatar / Name / Bio','string','rbxassetid://0 / Nguyen Nhat / empty','Profile fields','Thông tin hồ sơ'),('Info.Badges','table','{}','Badge list','Danh sách badge')],
'Discord: `SetInvite(link, code)`, `Destroy()`. Info: `SetAvatar(id)`, `SetName(text)`, `SetBio(text)`, `Destroy()`, `Info.AddSocialIcon(icon, copyValue, order)` (dot call).', '''local discord = Tab:Discord({ Name = "Community", Desc = "Join us", InviteLink = "discord.gg/example" })
local info = Tab:InfoNguyenNhat({ Name = "Developer", Bio = "Building a hub" })
info:SetBio("Welcome!")
-- discord:SetInvite("discord.gg/example", "example")''','Invite and avatar/network behavior depends on the executor and live services; placeholders are not real invites.','Hoạt động của invite, avatar và mạng phụ thuộc executor/dịch vụ; ví dụ link chỉ là placeholder.')]
sections_controls=[('controls-start','CONTROLS','CONTROL','Control guides: start here','Control: bắt đầu tại đây','22',intro_en,intro_vi)]
for i,(slug,title,en,vi,opts,methods,example,extra_en,extra_vi) in enumerate(pages,23):
 def render(lang):
  v=lang=='vi'; rows='\n'.join(f'| `{key}` | {typ} | `{default}` | {desc_vi if v else desc_en} |' for key,typ,default,desc_en,desc_vi in opts)
  return f'''# {title}\n\n{vi if v else en}\n\n{'Trước tiên xem trang **Control: bắt đầu tại đây**; thêm đoạn này bên dưới phần khởi tạo.' if v else 'First see **Control guides: start here**; append this snippet below the setup.'}\n\n```lua\n{example}\n```\n\n## {'Tùy chọn' if v else 'Options'}\n\n| {'Tên' if v else 'Name'} | {'Kiểu' if v else 'Type'} | {'Mặc định' if v else 'Default'} | {'Ý nghĩa' if v else 'Meaning'} |\n| --- | --- | --- | --- |\n{rows}\n\n## {'Đối tượng trả về' if v else 'Returned object'}\n\n{methods}\n\n## {'Lưu ý' if v else 'Notes'}\n\n{extra_vi if v else extra_en}\n'''
 sections_controls.append(('control-'+slug,'CONTROLS','CONTROL',title,title,str(i),render('en'),render('vi')))
