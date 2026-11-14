# xNgot Library Library — Usage Guide

> For **script authors reusing the library**.
> Vietnamese version: [`LIBRARY.vi.md`](LIBRARY.vi.md) · Repo overview: [`../README.md`](../README.md)

The library ships five independent pieces:

| Block | What you get | Global |
|---|---|---|
| **UI** | Window, Tabs, 11 element types, Settings tab, KeySystem | `LIB` (returned value) |
| **Floating panel** | Floating control panel: notifications, activities, music, Cross AI, timers | `Window.DynamicIsland` |
| **Music engine** | Search / score / download from YouTube, SoundCloud, Audius | `_G.CrossAIMusic` |
| **Music config** | 16 schema-checked keys, 4 presets | `_G.xNgotMusicConfig` |
| **Log / debug** | `Log`, `DevTools`, `Debug` (release build swaps in stubs) | `_G.xNgotLog`, `_G.xNgotDevTools` |

---

## 1. Loading the library

### 1.1. Default mode (opens the xNgot Library hub)

```lua
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()
```

The stock **xNgot Library** window opens and `_G.Window` is created.

### 1.2. Library-only mode (recommended for your own hub)

Set the flag **before** loading:

```lua
getgenv().xNgotLibraryOnly = true

local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()
local Window = LIB:CreateWindow({ Title = "My Hub" })
```

In this mode:

- the stock hub does **not** open, there is **no** `_G.Window`;
- `LIB` is fully functional, you build your own window;
- the floating panel is only created when `SettingsUI = true` (the default);
- open the stock hub any time with `LIB.OpenXNgotHub()`.

### 1.3. Minified build

Same API, different URL — roughly 25% smaller:

```lua
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.min.lua"))()
```

### 1.4. Loading from a local file

```lua
local code = readfile("xNgotStudio.lua")
local LIB = loadstring(code)()
```

> Order matters: `loadstring` → call it → receive the `LIB` table. Forget the `()` and you
> hold a function, not the library.

---

## 2. Globals

| Name | Type | Available | Purpose |
|---|---|---|---|
| `LIB` | table | always | root API |
| `LIB.Version` | string | always | `"3.0.0"` |
| `LIB.OpenXNgotHub()` | function | always | open the stock hub |
| `LIB.ActiveDynamicIsland` | table? | after a window exists | live floating panel |
| `LIB.LastDynamicIslandError` | string? | when floating panel creation failed | error text |
| `LIB.ShowStartupError(err)` | function | always | show a startup error dialog |
| `_G.Window` | table? | default mode only | stock hub window |
| `_G.xNgotPanel` | function? | default mode | toggle the debug panel |
| `_G.xNgotLog` | table | always | see §11 |
| `_G.xNgotDevTools` | table | dev build | see §11 |
| `_G.xNgotDebug` | table | always | panel / log export |
| `_G.xNgotDebugBridge` | table | dev build | debug bridge |
| `_G.xNgotMusicConfig` | table | always | music config (§9) |
| `_G.CrossAIMusic` | table | always | music engine (§10) |
| `_G.Music` / `_G.xNgotMusicEngine` | table | always | engine aliases |
| `_G.xNgotMusicDoctor` | function | always | environment self-check |
| `_G.__xNgotEmbeddedLibrary` | table | always | `LIB` itself (used by the loader) |

`getgenv().xNgotStudio` is the stock hub's private handle — don't rely on it.

---

## 3. `LIB:CreateWindow(options)`

Returns a `Window` object. Every option is optional.

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
    Loading = { Text = "Loading", Duration = 1.4, Steps = { "UI", "Icons", "Done" } },
})
```

### 3.1. Options

| Option | Type | Default | Notes |
|---|---|---|---|
| `Title` | string | `"NgotStudio"` | window title, also used by the floating panel |
| `Icon` | string | `"layout-dashboard"` | icon name (§13) |
| `Version` | string | `"v1.0"` | shown next to the title |
| `Author` | string | `"v1.0"` | subtitle line |
| `Folder` | string | `"xNgotLibrary/Config"` | config folder |
| `Size` | UDim2 | `580×420` | initial size |
| `ToggleKey` | Enum.KeyCode | `RightShift` | show/hide hotkey |
| `ToggleButtonPlatform` | `"PC"`/`"Mobile"`/`"Both"` | `"Both"` | where the floating button appears |
| `LiveSearchDropdown` | boolean | `false` | filter while typing |
| `AutoSave` | boolean | `true` | persist `CONFIG` on change |
| `FileSaveName` | string | `"NgotStudio_Config.json"` | config file name |
| `SettingsUI` | boolean | `true` | **`false` ⇒ no Settings tab and no floating panel** |
| `SettingsTitle` / `SettingsIcon` | string | `"Settings Ui"` / `"settings"` | customise the Settings tab |
| `Loading` | table | `{Duration = 1.6}` | splash screen: `Text`, `Steps`, `Duration` |
| `KeySystem` | table / `false` | `false` | see 3.2 |
| `AdminInfo` | table / `false` | `false` | admin card: `{Name, Bio, Avatar}` |

### 3.2. KeySystem

```lua
KeySystem = {
    Enabled = true,
    Title = "Key System",
    Subtitle = "Enter your key",
    Note = "Get a key on Discord",
    Key = "XNGOT-2026",                 -- single key
    Keys = { "XNGOT-2026", "VIP-2026" },-- or several
    CaseSensitive = false,
    GetKey = "https://discord.gg/...",
    GetKeyUrl = "https://...",
    KeyFile = "xNgotLibrary/Keys/key.txt", -- remembered key
}
```

- A valid key is stored in `KeyFile` and reused next launch.
- `Window.KeyUnlocked` tells you whether the gate has been cleared.
- Forget it: `Window:ForgetSavedKey()` (deletes `KeyFile`).

> The gate also engages whenever `Loading` is set — the splash screen shares the same
> "startup gate" machinery.

---

## 4. The `Window` object

### 4.1. Properties

| Property | Type | Meaning |
|---|---|---|
| `Window.Title`, `.Icon`, `.Version` | string | copies of the options |
| `Window.DynamicIsland` | table? | this window's floating panel (`nil` when `SettingsUI = false`) |
| `Window.DynamicIslandError` | string? | floating panel creation error |
| `Window.Size` | UDim2 | current size |
| `Window.ToggleKey` | Enum.KeyCode | hotkey |
| `Window.ConfigPath` | string | config file path |
| `Window.KeySystem` | table? | key config |
| `Window.KeyUnlocked` | boolean | gate cleared |
| `Window.Visible` | boolean | window visible |

### 4.2. Visibility

| Call | Effect |
|---|---|
| `Window:Show()` / `Window:Hide()` / `Window:Toggle(state?)` | show / hide / flip |
| `Window:Destroy()` | close and clean up |
| `Window:SetToggleKey(Enum.KeyCode.X)` | change hotkey |
| `Window:SetToggleButtonPlatform("PC"\|"Mobile"\|"Both")` | change platform |
| `Window:GetToggleButtonPlatform()` | read it back |
| `Window:EditOpenButton({ Icon = "x", Size = UDim2.fromOffset(44,44) })` | restyle the floating button |

### 4.3. Tabs & content

| Call | Effect |
|---|---|
| `Window:Tab({ Title, Icon })` → `Tab` | create a tab |
| `Window:SelectTab("Main")` / `SelectTab(2)` | switch by name / index |
| `Window:Divider()` | separator in the current tab |
| `Window:Dialog({ Title, Content, Icon, Buttons })` | modal dialog (§5.10) |

### 4.4. Config

| Call | Effect |
|---|---|
| `Window:SaveConfig()` | write `CONFIG` to `ConfigPath` |
| `Window:DeleteConfig()` | delete the config file |
| `Window:GetConfigPath()` | config path |
| `Window:ForgetSavedKey()` | delete the remembered key |

### 4.5. UI settings

| Call | Effect |
|---|---|
| `Window:GetUISettings()` | current appearance settings |
| `Window:SetUISettings(tbl, save?)` | apply (accent, opacity, blur, font…) |
| `Window:GetUIOverrides()` / `ClearUIOverride(key, save?)` | overrides |
| `Window:SetUISize(w, h, save?)` / `GetUISize()` / `ResetUISize(save?)` | size |
| `Window:ApplyUIPreset("Default"\|...)` / `GetUIPresets()` | presets |
| `Window:UseOriginalUI(save?)` | restore the stock look |
| `Window:ExportUISettings()` / `ImportUISettings(json, save?)` | JSON export / import |
| `Window:SaveUISettings()` | save now |
| `Window:GetUIProfileNames()` / `SaveUIProfile(name)` / `LoadUIProfile(name, save?)` / `DeleteUIProfile(name)` | UI profiles |
| `Window:OpenUISettings()` | open the Settings tab |
| `Window:GetUILanguage()` / `SetUILanguage()` | UI language (this build: `"en"`) |
| `Window:RefreshAdminAvatar()` | reload the admin avatar |

```lua
Window:SetUISettings({ AccentColor = Color3.fromRGB(255, 55, 132), Enabled = true }, true)
```

### 4.6. floating panel bridges

| Call | Effect |
|---|---|
| `Window:GetDynamicIsland()` | floating panel API (or `nil`) |
| `Window:NotifyIsland(title, message, kind?, duration?)` | notification on the floating panel |
| `Window:IslandActivity(title, message, duration?, kind?)` | activity bar |

---

## 5. `Tab` and elements

### 5.1. Creating a tab

```lua
local Tab = Window:Tab({ Title = "Main", Icon = "house" })
```

- Each tab owns a `CONFIG[Title]` sub-table that stores element values.
- **Element `Title`s must be unique inside a tab** — duplicate titles mean duplicate keys.
- `Icon`: a icon name (§13).

### 5.2. Element conventions

1. Every element takes `Title`, `Desc`, `Locked` plus its own fields.
2. `Callback(value)` fires **once at creation** with the initial value, then on every change.
3. Every element returns an object with at least `:Destroy()`; most also have `:Set`,
   `:SetTitle`, `:SetDesc`, `:Lock`, `:Unlock`.
4. `Locked = true` renders the element but disables interaction.

### 5.3. `Tab:Section(data)`

| Field | Type | Default |
|---|---|---|
| `Title` | string | `"Section"` |
| `Default` | boolean | `false` (expanded or not) |
| `TextXAlignment` | Enum | `Left` |

```lua
local Sec = Tab:Section({ Title = "Basics", Default = true })
Sec:SetTitle("New")  Sec:SetOpen(true)  Sec:Toggle()  Sec:Destroy()
Sec:_Use("Button", { Title = "Button inside the section" })
```

### 5.4. `Tab:Toggle(data)`

| Field | Type | Default |
|---|---|---|
| `Title` / `Desc` / `Icon` | string | — |
| `Default` (or `Value`) | boolean | `false` |
| `Callback` | function(state) | — |

```lua
local esp = Tab:Toggle({ Title = "ESP", Default = false, Callback = print })
esp:Set(true)   -- updates UI and calls Callback
print(esp.State)
```

### 5.5. `Tab:Slider(data)`

| Field | Type | Notes |
|---|---|---|
| `Value = { Min, Max, Default }` | table | `Min` 0, `Max` 100 |
| `Default` | number | alternative to `Value.Default` |
| `Step` | number | default 1 |

```lua
local s = Tab:Slider({ Title = "Speed", Value = { Min = 16, Max = 200, Default = 50 }, Step = 2,
    Callback = function(v) getgenv().Speed = v end })
s:Set(100)
```

### 5.6. `Tab:Input(data)`

| Field | Type | Notes |
|---|---|---|
| `Placeholder` | string | hint text |
| `Default` / `Text` | string | initial value |
| `MultiLine` | boolean | textarea |
| `ClearTextOnFocus` | boolean | clear on focus |

```lua
local nick = Tab:Input({ Title = "Name", Placeholder = "Type…", Default = "xNgot" })
print(nick.Text)   nick:Set("New")   nick:SetPlaceholder("…")
```

### 5.7. `Tab:Dropdown(data)`

| Field | Type | Notes |
|---|---|---|
| `Values` | array | options |
| `Value` / `Default` | string / table | initial value |
| `Multi` | boolean | multi-select ⇒ Callback receives a **table** |
| `AllowNone` | boolean | adds a `"None"` entry |

```lua
local src = Tab:Dropdown({ Title = "Source", Values = { "youtube", "soundcloud" },
    Default = "youtube", Callback = print })
src:Refresh({ "a", "b", "c" })   src:Select("b")
```

### 5.8. `Tab:Colorpicker(data)`

```lua
local c = Tab:Colorpicker({ Title = "Accent", Default = Color3.fromRGB(10,132,255), Callback = print })
c:Set(Color3.new(1,0,0))   print(c:Get())
```

### 5.9. `Tab:Paragraph`, `Tab:Code`, `Tab:Button`

```lua
Tab:Paragraph({ Title = "About", Desc = "Descriptive text, RichText ok." })
local code = Tab:Code({ Title = "Example", Code = "print('hi')" }); code:SetCode("print(2)")
local btn = Tab:Button({ Title = "Run", Callback = function() end })
btn:SetTitle("Run again"); btn:Lock(); btn:Unlock()
```

### 5.10. `Window:Dialog(data)`

```lua
Window:Dialog({
    Title = "Confirm",
    Content = "Delete all settings?",
    Icon = "triangle-alert",
    Buttons = {
        { Title = "Cancel" },
        { Title = "Delete", Callback = function() Window:DeleteConfig() end },
    },
})
```

### 5.11. `Tab:InfoNguyenNhat(data)` / `Tab:Discord(data)`

```lua
Tab:InfoNguyenNhat({ Title = "Author", Name = "xNgot", Bio = "…", Avatar = 1234567890 })
Tab:Discord({ Title = "Discord", InviteCode = "abcd1234" })
```

`Info`: `SetName`, `SetBio`, `SetAvatar(id)` · `Discord`: `SetInvite(link, code)`.

---

## 6. Config persistence (`CONFIG`)

- Tab = `CONFIG["<tab title>"]`; element = `CONFIG["<tab>"]["<element Title>"]`.
- Stored values win over `Default` when the element is created.
- `AutoSave = true` writes (debounced) on every change.
- Renaming an element `Title` loses its saved value.
- Manual access: `Window:SaveConfig()`, `Window:GetConfigPath()` then
  `HttpService:JSONDecode(readfile(path))`.

---

## 7. `LIB:Notify(data)`

Card-style notification. When the floating panel is enabled it is routed to the floating panel unless
`Native = true`.

| Field | Type | Default | Notes |
|---|---|---|---|
| `Title` | string | `"Notification"` | |
| `Content` | string | `""` | |
| `Icon` | string | `"info"` | `"circle-check"`/`"check"` ⇒ success, `"triangle-alert"` ⇒ warn |
| `Kind` | `"info"`/`"success"`/`"warn"`/`"error"` | `"info"` | |
| `Duration` | number (s) | `5` | minimum `0.1` |
| `Native` | boolean | `false` | `true` ⇒ always the on-screen card |

```lua
local n = LIB:Notify({ Title = "Done", Content = "Saved", Kind = "success", Duration = 4 })
n.Close()
```

---

## 8. Floating panel API

```lua
local Island = Window:GetDynamicIsland()
if Island then Island:Notify("Title", "Body", "info", 4) end
```

`nil` when `SettingsUI = false` or floating panel creation failed (see `Window.DynamicIslandError`).

### 8.1. Notifications & activity

| Call | Effect |
|---|---|
| `Island:Notify(title, message, kind?, duration?)` | notification on the floating panel; returns `false` when disabled |
| `Island:GameplayActivity(title, message, duration?, kind?)` | timed activity bar |
| `Island:Enable(bool)` | enable / disable |
| `Island:Set(key, value)` | change a setting (§8.5) |
| `Island:State()` | `{ Cross, Playing, MusicIndex, FPS, Ping, Timer, Island }` |

### 8.2. Expand / collapse

| Call | Effect |
|---|---|
| `Island:Expand(page?)` | expand; `page` = `"Home"`, `"Music"`, `"Cross"`, `"Timer"`, `"Stopwatch"`, `"Download"` |
| `Island:Collapse()` | back to the compact bar |
| `Island:Theme(n)` / `Island:Accent(n)` | palette (1–7) / accent (1–6) |
| `Island:SetLanguage(lang)` | `"vi"` / `"en"` |

### 8.3. Timers

| Call | Effect |
|---|---|
| `Island:Timer(seconds)` | countdown (1–86400) |
| `Island:StopTimer()` / `Island:ExtendTimer(seconds)` | stop / add time |
| `Island:WatchToggle()` / `WatchLap()` / `WatchReset()` | stopwatch |

### 8.4. Music

| Call | Effect |
|---|---|
| `Island:MusicSearch(prompt)` | natural-language search (`"chill lofi for the evening"`) |
| `Island:MusicSearchState()` | current search state |
| `Island:MusicRows()` | result rows |
| `Island:MusicSelectValue(value, play?)` | select a row by its `value` |
| `Island:MusicSelect(index, play?)` | select by index |
| `Island:MusicCatalog()` / `OnMusicCatalogChanged(fn)` | catalog + listener |
| `Island:OnMusicChanged(fn)` | track/state listener |
| `Island:PlayMusic()` / `NextMusic(n?)` | play-pause / next (± n) |
| `Island:MusicVolume(0–100)` / `MusicSpeed(0.5–2)` | volume / tempo |
| `Island:MusicMode("Auto"\|"Shuffle"\|"RepeatOne"\|"ShowIsland", bool)` | playback modes |
| `Island:MusicFiles(includeSizes?)` → `files, stats` | downloaded files |
| `Island:MusicStorage()` → `stats` | cache size |
| `Island:MusicPlayFile(path)` / `MusicDeleteFile(path)` / `MusicClearDownloaded()` | file ops |
| `Island:MusicPlayTrack(id, url, source)` / `MusicDownloadOne(id, url, source)` | play / download directly |
| `Island:MusicLoadDownloaded()` | load the downloaded list |
| `Island:MusicAiLearn(title, good)` | teach the AI a like/dislike |
| `Island:DemoDownload()` | demo download animation |

### 8.5. Cross AI

| Call | Effect |
|---|---|
| `Island:AiEnable(bool)` | enable / disable |
| `Island:AiAsk(prompt)` | ask (understands Vietnamese and English) |
| `Island:AiOpen()` | open the Cross page |
| `Island:AiClear()` | clear the conversation |
| `Island:AiPermission(name, bool)` | `name` ∈ `Ui`, `Body`, `Free`, `Key` |
| `Island:MusicAiOnline(bool)` / `MusicAiOnlineState()` | online AI mode |

### 8.6. floating panel settings (`Island:Set`)

Common keys: `Language`, `Theme`, `Accent`, `Duration`, `Ring`, `RimLight`, `Fps`, `Ping`,
`Clock`, `Expand`, `ShowIsland`, `Toast`, `Bubble`…

```lua
Island:Set("Duration", 6)   -- notifications last 6s
Island:Set("Ring", false)   -- disable the progress ring (lighter)
Island:Set("Fps", true)     -- show FPS on the compact bar
```

### 8.7. Events & teardown

```lua
Island:OnMusicChanged(function(state) print("track changed", state) end)
Island:Destroy()
```

---

## 9. Music config `_G.xNgotMusicConfig`

```lua
local cfg = _G.xNgotMusicConfig
cfg:Set("topN", 15)
print(cfg:Get("topN"))
```

| Call | Effect |
|---|---|
| `Get(key)` | read |
| `Set(key, value)` | write (schema-checked, applied to the engine) |
| `Schema()` | full schema |
| `Apply()` | push everything to the engine |
| `OnChange(fn)` | listen |
| `Preset(name)` → `ok, err` | apply a preset |
| `Presets()` | list presets |

### 9.1. The 16 keys

| Key | Type | Default | Meaning |
|---|---|---|---|
| `topN` | number 1–40 | `12` | number of results |
| `sources` | table | `{youtube,soundcloud,audius}` | sources |
| `searchTimeout` | number 2–60 | `12` | seconds per search |
| `preferShort` | number 0–7200 | `600` | prefer tracks ≤ N seconds (0 = off) |
| `folder` | string | `"xNgotLibrary/Music"` | mp3 cache folder |
| `raceTracks` | number 1–4 | `2` | parallel downloads |
| `downloadTimeout` | number 20–600 | `200` | conversion timeout |
| `retries` | number 0–5 | `2` | retry count |
| `renameFiles` | boolean | `true` | name files after the track |
| `aiBrain` | string | `"local"` | AI brain (offline) |
| `aiLearn` | boolean | `true` | learn from skips |
| `coverArt` | boolean | `true` | show cover art |
| `compactRows` | boolean | `false` | one-line track cards |
| `showSource` | boolean | `true` | show source badge |
| `notifyOnSearch` | boolean | `true` | notify when a search ends |
| `debug` | boolean | `false` | console logging |

### 9.2. Presets

| Preset | Effect |
|---|---|
| `fast` | `raceTracks 2`, `topN 8`, `searchTimeout 8`, YouTube + Audius |
| `quality` | sequential, `topN 20`, `searchTimeout 20`, all three sources |
| `lowdata` | `topN 6`, YouTube only, covers off |
| `vietnamese` | SoundCloud first, `topN 15`, `preferShort 420` |

```lua
_G.xNgotMusicConfig:Preset("lowdata")
```

---

## 10. Music engine `_G.CrossAIMusic`

| Group | Functions |
|---|---|
| **Parse** | `parse(prompt)` → plan, `durationSeconds(text)`, `normalizeRow(row, src)`, `queryVariants(plan, prompt)` |
| **Search & score** | `search(plan, callback, prompt)`, `score(track, plan)`, `learn(title, good)` |
| **Download** | `download(url, onProgress)`, `fetchFile(key, urls, onProgress, title)`, `resolve(prompt, onState)`, `assetFor(track, onProgress)` |
| **Files** | `listDownloaded(sizes?)`, `downloadedStats(sizes?)`, `deleteDownloaded(path)`, `clearDownloaded()`, `saveBytes(key, data, title)` |
| **Metadata** | `readDownloadedMeta(path)`, `writeDownloadedMeta(path, meta)`, `renameFiles(bool)`, `isRenameEnabled()` |
| **Covers** | `thumbAsset(track)`, `coverAsset(track)`, `prefetchCovers(list, onOne)` |
| **Rows** | `rowLabel(track, i)`, `rowValue(track, i)`, `rowData(track, i)`, `enrich(track)` |
| **PoW / HTTP** | `request(url, method, headers, body, timeout)`, `getPowToken()` |
| **LLM (optional)** | `llmAvailable()`, `llmEnabled()`, `llmSetEnabled(bool)`, `llmStatus()`, `llmPlan(prompt, plan)`, `llmSay(prompt, ctx)`, `applyLlmPlan(plan, extra)` |

```lua
local plan = _G.CrossAIMusic.parse("chill lofi for the evening")
_G.CrossAIMusic.search(plan, function(state, rows)
    for i, row in ipairs(rows or {}) do print(i, row.Title, row.Source) end
end, "chill lofi for the evening")
```

### 10.1. Self-check

```lua
local report = _G.xNgotMusicDoctor()
-- report.items: { { name = "writefile", status = "ok"|"fail"|"warn", detail = "..." }, ... }
-- report.fails, report.warns, report.ok
```

Checks `writefile/readfile/isfile/makefolder/listfiles/getcustomasset`, `request`, engine,
parser, PoW-SHA256, config, floating panel API.

---

## 11. Log, Debug, DevTools

```lua
_G.xNgotLog.info("tag", "message", { extra = 1 })   -- levels: trace debug info warn error
_G.xNgotLog:filter("warn")
_G.xNgotLog:export()
_G.xNgotLog.clear()
```

| Object | Main functions |
|---|---|
| `Log` (`_G.xNgotLog`) | `add`, `trace/debug/info/warn/error`, `filter`, `tags`, `stats`, `countsByTag`, `export`, `download`, `onEntry`, `hookConsole`, `measure`, `apiCall`, `clear`, `level`, `format` |
| `DevTools` (`_G.xNgotDevTools`) | `note`, `vars`, `executors`, `run(code)`, `add`, `check`, `selftest`, `report` |
| `Debug` (`_G.xNgotDebug`) | `getLogPanel()`, `exportLog()`, `openPanel()`, `closePanel()`, `toggle()`, `report()`, `mode()` |

> `--release` swaps `DevTools`, the HTTP hook, the bridge and the panel for empty stubs:
> `_G.xNgotLog` still works, `_G.xNgotDevTools` exists but `selftest()` returns
> `{ passed = 0, skipped = true }`.

---

## 12. Loader flags

| Flag / variable | Effect |
|---|---|
| `getgenv().xNgotLibraryOnly = true` | don't open the stock hub |
| `getgenv().xNgotMusic = { topN = 10, ... }` | music config before the engine boots |
| `getgenv().xNgotLoaderConfig` | loader options (`localFile`, `remoteUrl`, `title`…) |
| `__xNgotBoot.start()` | boot the stock hub manually |
| `__xNgotBoot.performance()` / `lowPower(bool)` | runtime stats / low-power mode |
| `__xNgotBoot.Stage` | `"ready"` once booted |

The loader tries sources in order: **embedded library → local file (`main.lua`) → remote
URL**, until a window is created.

---

## 13. Icons

`Icon = "<name>"` uses icon names, e.g.:

```
house · music-2 · sparkles · settings · bell · search · download · trash-2 · play · pause
skip-forward · skip-back · volume-2 · clock · timer · activity · cpu · wifi · user · key
shield · layout-dashboard · wrench · info · circle-check · triangle-alert · sliders-horizontal
```

The full set (1,548 icons) lives in `src/modules/50_lucide/040_icons_*.lua`.
A wrong name is harmless — the icon simply doesn't render.

---

## 14. Complete examples

### 14.1. Minimal hub

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "Demo", Icon = "music-2", Author = "v1.0" })
local Tab = Window:Tab({ Title = "Main", Icon = "house" })

Tab:Section({ Title = "Basics", Default = true })
Tab:Toggle({ Title = "Enabled", Default = true, Callback = print })
Tab:Slider({ Title = "Speed", Value = { Min = 16, Max = 200, Default = 50 }, Callback = print })
Tab:Button({ Title = "Notify", Callback = function()
    LIB:Notify({ Title = "Hello", Content = "from the library", Kind = "success" })
end })
```

### 14.2. Hub + floating panel + music

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()
local Window = LIB:CreateWindow({ Title = "Music Hub", Icon = "sparkles", SettingsUI = true })
local Island = Window:GetDynamicIsland()

local Tab = Window:Tab({ Title = "Music", Icon = "music-2" })
Tab:Section({ Title = "Search", Default = true })

local q = Tab:Input({ Title = "Prompt", Default = "chill lofi for the evening" })
Tab:Button({ Title = "Search", Callback = function()
    Island:MusicSearch(q.Text)
    Island:Expand("Music")
end })
Tab:Button({ Title = "Play / pause", Callback = function() Island:PlayMusic() end })
Tab:Slider({ Title = "Volume", Value = { Min = 0, Max = 100, Default = 60 },
    Callback = function(v) Island:MusicVolume(v) end })
Tab:Button({ Title = "Cache", Callback = function()
    local s = Island:MusicStorage()
    LIB:Notify({ Title = "Cache", Content = string.format("%d files · %s", s.Count or 0, tostring(s.TotalText)) })
end })
```

---

## 15. FAQ

| Question | Answer |
|---|---|
| No floating panel? | `SettingsUI = false` means no floating panel. Re-create the window with it enabled. |
| `Window.DynamicIsland` is `nil`? | Check `Window.DynamicIslandError`; usually a GUI build failure. |
| Elements overwrite each other? | `CONFIG[tab][Title]` — keep titles unique per tab. |
| Does `Callback` run at creation? | Yes, once, with the initial value. Don't assume it's only user input. |
| Change colours / fonts globally? | `Window:SetUISettings{...}` or `Window:ApplyUIPreset("...")`. |
| Silence search notifications? | `_G.xNgotMusicConfig:Set("notifyOnSearch", false)` |
| Low-end device? | `_G.xNgotMusicConfig:Preset("lowdata")` + `Island:Set("Ring", false)` |
| Several windows at once? | Fine — each `CreateWindow` returns its own object; the floating panel belongs to the newest. |
| `attempt to index nil` on `Island:` | You didn't check for `nil`. Always `if Island then ... end`. |
| Music doesn't play? | Run `_G.xNgotMusicDoctor()` and look for `fail` entries. |
