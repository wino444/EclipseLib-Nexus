--[[
    EclipseLib-Nexus Loader
    Version: 1.0.0
    ส่วนหนึ่งของ EclipseLib-Nexus โดย wino444 & Deekseek AI Lab
    หน้าที่: โหลดทุกโมดูลตามลำดับ + ฉีด Dependency + ส่งคืน EclipseLib Object
]]

local NexusPath = "EclipseLib-Nexus/" -- เปลี่ยนตาม path จริงของโฟลเดอร์

-- ฟังก์ชันภายในสำหรับโหลดไฟล์ Lua
local function loadModule(relativePath)
    local fullPath = NexusPath .. relativePath
    local success, code = pcall(function()
        if not isfile or not readfile then
            error("Executor ไม่รองรับ filesystem (isfile/readfile)")
        end
        if not isfile(fullPath) then
            error("ไม่พบไฟล์: " .. fullPath)
        end
        return readfile(fullPath)
    end)
    if not success or not code then
        warn("❌ โหลดไฟล์ไม่สำเร็จ: " .. fullPath .. " | เหตุผล: " .. tostring(code))
        return nil
    end
    local fn, err = loadstring(code)
    if not fn then
        warn("❌ Compile error ใน " .. fullPath .. ": " .. err)
        return nil
    end
    local ok, result = pcall(fn)
    if not ok then
        warn("❌ Runtime error ใน " .. fullPath .. ": " .. tostring(result))
        return nil
    end
    return result
end

-- ===== ลำดับการโหลดตาม blueprint =====

-- 1. Core/Init.lua (จำเป็นสูงสุด)
local Init = loadModule("Core/Init.lua")
if not Init then
    error("EclipseLib-Nexus: Init.lua is required. หยุดการทำงาน.")
end

-- 2. Core/Utils.lua
local Utils = loadModule("Core/Utils.lua")
if Utils and Utils.Inject then
    Utils.Inject(Init.Services)
end

-- 3. Core/Theme.lua
local ThemeModule = loadModule("Core/Theme.lua")

-- 4. Shield/MemoryGuard.lua
local MemoryGuard = loadModule("Shield/MemoryGuard.lua")

-- 5. Shield/Obfuscator.lua (optional)
local Obfuscator = loadModule("Shield/Obfuscator.lua")

-- 6. Systems
local Notification = loadModule("Systems/Notification.lua")
local ConfigManager = loadModule("Systems/ConfigManager.lua")
local KeySystem = loadModule("Systems/KeySystem.lua")
local IntroEngine = loadModule("Systems/IntroEngine.lua")

-- 7. Components
local BaseCard = loadModule("Components/BaseCard.lua")
local TabBar = loadModule("Components/TabBar.lua")
local TabFrame = loadModule("Components/TabFrame.lua")

-- 8. Elements (โหลดทุกไฟล์ใน Elements/ อัตโนมัติ)
local Elements = {}
if isfolder and listfiles then
    local elementPath = NexusPath .. "Components/Elements"
    if isfolder(elementPath) then
        local files = listfiles(elementPath)
        for _, file in ipairs(files) do
            if file:match("%.lua$") then
                local name = file:match("([^/\\]+)%.lua$")
                local module = loadModule("Components/Elements/" .. name .. ".lua")
                if module then
                    Elements[name] = module
                end
            end
        end
    end
end

-- 9. Shield/MobileOptimizer.lua (โหลดหลัง Elements)
local MobileOptimizer = loadModule("Shield/MobileOptimizer.lua")
if MobileOptimizer and MobileOptimizer.Toggle then
    -- อ่านค่าเริ่มต้นจาก SafeGlobal หรือค่า default
    local initState = Init.SafeGlobal:Get("EclipseNexus_MobileOptimize", true)
    MobileOptimizer:Toggle(initState)
end

-- 10. Core/Window.lua (เป็นตัวสุดท้ายที่ต้องรับ dependencies ทั้งหมด)
local WindowModule = loadModule("Core/Window.lua")
local Window
if WindowModule then
    -- ถ้า Window เป็นฟังก์ชัน (แบบที่เราเขียนไว้) จะต้องเรียก Inject ก่อน
    if type(WindowModule) == "table" and WindowModule.Inject then
        WindowModule.Inject({
            Utils = Utils,
            Theme = ThemeModule,
            Notification = Notification,
            ConfigManager = ConfigManager,
            KeySystem = KeySystem,
            IntroEngine = IntroEngine,
            BaseCard = BaseCard,
            TabBar = TabBar,
            TabFrame = TabFrame,
            Elements = Elements,
            MemoryGuard = MemoryGuard,
            Obfuscator = Obfuscator,
            MobileOptimizer = MobileOptimizer,
            SafeGlobal = Init.SafeGlobal,
            Services = Init.Services,
        })
        Window = WindowModule
    elseif type(WindowModule) == "function" then
        -- ถ้า WindowModule เป็นฟังก์ชัน constructor เรียกเลย
        Window = WindowModule({
            Utils = Utils,
            Theme = ThemeModule,
            Notification = Notification,
            ConfigManager = ConfigManager,
            KeySystem = KeySystem,
            IntroEngine = IntroEngine,
            BaseCard = BaseCard,
            TabBar = TabBar,
            TabFrame = TabFrame,
            Elements = Elements,
            MemoryGuard = MemoryGuard,
            Obfuscator = Obfuscator,
            MobileOptimizer = MobileOptimizer,
            SafeGlobal = Init.SafeGlobal,
            Services = Init.Services,
        })
    else
        warn("Window module มีรูปแบบไม่ถูกต้อง")
    end
end

-- ===== สร้าง EclipseLib Object =====
local EclipseLib = {
    -- เวอร์ชั่น
    Version = "1.0.0",
    Codename = "Nexus",

    -- โมดูลที่เปิดให้ผู้ใช้เรียกโดยตรง
    Init = Init,
    Utils = Utils,
    Theme = ThemeModule,
    Window = Window,            -- สำหรับ Window.Create
    Notification = Notification,
    ConfigManager = ConfigManager,
    KeySystem = KeySystem,
    IntroEngine = IntroEngine,
    MobileOptimizer = MobileOptimizer,
    Elements = Elements,        -- เข้าถึง Element factories โดยตรง

    -- ฟังก์ชันหลักที่ผู้ใช้จะเรียก
    CreateWindow = Window and Window.Create,
}

-- ถ้าต้องการให้ใช้ EclipseLib:Notify() ได้ทันที
EclipseLib.Notify = function(opts)
    if Notification then
        Notification:Notify(opts)
    end
end

-- บันทึก SafeGlobal ไว้ (ผู้ใช้จะได้ไม่ต้องเรียก Init เอง)
EclipseLib.SafeGlobal = Init.SafeGlobal

return EclipseLib
