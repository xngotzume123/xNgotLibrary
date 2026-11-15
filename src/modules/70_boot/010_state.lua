--[[ xngot-studio · src/modules/70_boot/010_state.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.state
     role   : _G.__xNgotEmbeddedLibrary + __xNgotBoot + Opts
     source : main 2.txt L26020-26061 · 40 dòng · delta +0
     note   : đã bỏ 26021, 26022 (closure ngoài cùng, xem docs/PROVENANCE.md)
--]]
_G.__xNgotEmbeddedLibrary = LIB
_G.__xNgotEmbeddedLibrary = LIB
local __xNgotEmbeddedLibrary = LIB
local __xNgotBoot = {}
__xNgotBoot.Version = "3.0.0"

__xNgotBoot.Opts = {
	localFile = "main.lua",
	configFile = "xNgotLibrary/Config/xNgotMusic.config.lua",
	remoteUrl = "https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua",
	title = "xNgọt Studio",
	author = "Dynamic Island · AI Music · Assistant",
	icon = "music-2",  
	autoRun = true,
	debug = true,
	openPanel = false,
	theme = "dark",
	 
	loading = {
		 
		Text = "Starting",
		Steps = { "Preparing interface", "Loading icons", "Almost there" },
		Duration = 1.6,
	},
	keySystem = {
		Enabled = true,
		 
		Keys = { "XNGOT-2026" },
		KeyFile = "xNgotLibrary/Keys/key.txt",
		GetKeyUrl = "",
	},
}

__xNgotBoot.Log = {}
__xNgotBoot.Stage = "init"
__xNgotBoot.Window = nil
__xNgotBoot.Library = nil
__xNgotBoot.Island = nil
__xNgotBoot.StartedAt = os.clock()

