--[[ xngot-studio · src/modules/25_localai/015_movement.lua
     lang : Luau · executor
     module : localai.movement
     role : bounded, confirmed, local-player movement capabilities for Cross
--]]
local function __xNgotCreateMovement(window, env, normalize)
    local M={Pending=nil, FlySpeed=40, Destroyed=false}
    local game=env.game
    local players,run,uis
    pcall(function() players=game:GetService("Players");run=game:GetService("RunService");uis=game:GetService("UserInputService") end)
    local player=players and players.LocalPlayer
    local function text(vi,v,e) return vi and v or e end
    local function disconnect(conn) if conn then pcall(function() conn:Disconnect() end) end end
    local function getCharacter()
        if not player then return nil end
        local ok,char,hum,root=pcall(function()
            local c=player.Character
            return c, c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
        end)
        if not ok or not char or not hum or not root then return nil end
        local alive=pcall(function() assert(hum.Health>0 and root.Parent and char.Parent) end)
        if not alive then return nil end
        return char,hum,root
    end
    function M.StopFly()
        disconnect(M.FlyConnection);M.FlyConnection=nil
        if M.Velocity then pcall(function() M.Velocity:Destroy() end);M.Velocity=nil end
        M.Flying=false
    end
    function M.StopNoclip()
        disconnect(M.NoclipConnection);M.NoclipConnection=nil
        disconnect(M.DescendantConnection);M.DescendantConnection=nil
        for part,was in pairs(M.Collision or {}) do
            pcall(function() if part.Parent and part.CanCollide==false then part.CanCollide=was end end)
        end
        M.Collision=nil;M.Noclip=false
    end
    function M.ResetSpeed()
        if M.SpeedHumanoid then
            pcall(function()
                if M.SpeedHumanoid.Parent and M.SpeedHumanoid.WalkSpeed==M.SpeedApplied then M.SpeedHumanoid.WalkSpeed=M.SpeedOriginal end
            end)
        end
        M.SpeedHumanoid=nil;M.SpeedOriginal=nil;M.SpeedApplied=nil
    end
    function M.StopAll()
        M.Pending=nil;M.StopFly();M.StopNoclip();M.ResetSpeed();disconnect(M.RemovingConnection);M.RemovingConnection=nil
        disconnect(M.DiedConnection);M.DiedConnection=nil;M.Character=nil
    end
    local function watch(char,hum)
        if M.Character==char then return end
        M.StopAll();M.Character=char
        if player and player.CharacterRemoving then
            M.RemovingConnection=player.CharacterRemoving:Connect(function(old) if old==M.Character then M.StopAll() end end)
        end
        if hum.Died then M.DiedConnection=hum.Died:Connect(function() M.StopAll() end) end
    end
    local function setSpeed(hum,value)
        if M.SpeedHumanoid and M.SpeedHumanoid~=hum then M.ResetSpeed() end
        if M.SpeedHumanoid==hum and hum.WalkSpeed~=M.SpeedApplied then M.SpeedOriginal=hum.WalkSpeed end
        if not M.SpeedHumanoid then M.SpeedHumanoid=hum;M.SpeedOriginal=hum.WalkSpeed end
        M.SpeedApplied=value;hum.WalkSpeed=value
    end
    local function startNoclip(char)
        if M.Noclip then return end
        assert(run and run.Stepped,"RunService unavailable")
        local saved={};M.Collision=saved;M.Noclip=true
        local function track(part)
            local ok,isPart=pcall(function() return part:IsA("BasePart") end)
            if ok and isPart and saved[part]==nil then
                local read,collide=pcall(function() return part.CanCollide end)
                if read then saved[part]=collide end
            end
        end
        for _,part in ipairs(char:GetDescendants()) do track(part) end
        M.DescendantConnection=char.DescendantAdded:Connect(track)
        M.NoclipConnection=run.Stepped:Connect(function()
            if M.Destroyed then return end
            for part in pairs(saved) do pcall(function() if part.Parent and part.CanCollide then part.CanCollide=false end end) end
        end)
    end
    local function startFly(char,hum,root)
        if M.Flying then return end
        assert(run and run.Heartbeat and env.Instance and env.Vector3,"Flight APIs unavailable")
        local force=env.Instance.new("BodyVelocity");M.Velocity=force
        force.Name="xNgotCrossFlight";force.MaxForce=env.Vector3.new(10000000,10000000,10000000)
        force.P=12500;force.Velocity=env.Vector3.new(0,0,0);force.Parent=root
        M.Flying=true
        M.FlyConnection=run.Heartbeat:Connect(function()
            local ok,reason=pcall(function()
                if M.Destroyed or not root.Parent or not hum.Parent or hum.Health<=0 then error("character unavailable") end
                local direction=hum.MoveDirection
                local y=0
                local camera=env.workspace and env.workspace.CurrentCamera
                if camera then
                    local look=camera.CFrame.LookVector
                    local flat=env.Vector3.new(look.X,0,look.Z)
                    if flat.Magnitude>0.001 then y=direction:Dot(flat.Unit)*look.Y end
                end
                local up,down=false,false
                if uis and env.Enum then
                    pcall(function() up=uis:IsKeyDown(env.Enum.KeyCode.Space);down=uis:IsKeyDown(env.Enum.KeyCode.LeftControl) or uis:IsKeyDown(env.Enum.KeyCode.C) end)
                end
                if hum.Jump or up then y=1 elseif down then y=-1 end
                force.Velocity=env.Vector3.new(direction.X,y,direction.Z)*M.FlySpeed
            end)
            if not ok then M.StopFly();if type(M.OnError)=="function" then pcall(M.OnError,reason) end end
        end)
    end
    function M.Apply(p,vi)
        if M.Destroyed then return false,text(vi,"Cửa sổ đã đóng.","Window is closed.") end
        if type(p)~="table" or (p.kind~="speed" and p.kind~="flyspeed" and p.kind~="fly" and p.kind~="noclip") then return false,text(vi,"Yêu cầu không hợp lệ.","Invalid request.") end
        if p.kind=="speed" or p.kind=="flyspeed" then
            if type(p.value)~="number" or p.value~=math.floor(p.value) or p.value<4 or p.value>100 then return false,text(vi,"Tốc độ phải là số nguyên từ 4 đến 100.","Speed must be an integer from 4 to 100.") end
        end
        local char,hum,root=getCharacter()
        if not char or char~=p.char or hum~=p.hum or root~=p.root then return false,text(vi,"Nhân vật đã thay đổi hoặc chưa sẵn sàng; hãy yêu cầu lại.","Character changed or is not ready; request again.") end
        local ok,err=pcall(function()
            watch(char,hum)
            if p.kind=="speed" then setSpeed(hum,p.value)
            elseif p.kind=="noclip" then startNoclip(char)
            elseif p.kind=="fly" then startFly(char,hum,root)
            elseif p.kind=="flyspeed" then M.FlySpeed=p.value
            else error("unsupported") end
        end)
        if not ok then M.StopAll();return false,text(vi,"Không thể áp dụng; đã dọn trạng thái. ","Could not apply; cleaned up. ")..tostring(err):sub(1,150) end
        if p.kind=="speed" then return true,text(vi,"Đã đặt WalkSpeed phía client: ","Client WalkSpeed set to: ")..p.value..text(vi,". Game có thể ghi đè.",". The game may override it.") end
        if p.kind=="flyspeed" then return true,text(vi,"Đã đặt tốc độ bay: ","Flight speed set to: ")..p.value end
        if p.kind=="noclip" then return true,text(vi,"Đã bắt đầu noclip phía client; server có thể chặn. Nói 'tắt noclip' để dừng.","Client noclip started; the server may block it. Say 'disable noclip' to stop.") end
        return true,text(vi,"Đã bật bay phía client; di chuyển bằng nút hướng, nhìn lên/xuống để đổi độ cao; Space/nhảy để lên, Ctrl/C để xuống. Nói 'tắt bay' để dừng. Game có thể chặn.","Client flight enabled; move and look up/down for altitude, Space/jump to rise, Ctrl/C to descend. Say 'disable fly' to stop. The game may block it.")
    end
    function M.Route(prompt,yes,no,permitted,vi)
        local n=normalize(prompt)
        if n=="tat bay" or n=="tat fly" or n=="dung bay" or n=="disable fly" or n=="stop flying" or n=="fly off" or n=="unfly" then M.Pending=nil;M.StopFly();return true,text(vi,"Đã dừng bay.","Flight stopped.") end
        if n=="tat noclip" or n=="tat xuyen tuong" or n=="dung noclip" or n=="disable noclip" or n=="noclip off" or n=="clip" then M.Pending=nil;M.StopNoclip();return true,text(vi,"Đã dừng noclip và thử khôi phục trạng thái va chạm đã lưu.","Noclip stopped; attempted to restore saved collision states.") end
        if n=="dat lai toc do" or n=="reset speed" or n=="tat toc do" then M.Pending=nil;M.ResetSpeed();return true,text(vi,"Đã khôi phục tốc độ nếu giá trị chưa bị game thay đổi.","Speed restored if the game had not changed it.") end
        if n=="dung tat ca di chuyen" or n=="stop movement" then M.StopAll();return true,text(vi,"Đã dừng các tính năng di chuyển của Cross.","Cross movement features stopped.") end
        if M.Pending then
            local p=M.Pending
            if no then M.Pending=nil;return true,text(vi,"Đã hủy, không thay đổi nhân vật.","Cancelled; character unchanged.") end
            if not permitted then M.Pending=nil;return true,text(vi,"Quyền nhân vật đã tắt; yêu cầu đã hủy.","Character permission is off; request cancelled.") end
            if os.clock()>p.expires then M.Pending=nil;return true,text(vi,"Xác nhận đã hết hạn; hãy yêu cầu lại.","Confirmation expired; request again.") end
            if not yes then return true,text(vi,"Đang chờ xác nhận. Trả lời Có hoặc Không.","Confirmation pending. Reply Yes or No.") end
            M.Pending=nil;local _,answer=M.Apply(p,vi);return true,answer
        end
        local kind,value
        if n=="bat bay" or n=="bat fly" or n=="bay" or n=="fly" or n=="enable fly" or n=="fly on" then kind="fly"
        elseif n=="bat noclip" or n=="bat xuyen tuong" or n=="di xuyen tuong" or n=="noclip" or n=="enable noclip" or n=="noclip on" then kind="noclip"
        else
            -- Only unsigned whole numbers in the original input; do not silently turn -10 into 10.
            local flyValue=n:match("^toc do bay (%d+)$") or n:match("^fly speed (%d+)$") or n:match("^set fly speed (%d+)$")
            local walkValue=n:match("^toc do (%d+)$") or n:match("^dat toc do (%d+)$") or n:match("^chinh toc do (%d+)$") or n:match("^toc do chay (%d+)$") or n:match("^speed (%d+)$") or n:match("^set speed (%d+)$") or n:match("^walkspeed (%d+)$") or n:match("^set walk speed (%d+)$")
            if flyValue or walkValue then
                if prompt:find("[-%.+]") then return true,text(vi,"Tốc độ phải là số nguyên từ 4 đến 100.","Speed must be an integer from 4 to 100.") end
                kind=flyValue and "flyspeed" or "speed";value=tonumber(flyValue or walkValue)
                if not value or value<4 or value>100 then return true,text(vi,"Tốc độ phải từ 4 đến 100.","Speed must be between 4 and 100.") end
            end
        end
        if not kind then return false end
        if not permitted then return true,text(vi,"Quyền điều khiển nhân vật đang tắt.","Character movement permission is disabled.") end
        local char,hum,root=getCharacter()
        if not char then return true,text(vi,"Nhân vật chưa sẵn sàng. Hãy thử lại sau khi hồi sinh.","Character is not ready. Try again after spawning.") end
        M.Pending={kind=kind,value=value,char=char,hum=hum,root=root,expires=os.clock()+60}
        local detail=({speed=text(vi,"đặt tốc độ đi thành ","set walk speed to ")..tostring(value),flyspeed=text(vi,"đặt tốc độ bay thành ","set flight speed to ")..tostring(value),fly=text(vi,"bật bay","enable flight"),noclip=text(vi,"bật noclip","enable noclip")})[kind]
        return true,text(vi,"Bạn có muốn ","Do you want to ")..detail..text(vi," cho nhân vật của bạn? Trả lời Có hoặc Không."," for your character? Reply Yes or No.")
    end
    function M.Destroy() if M.Destroyed then return end;M.StopAll();M.Destroyed=true end
    return M
end
