--[[
    🌒 EclipseLib — Deekseek Edition (Full Body)
    Version: 6.0.0
    ผู้ปรับปรุง: Deekseek AI Lab ตามคำสั่งจูซิง
    Features: Mobile Optimized, Anti-Cheat Bypass, Complete UI
--]]

-- Environment
local getgenv, getrenv, hookfunction, cloneref = 
    (getgenv or function() return _G end), 
    (getrenv or function() return _G end),
    (hookfunction or function(a,b) return a end),
    (cloneref or function(obj) return obj end)
local syn = syn or {crypt = {randomstring = function(len) local chars = "abcdefghijklmnopqrstuvwxyz0123456789"; local s = ""; for i=1,len do s = s .. chars:sub(math.random(1,#chars),math.random(1,#chars)) end; return s end}}
local isfolder, makefolder, listfiles, isfile, delfile, readfile, writefile, setclipboard, Clipboard = 
    isfolder, makefolder, listfiles, isfile, delfile, readfile, writefile, setclipboard, Clipboard

local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local EclipseLib = {}
EclipseLib.__index = EclipseLib

-- Helper: random name for anti-cheat
local function _randomName(prefix)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local rnd = ""
    for _ = 1, 10 do
        rnd = rnd .. chars:sub(math.random(1,#chars), math.random(1,#chars))
    end
    return (prefix or "el_") .. rnd
end

-- Deep copy
local function _deepClone(obj)
    if type(obj) ~= "table" then return obj end
    local res = {}
    for k,v in pairs(obj) do
        res[_deepClone(k)] = _deepClone(v)
    end
    return res
end

-- Default Theme
local DefaultTheme = {
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
local Theme = _deepClone(DefaultTheme)

-- Intro Config
local IntroConfig = {
    Mode = "particle",
    Duration = 4,
    Icon = "🌒",
}

-- Tween helpers
local function Tween(obj, props, t, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function TweenWait(obj, props, t, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    tw.Completed:Wait()
end

-- Draggable (fixed)
local function MakeDraggable(frame, handle)
    local connection
    local dragStart, startPos
    local function startDrag(input)
        dragStart = input.Position
        startPos = frame.Position
    end
    local function updateDrag(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    local function endDrag()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    updateDrag(input)
                end
            end)
            local conn2
            conn2 = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    endDrag()
                    conn2:Disconnect()
                end
            end)
        end
    end)
end

-- UI Corner / Stroke
local function CC(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

local function CS(p, color, t)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = t or 1
    s.Parent = p
end

-- Clipboard
local function SetClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text)
        elseif Clipboard then Clipboard.set(text)
        end
    end)
end

-- ScreenGui with random name
local function MakeScreenGui(name, order)
    local sg = Instance.new("ScreenGui")
    sg.Name = name or _randomName("eclipse_")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = order or 999
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    return sg
end

-- ================= NOTIFICATION SYSTEM (Fixed) =================
local NotifQueue = {}
local NotifQueueBusy = false
local NotifQueueEnabled = true
local NotifHolder = nil

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return NotifHolder end
    local gui = Instance.new("ScreenGui")
    gui.Name = _randomName("eclipse_notif_")
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10000
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end
    NotifHolder = gui
    return gui
end

local function _createNotif(gui, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 70)
    frame.Position = UDim2.new(1, 10, 1, -90)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = Theme.Notif_BG
    frame.BorderSizePixel = 0
    frame.Parent = gui
    CC(frame, 12)
    CS(frame, Theme.Notif_Border, 2)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.Position = UDim2.new(0, 5, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🌒"
    icon.TextScaled = true
    icon.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -55, 0, 28)
    title.Position = UDim2.new(0, 50, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = data.Title or "EclipseLib"
    title.TextColor3 = Theme.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -55, 0, 28)
    msg.Position = UDim2.new(0, 50, 0, 30)
    msg.BackgroundTransparency = 1
    msg.Text = data.Content or ""
    msg.TextColor3 = Theme.Text
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 13
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 3)
    bar.Position = UDim2.new(0, 0, 1, -3)
    bar.BackgroundColor3 = Theme.Accent
    bar.BorderSizePixel = 0
    bar.Parent = frame
    CC(bar, 4)

    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -10, 1, -90) }):Play()
    local duration = data.Duration or 3
    TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) }):Play()
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Position = UDim2.new(1, 300, 1, -90) }):Play()
        task.wait(0.3)
        frame:Destroy()
        NotifQueueBusy = false
        _showNextNotif()
    end)
end

local function _showNextNotif()
    if not NotifQueueEnabled then
        while #NotifQueue > 0 do
            local data = table.remove(NotifQueue, 1)
            _createNotif(EnsureNotifHolder(), data)
        end
        return
    end
    if NotifQueueBusy or #NotifQueue == 0 then return end
    NotifQueueBusy = true
    local data = table.remove(NotifQueue, 1)
    _createNotif(EnsureNotifHolder(), data)
end

function EclipseLib:Notify(opts)
    opts = opts or {}
    table.insert(NotifQueue, {
        Title = opts.Title or opts.title or "EclipseLib",
        Content = opts.Content or opts.text or "",
        Duration = opts.Duration or opts.duration or 3,
    })
    if NotifQueueEnabled then
        _showNextNotif()
    else
        local data = table.remove(NotifQueue, 1)
        _createNotif(EnsureNotifHolder(), data)
    end
end

-- ================= KEY SYSTEM (Encrypted Saving) =================
local function ShowKeySystem(opts, onSuccess)
    local keyList = opts.Key or {}
    local keyTitle = opts.KeyTitle or "🔑 ใส่ Key"
    local keyDesc = opts.KeyDescription or "กรอก Key เพื่อใช้งาน"
    local keyLink = opts.KeyLink or ""
    local saveFolder = opts.SaveFolder or "EclipseLib"
    local keyFile = saveFolder .. "/.eclipse_key.dat"

    local function encrypt(str, seed)
        seed = seed or 12345
        local res = ""
        for i = 1, #str do
            local c = str:sub(i,i)
            res = res .. string.char((string.byte(c) + seed + i) % 256)
        end
        return res
    end
    local function decrypt(enc, seed)
        seed = seed or 12345
        local res = ""
        for i = 1, #enc do
            local c = enc:sub(i,i)
            res = res .. string.char((string.byte(c) - seed - i) % 256)
        end
        return res
    end

    local function CheckSavedKey()
        local ok, saved = pcall(function()
            if not isfolder(saveFolder) then return nil end
            if not isfile(keyFile) then return nil end
            return readfile(keyFile)
        end)
        if not ok or not saved then return false end
        local decrypted = decrypt(saved)
        for _, k in ipairs(keyList) do
            if k == decrypted then return true end
        end
        pcall(function() delfile(keyFile) end)
        return false
    end

    local function SaveKey(key)
        pcall(function()
            if not isfolder(saveFolder) then makefolder(saveFolder) end
            writefile(keyFile, encrypt(key))
        end)
    end

    if CheckSavedKey() then onSuccess(); return end

    -- GUI construction...
    local sg = MakeScreenGui(_randomName("eclipse_key_"), 10001)
    local bgO = Instance.new("Frame")
    bgO.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bgO.BackgroundTransparency = 1
    bgO.Size = UDim2.new(1,0,1,0)
    bgO.Parent = sg

    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Background
    card.Size = UDim2.new(0,320,0,300)
    card.Position = UDim2.new(0.5,-160,0.5,-150)
    card.BackgroundTransparency = 1
    card.Parent = sg
    CC(card,14)
    CS(card,Theme.Accent,1.5)

    local gb = Instance.new("Frame")
    gb.BackgroundColor3 = Theme.Accent
    gb.Size = UDim2.new(1,0,0,3)
    gb.BorderSizePixel = 0
    gb.Parent = card

    local iL = Instance.new("TextLabel")
    iL.BackgroundTransparency = 1
    iL.Position = UDim2.new(0,0,0,16)
    iL.Size = UDim2.new(1,0,0,36)
    iL.Text = "🔑"
    iL.TextSize = 28
    iL.Font = Enum.Font.GothamBold
    iL.TextTransparency = 1
    iL.Parent = card

    local tL = Instance.new("TextLabel")
    tL.BackgroundTransparency = 1
    tL.Position = UDim2.new(0,0,0,54)
    tL.Size = UDim2.new(1,0,0,24)
    tL.Text = keyTitle
    tL.TextColor3 = Theme.Text
    tL.TextTransparency = 1
    tL.Font = Enum.Font.GothamBold
    tL.TextSize = 16
    tL.Parent = card

    local dL = Instance.new("TextLabel")
    dL.BackgroundTransparency = 1
    dL.Position = UDim2.new(0,16,0,80)
    dL.Size = UDim2.new(1,-32,0,30)
    dL.Text = keyDesc
    dL.TextColor3 = Theme.SubText
    dL.TextTransparency = 1
    dL.Font = Enum.Font.Gotham
    dL.TextSize = 12
    dL.TextWrapped = true
    dL.Parent = card

    local iBG = Instance.new("Frame")
    iBG.BackgroundColor3 = Theme.Input_BG
    iBG.BackgroundTransparency = 1
    iBG.Size = UDim2.new(1,-32,0,36)
    iBG.Position = UDim2.new(0,16,0,118)
    iBG.Parent = card
    CC(iBG,8)
    CS(iBG,Theme.Border)

    local iBox = Instance.new("TextBox")
    iBox.BackgroundTransparency = 1
    iBox.Size = UDim2.new(1,-12,1,0)
    iBox.Position = UDim2.new(0,8,0,0)
    iBox.PlaceholderText = "🔐 กรอก Key ที่นี่..."
    iBox.PlaceholderColor3 = Theme.SubText
    iBox.TextColor3 = Theme.Text
    iBox.TextTransparency = 1
    iBox.Font = Enum.Font.Gotham
    iBox.TextSize = 13
    iBox.ClearTextOnFocus = false
    iBox.Text = ""
    iBox.Parent = iBG

    local stL = Instance.new("TextLabel")
    stL.BackgroundTransparency = 1
    stL.Position = UDim2.new(0,16,0,160)
    stL.Size = UDim2.new(1,-32,0,16)
    stL.Text = ""
    stL.TextColor3 = Color3.fromRGB(200,60,60)
    stL.Font = Enum.Font.Gotham
    stL.TextSize = 11
    stL.Parent = card

    local rememberKey = true
    local remRow = Instance.new("Frame")
    remRow.BackgroundTransparency = 1
    remRow.Size = UDim2.new(1,-32,0,24)
    remRow.Position = UDim2.new(0,16,0,182)
    remRow.Parent = card

    local remLbl = Instance.new("TextLabel")
    remLbl.BackgroundTransparency = 1
    remLbl.Size = UDim2.new(1,-46,1,0)
    remLbl.Text = "💾 จำ Key ไว้ (ไม่ต้องใส่ทุกครั้ง)"
    remLbl.TextColor3 = Theme.SubText
    remLbl.Font = Enum.Font.Gotham
    remLbl.TextSize = 10
    remLbl.TextXAlignment = Enum.TextXAlignment.Left
    remLbl.Parent = remRow

    local remBG = Instance.new("Frame")
    remBG.BackgroundColor3 = Theme.Toggle_ON
    remBG.Size = UDim2.new(0,36,0,20)
    remBG.Position = UDim2.new(1,-38,0.5,-10)
    remBG.Parent = remRow
    CC(remBG,10)

    local remKnob = Instance.new("Frame")
    remKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    remKnob.Size = UDim2.new(0,14,0,14)
    remKnob.Position = UDim2.new(1,-17,0.5,-7)
    remKnob.Parent = remBG
    CC(remKnob,7)

    local remBtn = Instance.new("TextButton")
    remBtn.BackgroundTransparency = 1
    remBtn.Size = UDim2.new(1,0,1,0)
    remBtn.Text = ""
    remBtn.Parent = remRow

    remBtn.MouseButton1Click:Connect(function()
        rememberKey = not rememberKey
        Tween(remBG, { BackgroundColor3 = rememberKey and Theme.Toggle_ON or Theme.Toggle_OFF }, 0.2)
        Tween(remKnob, { Position = rememberKey and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7) }, 0.2)
    end)

    local glB = Instance.new("TextButton")
    glB.BackgroundColor3 = Theme.Secondary
    glB.BackgroundTransparency = 1
    glB.Size = UDim2.new(0,120,0,34)
    glB.Position = UDim2.new(0,16,0,214)
    glB.Text = "🔗 Get Key"
    glB.TextColor3 = Theme.Accent
    glB.TextTransparency = 1
    glB.Font = Enum.Font.GothamBold
    glB.TextSize = 12
    glB.Parent = card
    CC(glB,8)
    CS(glB,Theme.Accent,1)

    local suB = Instance.new("TextButton")
    suB.BackgroundColor3 = Theme.Accent
    suB.BackgroundTransparency = 1
    suB.Size = UDim2.new(0,130,0,34)
    suB.Position = UDim2.new(1,-146,0,214)
    suB.Text = "✅ ยืนยัน Key"
    suB.TextColor3 = Color3.fromRGB(255,255,255)
    suB.TextTransparency = 1
    suB.Font = Enum.Font.GothamBold
    suB.TextSize = 12
    suB.Parent = card
    CC(suB,8)

    task.spawn(function()
        Tween(bgO,{BackgroundTransparency=0.5},0.3)
        Tween(card,{BackgroundTransparency=0},0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        task.wait(0.15)
        for _,o in ipairs({iL,tL,dL,glB,suB}) do
            Tween(o,{TextTransparency=0},0.3)
            pcall(function() Tween(o,{BackgroundTransparency=0},0.3) end)
            task.wait(0.05)
        end
        Tween(iBG,{BackgroundTransparency=0},0.3)
        Tween(iBox,{TextTransparency=0},0.3)
    end)

    glB.MouseButton1Click:Connect(function()
        SetClipboard(keyLink)
        local old=glB.Text
        glB.Text="✅ คัดลอกแล้ว!"
        Tween(glB,{BackgroundColor3=Color3.fromRGB(30,80,40)},0.2)
        task.wait(2)
        glB.Text=old
        Tween(glB,{BackgroundColor3=Theme.Secondary},0.2)
    end)

    suB.MouseButton1Click:Connect(function()
        local entered = iBox.Text
        local valid = false
        for _,k in ipairs(keyList) do
            if k == entered then valid=true; break end
        end
        if valid then
            if rememberKey then SaveKey(entered) end
            stL.TextColor3 = Color3.fromRGB(60,200,100)
            stL.Text = rememberKey and "✅ Key ถูกต้อง! จำไว้แล้ว 💾" or "✅ Key ถูกต้อง!"
            task.wait(0.5)
            for i=1,3 do
                Tween(bgO,{BackgroundTransparency=i%2==0 and 0.5 or 0.1},0.06)
                task.wait(0.06)
            end
            Tween(card,{BackgroundTransparency=1,Size=UDim2.new(0,320,0,0)},0.25)
            Tween(bgO,{BackgroundTransparency=1},0.3)
            task.wait(0.35)
            sg:Destroy()
            onSuccess()
        else
            stL.TextColor3 = Color3.fromRGB(200,60,60)
            stL.Text = "❌ Key ไม่ถูกต้อง ลองใหม่!"
            Tween(iBG,{BackgroundColor3=Color3.fromRGB(60,20,20)},0.12)
            local op=iBG.Position
            for i=1,4 do
                Tween(iBG,{Position=UDim2.new(op.X.Scale,op.X.Offset+(i%2==0 and 6 or -6),op.Y.Scale,op.Y.Offset)},0.05)
                task.wait(0.05)
            end
            Tween(iBG,{Position=op,BackgroundColor3=Theme.Input_BG},0.1)
        end
    end)
end

-- ================= INTRO ANIMATIONS =================
local function RunIntro_Fade(sg, title, subtitle, onDone)
    local bg = Instance.new("Frame"); bg.BackgroundColor3 = Color3.fromRGB(8,8,12); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundTransparency = 1; bg.Parent = sg
    local glow = Instance.new("Frame"); glow.BackgroundColor3 = Theme.Accent; glow.BackgroundTransparency = 1; glow.Size = UDim2.new(0,180,0,180); glow.Position = UDim2.new(0.5,-90,0.5,-90); glow.Parent = bg; CC(glow,90)
    local iconL = Instance.new("TextLabel"); iconL.BackgroundTransparency=1; iconL.Size=UDim2.new(0,80,0,80); iconL.Position=UDim2.new(0.5,-40,0.5,-50); iconL.Text=IntroConfig.Icon; iconL.TextSize=56; iconL.Font=Enum.Font.GothamBold; iconL.TextTransparency=1; iconL.Parent=bg
    local titleL = Instance.new("TextLabel"); titleL.BackgroundTransparency=1; titleL.Size=UDim2.new(1,0,0,36); titleL.Position=UDim2.new(0,0,0.5,20); titleL.Text=title; titleL.TextColor3=Theme.Text; titleL.TextTransparency=1; titleL.Font=Enum.Font.GothamBold; titleL.TextSize=22; titleL.Parent=bg
    local subL = Instance.new("TextLabel"); subL.BackgroundTransparency=1; subL.Size=UDim2.new(1,0,0,24); subL.Position=UDim2.new(0,0,0.5,58); subL.Text=subtitle; subL.TextColor3=Theme.SubText; subL.TextTransparency=1; subL.Font=Enum.Font.Gotham; subL.TextSize=14; subL.Parent=bg
    local barBG = Instance.new("Frame"); barBG.BackgroundColor3=Theme.Slider_BG; barBG.BackgroundTransparency=1; barBG.Size=UDim2.new(0,220,0,3); barBG.Position=UDim2.new(0.5,-110,0.5,90); barBG.Parent=bg; CC(barBG,3)
    local barFill = Instance.new("Frame"); barFill.BackgroundColor3=Theme.Accent; barFill.Size=UDim2.new(0,0,1,0); barFill.Parent=barBG; CC(barFill,3)
    task.spawn(function()
        TweenWait(bg,{BackgroundTransparency=0},0.4)
        Tween(glow,{BackgroundTransparency=0.88,Size=UDim2.new(0,200,0,200),Position=UDim2.new(0.5,-100,0.5,-100)},0.6,Enum.EasingStyle.Sine)
        iconL.Position=UDim2.new(0.5,-40,0.5,-50)
        TweenWait(iconL,{TextTransparency=0,Position=UDim2.new(0.5,-40,0.5,-70)},0.5,Enum.EasingStyle.Quint)
        task.wait(0.1); TweenWait(titleL,{TextTransparency=0},0.45)
        task.wait(0.1); TweenWait(subL,{TextTransparency=0},0.4)
        task.wait(0.1); TweenWait(barBG,{BackgroundTransparency=0},0.3)
        TweenWait(barFill,{Size=UDim2.new(1,0,1,0)},1.2,Enum.EasingStyle.Quint)
        task.wait(0.25)
        Tween(iconL,{TextTransparency=1,Position=UDim2.new(0.5,-40,0.5,-90)},0.45)
        Tween(titleL,{TextTransparency=1},0.45); Tween(subL,{TextTransparency=1},0.45)
        Tween(barBG,{BackgroundTransparency=1},0.45); Tween(glow,{BackgroundTransparency=1},0.45)
        TweenWait(bg,{BackgroundTransparency=1},0.5); sg:Destroy(); onDone()
    end)
end

local function RunIntro_Zoom(sg, title, subtitle, onDone)
    local bg=Instance.new("Frame"); bg.BackgroundColor3=Color3.fromRGB(8,8,12); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundTransparency=1; bg.Parent=sg
    local iconL=Instance.new("TextLabel"); iconL.BackgroundTransparency=1; iconL.Size=UDim2.new(0,20,0,20); iconL.Position=UDim2.new(0.5,-10,0.5,-60); iconL.Text=IntroConfig.Icon; iconL.TextSize=12; iconL.TextTransparency=0.8; iconL.Font=Enum.Font.GothamBold; iconL.Parent=bg
    local titleL=Instance.new("TextLabel"); titleL.BackgroundTransparency=1; titleL.Size=UDim2.new(1,0,0,36); titleL.Position=UDim2.new(0,0,0.5,20); titleL.Text=title; titleL.TextColor3=Theme.Text; titleL.TextTransparency=1; titleL.Font=Enum.Font.GothamBold; titleL.TextSize=22; titleL.Parent=bg
    local subL=Instance.new("TextLabel"); subL.BackgroundTransparency=1; subL.Size=UDim2.new(1,0,0,24); subL.Position=UDim2.new(0,0,0.5,58); subL.Text=subtitle; subL.TextColor3=Theme.SubText; subL.TextTransparency=1; subL.Font=Enum.Font.Gotham; subL.TextSize=14; subL.Parent=bg
    local barBG=Instance.new("Frame"); barBG.BackgroundColor3=Theme.Slider_BG; barBG.BackgroundTransparency=1; barBG.Size=UDim2.new(0,220,0,3); barBG.Position=UDim2.new(0.5,-110,0.5,90); barBG.Parent=bg; CC(barBG,3)
    local barFill=Instance.new("Frame"); barFill.BackgroundColor3=Theme.Accent; barFill.Size=UDim2.new(0,0,1,0); barFill.Parent=barBG; CC(barFill,3)
    task.spawn(function()
        TweenWait(bg,{BackgroundTransparency=0},0.3)
        TweenWait(iconL,{TextSize=72,TextTransparency=0,Size=UDim2.new(0,80,0,80),Position=UDim2.new(0.5,-40,0.5,-70)},0.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        TweenWait(iconL,{TextSize=56,Size=UDim2.new(0,70,0,70)},0.2,Enum.EasingStyle.Bounce)
        task.wait(0.05); TweenWait(titleL,{TextTransparency=0},0.4); task.wait(0.1); TweenWait(subL,{TextTransparency=0},0.35)
        task.wait(0.1); TweenWait(barBG,{BackgroundTransparency=0},0.25); TweenWait(barFill,{Size=UDim2.new(1,0,1,0)},1.2,Enum.EasingStyle.Quint)
        task.wait(0.2); Tween(iconL,{TextTransparency=1,TextSize=100},0.5); Tween(titleL,{TextTransparency=1},0.4); Tween(subL,{TextTransparency=1},0.4); Tween(barBG,{BackgroundTransparency=1},0.4)
        TweenWait(bg,{BackgroundTransparency=1},0.5); sg:Destroy(); onDone()
    end)
end

local function RunIntro_Glitch(sg, title, subtitle, onDone)
    local bg=Instance.new("Frame"); bg.BackgroundColor3=Color3.fromRGB(8,8,12); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundTransparency=1; bg.Parent=sg
    for i=1,8 do local l=Instance.new("Frame"); l.BackgroundColor3=Color3.fromRGB(100,60,200); l.BackgroundTransparency=0.92; l.Size=UDim2.new(1,0,0,1); l.Position=UDim2.new(0,0,i/9,0); l.BorderSizePixel=0; l.Parent=bg end
    local iconL=Instance.new("TextLabel"); iconL.BackgroundTransparency=1; iconL.Size=UDim2.new(0,80,0,80); iconL.Position=UDim2.new(0.5,-40,0.5,-70); iconL.Text=IntroConfig.Icon; iconL.TextSize=56; iconL.TextTransparency=1; iconL.Font=Enum.Font.GothamBold; iconL.Parent=bg
    local titleL=Instance.new("TextLabel"); titleL.BackgroundTransparency=1; titleL.Size=UDim2.new(1,0,0,36); titleL.Position=UDim2.new(0,0,0.5,20); titleL.Text="█▓░ LOADING ░▓█"; titleL.TextColor3=Theme.Accent; titleL.TextTransparency=1; titleL.Font=Enum.Font.Code; titleL.TextSize=18; titleL.Parent=bg
    local subL=Instance.new("TextLabel"); subL.BackgroundTransparency=1; subL.Size=UDim2.new(1,0,0,24); subL.Position=UDim2.new(0,0,0.5,58); subL.Text=subtitle; subL.TextColor3=Theme.SubText; subL.TextTransparency=1; subL.Font=Enum.Font.Code; subL.TextSize=13; subL.Parent=bg
    local barBG=Instance.new("Frame"); barBG.BackgroundColor3=Theme.Slider_BG; barBG.BackgroundTransparency=1; barBG.Size=UDim2.new(0,220,0,3); barBG.Position=UDim2.new(0.5,-110,0.5,90); barBG.Parent=bg; CC(barBG,2)
    local barFill=Instance.new("Frame"); barFill.BackgroundColor3=Theme.Accent; barFill.Size=UDim2.new(0,0,1,0); barFill.Parent=barBG
    local gc={"█","▓","▒","░","▄","▌","▐","▀","■","□"}
    local function GT(lbl, ft, dur)
        local steps=math.floor(dur/0.06)
        for i=1,steps do
            local out=""
            for j=1,#ft do
                if i/steps>(j/#ft*0.8) then out=out..ft:sub(j,j) else out=out..gc[math.random(1,#gc)] end
            end
            lbl.Text=out; task.wait(0.06)
        end
        lbl.Text=ft
    end
    task.spawn(function()
        TweenWait(bg,{BackgroundTransparency=0},0.25)
        titleL.TextTransparency=0; iconL.TextTransparency=0; iconL.TextColor3=Theme.Accent
        for i=1,6 do iconL.TextTransparency=(i%2==0) and 0 or 0.7; iconL.Position=UDim2.new(0.5,math.random(-4,4),0.5,-70+math.random(-3,3)); task.wait(0.07) end
        iconL.TextTransparency=0; iconL.TextColor3=Theme.Text; iconL.Position=UDim2.new(0.5,-40,0.5,-70)
        task.wait(0.1); GT(titleL,title,0.9); titleL.TextColor3=Theme.Text; titleL.Font=Enum.Font.GothamBold; titleL.TextSize=22
        task.wait(0.1); TweenWait(subL,{TextTransparency=0},0.3); subL.Font=Enum.Font.Gotham
        task.wait(0.1); TweenWait(barBG,{BackgroundTransparency=0},0.2); TweenWait(barFill,{Size=UDim2.new(1,0,1,0)},1.1,Enum.EasingStyle.Linear)
        task.wait(0.2)
        for i=1,5 do bg.BackgroundColor3=i%2==0 and Color3.fromRGB(8,8,12) or Color3.fromRGB(20,10,40); task.wait(0.05) end
        Tween(iconL,{TextTransparency=1},0.35); Tween(titleL,{TextTransparency=1},0.35); Tween(subL,{TextTransparency=1},0.35); Tween(barBG,{BackgroundTransparency=1},0.35)
        TweenWait(bg,{BackgroundTransparency=1},0.45); sg:Destroy(); onDone()
    end)
end

local function RunIntro_Particle(sg, title, subtitle, onDone)
    local bg=Instance.new("Frame"); bg.BackgroundColor3=Color3.fromRGB(8,8,12); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundTransparency=1; bg.Parent=sg
    local parts={}; math.randomseed(tick())
    for i=1,28 do
        local p=Instance.new("Frame"); local sz=math.random(2,6)
        p.BackgroundColor3=(math.random()>0.5) and Theme.Accent or Color3.fromRGB(180,140,255)
        p.Size=UDim2.new(0,sz,0,sz)
        local a=math.rad(math.random(0,360)); local d=math.random(80,200)
        p.Position=UDim2.new(0.5+math.cos(a)*d/600,-sz/2,0.5+math.sin(a)*d/600,-sz/2)
        p.Parent=bg; CC(p,sz); table.insert(parts,p)
    end
    local iconL=Instance.new("TextLabel"); iconL.BackgroundTransparency=1; iconL.Size=UDim2.new(0,80,0,80); iconL.Position=UDim2.new(0.5,-40,0.5,-70); iconL.Text=IntroConfig.Icon; iconL.TextSize=12; iconL.TextTransparency=1; iconL.Font=Enum.Font.GothamBold; iconL.Parent=bg
    local titleL=Instance.new("TextLabel"); titleL.BackgroundTransparency=1; titleL.Size=UDim2.new(1,0,0,36); titleL.Position=UDim2.new(0,0,0.5,20); titleL.Text=title; titleL.TextColor3=Theme.Text; titleL.TextTransparency=1; titleL.Font=Enum.Font.GothamBold; titleL.TextSize=22; titleL.Parent=bg
    local subL=Instance.new("TextLabel"); subL.BackgroundTransparency=1; subL.Size=UDim2.new(1,0,0,24); subL.Position=UDim2.new(0,0,0.5,58); subL.Text=subtitle; subL.TextColor3=Theme.SubText; subL.TextTransparency=1; subL.Font=Enum.Font.Gotham; subL.TextSize=14; subL.Parent=bg
    local barBG=Instance.new("Frame"); barBG.BackgroundColor3=Theme.Slider_BG; barBG.BackgroundTransparency=1; barBG.Size=UDim2.new(0,220,0,3); barBG.Position=UDim2.new(0.5,-110,0.5,90); barBG.Parent=bg; CC(barBG,3)
    local barFill=Instance.new("Frame"); barFill.BackgroundColor3=Theme.Accent; barFill.Size=UDim2.new(0,0,1,0); barFill.Parent=barBG; CC(barFill,3)
    task.spawn(function()
        TweenWait(bg,{BackgroundTransparency=0},0.3)
        for _,p in ipairs(parts) do Tween(p,{Position=UDim2.new(0.5,-3,0.5,-3),BackgroundTransparency=0.3,Size=UDim2.new(0,4,0,4)},0.7,Enum.EasingStyle.Quint) end
        task.wait(0.65)
        for _,p in ipairs(parts) do Tween(p,{BackgroundTransparency=1,Size=UDim2.new(0,0,0,0)},0.2) end
        TweenWait(iconL,{TextTransparency=0,TextSize=56},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        task.wait(0.1); TweenWait(titleL,{TextTransparency=0},0.4); task.wait(0.1); TweenWait(subL,{TextTransparency=0},0.35)
        task.wait(0.1); TweenWait(barBG,{BackgroundTransparency=0},0.25); TweenWait(barFill,{Size=UDim2.new(1,0,1,0)},1.1,Enum.EasingStyle.Quint)
        task.wait(0.2); Tween(iconL,{TextTransparency=1},0.4); Tween(titleL,{TextTransparency=1},0.4); Tween(subL,{TextTransparency=1},0.4); Tween(barBG,{BackgroundTransparency=1},0.4)
        TweenWait(bg,{BackgroundTransparency=1},0.5); sg:Destroy(); onDone()
    end)
end

local function PlayIntro(title, subtitle, onDone)
    local sg = MakeScreenGui(_randomName("eclipse_intro_"), 10000)
    local m = IntroConfig.Mode
    if m == "zoom" then RunIntro_Zoom(sg,title,subtitle,onDone)
    elseif m == "glitch" then RunIntro_Glitch(sg,title,subtitle,onDone)
    elseif m == "particle" then RunIntro_Particle(sg,title,subtitle,onDone)
    else RunIntro_Fade(sg,title,subtitle,onDone) end
end

-- ================= CONFIG SYSTEM (Encrypted JSON) =================
local ConfigSystem = {}
ConfigSystem._folder = "EclipseLib"
ConfigSystem._data = {}
ConfigSystem._registered = {}

function ConfigSystem:SetFolder(f) self._folder = f end
function ConfigSystem:Register(key, getFn, setFn) self._registered[key] = { get = getFn, set = setFn } end

local function configEncrypt(str)
    local res = ""
    for i = 1, #str do
        local c = string.byte(str, i)
        res = res .. string.char((c + i * 3 + 7) % 256)
    end
    return res
end

local function configDecrypt(str)
    local res = ""
    for i = 1, #str do
        local c = string.byte(str, i)
        res = res .. string.char((c - i * 3 - 7) % 256)
    end
    return res
end

function ConfigSystem:GetSaveList()
    local list = {}
    pcall(function()
        if isfolder(self._folder) then
            for _, f in ipairs(listfiles(self._folder)) do
                local name = f:match("([^/\\]+)%.ecl$")
                if name then table.insert(list, name) end
            end
        end
    end)
    if #list == 0 then table.insert(list, "(ยังไม่มีไฟล์)") end
    return list
end

function ConfigSystem:Save(filename)
    if not filename or filename == "" or filename == "(ยังไม่มีไฟล์)" then return false end
    local snapshot = {}
    for key, fns in pairs(self._registered) do
        pcall(function() snapshot[key] = fns.get() end)
    end
    self._data[filename] = snapshot
    pcall(function()
        if not isfolder(self._folder) then makefolder(self._folder) end
        local json = HttpService:JSONEncode(snapshot)
        writefile(self._folder .. "/" .. filename .. ".ecl", configEncrypt(json))
    end)
    return true
end

function ConfigSystem:Load(filename)
    if not filename or filename == "" or filename == "(ยังไม่มีไฟล์)" then return false end
    local snapshot = nil
    pcall(function()
        local path = self._folder .. "/" .. filename .. ".ecl"
        if isfile(path) then
            local enc = readfile(path)
            local json = configDecrypt(enc)
            snapshot = HttpService:JSONDecode(json)
        end
    end)
    if snapshot then
        for key, fns in pairs(self._registered) do
            if snapshot[key] ~= nil then
                pcall(function() fns.set(snapshot[key]) end)
            end
        end
        return true
    end
    return false
end

-- ================= MAIN WINDOW =================
function EclipseLib:CreateWindow(opts)
    opts = opts or {}
    local windowName = opts.Name or "EclipseLib"
    local loadTitle = opts.LoadingTitle or "🌒 EclipseLib"
    local loadSub = opts.LoadingSubtitle or "กำลังโหลด..."
    local useKey = opts.KeySystem or false
    local cfgFolder = (opts.ConfigurationSaving and opts.ConfigurationSaving.FolderName) or "EclipseLib"
    local keyOpts = {
        Key = opts.Key or {},
        KeyTitle = opts.KeyTitle or "🔑 ใส่ Key",
        KeyDescription = opts.KeyDescription or "กรอก Key เพื่อใช้งาน",
        KeyLink = opts.KeyLink or "",
        SaveFolder = cfgFolder,
    }
    ConfigSystem:SetFolder(cfgFolder)

    -- Updaters system
    local updaters = {}
    local function addUpdater(element, updateFunc)
        table.insert(updaters, {element, updateFunc})
    end
    local function removeUpdatersForElement(element)
        for i = #updaters, 1, -1 do
            if updaters[i][1] == element then
                table.remove(updaters, i)
            end
        end
    end
    RunService.Heartbeat:Connect(function()
        for _, v in ipairs(updaters) do
            pcall(v[2], v[1])
        end
    end)

    local ScreenGui = MakeScreenGui(_randomName("eclipse_main_"), 999)
    local Main = Instance.new("Frame")
    Main.BackgroundColor3 = Theme.Background
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.ClipsDescendants = true
    Main.Visible = false
    Main.Parent = ScreenGui
    CC(Main, 12)
    CS(Main, Theme.Border, 1.5)

    local TopBar = Instance.new("Frame")
    TopBar.BackgroundColor3 = Theme.Secondary
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.Parent = Main
    CC(TopBar, 12)
    local tbFix = Instance.new("Frame")
    tbFix.BackgroundColor3 = Theme.Secondary
    tbFix.Size = UDim2.new(1, 0, 0, 10)
    tbFix.Position = UDim2.new(0, 0, 1, -10)
    tbFix.BorderSizePixel = 0
    tbFix.Parent = TopBar

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.Size = UDim2.new(1, -80, 1, 0)
    TitleLbl.Text = "🌒 " .. windowName
    TitleLbl.TextColor3 = Theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Parent = TopBar
    CC(CloseBtn, 6)

    local MinBtn = Instance.new("TextButton")
    MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    MinBtn.Size = UDim2.new(0, 22, 0, 22)
    MinBtn.Position = UDim2.new(1, -56, 0.5, -11)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Theme.Text
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 12
    MinBtn.Parent = TopBar
    CC(MinBtn, 6)

    MakeDraggable(Main, TopBar)

    local Body = Instance.new("Frame")
    Body.BackgroundTransparency = 1
    Body.Position = UDim2.new(0, 0, 0, 38)
    Body.Size = UDim2.new(1, 0, 1, -38)
    Body.Parent = Main

    local TabBar = Instance.new("ScrollingFrame")
    TabBar.BackgroundColor3 = Theme.Secondary
    TabBar.Size = UDim2.new(0, 115, 1, 0)
    TabBar.ScrollBarThickness = 2
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.ScrollingDirection = Enum.ScrollingDirection.Y
    TabBar.Parent = Body
    CS(TabBar, Theme.Border, 1)
    local TL = Instance.new("UIListLayout")
    TL.SortOrder = Enum.SortOrder.LayoutOrder
    TL.Padding = UDim.new(0, 4)
    TL.Parent = TabBar
    local TP = Instance.new("UIPadding")
    TP.PaddingTop = UDim.new(0, 6)
    TP.PaddingLeft = UDim.new(0, 5)
    TP.PaddingRight = UDim.new(0, 5)
    TP.Parent = TabBar
    TL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBar.CanvasSize = UDim2.new(0, 0, 0, TL.AbsoluteContentSize.Y + 12)
    end)

    local ContentArea = Instance.new("Frame")
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 119, 0, 0)
    ContentArea.Size = UDim2.new(1, -119, 1, 0)
    ContentArea.Parent = Body

    local isOpen = true
    MinBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        Tween(Main, { Size = isOpen and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 500, 0, 38) }, 0.3)
        MinBtn.Text = isOpen and "—" or "▲"
    end)

    local floatSG = MakeScreenGui(_randomName("eclipse_float_"), 998)
    local floatBtn = Instance.new("TextButton")
    floatBtn.BackgroundColor3 = Theme.Accent
    floatBtn.Size = UDim2.new(0, 46, 0, 46)
    floatBtn.Position = UDim2.new(0, 12, 0.5, -23)
    floatBtn.Text = "🌒"
    floatBtn.TextSize = 22
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.Visible = false
    floatBtn.Parent = floatSG
    CC(floatBtn, 23)
    CS(floatBtn, Theme.Border, 1.5)
    MakeDraggable(floatBtn, floatBtn)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, { Size = UDim2.new(0, 500, 0, 0) }, 0.25)
        task.wait(0.3)
        Main.Visible = false
        floatBtn.Visible = true
    end)
    floatBtn.MouseButton1Click:Connect(function()
        floatBtn.Visible = false
        Main.Visible = true
        Main.Size = UDim2.new(0, 500, 0, 0)
        Tween(Main, { Size = UDim2.new(0, 500, 0, 350) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        isOpen = true
        MinBtn.Text = "—"
    end)

    local tabButtons = {}
    local tabFrames = {}
    local activeTab = nil

    local function SetActiveTab(name)
        for n, btn in pairs(tabButtons) do
            local isAct = (n == name)
            Tween(btn, { BackgroundColor3 = isAct and Theme.TabActive or Theme.TabInactive }, 0.2)
            btn.TextColor3 = isAct and Color3.fromRGB(255, 255, 255) or Theme.SubText
            local ind = btn:FindFirstChild("_Indicator")
            if ind then ind.Visible = isAct end
        end
        for n, f in pairs(tabFrames) do
            f.Visible = (n == name)
        end
        activeTab = name
    end

    local function MakeSF(name)
        local sf = Instance.new("ScrollingFrame")
        sf.Name = name
        sf.BackgroundTransparency = 1
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ScrollBarThickness = 3
        sf.Visible = false
        sf.Parent = ContentArea
        local ly = Instance.new("UIListLayout")
        ly.Padding = UDim.new(0, 6)
        ly.SortOrder = Enum.SortOrder.LayoutOrder
        ly.Parent = sf
        local pd = Instance.new("UIPadding")
        pd.PaddingTop = UDim.new(0, 8)
        pd.PaddingLeft = UDim.new(0, 8)
        pd.PaddingRight = UDim.new(0, 8)
        pd.Parent = sf
        ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, ly.AbsoluteContentSize.Y + 20)
        end)
        return sf
    end

    local function MakeTabBtn(label, active)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = active and Theme.TabActive or Theme.TabInactive
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.Text = label
        btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Theme.SubText
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextWrapped = true
        btn.Parent = TabBar
        CC(btn, 8)
        local ind = Instance.new("Frame")
        ind.Name = "_Indicator"
        ind.BackgroundColor3 = Theme.Accent
        ind.Size = UDim2.new(0, 3, 1, -8)
        ind.Position = UDim2.new(0, 0, 0, 4)
        ind.BorderSizePixel = 0
        ind.Visible = active
        ind.Parent = btn
        CC(ind, 2)
        return btn
    end

    -- Helper card for Welcome/Settings
    local function createCard(parent, height)
        local c = Instance.new("Frame")
        c.BackgroundColor3 = Theme.Secondary
        c.Size = UDim2.new(1, 0, 0, height)
        c.Parent = parent
        CC(c, 10)
        CS(c, Theme.Border, 1)
        local leftBar = Instance.new("Frame")
        leftBar.BackgroundColor3 = Theme.Accent
        leftBar.Size = UDim2.new(0, 3, 1, -16)
        leftBar.Position = UDim2.new(0, 0, 0, 8)
        leftBar.BorderSizePixel = 0
        leftBar.Parent = c
        CC(leftBar, 2)
        return c
    end

    -- ==================== WELCOME TAB ====================
    do
        local wBtn = MakeTabBtn("🏠 ยินดีต้อนรับ", true)
        local wFrame = MakeSF("Frame_Welcome")
        wFrame.Visible = true
        tabButtons["_Welcome"] = wBtn
        tabFrames["_Welcome"] = wFrame
        activeTab = "_Welcome"

        -- Account Card
        local aCard = createCard(wFrame, 84)
        local aFr = Instance.new("Frame")
        aFr.BackgroundColor3 = Theme.Accent
        aFr.Size = UDim2.new(0, 62, 0, 62)
        aFr.Position = UDim2.new(0, 11, 0.5, -31)
        aFr.Parent = aCard
        CC(aFr, 31)
        CS(aFr, Theme.Accent, 2)
        local aImg = Instance.new("ImageLabel")
        aImg.BackgroundTransparency = 1
        aImg.Size = UDim2.new(1, -4, 1, -4)
        aImg.Position = UDim2.new(0, 2, 0, 2)
        aImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer.UserId) .. "&width=150&height=150&format=png"
        aImg.Parent = aFr
        CC(aImg, 29)

        local dN = Instance.new("TextLabel")
        dN.BackgroundTransparency = 1
        dN.Position = UDim2.new(0, 86, 0, 8)
        dN.Size = UDim2.new(1, -166, 0, 22)
        dN.Text = LocalPlayer.DisplayName or "?"
        dN.TextColor3 = Theme.Text
        dN.Font = Enum.Font.GothamBold
        dN.TextSize = 16
        dN.TextXAlignment = Enum.TextXAlignment.Left
        dN.Parent = aCard

        local uN = Instance.new("TextLabel")
        uN.BackgroundTransparency = 1
        uN.Position = UDim2.new(0, 86, 0, 32)
        uN.Size = UDim2.new(1, -166, 0, 16)
        uN.Text = "@" .. (LocalPlayer.Name or "?")
        uN.TextColor3 = Theme.SubText
        uN.Font = Enum.Font.Gotham
        uN.TextSize = 12
        uN.TextXAlignment = Enum.TextXAlignment.Left
        uN.Parent = aCard

        local idB = Instance.new("Frame")
        idB.BackgroundColor3 = Theme.Accent
        idB.Size = UDim2.new(0, 100, 0, 18)
        idB.Position = UDim2.new(0, 86, 0, 54)
        idB.Parent = aCard
        CC(idB, 6)
        local idL = Instance.new("TextLabel")
        idL.BackgroundTransparency = 1
        idL.Size = UDim2.new(1, 0, 1, 0)
        idL.Text = "🆔 " .. tostring(LocalPlayer.UserId)
        idL.TextColor3 = Color3.fromRGB(255, 255, 255)
        idL.Font = Enum.Font.GothamBold
        idL.TextSize = 10
        idL.Parent = idB

        local function MakeCopyBtn(parent, xPos, yPos, getCopyVal)
            local btn = Instance.new("TextButton")
            btn.BackgroundColor3 = Theme.Secondary
            btn.Size = UDim2.new(0, 60, 0, 20)
            btn.Position = UDim2.new(1, xPos, 0, yPos)
            btn.Text = "📋 Copy"
            btn.TextColor3 = Theme.Accent
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 9
            btn.Parent = parent
            CC(btn, 5)
            CS(btn, Theme.Accent, 1)
            btn.MouseButton1Click:Connect(function()
                SetClipboard(tostring(getCopyVal()))
                local old = btn.Text
                btn.Text = "✅ แล้ว!"
                Tween(btn, { BackgroundColor3 = Color3.fromRGB(30, 80, 40) }, 0.1)
                task.wait(1.2)
                btn.Text = old
                Tween(btn, { BackgroundColor3 = Theme.Secondary }, 0.15)
            end)
        end
        MakeCopyBtn(aCard, -68, 8, function() return LocalPlayer.DisplayName end)
        MakeCopyBtn(aCard, -68, 32, function() return LocalPlayer.Name end)

        -- Info Cards
        local function MakeInfoCard(icon, label, valFn, copyable)
            local c = createCard(wFrame, 54)
            local iL = Instance.new("TextLabel")
            iL.BackgroundTransparency = 1
            iL.Position = UDim2.new(0, 8, 0, 0)
            iL.Size = UDim2.new(0, 30, 1, 0)
            iL.Text = icon
            iL.TextSize = 20
            iL.Font = Enum.Font.GothamBold
            iL.Parent = c

            local kL = Instance.new("TextLabel")
            kL.BackgroundTransparency = 1
            kL.Position = UDim2.new(0, 44, 0, 7)
            kL.Size = UDim2.new(1, -120, 0, 16)
            kL.Text = label
            kL.TextColor3 = Theme.SubText
            kL.TextSize = 10
            kL.Font = Enum.Font.Gotham
            kL.TextXAlignment = Enum.TextXAlignment.Left
            kL.Parent = c

            local vL = Instance.new("TextLabel")
            vL.BackgroundTransparency = 1
            vL.Position = UDim2.new(0, 44, 0, 24)
            vL.Size = UDim2.new(1, -120, 0, 22)
            vL.Text = tostring(valFn())
            vL.TextColor3 = Theme.Text
            vL.TextSize = 13
            vL.Font = Enum.Font.GothamBold
            vL.TextXAlignment = Enum.TextXAlignment.Left
            vL.Parent = c

            addUpdater(vL, function(lbl)
                local v = tostring(valFn())
                lbl.Text = v
            end)
            vL.Destroying:Connect(function() removeUpdatersForElement(vL) end)

            if copyable then
                local cpBtn = Instance.new("TextButton")
                cpBtn.BackgroundColor3 = Theme.Secondary
                cpBtn.Size = UDim2.new(0, 60, 0, 22)
                cpBtn.Position = UDim2.new(1, -70, 0.5, -11)
                cpBtn.Text = "📋 Copy"
                cpBtn.TextColor3 = Theme.Accent
                cpBtn.Font = Enum.Font.GothamBold
                cpBtn.TextSize = 9
                cpBtn.Parent = c
                CC(cpBtn, 5)
                CS(cpBtn, Theme.Accent, 1)
                cpBtn.MouseButton1Click:Connect(function()
                    SetClipboard(tostring(valFn()))
                    local old = cpBtn.Text
                    cpBtn.Text = "✅ แล้ว!"
                    Tween(cpBtn, { BackgroundColor3 = Color3.fromRGB(30, 80, 40) }, 0.1)
                    task.wait(1.2)
                    cpBtn.Text = old
                    Tween(cpBtn, { BackgroundColor3 = Theme.Secondary }, 0.15)
                end)
            end
        end

        MakeInfoCard("🗺️", "ชื่อแมพ", function()
            local name = ""
            pcall(function() name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
            if not name or name == "" then pcall(function() name = game.Name end) end
            return name ~= "" and name or "ไม่พบชื่อแมพ"
        end, true)
        MakeInfoCard("📍", "Place ID", function() return tostring(game.PlaceId) end, true)
        MakeInfoCard("⏳", "อายุบัญชี", function()
            local days = LocalPlayer.AccountAge or 0
            local years = math.floor(days/365); local remain = days - (years*365)
            local months = math.floor(remain/30); local d = remain - (months*30)
            local result = ""
            if years > 0 then result = result .. years .. " ปี " end
            if months > 0 then result = result .. months .. " เดือน " end
            result = result .. d .. " วัน"
            return result
        end, false)
        MakeInfoCard("🖥️", "Server ID", function() return game.JobId or "ไม่พบ" end, true)
        local sessionStart = tick()
        MakeInfoCard("⏱️", "เวลาที่เล่น", function()
            local elapsed = math.floor(tick() - sessionStart)
            local d = math.floor(elapsed/86400); elapsed = elapsed - (d*86400)
            local h = math.floor(elapsed/3600); elapsed = elapsed - (h*3600)
            local m = math.floor(elapsed/60); local s = elapsed - (m*60)
            local result = ""
            if d > 0 then result = result .. d .. " วัน " end
            if h > 0 then result = result .. h .. " ชั่วโมง " end
            if m > 0 then result = result .. m .. " นาที " end
            result = result .. s .. " วินาที"
            return result
        end, false)

        -- Credit
        local creditCard = createCard(wFrame, 36)
        local creditL = Instance.new("TextLabel")
        creditL.BackgroundTransparency = 1
        creditL.Size = UDim2.new(1, 0, 1, 0)
        creditL.Text = "🏷️ UI สร้างโดย wino444 · ปรับปรุงโดย Deekseek"
        creditL.TextColor3 = Theme.Accent
        creditL.Font = Enum.Font.GothamBold
        creditL.TextSize = 11
        creditL.Parent = creditCard
        wBtn.MouseButton1Click:Connect(function() SetActiveTab("_Welcome") end)
    end

    -- ==================== SETTINGS TAB ====================
    do
        local sBtn = MakeTabBtn("⚙️ ตั้งค่า UI", false)
        local sFrame = MakeSF("Frame_Settings")
        tabButtons["_Settings"] = sBtn
        tabFrames["_Settings"] = sFrame
        sBtn.MouseButton1Click:Connect(function() SetActiveTab("_Settings") end)

        local function SecTitle(text)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(1, 0, 0, 22)
            l.Text = text
            l.TextColor3 = Theme.Accent
            l.Font = Enum.Font.GothamBold
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = sFrame
        end

        -- Preset Themes
        SecTitle("🎨 Preset Themes")
        local Themes = {
            {name = "🌒 Eclipse", accent = Color3.fromRGB(100,60,200), bg = Color3.fromRGB(15,15,20), sec = Color3.fromRGB(22,22,30), border = Color3.fromRGB(50,40,80), inactive = Color3.fromRGB(30,28,40)},
            {name = "🌊 Ocean", accent = Color3.fromRGB(30,120,220), bg = Color3.fromRGB(10,18,28), sec = Color3.fromRGB(15,28,42), border = Color3.fromRGB(20,60,100), inactive = Color3.fromRGB(18,32,50)},
            {name = "🌲 Forest", accent = Color3.fromRGB(40,170,90), bg = Color3.fromRGB(10,18,12), sec = Color3.fromRGB(15,26,18), border = Color3.fromRGB(25,70,35), inactive = Color3.fromRGB(18,32,20)},
            {name = "🔥 Inferno", accent = Color3.fromRGB(220,80,30), bg = Color3.fromRGB(20,10,8), sec = Color3.fromRGB(30,15,10), border = Color3.fromRGB(80,30,15), inactive = Color3.fromRGB(35,18,12)},
            {name = "🌸 Sakura", accent = Color3.fromRGB(220,80,140), bg = Color3.fromRGB(20,12,18), sec = Color3.fromRGB(30,18,26), border = Color3.fromRGB(80,30,60), inactive = Color3.fromRGB(35,18,30)},
            {name = "🖤 Midnight", accent = Color3.fromRGB(160,160,180), bg = Color3.fromRGB(8,8,10), sec = Color3.fromRGB(14,14,18), border = Color3.fromRGB(40,40,50), inactive = Color3.fromRGB(20,20,26)},
        }
        local thCard = createCard(sFrame, 120)
        local thLy = Instance.new("UIGridLayout")
        thLy.CellSize = UDim2.new(0.31, 0, 0, 48)
        thLy.CellPadding = UDim2.new(0.02, 0, 0, 6)
        thLy.SortOrder = Enum.SortOrder.LayoutOrder
        thLy.Parent = thCard
        local thPd = Instance.new("UIPadding")
        thPd.PaddingTop = UDim.new(0, 8)
        thPd.PaddingLeft = UDim.new(0, 6)
        thPd.PaddingRight = UDim.new(0, 6)
        thPd.Parent = thCard

        for _, th in ipairs(Themes) do
            local tb = Instance.new("TextButton")
            tb.BackgroundColor3 = th.bg
            tb.Size = UDim2.new(1, 0, 1, 0)
            tb.Text = th.name
            tb.TextColor3 = Color3.fromRGB(220, 220, 235)
            tb.Font = Enum.Font.GothamBold
            tb.TextSize = 10
            tb.TextWrapped = true
            tb.Parent = thCard
            CC(tb, 7)
            CS(tb, th.accent, 1.5)
            tb.MouseButton1Click:Connect(function()
                Theme.Background = th.bg
                Theme.Secondary = th.sec
                Theme.Border = th.border
                Theme.TabInactive = th.inactive
                Theme.Accent = th.accent
                Theme.TabActive = th.accent
                Theme.Toggle_ON = th.accent
                Theme.Slider_Fill = th.accent
                Theme.Notif_Border = th.accent
                Theme.Dropdown_BG = th.sec
                Theme.Input_BG = th.sec
                Theme.Slider_BG = th.sec
                -- Apply visually
                Main.BackgroundColor3 = Theme.Background
                TopBar.BackgroundColor3 = Theme.Secondary
                tbFix.BackgroundColor3 = Theme.Secondary
                TabBar.BackgroundColor3 = Theme.Secondary
                for _, btn in pairs(tabButtons) do
                    if btn.Name ~= "_Settings" then
                        local isAct = (btn.Text == activeTab)
                        btn.BackgroundColor3 = isAct and Theme.TabActive or Theme.TabInactive
                    end
                end
                floatBtn.BackgroundColor3 = Theme.Accent
                EclipseLib:Notify({ Title = "🎨 เปลี่ยน Theme แล้ว", Content = th.name, Duration = 2 })
            end)
        end

        -- Custom Accent Color
        SecTitle("🖌️ Custom Accent Color")
        local rgbCard = createCard(sFrame, 150)
        local prevFrame = Instance.new("Frame")
        prevFrame.BackgroundColor3 = Theme.Accent
        prevFrame.Size = UDim2.new(1, -20, 0, 22)
        prevFrame.Position = UDim2.new(0, 10, 0, 8)
        prevFrame.Parent = rgbCard
        CC(prevFrame, 6)
        local prevLbl = Instance.new("TextLabel")
        prevLbl.BackgroundTransparency = 1
        prevLbl.Size = UDim2.new(1, 0, 1, 0)
        prevLbl.Text = "Preview"
        prevLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        prevLbl.Font = Enum.Font.GothamBold
        prevLbl.TextSize = 11
        prevLbl.Parent = prevFrame

        local rVal, gVal, bVal = 100, 60, 200
        local function UpdatePreview()
            local c = Color3.fromRGB(rVal, gVal, bVal)
            prevFrame.BackgroundColor3 = c
            prevLbl.Text = "R:" .. rVal .. " G:" .. gVal .. " B:" .. bVal
        end
        local function MakeRGBSlider(label, yPos, initVal, onChange)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.new(0, 10, 0, yPos)
            lbl.Size = UDim2.new(0, 18, 0, 16)
            lbl.Text = label
            lbl.TextColor3 = Theme.SubText
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.Parent = rgbCard

            local valLbl = Instance.new("TextLabel")
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(1, -36, 0, yPos)
            valLbl.Size = UDim2.new(0, 30, 0, 16)
            valLbl.Text = tostring(initVal)
            valLbl.TextColor3 = Theme.Text
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 11
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = rgbCard

            local tr = Instance.new("Frame")
            tr.BackgroundColor3 = Theme.Slider_BG
            tr.Size = UDim2.new(1, -62, 0, 8)
            tr.Position = UDim2.new(0, 30, 0, yPos + 4)
            tr.Parent = rgbCard
            CC(tr, 4)

            local fillColor = label == "R" and Color3.fromRGB(220, 60, 60) or label == "G" and Color3.fromRGB(60, 200, 80) or Color3.fromRGB(60, 120, 220)
            local fi = Instance.new("Frame")
            fi.BackgroundColor3 = fillColor
            fi.Size = UDim2.new(initVal / 255, 0, 1, 0)
            fi.Parent = tr
            CC(fi, 4)

            local drag = false
            local function upd(pos)
                local r = math.clamp((pos.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
                local v = math.floor(r * 255)
                fi.Size = UDim2.new(r, 0, 1, 0)
                valLbl.Text = tostring(v)
                onChange(v)
                UpdatePreview()
            end
            tr.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = true
                    upd(i.Position)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    upd(i.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = false
                end
            end)
        end
        MakeRGBSlider("R", 38, rVal, function(v) rVal = v end)
        MakeRGBSlider("G", 64, gVal, function(v) gVal = v end)
        MakeRGBSlider("B", 90, bVal, function(v) bVal = v end)

        local applyBtn = Instance.new("TextButton")
        applyBtn.BackgroundColor3 = Theme.Accent
        applyBtn.Size = UDim2.new(1, -20, 0, 28)
        applyBtn.Position = UDim2.new(0, 10, 0, 116)
        applyBtn.Text = "🎨 ใช้สีนี้"
        applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyBtn.Font = Enum.Font.GothamBold
        applyBtn.TextSize = 12
        applyBtn.Parent = rgbCard
        CC(applyBtn, 7)
        applyBtn.MouseButton1Click:Connect(function()
            local c = Color3.fromRGB(rVal, gVal, bVal)
            Theme.Accent = c
            Theme.TabActive = c
            Theme.Toggle_ON = c
            Theme.Slider_Fill = c
            Theme.Notif_Border = c
            -- apply to UI
            floatBtn.BackgroundColor3 = c
            for _, btn in pairs(tabButtons) do
                if btn.Text == activeTab then
                    btn.BackgroundColor3 = c
                end
            end
            applyBtn.BackgroundColor3 = c
            EclipseLib:Notify({ Title = "🎨 ใช้สีแล้ว!", Content = "R:" .. rVal .. " G:" .. gVal .. " B:" .. bVal, Duration = 2 })
        end)

        -- UI Size
        SecTitle("📏 ขนาด UI")
        local szRow = createCard(sFrame, 48)
        local sl2 = Instance.new("UIListLayout")
        sl2.FillDirection = Enum.FillDirection.Horizontal
        sl2.Padding = UDim.new(0, 6)
        sl2.VerticalAlignment = Enum.VerticalAlignment.Center
        sl2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sl2.Parent = szRow
        local sizes = {
            { "เล็ก", UDim2.new(0, 420, 0, 300) },
            { "กลาง", UDim2.new(0, 500, 0, 350) },
            { "ใหญ่", UDim2.new(0, 600, 0, 420) }
        }
        for _, sz in ipairs(sizes) do
            local b = Instance.new("TextButton")
            b.BackgroundColor3 = Theme.TabInactive
            b.Size = UDim2.new(0, 80, 0, 30)
            b.Text = sz[1]
            b.TextColor3 = Theme.Text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.Parent = szRow
            CC(b, 8)
            b.MouseButton1Click:Connect(function()
                if isOpen then
                    Tween(Main, { Size = sz[2] }, 0.3)
                    Main.Position = UDim2.new(0.5, -sz[2].X.Offset/2, 0.5, -sz[2].Y.Offset/2)
                end
            end)
        end

        -- Notification Position
        SecTitle("🔔 ตำแหน่ง Notification")
        local nRow = createCard(sFrame, 48)
        local nl = Instance.new("UIListLayout")
        nl.FillDirection = Enum.FillDirection.Horizontal
        nl.Padding = UDim.new(0, 6)
        nl.VerticalAlignment = Enum.VerticalAlignment.Center
        nl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        nl.Parent = nRow
        local notifPositions = {
            { "มุมขวาบน", UDim2.new(1, -220, 0, 60) },
            { "มุมซ้ายบน", UDim2.new(0, 10, 0, 60) }
        }
        for _, np in ipairs(notifPositions) do
            local b = Instance.new("TextButton")
            b.BackgroundColor3 = Theme.TabInactive
            b.Size = UDim2.new(0, 110, 0, 30)
            b.Text = np[1]
            b.TextColor3 = Theme.Text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.Parent = nRow
            CC(b, 8)
            b.MouseButton1Click:Connect(function()
                EnsureNotifHolder()
                NotifHolder.Position = np[2]
                EclipseLib:Notify({ Title = "🔔 เปลี่ยนตำแหน่งแล้ว", Content = np[1], Duration = 2 })
            end)
        end

        -- Transparency Slider
        SecTitle("🌗 ความโปร่งใส UI")
        local tCard = createCard(sFrame, 60)
        local tNL = Instance.new("TextLabel")
        tNL.BackgroundTransparency = 1
        tNL.Position = UDim2.new(0, 10, 0, 6)
        tNL.Size = UDim2.new(0.68, 0, 0, 18)
        tNL.Text = "ความโปร่งใสพื้นหลัง"
        tNL.TextColor3 = Theme.Text
        tNL.Font = Enum.Font.GothamBold
        tNL.TextSize = 12
        tNL.TextXAlignment = Enum.TextXAlignment.Left
        tNL.Parent = tCard

        local tVL = Instance.new("TextLabel")
        tVL.BackgroundTransparency = 1
        tVL.Position = UDim2.new(0.7, 0, 0, 6)
        tVL.Size = UDim2.new(0.28, 0, 0, 18)
        tVL.Text = "0%"
        tVL.TextColor3 = Theme.Accent
        tVL.Font = Enum.Font.GothamBold
        tVL.TextSize = 13
        tVL.TextXAlignment = Enum.TextXAlignment.Right
        tVL.Parent = tCard

        local tTr = Instance.new("Frame")
        tTr.BackgroundColor3 = Theme.Slider_BG
        tTr.Size = UDim2.new(1, -20, 0, 8)
        tTr.Position = UDim2.new(0, 10, 0, 36)
        tTr.Parent = tCard
        CC(tTr, 4)

        local tFi = Instance.new("Frame")
        tFi.BackgroundColor3 = Theme.Slider_Fill
        tFi.Size = UDim2.new(0, 0, 1, 0)
        tFi.Parent = tTr
        CC(tFi, 4)

        local tDrag = false
        tTr.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                tDrag = true
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if tDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local r = math.clamp((i.Position.X - tTr.AbsolutePosition.X) / tTr.AbsoluteSize.X, 0, 1)
                tFi.Size = UDim2.new(r, 0, 1, 0)
                tVL.Text = math.floor(r * 80) .. "%"
                Main.BackgroundTransparency = r * 0.8
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                tDrag = false
            end
        end)

        -- Notification Queue Toggle
        SecTitle("🔔 ระบบคิว Notification")
        local qCard = createCard(sFrame, 54)
        local qIcon = Instance.new("TextLabel")
        qIcon.BackgroundTransparency = 1
        qIcon.Position = UDim2.new(0, 10, 0, 8)
        qIcon.Size = UDim2.new(0, 24, 0, 18)
        qIcon.Text = "📋"
        qIcon.TextSize = 16
        qIcon.Font = Enum.Font.GothamBold
        qIcon.Parent = qCard

        local qNL = Instance.new("TextLabel")
        qNL.BackgroundTransparency = 1
        qNL.Position = UDim2.new(0, 38, 0, 6)
        qNL.Size = UDim2.new(0.6, 0, 0, 18)
        qNL.Text = "ระบบคิว Notification"
        qNL.TextColor3 = Theme.Text
        qNL.Font = Enum.Font.GothamBold
        qNL.TextSize = 12
        qNL.TextXAlignment = Enum.TextXAlignment.Left
        qNL.Parent = qCard

        local qDL = Instance.new("TextLabel")
        qDL.BackgroundTransparency = 1
        qDL.Position = UDim2.new(0, 38, 0, 26)
        qDL.Size = UDim2.new(0.65, 0, 0, 16)
        qDL.Text = "แสดงทีละอันตามลำดับ"
        qDL.TextColor3 = Theme.SubText
        qDL.Font = Enum.Font.Gotham
        qDL.TextSize = 10
        qDL.TextXAlignment = Enum.TextXAlignment.Left
        qDL.Parent = qCard

        local qSW = Instance.new("Frame")
        qSW.BackgroundColor3 = Theme.Toggle_OFF
        qSW.Size = UDim2.new(0, 44, 0, 24)
        qSW.Position = UDim2.new(1, -54, 0.5, -12)
        qSW.Parent = qCard
        CC(qSW, 12)

        local qKN = Instance.new("Frame")
        qKN.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        qKN.Size = UDim2.new(0, 18, 0, 18)
        qKN.Position = UDim2.new(0, 3, 0.5, -9)
        qKN.Parent = qSW
        CC(qKN, 9)

        local qBtn = Instance.new("TextButton")
        qBtn.BackgroundTransparency = 1
        qBtn.Size = UDim2.new(1, 0, 1, 0)
        qBtn.Text = ""
        qBtn.Parent = qCard

        qBtn.MouseButton1Click:Connect(function()
            NotifQueueEnabled = not NotifQueueEnabled
            Tween(qSW, { BackgroundColor3 = NotifQueueEnabled and Theme.Toggle_ON or Theme.Toggle_OFF }, 0.2)
            Tween(qKN, { Position = NotifQueueEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.2)
            EclipseLib:Notify({
                Title = NotifQueueEnabled and "📋 เปิดระบบคิวแล้ว" or "⚡ ปิดระบบคิวแล้ว",
                Content = NotifQueueEnabled and "Notification จะแสดงทีละอัน" or "Notification แสดงพร้อมกันได้",
                Duration = 2,
            })
        end)

        -- Reset Settings
        SecTitle("🔄 Reset การตั้งค่า")
        local resetCard = createCard(sFrame, 126)
        local resetLy = Instance.new("UIGridLayout")
        resetLy.CellSize = UDim2.new(0.46, 0, 0, 28)
        resetLy.CellPadding = UDim2.new(0.04, 0, 0, 6)
        resetLy.SortOrder = Enum.SortOrder.LayoutOrder
        resetLy.Parent = resetCard
        local resetPd = Instance.new("UIPadding")
        resetPd.PaddingTop = UDim.new(0, 8)
        resetPd.PaddingLeft = UDim.new(0, 8)
        resetPd.PaddingRight = UDim.new(0, 8)
        resetPd.Parent = resetCard

        local resetItems = {
            { label = "🎨 Reset สี Theme", fn = function()
                for k, v in pairs(DefaultTheme) do Theme[k] = v end
                Main.BackgroundColor3 = DefaultTheme.Background
                TopBar.BackgroundColor3 = DefaultTheme.Secondary
                tbFix.BackgroundColor3 = DefaultTheme.Secondary
                TabBar.BackgroundColor3 = DefaultTheme.Secondary
                for _, btn in pairs(tabButtons) do
                    if btn.Text == activeTab then btn.BackgroundColor3 = DefaultTheme.TabActive
                    else btn.BackgroundColor3 = DefaultTheme.TabInactive end
                end
                floatBtn.BackgroundColor3 = DefaultTheme.Accent
                applyBtn.BackgroundColor3 = DefaultTheme.Accent
                EclipseLib:Notify({ Title = "🔄 Reset แล้ว", Content = "สี Theme กลับค่าเริ่มต้น", Duration = 2 })
            end },
            { label = "📏 Reset ขนาด UI", fn = function()
                Tween(Main, { Size = UDim2.new(0, 500, 0, 350) }, 0.3)
                Main.Position = UDim2.new(0.5, -250, 0.5, -175)
                EclipseLib:Notify({ Title = "🔄 Reset แล้ว", Content = "ขนาด UI กลับค่าเริ่มต้น", Duration = 2 })
            end },
            { label = "🌗 Reset โปร่งใส", fn = function()
                tFi.Size = UDim2.new(0, 0, 1, 0)
                tVL.Text = "0%"
                Main.BackgroundTransparency = 0
                EclipseLib:Notify({ Title = "🔄 Reset แล้ว", Content = "ความโปร่งใสกลับค่าเริ่มต้น", Duration = 2 })
            end },
            { label = "🔔 Reset Notif", fn = function()
                EnsureNotifHolder()
                NotifHolder.Position = UDim2.new(1, -220, 0, 60)
                EclipseLib:Notify({ Title = "🔄 Reset แล้ว", Content = "ตำแหน่ง Notification กลับค่าเริ่มต้น", Duration = 2 })
            end },
        }
        for _, item in ipairs(resetItems) do
            local rb = Instance.new("TextButton")
            rb.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
            rb.Size = UDim2.new(1, 0, 1, 0)
            rb.Text = item.label
            rb.TextColor3 = Theme.Text
            rb.Font = Enum.Font.GothamBold
            rb.TextSize = 10
            rb.TextWrapped = true
            rb.Parent = resetCard
            CC(rb, 7)
            CS(rb, Theme.Border, 1)
            rb.MouseButton1Click:Connect(function()
                Tween(rb, { BackgroundColor3 = Color3.fromRGB(80, 40, 120) }, 0.1)
                task.wait(0.15)
                Tween(rb, { BackgroundColor3 = Color3.fromRGB(50, 30, 80) }, 0.2)
                item.fn()
            end)
        end

        -- Config Save/Load
        SecTitle("💾 บันทึก / โหลด Config")
        local saveCard = createCard(sFrame, 182)
        local snL = Instance.new("TextLabel")
        snL.BackgroundTransparency = 1
        snL.Position = UDim2.new(0, 10, 0, 8)
        snL.Size = UDim2.new(1, -20, 0, 14)
        snL.Text = "📝 ชื่อไฟล์ใหม่"
        snL.TextColor3 = Theme.SubText
        snL.Font = Enum.Font.Gotham
        snL.TextSize = 11
        snL.TextXAlignment = Enum.TextXAlignment.Left
        snL.Parent = saveCard

        local nIBG = Instance.new("Frame")
        nIBG.BackgroundColor3 = Theme.Input_BG
        nIBG.Size = UDim2.new(1, -20, 0, 28)
        nIBG.Position = UDim2.new(0, 10, 0, 24)
        nIBG.Parent = saveCard
        CC(nIBG, 6)
        CS(nIBG, Theme.Border)

        local nBox = Instance.new("TextBox")
        nBox.BackgroundTransparency = 1
        nBox.Size = UDim2.new(1, -10, 1, 0)
        nBox.Position = UDim2.new(0, 6, 0, 0)
        nBox.PlaceholderText = "พิมพ์ชื่อไฟล์..."
        nBox.PlaceholderColor3 = Theme.SubText
        nBox.TextColor3 = Theme.Text
        nBox.Font = Enum.Font.Gotham
        nBox.TextSize = 12
        nBox.TextXAlignment = Enum.TextXAlignment.Left
        nBox.ClearTextOnFocus = false
        nBox.Text = ""
        nBox.Parent = nIBG

        local saveNewBtn = Instance.new("TextButton")
        saveNewBtn.BackgroundColor3 = Theme.Accent
        saveNewBtn.Size = UDim2.new(1, -20, 0, 28)
        saveNewBtn.Position = UDim2.new(0, 10, 0, 58)
        saveNewBtn.Text = "💾 Save ใหม่"
        saveNewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        saveNewBtn.Font = Enum.Font.GothamBold
        saveNewBtn.TextSize = 12
        saveNewBtn.Parent = saveCard
        CC(saveNewBtn, 7)

        local sep = Instance.new("Frame")
        sep.BackgroundColor3 = Theme.Border
        sep.Size = UDim2.new(1, -20, 0, 1)
        sep.Position = UDim2.new(0, 10, 0, 94)
        sep.BorderSizePixel = 0
        sep.Parent = saveCard

        local exL = Instance.new("TextLabel")
        exL.BackgroundTransparency = 1
        exL.Position = UDim2.new(0, 10, 0, 100)
        exL.Size = UDim2.new(1, -20, 0, 14)
        exL.Text = "📂 ไฟล์ที่บันทึกไว้"
        exL.TextColor3 = Theme.SubText
        exL.Font = Enum.Font.Gotham
        exL.TextSize = 11
        exL.TextXAlignment = Enum.TextXAlignment.Left
        exL.Parent = saveCard

        local fileSelected = ""
        local fdBG = Instance.new("Frame")
        fdBG.BackgroundColor3 = Theme.Dropdown_BG
        fdBG.Size = UDim2.new(0.48, 0, 0, 28)
        fdBG.Position = UDim2.new(0, 10, 0, 118)
        fdBG.ClipsDescendants = false
        fdBG.Parent = saveCard
        CC(fdBG, 6)
        CS(fdBG, Theme.Border)

        local fdLbl = Instance.new("TextLabel")
        fdLbl.BackgroundTransparency = 1
        fdLbl.Size = UDim2.new(1, -26, 1, 0)
        fdLbl.Position = UDim2.new(0, 6, 0, 0)
        fdLbl.Text = "(ยังไม่มีไฟล์)"
        fdLbl.TextColor3 = Theme.Text
        fdLbl.Font = Enum.Font.Gotham
        fdLbl.TextSize = 11
        fdLbl.TextXAlignment = Enum.TextXAlignment.Left
        fdLbl.Parent = fdBG

        local fdArrow = Instance.new("TextButton")
        fdArrow.BackgroundTransparency = 1
        fdArrow.Size = UDim2.new(0, 24, 1, 0)
        fdArrow.Position = UDim2.new(1, -26, 0, 0)
        fdArrow.Text = "▼"
        fdArrow.TextColor3 = Theme.Accent
        fdArrow.Font = Enum.Font.GothamBold
        fdArrow.TextSize = 12
        fdArrow.Parent = fdBG

        local fdList = Instance.new("Frame")
        fdList.BackgroundColor3 = Theme.Dropdown_BG
        fdList.Size = UDim2.new(1, 0, 0, 0)
        fdList.Position = UDim2.new(0, 0, 1, 2)
        fdList.Visible = false
        fdList.ZIndex = 20
        fdList.Parent = fdBG
        CC(fdList, 6)
        CS(fdList, Theme.Border)

        local fdLy = Instance.new("UIListLayout")
        fdLy.Padding = UDim.new(0, 2)
        fdLy.SortOrder = Enum.SortOrder.LayoutOrder
        fdLy.Parent = fdList

        local fdPd = Instance.new("UIPadding")
        fdPd.PaddingTop = UDim.new(0, 4)
        fdPd.PaddingLeft = UDim.new(0, 4)
        fdPd.PaddingRight = UDim.new(0, 4)
        fdPd.Parent = fdList

        local fdExp = false
        local function RefreshFileList()
            for _, c in ipairs(fdList:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            local files = ConfigSystem:GetSaveList()
            for _, fname in ipairs(files) do
                local fb = Instance.new("TextButton")
                fb.BackgroundColor3 = Theme.Secondary
                fb.Size = UDim2.new(1, 0, 0, 24)
                fb.Text = " " .. fname
                fb.TextColor3 = Theme.Text
                fb.Font = Enum.Font.Gotham
                fb.TextSize = 11
                fb.TextXAlignment = Enum.TextXAlignment.Left
                fb.ZIndex = 21
                fb.Parent = fdList
                CC(fb, 5)
                fb.MouseButton1Click:Connect(function()
                    fileSelected = fname
                    fdLbl.Text = fname
                    fdExp = false
                    fdList.Visible = false
                    fdArrow.Text = "▼"
                end)
            end
            fdList.Size = UDim2.new(1, 0, 0, #files * 28 + 8)
        end
        RefreshFileList()
        fdArrow.MouseButton1Click:Connect(function()
            fdExp = not fdExp
            if fdExp then RefreshFileList() end
            fdList.Visible = fdExp
            fdArrow.Text = fdExp and "▲" or "▼"
        end)

        local loadBtn = Instance.new("TextButton")
        loadBtn.BackgroundColor3 = Color3.fromRGB(40, 110, 190)
        loadBtn.Size = UDim2.new(0.23, 0, 0, 28)
        loadBtn.Position = UDim2.new(0.52, 0, 0, 118)
        loadBtn.Text = "📂 Load"
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadBtn.Font = Enum.Font.GothamBold
        loadBtn.TextSize = 11
        loadBtn.Parent = saveCard
        CC(loadBtn, 7)

        local overBtn = Instance.new("TextButton")
        overBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 10)
        overBtn.Size = UDim2.new(0.23, 0, 0, 28)
        overBtn.Position = UDim2.new(0.77, 0, 0, 118)
        overBtn.Text = "✏️ ทับ"
        overBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        overBtn.Font = Enum.Font.GothamBold
        overBtn.TextSize = 11
        overBtn.Parent = saveCard
        CC(overBtn, 7)

        local cfgSt = Instance.new("TextLabel")
        cfgSt.BackgroundTransparency = 1
        cfgSt.Position = UDim2.new(0, 10, 0, 154)
        cfgSt.Size = UDim2.new(1, -20, 0, 18)
        cfgSt.Text = ""
        cfgSt.TextColor3 = Color3.fromRGB(60, 200, 100)
        cfgSt.Font = Enum.Font.Gotham
        cfgSt.TextSize = 11
        cfgSt.TextXAlignment = Enum.TextXAlignment.Left
        cfgSt.Parent = saveCard

        local function ShowSt(msg, ok)
            cfgSt.Text = msg
            cfgSt.TextColor3 = ok and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(200, 80, 60)
            task.delay(3, function() cfgSt.Text = "" end)
        end

        saveNewBtn.MouseButton1Click:Connect(function()
            local name = nBox.Text
            if name == "" then ShowSt("❌ พิมพ์ชื่อไฟล์ก่อนนะ!", false); return end
            local ok = ConfigSystem:Save(name)
            if ok then ShowSt("✅ Save '" .. name .. "' สำเร็จ!", true); nBox.Text = ""; RefreshFileList()
            else ShowSt("❌ Save ไม่สำเร็จ", false) end
        end)
        loadBtn.MouseButton1Click:Connect(function()
            if fileSelected == "" or fileSelected == "(ยังไม่มีไฟล์)" then ShowSt("❌ เลือกไฟล์ก่อน", false); return end
            local ok = ConfigSystem:Load(fileSelected)
            if ok then ShowSt("✅ Load '" .. fileSelected .. "' สำเร็จ!", true)
            else ShowSt("❌ ไม่พบไฟล์", false) end
        end)
        overBtn.MouseButton1Click:Connect(function()
            if fileSelected == "" or fileSelected == "(ยังไม่มีไฟล์)" then ShowSt("❌ เลือกไฟล์ที่จะ Save ทับก่อน", false); return end
            local ok = ConfigSystem:Save(fileSelected)
            if ok then ShowSt("✅ Save ทับ '" .. fileSelected .. "' สำเร็จ!", true)
            else ShowSt("❌ Save ทับไม่สำเร็จ", false) end
        end)
    end

    -- ================= TAB API =================
    local WindowObj = {}
    function WindowObj:CreateTab(nameOrOpts, _icon)
        local tabName, tabIcon
        if type(nameOrOpts) == "string" then
            tabName = nameOrOpts
            tabIcon = _icon or ""
        else
            tabName = nameOrOpts.Name or "Tab"
            tabIcon = nameOrOpts.Icon or ""
        end
        local label = (tabIcon ~= "") and (tabIcon .. " " .. tabName) or tabName
        local tabBtn = MakeTabBtn(label, false)
        local tabFrame = MakeSF("Frame_" .. tabName)
        tabButtons[tabName] = tabBtn
        tabFrames[tabName] = tabFrame
        tabBtn.MouseButton1Click:Connect(function() SetActiveTab(tabName) end)

        local TabAPI = {}

        -- BaseCard for Tab API
        local function BaseCard(h)
            local c = Instance.new("Frame")
            c.BackgroundColor3 = Theme.Secondary
            c.Size = UDim2.new(1, 0, 0, h)
            c.Parent = tabFrame
            CC(c, 8)
            CS(c, Theme.Border)
            local leftBar = Instance.new("Frame")
            leftBar.BackgroundColor3 = Theme.Accent
            leftBar.Size = UDim2.new(0, 3, 1, -16)
            leftBar.Position = UDim2.new(0, 0, 0, 8)
            leftBar.BorderSizePixel = 0
            leftBar.Parent = c
            CC(leftBar, 2)
            return c
        end

        function TabAPI:AddLabel(o)
            o = o or {}
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(1, 0, 0, 24)
            l.Text = o.Text or ""
            l.TextColor3 = Theme.SubText
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped = true
            l.Parent = tabFrame
            local A = {}
            function A:SetText(t) l.Text = t end
            return A
        end

        function TabAPI:AddSection(o)
            o = o or {}
            local sf = Instance.new("Frame")
            sf.BackgroundTransparency = 1
            sf.Size = UDim2.new(1, 0, 0, 28)
            sf.Parent = tabFrame
            local line = Instance.new("Frame")
            line.BackgroundColor3 = Theme.Border
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 0.5, 0)
            line.BorderSizePixel = 0
            line.Parent = sf
            local bg2 = Instance.new("Frame")
            bg2.BackgroundColor3 = Theme.Background
            bg2.AutomaticSize = Enum.AutomaticSize.X
            bg2.Size = UDim2.new(0, 0, 1, 0)
            bg2.Parent = sf
            local sl2 = Instance.new("TextLabel")
            sl2.BackgroundTransparency = 1
            sl2.AutomaticSize = Enum.AutomaticSize.X
            sl2.Size = UDim2.new(0, 0, 1, 0)
            sl2.Text = " " .. (o.Name or "Section") .. " "
            sl2.TextColor3 = Theme.Accent
            sl2.Font = Enum.Font.GothamBold
            sl2.TextSize = 11
            sl2.Parent = bg2
        end

        function TabAPI:AddProgressBar(o)
            o = o or {}
            local maxVal = o.Max or 100
            local valFn = o.Value or function() return 0 end
            local card = BaseCard(54)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(0.7, 0, 0, 16)
            nL.Text = o.Name or "Progress"
            nL.TextColor3 = Theme.Text
            nL.Font = Enum.Font.GothamBold
            nL.TextSize = 13
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local vL = Instance.new("TextLabel")
            vL.BackgroundTransparency = 1
            vL.Position = UDim2.new(0.7, 0, 0, 6)
            vL.Size = UDim2.new(0.28, 0, 0, 16)
            vL.Text = "0/" .. tostring(maxVal)
            vL.TextColor3 = Theme.Accent
            vL.Font = Enum.Font.GothamBold
            vL.TextSize = 11
            vL.TextXAlignment = Enum.TextXAlignment.Right
            vL.Parent = card
            local barBG = Instance.new("Frame")
            barBG.BackgroundColor3 = Theme.Slider_BG
            barBG.Size = UDim2.new(1, -20, 0, 10)
            barBG.Position = UDim2.new(0, 10, 0, 30)
            barBG.Parent = card
            CC(barBG, 5)
            local barFill = Instance.new("Frame")
            barFill.BackgroundColor3 = Theme.Accent
            barFill.Size = UDim2.new(0, 0, 1, 0)
            barFill.Parent = barBG
            CC(barFill, 5)

            addUpdater(card, function()
                local cur = valFn()
                cur = math.clamp(cur, 0, maxVal)
                local pct = cur / maxVal
                barFill.Size = UDim2.new(pct, 0, 1, 0)
                vL.Text = math.floor(cur) .. "/" .. maxVal
                barFill.BackgroundColor3 = pct > 0.6 and Color3.fromRGB(60,180,100) or pct > 0.3 and Color3.fromRGB(200,160,40) or Color3.fromRGB(200,60,60)
            end)
            card.Destroying:Connect(function() removeUpdatersForElement(card) end)
        end

        function TabAPI:AddButton(o)
            o = o or {}
            local card = BaseCard(50)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(0.6, 0, 0, 18)
            nL.Text = o.Name or "Button"
            nL.TextColor3 = Theme.Text
            nL.Font = Enum.Font.GothamBold
            nL.TextSize = 13
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local dL = Instance.new("TextLabel")
            dL.BackgroundTransparency = 1
            dL.Position = UDim2.new(0, 10, 0, 26)
            dL.Size = UDim2.new(0.6, 0, 0, 16)
            dL.Text = o.Description or ""
            dL.TextColor3 = Theme.SubText
            dL.Font = Enum.Font.Gotham
            dL.TextSize = 10
            dL.TextXAlignment = Enum.TextXAlignment.Left
            dL.Parent = card
            if o.RealtimeValue then
                local rL = Instance.new("TextLabel")
                rL.BackgroundTransparency = 1
                rL.Position = UDim2.new(0.58, 0, 0, 6)
                rL.Size = UDim2.new(0.24, 0, 0, 18)
                rL.Text = tostring(o.RealtimeValue())
                rL.TextColor3 = Theme.Accent
                rL.Font = Enum.Font.GothamBold
                rL.TextSize = 11
                rL.TextXAlignment = Enum.TextXAlignment.Right
                rL.Parent = card
                addUpdater(rL, function(lbl)
                    local v = tostring(o.RealtimeValue())
                    lbl.Text = v
                end)
                rL.Destroying:Connect(function() removeUpdatersForElement(rL) end)
            end
            local btn = Instance.new("TextButton")
            btn.BackgroundColor3 = Theme.Accent
            btn.Size = UDim2.new(0, 52, 0, 26)
            btn.Position = UDim2.new(1, -62, 0.5, -13)
            btn.Text = "▶ RUN"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.Parent = card
            CC(btn, 6)
            btn.MouseButton1Click:Connect(function()
                Tween(btn, { BackgroundColor3 = Theme.AccentHover }, 0.1)
                task.wait(0.1)
                Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.1)
                if o.Callback then o.Callback() end
            end)
        end

        function TabAPI:AddToggle(o)
            o = o or {}
            local state = o.Default or false
            local card = BaseCard(50)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(0.7, 0, 0, 18)
            nL.Text = o.Name or "Toggle"
            nL.TextColor3 = Theme.Text
            nL.Font = Enum.Font.GothamBold
            nL.TextSize = 13
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local dL = Instance.new("TextLabel")
            dL.BackgroundTransparency = 1
            dL.Position = UDim2.new(0, 10, 0, 26)
            dL.Size = UDim2.new(0.7, 0, 0, 16)
            dL.Text = o.Description or ""
            dL.TextColor3 = Theme.SubText
            dL.Font = Enum.Font.Gotham
            dL.TextSize = 10
            dL.TextXAlignment = Enum.TextXAlignment.Left
            dL.Parent = card
            local sw = Instance.new("Frame")
            sw.BackgroundColor3 = state and Theme.Toggle_ON or Theme.Toggle_OFF
            sw.Size = UDim2.new(0, 44, 0, 24)
            sw.Position = UDim2.new(1, -54, 0.5, -12)
            sw.Parent = card
            CC(sw, 12)
            local kn = Instance.new("Frame")
            kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            kn.Size = UDim2.new(0, 18, 0, 18)
            kn.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            kn.Parent = sw
            CC(kn, 9)
            local ca = Instance.new("TextButton")
            ca.BackgroundTransparency = 1
            ca.Size = UDim2.new(1, 0, 1, 0)
            ca.Text = ""
            ca.Parent = card
            local function Apply(s)
                state = s
                Tween(sw, { BackgroundColor3 = s and Theme.Toggle_ON or Theme.Toggle_OFF }, 0.2)
                Tween(kn, { Position = s and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.2)
                if o.Callback then o.Callback(s) end
            end
            ca.MouseButton1Click:Connect(function() Apply(not state) end)
            if o.ConfigKey then ConfigSystem:Register(o.ConfigKey, function() return state end, function(v) Apply(v) end) end
            local A = {}
            function A:SetState(s) Apply(s) end
            function A:GetState() return state end
            return A
        end

        function TabAPI:AddSlider(o)
            o = o or {}
            local mn = o.Min or 0
            local mx = o.Max or 100
            local val = math.clamp(o.Default or mn, mn, mx)
            local card = BaseCard(60)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(0.7, 0, 0, 18)
            nL.Text = o.Name or "Slider"
            nL.TextColor3 = Theme.Text
            nL.Font = Enum.Font.GothamBold
            nL.TextSize = 13
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local vL = Instance.new("TextLabel")
            vL.BackgroundTransparency = 1
            vL.Position = UDim2.new(0.7, 0, 0, 6)
            vL.Size = UDim2.new(0.28, 0, 0, 18)
            vL.Text = tostring(val)
            vL.TextColor3 = Theme.Accent
            vL.Font = Enum.Font.GothamBold
            vL.TextSize = 13
            vL.TextXAlignment = Enum.TextXAlignment.Right
            vL.Parent = card
            local tr = Instance.new("Frame")
            tr.BackgroundColor3 = Theme.Slider_BG
            tr.Size = UDim2.new(1, -20, 0, 8)
            tr.Position = UDim2.new(0, 10, 0, 36)
            tr.Parent = card
            CC(tr, 4)
            local fi = Instance.new("Frame")
            fi.BackgroundColor3 = Theme.Slider_Fill
            fi.Size = UDim2.new((val - mn) / (mx - mn), 0, 1, 0)
            fi.Parent = tr
            CC(fi, 4)
            local drag = false
            local function upd(pos)
                local r = math.clamp((pos.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
                val = math.floor(mn + (mx - mn) * r)
                vL.Text = tostring(val)
                fi.Size = UDim2.new(r, 0, 1, 0)
                if o.Callback then o.Callback(val) end
            end
            tr.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = true
                    upd(i.Position)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    upd(i.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = false
                end
            end)
            if o.ConfigKey then ConfigSystem:Register(o.ConfigKey, function() return val end, function(v)
                val = math.clamp(v, mn, mx)
                local r = (val - mn) / (mx - mn)
                fi.Size = UDim2.new(r, 0, 1, 0)
                vL.Text = tostring(val)
                if o.Callback then o.Callback(val) end
            end) end
            local A = {}
            function A:GetValue() return val end
            function A:SetValue(v)
                val = math.clamp(v, mn, mx)
                local r = (val - mn) / (mx - mn)
                fi.Size = UDim2.new(r, 0, 1, 0)
                vL.Text = tostring(val)
                if o.Callback then o.Callback(val) end
            end
            return A
        end

        function TabAPI:AddDropdown(o)
            o = o or {}
            local items = o.Options or {}
            local sel = o.Default or (items[1] or "")
            local exp = false
            local wr = Instance.new("Frame")
            wr.BackgroundTransparency = 1
            wr.Size = UDim2.new(1, 0, 0, 46)
            wr.ClipsDescendants = false
            wr.Parent = tabFrame
            local card = Instance.new("Frame")
            card.BackgroundColor3 = Theme.Secondary
            card.Size = UDim2.new(1, 0, 0, 46)
            card.ClipsDescendants = false
            card.Parent = wr
            CC(card, 8)
            CS(card, Theme.Border)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(0.55, 0, 0, 14)
            nL.Text = o.Name or "Dropdown"
            nL.TextColor3 = Theme.SubText
            nL.Font = Enum.Font.Gotham
            nL.TextSize = 11
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local sL = Instance.new("TextLabel")
            sL.BackgroundTransparency = 1
            sL.Position = UDim2.new(0, 10, 0, 22)
            sL.Size = UDim2.new(0.65, 0, 0, 18)
            sL.Text = sel
            sL.TextColor3 = Theme.Text
            sL.Font = Enum.Font.GothamBold
            sL.TextSize = 13
            sL.TextXAlignment = Enum.TextXAlignment.Left
            sL.Parent = card
            if o.RealtimeValue then
                local rL = Instance.new("TextLabel")
                rL.BackgroundTransparency = 1
                rL.Position = UDim2.new(0.6, 0, 0, 22)
                rL.Size = UDim2.new(0.2, 0, 0, 18)
                rL.Text = tostring(o.RealtimeValue())
                rL.TextColor3 = Theme.Accent
                rL.Font = Enum.Font.GothamBold
                rL.TextSize = 11
                rL.TextXAlignment = Enum.TextXAlignment.Right
                rL.Parent = card
                addUpdater(rL, function(lbl)
                    local v = tostring(o.RealtimeValue())
                    lbl.Text = v
                end)
                rL.Destroying:Connect(function() removeUpdatersForElement(rL) end)
            end
            local ab = Instance.new("TextButton")
            ab.BackgroundColor3 = Theme.Accent
            ab.Size = UDim2.new(0, 30, 0, 30)
            ab.Position = UDim2.new(1, -40, 0.5, -15)
            ab.Text = "▼"
            ab.TextColor3 = Color3.fromRGB(255, 255, 255)
            ab.Font = Enum.Font.GothamBold
            ab.TextSize = 12
            ab.Parent = card
            CC(ab, 6)
            local maxH = 150
            local dl = Instance.new("ScrollingFrame")
            dl.BackgroundColor3 = Theme.Dropdown_BG
            dl.Position = UDim2.new(0, 0, 1, 4)
            dl.Visible = false
            dl.ZIndex = 10
            dl.Parent = card
            dl.ScrollBarThickness = 3
            dl.ScrollBarImageColor3 = Theme.Accent
            dl.ScrollingDirection = Enum.ScrollingDirection.Y
            dl.CanvasSize = UDim2.new(0, 0, 0, 0)
            dl.ClipsDescendants = true
            CC(dl, 8)
            CS(dl, Theme.Border)
            local dly = Instance.new("UIListLayout")
            dly.Padding = UDim.new(0, 2)
            dly.SortOrder = Enum.SortOrder.LayoutOrder
            dly.Parent = dl
            local dp = Instance.new("UIPadding")
            dp.PaddingTop = UDim.new(0, 4)
            dp.PaddingLeft = UDim.new(0, 4)
            dp.PaddingRight = UDim.new(0, 4)
            dp.Parent = dl
            local function Pop()
                for _, c in ipairs(dl:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, item in ipairs(items) do
                    local ib = Instance.new("TextButton")
                    ib.BackgroundColor3 = Theme.Secondary
                    ib.Size = UDim2.new(1, 0, 0, 26)
                    ib.Text = " " .. item
                    ib.TextColor3 = Theme.Text
                    ib.Font = Enum.Font.Gotham
                    ib.TextSize = 12
                    ib.TextXAlignment = Enum.TextXAlignment.Left
                    ib.ZIndex = 11
                    ib.Parent = dl
                    CC(ib, 6)
                    ib.MouseButton1Click:Connect(function()
                        sel = item
                        sL.Text = item
                        exp = false
                        dl.Visible = false
                        ab.Text = "▼"
                        if o.Callback then o.Callback(item) end
                    end)
                end
                local totalH = math.min(#items * 30 + 8, maxH)
                dl.Size = UDim2.new(1, 0, 0, totalH)
                dl.CanvasSize = UDim2.new(0, 0, 0, #items * 30 + 8)
            end
            Pop()
            ab.MouseButton1Click:Connect(function()
                exp = not exp
                dl.Visible = exp
                ab.Text = exp and "▲" or "▼"
            end)
            if o.ConfigKey then ConfigSystem:Register(o.ConfigKey, function() return sel end, function(v)
                sel = v
                sL.Text = v
                if o.Callback then o.Callback(v) end
            end) end
            local A = {}
            function A:GetValue() return sel end
            function A:SetOptions(n)
                items = n
                Pop()
            end
            return A
        end

        function TabAPI:AddInput(o)
            o = o or {}
            local card = BaseCard(60)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(1, -20, 0, 16)
            nL.Text = o.Name or "Input"
            nL.TextColor3 = Theme.SubText
            nL.Font = Enum.Font.Gotham
            nL.TextSize = 11
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local iBG = Instance.new("Frame")
            iBG.BackgroundColor3 = Theme.Input_BG
            iBG.Size = UDim2.new(1, -20, 0, 28)
            iBG.Position = UDim2.new(0, 10, 0, 26)
            iBG.Parent = card
            CC(iBG, 6)
            CS(iBG, Theme.Border)
            local box = Instance.new("TextBox")
            box.BackgroundTransparency = 1
            box.Size = UDim2.new(1, -10, 1, 0)
            box.Position = UDim2.new(0, 6, 0, 0)
            box.PlaceholderText = o.Placeholder or "พิมพ์ที่นี่..."
            box.PlaceholderColor3 = Theme.SubText
            box.TextColor3 = Theme.Text
            box.Font = Enum.Font.Gotham
            box.TextSize = 12
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false
            box.Text = ""
            box.Parent = iBG
            box.FocusLost:Connect(function(enter)
                if enter and o.Callback then o.Callback(box.Text) end
            end)
            local A = {}
            function A:GetValue() return box.Text end
            function A:SetValue(v) box.Text = v end
            return A
        end

        function TabAPI:AddParagraph(o)
            o = o or {}
            local titleText = o.Title or ""
            local contentText = o.Content or ""
            local lines = math.max(1, math.ceil(#contentText / 42))
            local h = 46 + (lines * 16)
            local card = BaseCard(h)
            local tL = Instance.new("TextLabel")
            tL.BackgroundTransparency = 1
            tL.Position = UDim2.new(0, 10, 0, 8)
            tL.Size = UDim2.new(1, -20, 0, 18)
            tL.Text = titleText
            tL.TextColor3 = Theme.Text
            tL.Font = Enum.Font.GothamBold
            tL.TextSize = 13
            tL.TextXAlignment = Enum.TextXAlignment.Left
            tL.Parent = card
            local sep = Instance.new("Frame")
            sep.BackgroundColor3 = Theme.Border
            sep.Size = UDim2.new(1, -20, 0, 1)
            sep.Position = UDim2.new(0, 10, 0, 28)
            sep.BorderSizePixel = 0
            sep.Parent = card
            local cL = Instance.new("TextLabel")
            cL.BackgroundTransparency = 1
            cL.Position = UDim2.new(0, 10, 0, 32)
            cL.Size = UDim2.new(1, -20, 0, h - 38)
            cL.Text = contentText
            cL.TextColor3 = Theme.SubText
            cL.Font = Enum.Font.Gotham
            cL.TextSize = 12
            cL.TextXAlignment = Enum.TextXAlignment.Left
            cL.TextWrapped = true
            cL.Parent = card
            local A = {}
            function A:SetTitle(t) tL.Text = t end
            function A:SetContent(t) cL.Text = t end
            return A
        end

        function TabAPI:AddColorPicker(o)
            o = o or {}
            local defColor = o.Default or Color3.fromRGB(100, 60, 200)
            local rV = math.floor(defColor.R * 255)
            local gV = math.floor(defColor.G * 255)
            local bV = math.floor(defColor.B * 255)
            local card = BaseCard(162)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(0.6, 0, 0, 18)
            nL.Text = o.Name or "ColorPicker"
            nL.TextColor3 = Theme.Text
            nL.Font = Enum.Font.GothamBold
            nL.TextSize = 13
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local prev = Instance.new("Frame")
            prev.BackgroundColor3 = defColor
            prev.Size = UDim2.new(0, 36, 0, 20)
            prev.Position = UDim2.new(1, -46, 0, 6)
            prev.Parent = card
            CC(prev, 5)
            CS(prev, Theme.Border, 1)
            local function UpdateColor()
                local c = Color3.fromRGB(rV, gV, bV)
                prev.BackgroundColor3 = c
                if o.Callback then o.Callback(c) end
            end
            local function MakeCPSlider(label, yP, initV, col, onChange)
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.new(0, 10, 0, yP)
                lbl.Size = UDim2.new(0, 14, 0, 14)
                lbl.Text = label
                lbl.TextColor3 = col
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 11
                lbl.Parent = card
                local vLb = Instance.new("TextLabel")
                vLb.BackgroundTransparency = 1
                vLb.Position = UDim2.new(1, -38, 0, yP)
                vLb.Size = UDim2.new(0, 32, 0, 14)
                vLb.Text = tostring(initV)
                vLb.TextColor3 = Theme.SubText
                vLb.Font = Enum.Font.GothamBold
                vLb.TextSize = 10
                vLb.TextXAlignment = Enum.TextXAlignment.Right
                vLb.Parent = card
                local tr = Instance.new("Frame")
                tr.BackgroundColor3 = Theme.Slider_BG
                tr.Size = UDim2.new(1, -58, 0, 7)
                tr.Position = UDim2.new(0, 26, 0, yP + 4)
                tr.Parent = card
                CC(tr, 3)
                local fi = Instance.new("Frame")
                fi.BackgroundColor3 = col
                fi.Size = UDim2.new(initV / 255, 0, 1, 0)
                fi.Parent = tr
                CC(fi, 3)
                local drag = false
                local function upd(pos)
                    local r = math.clamp((pos.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
                    local v = math.floor(r * 255)
                    fi.Size = UDim2.new(r, 0, 1, 0)
                    vLb.Text = tostring(v)
                    onChange(v)
                    UpdateColor()
                end
                tr.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        drag = true
                        upd(i.Position)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        upd(i.Position)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        drag = false
                    end
                end)
            end
            MakeCPSlider("R", 34, rV, Color3.fromRGB(220, 60, 60), function(v) rV = v end)
            MakeCPSlider("G", 60, gV, Color3.fromRGB(60, 200, 80), function(v) gV = v end)
            MakeCPSlider("B", 86, bV, Color3.fromRGB(60, 120, 220), function(v) bV = v end)
            local hexLbl = Instance.new("TextLabel")
            hexLbl.BackgroundTransparency = 1
            hexLbl.Position = UDim2.new(0, 10, 0, 110)
            hexLbl.Size = UDim2.new(1, -20, 0, 16)
            hexLbl.Text = "Color3.fromRGB(" .. rV .. "," .. gV .. "," .. bV .. ")"
            hexLbl.TextColor3 = Theme.SubText
            hexLbl.Font = Enum.Font.Code
            hexLbl.TextSize = 10
            hexLbl.TextXAlignment = Enum.TextXAlignment.Left
            hexLbl.Parent = card
            local copyBtn = Instance.new("TextButton")
            copyBtn.BackgroundColor3 = Theme.Secondary
            copyBtn.Size = UDim2.new(1, -20, 0, 26)
            copyBtn.Position = UDim2.new(0, 10, 0, 130)
            copyBtn.Text = "📋 Copy Color3"
            copyBtn.TextColor3 = Theme.Text
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 11
            copyBtn.Parent = card
            CC(copyBtn, 7)
            CS(copyBtn, Theme.Border, 1)
            addUpdater(hexLbl, function(lbl)
                lbl.Text = "Color3.fromRGB(" .. rV .. "," .. gV .. "," .. bV .. ")"
            end)
            hexLbl.Destroying:Connect(function() removeUpdatersForElement(hexLbl) end)
            copyBtn.MouseButton1Click:Connect(function()
                SetClipboard("Color3.fromRGB(" .. rV .. "," .. gV .. "," .. bV .. ")")
                local old = copyBtn.Text
                copyBtn.Text = "✅ คัดลอกแล้ว!"
                Tween(copyBtn, { BackgroundColor3 = Color3.fromRGB(30, 80, 40) }, 0.15)
                task.wait(1.5)
                copyBtn.Text = old
                Tween(copyBtn, { BackgroundColor3 = Theme.Secondary }, 0.15)
            end)
            local A = {}
            function A:GetColor() return Color3.fromRGB(rV, gV, bV) end
            return A
        end

        function TabAPI:AddKeybind(o)
            o = o or {}
            local currentKey = o.Default or Enum.KeyCode.F
            local isListening = false
            local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
            local card = BaseCard(50)
            local nL = Instance.new("TextLabel")
            nL.BackgroundTransparency = 1
            nL.Position = UDim2.new(0, 10, 0, 6)
            nL.Size = UDim2.new(0.55, 0, 0, 18)
            nL.Text = o.Name or "Keybind"
            nL.TextColor3 = Theme.Text
            nL.Font = Enum.Font.GothamBold
            nL.TextSize = 13
            nL.TextXAlignment = Enum.TextXAlignment.Left
            nL.Parent = card
            local dL = Instance.new("TextLabel")
            dL.BackgroundTransparency = 1
            dL.Position = UDim2.new(0, 10, 0, 26)
            dL.Size = UDim2.new(0.55, 0, 0, 16)
            dL.Text = o.Description or ""
            dL.TextColor3 = Theme.SubText
            dL.Font = Enum.Font.Gotham
            dL.TextSize = 10
            dL.TextXAlignment = Enum.TextXAlignment.Left
            dL.Parent = card
            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0, 80, 0, 28)
            keyBtn.Position = UDim2.new(1, -90, 0.5, -14)
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.TextSize = 11
            keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            keyBtn.Parent = card
            CC(keyBtn, 7)
            if isMobile then
                keyBtn.BackgroundColor3 = Theme.Accent
                keyBtn.Text = "▶ กด"
                keyBtn.MouseButton1Click:Connect(function()
                    Tween(keyBtn, { BackgroundColor3 = Theme.AccentHover }, 0.1)
                    task.wait(0.1)
                    Tween(keyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
                    if o.Callback then o.Callback() end
                end)
            else
                keyBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
                keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
                CS(keyBtn, Theme.Accent, 1.5)
                keyBtn.MouseButton1Click:Connect(function()
                    if isListening then return end
                    isListening = true
                    keyBtn.Text = "[...]"
                    keyBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
                            keyBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
                            isListening = false
                            conn:Disconnect()
                        end
                    end)
                end)
                UserInputService.InputBegan:Connect(function(input, gp)
                    if gp or isListening then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if o.Callback then o.Callback() end
                    end
                end)
            end
            local A = {}
            function A:GetKey() return currentKey end
            function A:SetKey(k)
                currentKey = k
                if not isMobile then keyBtn.Text = "[" .. tostring(k.Name) .. "]" end
            end
            return A
        end

        function TabAPI:AddCard(o)
            o = o or {}
            local titleText = o.Title or "Card"
            local contentText = o.Content or ""
            local h = o.Height or 80
            local card = BaseCard(h)
            local tL = Instance.new("TextLabel")
            tL.BackgroundTransparency = 1
            tL.Position = UDim2.new(0, 10, 0, 8)
            tL.Size = UDim2.new(1, -20, 0, 18)
            tL.Text = titleText
            tL.TextColor3 = Theme.Text
            tL.Font = Enum.Font.GothamBold
            tL.TextSize = 13
            tL.TextXAlignment = Enum.TextXAlignment.Left
            tL.Parent = card
            local sep = Instance.new("Frame")
            sep.BackgroundColor3 = Theme.Border
            sep.Size = UDim2.new(1, -20, 0, 1)
            sep.Position = UDim2.new(0, 10, 0, 28)
            sep.BorderSizePixel = 0
            sep.Parent = card
            local cL = Instance.new("TextLabel")
            cL.BackgroundTransparency = 1
            cL.Position = UDim2.new(0, 10, 0, 32)
            cL.Size = UDim2.new(1, -20, 0, h - 38)
            cL.Text = contentText
            cL.TextColor3 = Theme.SubText
            cL.Font = Enum.Font.Gotham
            cL.TextSize = 12
            cL.TextXAlignment = Enum.TextXAlignment.Left
            cL.TextWrapped = true
            cL.Parent = card
            local A = {}
            function A:SetTitle(t) tL.Text = t end
            function A:SetContent(t) cL.Text = t end
            return A
        end

        return TabAPI
    end

    function WindowObj:Notify(o) EclipseLib:Notify(o) end
    function WindowObj:Show()
        Main.Visible = true
        Main.Size = UDim2.new(0, 500, 0, 0)
        Tween(Main, { Size = UDim2.new(0, 500, 0, 350) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        floatBtn.Visible = false
        isOpen = true
        MinBtn.Text = "—"
    end
    function WindowObj:Hide()
        Tween(Main, { Size = UDim2.new(0, 500, 0, 0) }, 0.25)
        task.delay(0.3, function() Main.Visible = false; floatBtn.Visible = true end)
    end
    function WindowObj:Toggle()
        if Main.Visible then self:Hide() else self:Show() end
    end
    function WindowObj:Destroy()
        pcall(function() ScreenGui:Destroy() end)
        pcall(function() floatSG:Destroy() end)
        pcall(function() if NotifHolder then NotifHolder:Destroy() end end)
        updaters = {}
    end

    local function OpenMainUI()
        Main.Visible = true
        Main.Size = UDim2.new(0, 500, 0, 0)
        Tween(Main, { Size = UDim2.new(0, 500, 0, 350) }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.wait(0.5)
        EclipseLib:Notify({ Title = "🌒 " .. windowName, Content = "โหลดสำเร็จแล้ว! ✨", Duration = 3 })
    end

    if useKey then
        PlayIntro(loadTitle, loadSub, function()
            ShowKeySystem(keyOpts, OpenMainUI)
        end)
    else
        PlayIntro(loadTitle, loadSub, OpenMainUI)
    end

    return WindowObj
end

return EclipseLib
