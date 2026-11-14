--[[ xngot-studio · src/modules/30_overlay/024_i18n_index.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.i18n_index
     role   : orderedKeys/replacePlain/translate + State/Metrics/P
     source : main 2.txt L3315-3387 · 73 dòng · delta +0
--]]
		    local function orderedKeys(mapping)
		        local keys = {}
		        for key in pairs(mapping) do
		            table.insert(keys, key)
		        end
		        table.sort(keys, function(a, b)
		            return #a > #b
		        end)
		        return keys
		    end

		    local VI_KEYS = orderedKeys(VI_EN)
		    local EN_KEYS = orderedKeys(EN_VI)

		    local function replacePlain(source, needle, replacement)
		        if needle == "" then
		            return source
		        end
		        local chunks = {}
		        local cursor = 1
		        while true do
		            local first, last = string.find(source, needle, cursor, true)
		            if not first then
		                table.insert(chunks, string.sub(source, cursor))
		                break
		            end
		            table.insert(chunks, string.sub(source, cursor, first - 1))
		            table.insert(chunks, replacement)
		            cursor = last + 1
		        end
		        return table.concat(chunks)
		    end

		    local function translate(value)
		        if type(value) ~= "string" then
		            return value
		        end
		        local mapping = Settings.Language == "en" and VI_EN or EN_VI
		        local keys = Settings.Language == "en" and VI_KEYS or EN_KEYS
		        if mapping[value] then
		            return mapping[value]
		        end
		        local extra = Settings.Language == "en" and Extra.En or Extra.Vi
		        if extra[value] then
		            return extra[value]
		        end
		        local result = value
		        for _, key in ipairs(keys) do
		            if string.find(result, key, 1, true) then
		                result = replacePlain(result, key, mapping[key])
		            end
		        end
		        return result
		    end

		    local State = {
		        Ready = false,
		        Open = false,
		    }

		    local Metrics = {
		        Fps = 60,
		        Ping = 0,
		    }

		    local P = {}
		    for key, value in pairs(Palettes[1]) do
		        P[key] = value
		    end
		    P.Accent = Accents[1][2]

		    local Fwd, Isl, Spr = {}, {}, {}

