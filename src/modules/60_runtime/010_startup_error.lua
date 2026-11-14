--[[ xngot-studio · src/modules/60_runtime/010_startup_error.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.startup_error
     role   : Hộp thoại + cảnh báo lỗi khởi động (__xNgotShowStartupError)
     source : main 2.txt L25084-25172 · 89 dòng · delta +0
--]]

local function __xNgotShowStartupError(message)
    local details = tostring(message or "Unknown error")
    local environment = type(getgenv) == "function" and getgenv() or _G
    environment.xNgotStudioLastStartupError = details
    warn("[xNgotStudio] Startup error: " .. details)
    pcall(function()
        local players = game:GetService("Players")
        local player = players.LocalPlayer
        local parent = player and (player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5))
        if not parent then parent = game:GetService("CoreGui") end
        local old = parent:FindFirstChild("xNgotStudio_StartupError")
        if old then old:Destroy() end
        local screen = Instance.new("ScreenGui")
        screen.Name = "xNgotStudio_StartupError"
        screen.ResetOnSpawn = false
        screen.IgnoreGuiInset = true
        screen.DisplayOrder = 2147483000
        screen.Parent = parent
        local panel = Instance.new("Frame")
        panel.Name = "ErrorPanel"
        panel.AnchorPoint = Vector2.new(0.5, 0)
        panel.Position = UDim2.new(0.5, 0, 0, 52)
        panel.Size = UDim2.new(0.9, 0, 0, 220)
        panel.BackgroundColor3 = Color3.fromRGB(24, 29, 40)
        panel.BorderSizePixel = 0
        panel.Parent = screen
        local limit = Instance.new("UISizeConstraint")
        limit.MaxSize = Vector2.new(480, 220)
        limit.Parent = panel
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
        local heading = Instance.new("TextLabel")
        heading.BackgroundTransparency = 1
        heading.Position = UDim2.fromOffset(14, 8)
        heading.Size = UDim2.new(1, -28, 0, 28)
        heading.Text = "xNgotStudio | Startup Error"
        heading.TextColor3 = Color3.fromRGB(255, 185, 173)
        heading.TextSize = 15
        heading.Font = Enum.Font.GothamBold
        heading.TextXAlignment = Enum.TextXAlignment.Left
        heading.Parent = panel
        local body = Instance.new("TextBox")
        body.Name = "ErrorDetails"
        body.Position = UDim2.fromOffset(14, 40)
        body.Size = UDim2.new(1, -28, 1, -89)
        body.BackgroundColor3 = Color3.fromRGB(16, 20, 29)
        body.BorderSizePixel = 0
        body.TextColor3 = Color3.fromRGB(243, 216, 210)
        body.Font = Enum.Font.Code
        body.TextSize = 12
        body.TextWrapped = true
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.MultiLine = true
        body.TextEditable = false
        body.ClearTextOnFocus = false
        body.Text = details
        body.Parent = panel
        Instance.new("UICorner", body).CornerRadius = UDim.new(0, 7)
        local copy = Instance.new("TextButton")
        copy.Text = "Copy Error"
        copy.Font = Enum.Font.GothamSemibold
        copy.TextSize = 12
        copy.BackgroundColor3 = Color3.fromRGB(46, 115, 203)
        copy.TextColor3 = Color3.new(1, 1, 1)
        copy.Position = UDim2.new(1, -120, 1, -40)
        copy.Size = UDim2.fromOffset(105, 28)
        copy.Parent = panel
        Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 7)
        copy.MouseButton1Click:Connect(function()
            local clipboard = setclipboard or toclipboard
            if type(clipboard) == "function" then
                local ok = pcall(clipboard, details)
                copy.Text = ok and "Copied" or "Copy failed"
            end
        end)
        local close = Instance.new("TextButton")
        close.Text = "Close"
        close.Font = Enum.Font.Gotham
        close.TextSize = 12
        close.BackgroundTransparency = 1
        close.TextColor3 = Color3.new(0.85, 0.88, 0.95)
        close.Position = UDim2.new(0, 14, 1, -40)
        close.Size = UDim2.fromOffset(75, 28)
        close.Parent = panel
        close.MouseButton1Click:Connect(function() screen:Destroy() end)
    end)
end

