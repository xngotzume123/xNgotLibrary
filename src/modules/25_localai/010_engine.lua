--[[ xngot-studio · src/modules/25_localai/010_engine.lua
     lang : Luau · executor
     module : localai.engine
     role : independent offline intent, storage, diagnostics, macro, music and performance engine
--]]
local function __xNgotCreateLocalAI(window, env)
    local LocalAI = {Version="2.0.0", Status="Ready", Chat={}, Pending=nil, Dead=false}
    local NLP, Memory, Learning, Commands, Diagnostics, Macro, Performance, Music, Explainer, Core = {},{},{},{},{},{},{},{},{},{}
    LocalAI.NLP,LocalAI.Memory,LocalAI.Learning,LocalAI.Commands=NLP,Memory,Learning,Commands
    LocalAI.Diagnostics,LocalAI.Macro,LocalAI.Performance,LocalAI.Music,LocalAI.Explainer,LocalAI.Core=Diagnostics,Macro,Performance,Music,Explainer,Core
    local upper={ ["À"]="à",["Á"]="á",["Ạ"]="ạ",["Ả"]="ả",["Ã"]="ã",["Â"]="â",["Ầ"]="ầ",["Ấ"]="ấ",["Ậ"]="ậ",["Ẩ"]="ẩ",["Ẫ"]="ẫ",["Ă"]="ă",["Ằ"]="ằ",["Ắ"]="ắ",["Ặ"]="ặ",["Ẳ"]="ẳ",["Ẵ"]="ẵ",["È"]="è",["É"]="é",["Ẹ"]="ẹ",["Ẻ"]="ẻ",["Ẽ"]="ẽ",["Ê"]="ê",["Ề"]="ề",["Ế"]="ế",["Ệ"]="ệ",["Ể"]="ể",["Ễ"]="ễ",["Ì"]="ì",["Í"]="í",["Ị"]="ị",["Ỉ"]="ỉ",["Ĩ"]="ĩ",["Ò"]="ò",["Ó"]="ó",["Ọ"]="ọ",["Ỏ"]="ỏ",["Õ"]="õ",["Ô"]="ô",["Ồ"]="ồ",["Ố"]="ố",["Ộ"]="ộ",["Ổ"]="ổ",["Ỗ"]="ỗ",["Ơ"]="ơ",["Ờ"]="ờ",["Ớ"]="ớ",["Ợ"]="ợ",["Ở"]="ở",["Ỡ"]="ỡ",["Ù"]="ù",["Ú"]="ú",["Ụ"]="ụ",["Ủ"]="ủ",["Ũ"]="ũ",["Ư"]="ư",["Ừ"]="ừ",["Ứ"]="ứ",["Ự"]="ự",["Ử"]="ử",["Ữ"]="ữ",["Ỳ"]="ỳ",["Ý"]="ý",["Ỵ"]="ỵ",["Ỷ"]="ỷ",["Ỹ"]="ỹ",["Đ"]="đ" }
    local accent={ ["à"]="a",["á"]="a",["ạ"]="a",["ả"]="a",["ã"]="a",["â"]="a",["ầ"]="a",["ấ"]="a",["ậ"]="a",["ẩ"]="a",["ẫ"]="a",["ă"]="a",["ằ"]="a",["ắ"]="a",["ặ"]="a",["ẳ"]="a",["ẵ"]="a",["è"]="e",["é"]="e",["ẹ"]="e",["ẻ"]="e",["ẽ"]="e",["ê"]="e",["ề"]="e",["ế"]="e",["ệ"]="e",["ể"]="e",["ễ"]="e",["ì"]="i",["í"]="i",["ị"]="i",["ỉ"]="i",["ĩ"]="i",["ò"]="o",["ó"]="o",["ọ"]="o",["ỏ"]="o",["õ"]="o",["ô"]="o",["ồ"]="o",["ố"]="o",["ộ"]="o",["ổ"]="o",["ỗ"]="o",["ơ"]="o",["ờ"]="o",["ớ"]="o",["ợ"]="o",["ở"]="o",["ỡ"]="o",["ù"]="u",["ú"]="u",["ụ"]="u",["ủ"]="u",["ũ"]="u",["ư"]="u",["ừ"]="u",["ứ"]="u",["ự"]="u",["ử"]="u",["ữ"]="u",["ỳ"]="y",["ý"]="y",["ỵ"]="y",["ỷ"]="y",["ỹ"]="y",["đ"]="d" }
    function NLP.Normalize(s)
        s=tostring(s or ""):sub(1,500)
        for a,b in pairs(upper) do s=s:gsub(a,b) end
        s=s:lower(); for a,b in pairs(accent) do s=s:gsub(a,b) end
        return (s:gsub("[^%w]+"," "):gsub("%s+"," "):match("^%s*(.-)%s*$"))
    end
    function NLP.Has(text, word) return (" "..text.." "):find(" "..word.." ",1,true)~=nil end
    function NLP.Safe(s, allowDigits)
        if type(s)~="string" or #s<2 or #s>160 or s:find("[@/#:%._\"'\\]") or (not allowDigits and s:find("%d")) then return false end
        local n=NLP.Normalize(s)
        for _,word in ipairs({"password","passcode","mat khau","token","secret","api key","private key","email","gmail","sdt","phone","cookie","session","key","code"}) do
            if n:find(word,1,true) then return false end
        end
        return n~=""
    end
    local userId=tonumber(env.userId)
    if not userId or userId<1 or userId~=math.floor(userId) or userId>9007199254740991 then userId=nil end
    Memory.Path=userId and ("xNgotLibrary/AI/LocalAI_v2_user_"..string.format("%.0f",userId)..".json") or nil
    Memory.Available=Memory.Path~=nil and env.http and type(env.isfile)=="function" and type(env.readfile)=="function" and type(env.writefile)=="function"
    Memory.Blocked=false;Memory.Error=nil
    local function fresh() return {version=2,userId=userId,enabled=false,chat={},aliases={},preferences={},macros={},favorites={},playlists={},history={}} end
    Memory.Data=fresh()
    if type(env.makefolder)=="function" then pcall(env.makefolder,"xNgotLibrary");pcall(env.makefolder,"xNgotLibrary/AI") end
    function Memory.Save()
        if not Memory.Available or Memory.Blocked then return false,Memory.Error or "Filesystem unavailable; session only." end
        local existsOk,exists=pcall(env.isfile,Memory.Path)
        if not existsOk then Memory.Blocked=true;Memory.Error="Cannot verify memory file; original preserved.";return false,Memory.Error end
        if exists then
            local readOk,old=pcall(env.readfile,Memory.Path)
            if not readOk or type(old)~="string" or old~=Memory.Revision then
                Memory.Blocked=true;Memory.Error="Memory changed externally; original preserved.";return false,Memory.Error
            end
        elseif Memory.Revision~=nil then
            Memory.Blocked=true;Memory.Error="Memory was removed externally; no overwrite.";return false,Memory.Error
        end
        local ok,raw=pcall(env.http.JSONEncode,env.http,Memory.Data)
        if not ok or type(raw)~="string" or #raw>131072 then Memory.Error="Cannot encode or memory exceeds 128 KB.";return false,Memory.Error end
        local wrote,result=pcall(env.writefile,Memory.Path,raw)
        if not wrote or result==false then Memory.Error="Could not write Local AI memory.";return false,Memory.Error end
        Memory.Revision=raw;Memory.Error=nil;return true
    end
    local function validArray(t, limit, check)
        if type(t)~="table" or #t>limit then return false end
        local count=0
        for k,v in pairs(t) do
            if type(k)~="number" or k<1 or k~=math.floor(k) or k>#t or not check(v) then return false end
            count+=1
        end
        return count==#t
    end
    local function validSpec(v)
        return type(v)=="table" and type(v.tab)=="string" and #v.tab<=160 and type(v.title)=="string" and #v.title<=160
            and ((v.kind=="Toggle" or v.kind=="Section") and (v.action=="on" or v.action=="off") or v.kind=="Button" and v.action=="press")
    end
    local function validTrack(v)
        return type(v)=="table" and type(v.name)=="string" and #v.name<=160 and type(v.artist)=="string" and #v.artist<=160
    end
    local function validData(d)
        return validArray(d.chat,60,function(v) return type(v)=="table" and (v.role=="user" or v.role=="ai") and type(v.text)=="string" and #v.text<=500 end)
            and validArray(d.aliases,60,function(v) return type(v)=="table" and type(v.key)=="string" and type(v.phrase)=="string" and #v.key<=160 and #v.phrase<=160 and validSpec(v.spec) end)
            and validArray(d.preferences,60,function(v) return type(v)=="table" and type(v.key)=="string" and #v.key<=330 and type(v.count)=="number" and v.count>=0 and v.count<=100000 end)
            and validArray(d.macros,20,function(v) return type(v)=="table" and type(v.name)=="string" and #v.name<=160 and validArray(v.steps,10,validSpec) and #v.steps>0 end)
            and validArray(d.favorites,100,validTrack) and validArray(d.history,60,validTrack)
            and validArray(d.playlists,20,function(v) return type(v)=="table" and type(v.name)=="string" and #v.name<=160 and validArray(v.tracks,50,validTrack) end)
    end
    if Memory.Available then
        local ok,exists=pcall(env.isfile,Memory.Path)
        if not ok then Memory.Blocked=true;Memory.Error="Cannot inspect memory file."
        elseif exists then
            local got,raw=pcall(env.readfile,Memory.Path)
            local decoded,data=false,nil
            if got and type(raw)=="string" and #raw<=131072 then decoded,data=pcall(env.http.JSONDecode,env.http,raw) end
            if not decoded or type(data)~="table" or data.version~=2 or tonumber(data.userId)~=userId or type(data.enabled)~="boolean"
                or type(data.chat)~="table" or type(data.aliases)~="table" or type(data.preferences)~="table" or type(data.macros)~="table"
                or type(data.favorites)~="table" or type(data.playlists)~="table" or type(data.history)~="table"
                or not validData(data) then
                Memory.Blocked=true;Memory.Error="Memory invalid, oversized or belongs to another player; original preserved."
            else Memory.Data=data;Memory.Revision=raw end
        end
    else Memory.Error="Filesystem unavailable; session only." end
    function Memory.SetEnabled(on)
        if not on and not Memory.Data.enabled then return true,"Memory already off; session data was not saved." end
        Memory.Data.enabled=on==true
        local ok,err=Memory.Save();return ok,ok and "Memory setting saved locally." or err
    end
    function Memory.Clear()
        if Memory.Blocked then return false,"Invalid memory file preserved; inspect it manually." end
        if Memory.Path and type(env.delfile)=="function" and type(env.isfile)=="function" then
            local ok,exists=pcall(env.isfile,Memory.Path);if not ok then return false,"Cannot inspect memory file." end
            if exists then
                local readOk,old=pcall(env.readfile,Memory.Path)
                if not readOk or old~=Memory.Revision then return false,"Memory changed externally; file preserved." end
                local deleted,res=pcall(env.delfile,Memory.Path);if not deleted or res==false then return false,"Could not delete memory file." end
            end
        elseif Memory.Available then return false,"Delete API unavailable; file not removed." end
        Memory.Data=fresh();Memory.Revision=nil;LocalAI.Chat={};LocalAI.Pending=nil;Macro.Active=nil;return true,"Local AI memory cleared. Cross memory was not changed."
    end
    local function persist() if Memory.Data.enabled then Memory.Save() end end
    function Core.Record(role,text)
        text=tostring(text or ""):sub(1,500)
        table.insert(LocalAI.Chat,{role=role,text=text});if #LocalAI.Chat>60 then table.remove(LocalAI.Chat,1) end
        if Memory.Data.enabled and NLP.Safe(text) then
            table.insert(Memory.Data.chat,{role=role,text=text});if #Memory.Data.chat>60 then table.remove(Memory.Data.chat,1) end;persist()
        end
    end
    if Memory.Data.enabled then
        for _,item in ipairs(Memory.Data.chat) do
            if type(item)=="table" and (item.role=="user" or item.role=="ai") and NLP.Safe(item.text) then table.insert(LocalAI.Chat,{role=item.role,text=item.text}) end
        end
    end
    function Diagnostics.Error(where,err)
        Diagnostics.Last=tostring(where)..": "..tostring(err):sub(1,220)
        LocalAI.Status="Error"
    end
    function Diagnostics.Report()
        local rows={}
        for _,key in ipairs({"Core","NLP","Learning","Memory","Commands","Diagnostics","Macro","Music","Performance","Explainer"}) do
            rows[#rows+1]=key..": "..(type(LocalAI[key])=="table" and "present" or "missing")
        end
        rows[#rows+1]="UI controls indexed: "..tostring(type(window._AIControls)=="table" and #window._AIControls or 0)
        rows[#rows+1]="Dynamic Island: "..(window.DynamicIsland and "available" or "not available")
        rows[#rows+1]="Memory: "..(Memory.Blocked and "blocked: "..tostring(Memory.Error) or (Memory.Available and "filesystem available" or "session only"))
        rows[#rows+1]="Last observed Local AI error: "..tostring(Diagnostics.Last or "none")
        rows[#rows+1]="This checks availability, not all callbacks or external scripts. Reopen UI or inspect the reported error; no code is modified."
        return table.concat(rows,"\n")
    end
    function Commands.Alive(e)
        if type(e)~="table" or type(e.Object)~="table" or type(e.Root)=="nil" then return false end
        local ok,yes=pcall(function() return e.Object._AIInstance:IsDescendantOf(e.Root) end);return ok and yes==true
    end
    function Commands.Find(text)
        text=NLP.Normalize(text);local matches,best={},0
        for _,e in ipairs(window._AIControls or {}) do
            if Commands.Alive(e) then
                local title=NLP.Normalize(e.Title)
                if #title>=2 and NLP.Has(text,title) then
                    local score=#title+(NLP.Has(text,NLP.Normalize(e.Tab)) and 1000 or 0)
                    if score>best then matches={e};best=score elseif score==best then table.insert(matches,e) end
                end
            end
        end
        return matches
    end
    function Commands.Resolve(spec)
        if type(spec)~="table" or type(spec.tab)~="string" or type(spec.title)~="string" or type(spec.kind)~="string" then return nil,"Invalid action." end
        local found={};for _,e in ipairs(window._AIControls or {}) do
            if Commands.Alive(e) and e.Tab==spec.tab and e.Title==spec.title and e.Kind==spec.kind then found[#found+1]=e end
        end
        if #found~=1 then return nil,"Control missing, renamed or ambiguous; specify its current tab and title." end
        local o=found[1].Object;local ok,locked=pcall(function() if type(o._AIIsLocked)=="function" then return o:_AIIsLocked() end return o.Locked==true end)
        if not ok or locked then return nil,"Control is locked or cannot be checked." end
        return found[1]
    end
    function Commands.MacroAllowed(entry)
        if type(entry)~="table" then return false end
        local text=NLP.Normalize(tostring(entry.Tab or "").." "..tostring(entry.Title or ""))
        for _,word in ipairs({"delete", "destroy", "unload", "shutdown", "crash", "exploit", "dupe", "kick", "ban", "xoa", "pha hoai", "tan cong", "thuc thi code", "execute code"}) do
            if NLP.Has(text,word) then return false end
        end
        if entry.Kind=="Button" then return entry.MacroAllowed==true end
        return entry.Kind=="Toggle" or entry.Kind=="Section"
    end
    function Commands.Parse(text)
        local n=NLP.Normalize(text);local results=Commands.Find(n)
        if #results~=1 then return nil,#results==0 and "No matching registered control." or "Multiple matches; include tab name." end
        if NLP.Has(n,"dung bat") or NLP.Has(n,"khong bat") or NLP.Has(n,"khong mo") or NLP.Has(n,"do not") or NLP.Has(n,"dont") then return nil,"Negated request is not a permitted action." end
        local e=results[1];local spec={tab=e.Tab,title=e.Title,kind=e.Kind}
        local stripped=(" "..n.." "):gsub("%f[%w]"..NLP.Normalize(e.Title):gsub("([^%w])","%%%1").."%f[%W]"," ")
        local on=NLP.Has(stripped,"bat") or NLP.Has(stripped,"mo") or NLP.Has(stripped,"enable") or NLP.Has(stripped,"turn on") or NLP.Has(stripped,"open")
        local off=NLP.Has(stripped,"tat") or NLP.Has(stripped,"dong") or NLP.Has(stripped,"disable") or NLP.Has(stripped,"turn off") or NLP.Has(stripped,"close")
        if e.Kind=="Toggle" or e.Kind=="Section" then
            if on==off then return nil,"Specify bật/tắt or open/close explicitly." end
            spec.action=on and "on" or "off"
        elseif e.Kind=="Button" then
            if not (NLP.Has(stripped,"bam") or NLP.Has(stripped,"nhan") or NLP.Has(stripped,"click") or NLP.Has(stripped,"press")) then return nil,"Specify bấm/click explicitly." end
            spec.action="press"
        else return nil,"This Local AI action supports Toggle, Section and Button only; other existing controls remain available via UI/Cross." end
        local target,err=Commands.Resolve(spec);if not target then return nil,err end
        return spec
    end
    function Commands.Execute(spec)
        if LocalAI.Dead then return false,"Window is closed." end
        local e,err=Commands.Resolve(spec);if not e then return false,err end
        local o=e.Object;local ok,res
        if (e.Kind=="Toggle" or e.Kind=="Section") and (spec.action=="on" or spec.action=="off") then
            local method=e.Kind=="Toggle" and o.Set or o.SetOpen
            if type(method)~="function" then return false,"Expected control method missing." end
            ok,res=pcall(method,o,spec.action=="on")
        elseif e.Kind=="Button" and spec.action=="press" and type(o._AIActivate)=="function" then ok,res=pcall(o._AIActivate,o)
        else return false,"Action not on whitelist." end
        if not ok or res==false then Diagnostics.Error("Callback",ok and "rejected" or res);return false,"Action failed; callback may have partially run." end
        local prefs=Memory.Data.preferences;local key=e.Tab.." / "..e.Title
        for _,p in ipairs(prefs) do if type(p)=="table" and p.key==key then p.count=math.min((tonumber(p.count) or 0)+1,100000);persist();return true end end
        if #prefs<60 and NLP.Safe(key:gsub(" / "," ")) then table.insert(prefs,{key=key,count=1});persist() end
        return true
    end
    function Learning.List() return Memory.Data.aliases end
    function Learning.Put(phrase, command, replace)
        if not NLP.Safe(phrase) or not NLP.Safe(command) then return false,"Phrase or command may contain private data or unsupported characters; not saved." end
        local spec,err=Commands.Parse(command);if not spec then return false,err end
        local key=NLP.Normalize(phrase)
        for _,a in ipairs(Memory.Data.aliases) do
            if type(a)=="table" and a.key==key then
                if not replace then return false,"Duplicate phrase; use edit to replace it." end
                a.phrase=phrase;a.spec=spec;persist();return true,"Phrase updated; action not executed."
            end
        end
        if replace then return false,"Phrase not found; teach it first." end
        if #Memory.Data.aliases>=60 then return false,"Phrase limit reached." end
        table.insert(Memory.Data.aliases,{key=key,phrase=phrase,spec=spec});persist();return true,"Phrase learned; action not executed."
    end
    function Learning.Delete(phrase)
        local key=NLP.Normalize(phrase);for i,a in ipairs(Memory.Data.aliases) do if type(a)=="table" and a.key==key then table.remove(Memory.Data.aliases,i);persist();return true,"Phrase removed." end end
        return false,"Phrase not found."
    end
    function Learning.Find(text)
        local key=NLP.Normalize(text);for _,a in ipairs(Memory.Data.aliases) do if type(a)=="table" and a.key==key and type(a.spec)=="table" then return a.spec end end
    end
    function Explainer.Describe(text)
        local list=Commands.Find(text);if #list~=1 then return #list==0 and "No registered control found." or "More than one control matches; include the tab." end
        local e=list[1];local guide={Toggle="Turns an on/off state on or off.",Section="Opens or closes a section.",Button="Runs its original callback when pressed; effects depend on the script.",Slider="Changes a numeric value.",Dropdown="Selects an available option.",Input="Accepts text.",Colorpicker="Selects a color.",Paragraph="Displays text.",Code="Displays code text; it is not executed."}
        return e.Tab.." / "..e.Title.." ["..e.Kind.."] — "..(guide[e.Kind] or "Control registered by the library; its specific behavior is not available.").." Check the UI description or author documentation for exact behavior."
    end
    function Performance.Analyze()
        local api=window.DynamicIsland;if not api or type(api.State)~="function" then return "Performance metrics unavailable: Dynamic Island is not ready." end
        local ok,state=pcall(api.State,api);if not ok or type(state)~="table" then return "Performance metrics unavailable." end
        local fps,ping=tonumber(state.FPS),tonumber(state.Ping)
        if not fps or fps<=0 then fps=nil end;if not ping or ping<=0 then ping=nil end
        local sample={fps=fps,ping=ping};Performance.Samples=Performance.Samples or {};table.insert(Performance.Samples,sample);if #Performance.Samples>20 then table.remove(Performance.Samples,1) end
        local advice={"FPS: "..(fps and tostring(fps) or "unavailable"),"Ping: "..(ping and (tostring(ping).." ms") or "unavailable"),"Samples: "..#Performance.Samples}
        local previous=Performance.Samples[#Performance.Samples-1]
        if previous and fps and previous.fps then advice[#advice+1]=string.format("FPS change: %+.0f",fps-previous.fps) end
        if previous and ping and previous.ping then advice[#advice+1]=string.format("Ping change: %+.0f ms",ping-previous.ping) end
        if fps and fps<30 then table.insert(advice,"Low FPS: try lower Roblox graphics or close unnecessary UI.") end
        if ping and ping>180 then table.insert(advice,"High ping: check network or try a closer server.") end
        return table.concat(advice," · ")
    end
    function Performance.Vietnamese(text)
        local replacements={
            {"Performance metrics unavailable: Dynamic Island is not ready.","Không có số đo: Dynamic Island chưa sẵn sàng."},
            {"Performance metrics unavailable.","Không có số đo hiệu năng."},
            {"Low FPS: try lower Roblox graphics or close unnecessary UI.","FPS thấp: thử giảm đồ họa Roblox hoặc đóng giao diện không cần thiết."},
            {"High ping: check network or try a closer server.","Ping cao: kiểm tra mạng hoặc thử máy chủ gần hơn."},
            {"FPS change:","Thay đổi FPS:"}, {"Ping change:","Thay đổi ping:"}, {"Samples:","Số mẫu:"}, {"unavailable","không có số đo"},
        }
        for _,pair in ipairs(replacements) do text=text:gsub(pair[1]:gsub("([^%w])","%%%1"),function() return pair[2] end) end
        return text
    end
    function Music.Search(query)
        local api=window.DynamicIsland
        if not api or type(api.MusicFiles)~="function" then return {},"Downloaded music catalog unavailable." end
        local ok,files=pcall(api.MusicFiles,api,false);if not ok or type(files)~="table" then return {},"Cannot read downloaded music." end
        local n=NLP.Normalize(query);local out={};for _,x in ipairs(files) do
            if type(x)=="table" and type(x.Path)=="string" and n~="" and NLP.Normalize(tostring(x.Title or "").." "..tostring(x.Artist or "")):find(n,1,true) then
                out[#out+1]={name=tostring(x.Title or ""),artist=tostring(x.Artist or ""),path=x.Path}
            end
        end
        return out,#out.." downloaded tracks found offline. Online search was not used."
    end
    function Music.Favorite(query)
        local matches,err=Music.Search(query);if #matches~=1 then return false,#matches==0 and err or "Ambiguous song; use a more specific name." end
        local track=matches[1];if not NLP.Safe(track.name,true) or (track.artist~="" and not NLP.Safe(track.artist,true)) then return false,"Track name is not eligible for saved memory." end
        for _,v in ipairs(Memory.Data.favorites) do if type(v)=="table" and v.name==track.name and v.artist==track.artist then return false,"Already a favorite." end end
        if #Memory.Data.favorites>=100 then return false,"Favorites limit reached." end
        table.insert(Memory.Data.favorites,{name=track.name,artist=track.artist});persist();return true,"Added favorite."
    end
    function Music.Play(query)
        local matches,err=Music.Search(query);if #matches~=1 then return false,#matches==0 and err or "Ambiguous song." end
        local api=window.DynamicIsland;if not api or type(api.MusicPlayCachedFile)~="function" then return false,"Local player unavailable." end
        local ok,result,reason=pcall(api.MusicPlayCachedFile,api,matches[1].path)
        return ok and result==true,ok and (reason or (result and "Selected downloaded track." or "File not playable.")) or tostring(result)
    end
    function Music.Pause()
        local api=window.DynamicIsland
        if not api or type(api.State)~="function" or type(api.PlayMusic)~="function" then return false,"Music player unavailable." end
        local ok,state=pcall(api.State,api);if not ok or type(state)~="table" then return false,"Music state unavailable." end
        if not state.Playing then return true,"Music is already paused." end
        local stopped,result=pcall(api.PlayMusic,api)
        return stopped and result~=false,stopped and (result~=false and "Pause requested." or "Music player rejected pause.") or tostring(result)
    end
    function Music.Playlist(name, query)
        if not NLP.Safe(name) then return false,"Invalid playlist name." end
        local matches,err=Music.Search(query);if #matches~=1 then return false,#matches==0 and err or "Ambiguous song." end
        local track=matches[1];if not NLP.Safe(track.name,true) or (track.artist~="" and not NLP.Safe(track.artist,true)) then return false,"Track metadata is not eligible." end
        local playlists=Memory.Data.playlists;local selected
        for _,p in ipairs(playlists) do if type(p)=="table" and NLP.Normalize(p.name)==NLP.Normalize(name) and type(p.tracks)=="table" then selected=p;break end end
        if not selected then if #playlists>=20 then return false,"Playlist limit reached." end;selected={name=name,tracks={}};table.insert(playlists,selected) end
        if #selected.tracks>=50 then return false,"Playlist track limit reached." end
        for _,t in ipairs(selected.tracks) do if type(t)=="table" and t.name==track.name and t.artist==track.artist then return false,"Track already in playlist." end end
        table.insert(selected.tracks,{name=track.name,artist=track.artist});persist();return true,"Added to playlist."
    end
    function Music.RemoveFavorite(name)
        local key=NLP.Normalize(name)
        for i,v in ipairs(Memory.Data.favorites) do if type(v)=="table" and NLP.Normalize(v.name)==key then table.remove(Memory.Data.favorites,i);persist();return true,"Favorite removed." end end
        return false,"Favorite not found."
    end
    function Music.RemovePlaylist(name)
        local key=NLP.Normalize(name)
        for i,v in ipairs(Memory.Data.playlists) do if type(v)=="table" and NLP.Normalize(v.name)==key then table.remove(Memory.Data.playlists,i);persist();return true,"Playlist removed." end end
        return false,"Playlist not found."
    end
    function Music.RemoveFromPlaylist(name, song)
        for _,p in ipairs(Memory.Data.playlists) do
            if type(p)=="table" and NLP.Normalize(p.name)==NLP.Normalize(name) and type(p.tracks)=="table" then
                for i,t in ipairs(p.tracks) do if type(t)=="table" and NLP.Normalize(t.name)==NLP.Normalize(song) then table.remove(p.tracks,i);persist();return true,"Track removed from playlist." end end
            end
        end
        return false,"Playlist or track not found."
    end
    function Music.PlaylistPlay(name, step)
        local chosen
        for _,p in ipairs(Memory.Data.playlists) do if type(p)=="table" and NLP.Normalize(p.name)==NLP.Normalize(name) and type(p.tracks)=="table" then chosen=p;break end end
        if not chosen or #chosen.tracks==0 then return false,"Playlist is empty or missing." end
        local current = Music.CurrentPlaylist==chosen.name and (Music.PlaylistIndex or 0) or 0
        local nextIndex=(current+(tonumber(step) or 1)-1)%#chosen.tracks+1
        local track=chosen.tracks[nextIndex]
        if type(track)~="table" then return false,"Invalid playlist track." end
        local api=window.DynamicIsland;if not api or type(api.MusicFiles)~="function" or type(api.MusicPlayCachedFile)~="function" then return false,"Local player unavailable." end
        local ok,files=pcall(api.MusicFiles,api,false);if not ok or type(files)~="table" then return false,"Downloaded files unavailable." end
        local found={};for _,t in ipairs(files) do if t.Title==track.name and tostring(t.Artist or "")==tostring(track.artist or "") then found[#found+1]=t end end
        if #found~=1 or type(found[1].Path)~="string" then return false,"Saved track missing or ambiguous in downloaded files." end
        local played,result,reason=pcall(api.MusicPlayCachedFile,api,found[1].Path)
        if played and result==true then Music.CurrentPlaylist=chosen.name;Music.PlaylistIndex=nextIndex end
        return played and result==true,played and (result and ("Playlist playback requested: "..chosen.name.." "..nextIndex.."/"..#chosen.tracks) or (reason or "File not playable.")) or tostring(result)
    end
    function Music.ConnectHistory()
        local api=window.DynamicIsland
        if not api or type(api.OnMusicChanged)~="function" or type(api.State)~="function" or type(api.MusicCatalog)~="function" then return false end
        local function changed()
            if LocalAI.Dead then return end
            local ok,state=pcall(api.State,api);if not ok or type(state)~="table" or not state.Playing then return end
            local got,cat=pcall(api.MusicCatalog,api);if not got or type(cat)~="table" then return end
            for _,t in ipairs(cat) do
                if t.Index==state.MusicIndex and NLP.Safe(t.Name,true) and (not t.Artist or t.Artist=="" or NLP.Safe(t.Artist,true)) then
                    local signature=tostring(t.Name).."|"..tostring(t.Artist or "")
                    if signature~=Music.LastTrack then
                        Music.LastTrack=signature;local h=Memory.Data.history;table.insert(h,{name=t.Name,artist=t.Artist or ""});if #h>60 then table.remove(h,1) end;persist()
                    end
                    break
                end
            end
        end
        local ok,unsubscribe=pcall(api.OnMusicChanged,api,changed)
        if ok and type(unsubscribe)=="function" then LocalAI.MusicUnsubscribe=unsubscribe;return true end
        return false
    end
    function Performance.SetMonitor(on, callback)
        if LocalAI.PerformanceConnection then pcall(function() LocalAI.PerformanceConnection:Disconnect() end);LocalAI.PerformanceConnection=nil end
        if not on then return true,"Monitoring disabled." end
        local ok,service=pcall(function() return env.game:GetService("RunService") end)
        if not ok or not service or not service.Heartbeat then return false,"Heartbeat unavailable." end
        local elapsed=0; local lastAlert=-60
        local good,conn=pcall(function() return service.Heartbeat:Connect(function(dt)
            if LocalAI.Dead then return end
            elapsed+=math.min(tonumber(dt) or 0,1)
            if elapsed<15 then return end
            elapsed=0;local result=Performance.Analyze();local s=Performance.Samples and Performance.Samples[#Performance.Samples]
            if s and ((s.fps and s.fps<30) or (s.ping and s.ping>180)) and type(callback)=="function" and os.clock()-lastAlert>=60 then
                lastAlert=os.clock();pcall(callback,result)
            end
        end) end)
        if not good then return false,"Could not start monitoring." end
        LocalAI.PerformanceConnection=conn;return true,"Monitoring every 15 seconds."
    end
    function Macro.Build(commands)
        if type(commands)~="table" or #commands<1 or #commands>10 then return nil,"Macro must contain 1–10 actions." end
        local steps={};for _,cmd in ipairs(commands) do if not NLP.Safe(cmd) then return nil,"Unsafe macro text." end;local spec,err=Commands.Parse(cmd);if not spec then return nil,err end
            local target;target,err=Commands.Resolve(spec);if not target then return nil,err end
            if not Commands.MacroAllowed(target) then return nil,"Macro action denied: sensitive name or missing explicit button permission." end
            steps[#steps+1]=spec end
        return steps
    end
    function Macro.Begin(commands)
        if Macro.Active or LocalAI.Pending then return false,"Another action is pending." end
        local steps,err=Macro.Build(commands);if not steps then return false,err end
        Macro.Active={name="Cross",steps=steps,index=1,paused=false};return Macro.Next()
    end
    function Macro.Save(name, commands)
        if not NLP.Safe(name) then return false,"Invalid macro name." end
        local steps,err=Macro.Build(commands);if not steps then return false,err end
        for _,m in ipairs(Memory.Data.macros) do if type(m)=="table" and NLP.Normalize(m.name)==NLP.Normalize(name) then return false,"Macro already exists." end end
        if #Memory.Data.macros>=20 then return false,"Macro limit reached." end
        table.insert(Memory.Data.macros,{name=name,steps=steps});persist();return true,"Macro saved; nothing executed."
    end
    function Macro.Delete(name)
        if Macro.Active then return false,"Cancel the running macro before deleting." end
        local key=NLP.Normalize(name)
        for i,m in ipairs(Memory.Data.macros) do if type(m)=="table" and NLP.Normalize(m.name)==key then table.remove(Memory.Data.macros,i);persist();return true,"Macro removed." end end
        return false,"Macro not found."
    end
    function Macro.Start(name)
        if Macro.Active or LocalAI.Pending then return false,"Another action is pending." end
        for _,m in ipairs(Memory.Data.macros) do
            if type(m)=="table" and NLP.Normalize(m.name)==NLP.Normalize(name) and type(m.steps)=="table" and #m.steps>=1 and #m.steps<=10 then
                Macro.Active={name=m.name,steps=m.steps,index=1,paused=false};return Macro.Next()
            end
        end
        return false,"Macro not found."
    end
    function Macro.Next()
        local m=Macro.Active;if not m or m.paused then return false,"Macro is paused or stopped." end
        local spec=m.steps[m.index];if not spec then Macro.Active=nil;return true,"Macro complete." end
        local e,err=Commands.Resolve(spec);if not e then Macro.Active=nil;return false,err end
        if not Commands.MacroAllowed(e) then Macro.Active=nil;return false,"Macro action is no longer permitted." end
        LocalAI.Pending={spec=spec,macro=true,target=e.Object,expires=os.clock()+60}
        return true,"Macro "..m.name.." step "..m.index.."/"..#m.steps..": "..tostring(spec.action).." "..spec.tab.." / "..spec.title..". Confirm or cancel."
    end
    function Macro.Pause() if not Macro.Active then return false,"No macro running." end;Macro.Active.paused=true;LocalAI.Pending=nil;return true,"Macro paused." end
    function Macro.Resume() if not Macro.Active or not Macro.Active.paused then return false,"No paused macro." end;Macro.Active.paused=false;return Macro.Next() end
    function Macro.Cancel() Macro.Active=nil;LocalAI.Pending=nil;return true,"Macro cancelled; completed steps are not undone." end
    function Core.Confirm(yes)
        local p=LocalAI.Pending;if not p then return false,"No pending action." end
        LocalAI.Pending=nil
        if not yes then if p.macro then Macro.Active=nil end;return true,"Cancelled; no action performed." end
        if os.clock()>p.expires then if p.macro then Macro.Active=nil end;return false,"Confirmation expired." end
        local entry,why=Commands.Resolve(p.spec)
        if not entry or entry.Object~=p.target then if p.macro then Macro.Active=nil end;return false,why or "Target changed; request the action again." end
        if p.macro and not Commands.MacroAllowed(entry) then Macro.Active=nil;return false,"Macro permission revoked." end
        local ok,err=Commands.Execute(p.spec);if not ok then if p.macro then Macro.Active=nil end;return false,err end
        if p.phrase and NLP.Safe(p.phrase) and #Memory.Data.aliases<60 and not Learning.Find(p.phrase) then
            table.insert(Memory.Data.aliases,{key=NLP.Normalize(p.phrase),phrase=p.phrase,spec=p.spec});persist()
        end
        if p.macro and Macro.Active then Macro.Active.index+=1;return Macro.Next() end
        return true,"Action completed."
    end
    function Core.Ask(prompt)
        if LocalAI.Dead then return false,"Window is closed." end
        if type(prompt)~="string" or #prompt<1 or #prompt>500 then return false,"Request must be 1–500 bytes." end
        LocalAI.Status="Thinking";Core.Record("user",prompt)
        local n=NLP.Normalize(prompt);local answer
        if n=="co" or n=="yes" or n=="confirm" then local _,msg=Core.Confirm(true);answer=msg
        elseif n=="khong" or n=="no" or n=="cancel" or n=="huy" then local _,msg=Core.Confirm(false);answer=msg
        elseif LocalAI.Pending then answer="Action pending; confirm or cancel first."
        elseif n:find("giai thich",1,true) or n:find("explain",1,true) then answer=Explainer.Describe(prompt)
        elseif n=="chan doan" or n=="diagnostics" or n=="kiem tra loi" then answer=Diagnostics.Report()
        elseif n=="hieu suat" or n=="performance" or n=="fps ping" then answer=Performance.Analyze()
        elseif n=="tam dung nhac" or n=="pause music" then local _,msg=Music.Pause();answer=msg
        elseif n:match("^phat nhac ") or n:match("^play music ") then
            local query=n:gsub("^phat nhac ",""):gsub("^play music ","");local _,msg=Music.Play(query);answer=msg
        elseif n:match("^tim nhac ") or n:match("^find music ") then local query=n:gsub("^tim nhac ",""):gsub("^find music ","");local items,msg=Music.Search(query);local names={};for i=1,math.min(#items,10) do names[i]=items[i].name.." — "..items[i].artist end;answer=msg.." "..table.concat(names,"; ")
        elseif n:match("^mo tab ") or n:match("^open tab ") then
            local tabs={};local visited={}
            for _,e in ipairs(window._AIControls or {}) do
                if Commands.Alive(e) and type(e.Tab)=="string" and NLP.Has(n,NLP.Normalize(e.Tab)) and not visited[e.Tab] then tabs[#tabs+1]=e.Tab;visited[e.Tab]=true end
            end
            if #tabs==1 then answer=window:SelectTab(tabs[1]) and ("Opened tab: "..tabs[1]) or "Tab unavailable."
            else answer=#tabs==0 and "Tab not found among registered controls." or "Multiple matching tabs." end
        elseif n:match("^tim ") or n:match("^find ") then
            local matches=Commands.Find(prompt)
            if #matches==1 then local ok=window:SelectTab(matches[1].Tab);answer=ok and Explainer.Describe(prompt) or "Tab unavailable."
            else answer=#matches==0 and "No matching registered control." or "Multiple matches; include tab name." end
        else
            local spec=Learning.Find(prompt);local err
            if not spec then spec,err=Commands.Parse(prompt) end
            if spec then
                local e; e,err=Commands.Resolve(spec)
                if e then LocalAI.Pending={spec=spec,target=e.Object,phrase=Learning.Find(prompt) and nil or prompt,expires=os.clock()+60};answer="Confirm "..spec.action.." — "..spec.tab.." / "..spec.title.."? Reply yes/no."
                else answer=err end
            else answer=err or "Request not recognized." end
        end
        Core.Record("ai",answer);if LocalAI.Status~="Error" then LocalAI.Status="Ready" end
        return true,answer
    end
    function LocalAI:Destroy()
        if self.Dead then return end;self.Dead=true;self.Pending=nil;Macro.Active=nil
        if self.Movement and type(self.Movement.Destroy)=="function" then pcall(self.Movement.Destroy) end
        if self.MusicUnsubscribe then pcall(self.MusicUnsubscribe);self.MusicUnsubscribe=nil end
        if self.PerformanceConnection then pcall(function() self.PerformanceConnection:Disconnect() end);self.PerformanceConnection=nil end
    end
    return LocalAI
end
