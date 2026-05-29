--[[
    EclipseLib-Nexus Shield/MemoryGuard.lua
    Version: 1.0.0
    หน้าที่: Updater กลาง ป้องกัน Heartbeat Leak
]]

return function(deps)
    local Services = deps.Services
    local RunService = Services.RunService

    local MemoryGuard = {}
    local updaters = {} -- {element, updateFn}

    -- เริ่ม Heartbeat กลางเพียงตัวเดียว
    local heartbeatConnection
    local function startHeartbeat()
        if heartbeatConnection then return end
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            -- ทำสำเนาไว้กัน error ตอนลูป
            local copy = {}
            for _, v in ipairs(updaters) do
                table.insert(copy, v)
            end
            for _, v in ipairs(copy) do
                pcall(v[2], v[1])
            end
        end)
    end

    -- หยุด Heartbeat เมื่อไม่มี updaters
    local function stopHeartbeat()
        if #updaters == 0 and heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
    end

    function MemoryGuard:Register(element, updateFn)
        table.insert(updaters, { element, updateFn })
        startHeartbeat()
        -- ผูก Destroying ให้ถอดตัวเองเมื่อ element ถูกทำลาย
        if element.Destroying then
            local conn
            conn = element.Destroying:Connect(function()
                self:Unregister(element)
                conn:Disconnect()
            end)
        end
    end

    function MemoryGuard:Unregister(element)
        for i = #updaters, 1, -1 do
            if updaters[i][1] == element then
                table.remove(updaters, i)
                break
            end
        end
        stopHeartbeat()
    end

    function MemoryGuard:Clear()
        updaters = {}
        stopHeartbeat()
    end

    return MemoryGuard
end
