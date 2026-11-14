--[[ xngot-studio · src/modules/30_overlay/012_connections.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.connections
     role   : Bảng connections + track() huỷ kết nối khi destroy
     source : main 2.txt L2810-2816 · 7 dòng · delta +0
--]]
		    local connections = {}

		    local function track(connection)
		        table.insert(connections, connection)
		        return connection
		    end

