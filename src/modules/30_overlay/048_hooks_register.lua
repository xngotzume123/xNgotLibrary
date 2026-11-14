--[[ xngot-studio · src/modules/30_overlay/048_hooks_register.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.hooks_register
     role   : Hooks.Tasks + Hooks.Frame (vòng cập nhật mỗi frame)
     source : main 2.txt L4711-4758 · 48 dòng · delta +0
--]]
		    Hooks.Tasks = {}
		    Hooks.Stride = {}

		    function Hooks.Register(fn, stride)
		        local index = #Hooks.Tasks + 1
		        Hooks.Tasks[index] = fn
		        Hooks.Stride[index] = math.max(tonumber(stride) or 1, 1)
		        return index
		    end

		    Hooks.Register(function()
		        local phase = (os.clock() % 7) / 1.5
		        Media.ShineGradient.Offset = Vector2.new(phase < 1 and (2 * phase - 1) or -1, 0)
		    end, 3)

		    Hooks.Frame = function(dt)
		        Hooks.FrameTick = (Hooks.FrameTick or 0) + 1
		        local visible = gui.Visible and islandState.Base > 0.02
		        if islandState.Dirty then
		            islandState.Dirty = false
		            Isl.layoutIsland()
		        end
		        if Ring.Visible then
		            if Ring.Source then
		                local value = math.clamp(Ring.Source(), 0, 1)
		                if math.abs(value - Ring.Progress) > 0.0005 then
		                    Ring.Progress = value
		                    Ring.Dirty = true
		                end
		            end
		            if Ring.Dirty then
		                Ring.Dirty = false
		                Ring.updateRing()
		            end
		        end
		        if not visible then
		            return
		        end
		        local heaviest = Island and Island.Expanded
		        for index = 1, #Hooks.Tasks do
		            local task_ = Hooks.Tasks[index]
		            local stride = Hooks.Stride and Hooks.Stride[index] or 1
		            if stride <= 1 or heaviest or Hooks.FrameTick % stride == 0 then
		                task_(dt * stride)
		            end
		        end
		    end

