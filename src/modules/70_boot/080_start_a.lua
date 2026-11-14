--[[ xngot-studio · src/modules/70_boot/080_start_a.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.start_a
     role   : __xNgotBoot.start() phần đầu: nạp cấu hình, chọn nguồn
     source : main 2.txt L26298-26365 · 68 dòng · delta +1
--]]
function __xNgotBoot.start()
	local opts = __xNgotBoot.Opts
	local env = bootEnv()

	local logApi = env.xNgotLog or _G.xNgotLog
	if logApi then
		pcall(logApi.hookConsole)
		pcall(logApi.info, "boot", "xNgotStudio boot " .. __xNgotBoot.Version)
	end

	if opts.debug ~= false then
		__xNgotBoot.attachDebug()
		if opts.openPanel == true then
			local debugApi = _G.xNgotDebug
			local okPanel, opened = pcall(function() return debugApi.toggle(true) end)
			__xNgotBoot.log(okPanel and opened and "info" or "warn",
				"mở panel lúc khởi động: " .. (okPanel and tostring(opened) or "lỗi"))
		end
	end

	-- xNgotLibrary: thu muc goc duy nhat cho moi du lieu (Config / Music / Avatars / Keys).
	-- Tao san cay thu muc con va chuyen du lieu cu (xNgotStudio, xNgotStudioMusic, file roi o goc) sang.
	do
		local rootFolders = { "xNgotLibrary", "xNgotLibrary/Config", "xNgotLibrary/Music", "xNgotLibrary/Music/Covers", "xNgotLibrary/Avatars", "xNgotLibrary/Keys" }
		if type(makefolder) == "function" then
			for _, folderPath in ipairs(rootFolders) do pcall(makefolder, folderPath) end
		end
		local function migrateFile(oldPath, newPath)
			if type(isfile) ~= "function" or type(readfile) ~= "function" or type(writefile) ~= "function" then return end
			pcall(function()
				if isfile(oldPath) and not isfile(newPath) then writefile(newPath, readfile(oldPath)) end
			end)
		end
		local function migrateFolder(oldFolder, newFolder)
			if type(listfiles) ~= "function" then return end
			pcall(function()
				for _, filePath in ipairs(listfiles(oldFolder)) do
					local name = tostring(filePath):gsub("\\", "/"):match("([^/]+)$")
					if name then migrateFile(filePath, newFolder .. "/" .. name) end
				end
			end)
		end
		migrateFile("xNgotStudio/DynamicIsland_AI.json", "xNgotLibrary/Config/DynamicIsland_AI.json")
		migrateFile("xNgotMusic.config.lua", "xNgotLibrary/Config/xNgotMusic.config.lua")
		migrateFile("xNgotStudio/xNgotStudio_Key.txt", "xNgotLibrary/Keys/key.txt")
		migrateFile("xNgotStudio_Key.txt", "xNgotLibrary/Keys/key.txt")
		migrateFolder("xNgotStudioMusic", "xNgotLibrary/Music")
		migrateFolder("xNgotStudioMusic/Covers", "xNgotLibrary/Music/Covers")
	end

	local cfgCode = bootRead(opts.configFile)
	if cfgCode then
		local okCfg, errCfg = pcall(function()
			local chunk = (loadstring or load)(cfgCode)
			assert(type(chunk) == "function", "loadstring thất bại")
			chunk()
		end)
		if okCfg then
			__xNgotBoot.info("nạp cấu hình: " .. tostring(opts.configFile))
		else
			__xNgotBoot.warn("cấu hình lỗi, bỏ qua: " .. bootSafe(errCfg))
		end
	else
		__xNgotBoot.info("không có " .. tostring(opts.configFile) .. " · dùng CONFIG trong tệp")
	end

	local window, failure

