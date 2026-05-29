--[[
    EclipseLib-Nexus Loader (Remote Edition) – Fixed
    Version: 1.2.0
    เรียก Constructor ของทุกโมดูลอย่างถูกต้อง
]]

local BASE_URL = "https://raw.githubusercontent.com/wino444/EclipseLib-Nexus/main/"

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

-- ===== 1. Core พื้นฐาน =====
local Init = loadModule("Core/Init.lua")
if not Init then error("Init.lua is required.") end

local Utils = loadModule("Core/Utils.lua")
if Utils and Utils.Inject then
    Utils.Inject(Init.Services)
end

local ThemeModule = loadModule("Core/Theme.lua")

-- ===== 2. Shield ที่ไม่มี Dependency ซับซ้อน =====
local MemoryGuard = loadModule("Shield/MemoryGuard.lua")
if type(MemoryGuard) == "function" then
    MemoryGuard = MemoryGuard({ Services = Init.Services })
end

local Obfuscator = loadModule("Shield/Obfuscator.lua")
if type(Obfuscator) == "function" then
    Obfuscator = Obfuscator({ Utils = Utils, Init = Init })
end

-- ===== 3. Systems =====
local deps = {
    Utils = Utils,
    Theme = ThemeModule,
    Services = Init.Services,
    SafeGlobal = Init.SafeGlobal,
    Init = Init,
    MemoryGuard = MemoryGuard,
    Obfuscator = Obfuscator,
}

local Notification = loadModule("Systems/Notification.lua")
if type(Notification) == "function" then
    Notification = Notification(deps)
end
deps.Notification = Notification

local ConfigManager = loadModule("Systems/ConfigManager.lua")
if type(ConfigManager) == "function" then
    ConfigManager = ConfigManager(deps)
end
deps.ConfigManager = ConfigManager

local KeySystem = loadModule("Systems/KeySystem.lua")
if type(KeySystem) == "function" then
    KeySystem = KeySystem(deps)
end
deps.KeySystem = KeySystem

local IntroEngine = loadModule("Systems/IntroEngine.lua")
if type(IntroEngine) == "function" then
    IntroEngine = IntroEngine(deps)
end
deps.IntroEngine = IntroEngine

-- ===== 4. MobileOptimizer (ใช้ใน BaseCard) =====
local MobileOptimizer = loadModule("Shield/MobileOptimizer.lua")
if type(MobileOptimizer) == "function" then
    MobileOptimizer = MobileOptimizer(deps)
end
deps.MobileOptimizer = MobileOptimizer

-- ===== 5. Components =====
local BaseCard = loadModule("Components/BaseCard.lua")
if type(BaseCard) == "function" then
    BaseCard = BaseCard(deps)
end
deps.BaseCard = BaseCard

local TabBar = loadModule("Components/TabBar.lua")
if type(TabBar) == "function" then
    TabBar = TabBar(deps)
end
deps.TabBar = TabBar

local TabFrame = loadModule("Components/TabFrame.lua")
if type(TabFrame) == "function" then
    TabFrame = TabFrame(deps)
end
deps.TabFrame = TabFrame

-- ===== 6. Elements (แต่ละตัวเป็น Factory ที่ต้องเรียก constructor) =====
local Elements = {}
local elementFiles = {
    "Label", "Section", "Button", "Toggle", "Slider", "Dropdown",
    "Input", "ProgressBar", "Paragraph", "ColorPicker", "Keybind", "Card"
}
for _, name in ipairs(elementFiles) do
    local module = loadModule("Components/Elements/" .. name .. ".lua")
    if module then
        if type(module) == "function" then
            Elements[name] = module(deps)   -- ได้ factory function
        else
            Elements[name] = module
        end
    end
end
deps.Elements = Elements

-- ===== 7. Window (สุดท้าย) =====
local WindowModule = loadModule("Core/Window.lua")
local Window
if WindowModule then
    if type(WindowModule) == "function" then
        Window = WindowModule(deps)
    else
        Window = WindowModule
    end
end

-- ===== 8. สร้าง EclipseLib Object =====
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
