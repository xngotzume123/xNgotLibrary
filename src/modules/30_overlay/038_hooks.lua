--[[ xngot-studio · src/modules/30_overlay/038_hooks.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.hooks
     role   : Hooks: đăng ký hàm chạy theo Frame/Stride
     source : main 2.txt L3895-3993 · 99 dòng · delta +0
--]]
		    local Hooks = {}

		    track(RunService.RenderStepped:Connect(function(dt)
		        if dt > 0 then
		            Metrics.Fps = Metrics.Fps + (1 / dt - Metrics.Fps) * 0.06
		        end
		        stepSprings(dt)
		        if Hooks.Frame then
		            Hooks.Frame(dt)
		        end
		    end))

		    local playSound
		    local sfxReverb

		    do
		        local SFX = {
		            Click = "rbxasset://sounds/button.wav",
		            Tick = "rbxasset://sounds/switch.wav",
		            Ping = "rbxasset://sounds/electronicpingshort.wav",
		            Fast = "rbxasset://sounds/clickfast.wav",
		            Snap = "rbxasset://sounds/snap.wav",
		        }

		        local Voices = {
		            tick = { { "Tick", 1.9, 0.5, 0 } },
		            click = { { "Fast", 1.2, 0.6, 0 }, { "Ping", 2.2, 0.14, 0.02 } },
		            slide = { { "Tick", 1.5, 0.22, 0 } },
		            on = { { "Tick", 1.6, 0.55, 0 }, { "Ping", 2.1, 0.22, 0.035 } },
		            off = { { "Tick", 1.15, 0.5, 0 }, { "Ping", 1.45, 0.16, 0.035 } },
		            open = { { "Tick", 1.3, 0.45, 0 }, { "Ping", 1.25, 0.3, 0.03 }, { "Ping", 1.88, 0.26, 0.1 } },
		            close = { { "Ping", 1.7, 0.26, 0 }, { "Ping", 1.15, 0.26, 0.08 } },
		            success = { { "Ping", 1, 0.5, 0 }, { "Ping", 1.26, 0.46, 0.085 }, { "Ping", 1.5, 0.46, 0.17 } },
		            info = { { "Ping", 1.12, 0.45, 0 }, { "Ping", 1.68, 0.38, 0.1 } },
		            warn = { { "Ping", 0.86, 0.5, 0 }, { "Ping", 0.86, 0.5, 0.14 } },
		            error = { { "Ping", 0.92, 0.55, 0 }, { "Ping", 0.69, 0.6, 0.11 } },
		            welcome = { { "Ping", 1, 0.4, 0 }, { "Ping", 1.26, 0.4, 0.11 }, { "Ping", 1.5, 0.4, 0.22 }, { "Ping", 2, 0.46, 0.35 } },
		        }

		        local Gaps = { slide = 0.05, tick = 0.04 }

		        local sfxGroup = new("SoundGroup", { Name = "BoncutiSFX", Volume = 1, Parent = SoundService })
		        sfxReverb = new("ReverbSoundEffect", {
		            DecayTime = 1.2,
		            Density = 0.75,
		            Diffusion = 0.85,
		            DryLevel = 0,
		            WetLevel = -10,
		            Parent = sfxGroup,
		        })
		        new("EqualizerSoundEffect", { LowGain = -8, MidGain = 0, HighGain = 3, Parent = sfxGroup })

		        gui.Destroying:Connect(function()
		            sfxGroup:Destroy()
		        end)

		        local lastPlayed = {}

		        local function emit(id, speed, volume, delay)
		            local function fire()
		                if not Settings.Sound or not gui.Parent then
		                    return
		                end
		                local sound = new("Sound", {
		                    SoundId = SFX[id],
		                    PlaybackSpeed = speed,
		                    Volume = math.clamp(volume * Settings.Volume / 100 * 1.6, 0, 1),
		                    SoundGroup = sfxGroup,
		                    Parent = gui,
		                })
		                sound:Play()
		                Debris:AddItem(sound, 3)
		            end
		            if delay and delay > 0 then
		                task.delay(delay, fire)
		            else
		                fire()
		            end
		        end

		        function playSound(name, pitch)
		            if not Settings.Sound then
		                return
		            end
		            local voice = Voices[name]
		            if not voice then
		                return
		            end
		            local now = os.clock()
		            if lastPlayed[name] and now - lastPlayed[name] < (Gaps[name] or 0.03) then
		                return
		            end
		            lastPlayed[name] = now
		            for _, part in ipairs(voice) do
		                emit(part[1], part[2] * (pitch or 1), part[3], part[4])
		            end
		        end
		    end

