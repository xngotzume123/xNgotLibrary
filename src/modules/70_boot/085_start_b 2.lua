--[[ xngot-studio · src/modules/70_boot/085_start_b.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.start_b
     role   : createWindow() + vòng thử nguồn + selftest + Stage=ready
     source : main 2.txt L26366-26503 · 138 dòng · delta -1
--]]
	local function createWindow(library, label)
	-- Dong bo: tieu de loader lay tu opts.title (cung nguon voi tieu de cua so)
	local loadingCfg = opts.loading
	if type(loadingCfg) == "table" and loadingCfg.Title == nil then loadingCfg.Title = opts.title end
		local okWindow, built = xpcall(function()
			return library:CreateWindow({
				-- Cờ nội bộ: cửa sổ do chính thư viện mở lúc khởi động.
				-- Khi script của bạn gọi CreateWindow, thư viện tự đóng bản demo này
				-- để trên màn hình chỉ còn 1 UI.
				__xNgotSelf = true,
				Title = opts.title,
				Author = opts.author,
				Icon = opts.icon or "music-2",
				Folder = "xNgotLibrary/Config",
				Size = UDim2.fromOffset(650, 470),
				FileSaveName = "DynamicIsland_AI.json",
				AutoSave = true,
				SettingsUI = true,
				Loading = loadingCfg,
				KeySystem = opts.keySystem,
			})
		end, bootTrace)
		if okWindow then
			__xNgotBoot.info("cửa sổ đã tạo từ " .. label)
			return built
		end
		failure = bootSafe(built)
		__xNgotBoot.error("CreateWindow lỗi (" .. label .. "): " .. failure)
		return nil
	end

	for _, source in ipairs(bootSources()) do
		if window then break end
		__xNgotBoot.log("debug", "thử nguồn: " .. source.name)
		if source.kind == "builtin" then
			local builtIn = __xNgotEmbeddedLibrary or _G.__xNgotEmbeddedLibrary
			if type(builtIn) == "table" and type(builtIn.CreateWindow) == "function" then
				__xNgotBoot.Library = builtIn
				window = createWindow(builtIn, "thư viện nhúng")
			else
				__xNgotBoot.warn("không thấy thư viện nhúng")
			end
		elseif source.kind == "local" then
			local loader = loadstring or load
			local chunk, compileError = loader(source.code, "=xNgotLocalSource")
			if not chunk then
				failure = bootSafe(compileError)
				__xNgotBoot.warn("bản local lỗi biên dịch: " .. failure)
			else
				local okLib, result = xpcall(chunk, bootTrace)
				if okLib and type(result) == "table" and type(result.CreateWindow) == "function" then
					__xNgotBoot.Library = result
					window = createWindow(result, "bản local")
				else
					failure = bootSafe(result)
					__xNgotBoot.warn("bản local không trả về Library: " .. failure)
				end
			end
		elseif source.kind == "remote" and source.path then
			local code = bootFetch(source.path)
			if code then
				local clean = bootClean(code)
				local snippet = 'local __b = loadstring or load\nlocal __s = __b([====[' .. clean
					.. ']====], "=xNgotRemoteTry")\nif not __s then return nil end\n'
					.. 'local __ok, __lib = pcall(__s)\n'
					.. 'if __ok and type(__lib) == "table" and type(__lib.CreateWindow) == "function" then return __lib end\nreturn nil'
				local loader = loadstring or load
				local chunk = loader(snippet, "=xNgotRemotePlane")
				if chunk then
					local okLib, result = pcall(chunk)
					if okLib and type(result) == "table" and type(result.CreateWindow) == "function" then
						__xNgotBoot.Library = result
						window = createWindow(result, "GitHub raw")
					else
						failure = bootSafe(result)
						__xNgotBoot.warn("bản GitHub raw không dùng được: " .. failure)
					end
				else
					__xNgotBoot.warn("không biên dịch được snapshot từ GitHub")
				end
			else
				__xNgotBoot.warn("không tải được " .. tostring(source.path))
			end
		end
	end

	if not window then
		local reason = __xNgotBoot.recordError("Load", failure or "không nguồn nào nạp được")
		__xNgotBoot.Stage = "failed"
		__xNgotBoot.attachDebug()
		local debugApi = _G.xNgotDebug
		__xNgotBoot.warn(debugApi and debugApi.Build == "release"
			and "boot lỗi — chạy _G.xNgotDebug.getLogPanel() để lấy log chẩn đoán"
			or "boot lỗi — bấm RightShift hoặc _G.xNgotDebug.openPanel() để mở panel chẩn đoán")
		return false, reason
	end

	__xNgotBoot.Window = window
	__xNgotBoot.Stage = "ready"
	env.Window = window
	_G.Window = window
	env.xNgotStudio = __xNgotBoot
	_G.xNgotStudio = __xNgotBoot

	local island = type(window.GetDynamicIsland) == "function" and window:GetDynamicIsland() or nil
	__xNgotBoot.Island = island
	__xNgotBoot.info("Dynamic Island: " .. (island and "sẵn sàng" or "chưa tạo"))

	pcall(function()
		local cfgApi = env.xNgotMusicConfig or _G.xNgotMusicConfig
		if cfgApi and type(cfgApi.Apply) == "function" then cfgApi:Apply() end
		local preset = env.xNgotMusicPreset
		if preset and cfgApi and type(cfgApi.Preset) == "function" then cfgApi:Preset(preset) end
	end)

	if opts.autoRun ~= false then
		pcall(function() window:SelectTab(window.SettingsTitle or "Settings Ui") end)
	end

	if type(_G.xNgotMusicDoctor) == "function" then
		local okReport, report = pcall(_G.xNgotMusicDoctor)
		if okReport and type(report) == "table" then
			__xNgotBoot.log(report.fails and report.fails > 0 and "warn" or "info",
				string.format("doctor: %d lỗi, %d cảnh báo", report.fails or 0, report.warns or 0))
		end
	end
	if env.xNgotDevTools and type(env.xNgotDevTools.selftest) == "function" then
		local okTest, summary = pcall(env.xNgotDevTools.selftest)
		if okTest and type(summary) == "table" then
			__xNgotBoot.log(summary.fails == 0 and "info" or "warn",
				string.format("selftest: %d test, %d lỗi", #summary.results, summary.fails))
		end
	end

	__xNgotBoot.Stage = "ready"
	__xNgotBoot.info(string.format("xNgotStudio sẵn sàng · %.2fs · RightShift để mở panel debug", os.clock() - __xNgotBoot.StartedAt))

	if opts.openPanel == true then
		__xNgotBoot.openDebug()
	end
	return window
end
