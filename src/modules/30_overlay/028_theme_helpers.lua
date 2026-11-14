--[[ xngot-studio · src/modules/30_overlay/028_theme_helpers.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.theme
     role   : new/paint/applyTheme/applyAccent/corner/stroke/text/box
     source : main 2.txt L3388-3498 · 111 dòng · delta +0
--]]
		    local function tween(obj, duration, props, style, direction)
		        local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
		        local playing = TweenService:Create(obj, info, props)
		        playing:Play()
		        return playing
		    end

		    local function new(class, props, children)
		        local inst = Instance.new(class)
		        local parent
		        for key, value in pairs(props or {}) do
		            if key == "Parent" then
		                parent = value
		            else
		                inst[key] = value
		            end
		        end
		        for _, child in ipairs(children or {}) do
		            child.Parent = inst
		        end
		        if parent then
		            inst.Parent = parent
		        end
		        return inst
		    end

		    local painted = {}
		    local paletteListeners = {}

		    local function paint(inst, prop, role)
		        inst[prop] = P[role]
		        table.insert(painted, { inst, prop, role })
		    end

		    local function refreshPalette(duration)
		        local info = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		        for _, item in ipairs(painted) do
		            TweenService:Create(item[1], info, { [item[2]] = P[item[3]] }):Play()
		        end
		        for _, listener in ipairs(paletteListeners) do
		            listener(duration)
		        end
		    end

		    local function applyTheme(index)
		        Settings.Theme = index
		        for key, value in pairs(Palettes[index]) do
		            P[key] = value
		        end
		        refreshPalette(0.4)
		    end

		    local function applyAccent(index)
		        Settings.Accent = index
		        P.Accent = Accents[index][2]
		        refreshPalette(0.3)
		    end

		    local function corner(radius, parent)
		        return new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
		    end

		    local function stroke(parent, color, transparency, thickness)
		        local line = new("UIStroke", {
		            Transparency = transparency,
		            Thickness = thickness or 1,
		            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		            Parent = parent,
		        })
		        if type(color) == "string" then
		            paint(line, "Color", color)
		        else
		            line.Color = color
		        end
		        return line
		    end

		    local function text(props)
		        local role = props.Role
		        props.Role = nil
		        props.BackgroundTransparency = 1
		        props.BorderSizePixel = 0
		        if type(props.Text) == "string" then
		            props.Text = translate(props.Text)
		        end
		        if type(props.PlaceholderText) == "string" then
		            props.PlaceholderText = translate(props.PlaceholderText)
		        end
		        props.FontFace = props.FontFace or Fonts.Medium
		        props.TextSize = props.TextSize or 14
		        local fixed = props.TextColor3
		        local label = new("TextLabel", props)
		        if not fixed then
		            paint(label, "TextColor3", role or "Text")
		        end
		        return label
		    end

		    local function box(props)
		        local class = props.Class or "Frame"
		        local role = props.Role
		        props.Class = nil
		        props.Role = nil
		        props.BorderSizePixel = 0
		        local inst = new(class, props)
		        if role then
		            paint(inst, "BackgroundColor3", role)
		        end
		        return inst
		    end

