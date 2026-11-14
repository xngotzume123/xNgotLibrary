--[[ xngot-studio · src/modules/60_runtime/060_http_log.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.http_log
     role   : Hook http_request để ghi log request/response
     source : main 2.txt L25637-25667 · 31 dòng · delta +0
--]]
local __xNgotHttpLog = function()
	local logApi = _G.xNgotLog
	if not (logApi and type(logApi.apiCall) == "function") then return end
	local function describe(url, method)
		return tostring(method or "GET"), tostring(url or "?")
	end
	local function bodySize(body)
		if type(body) ~= "string" then return 0 end
		return #body
	end
	if type(CrossAIMusic) == "table" and type(CrossAIMusic.request) == "function" and not CrossAIMusic._logged then
		local base = CrossAIMusic.request
		CrossAIMusic._logged = true
		CrossAIMusic.request = function(url, method, headers, body, timeout)
			local started = os.clock()
			local res = base(url, method, headers, body, timeout)
			local ms = math.floor((os.clock() - started) * 1000)
			local okRes = type(res) == "table"
			local status = okRes and (res.StatusCode or res.Status or res.statusCode) or nil
			local text = okRes and (res.Body or res.body) or nil
			logApi.apiCall({
				url = url, method = method or "GET", ok = okRes, status = status, ms = ms,
				bytes = type(text) == "string" and #text or bodySize(body),
				source = "CrossAIMusic.request", timeout = timeout,
			})
			return res
		end
	end
end
__xNgotHttpLog()

