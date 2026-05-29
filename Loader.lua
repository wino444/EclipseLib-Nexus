--[[
    EclipseLib-Nexus Loader (Remote Edition) – Fixed Factory Instantiation
    Version: 1.2.0
    ✅ ทุกโมดูลที่เป็น Factory จะถูกเรียกใช้ด้วย deps อัตโนมัติ
]]

local BASE_URL = "https://raw.githubusercontent.com/wino444/EclipseLib-Nexus/main/"

local function loadModule(path)
    local url = BASE_URL .. path
    local ok, code = pcall(function() return game:HttpGet(url) end)
    if not ok or not code then
        warn("❌ โหลดโมดูลไม่สำเร็จ: " .. url .. " | " .. tostring(code))
        return nil
    end
    local fn, err = loadstring(code)
    if not fn then
        warn("❌ Compile error: " .. url .. " | " .. err)
        return nil
    end
    local success, result = pcall(fn)
    if not success then
        warn("❌ Runtime error: " .. url .. " | " .. tostring(result))
        return nil
    end
    return result
end

-- 1) Init – ต้นกำเนิด
local Init = loadModule("Core/Init.lua")
if not Init then error("Init.lua is required") end

-- 2) Utils
local Utils = loadModule("Core/Utils.lua")
if Utils and Utils.Inject then Utils.Inject(Init.Services) end

-- 3) Theme
local ThemeModule = loadModule("Core/Theme.lua")

-- 4) MemoryGuard (factory)
local MemoryGuard = loadModule("Shield/MemoryGuard.lua")
if type(MemoryGuard) == "function" then
    MemoryGuard = MemoryGuard({ Services = Init.Services })
end

-- 5) Obfuscator (factory, optional)
local Obfuscator = loadModule("Shield/Obfuscator.lua")
if type(Obfuscator) == "function" then
    Obfuscator = Obfuscator({ Utils = Utils, Init = Init })
end

-- 6) Systems (factories)
local function callFactory(module, deps)
    if type(module) == "function" then return module(deps) end
    return module
end

local depsSys = { Utils = Utils, Theme = ThemeModule, Services = Init.Services, SafeGlobal = Init.SafeGlobal }
local Notification = callFactory(loadModule("Systems/Notification.lua"), depsSys)
-- เพิ่ม Notification เข้าไปใน deps สำหรับ KeySystem
depsSys.Notification = Notification

local ConfigManager = callFactory(loadModule("Systems/ConfigManager.lua"), { Services = Init.Services })
local KeySystem = callFactory(loadModule("Systems/KeySystem.lua"), depsSys)
local IntroEngine = callFactory(loadModule("Systems/IntroEngine.lua"), depsSys)

-- 7) Components (factories)
local depsComp = { Utils = Utils, Theme = ThemeModule, Services = Init.Services, MemoryGuard = MemoryGuard, MobileOptimizer = nil } -- MobileOptimizer จะเติมทีหลัง
local BaseCard = callFactory(loadModule("Components/BaseCard.lua"), depsComp)
local TabBar = callFactory(loadModule("Components/TabBar.lua"), depsComp)
local TabFrame = callFactory(loadModule("Components/TabFrame.lua"), depsComp)

-- 8) Elements (factories – ยังไม่ Instantiate เพราะจะถูกเรียกใช้โดย Tab API ด้วย deps เฉพาะหน้า)
local Elements = {}
local elementNames = { "Label","Section","Button","Toggle","Slider","Dropdown","Input","ProgressBar","Paragraph","ColorPicker","Keybind","Card" }
for _, name in ipairs(elementNames) do
    local mod = loadModule("Components/Elements/" .. name .. ".lua")
    if mod then
        Elements[name] = mod  -- เก็บ factory function เอาไว้ (จะถูกเรียกใช้ตอนสร้าง element โดย Tab API พร้อม deps)
    end
end

-- 9) MobileOptimizer
local MobileOptimizer = loadModule("Shield/MobileOptimizer.lua")
if type(MobileOptimizer) == "function" then
    MobileOptimizer = MobileOptimizer({
        Services = Init.Services,
        SafeGlobal = Init.SafeGlobal,
        Theme = ThemeModule,
        Utils = Utils,
        IntroEngine = IntroEngine,  -- เผื่อใช้เปลี่ยน Intro mode
    })
end
-- อัปเดต depsComp สำหรับ BaseCard ที่อาจใช้ MobileOptimizer
depsComp.MobileOptimizer = MobileOptimizer
-- ถ้า BaseCard ถูกสร้างไปแล้วและไม่ได้รับ MobileOptimizer อาจต้องสร้างใหม่ (แต่ BaseCard เป็นแค่ factory ธรรมดา ไม่มี state ก็ใช้ซ้ำได้)

-- 10) Window
local WindowModule = loadModule("Core/Window.lua")
local Window
if WindowModule then
    local depsWindow = {
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
        WindowModule.Inject(depsWindow)
        Window = WindowModule
    elseif type(WindowModule) == "function" then
        Window = WindowModule(depsWindow)
    else
        warn("Window module มีรูปแบบไม่ถูกต้อง")
    end
end

-- สร้าง EclipseLib object
local EclipseLib = {
    Version = "1.2.0",
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
