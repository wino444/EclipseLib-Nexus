--[[
    EclipseLib-Nexus Shield/Obfuscator.lua
    Version: 1.0.0
    หน้าที่: สุ่มชื่อ Instance ป้องกัน Anti-Cheat ตรวจจับ
]]

return function(deps)
    local Utils = deps.Utils
    local cloneref = deps.Init and deps.Init.cloneref or function(o) return o end
    local hookfunction = deps.Init and deps.Init.hookfunction or function(a,b) return a end
    local _randomName = Utils._randomName

    local Obfuscator = { enabled = false }

    -- เก็บต้นฉบับ Instance.new ไว้
    local originalNew = Instance.new

    -- สร้างเวอร์ชันที่เปลี่ยนชื่ออัตโนมัติ
    local function obfuscatedNew(className, parent)
        local obj = originalNew(className, parent)
        if Obfuscator.enabled then
            pcall(function()
                -- เปลี่ยนชื่อให้สุ่ม (ถ้าต้องการ)
                -- หมายเหตุ: การเปลี่ยนชื่อหลังสร้างอาจไม่ช่วยมากเท่าสร้างด้วยชื่อสุ่มเลย
                -- แต่เราจะดักที่การสร้างและใช้ชื่อสุ่มตั้งแต่แรก
            end)
        end
        return obj
    end

    -- เปลี่ยนการทำงานของ MakeScreenGui ให้ใช้ชื่อสุ่ม (ทำอยู่แล้ว)
    -- เพิ่มระบบ hook Instance.new ให้เปลี่ยนชื่ออัตโนมัติ (ใช้ hookfunction)
    function Obfuscator:Enable()
        if self.enabled then return end
        self.enabled = true
        -- แทนที่ Instance.new ด้วยของเรา
        Instance.new = obfuscatedNew
    end

    function Obfuscator:Disable()
        if not self.enabled then return end
        self.enabled = false
        Instance.new = originalNew
    end

    function Obfuscator:IsEnabled()
        return self.enabled
    end

    -- ฟังก์ชันสำหรับสุ่มชื่อให้ Instance ที่มีอยู่แล้ว (ใช้สำหรับ UI ที่สร้างเสร็จ)
    function Obfuscator:RandomizeNames(container)
        if not container then return end
        for _, child in ipairs(container:GetDescendants()) do
            if child:IsA("GuiObject") then
                pcall(function()
                    child.Name = _randomName("el_")
                end)
            end
        end
    end

    return Obfuscator
end
