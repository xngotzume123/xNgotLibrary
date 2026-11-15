--[[ xngot-studio · src/modules/10_config/050_apply.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/10_config · cấu hình nhạc toàn cục _G.xNgotMusicConfig
     module : config.apply
     role   : Áp cấu hình xuống _G.CrossAIMusic (nguồn, timeout, thư mục...)
     source : main 2.txt L111-131 · 21 dòng · delta +0
--]]
local function applyToEngine(engine)
	if type(engine) ~= "table" or type(engine.Config) ~= "table" then return false end
	local c = engine.Config
	c.TopN = Config.topN
	c.Sources = Config.sources
	c.Region = Config.region
	c.PrefetchNext = Config.prefetchNext
	c.SearchTimeout = Config.searchTimeout
	c.PreferShort = Config.preferShort
	c.Folder = Config.folder
	c.CoversFolder = Config.folder .. "/Covers"
	c.RaceTracks = Config.raceTracks
	c.DownloadTimeout = Config.downloadTimeout
	c.Retries = Config.retries
	c.LlmMode = "off"
	c.AiBrain = Config.aiBrain
	c.AiLearn = Config.aiLearn
	if type(engine.renameFiles) == "function" then
		engine.renameFiles(Config.renameFiles)
	end
	return true
end

