--[[ xngot-studio · src/modules/25_localai/020_ui.lua
     lang : Luau · executor
     module : localai.ui
     role : attach offline capabilities to the existing Cross assistant without a new tab
--]]
local function __xNgotMountLocalAI(window)
    local hs,uid
    pcall(function() hs=game:GetService("HttpService");uid=game:GetService("Players").LocalPlayer.UserId end)
    local engine=__xNgotCreateLocalAI(window,{http=hs,userId=uid,game=game,isfile=isfile,readfile=readfile,writefile=writefile,delfile=delfile,makefolder=makefolder})
    window.LocalAI=engine
    engine.Movement=__xNgotCreateMovement(window,{game=game,Instance=Instance,Vector3=Vector3,Enum=Enum,workspace=workspace},engine.NLP.Normalize)
    engine.Movement.OnError=function(err)
        engine.Diagnostics.Error("Movement",err)
        pcall(function() window:NotifyIsland("Cross", "Bay đã dừng do lỗi hoặc nhân vật không còn sẵn sàng.", "warn", 4) end)
    end
    -- New installations follow Cross's automatic local learning. Never change an existing V2 preference or damaged file.
    if engine.Memory.Available and not engine.Memory.Blocked and engine.Memory.Revision==nil then
        engine.Memory.SetEnabled(true)
    end
    engine.Music.ConnectHistory()
    engine.Performance.SetMonitor(true,function(text)
        local api=window.DynamicIsland
        if engine.Dead or not api or type(api.State)~="function" then return end
        local ok,state=pcall(api.State,api)
        if ok and type(state)=="table" and state.Cross then
            local langOK,info=pcall(function() return type(api.AiState)=="function" and api:AiState() end)
            if langOK and type(info)=="table" and info.Language~="en" then text=engine.Performance.Vietnamese(text) end
            pcall(function() window:NotifyIsland("Cross · FPS / Ping",text,"warn",4) end)
        end
    end)
    function engine.RouteCross(prompt, yes, no, uiAllowed, vi, oldLearned, bodyAllowed)
        if engine.Dead or type(prompt)~="string" or #prompt>500 then return false end
        local n=engine.NLP.Normalize(prompt)
        local function msg(v,e) return vi and v or e end
        local function result(ok,detail)
            local text=tostring(detail or (ok and msg("Đã thực hiện.","Done.") or msg("Không thực hiện được.","Could not complete.")))
            if vi then
                local translations={
                    ["Macro complete."]="Đã hoàn thành các bước.", ["Macro paused."]="Đã tạm dừng; nói 'tiếp tục macro' để tiếp tục.",
                    ["Macro cancelled; completed steps are not undone."]="Đã hủy; các bước đã chạy không được hoàn tác.",
                    ["Cancelled; no action performed."]="Đã hủy bước đang chờ.", ["Confirmation expired."]="Xác nhận đã hết hạn; hãy yêu cầu lại.",
                    ["Macro saved; nothing executed."]="Đã ghi nhớ macro; chưa chạy thao tác nào.", ["Macro removed."]="Đã xóa macro.",
                    ["Added favorite."]="Đã thêm bài yêu thích.", ["Favorite removed."]="Đã bỏ bài yêu thích.", ["Added to playlist."]="Đã thêm bài vào playlist.",
                    ["Track removed from playlist."]="Đã bỏ bài khỏi playlist.", ["Playlist removed."]="Đã xóa playlist.",
                    ["Another action is pending."]="Đang có thao tác khác chờ xử lý.", ["Macro not found."]="Không tìm thấy macro.",
                    ["No matching registered control."]="Không tìm thấy chức năng đã đăng ký.",
                    ["Multiple matches; include tab name."]="Có nhiều chức năng trùng; hãy ghi thêm tên tab.",
                    ["Control missing, renamed or ambiguous; specify its current tab and title."]="Chức năng đã mất, đổi tên hoặc bị trùng; hãy ghi lại tên tab và chức năng hiện tại.",
                    ["Control is locked or cannot be checked."]="Chức năng đang khóa hoặc không thể kiểm tra.",
                    ["Negated request is not a permitted action."]="Không chạy yêu cầu mang ý phủ định.",
                    ["Specify bật/tắt or open/close explicitly."]="Hãy ghi rõ bật hay tắt, mở hay đóng.",
                    ["Specify bấm/click explicitly."]="Hãy ghi rõ bấm chức năng nào.",
                    ["This Local AI action supports Toggle, Section and Button only; other existing controls remain available via UI/Cross."]="Chuỗi chỉ hỗ trợ Toggle, Section và Button; các control khác vẫn dùng được qua Cross.",
                    ["Macro action denied: sensitive name or missing explicit button permission."]="Không cho phép bước này: tên nhạy cảm hoặc Button chưa được tác giả cấp quyền macro.",
                    ["Macro action is no longer permitted."]="Bước này không còn được cấp quyền.", ["Macro permission revoked."]="Quyền macro đã bị thu hồi.",
                    ["Macro must contain 1–10 actions."]="Chuỗi phải có từ 1 đến 10 bước.", ["Unsafe macro text."]="Nội dung bước không hợp lệ hoặc có thể nhạy cảm.",
                    ["Invalid macro name."]="Tên macro không hợp lệ.", ["Macro already exists."]="Tên macro đã tồn tại.", ["Macro limit reached."]="Đã đạt giới hạn macro.",
                    ["No paused macro."]="Không có macro đang tạm dừng.", ["No macro running."]="Không có macro đang chạy.",
                    ["Target changed; request the action again."]="Chức năng đã thay đổi; hãy yêu cầu lại.",
                    ["Action failed; callback may have partially run."]="Thao tác lỗi; callback có thể đã chạy một phần.", ["Action completed."]="Đã thực hiện.",
                    ["Invalid playlist name."]="Tên playlist không hợp lệ.", ["Playlist limit reached."]="Đã đạt giới hạn playlist.",
                    ["Playlist track limit reached."]="Playlist đã đạt giới hạn bài hát.", ["Track already in playlist."]="Bài đã có trong playlist.",
                    ["Already a favorite."]="Bài đã có trong yêu thích.", ["Favorites limit reached."]="Đã đạt giới hạn bài yêu thích.",
                    ["Favorite not found."]="Không tìm thấy bài yêu thích.", ["Playlist not found."]="Không tìm thấy playlist.",
                    ["Playlist or track not found."]="Không tìm thấy playlist hoặc bài hát.", ["Playlist is empty or missing."]="Playlist trống hoặc không tồn tại.",
                    ["Downloaded music catalog unavailable."]="Không có danh sách nhạc đã tải.", ["Cannot read downloaded music."]="Không đọc được nhạc đã tải.",
                    ["Ambiguous song; use a more specific name."]="Tên bài bị trùng; hãy ghi rõ hơn.", ["Ambiguous song."]="Tên bài bị trùng; hãy ghi rõ hơn.",
                    ["Downloaded files unavailable."]="Không đọc được danh sách file đã tải.", ["Saved track missing or ambiguous in downloaded files."]="Không tìm thấy bài đã lưu hoặc có nhiều file trùng.",
                    ["Local player unavailable."]="Music Player chưa sẵn sàng.", ["File not playable."]="Không thể phát file này.",
                    ["Disable Auto play in Music settings before offline playback."]="Hãy tắt Music Auto trong cài đặt nhạc trước khi phát file đã tải.",
                    ["Executor cannot load local audio."]="Executor không hỗ trợ nạp audio local.", ["Cannot load cached audio."]="Không nạp được file audio đã tải.",
                    ["Tab unavailable."]="Không mở được tab.", ["Tab not found among registered controls."]="Không tìm thấy tab trong các control đã đăng ký.",
                    ["Multiple matching tabs."]="Có nhiều tab trùng tên; hãy ghi rõ hơn.",
                    ["Memory changed externally; original preserved."]="File bộ nhớ đã thay đổi bên ngoài; đã giữ nguyên file.",
                    ["Memory invalid, oversized or belongs to another player; original preserved."]="Bộ nhớ lỗi, quá lớn hoặc thuộc tài khoản khác; đã giữ nguyên file.",

                }
                local macro,i,total,action,tab,title=text:match("^Macro (.-) step (%d+)/(%d+): (.-) (.-) / (.-)%. Confirm or cancel%.$")
                if macro then
                    local verbs={on="bật/mở",off="tắt/đóng",press="bấm"}
                    text="Bước "..i.."/"..total..": "..(verbs[action] or action).." "..tab.." / "..title..". Xác nhận Có hoặc Không."
                else
                    local count=text:match("^(%d+) downloaded tracks found offline%. Online search was not used%.$")
                    local pl=text:match("^Playlist playback requested: (.+)$")
                    local opened=text:match("^Opened tab: (.+)$")
                    local action,target=text:match("^Confirm (.-) — (.-)%? Reply yes/no%.$")
                    if count then text="Tìm thấy "..count.." bài đã tải; không tìm online."
                    elseif pl then text="Đã yêu cầu phát playlist: "..pl..". Việc phát thực tế phụ thuộc client."
                    elseif opened then text="Đã mở tab: "..opened
                    elseif action then local verbs={on="bật/mở",off="tắt/đóng",press="bấm"};text="Bạn có muốn "..(verbs[action] or action).." "..target.."? Trả lời Có hoặc Không."
                    else text=translations[text] or text end
                end
            end
            return true,text
        end
        local emergencyStop = n=="tat bay" or n=="tat fly" or n=="dung bay" or n=="disable fly" or n=="stop flying" or n=="fly off" or n=="unfly"
            or n=="tat noclip" or n=="tat xuyen tuong" or n=="dung noclip" or n=="disable noclip" or n=="noclip off" or n=="clip"
            or n=="dat lai toc do" or n=="reset speed" or n=="tat toc do" or n=="dung tat ca di chuyen" or n=="stop movement"
        if engine.Movement and (not engine.Pending or emergencyStop) then
            local handled,answer=engine.Movement.Route(prompt,yes,no,bodyAllowed,vi)
            if handled then return true,answer end
        end
        if engine.Macro.Active and (n=="tam dung macro" or n=="pause macro") then return result(engine.Macro.Pause()) end
        if engine.Macro.Active and (n=="huy macro" or n=="cancel macro") then return result(engine.Macro.Cancel()) end
        if engine.Pending then
            if not uiAllowed then engine.Macro.Cancel();return true,msg("Quyền UI đã tắt; yêu cầu đã hủy.","UI permission is off; the request was cancelled.") end
            if yes or no then return result(engine.Core.Confirm(yes)) end
            return true,msg("Đang chờ xác nhận. Trả lời Có hoặc Không; có thể tạm dừng/hủy macro.","Confirmation pending. Reply Yes or No; you can pause/cancel the macro.")
        end
        if n=="tiep tuc macro" or n=="resume macro" then
            if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end
            return result(engine.Macro.Resume())
        end
        if n=="chan doan" or n=="kiem tra loi" or n=="diagnostics" then
            local d=engine.Diagnostics; local memory=engine.Memory
            return true,msg("Cross kiểm tra: ","Cross check: ")..(window.DynamicIsland and msg("Island sẵn sàng", "Island available") or msg("không có Island", "Island unavailable"))
                .." · "..msg("control: ","controls: ")..tostring(#(window._AIControls or {}))
                .." · "..msg("lỗi Local AI gần nhất: ","last Local AI error: ")..tostring(d.Last or msg("chưa ghi nhận","none observed"))
                ..(memory.Blocked and (" · "..tostring(memory.Error)) or "")
                ..msg(". Chỉ kiểm tra lỗi quan sát được, không tự sửa script.",". Only observed errors are reported; source is not modified.")
        end
        if n=="hieu suat" or n=="performance" or n=="fps ping" then local text=engine.Performance.Analyze();return true,vi and engine.Performance.Vietnamese(text) or text end
        if n:match("^giai thich ") or n:match("^explain ") then
            if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end
            local matches=engine.Commands.Find(n)
            if #matches~=1 then return true,msg(#matches==0 and "Không tìm thấy control." or "Có nhiều control trùng; hãy ghi thêm tên tab.",#matches==0 and "Control not found." or "Multiple controls match; include the tab.") end
            local e=matches[1]
            local guide={Toggle="bật hoặc tắt",Section="mở hoặc đóng mục",Button="gọi callback gốc",Slider="thay đổi giá trị số",Dropdown="chọn tùy chọn",Input="nhập văn bản",Colorpicker="chọn màu",Paragraph="hiển thị văn bản",Code="hiển thị mã"}
            if vi then return true,e.Tab.." / "..e.Title.." ["..e.Kind.."]: "..(guide[e.Kind] or "control của thư viện")..". Tác dụng cụ thể phụ thuộc script; xem mô tả của tác giả." end
            return true,engine.Explainer.Describe(n)
        end
        if n:match("^mo tab ") or n:match("^open tab ") then
            if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end
            return result(engine.Core.Ask(n))
        end
        if n:match("^tim chuc nang ") or n:match("^find control ") then
            if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end
            local matches=engine.Commands.Find(n)
            if #matches~=1 then return true,msg(#matches==0 and "Không tìm thấy chức năng." or "Có nhiều chức năng trùng; hãy ghi thêm tên tab.",#matches==0 and "Control not found." or "Multiple controls match; include the tab.") end
            local e=matches[1]
            if not window:SelectTab(e.Tab) then return true,msg("Không mở được tab.","Tab unavailable.") end
            return true,msg("Đã mở tab chứa: ","Opened tab containing: ")..e.Tab.." / "..e.Title.." ["..e.Kind.."]"
        end
        local name
        -- Keep the separator in the original input; names and action text are normalized for matching.
        if n:match("^tao macro ") or n:match("^create macro ") then
            if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end
            local left,right=prompt:match("^(.-):%s*(.+)$")
            if not left then return true,msg("Nhập: tạo macro tên: bật Tab Chức năng; tắt Tab Chức năng", "Use: create macro name: enable Tab Control; disable Tab Control") end
            name=engine.NLP.Normalize(left):gsub("^tao macro ",""):gsub("^create macro ","")
            local steps={};for step in right:gmatch("[^;]+") do steps[#steps+1]=step:match("^%s*(.-)%s*$") end
            return result(engine.Macro.Save(name,steps))
        end
        -- Natural one-off sequences do not require creating or naming a macro.
        local first,second=n:match("^(.-) roi (.+)$")
        if not first then first,second=n:match("^(.-) then (.+)$") end
        local function actionStart(x)
            return x and (x:match("^bat ") or x:match("^tat ") or x:match("^bam ") or x:match("^nhan ") or x:match("^enable ") or x:match("^disable ") or x:match("^press ") or x:match("^click "))
        end
        if actionStart(first) and actionStart(second) and not n:find(" nhac",1,true) and not n:find(" music",1,true) then
            if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end
            local steps={first};for part in (second.." roi "):gmatch("(.-) roi ") do steps[#steps+1]=part end
            return result(engine.Macro.Begin(steps))
        end
        name=n:match("^chay macro (.+)$") or n:match("^run macro (.+)$")
        if name then if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end;return result(engine.Macro.Start(name)) end
        name=n:match("^xoa macro (.+)$") or n:match("^delete macro (.+)$")
        if name then return result(engine.Macro.Delete(name)) end
        if n=="danh sach macro" or n=="list macros" then
            local rows={};for _,m in ipairs(engine.Memory.Data.macros) do rows[#rows+1]=tostring(m.name).." ("..#m.steps..")" end
            return true,#rows>0 and table.concat(rows, "; ") or msg("Chưa có macro.","No macros yet.")
        end
        local song
        local listName,listSong=n:match("^them (.-) vao playlist (.+)$")
        if listName then return result(engine.Music.Playlist(listSong,listName)) end
        listName,listSong=n:match("^remove (.-) from playlist (.+)$")
        if listName then return result(engine.Music.RemoveFromPlaylist(listSong,listName)) end
        listName,listSong=n:match("^add (.-) to playlist (.+)$")
        if listName then return result(engine.Music.Playlist(listSong,listName)) end
        listName,listSong=n:match("^bo (.-) khoi playlist (.+)$")
        if listName then return result(engine.Music.RemoveFromPlaylist(listSong,listName)) end
        listName=n:match("^xoa playlist (.+)$") or n:match("^delete playlist (.+)$")
        if listName then return result(engine.Music.RemovePlaylist(listName)) end
        listName=n:match("^phat playlist (.+)$") or n:match("^play playlist (.+)$") or n:match("^next playlist (.+)$") or n:match("^bai tiep playlist (.+)$")
        if listName then return result(engine.Music.PlaylistPlay(listName,1)) end
        if n=="danh sach playlist" or n=="playlists" then
            local rows={};for _,p in ipairs(engine.Memory.Data.playlists) do rows[#rows+1]=p.name.." ("..#p.tracks..")" end
            return true,#rows>0 and table.concat(rows,"; ") or msg("Chưa có playlist.","No playlists yet.")
        end
        song=n:match("^them (.-) vao yeu thich$") or n:match("^them yeu thich (.+)$") or n:match("^favorite (.+)$")
        if song then return result(engine.Music.Favorite(song)) end
        song=n:match("^bo yeu thich (.+)$") or n:match("^unfavorite (.+)$")
        if song then return result(engine.Music.RemoveFavorite(song)) end
        if n=="danh sach yeu thich" or n=="favorites" then
            local rows={};for _,t in ipairs(engine.Memory.Data.favorites) do rows[#rows+1]=t.name.." — "..t.artist end
            return true,#rows>0 and table.concat(rows,"; ") or msg("Chưa có bài yêu thích.","No favorites yet.")
        end
        if n=="lich su nhac" or n=="music history" then
            local rows={};local h=engine.Memory.Data.history;for i=math.max(1,#h-9),#h do rows[#rows+1]=h[i].name end
            return true,#rows>0 and table.concat(rows,"; ") or msg("Chưa ghi nhận lịch sử nhạc.","No music history recorded.")
        end
        if not oldLearned and engine.Learning.Find(prompt) then
            if not uiAllowed then return true,msg("Quyền UI đang tắt.","UI permission is off.") end
            return result(engine.Core.Ask(prompt))
        end
        return false
    end
    return engine
end
