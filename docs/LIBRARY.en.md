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
python3 src/build.py --release --minify light
```

This produces `dist/main.lua` and `dist/main.min.lua`. The light build keeps line breaks and was checked with an older Luau compiler with a 200-register limit. A working Roblox executor is still needed for runtime testing.

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

The window and island are held until the key screen completes. If the user closes the key screen before authentication, the window is destroyed rather than unlocked.

---

# UI components

Add elements to a tab using `Tab:Button`, `Tab:Toggle`, `Tab:Slider`, `Tab:Input`, `Tab:Dropdown`, `Tab:Colorpicker`, `Tab:Section`, `Tab:Paragraph`, `Tab:Code`, `Tab:Discord` and `Tab:InfoNguyenNhat`.

## Buttons and text

```lua
Main:Section({ Title = "General", Default = true })
Main:Paragraph({ Title = "Welcome", Desc = "Choose an option below." })
Main:Button({ Title = "Refresh", Icon = "refresh-cw", Callback = function()
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
    Island:PlayMusic()
end
```

## Presets

```lua
_G.xNgotMusicConfig:Preset("lowdata")
_G.xNgotMusicConfig:Set("topN", 8)
print(_G.xNgotMusicConfig:Get("topN"))
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
