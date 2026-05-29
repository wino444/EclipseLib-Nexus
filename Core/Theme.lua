--[[
    EclipseLib-Nexus Core/Theme.lua
    Version: 1.0.0
    หน้าที่: DefaultTheme, Presets (6 ธีม), ApplyAccent, ResetToDefault, Callback OnThemeChanged
]]

local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(22, 22, 30),
    Accent = Color3.fromRGB(100, 60, 200),
    AccentHover = Color3.fromRGB(120, 80, 220),
    Text = Color3.fromRGB(220, 220, 235),
    SubText = Color3.fromRGB(140, 140, 160),
    Border = Color3.fromRGB(50, 40, 80),
    TabActive = Color3.fromRGB(100, 60, 200),
    TabInactive = Color3.fromRGB(30, 28, 40),
    Toggle_ON = Color3.fromRGB(100, 60, 200),
    Toggle_OFF = Color3.fromRGB(50, 45, 65),
    Slider_Fill = Color3.fromRGB(100, 60, 200),
    Slider_BG = Color3.fromRGB(35, 32, 50),
    Notif_BG = Color3.fromRGB(20, 18, 30),
    Notif_Border = Color3.fromRGB(100, 60, 200),
    Input_BG = Color3.fromRGB(28, 25, 40),
    Dropdown_BG = Color3.fromRGB(25, 22, 38),
}

-- สำเนาตั้งต้นสำหรับ Reset
local DefaultTheme = {}
for k, v in pairs(Theme) do
    DefaultTheme[k] = v
end

-- Preset Themes (6 แบบ)
local Presets = {
    {
        name = "🌒 Eclipse",
        accent = Color3.fromRGB(100, 60, 200),
        bg = Color3.fromRGB(15, 15, 20),
        sec = Color3.fromRGB(22, 22, 30),
        border = Color3.fromRGB(50, 40, 80),
        inactive = Color3.fromRGB(30, 28, 40),
    },
    {
        name = "🌊 Ocean",
        accent = Color3.fromRGB(30, 120, 220),
        bg = Color3.fromRGB(10, 18, 28),
        sec = Color3.fromRGB(15, 28, 42),
        border = Color3.fromRGB(20, 60, 100),
        inactive = Color3.fromRGB(18, 32, 50),
    },
    {
        name = "🌲 Forest",
        accent = Color3.fromRGB(40, 170, 90),
        bg = Color3.fromRGB(10, 18, 12),
        sec = Color3.fromRGB(15, 26, 18),
        border = Color3.fromRGB(25, 70, 35),
        inactive = Color3.fromRGB(18, 32, 20),
    },
    {
        name = "🔥 Inferno",
        accent = Color3.fromRGB(220, 80, 30),
        bg = Color3.fromRGB(20, 10, 8),
        sec = Color3.fromRGB(30, 15, 10),
        border = Color3.fromRGB(80, 30, 15),
        inactive = Color3.fromRGB(35, 18, 12),
    },
    {
        name = "🌸 Sakura",
        accent = Color3.fromRGB(220, 80, 140),
        bg = Color3.fromRGB(20, 12, 18),
        sec = Color3.fromRGB(30, 18, 26),
        border = Color3.fromRGB(80, 30, 60),
        inactive = Color3.fromRGB(35, 18, 30),
    },
    {
        name = "🖤 Midnight",
        accent = Color3.fromRGB(160, 160, 180),
        bg = Color3.fromRGB(8, 8, 10),
        sec = Color3.fromRGB(14, 14, 18),
        border = Color3.fromRGB(40, 40, 50),
        inactive = Color3.fromRGB(20, 20, 26),
    },
}

-- Callback เมื่อ Theme เปลี่ยน (Window จะเป็นคนผูก)
Theme.OnThemeChanged = nil

-- เปลี่ยนสี Accent (ใช้ใน Custom Color Picker)
local function ApplyAccent(color)
    Theme.Accent = color
    Theme.TabActive = color
    Theme.Toggle_ON = color
    Theme.Slider_Fill = color
    Theme.Notif_Border = color
    Theme.AccentHover = Color3.fromRGB(
        math.min(color.R * 255 + 20, 255) / 255,
        math.min(color.G * 255 + 20, 255) / 255,
        math.min(color.B * 255 + 20, 255) / 255
    )
    if Theme.OnThemeChanged then
        Theme.OnThemeChanged()
    end
end

-- เปลี่ยนธีมทั้งชุด (จาก Presets)
local function ApplyPreset(preset)
    Theme.Background = preset.bg
    Theme.Secondary = preset.sec
    Theme.Border = preset.border
    Theme.TabInactive = preset.inactive
    Theme.Dropdown_BG = preset.sec
    Theme.Input_BG = preset.sec
    Theme.Slider_BG = preset.sec
    ApplyAccent(preset.accent)
end

-- Reset ทุกอย่างกลับเป็น Default
local function ResetToDefault()
    for k, v in pairs(DefaultTheme) do
        Theme[k] = v
    end
    if Theme.OnThemeChanged then
        Theme.OnThemeChanged()
    end
end

-- ส่งออก
return {
    Theme = Theme,
    DefaultTheme = DefaultTheme,
    Presets = Presets,
    ApplyAccent = ApplyAccent,
    ApplyPreset = ApplyPreset,
    ResetToDefault = ResetToDefault,
}
