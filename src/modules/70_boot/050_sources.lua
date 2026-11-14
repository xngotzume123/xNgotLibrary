--[[ xngot-studio · src/modules/70_boot/050_sources.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.sources
     role   : bootClean + bootSources (nguồn nhúng / local / remote)
     source : main 2.txt L26131-26192 · 62 dòng · delta +0
--]]
local function bootClean(text)
	local out, index, length = {}, 1, #text
	while index <= length do
		local two = text:sub(index, index + 1)
		if two == "--" then
			local eq = text:match("^%-%-%[(=*)%[", index)
			if eq then
				local close = "]" .. eq .. "]"
				local found = text:find(close, index, true)
				index = found and (found + #close) or (length + 1)
			else
				local nl = text:find("\n", index, true)
				index = nl or (length + 1)
			end
		elseif two:sub(1, 1) == '"' or two:sub(1, 1) == "'" then
			local quote = two:sub(1, 1)
			local cursor = index + 1
			while cursor <= length do
				local char = text:sub(cursor, cursor)
				if char == "\\" then
					cursor = cursor + 2
				elseif char == quote then
					cursor = cursor + 1
					break
				else
					cursor = cursor + 1
				end
			end
			out[#out + 1] = text:sub(index, cursor - 1)
			index = cursor
		else
			out[#out + 1] = text:sub(index, index)
			index = index + 1
		end
	end
	return (table.concat(out):gsub("\n\n\n+", "\n\n"))
end
__xNgotBoot.clean = bootClean

local function bootSources()
	local opts = __xNgotBoot.Opts
	local env = bootEnv()
	local userOpts = type(env.xNgotLoaderConfig) == "table" and env.xNgotLoaderConfig or {}
	for key, value in pairs(userOpts) do opts[key] = value end

	local list = {}
	local function add(name, kind, path, code)
		list[#list + 1] = { name = name, kind = kind, path = path, code = code }
	end

	add("built-in (thư viện nhúng trong tệp này)", "builtin", nil, nil)

	local localCode = bootRead(opts.localFile)
	if localCode then
		add("local: " .. tostring(opts.localFile), "local", opts.localFile, localCode)
	end
	if opts.remoteUrl then
		add("GitHub raw " .. tostring(opts.remoteUrl):gsub("^https?://", ""), "remote", tostring(opts.remoteUrl))
	end
	return list
end

