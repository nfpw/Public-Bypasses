local oth_hook = false
local b = nil

local function c(d, e)
    if oth_hook and oth and iscclosure(d) then
        return oth.hook(d, e)
    end
    return hookfunction(d, e)
end

setthreadidentity(2)

local f = nil
local g = nil

for _, h in pairs(filtergc("table", {}, false)) do
    if not f and rawget(h, "Detected") and typeof(h.Detected) == "function" then
        f = h.Detected
        c(f, function(i, j, k) 
            return true 
        end)
    end
    
    if not g and rawget(h, "Variables") and rawget(h, "Process") and rawget(h, "Kill") and typeof(h.Kill) == "function" then
        g = h.Kill
        c(g, function(l) 
            return
        end)
    end
    if f and g then break end
end

b = f 

local m; m = c(getrenv().debug.info, newcclosure(function(...)
    local n = ...

    if b and n == b then
        return coroutine.yield(coroutine.running())
    end

    return m(...)
end))

setthreadidentity(8)
