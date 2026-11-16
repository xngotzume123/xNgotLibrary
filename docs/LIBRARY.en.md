# xNgot Library — User Manual


---

# Your interface, made simpler.

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

---

# Installation

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

---

# Windows & tabs

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

---

# UI components

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

---

# Notifications & dialogs

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

---

# Key system

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

---

# Local keys & keyless

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

---

# Provider setup

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

---

# Custom & appearance

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

---

# Dynamic Island

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

---

# Music & configuration

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

---

# Appearance & storage

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

---

# Troubleshooting

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

---

# API reference

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

---

# Complete hub example

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

---

# Component reference

All constructors below are called on a `Tab`. Their `Title` values should be unique within a tab because stateful controls use the original title as a config key. Renaming a control later does **not** migrate that key.

| Constructor | Options | Callback / behavior |
| --- | --- | --- |
| `Button` | `Title`, `Desc`, `Locked`, `Callback` | Invoked on activation. This build does not read an `Icon` option for Button. |
| `Toggle` | `Title`, `Desc`, `Default` or `Value`, `Icon`, `Locked`, `Callback` | Boolean; callback fires at creation and on `:Set`. Avoid specifying conflicting `Default` and `Value`. |
| `Slider` | `Title`, `Desc`, `Value = {Min, Max, Default}`, `Step`, `Locked`, `Callback` | Number; clamped, stepped; callbacks at initialization and changes. `:Set` returns the value or `nil` if outside bounds. |
| `Input` | `Title`, `Desc`, `Placeholder`, `Default` / `Value`, `ClearTextOnFocus`, `MultiLine`, `NoSave`, `Locked`, `Callback` | String; callback on initialization, focus loss, and `:Set`. |
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
| Input | `Set`, `Get`, `SetTitle`, `SetDesc`, `SetPlaceholder`, `Lock`, `Unlock`, `Destroy` |
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

---

# Window and storage APIs

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

With `AutoSave = false`, automatic writes are disabled; explicit `SaveConfig()` still attempts a write. Saved data is local, not encrypted, and depends on executor filesystem functions. The default configuration path is `xNgotLibrary/Config/<FileSaveName>`; existing valid root config is copied on first use without deleting it. Explicit custom `Folder` paths remain supported and may be outside the root. Default keys, AI and music are under `xNgotLibrary/Keys`, `xNgotLibrary/AI` and `xNgotLibrary/Music` (covers under `Music/Covers`); externally configured or third-party paths can differ. Files are not E2E protected: other scripts or users with executor workspace access can read or modify them. `DeleteConfig` does not delete downloaded music or the separately stored key.

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

---

# Dynamic Island API

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

In **Settings → Open Dynamic Island Settings → Cross AI Assistant**, turn on **Enable Cross AI**, enter a command such as `next song` or `timer 60`, and press **Send to Cross AI**. The response appears in the section. **Open Cross AI on Island** opens the island interface (enable the island first); **Clear Cross AI chat** clears the session. The input is not written to window config, but music-search commands may be sent to third-party search services; never enter secrets. This is a local, rule-based assistant, not a general online AI chatbot.

`AiState()` returns a snapshot with `Enabled`, `Thinking`, `Reply`, `Version` and `Pending` (latest assistant response, not the full chat). `AiAsk` may yield during music resolution; use a task when needed.

`AiEnable(boolean)`, `AiOpen()`, `AiAsk(text)`, `AiClear()` and `AiPermission(name, boolean)` control the local assistant. `Ui` and `Key` permissions can be configured; `Body` and `Free` are forced off by the implementation. `MusicAiLearn(title, good)` records feedback when supported; `DemoDownload()` displays simulated progress rather than downloading a real file. `MusicAiOnline(true)` does not enable an online model in this build; `MusicAiOnlineState()` reports removed/local. Do not assume it calls an external AI service.

`SetLanguage` / `Set("Language", ...)` currently force English. The documentation language switch is independent of the library UI language.

---

# Music API and settings

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

---

# Loader and key lifecycle

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

---

# Build, test and publish

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

---

# Control guides: start here

Each control page has a small **addition**, not a separate script. First paste and run this setup together with one or more examples on the following pages. Put the current `main.lua` in the executor workspace. `readfile` and `loadstring` are required.

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

## Before you begin

- `Tab:Section()` changes the parent used by *subsequently created* controls; create another section to switch. `Section:_Use("Button", {...})` explicitly targets a section. Destroying the current section resets the parent to the tab.
- Toggle, Slider, Input, Dropdown and Colorpicker invoke their callback while being created, with the initial or restored value. Create dependencies before these controls; do not refer to a local that is still being assigned from its own constructor.
- Saved values are indexed by tab title and the control's original title, not by `Flag`. Use unique titles per tab. Renaming a control later does not migrate its saved key. `AutoSave` and filesystem support affect persistence; see Window & storage.
- `Lock()` blocks interaction; programmatic setters can still update values and trigger callbacks. `Destroy()` removes the visual control.
- `AIControl = false` on a control opts it out of the local assistant index. Confirmed UI actions run the original callback; see Cross AI: control your UI.
- Mobile retains its original dimensions. Drag sliders horizontally; vertical gestures are treated as scrolling. Actual executor behavior still needs Roblox testing.

---

# Section

Group controls in a collapsible area.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local group = Tab:Section({ Title = "Actions", Default = true })
Tab:Button({ Title = "Inside Actions", Callback = function() print("Pressed") end })
group:SetOpen(true)
-- group:_Use("Toggle", { Title = "Extra", Callback = function(v) print(v) end })
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title` | string | `Section` | Heading |
| `Default` | boolean | `false` | Initially open |
| `TextXAlignment` | string | `Left` | Left, Center or Right |

## Returned object

`SetTitle(text)`, `SetOpen(boolean)` (returns state), `Toggle()` (returns state), `Destroy()`, `_Use(methodName, options)`

## Notes

Later `Tab` controls go into the most recently created section, not automatically back to the tab. `_Use` does not permanently change that parent.

---

# Button

Execute an action on activation.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local button = Tab:Button({
    Title = "Say hello", Desc = "Run an action",
    Callback = function() print("Hello!") end,
})
-- button:Lock()  -- button:Unlock()
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title` | string | `Button` | Label |
| `Desc` | string | `nil` | Optional description |
| `Locked` | boolean | `false` | Disable user activation |
| `Callback` | function() | `no-op` | Runs when pressed |

## Returned object

`SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Notes

The callback receives no arguments.

---

# Toggle

Turn a feature on or off.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local toggle = Tab:Toggle({
    Title = "Auto action", Desc = "Example switch", Default = false, Icon = "zap",
    Callback = function(enabled) print("Auto action:", enabled) end,
})
toggle:Set(true)
-- toggle:Set() -- invert
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title` | string | `Toggle` | Label and original storage key |
| `Desc` | string | `nil` | Optional description |
| `Default / Value` | boolean | `false` | Initial state; prefer Default alone |
| `Icon` | string | `nil` | Optional icon name |
| `Locked` | boolean | `false` | Disable interaction |
| `Callback` | function(boolean) | `no-op` | Receives new state |

## Returned object

`Set(boolean)` or `Set()` to invert, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Notes

The callback runs at creation and after Set. A saved state can override Default. Avoid supplying both Default=false and Value=true: the source fallback expression can choose Value.

---

# Slider

Choose a number in a range.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local slider = Tab:Slider({
    Title = "Speed", Value = { Min = 0, Max = 100, Default = 25 }, Step = 5,
    Callback = function(value) print("Speed:", value) end,
})
slider:Set(40)
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Slider / nil` | Label and description |
| `Value.Min / Max` | number | `0 / 100` | Range bounds |
| `Value.Default` | number | `Min` | Initial number; top-level Default also supported |
| `Step` | number | `1` | Positive step for updates |
| `Locked` | boolean | `false` | Disable interaction |
| `Callback` | function(number) | `no-op` | Receives number |

## Returned object

`Set(number)`, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Notes

Values are clamped; invalid/non-positive Step falls back to 1. Callback also runs on creation and Set.

---

# Input

Accept text, optionally multiline.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local input = Tab:Input({
    Title = "Nickname", Placeholder = "Enter a name", Default = "Guest",
    Callback = function(text) print("Nickname:", text) end,
})
input:Set("Player")
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Input / nil` | Label and description |
| `Placeholder` | string | `empty` | Hint in text box |
| `Default / Value` | string | `empty` | Initial text |
| `ClearTextOnFocus` | boolean | `false` | Clear when focused |
| `NoSave` | boolean | `false` | Do not restore or save this input in config |
| `MultiLine` | boolean | `false` | Allow multiple lines |
| `Locked` | boolean | `false` | Disable interaction |
| `Callback` | function(string) | `no-op` | Receives text |

## Returned object

`Set(text)`, `Get()` (current TextBox text, even while focused), `SetTitle(text)`, `SetDesc(text)`, `SetPlaceholder(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Notes

Callback runs at creation, on focus loss and after Set; it is not an every-keystroke callback. `NoSave=true` prevents this input from reading or writing config; it does not delete old saved values.

---

# Dropdown

Pick one or multiple options.

First see **Control guides: start here**; append this snippet below the setup.

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

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Dropdown / nil` | Label and description |
| `Values` | array of strings | `{}` | Available items |
| `Value / Default` | string or array | `nil` | Initial selection |
| `Multi` | boolean | `false` | Allow multiple selections |
| `AllowNone` | boolean | `false` | Allow no selection |
| `Locked` | boolean | `false` | Disable interaction |
| `Callback` | function(value) | `no-op` | Single: string or nil; multi: array |

## Returned object

`Select(value)` (returns selected value or nil), `Refresh(values)` (returns selection), `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Notes

Callback runs on creation and Select. For multi-select, Select toggles each named item rather than replacing the entire selection. Single AllowNone represents None as an empty string in callbacks; multi receives an array. Refresh resets the selection and saves it but does not call Callback. With multi and AllowNone=false, the first option is used if no initial selection exists.

---

# Colorpicker

Pick and observe a Color3 value.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local color = Tab:Colorpicker({
    Title = "Accent example", Default = "#66AAFF",
    Callback = function(value) print("Color:", value) end,
})
color:Set(Color3.fromRGB(255, 120, 80))
print(color:Get())
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title / Desc` | string | `Color / empty` | Label and description |
| `Default / Value` | Color3, hex string or RGB table | `white` | Initial color |
| `Locked` | boolean | `false` | Disable interaction |
| `Callback` | function(Color3) | `no-op` | Receives Color3 |

## Returned object

`Set(value)`, `Get()` → Color3, `SetTitle(text)`, `SetDesc(text)`, `Lock()`, `Unlock()`, `Destroy()`

## Notes

Accepts Color3, `#RRGGBB`, or an RGB table. Invalid input falls back to white. Callback runs on creation and Set; this example does not change the global UI theme.

---

# Paragraph

Display a title and descriptive text.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local status = Tab:Paragraph({ Title = "Status", Desc = "Ready" })
status:SetDesc("Running")
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title` | string | `Paragraph` | Heading |
| `Desc` | string | `nil` | Body |
| `RichText` | boolean | `false` | Interpret Roblox RichText tags |

## Returned object

`SetTitle(text)`, `SetDesc(text)`, `Destroy()`

## Notes

This is a display element, not a persistent value control.

---

# Code

Show a code block in the window.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local code = Tab:Code({ Title = "Example", Code = 'print("Hello")' })
code:SetCode('print("Updated")')
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Title` | string | `Code` | Heading |
| `Code` | string | `empty` | Code content |

## Returned object

`SetTitle(text)`, `SetCode(text)`, `Destroy()`

## Notes

Displays text; it does not execute that text.

---

# Discord & InfoNguyenNhat

Display community and profile cards.

First see **Control guides: start here**; append this snippet below the setup.

```lua
local discord = Tab:Discord({ Name = "Community", Desc = "Join us", InviteLink = "discord.gg/example" })
local info = Tab:InfoNguyenNhat({ Name = "Developer", Bio = "Building a hub" })
info:SetBio("Welcome!")
-- discord:SetInvite("discord.gg/example", "example")
```

## Options

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `Discord.Avatar` | string | `rbxassetid://0` | Avatar asset |
| `Discord.Name / Desc` | string | `Discord Server / empty` | Server text |
| `Discord.InviteLink / InviteCode` | string | `discord.gg/xxxxxxx / nil` | Invite URL and optional code |
| `Info.Avatar / Name / Bio` | string | `rbxassetid://0 / Nguyen Nhat / empty` | Profile fields |
| `Info.Badges` | table | `{}` | Badge list |

## Returned object

Discord: `SetInvite(link, code)`, `Destroy()`. Info: `SetAvatar(id)`, `SetName(text)`, `SetBio(text)`, `Destroy()`, `Info.AddSocialIcon(icon, copyValue, order)` (dot call).

## Notes

Invite and avatar/network behavior depends on the executor and live services; placeholders are not real invites.

---

# Cross AI: control your UI

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

---

# Cross automatic memory

Cross remembers eligible confirmed UI requests automatically; there is no Learning section or setup switch in Settings. It is a local rule-based lookup and frequency counter, **not model training** or an online chatbot. It cannot infer every unfamiliar sentence.

## How it learns

1. Enable Cross in **Settings → Open Dynamic Island Settings → Cross AI Assistant**.
2. Ask for an existing control, for example `bật Show FPS`. Cross proposes an action; review the name and tab, then answer `có`/`yes` or `không`/`no`.
3. A successful confirmed UI operation increases that control's use counter, up to 80 distinct controls. For eligible toggle, section and button phrases, Cross may save the phrase and its specific action (up to 80 learned phrases). Cancellation, expiry, blocked permissions or failed actions do not teach it.
4. If Cross cannot match an action-like request, it may ask you to clarify the control and action. Give the existing tab and control name, for example `bật Main Auto Farm`, then confirm. If the direction agrees and the phrase is eligible, Cross remembers the first phrase for later use. It will **still ask before acting** on a learned phrase.

For safety, automatic phrase learning is limited to short phrases without numbers, quotes, URLs or certain sensitive terms; these checks are imperfect. It only saves phrases for toggle, section and button actions, not arbitrary input text or code. It stores a normalized phrase and its mapped control/action; slider, dropdown, input, color and other controls can still be operated with confirmation and counted, but their value or arbitrary input is not automatically saved as a learned phrase. Manual clicks outside Cross are not counted.

Duplicate names require the tab; a renamed, deleted, locked or duplicated target cannot be automatically run from an old mapping. Some existing music and timer chat commands remain immediate, rather than going through UI confirmation. Send `gợi ý` / `preferences` to see frequently confirmed controls; these are suggestions, not automatic actions.

## Storage and privacy

The executor stores `xNgotLibrary/AI/xNgotCrossAI_user_<UserId>.json` in its workspace. This is local to the account and executor/device, not online synchronization. The legacy root file is read if the new file does not exist; the original is not deleted. Existing compatible learned phrases remain available; older files with remembering turned off are now read with automatic remembering on. Counts store tab, control name, type and frequency, not values. They may still reveal information if a control name itself contains personal data.

The JSON is **plain text**, and can be read or altered by other scripts or anyone with workspace access. The phrase filter cannot reliably detect all personal data, so do not put passwords, keys or private information in Cross requests. Full chat history is not saved by this feature. The file can be removed manually in the executor workspace if needed; there is no Learning management section in the UI.

`isfile`, `readfile`, `writefile` and Roblox `HttpService` JSON support are required. If unavailable or a write fails, the assistant reports that learning is **session only**; it is not guaranteed to survive restart. An invalid, unreadable, oversized or wrong-user file is not silently overwritten. Back it up and inspect it before manually removing it. None of this prevents another script from directly calling the library API.

Developers can inspect `island:AiLearningState()` for the local path and error status. The former `AiSetRemember(false)` switch cannot disable automatic learning in this build. Previously provided learning APIs remain for compatibility, but no setup or management controls are shown in Settings.
