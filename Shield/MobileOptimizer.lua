--[[
    EclipseLib-Nexus Shield/MobileOptimizer.lua
    Version: 1.0.0
    หน้าที่: โหมดประหยัดมือถือ + Toggle (SafeGlobal)
]]

return function(deps)
    local Services = deps.Services
    local SafeGlobal = deps.SafeGlobal
    local ThemeModule = deps.Theme
    local Utils = deps.Utils

    local RunService = Services.RunService
    local UserInputService = Services.UserInputService

    local MobileOptimizer = {
        Enabled = true,
        -- เก็บค่าตั้งต้นของธีมบางตัว
        _originalStrokeThickness = 1,
        _originalIntroMode = "particle",
    }

    -- ตั้งค่าเริ่มต้นจาก SafeGlobal
    local initState = SafeGlobal:Get("EclipseNexus_MobileOptimize", true)
    MobileOptimizer.Enabled = initState

    -- ตรวจสอบอุปกรณ์ (auto-detect)
    local function isMobileDevice()
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end

    local function hasLowMemory()
        -- วิธีง่าย ๆ: ถ้าไม่มี stats ให้เดาว่าต่ำ
        local success, stats = pcall(function() return game:GetService("Stats") end)
        if not success then return true end
        local mem = stats:GetTotalMemoryUsageMb() -- อาจไม่มีในทุกเกม
        return mem and mem > 2000 or false -- ถ้าใช้ RAM > 2GB ถือว่าไม่ต่ำ
    end

    -- ฟังก์ชัน Auto-Detect (จะเปิดถ้าเป็นมือถือหรือแรมต่ำ)
    function MobileOptimizer:AutoDetect()
        if isMobileDevice() or hasLowMemory() then
            self:Toggle(true)
        else
            self:Toggle(false)
        end
    end

    -- เปิด/ปิดการปรับแต่ง
    function MobileOptimizer:Toggle(state)
        self.Enabled = state
        SafeGlobal:Set("EclipseNexus_MobileOptimize", state)
        if state then
            self:ApplyOptimizations()
        else
            self:RevertOptimizations()
        end
    end

    function MobileOptimizer:GetStatus()
        return self.Enabled
    end

    -- ปรับ UI ให้เบาลง
    function MobileOptimizer:ApplyOptimizations()
        local Theme = ThemeModule.Theme
        -- ลด UIStroke thickness (ให้บางลง)
        self._originalStrokeThickness = Theme._strokeThickness or 1
        Theme._strokeThickness = 0.5 -- เปลี่ยนไปใช้ค่าใหม่
        -- เปลี่ยน Intro mode เป็น fade (เร็วสุด)
        if deps.IntroEngine then
            local cfg = deps.IntroEngine.IntroConfig
            if cfg then
                self._originalIntroMode = cfg.Mode
                cfg.Mode = "fade"
            end
        end
        -- ลดความถี่ Updater (ทำผ่าน MemoryGuard ได้ แต่ต้องเข้าถึง)
        -- ในที่นี้จะเพิ่มค่า Tick ให้ช้าลง (ทำภายหลัง)
        -- หมายเหตุ: การลด UIGradient อาจต้องดักที่ BaseCard (จะทำใน Window.lua)
    end

    -- คืนค่ากลับ
    function MobileOptimizer:RevertOptimizations()
        local Theme = ThemeModule.Theme
        Theme._strokeThickness = self._originalStrokeThickness
        if deps.IntroEngine then
            local cfg = deps.IntroEngine.IntroConfig
            if cfg then
                cfg.Mode = self._originalIntroMode
            end
        end
    end

    -- เรียก Auto-Detect ครั้งแรกตอนโหลด (ถ้าไม่มีค่าใน SafeGlobal)
    if SafeGlobal:Get("EclipseNexus_MobileOptimize") == nil then
        MobileOptimizer:AutoDetect()
    end

    return MobileOptimizer
end
