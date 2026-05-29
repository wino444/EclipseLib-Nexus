--[[
    EclipseLib-Nexus Loader (Remote Edition)
    Version: 1.1.0
    ดึงทุกโมดูลจาก GitHub Raw โดยอัตโนมัติ – ไม่จำเป็นต้องมีไฟล์ในเครื่อง
]]

local BASE_URL = "https://raw.githubusercontent.com/wino444/EclipseLib-Nexus/main/"

-- ฟังก์ชันภายในสำหรับโหลดโมดูลจาก URL
local function loadModule(relativePath)
    local url = BASE_URL .. relativePath
    local success, code = pcall(function()
        return game:HttpGet(url)
    end)
    if not success or not code then
        warn("❌ โหลดโมดูลไม่สำเร็จ: " .. url .. " | เหตุผล: " .. tostring(code))
        return nil
    end
    local fn, err = loadstring(code)
    if not fn then
        warn("❌ Compile error ใน " .. url .. ": " .. err)
        return nil
    end
    local ok, result = pcall(fn)
    if not ok then
        warn("❌ Runtime error ใน " .. url .. ": " .. tostring(result))
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

-- 8. Elements (โหลดทุกไฟล์ใน Elements/ จากรายการที่เรากำหนด)
local Elements = {}
local elementFiles = {
    "Label", "Section", "Button", "Toggle", "Slider", "Dropdown",
    "Input", "ProgressBar", "Paragraph", "ColorPicker", "Keybind", "Card"
}
for _, name in ipairs(elementFiles) do
    local module = loadModule("Components/Elements/" .. name .. ".lua")
    if module then
        Elements[name] = module
    end
end

-- 9. Shield/MobileOptimizer.lua
local MobileOptimizer = loadModule("Shield/MobileOptimizer.lua")
if MobileOptimizer and MobileOptimizer.Toggle then
    local initState = Init.SafeGlobal:Get("EclipseNexus_MobileOptimize", true)
    MobileOptimizer:Toggle(initState)
end

-- 10. Core/Window.lua
local WindowModule = loadModule("Core/Window.lua")
local Window
if WindowModule then
    -- Inject dependencies
    local deps = {
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
    }
    if type(WindowModule) == "table" and WindowModule.Inject then
        WindowModule.Inject(deps)
        Window = WindowModule
    elseif type(WindowModule) == "function" then
        Window = WindowModule(deps)
    else
        warn("Window module มีรูปแบบไม่ถูกต้อง")
    end
end

-- ===== สร้าง EclipseLib Object =====
local EclipseLib = {
    Version = "1.1.0",
    Codename = "Nexus Remote",
    Init = Init,
    Utils = Utils,
    Theme = ThemeModule,
    Window = Window,
    Notification = Notification,
    ConfigManager = ConfigManager,
    KeySystem = KeySystem,
    IntroEngine = IntroEngine,
    MobileOptimizer = MobileOptimizer,
    Elements = Elements,
    CreateWindow = Window and Window.Create,
}
EclipseLib.Notify = function(opts)
    if Notification then Notification:Notify(opts) end
end
EclipseLib.SafeGlobal = Init.SafeGlobal

return EclipseLib
