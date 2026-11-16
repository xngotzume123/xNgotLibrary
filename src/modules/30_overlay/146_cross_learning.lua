--[[ xngot-studio · src/modules/30_overlay/146_cross_learning.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · per-user local learning
     module : overlay.cross_learning
     role   : validated local JSON storage for explicit teaching and opt-in preferences
--]]
do
    local maxAliases, maxPreferences, maxFileSize = 80, 80, 65536
    local userId = player and tonumber(player.UserId)
    if not userId or userId < 1 or userId > 9007199254740991 or userId ~= math.floor(userId) then userId = nil end
    local oldPath = userId and ("xNgotCrossAI_user_" .. string.format("%.0f", userId) .. ".json") or nil
    local path = oldPath and ("xNgotLibrary/AI/" .. oldPath) or nil
    if type(makefolder) == "function" then
        pcall(makefolder, "xNgotLibrary")
        pcall(makefolder, "xNgotLibrary/AI")
    end
    local http
    pcall(function() http = game:GetService("HttpService") end)
    local canPersist = path ~= nil and http ~= nil and type(isfile) == "function"
        and type(readfile) == "function" and type(writefile) == "function"
    local blocked, diskError = false, nil
    local function fresh() return {version=1, userId=userId, remember=true, aliases={}, prefs={}} end
    local memory = fresh()
    local function validString(s, max)
        return type(s) == "string" and #s > 0 and #s <= max
    end
    if not canPersist then diskError = "JSON persistence unavailable; session only." end
    if canPersist then
        local okExists, exists = pcall(isfile, path)
        local readPath = path
        if okExists and not exists and oldPath then
            local oldOk, oldExists = pcall(isfile, oldPath)
            if oldOk and oldExists then readPath, exists = oldPath, true end
        end
        if not okExists then blocked=true; diskError="Cannot inspect the learning file."
        elseif exists then
            local okRead, raw = pcall(readfile, readPath)
            if not okRead or type(raw) ~= "string" or #raw > maxFileSize then
                blocked=true; diskError="Cannot read learning file or file is too large."
            else
                local okDecode, saved = pcall(http.JSONDecode, http, raw)
                if not okDecode or type(saved) ~= "table" or saved.version ~= 1 or tonumber(saved.userId) ~= userId
                    or type(saved.aliases) ~= "table" or type(saved.prefs) ~= "table" or type(saved.remember) ~= "boolean" then
                    blocked=true; diskError="Learning file is invalid or belongs to another user."
                else
                    memory.remember = true
                    local seen = {}
                    for _, a in ipairs(saved.aliases) do
                        if #memory.aliases >= maxAliases then break end
                        if type(a)=="table" and validString(a.key,120) and validString(a.phrase,120) and validString(a.command,300)
                            and validString(a.tab,120) and validString(a.title,120) and validString(a.kind,40) and not seen[a.key] then
                            seen[a.key]=true
                            table.insert(memory.aliases, {key=a.key, phrase=a.phrase, command=a.command, tab=a.tab, title=a.title, kind=a.kind})
                        end
                    end
                    for _, p in ipairs(saved.prefs) do
                        if #memory.prefs >= maxPreferences then break end
                        if type(p)=="table" and validString(p.tab,120) and validString(p.title,120) and validString(p.kind,40)
                            and type(p.count)=="number" and p.count >= 1 and p.count <= 1000000 and p.count == math.floor(p.count) then
                            table.insert(memory.prefs,{tab=p.tab,title=p.title,kind=p.kind,count=p.count})
                        end
                    end
                end
            end
        end
    end
    local function save(force)
        if not canPersist then return false, diskError end
        if blocked and not force then return false, diskError end
        local okEncode, raw = pcall(http.JSONEncode, http, memory)
        if not okEncode or type(raw) ~= "string" or #raw > maxFileSize then diskError="Cannot encode learning JSON or limit exceeded."; return false,diskError end
        local okWrite, err = pcall(writefile, path, raw)
        if not okWrite or err == false then diskError="Cannot write learning file: " .. tostring(err); return false,diskError end
        blocked=false; diskError=nil
        return true
    end
    Cross.Learning = {}
    function Cross.Learning.State()
        return {UserId=userId, Path=path, Remember=memory.remember, AliasCount=#memory.aliases,
            PreferenceCount=#memory.prefs, Persistent=canPersist and not blocked and diskError==nil, Error=diskError}
    end
    function Cross.Learning.List()
        local result={}
        for _, a in ipairs(memory.aliases) do table.insert(result,{key=a.key,phrase=a.phrase,command=a.command,tab=a.tab,title=a.title,kind=a.kind}) end
        return result
    end
    function Cross.Learning.Preferences()
        local result={}
        for _, p in ipairs(memory.prefs) do table.insert(result,{tab=p.tab,title=p.title,kind=p.kind,count=p.count}) end
        table.sort(result,function(a,b) if a.count == b.count then return a.title < b.title end return a.count > b.count end)
        return result
    end
    function Cross.Learning.Find(key)
        for _, a in ipairs(Cross.Learning.List()) do if a.key == key then return a end end
        return nil
    end
    function Cross.Learning.Put(a)
        if type(a)~="table" or not validString(a.key,120) or not validString(a.phrase,120) or not validString(a.command,300)
            or not validString(a.tab,120) or not validString(a.title,120) or not validString(a.kind,40) then return false,"Invalid learning entry." end
        local idx
        for i, existing in ipairs(memory.aliases) do if existing.key == a.key then idx=i; break end end
        if not idx and #memory.aliases >= maxAliases then return false,"Learning limit reached (80 phrases)." end
        local item={key=a.key,phrase=a.phrase,command=a.command,tab=a.tab,title=a.title,kind=a.kind}
        if idx then memory.aliases[idx]=item else table.insert(memory.aliases,item) end
        local saved, err = save(false)
        return true, saved and "Saved to local JSON." or ("Session only: " .. tostring(err))
    end
    function Cross.Learning.Forget(key)
        for i, a in ipairs(memory.aliases) do
            if a.key == key then table.remove(memory.aliases,i); local ok,err=save(false); return true,ok and "Forgotten and saved." or ("Forgotten in session only: " .. tostring(err)) end
        end
        return false,"Phrase not found."
    end
    function Cross.Learning.SetRemember(on)
        if on ~= true then return false, "Learning is automatic; no settings switch is used." end
        memory.remember = true
        local saved, err = save(false)
        return true, saved and "Automatic learning enabled." or ("Session only: " .. tostring(err))
    end
    function Cross.Learning.Record(entry)
        if type(entry)~="table" then return end
        local tab,title,kind=entry.Tab,entry.Title,entry.Kind
        if not validString(tab,120) or not validString(title,120) or not validString(kind,40) then return end
        local item
        for _, p in ipairs(memory.prefs) do if p.tab==tab and p.title==title and p.kind==kind then item=p; break end end
        if not item then
            if #memory.prefs >= maxPreferences then return end
            item={tab=tab,title=title,kind=kind,count=0};table.insert(memory.prefs,item)
        end
        item.count=math.min(1000000,item.count+1)
        save(false)
    end
    function Cross.Learning.Clear()
        local old=memory
        memory=fresh()
        if not canPersist then return true,"Session memory cleared; local persistence was unavailable." end
        -- Explicit reset is the only operation allowed to replace a corrupt file.
        local ok, err = save(true)
        if not ok then memory=old; return false,"Could not clear the local file: " .. tostring(err) end
        return true,"Learning data cleared in local JSON."
    end
end
