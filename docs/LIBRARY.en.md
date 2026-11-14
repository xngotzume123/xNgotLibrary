# xNgot Library — User Manual

> For people **using this library to build a hub / menu for a Roblox script**.
> Vietnamese version: [`LIBRARY.vi.md`](LIBRARY.vi.md) · Overview & support: [`../README.md`](../README.md)

You don't need advanced Lua. All you do is pass **tables** — the library takes care of drawing,
dragging, resizing, effects, saving settings, notifications and music.

---

## 1. Start in 30 seconds

```lua
local LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "My Hub", Icon = "sparkles" })
local Tab = Window:Tab({ Title = "Main", Icon = "house" })

Tab:Button({ Title = "Say hi", Callback = function()
    LIB:Notify({ Title = "Hello", Content = "The library is running", Kind = "success" })
end })
```

Run it and you have a window. Read on when you need more.

---

## 2. Loading the library

### 2.1. Usual way

```lua
local LIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()
```

It opens a **demo window** so you can see the look. As soon as you call `LIB:CreateWindow`
yourself, the demo window closes itself.

### 2.2. Library only — nothing opens on its own

Set the flag **before** loading:

```lua
getgenv().xNgotLibraryOnly = true

local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()
local Window = LIB:CreateWindow({ Title = "My Hub" })
```

No demo window, no `_G.Window` — just `LIB` for you to use.

### 2.3. Lighter build

Swap `dist/main.lua` for `dist/main.min.lua`. About 25% smaller, identical API.

### 2.4. Load from a local file (offline)

```lua
local LIB = loadstring(readfile("xNgotLibrary.lua"))()
```

> Keep the trailing `()`. Without it you're holding a *function*, not the library.

---

## 3. Creating a window

```lua
local Window = LIB:CreateWindow({
    Title = "My Hub",              -- window title (also the name on the floating panel)
    Icon = "sparkles",             -- icon next to the title
    Version = "v1.0.0",            -- small text next to the title
    Size = UDim2.fromOffset(620, 440),
    ToggleKey = Enum.KeyCode.RightShift,
})
```

Every field is optional — defaults are used when omitted.

| Field | Type | Default | Meaning |
|---|---|---|---|
| `Title` | string | `"NgotStudio"` | window title |
| `Icon` | string | `"layout-dashboard"` | icon name (section 14) |
| `Version` | string | `"v1.0"` | text beside the title |
| `Author` | string | `"v1.0"` | subtitle line |
| `Folder` | string | `"xNgotLibrary/Config"` | where settings are stored |
| `Size` | UDim2 | `580×420` | initial size |
| `ToggleKey` | Enum.KeyCode | `RightShift` | show / hide hotkey |
| `ToggleButtonPlatform` | `"PC"` / `"Mobile"` / `"Both"` | `"Both"` | which devices show the floating button |
| `LiveSearchDropdown` | boolean | `false` | filter dropdowns while typing |
| `AutoSave` | boolean | `true` | save on every change |
| `FileSaveName` | string | `"NgotStudio_Config.json"` | settings file name |
| `SettingsUI` | boolean | `true` | `false` = **no Settings tab and no floating panel** |
| `SettingsTitle` / `SettingsIcon` | string | `"Settings Ui"` / `"settings"` | rename the settings tab |
| `Loading` | table | — | loading screen: `Text`, `Steps` (list), `Duration` (seconds) |
| `KeySystem` | table / `false` | `false` | key gate — see section 4 |
| `AdminInfo` | table / `false` | `false` | author card: `{ Name, Bio, Avatar }` |

---

## 4. Locking the window with a key

```lua
KeySystem = {
    Enabled = true,
    Title = "Enter key",
    Subtitle = "Get your key on Discord",
    Note = "Contact the author for a key",
    Keys = { "XNGOT-2026", "VIP-2026" },   -- multiple keys allowed
    CaseSensitive = false,
    GetKeyUrl = "https://discord.gg/...",  -- "Get key" button
}
```

- A correct key is remembered in `xNgotLibrary/Keys/key.txt` — next launch goes straight in.
- `Window.KeyUnlocked` tells you whether the gate has been passed.
- Ask again next time: `Window:ForgetSavedKey()`.

---

## 5. Tabs and elements

### 5.1. Create a tab

```lua
local Tab = Window:Tab({ Title = "Main", Icon = "house" })
```

- A tab's `Title` is the **settings group name** — renaming a tab loses that tab's saved values.
- Inside **one tab**, element `Title`s must be **unique** (duplicates overwrite each other).

### 5.2. Common rules

1. Every element takes a `data` table: `Title`, `Desc`, `Locked` plus its own fields.
2. `Callback` fires **once at creation** (with the initial value), then on every change.
   Don't assume it only runs when the user clicks.
3. Elements return an object with `:Destroy()`, usually also `:Set`, `:SetTitle`, `:SetDesc`,
   `:Lock`, `:Unlock`.
4. `Locked = true` ⇒ visible but not clickable (soft lock).

### 5.3. Group box — `Section`

```lua
local Sec = Tab:Section({ Title = "Basics", Default = true })
Sec:SetTitle("New")   Sec:SetOpen(true)   Sec:Toggle()   Sec:Destroy()
```

| Field | Type | Default |
|---|---|---|
| `Title` | string | `"Section"` |
| `Default` | boolean | `false` (open by default?) |
| `TextXAlignment` | Enum | `Left` |

### 5.4. Switch — `Toggle`

```lua
local esp = Tab:Toggle({
    Title = "ESP",
    Desc = "Draw player boxes",
    Default = false,
    Callback = function(on) print("ESP:", on) end,
})

esp:Set(true)     -- change from code (fires Callback)
print(esp.State)  -- read state
```

### 5.5. Slider — `Slider`

```lua
local s = Tab:Slider({
    Title = "Speed",
    Value = { Min = 16, Max = 200, Default = 50 },
    Step = 2,
    Callback = function(v) getgenv().Speed = v end,
})
s:Set(100)
```

### 5.6. Text box — `Input`

```lua
local nick = Tab:Input({ Title = "Name", Placeholder = "Type a name…", Default = "xNgot" })
print(nick.Text)
nick:Set("New")   nick:SetPlaceholder("…")
```

| Field | Type | Note |
|---|---|---|
| `Placeholder` | string | grey hint text |
| `Default` / `Text` | string | initial value |
| `MultiLine` | boolean | multi-line box |
| `ClearTextOnFocus` | boolean | clear on click |

### 5.7. Select list — `Dropdown`

```lua
local src = Tab:Dropdown({
    Title = "Music source",
    Values = { "youtube", "soundcloud", "audius" },
    Default = "youtube",
    Callback = function(v) print("picked:", v) end,
})
src:Refresh({ "a", "b", "c" })
src:Select("b")

-- multi-select: Callback receives a table
local tags = Tab:Dropdown({
    Title = "Genres", Multi = true, AllowNone = true,
    Values = { "lofi", "jazz", "chill" }, Default = { "lofi" },
    Callback = function(list) print(#list .. " selected") end,
})
```

### 5.8. Colour picker — `Colorpicker`

```lua
local c = Tab:Colorpicker({
    Title = "Accent",
    Default = Color3.fromRGB(10, 132, 255),
    Callback = function(color) print(color) end,
})
c:Set(Color3.new(1, 0, 0))
print(c:Get())
```

### 5.9. Paragraph, code block, button

```lua
Tab:Paragraph({ Title = "About", Desc = "RichText is supported." })

local code = Tab:Code({ Title = "Example", Code = "print('hello')" })
code:SetCode("print(2)")

local btn = Tab:Button({ Title = "Run", Desc = "click to run", Callback = function() end })
btn:SetTitle("Run again")   btn:Lock()   btn:Unlock()
```

### 5.10. Dialog — `Window:Dialog`

```lua
Window:Dialog({
    Title = "Confirm",
    Content = "Delete all settings?",
    Icon = "triangle-alert",
    Buttons = {
        { Title = "Cancel" },                                     -- no Callback = just closes
        { Title = "Delete", Callback = function() Window:DeleteConfig() end },
    },
})
```

### 5.11. Author card and Discord

```lua
Tab:InfoNguyenNhat({ Title = "Author", Name = "xNgot", Bio = "…", Avatar = 1234567890 })
Tab:Discord({ Title = "Discord", InviteCode = "abcd1234" })
```

`Info`: `SetName`, `SetBio`, `SetAvatar(id)` · `Discord`: `SetInvite(link, code)`.

---

## 6. Notifications — `LIB:Notify`

```lua
local n = LIB:Notify({
    Title = "Saved",
    Content = "Your settings were written to disk",
    Kind = "success",     -- info / success / warn / error
    Duration = 4,
})
n.Close()                 -- close early
```

| Field | Default | Note |
|---|---|---|
| `Title` | `"Notification"` | |
| `Content` | `""` | |
| `Kind` | `"info"` | info · success · warn · error |
| `Icon` | `"info"` | `circle-check` ⇒ success, `triangle-alert` ⇒ warn |
| `Duration` | `5` | seconds, minimum `0.1` |
| `Native` | `false` | `true` = always use the corner card |

When the floating panel is on, notifications appear **on the panel** to keep the screen clean.

---

## 7. Settings are saved for you

- Each tab is a group; each element is an entry inside it.
- On the next run, **saved** values win over `Default`.
- `AutoSave = true` ⇒ everything is written as the user changes it.
- Renaming an element's `Title` loses that element's saved value (the key follows the name).

Manual control:

```lua
Window:SaveConfig()
print(Window:GetConfigPath())
Window:DeleteConfig()
```

---

## 8. Floating panel

The floating panel is the small bar on screen (notifications, music, timer, AI assistant).
It exists **only when `SettingsUI = true`** (the default).

```lua
local Island = Window:GetDynamicIsland()      -- nil when there is no panel
if Island then
    Island:Notify("Title", "Message", "info", 4)
end
```

> Function names stay `GetDynamicIsland` / `DynamicIsland` exactly as in the original release so
> existing scripts keep working. These docs simply call it the **floating panel**.

### 8.1. Notifications and activity

| Function | Does |
|---|---|
| `Island:Notify(title, message, kind?, duration?)` | notification on the panel |
| `Island:GameplayActivity(title, message, duration?, kind?)` | activity bar with a countdown |
| `Island:Enable(true/false)` | turn the panel on / off |
| `Island:Set(key, value)` | change a setting (see 8.6) |
| `Island:State()` | current state table |

### 8.2. Expand / collapse

| Function | Does |
|---|---|
| `Island:Expand(page?)` | `"Home"`, `"Music"`, `"Cross"`, `"Timer"`, `"Stopwatch"`, `"Download"` |
| `Island:Collapse()` | back to the compact bar |
| `Island:Theme(1–7)` / `Island:Accent(1–6)` | palette / accent colour |
| `Island:SetLanguage("vi" / "en")` | panel language |

### 8.3. Timer and stopwatch

```lua
Island:Timer(300)        -- 5 minutes
Island:ExtendTimer(60)
Island:StopTimer()

Island:WatchToggle()  Island:WatchLap()  Island:WatchReset()
```

### 8.4. Music

```lua
Island:MusicSearch("lofi chill for the evening")
Island:Expand("Music")
Island:MusicSelect(1, true)      -- pick the first result and play
Island:PlayMusic()
Island:NextMusic(1)
Island:MusicVolume(65)
Island:MusicSpeed(1.0)
```

| Group | Functions |
|---|---|
| Search | `MusicSearch(prompt)`, `MusicSearchState()`, `MusicRows()` |
| Picking | `MusicSelectValue(value, play?)`, `MusicSelect(index, play?)`, `MusicCatalog()` |
| Playback | `PlayMusic()`, `NextMusic(n?)`, `MusicPlayTrack(id, url, source)` |
| Audio | `MusicVolume(0–100)`, `MusicSpeed(0.5–2)`, `MusicMode("Auto"/"Shuffle"/"RepeatOne"/"ShowIsland", bool)` |
| Downloaded files | `MusicFiles(sizes?)`, `MusicStorage()`, `MusicPlayFile(path)`, `MusicDeleteFile(path)`, `MusicClearDownloaded()`, `MusicLoadDownloaded()` |
| Direct download | `MusicDownloadOne(id, url, source)`, `DemoDownload()` |
| Taste learning | `MusicAiLearn(title, good)` |
| Events | `OnMusicChanged(fn)`, `OnMusicCatalogChanged(fn)` |

### 8.5. AI assistant

```lua
Island:AiEnable(true)
Island:AiAsk("open the music page")   -- understands Vietnamese and English
Island:AiOpen()
Island:AiClear()
Island:AiPermission("Ui", true)       -- Ui / Body / Free / Key
```

### 8.6. Panel settings — `Island:Set`

```lua
Island:Set("Duration", 6)    -- notifications stay 6s
Island:Set("Ring", false)    -- disable progress ring (lighter)
Island:Set("Fps", true)
Island:Set("Clock", true)
```

Common keys: `Language`, `Theme`, `Accent`, `Duration`, `Ring`, `RimLight`, `Fps`, `Ping`,
`Clock`, `Expand`, `ShowIsland`, `Toast`, `Bubble`.

### 8.7. Removing the panel

```lua
Island:Destroy()
```

---

## 9. Music settings — `_G.xNgotMusicConfig`

```lua
_G.xNgotMusicConfig:Set("topN", 15)
print(_G.xNgotMusicConfig:Get("topN"))
```

| Function | Does |
|---|---|
| `Get(key)` / `Set(key, value)` | read / write one key |
| `Preset(name)` | apply a preset (9.2) |
| `Presets()` | list presets |
| `Apply()` | push everything to the engine |
| `OnChange(fn)` | listen for changes |
| `Schema()` | every key with its allowed range |

### 9.1. Main keys

| Key | Default | Meaning |
|---|---|---|
| `topN` | `12` | results per search (1–40) |
| `sources` | youtube, soundcloud, audius | sources to search |
| `searchTimeout` | `12` | max seconds per search |
| `preferShort` | `600` | prefer tracks shorter than N seconds (0 = off) |
| `folder` | `xNgotLibrary/Music` | download folder |
| `raceTracks` | `2` | parallel downloads |
| `downloadTimeout` | `200` | seconds to wait for a download |
| `retries` | `2` | retry count |
| `renameFiles` | `true` | name files after the track |
| `aiLearn` | `true` | learn from skipped tracks |
| `coverArt` | `true` | show cover art |
| `compactRows` | `false` | single-line track rows |
| `notifyOnSearch` | `true` | notify when a search finishes |
| `debug` | `false` | verbose logging |

### 9.2. Presets

| Preset | Best for |
|---|---|
| `fast` | slow networks, want results quickly |
| `quality` | strong device, more choices, best quality |
| `lowdata` | mobile data / weak device, fewer results, no cover art |
| `vietnamese` | Vietnamese music (SoundCloud first) |

```lua
_G.xNgotMusicConfig:Preset("lowdata")
```

---

## 10. Appearance

Users can change everything in the **Settings Ui** tab. From code:

```lua
Window:SetUISettings({ AccentColor = Color3.fromRGB(255, 55, 132), Enabled = true }, true)

Window:ApplyUIPreset("Default")
Window:ResetUISize(true)
Window:UseOriginalUI(true)
```

| Group | Functions |
|---|---|
| Read / write | `GetUISettings()`, `SetUISettings(tbl, save?)`, `SaveUISettings()` |
| Size | `SetUISize(w, h, save?)`, `GetUISize()`, `ResetUISize(save?)` |
| Presets | `ApplyUIPreset(name)`, `GetUIPresets()` |
| Profiles | `SaveUIProfile(name)`, `LoadUIProfile(name)`, `DeleteUIProfile(name)`, `GetUIProfileNames()` |
| Export / import | `ExportUISettings()`, `ImportUISettings(json, save?)` |
| Other | `GetUIOverrides()`, `ClearUIOverride(key, save?)`, `OpenUISettings()`, `SetUILanguage()` |

---

## 11. Window control

| Call | Does |
|---|---|
| `Window:Show()` / `Hide()` / `Toggle(state?)` | show / hide / flip |
| `Window:Destroy()` | close and clean up |
| `Window:SetToggleKey(Enum.KeyCode.X)` | change the hotkey |
| `Window:SetToggleButtonPlatform("PC" / "Mobile" / "Both")` | floating button platform |
| `Window:EditOpenButton({ Icon = "x", Size = UDim2.fromOffset(44, 44) })` | restyle the floating button |
| `Window:SelectTab("Main")` or `SelectTab(2)` | switch tab |
| `Window:Divider()` | divider line |
| `Window:GetConfigPath()` / `SaveConfig()` / `DeleteConfig()` | settings file |
| `Window:ForgetSavedKey()` | forget the saved key |

---

## 12. Flags and globals

| Name | Purpose |
|---|---|
| `getgenv().xNgotLibraryOnly = true` | don't open the demo window (set before loading) |
| `getgenv().xNgotMusic = { topN = 10 }` | music settings before the engine starts |
| `_G.xNgotMusicConfig` | music settings (section 9) |
| `_G.CrossAIMusic` | music engine: `parse`, `search`, `download`, `assetFor`… |
| `_G.xNgotMusicDoctor()` | environment self-check (section 13) |
| `_G.xNgotLog` | library log |
| `_G.Window` | demo window (only without `xNgotLibraryOnly`) |

---

## 13. Troubleshooting

**No sound?** Run:

```lua
local report = _G.xNgotMusicDoctor()
print(report.fails, report.warns)
```

It checks `writefile`, `readfile`, `makefolder`, `getcustomasset`, `request`, the engine, the
parser… whatever says `fail` is the cause.

**Read the log:**

```lua
_G.xNgotLog.info("tag", "message")
print(_G.xNgotLog:export())
_G.xNgotLog.clear()
```

**Debug panel:** press **RightShift** or call `_G.xNgotDebug.openPanel()`.

---

## 14. Icons

`Icon = "<icon-name>"`. Over 1,500 icons, referred to by name:

```
house · music-2 · sparkles · settings · bell · search · download · trash-2 · play · pause
skip-forward · skip-back · volume-2 · clock · timer · activity · cpu · wifi · user · key
shield · layout-dashboard · wrench · info · circle-check · triangle-alert · sliders-horizontal
```

A wrong name **never errors** — the icon simply doesn't show. Try the obvious English name,
most of them exist.

---

## 15. Complete examples

### 15.1. Minimal hub

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "Demo", Icon = "music-2" })
local Tab = Window:Tab({ Title = "Main", Icon = "house" })

Tab:Section({ Title = "Basics", Default = true })
Tab:Toggle({ Title = "Enabled", Default = true, Callback = print })
Tab:Slider({ Title = "Speed", Value = { Min = 16, Max = 200, Default = 50 }, Callback = print })
Tab:Button({ Title = "Notify", Callback = function()
    LIB:Notify({ Title = "Hello", Content = "from the library", Kind = "success" })
end })
```

### 15.2. Hub with music

```lua
getgenv().xNgotLibraryOnly = true
local LIB = loadstring(game:HttpGet(".../dist/main.lua"))()

local Window = LIB:CreateWindow({ Title = "Music Hub", Icon = "sparkles" })
local Island = Window:GetDynamicIsland()
local Tab = Window:Tab({ Title = "Music", Icon = "music-2" })

Tab:Section({ Title = "Search", Default = true })
local q = Tab:Input({ Title = "Describe it", Default = "lofi chill for the evening" })

Tab:Button({ Title = "Search", Callback = function()
    Island:MusicSearch(q.Text)
    Island:Expand("Music")
end })

Tab:Button({ Title = "Play / pause", Callback = function() Island:PlayMusic() end })

Tab:Slider({ Title = "Volume", Value = { Min = 0, Max = 100, Default = 60 },
    Callback = function(v) Island:MusicVolume(v) end })

Tab:Button({ Title = "Storage used", Callback = function()
    local s = Island:MusicStorage()
    LIB:Notify({ Title = "Storage", Content = string.format("%d tracks", s.Count or 0) })
end })
```

---

## 16. FAQ

| Question | Answer |
|---|---|
| No floating panel? | `SettingsUI = false` removes it. Turn it back on and create the window again. |
| `Window.DynamicIsland` is `nil`? | Check `Window.DynamicIslandError` — usually the executor blocks GUI creation. |
| Two elements overwrite each other? | Same tab + same `Title`. Give them different titles. |
| Does `Callback` fire on creation? | Yes, once with the initial value. |
| Change colours / fonts globally? | `Window:SetUISettings{...}` or `Window:ApplyUIPreset("...")`. |
| Weak device? | `_G.xNgotMusicConfig:Preset("lowdata")` + `Island:Set("Ring", false)`. |
| Settings lost on exit? | No — they live in `xNgotLibrary/Config/`. |
| Multiple windows at once? | Yes, each `CreateWindow` returns its own object. |
| Release only to key holders? | Pass `KeySystem` when creating the window (section 4). |

---

<p align="center">
This library is free — if it helps you,
<a href="../README.md#-support-the-author">buy the author a coffee</a> ☕
</p>
