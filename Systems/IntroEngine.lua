--[[
    EclipseLib-Nexus Systems/IntroEngine.lua
    Version: 1.0.0
    หน้าที่: อนิเมชั่นเปิดตัว 4 โหมด (Fade, Zoom, Glitch, Particle)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local Services = deps.Services

    local Tween = Utils.Tween
    local TweenWait = Utils.TweenWait
    local CC = Utils.CC
    local _randomName = Utils._randomName
    local MakeScreenGui = Utils.MakeScreenGui

    local IntroConfig = {
        Mode = "particle",
        Duration = 4,
        Icon = "🌒",
    }

    -- อ่านค่าจาก SafeGlobal ถ้ามี
    if deps.SafeGlobal then
        local savedMode = deps.SafeGlobal:Get("EclipseNexus_IntroMode")
        if savedMode then IntroConfig.Mode = savedMode end
    end

    local function RunIntro_Fade(sg, title, subtitle, onDone)
        local bg = Instance.new("Frame")
        bg.BackgroundColor3 = Color3.fromRGB(8,8,12)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundTransparency = 1
        bg.Parent = sg

        local glow = Instance.new("Frame")
        glow.BackgroundColor3 = Theme.Accent
        glow.BackgroundTransparency = 1
        glow.Size = UDim2.new(0,180,0,180)
        glow.Position = UDim2.new(0.5,-90,0.5,-90)
        glow.Parent = bg
        CC(glow, 90)

        local iconL = Instance.new("TextLabel")
        iconL.BackgroundTransparency = 1
        iconL.Size = UDim2.new(0,80,0,80)
        iconL.Position = UDim2.new(0.5,-40,0.5,-50)
        iconL.Text = IntroConfig.Icon
        iconL.TextSize = 56
        iconL.Font = Enum.Font.GothamBold
        iconL.TextTransparency = 1
        iconL.Parent = bg

        local titleL = Instance.new("TextLabel")
        titleL.BackgroundTransparency = 1
        titleL.Size = UDim2.new(1,0,0,36)
        titleL.Position = UDim2.new(0,0,0.5,20)
        titleL.Text = title
        titleL.TextColor3 = Theme.Text
        titleL.TextTransparency = 1
        titleL.Font = Enum.Font.GothamBold
        titleL.TextSize = 22
        titleL.Parent = bg

        local subL = Instance.new("TextLabel")
        subL.BackgroundTransparency = 1
        subL.Size = UDim2.new(1,0,0,24)
        subL.Position = UDim2.new(0,0,0.5,58)
        subL.Text = subtitle
        subL.TextColor3 = Theme.SubText
        subL.TextTransparency = 1
        subL.Font = Enum.Font.Gotham
        subL.TextSize = 14
        subL.Parent = bg

        local barBG = Instance.new("Frame")
        barBG.BackgroundColor3 = Theme.Slider_BG
        barBG.BackgroundTransparency = 1
        barBG.Size = UDim2.new(0,220,0,3)
        barBG.Position = UDim2.new(0.5,-110,0.5,90)
        barBG.Parent = bg
        CC(barBG, 3)

        local barFill = Instance.new("Frame")
        barFill.BackgroundColor3 = Theme.Accent
        barFill.Size = UDim2.new(0,0,1,0)
        barFill.Parent = barBG
        CC(barFill, 3)

        task.spawn(function()
            TweenWait(bg, { BackgroundTransparency = 0 }, 0.4)
            Tween(glow, { BackgroundTransparency = 0.88, Size = UDim2.new(0,200,0,200), Position = UDim2.new(0.5,-100,0.5,-100) }, 0.6, Enum.EasingStyle.Sine)
            TweenWait(iconL, { TextTransparency = 0, Position = UDim2.new(0.5,-40,0.5,-70) }, 0.5, Enum.EasingStyle.Quint)
            task.wait(0.1)
            TweenWait(titleL, { TextTransparency = 0 }, 0.45)
            task.wait(0.1)
            TweenWait(subL, { TextTransparency = 0 }, 0.4)
            task.wait(0.1)
            TweenWait(barBG, { BackgroundTransparency = 0 }, 0.3)
            TweenWait(barFill, { Size = UDim2.new(1,0,1,0) }, 1.2, Enum.EasingStyle.Quint)
            task.wait(0.25)
            Tween(iconL, { TextTransparency = 1, Position = UDim2.new(0.5,-40,0.5,-90) }, 0.45)
            Tween(titleL, { TextTransparency = 1 }, 0.45)
            Tween(subL, { TextTransparency = 1 }, 0.45)
            Tween(barBG, { BackgroundTransparency = 1 }, 0.45)
            Tween(glow, { BackgroundTransparency = 1 }, 0.45)
            TweenWait(bg, { BackgroundTransparency = 1 }, 0.5)
            sg:Destroy()
            onDone()
        end)
    end

    local function RunIntro_Zoom(sg, title, subtitle, onDone)
        local bg = Instance.new("Frame")
        bg.BackgroundColor3 = Color3.fromRGB(8,8,12)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundTransparency = 1
        bg.Parent = sg

        local iconL = Instance.new("TextLabel")
        iconL.BackgroundTransparency = 1
        iconL.Size = UDim2.new(0,20,0,20)
        iconL.Position = UDim2.new(0.5,-10,0.5,-60)
        iconL.Text = IntroConfig.Icon
        iconL.TextSize = 12
        iconL.TextTransparency = 0.8
        iconL.Font = Enum.Font.GothamBold
        iconL.Parent = bg

        local titleL = Instance.new("TextLabel")
        titleL.BackgroundTransparency = 1
        titleL.Size = UDim2.new(1,0,0,36)
        titleL.Position = UDim2.new(0,0,0.5,20)
        titleL.Text = title
        titleL.TextColor3 = Theme.Text
        titleL.TextTransparency = 1
        titleL.Font = Enum.Font.GothamBold
        titleL.TextSize = 22
        titleL.Parent = bg

        local subL = Instance.new("TextLabel")
        subL.BackgroundTransparency = 1
        subL.Size = UDim2.new(1,0,0,24)
        subL.Position = UDim2.new(0,0,0.5,58)
        subL.Text = subtitle
        subL.TextColor3 = Theme.SubText
        subL.TextTransparency = 1
        subL.Font = Enum.Font.Gotham
        subL.TextSize = 14
        subL.Parent = bg

        local barBG = Instance.new("Frame")
        barBG.BackgroundColor3 = Theme.Slider_BG
        barBG.BackgroundTransparency = 1
        barBG.Size = UDim2.new(0,220,0,3)
        barBG.Position = UDim2.new(0.5,-110,0.5,90)
        barBG.Parent = bg
        CC(barBG, 3)

        local barFill = Instance.new("Frame")
        barFill.BackgroundColor3 = Theme.Accent
        barFill.Size = UDim2.new(0,0,1,0)
        barFill.Parent = barBG
        CC(barFill, 3)

        task.spawn(function()
            TweenWait(bg, { BackgroundTransparency = 0 }, 0.3)
            TweenWait(iconL, { TextSize = 72, TextTransparency = 0, Size = UDim2.new(0,80,0,80), Position = UDim2.new(0.5,-40,0.5,-70) }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            TweenWait(iconL, { TextSize = 56, Size = UDim2.new(0,70,0,70) }, 0.2, Enum.EasingStyle.Bounce)
            task.wait(0.05)
            TweenWait(titleL, { TextTransparency = 0 }, 0.4)
            task.wait(0.1)
            TweenWait(subL, { TextTransparency = 0 }, 0.35)
            task.wait(0.1)
            TweenWait(barBG, { BackgroundTransparency = 0 }, 0.25)
            TweenWait(barFill, { Size = UDim2.new(1,0,1,0) }, 1.2, Enum.EasingStyle.Quint)
            task.wait(0.2)
            Tween(iconL, { TextTransparency = 1, TextSize = 100 }, 0.5)
            Tween(titleL, { TextTransparency = 1 }, 0.4)
            Tween(subL, { TextTransparency = 1 }, 0.4)
            Tween(barBG, { BackgroundTransparency = 1 }, 0.4)
            TweenWait(bg, { BackgroundTransparency = 1 }, 0.5)
            sg:Destroy()
            onDone()
        end)
    end

    local function RunIntro_Glitch(sg, title, subtitle, onDone)
        local bg = Instance.new("Frame")
        bg.BackgroundColor3 = Color3.fromRGB(8,8,12)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundTransparency = 1
        bg.Parent = sg

        for i = 1, 8 do
            local l = Instance.new("Frame")
            l.BackgroundColor3 = Color3.fromRGB(100,60,200)
            l.BackgroundTransparency = 0.92
            l.Size = UDim2.new(1,0,0,1)
            l.Position = UDim2.new(0,0,i/9,0)
            l.BorderSizePixel = 0
            l.Parent = bg
        end

        local iconL = Instance.new("TextLabel")
        iconL.BackgroundTransparency = 1
        iconL.Size = UDim2.new(0,80,0,80)
        iconL.Position = UDim2.new(0.5,-40,0.5,-70)
        iconL.Text = IntroConfig.Icon
        iconL.TextSize = 56
        iconL.TextTransparency = 1
        iconL.Font = Enum.Font.GothamBold
        iconL.Parent = bg

        local titleL = Instance.new("TextLabel")
        titleL.BackgroundTransparency = 1
        titleL.Size = UDim2.new(1,0,0,36)
        titleL.Position = UDim2.new(0,0,0.5,20)
        titleL.Text = "█▓░ LOADING ░▓█"
        titleL.TextColor3 = Theme.Accent
        titleL.TextTransparency = 1
        titleL.Font = Enum.Font.Code
        titleL.TextSize = 18
        titleL.Parent = bg

        local subL = Instance.new("TextLabel")
        subL.BackgroundTransparency = 1
        subL.Size = UDim2.new(1,0,0,24)
        subL.Position = UDim2.new(0,0,0.5,58)
        subL.Text = subtitle
        subL.TextColor3 = Theme.SubText
        subL.TextTransparency = 1
        subL.Font = Enum.Font.Code
        subL.TextSize = 13
        subL.Parent = bg

        local barBG = Instance.new("Frame")
        barBG.BackgroundColor3 = Theme.Slider_BG
        barBG.BackgroundTransparency = 1
        barBG.Size = UDim2.new(0,220,0,3)
        barBG.Position = UDim2.new(0.5,-110,0.5,90)
        barBG.Parent = bg
        CC(barBG, 2)

        local barFill = Instance.new("Frame")
        barFill.BackgroundColor3 = Theme.Accent
        barFill.Size = UDim2.new(0,0,1,0)
        barFill.Parent = barBG

        local gc = { "█","▓","▒","░","▄","▌","▐","▀","■","□" }
        local function GT(lbl, ft, dur)
            local steps = math.floor(dur / 0.06)
            for i = 1, steps do
                local out = ""
                for j = 1, #ft do
                    if i / steps > (j / #ft * 0.8) then
                        out = out .. ft:sub(j,j)
                    else
                        out = out .. gc[math.random(1, #gc)]
                    end
                end
                lbl.Text = out
                task.wait(0.06)
            end
            lbl.Text = ft
        end

        task.spawn(function()
            TweenWait(bg, { BackgroundTransparency = 0 }, 0.25)
            titleL.TextTransparency = 0
            iconL.TextTransparency = 0
            iconL.TextColor3 = Theme.Accent
            for i = 1, 6 do
                iconL.TextTransparency = (i % 2 == 0) and 0 or 0.7
                iconL.Position = UDim2.new(0.5, math.random(-4,4), 0.5, -70 + math.random(-3,3))
                task.wait(0.07)
            end
            iconL.TextTransparency = 0
            iconL.TextColor3 = Theme.Text
            iconL.Position = UDim2.new(0.5,-40,0.5,-70)
            task.wait(0.1)
            GT(titleL, title, 0.9)
            titleL.TextColor3 = Theme.Text
            titleL.Font = Enum.Font.GothamBold
            titleL.TextSize = 22
            task.wait(0.1)
            TweenWait(subL, { TextTransparency = 0 }, 0.3)
            subL.Font = Enum.Font.Gotham
            task.wait(0.1)
            TweenWait(barBG, { BackgroundTransparency = 0 }, 0.2)
            TweenWait(barFill, { Size = UDim2.new(1,0,1,0) }, 1.1, Enum.EasingStyle.Linear)
            task.wait(0.2)
            for i = 1, 5 do
                bg.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(8,8,12) or Color3.fromRGB(20,10,40)
                task.wait(0.05)
            end
            Tween(iconL, { TextTransparency = 1 }, 0.35)
            Tween(titleL, { TextTransparency = 1 }, 0.35)
            Tween(subL, { TextTransparency = 1 }, 0.35)
            Tween(barBG, { BackgroundTransparency = 1 }, 0.35)
            TweenWait(bg, { BackgroundTransparency = 1 }, 0.45)
            sg:Destroy()
            onDone()
        end)
    end

    local function RunIntro_Particle(sg, title, subtitle, onDone)
        local bg = Instance.new("Frame")
        bg.BackgroundColor3 = Color3.fromRGB(8,8,12)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundTransparency = 1
        bg.Parent = sg

        local parts = {}
        math.randomseed(tick())
        for i = 1, 28 do
            local p = Instance.new("Frame")
            local sz = math.random(2, 6)
            p.BackgroundColor3 = (math.random() > 0.5) and Theme.Accent or Color3.fromRGB(180,140,255)
            p.Size = UDim2.new(0, sz, 0, sz)
            local a = math.rad(math.random(0, 360))
            local d = math.random(80, 200)
            p.Position = UDim2.new(0.5 + math.cos(a) * d / 600, -sz / 2, 0.5 + math.sin(a) * d / 600, -sz / 2)
            p.Parent = bg
            CC(p, sz)
            table.insert(parts, p)
        end

        local iconL = Instance.new("TextLabel")
        iconL.BackgroundTransparency = 1
        iconL.Size = UDim2.new(0,80,0,80)
        iconL.Position = UDim2.new(0.5,-40,0.5,-70)
        iconL.Text = IntroConfig.Icon
        iconL.TextSize = 12
        iconL.TextTransparency = 1
        iconL.Font = Enum.Font.GothamBold
        iconL.Parent = bg

        local titleL = Instance.new("TextLabel")
        titleL.BackgroundTransparency = 1
        titleL.Size = UDim2.new(1,0,0,36)
        titleL.Position = UDim2.new(0,0,0.5,20)
        titleL.Text = title
        titleL.TextColor3 = Theme.Text
        titleL.TextTransparency = 1
        titleL.Font = Enum.Font.GothamBold
        titleL.TextSize = 22
        titleL.Parent = bg

        local subL = Instance.new("TextLabel")
        subL.BackgroundTransparency = 1
        subL.Size = UDim2.new(1,0,0,24)
        subL.Position = UDim2.new(0,0,0.5,58)
        subL.Text = subtitle
        subL.TextColor3 = Theme.SubText
        subL.TextTransparency = 1
        subL.Font = Enum.Font.Gotham
        subL.TextSize = 14
        subL.Parent = bg

        local barBG = Instance.new("Frame")
        barBG.BackgroundColor3 = Theme.Slider_BG
        barBG.BackgroundTransparency = 1
        barBG.Size = UDim2.new(0,220,0,3)
        barBG.Position = UDim2.new(0.5,-110,0.5,90)
        barBG.Parent = bg
        CC(barBG, 3)

        local barFill = Instance.new("Frame")
        barFill.BackgroundColor3 = Theme.Accent
        barFill.Size = UDim2.new(0,0,1,0)
        barFill.Parent = barBG
        CC(barFill, 3)

        task.spawn(function()
            TweenWait(bg, { BackgroundTransparency = 0 }, 0.3)
            for _, p in ipairs(parts) do
                Tween(p, { Position = UDim2.new(0.5,-3,0.5,-3), BackgroundTransparency = 0.3, Size = UDim2.new(0,4,0,4) }, 0.7, Enum.EasingStyle.Quint)
            end
            task.wait(0.65)
            for _, p in ipairs(parts) do
                Tween(p, { BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0) }, 0.2)
            end
            TweenWait(iconL, { TextTransparency = 0, TextSize = 56 }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(0.1)
            TweenWait(titleL, { TextTransparency = 0 }, 0.4)
            task.wait(0.1)
            TweenWait(subL, { TextTransparency = 0 }, 0.35)
            task.wait(0.1)
            TweenWait(barBG, { BackgroundTransparency = 0 }, 0.25)
            TweenWait(barFill, { Size = UDim2.new(1,0,1,0) }, 1.1, Enum.EasingStyle.Quint)
            task.wait(0.2)
            Tween(iconL, { TextTransparency = 1 }, 0.4)
            Tween(titleL, { TextTransparency = 1 }, 0.4)
            Tween(subL, { TextTransparency = 1 }, 0.4)
            Tween(barBG, { BackgroundTransparency = 1 }, 0.4)
            TweenWait(bg, { BackgroundTransparency = 1 }, 0.5)
            sg:Destroy()
            onDone()
        end)
    end

    local function PlayIntro(title, subtitle, onDone)
        local sg = MakeScreenGui(_randomName("eclipse_intro_"), 10000)
        local mode = IntroConfig.Mode
        if mode == "zoom" then
            RunIntro_Zoom(sg, title, subtitle, onDone)
        elseif mode == "glitch" then
            RunIntro_Glitch(sg, title, subtitle, onDone)
        elseif mode == "particle" then
            RunIntro_Particle(sg, title, subtitle, onDone)
        else
            RunIntro_Fade(sg, title, subtitle, onDone)
        end
    end

    return { PlayIntro = PlayIntro, IntroConfig = IntroConfig }
end
