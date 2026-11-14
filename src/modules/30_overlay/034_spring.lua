--[[ xngot-studio · src/modules/30_overlay/034_spring.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.spring
     role   : Spring vật lý lò xo cho chuyển động island
     source : main 2.txt L3789-3845 · 57 dòng · delta +0
--]]
		    local Spring = {}
		    Spring.__index = Spring
		    local activeSprings = {}

		    function Spring.new(initial, stiffness, damping, callback, epsilon)
		        local self = setmetatable({}, Spring)
		        self.Value = initial
		        self.Target = initial
		        self.Velocity = 0
		        self.Stiffness = stiffness
		        self.Damping = damping
		        self.Callback = callback
		        self.Epsilon = epsilon or 0.01
		        callback(initial)
		        return self
		    end

		    function Spring:Set(target)
		        self.Target = target
		        activeSprings[self] = true
		    end

		    function Spring:Snap(value)
		        self.Value = value
		        self.Target = value
		        self.Velocity = 0
		        activeSprings[self] = nil
		        self.Callback(value)
		    end

		    local function stepSprings(dt)
		        dt = math.min(dt, 1 / 20)
		        local steps = math.max(1, math.ceil(dt / (1 / 120)))
		        local h = dt / steps
		        local list = {}
		        for spring in pairs(activeSprings) do
		            table.insert(list, spring)
		        end
		        for _, spring in ipairs(list) do
		            local value = spring.Value
		            local velocity = spring.Velocity
		            for _ = 1, steps do
		                local acceleration = spring.Stiffness * (spring.Target - value) - spring.Damping * velocity
		                velocity = velocity + acceleration * h
		                value = value + velocity * h
		            end
		            if math.abs(spring.Target - value) < spring.Epsilon and math.abs(velocity) < spring.Epsilon * 8 then
		                value = spring.Target
		                velocity = 0
		                activeSprings[spring] = nil
		            end
		            spring.Value = value
		            spring.Velocity = velocity
		            spring.Callback(value)
		        end
		    end

