-- made by @nfpw
local hooked = {}

for _, obj in pairs(filtergc("function", {}, false)) do
    if islclosure(obj) then
        local info = debug.getinfo(obj)
        if info and info.source then
            if info.source:match("Framework%.Interface%.Client") then
                local c, cons = pcall(debug.getconstants, obj)
                local uv, ups = pcall(debug.getupvalues, obj)
                if not c or not cons then continue end

                local is_log_watcher = false
                local is_fly_watcher = false
                
                for _, v in pairs(cons) do
                    if v == "GetLogHistory" then is_log_watcher = true end
                    if v == "BodyGyro" or v == "BodyVelocity" then is_fly_watcher = true end
                    if v == "VoiceChat3" or v == "FireServer" then is_log_watcher = true end
                end

                if is_log_watcher or is_fly_watcher then
                    if clonefunction then
                        local cloned = clonefunction(obj)
                        local u_ok, u_ups = pcall(debug.getupvalues, cloned)
                        if u_ok and u_ups then
                            for id, val in pairs(u_ups) do
                                if type(val) == "function" then
                                    pcall(debug.setupvalue, cloned, id, function() return true end)
                                end
                            end
                        end
                        hookfunction(obj, cloned)
                    else
                        hookfunction(obj, function() return true end)
                    end
                    warn("[@nfpw bypass] blocked AC function")
                end

                if uv and ups and type(ups[1]) == "function" and not hooked[ups[1]] then
                    local c2, cons2 = pcall(debug.getconstants, ups[1])
                    if c2 and cons2 then
                        for _, v in pairs(cons2) do
                            if v == "GetDescendants" or v == "Sound1" or v == "Part" then
                                hooked[ups[1]] = true
                                if clonefunction then
                                    local cloned_crash = clonefunction(ups[1])
                                    hookfunction(ups[1], cloned_crash)
                                else
                                    hookfunction(ups[1], function() return true end)
                                end
                                warn("[@nfpw bypass] blocked crash loop")
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

local lp = cloneref(game.GetService(game, "Players")).LocalPlayer

local function sigma_function(char)
    if not char or not char.Parent then return end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    for _, connection in pairs(getconnections(hrp.ChildAdded)) do
        pcall(function() connection:Disconnect() end)
        warn("[@nfpw bypass] fly connection removed")
    end
end

if lp.Character then
    sigma_function(lp.Character)
    lp.Character.Destroying:Connect(function()
        warn("[@nfpw bypass] character destroying, waiting for respawn")
    end)
end

lp.CharacterAdded:Connect(function(char)
    sigma_function(char)
    char.ChildAdded:Connect(function(c)
        if c.Name == "HumanoidRootPart" then
            sigma_function(char)
        end
    end)
end)

warn("[@nfpw bypass] anticheat disabled")
