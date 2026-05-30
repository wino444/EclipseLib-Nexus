--[[
    EclipseLib-Nexus Core/Window.lua (Final Edition)
    ใช้ Elements Library ผ่าน deps.Elements
    ประกอบด้วย Welcome, Settings, Tab API พร้อม Fallback
    แก้ไข KeySystem, AddLabel, Slider และอื่น ๆ
]]

return function(deps)
    local Utils = deps.Utils
    local ThemeModule = deps.Theme
    local Theme = ThemeModule.Theme
    local DefaultTheme = ThemeModule.DefaultTheme
    local Presets = ThemeModule.Presets
    local ApplyAccent = ThemeModule.ApplyAccent
    local ResetToDefaultTheme = ThemeModule.ResetToDefault
    local Notification = deps.Notification
    local ConfigManager = deps.ConfigManager
    local KeySystem = deps.KeySystem
    local IntroEngine = deps.IntroEngine
    local BaseCard = deps.BaseCard
    local TabBar = deps.TabBar
    local TabFrame = deps.TabFrame
    local MemoryGuard = deps.MemoryGuard
    local Obfuscator = deps.Obfuscator
    local MobileOptimizer = deps.MobileOptimizer
    local SafeGlobal = deps.SafeGlobal
    local Services = deps.Services
    local Elements = deps.Elements     -- ตาราง factory functions

    local Tween, TweenWait = Utils.Tween, Utils.TweenWait
    local CC, CS = Utils.CC, Utils.CS
    local MakeScreenGui = Utils.MakeScreenGui
    local _randomName = Utils._randomName
    local SetClipboard = Utils.SetClipboard
    local MakeDraggable = Utils.MakeDraggable

    local TweenService = Services.TweenService
    local UserInputService = Services.UserInputService
    local RunService = Services.RunService
    local CoreGui = Services.CoreGui
    local Players = Services.Players
    local LocalPlayer = Players.LocalPlayer

    -- Updaters fallback
    local updaters = {}
    local function addUpdater(element, updateFn)
        if MemoryGuard then MemoryGuard:Register(element, updateFn)
        else table.insert(updaters, {element, updateFn}) end
    end
    local function removeUpdatersForElement(element)
        if MemoryGuard then MemoryGuard:Unregister(element)
        else for i=#updaters,1,-1 do if updaters[i][1]==element then table.remove(updaters,i) break end end end
    end
    if not MemoryGuard then
        RunService.Heartbeat:Connect(function() for _,v in ipairs(updaters) do pcall(v[2],v[1]) end end)
    end

    local Window = {}
    function Window.Create(opts)
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
        if ConfigManager then ConfigManager:SetFolder(cfgFolder) end

        -- ScreenGui
        local ScreenGui = MakeScreenGui(_randomName("eclipse_main_"), 999)
        local Main = Instance.new("Frame")
        Main.BackgroundColor3 = Theme.Background
        Main.Size = UDim2.new(0,500,0,350)
        Main.Position = UDim2.new(0.5,-250,0.5,-175)
        Main.ClipsDescendants = true
        Main.Visible = false
        Main.Parent = ScreenGui
        CC(Main,12)
        CS(Main,Theme.Border,1.5)

        -- TopBar
        local TopBar = Instance.new("Frame")
        TopBar.BackgroundColor3 = Theme.Secondary
        TopBar.Size = UDim2.new(1,0,0,38)
        TopBar.Parent = Main
        CC(TopBar,12)
        local tbFix = Instance.new("Frame")
        tbFix.BackgroundColor3 = Theme.Secondary
        tbFix.Size = UDim2.new(1,0,0,10)
        tbFix.Position = UDim2.new(0,0,1,-10)
        tbFix.BorderSizePixel = 0
        tbFix.Parent = TopBar

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Position = UDim2.new(0,12,0,0)
        TitleLbl.Size = UDim2.new(1,-80,1,0)
        TitleLbl.Text = "🌒 " .. windowName
        TitleLbl.TextColor3 = Theme.Text
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextSize = 14
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Parent = TopBar

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
        CloseBtn.Size = UDim2.new(0,22,0,22)
        CloseBtn.Position = UDim2.new(1,-30,0.5,-11)
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 12
        CloseBtn.Parent = TopBar
        CC(CloseBtn,6)

        local MinBtn = Instance.new("TextButton")
        MinBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        MinBtn.Size = UDim2.new(0,22,0,22)
        MinBtn.Position = UDim2.new(1,-56,0.5,-11)
        MinBtn.Text = "—"
        MinBtn.TextColor3 = Theme.Text
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.TextSize = 12
        MinBtn.Parent = TopBar
        CC(MinBtn,6)

        MakeDraggable(Main,TopBar)

        local Body = Instance.new("Frame")
        Body.BackgroundTransparency = 1
        Body.Position = UDim2.new(0,0,0,38)
        Body.Size = UDim2.new(1,0,1,-38)
        Body.Parent = Main

        local TabBarContainer = Instance.new("Frame")
        TabBarContainer.Size = UDim2.new(0,115,1,0)
        TabBarContainer.Parent = Body

        local tabButtons = {}
        local tabFrames = {}
        local activeTab = nil

        local function MakeTabBtn(label, active)
            local btn = Instance.new("TextButton")
            btn.BackgroundColor3 = active and Theme.TabActive or Theme.TabInactive
            btn.Size = UDim2.new(1,0,0,34)
            btn.Text = label
            btn.TextColor3 = active and Color3.fromRGB(255,255,255) or Theme.SubText
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.TextWrapped = true
            btn.Parent = TabBarContainer
            CC(btn,8)
            local ind = Instance.new("Frame")
            ind.Name = "_Indicator"
            ind.BackgroundColor3 = Theme.Accent
            ind.Size = UDim2.new(0,3,1,-8)
            ind.Position = UDim2.new(0,0,0,4)
            ind.BorderSizePixel = 0
            ind.Visible = active
            ind.Parent = btn
            CC(ind,2)
            return btn
        end

        local ContentArea = Instance.new("Frame")
        ContentArea.BackgroundTransparency = 1
        ContentArea.Position = UDim2.new(0,119,0,0)
        ContentArea.Size = UDim2.new(1,-119,1,0)
        ContentArea.Parent = Body

        local function MakeSF(name)
            local sf = Instance.new("ScrollingFrame")
            sf.Name = name
            sf.BackgroundTransparency = 1
            sf.Size = UDim2.new(1,0,1,0)
            sf.CanvasSize = UDim2.new(0,0,0,0)
            sf.ScrollBarThickness = 3
            sf.ScrollBarImageColor3 = Theme.Accent
            sf.Visible = false
            sf.Parent = ContentArea
            local ly = Instance.new("UIListLayout")
            ly.Padding = UDim.new(0,6)
            ly.SortOrder = Enum.SortOrder.LayoutOrder
            ly.Parent = sf
            local pd = Instance.new("UIPadding")
            pd.PaddingTop = UDim.new(0,8)
            pd.PaddingLeft = UDim.new(0,8)
            pd.PaddingRight = UDim.new(0,8)
            pd.Parent = sf
            ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sf.CanvasSize = UDim2.new(0,0,0,ly.AbsoluteContentSize.Y+20)
            end)
            return sf
        end

        local function SetActiveTab(name)
            for n,btn in pairs(tabButtons) do
                local isAct = (n==name)
                Tween(btn,{BackgroundColor3=isAct and Theme.TabActive or Theme.TabInactive},0.2)
                btn.TextColor3 = isAct and Color3.fromRGB(255,255,255) or Theme.SubText
                local ind = btn:FindFirstChild("_Indicator")
                if ind then ind.Visible = isAct end
            end
            for n,f in pairs(tabFrames) do f.Visible=(n==name) end
            activeTab = name
        end

        -- Float
        local floatSG = MakeScreenGui(_randomName("eclipse_float_"),998)
        local floatBtn = Instance.new("TextButton")
        floatBtn.BackgroundColor3 = Theme.Accent
        floatBtn.Size = UDim2.new(0,46,0,46)
        floatBtn.Position = UDim2.new(0,12,0.5,-23)
        floatBtn.Text = "🌒"
        floatBtn.TextSize = 22
        floatBtn.Font = Enum.Font.GothamBold
        floatBtn.TextColor3 = Color3.fromRGB(255,255,255)
        floatBtn.Visible = false
        floatBtn.Parent = floatSG
        CC(floatBtn,23)
        CS(floatBtn,Theme.Border,1.5)
        MakeDraggable(floatBtn,floatBtn)

        local isOpen = true
        MinBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            Tween(Main,{Size=isOpen and UDim2.new(0,500,0,350) or UDim2.new(0,500,0,38)},0.3)
            MinBtn.Text = isOpen and "—" or "▲"
        end)
        CloseBtn.MouseButton1Click:Connect(function()
            Tween(Main,{Size=UDim2.new(0,500,0,0)},0.25)
            task.wait(0.3)
            Main.Visible = false
            floatBtn.Visible = true
        end)
        floatBtn.MouseButton1Click:Connect(function()
            floatBtn.Visible = false
            Main.Visible = true
            Main.Size = UDim2.new(0,500,0,0)
            Tween(Main,{Size=UDim2.new(0,500,0,350)},0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            isOpen = true
            MinBtn.Text = "—"
        end)

        -- Helper card
        local function createCard(parent, height)
            local c = Instance.new("Frame")
            c.BackgroundColor3 = Theme.Secondary
            c.Size = UDim2.new(1,0,0,height)
            c.Parent = parent
            CC(c,10)
            CS(c,Theme.Border,1)
            local leftBar = Instance.new("Frame")
            leftBar.BackgroundColor3 = Theme.Accent
            leftBar.Size = UDim2.new(0,3,1,-16)
            leftBar.Position = UDim2.new(0,0,0,8)
            leftBar.BorderSizePixel = 0
            leftBar.Parent = c
            CC(leftBar,2)
            return c
        end

        -- ================= WELCOME TAB =================
        local wBtn = MakeTabBtn("🏠 ยินดีต้อนรับ", true)
        local wFrame = MakeSF("Frame_Welcome")
        wFrame.Visible = true
        tabButtons["_Welcome"] = wBtn
        tabFrames["_Welcome"] = wFrame
        SetActiveTab("_Welcome")

        -- Profile Card
        local aCard = createCard(wFrame,84)
        local aFr = Instance.new("Frame")
        aFr.BackgroundColor3 = Theme.Accent
        aFr.Size = UDim2.new(0,62,0,62)
        aFr.Position = UDim2.new(0,11,0.5,-31)
        aFr.Parent = aCard
        CC(aFr,31)
        CS(aFr,Theme.Accent,2)
        local aImg = Instance.new("ImageLabel")
        aImg.BackgroundTransparency = 1
        aImg.Size = UDim2.new(1,-4,1,-4)
        aImg.Position = UDim2.new(0,2,0,2)
        aImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(LocalPlayer.UserId).."&width=150&height=150&format=png"
        aImg.Parent = aFr
        CC(aImg,29)
        local dN = Instance.new("TextLabel")
        dN.BackgroundTransparency=1; dN.Position=UDim2.new(0,86,0,8); dN.Size=UDim2.new(1,-166,0,22)
        dN.Text = LocalPlayer.DisplayName or "?"; dN.TextColor3=Theme.Text; dN.Font=Enum.Font.GothamBold; dN.TextSize=16; dN.TextXAlignment=Enum.TextXAlignment.Left; dN.Parent=aCard
        local uN = Instance.new("TextLabel")
        uN.BackgroundTransparency=1; uN.Position=UDim2.new(0,86,0,32); uN.Size=UDim2.new(1,-166,0,16)
        uN.Text = "@"..(LocalPlayer.Name or "?"); uN.TextColor3=Theme.SubText; uN.Font=Enum.Font.Gotham; uN.TextSize=12; uN.TextXAlignment=Enum.TextXAlignment.Left; uN.Parent=aCard
        local idB = Instance.new("Frame")
        idB.BackgroundColor3=Theme.Accent; idB.Size=UDim2.new(0,100,0,18); idB.Position=UDim2.new(0,86,0,54); idB.Parent=aCard; CC(idB,6)
        local idL = Instance.new("TextLabel")
        idL.BackgroundTransparency=1; idL.Size=UDim2.new(1,0,1,0); idL.Text="🆔 "..tostring(LocalPlayer.UserId); idL.TextColor3=Color3.fromRGB(255,255,255); idL.Font=Enum.Font.GothamBold; idL.TextSize=10; idL.Parent=idB
        local function MakeCopyBtn(parent, xPos, yPos, getCopyVal)
            local btn = Instance.new("TextButton")
            btn.BackgroundColor3=Theme.Secondary; btn.Size=UDim2.new(0,60,0,20); btn.Position=UDim2.new(1,xPos,0,yPos)
            btn.Text="📋 Copy"; btn.TextColor3=Theme.Accent; btn.Font=Enum.Font.GothamBold; btn.TextSize=9; btn.Parent=parent
            CC(btn,5); CS(btn,Theme.Accent,1)
            btn.MouseButton1Click:Connect(function()
                SetClipboard(tostring(getCopyVal()))
                local old=btn.Text; btn.Text="✅ แล้ว!"; Tween(btn,{BackgroundColor3=Color3.fromRGB(30,80,40)},0.1)
                task.wait(1.2); btn.Text=old; Tween(btn,{BackgroundColor3=Theme.Secondary},0.15)
            end)
        end
        MakeCopyBtn(aCard,-68,8,function() return LocalPlayer.DisplayName end)
        MakeCopyBtn(aCard,-68,32,function() return LocalPlayer.Name end)

        -- Info Cards (5 cards)
        local function MakeInfoCard(icon, label, valFn, copyable)
            local c = createCard(wFrame,54)
            local iL = Instance.new("TextLabel"); iL.BackgroundTransparency=1; iL.Position=UDim2.new(0,8,0,0); iL.Size=UDim2.new(0,30,1,0); iL.Text=icon; iL.TextSize=20; iL.Font=Enum.Font.GothamBold; iL.Parent=c
            local kL = Instance.new("TextLabel"); kL.BackgroundTransparency=1; kL.Position=UDim2.new(0,44,0,7); kL.Size=UDim2.new(1,-120,0,16); kL.Text=label; kL.TextColor3=Theme.SubText; kL.TextSize=10; kL.Font=Enum.Font.Gotham; kL.TextXAlignment=Enum.TextXAlignment.Left; kL.Parent=c
            local vL = Instance.new("TextLabel"); vL.BackgroundTransparency=1; vL.Position=UDim2.new(0,44,0,24); vL.Size=UDim2.new(1,-120,0,22); vL.Text=tostring(valFn()); vL.TextColor3=Theme.Text; vL.TextSize=13; vL.Font=Enum.Font.GothamBold; vL.TextXAlignment=Enum.TextXAlignment.Left; vL.Parent=c
            addUpdater(vL, function(lbl) lbl.Text=tostring(valFn()) end)
            vL.Destroying:Connect(function() removeUpdatersForElement(vL) end)
            if copyable then
                local cpBtn = Instance.new("TextButton"); cpBtn.BackgroundColor3=Theme.Secondary; cpBtn.Size=UDim2.new(0,60,0,22); cpBtn.Position=UDim2.new(1,-70,0.5,-11); cpBtn.Text="📋 Copy"; cpBtn.TextColor3=Theme.Accent; cpBtn.Font=Enum.Font.GothamBold; cpBtn.TextSize=9; cpBtn.Parent=c; CC(cpBtn,5); CS(cpBtn,Theme.Accent,1)
                cpBtn.MouseButton1Click:Connect(function() SetClipboard(tostring(valFn())); local old=cpBtn.Text; cpBtn.Text="✅ แล้ว!"; Tween(cpBtn,{BackgroundColor3=Color3.fromRGB(30,80,40)},0.1); task.wait(1.2); cpBtn.Text=old; Tween(cpBtn,{BackgroundColor3=Theme.Secondary},0.15) end)
            end
        end
        MakeInfoCard("🗺️","ชื่อแมพ", function() local name=""; pcall(function() name=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end); if not name or name=="" then pcall(function() name=game.Name end) end; return name~="" and name or "ไม่พบ" end, true)
        MakeInfoCard("📍","Place ID", function() return tostring(game.PlaceId) end, true)
        MakeInfoCard("⏳","อายุบัญชี", function() local days=LocalPlayer.AccountAge or 0; local years=math.floor(days/365); local remain=days-(years*365); local months=math.floor(remain/30); local d=remain-(months*30); local result=""; if years>0 then result=result..years.." ปี " end; if months>0 then result=result..months.." เดือน " end; result=result..d.." วัน"; return result end, false)
        MakeInfoCard("🖥️","Server ID", function() return game.JobId or "ไม่พบ" end, true)
        local sessionStart = tick()
        MakeInfoCard("⏱️","เวลาที่เล่น", function() local elapsed=math.floor(tick()-sessionStart); local d=math.floor(elapsed/86400); elapsed=elapsed-(d*86400); local h=math.floor(elapsed/3600); elapsed=elapsed-(h*3600); local m=math.floor(elapsed/60); local s=elapsed-(m*60); local result=""; if d>0 then result=result..d.." วัน " end; if h>0 then result=result..h.." ชั่วโมง " end; if m>0 then result=result..m.." นาที " end; result=result..s.." วินาที"; return result end, false)

        -- Credit Card
        local creditCard = createCard(wFrame,36)
        local creditL = Instance.new("TextLabel"); creditL.BackgroundTransparency=1; creditL.Size=UDim2.new(1,0,1,0); creditL.Text="🏷️ UI สร้างโดย wino444 · ขับเคลื่อนโดย Deekseek AI Lab"; creditL.TextColor3=Theme.Accent; creditL.Font=Enum.Font.GothamBold; creditL.TextSize=11; creditL.Parent=creditCard

        wBtn.MouseButton1Click:Connect(function() SetActiveTab("_Welcome") end)

        -- ================= SETTINGS TAB =================
        local sBtn = MakeTabBtn("⚙️ ตั้งค่า UI", false)
        local sFrame = MakeSF("Frame_Settings")
        tabButtons["_Settings"] = sBtn; tabFrames["_Settings"] = sFrame

        local function SecTitle(text)
            local l = Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,22); l.Text=text; l.TextColor3=Theme.Accent; l.Font=Enum.Font.GothamBold; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=sFrame
        end

        -- Preset Themes (ย่อส่วน, ใช้โค้ดเดิม)
        SecTitle("🎨 Preset Themes")
        local thCard = Instance.new("Frame"); thCard.BackgroundColor3=Theme.Secondary; thCard.Size=UDim2.new(1,0,0,0); thCard.AutomaticSize=Enum.AutomaticSize.Y; thCard.Parent=sFrame; CC(thCard,10); CS(thCard,Theme.Border,1)
        local leftBar = Instance.new("Frame"); leftBar.BackgroundColor3=Theme.Accent; leftBar.Size=UDim2.new(0,3,1,-16); leftBar.Position=UDim2.new(0,0,0,8); leftBar.BorderSizePixel=0; leftBar.Parent=thCard; CC(leftBar,2)
        local thLy = Instance.new("UIGridLayout"); thLy.CellSize=UDim2.new(0.31,0,0,48); thLy.CellPadding=UDim2.new(0.02,0,0,6); thLy.SortOrder=Enum.SortOrder.LayoutOrder; thLy.Parent=thCard
        local thPd = Instance.new("UIPadding"); thPd.PaddingTop=UDim.new(0,8); thPd.PaddingLeft=UDim.new(0,6); thPd.PaddingRight=UDim.new(0,6); thPd.Parent=thCard
        for _,th in ipairs(Presets) do
            local tb = Instance.new("TextButton"); tb.BackgroundColor3=th.bg; tb.Size=UDim2.new(1,0,1,0); tb.Text=th.name; tb.TextColor3=Color3.fromRGB(220,220,235); tb.Font=Enum.Font.GothamBold; tb.TextSize=10; tb.TextWrapped=true; tb.Parent=thCard; CC(tb,7); CS(tb,th.accent,1.5)
            tb.MouseButton1Click:Connect(function()
                ThemeModule.ApplyPreset(th)
                Main.BackgroundColor3=Theme.Background; TopBar.BackgroundColor3=Theme.Secondary; tbFix.BackgroundColor3=Theme.Secondary
                for n,btn in pairs(tabButtons) do btn.BackgroundColor3=(n==activeTab) and Theme.TabActive or Theme.TabInactive end
                floatBtn.BackgroundColor3=Theme.Accent
                Notification:Notify({Title="🎨 เปลี่ยน Theme แล้ว", Content=th.name, Duration=2})
            end)
        end

        -- Custom Accent (ย่อ)
        SecTitle("🖌️ Custom Accent Color")
        local rgbCard = createCard(sFrame,150)
        local prevFrame = Instance.new("Frame"); prevFrame.BackgroundColor3=Theme.Accent; prevFrame.Size=UDim2.new(1,-20,0,22); prevFrame.Position=UDim2.new(0,10,0,8); prevFrame.Parent=rgbCard; CC(prevFrame,6)
        local prevLbl = Instance.new("TextLabel"); prevLbl.BackgroundTransparency=1; prevLbl.Size=UDim2.new(1,0,1,0); prevLbl.Text="Preview"; prevLbl.TextColor3=Color3.fromRGB(255,255,255); prevLbl.Font=Enum.Font.GothamBold; prevLbl.TextSize=11; prevLbl.Parent=prevFrame
        local rVal,gVal,bVal = 100,60,200
        local function UpdatePreview()
            local c = Color3.fromRGB(rVal,gVal,bVal); prevFrame.BackgroundColor3=c; prevLbl.Text="R:"..rVal.." G:"..gVal.." B:"..bVal
        end
        local function MakeRGBSlider(label,yPos,initVal,color,onChange)
            local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,yPos); lbl.Size=UDim2.new(0,18,0,16); lbl.Text=label; lbl.TextColor3=Theme.SubText; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.Parent=rgbCard
            local valLbl = Instance.new("TextLabel"); valLbl.BackgroundTransparency=1; valLbl.Position=UDim2.new(1,-36,0,yPos); valLbl.Size=UDim2.new(0,30,0,16); valLbl.Text=tostring(initVal); valLbl.TextColor3=Theme.Text; valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=11; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=rgbCard
            local tr = Instance.new("Frame"); tr.BackgroundColor3=Theme.Slider_BG; tr.Size=UDim2.new(1,-62,0,8); tr.Position=UDim2.new(0,30,0,yPos+4); tr.Parent=rgbCard; CC(tr,4)
            local fi = Instance.new("Frame"); fi.BackgroundColor3=color; fi.Size=UDim2.new(initVal/255,0,1,0); fi.Parent=tr; CC(fi,4)
            local drag=false
            local function upd(pos)
                local r=math.clamp((pos.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); local v=math.floor(r*255)
                fi.Size=UDim2.new(r,0,1,0); valLbl.Text=tostring(v); onChange(v); UpdatePreview()
            end
            tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i.Position) end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
        end
        MakeRGBSlider("R",38,rVal,Color3.fromRGB(220,60,60),function(v) rVal=v end)
        MakeRGBSlider("G",64,gVal,Color3.fromRGB(60,200,80),function(v) gVal=v end)
        MakeRGBSlider("B",90,bVal,Color3.fromRGB(60,120,220),function(v) bVal=v end)
        local applyBtn = Instance.new("TextButton"); applyBtn.BackgroundColor3=Theme.Accent; applyBtn.Size=UDim2.new(1,-20,0,28); applyBtn.Position=UDim2.new(0,10,0,116); applyBtn.Text="🎨 ใช้สีนี้"; applyBtn.TextColor3=Color3.fromRGB(255,255,255); applyBtn.Font=Enum.Font.GothamBold; applyBtn.TextSize=12; applyBtn.Parent=rgbCard; CC(applyBtn,7)
        applyBtn.MouseButton1Click:Connect(function()
            local c = Color3.fromRGB(rVal,gVal,bVal); ApplyAccent(c); floatBtn.BackgroundColor3=c; applyBtn.BackgroundColor3=c
            for n,btn in pairs(tabButtons) do if n==activeTab then btn.BackgroundColor3=c end end
            Notification:Notify({Title="🎨 ใช้สีแล้ว!", Content="R:"..rVal.." G:"..gVal.." B:"..bVal, Duration=2})
        end)

        -- UI Size (ย่อ)
        SecTitle("📏 ขนาด UI")
        local szRow = createCard(sFrame,48)
        local sl2 = Instance.new("UIListLayout"); sl2.FillDirection=Enum.FillDirection.Horizontal; sl2.Padding=UDim.new(0,6); sl2.VerticalAlignment=Enum.VerticalAlignment.Center; sl2.HorizontalAlignment=Enum.HorizontalAlignment.Center; sl2.Parent=szRow
        local sizes = { {"เล็ก",UDim2.new(0,420,0,300)}, {"กลาง",UDim2.new(0,500,0,350)}, {"ใหญ่",UDim2.new(0,600,0,420)} }
        for _,sz in ipairs(sizes) do
            local b = Instance.new("TextButton"); b.BackgroundColor3=Theme.TabInactive; b.Size=UDim2.new(0,80,0,30); b.Text=sz[1]; b.TextColor3=Theme.Text; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.Parent=szRow; CC(b,8)
            b.MouseButton1Click:Connect(function() if isOpen then Tween(Main,{Size=sz[2]},0.3); Main.Position=UDim2.new(0.5,-sz[2].X.Offset/2,0.5,-sz[2].Y.Offset/2) end end)
        end

        -- Notification Position
        SecTitle("🔔 ตำแหน่ง Notification")
        local nRow = createCard(sFrame,48)
        local nl = Instance.new("UIListLayout"); nl.FillDirection=Enum.FillDirection.Horizontal; nl.Padding=UDim.new(0,6); nl.VerticalAlignment=Enum.VerticalAlignment.Center; nl.HorizontalAlignment=Enum.HorizontalAlignment.Center; nl.Parent=nRow
        local notifPositions = { {"มุมขวาบน",UDim2.new(1,-220,0,60)}, {"มุมซ้ายบน",UDim2.new(0,10,0,60)} }
        for _,np in ipairs(notifPositions) do
            local b = Instance.new("TextButton"); b.BackgroundColor3=Theme.TabInactive; b.Size=UDim2.new(0,110,0,30); b.Text=np[1]; b.TextColor3=Theme.Text; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.Parent=nRow; CC(b,8)
            b.MouseButton1Click:Connect(function() Notification:SetPosition(np[2]); Notification:Notify({Title="🔔 เปลี่ยนตำแหน่งแล้ว", Content=np[1], Duration=2}) end)
        end

        -- Transparency Slider
        SecTitle("🌗 ความโปร่งใส UI")
        local tCard = createCard(sFrame,60)
        local tNL = Instance.new("TextLabel"); tNL.BackgroundTransparency=1; tNL.Position=UDim2.new(0,10,0,6); tNL.Size=UDim2.new(0.68,0,0,18); tNL.Text="ความโปร่งใสพื้นหลัง"; tNL.TextColor3=Theme.Text; tNL.Font=Enum.Font.GothamBold; tNL.TextSize=12; tNL.TextXAlignment=Enum.TextXAlignment.Left; tNL.Parent=tCard
        local tVL = Instance.new("TextLabel"); tVL.BackgroundTransparency=1; tVL.Position=UDim2.new(0.7,0,0,6); tVL.Size=UDim2.new(0.28,0,0,18); tVL.Text="0%"; tVL.TextColor3=Theme.Accent; tVL.Font=Enum.Font.GothamBold; tVL.TextSize=13; tVL.TextXAlignment=Enum.TextXAlignment.Right; tVL.Parent=tCard
        local tTr = Instance.new("Frame"); tTr.BackgroundColor3=Theme.Slider_BG; tTr.Size=UDim2.new(1,-20,0,8); tTr.Position=UDim2.new(0,10,0,36); tTr.Parent=tCard; CC(tTr,4)
        local tFi = Instance.new("Frame"); tFi.BackgroundColor3=Theme.Slider_Fill; tFi.Size=UDim2.new(0,0,1,0); tFi.Parent=tTr; CC(tFi,4)
        local tDrag = false
        tTr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then tDrag=true end end)
        UserInputService.InputChanged:Connect(function(i) if tDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local r=math.clamp((i.Position.X-tTr.AbsolutePosition.X)/tTr.AbsoluteSize.X,0,1); tFi.Size=UDim2.new(r,0,1,0); tVL.Text=math.floor(r*80).."%"; Main.BackgroundTransparency=r*0.8 end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then tDrag=false end end)

        -- Notification Queue Toggle
        SecTitle("🔔 ระบบคิว Notification")
        local qCard = createCard(sFrame,54)
        local qIcon = Instance.new("TextLabel"); qIcon.BackgroundTransparency=1; qIcon.Position=UDim2.new(0,10,0,8); qIcon.Size=UDim2.new(0,24,0,18); qIcon.Text="📋"; qIcon.TextSize=16; qIcon.Font=Enum.Font.GothamBold; qIcon.Parent=qCard
        local qNL = Instance.new("TextLabel"); qNL.BackgroundTransparency=1; qNL.Position=UDim2.new(0,38,0,6); qNL.Size=UDim2.new(0.6,0,0,18); qNL.Text="ระบบคิว Notification"; qNL.TextColor3=Theme.Text; qNL.Font=Enum.Font.GothamBold; qNL.TextSize=12; qNL.TextXAlignment=Enum.TextXAlignment.Left; qNL.Parent=qCard
        local qDL = Instance.new("TextLabel"); qDL.BackgroundTransparency=1; qDL.Position=UDim2.new(0,38,0,26); qDL.Size=UDim2.new(0.65,0,0,16); qDL.Text="แสดงทีละอันตามลำดับ"; qDL.TextColor3=Theme.SubText; qDL.Font=Enum.Font.Gotham; qDL.TextSize=10; qDL.TextXAlignment=Enum.TextXAlignment.Left; qDL.Parent=qCard
        local qSW = Instance.new("Frame"); qSW.BackgroundColor3=Theme.Toggle_OFF; qSW.Size=UDim2.new(0,44,0,24); qSW.Position=UDim2.new(1,-54,0.5,-12); qSW.Parent=qCard; CC(qSW,12)
        local qKN = Instance.new("Frame"); qKN.BackgroundColor3=Color3.fromRGB(255,255,255); qKN.Size=UDim2.new(0,18,0,18); qKN.Position=UDim2.new(0,3,0.5,-9); qKN.Parent=qSW; CC(qKN,9)
        local qBtn = Instance.new("TextButton"); qBtn.BackgroundTransparency=1; qBtn.Size=UDim2.new(1,0,1,0); qBtn.Text=""; qBtn.Parent=qCard
        qBtn.MouseButton1Click:Connect(function()
            local newState = not Notification.NotifQueueEnabled
            Notification:SetQueueEnabled(newState)
            Tween(qSW,{BackgroundColor3=newState and Theme.Toggle_ON or Theme.Toggle_OFF},0.2)
            Tween(qKN,{Position=newState and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.2)
            Notification:Notify({Title=newState and "📋 เปิดระบบคิวแล้ว" or "⚡ ปิดระบบคิวแล้ว", Content=newState and "Notification จะแสดงทีละอัน" or "Notification แสดงพร้อมกันได้", Duration=2})
        end)

        -- Mobile Optimizer Toggle
        SecTitle("📱 โหมดประหยัดมือถือ")
        local mCard = createCard(sFrame,54)
        local mIcon = Instance.new("TextLabel"); mIcon.BackgroundTransparency=1; mIcon.Position=UDim2.new(0,10,0,8); mIcon.Size=UDim2.new(0,24,0,18); mIcon.Text="📱"; mIcon.TextSize=16; mIcon.Font=Enum.Font.GothamBold; mIcon.Parent=mCard
        local mNL = Instance.new("TextLabel"); mNL.BackgroundTransparency=1; mNL.Position=UDim2.new(0,38,0,6); mNL.Size=UDim2.new(0.6,0,0,18); mNL.Text="โหมดประหยัดมือถือ"; mNL.TextColor3=Theme.Text; mNL.Font=Enum.Font.GothamBold; mNL.TextSize=12; mNL.TextXAlignment=Enum.TextXAlignment.Left; mNL.Parent=mCard
        local mDL = Instance.new("TextLabel"); mDL.BackgroundTransparency=1; mDL.Position=UDim2.new(0,38,0,26); mDL.Size=UDim2.new(0.65,0,0,16); mDL.Text="ตัดลูกเล่นหนัก ๆ เพิ่มความลื่น"; mDL.TextColor3=Theme.SubText; mDL.Font=Enum.Font.Gotham; mDL.TextSize=10; mDL.TextXAlignment=Enum.TextXAlignment.Left; mDL.Parent=mCard
        local mSW = Instance.new("Frame"); mSW.BackgroundColor3=(MobileOptimizer and MobileOptimizer.Enabled) and Theme.Toggle_ON or Theme.Toggle_OFF; mSW.Size=UDim2.new(0,44,0,24); mSW.Position=UDim2.new(1,-54,0.5,-12); mSW.Parent=mCard; CC(mSW,12)
        local mKN = Instance.new("Frame"); mKN.BackgroundColor3=Color3.fromRGB(255,255,255); mKN.Size=UDim2.new(0,18,0,18); mKN.Position=(MobileOptimizer and MobileOptimizer.Enabled) and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9); mKN.Parent=mSW; CC(mKN,9)
        local mBtn = Instance.new("TextButton"); mBtn.BackgroundTransparency=1; mBtn.Size=UDim2.new(1,0,1,0); mBtn.Text=""; mBtn.Parent=mCard
        mBtn.MouseButton1Click:Connect(function()
            if not MobileOptimizer then return end
            local state = not MobileOptimizer.Enabled
            MobileOptimizer:Toggle(state)
            Tween(mSW,{BackgroundColor3=state and Theme.Toggle_ON or Theme.Toggle_OFF},0.2)
            Tween(mKN,{Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.2)
            Notification:Notify({Title=state and "📱 เปิดโหมดประหยัด" or "⚡ ปิดโหมดประหยัด", Content=state and "เอฟเฟกต์ถูกลดลงเพื่อความลื่น" or "แสดงผลเต็มรูปแบบ", Duration=2})
        end)
        if ConfigManager then ConfigManager:Register("MobileOptimizer", function() return MobileOptimizer and MobileOptimizer.Enabled end, function(v) if MobileOptimizer then MobileOptimizer:Toggle(v) end end) end

        -- Reset Settings (ย่อ)
        SecTitle("🔄 Reset การตั้งค่า")
        local resetCard = createCard(sFrame,126)
        local resetLy = Instance.new("UIGridLayout"); resetLy.CellSize=UDim2.new(0.46,0,0,28); resetLy.CellPadding=UDim2.new(0.04,0,0,6); resetLy.SortOrder=Enum.SortOrder.LayoutOrder; resetLy.Parent=resetCard
        local resetPd = Instance.new("UIPadding"); resetPd.PaddingTop=UDim.new(0,8); resetPd.PaddingLeft=UDim.new(0,8); resetPd.PaddingRight=UDim.new(0,8); resetPd.Parent=resetCard
        local resetItems = {
            { label="🎨 Reset สี Theme", fn=function()
                ResetToDefaultTheme(); Main.BackgroundColor3=Theme.Background; TopBar.BackgroundColor3=Theme.Secondary; tbFix.BackgroundColor3=Theme.Secondary
                for n,btn in pairs(tabButtons) do btn.BackgroundColor3=(n==activeTab) and Theme.TabActive or Theme.TabInactive end
                floatBtn.BackgroundColor3=Theme.Accent; applyBtn.BackgroundColor3=Theme.Accent
                Notification:Notify({Title="🔄 Reset แล้ว", Content="สี Theme กลับค่าเริ่มต้น", Duration=2})
            end },
            { label="📏 Reset ขนาด UI", fn=function() Tween(Main,{Size=UDim2.new(0,500,0,350)},0.3); Main.Position=UDim2.new(0.5,-250,0.5,-175); Notification:Notify({Title="🔄 Reset แล้ว", Content="ขนาด UI กลับค่าเริ่มต้น", Duration=2}) end },
            { label="🌗 Reset โปร่งใส", fn=function() tFi.Size=UDim2.new(0,0,1,0); tVL.Text="0%"; Main.BackgroundTransparency=0; Notification:Notify({Title="🔄 Reset แล้ว", Content="ความโปร่งใสกลับค่าเริ่มต้น", Duration=2}) end },
            { label="🔔 Reset Notif", fn=function() Notification:SetPosition(UDim2.new(1,-220,0,60)); Notification:Notify({Title="🔄 Reset แล้ว", Content="ตำแหน่ง Notification กลับค่าเริ่มต้น", Duration=2}) end },
        }
        for _,item in ipairs(resetItems) do
            local rb = Instance.new("TextButton"); rb.BackgroundColor3=Color3.fromRGB(50,30,80); rb.Size=UDim2.new(1,0,1,0); rb.Text=item.label; rb.TextColor3=Theme.Text; rb.Font=Enum.Font.GothamBold; rb.TextSize=10; rb.TextWrapped=true; rb.Parent=resetCard; CC(rb,7); CS(rb,Theme.Border,1)
            rb.MouseButton1Click:Connect(function() Tween(rb,{BackgroundColor3=Color3.fromRGB(80,40,120)},0.1); task.wait(0.15); Tween(rb,{BackgroundColor3=Color3.fromRGB(50,30,80)},0.2); item.fn() end)
        end

        -- Config Save/Load (ย่อ)
        SecTitle("💾 บันทึก / โหลด Config")
        local saveCard = createCard(sFrame,182)
        local snL = Instance.new("TextLabel"); snL.BackgroundTransparency=1; snL.Position=UDim2.new(0,10,0,8); snL.Size=UDim2.new(1,-20,0,14); snL.Text="📝 ชื่อไฟล์ใหม่"; snL.TextColor3=Theme.SubText; snL.Font=Enum.Font.Gotham; snL.TextSize=11; snL.TextXAlignment=Enum.TextXAlignment.Left; snL.Parent=saveCard
        local nIBG = Instance.new("Frame"); nIBG.BackgroundColor3=Theme.Input_BG; nIBG.Size=UDim2.new(1,-20,0,28); nIBG.Position=UDim2.new(0,10,0,24); nIBG.Parent=saveCard; CC(nIBG,6); CS(nIBG,Theme.Border)
        local nBox = Instance.new("TextBox"); nBox.BackgroundTransparency=1; nBox.Size=UDim2.new(1,-10,1,0); nBox.Position=UDim2.new(0,6,0,0); nBox.PlaceholderText="พิมพ์ชื่อไฟล์..."; nBox.PlaceholderColor3=Theme.SubText; nBox.TextColor3=Theme.Text; nBox.Font=Enum.Font.Gotham; nBox.TextSize=12; nBox.TextXAlignment=Enum.TextXAlignment.Left; nBox.ClearTextOnFocus=false; nBox.Text=""; nBox.Parent=nIBG
        local saveNewBtn = Instance.new("TextButton"); saveNewBtn.BackgroundColor3=Theme.Accent; saveNewBtn.Size=UDim2.new(1,-20,0,28); saveNewBtn.Position=UDim2.new(0,10,0,58); saveNewBtn.Text="💾 Save ใหม่"; saveNewBtn.TextColor3=Color3.fromRGB(255,255,255); saveNewBtn.Font=Enum.Font.GothamBold; saveNewBtn.TextSize=12; saveNewBtn.Parent=saveCard; CC(saveNewBtn,7)
        local sep = Instance.new("Frame"); sep.BackgroundColor3=Theme.Border; sep.Size=UDim2.new(1,-20,0,1); sep.Position=UDim2.new(0,10,0,94); sep.BorderSizePixel=0; sep.Parent=saveCard
        local exL = Instance.new("TextLabel"); exL.BackgroundTransparency=1; exL.Position=UDim2.new(0,10,0,100); exL.Size=UDim2.new(1,-20,0,14); exL.Text="📂 ไฟล์ที่บันทึกไว้"; exL.TextColor3=Theme.SubText; exL.Font=Enum.Font.Gotham; exL.TextSize=11; exL.TextXAlignment=Enum.TextXAlignment.Left; exL.Parent=saveCard
        local fileSelected = ""
        local fdBG = Instance.new("Frame"); fdBG.BackgroundColor3=Theme.Dropdown_BG; fdBG.Size=UDim2.new(0.48,0,0,28); fdBG.Position=UDim2.new(0,10,0,118); fdBG.ClipsDescendants=false; fdBG.Parent=saveCard; CC(fdBG,6); CS(fdBG,Theme.Border)
        local fdLbl = Instance.new("TextLabel"); fdLbl.BackgroundTransparency=1; fdLbl.Size=UDim2.new(1,-26,1,0); fdLbl.Position=UDim2.new(0,6,0,0); fdLbl.Text="(ยังไม่มีไฟล์)"; fdLbl.TextColor3=Theme.Text; fdLbl.Font=Enum.Font.Gotham; fdLbl.TextSize=11; fdLbl.TextXAlignment=Enum.TextXAlignment.Left; fdLbl.Parent=fdBG
        local fdArrow = Instance.new("TextButton"); fdArrow.BackgroundTransparency=1; fdArrow.Size=UDim2.new(0,24,1,0); fdArrow.Position=UDim2.new(1,-26,0,0); fdArrow.Text="▼"; fdArrow.TextColor3=Theme.Accent; fdArrow.Font=Enum.Font.GothamBold; fdArrow.TextSize=12; fdArrow.Parent=fdBG
        local fdList = Instance.new("Frame"); fdList.BackgroundColor3=Theme.Dropdown_BG; fdList.Size=UDim2.new(1,0,0,0); fdList.Position=UDim2.new(0,0,1,2); fdList.Visible=false; fdList.ZIndex=20; fdList.Parent=fdBG; CC(fdList,6); CS(fdList,Theme.Border)
        local fdLy = Instance.new("UIListLayout"); fdLy.Padding=UDim.new(0,2); fdLy.SortOrder=Enum.SortOrder.LayoutOrder; fdLy.Parent=fdList
        local fdPd = Instance.new("UIPadding"); fdPd.PaddingTop=UDim.new(0,4); fdPd.PaddingLeft=UDim.new(0,4); fdPd.PaddingRight=UDim.new(0,4); fdPd.Parent=fdList
        local fdExp = false
        local function RefreshFileList()
            for _,c in ipairs(fdList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local files = ConfigManager and ConfigManager:GetSaveList() or {}
            for _,fname in ipairs(files) do
                local fb = Instance.new("TextButton"); fb.BackgroundColor3=Theme.Secondary; fb.Size=UDim2.new(1,0,0,24); fb.Text=" "..fname; fb.TextColor3=Theme.Text; fb.Font=Enum.Font.Gotham; fb.TextSize=11; fb.TextXAlignment=Enum.TextXAlignment.Left; fb.ZIndex=21; fb.Parent=fdList; CC(fb,5)
                fb.MouseButton1Click:Connect(function() fileSelected=fname; fdLbl.Text=fname; fdExp=false; fdList.Visible=false; fdArrow.Text="▼" end)
            end
            fdList.Size=UDim2.new(1,0,0,#files*28+8)
        end
        RefreshFileList()
        fdArrow.MouseButton1Click:Connect(function() fdExp=not fdExp; if fdExp then RefreshFileList() end; fdList.Visible=fdExp; fdArrow.Text=fdExp and "▲" or "▼" end)
        local loadBtn = Instance.new("TextButton"); loadBtn.BackgroundColor3=Color3.fromRGB(40,110,190); loadBtn.Size=UDim2.new(0.23,0,0,28); loadBtn.Position=UDim2.new(0.52,0,0,118); loadBtn.Text="📂 Load"; loadBtn.TextColor3=Color3.fromRGB(255,255,255); loadBtn.Font=Enum.Font.GothamBold; loadBtn.TextSize=11; loadBtn.Parent=saveCard; CC(loadBtn,7)
        local overBtn = Instance.new("TextButton"); overBtn.BackgroundColor3=Color3.fromRGB(150,70,10); overBtn.Size=UDim2.new(0.23,0,0,28); overBtn.Position=UDim2.new(0.77,0,0,118); overBtn.Text="✏️ ทับ"; overBtn.TextColor3=Color3.fromRGB(255,255,255); overBtn.Font=Enum.Font.GothamBold; overBtn.TextSize=11; overBtn.Parent=saveCard; CC(overBtn,7)
        local cfgSt = Instance.new("TextLabel"); cfgSt.BackgroundTransparency=1; cfgSt.Position=UDim2.new(0,10,0,154); cfgSt.Size=UDim2.new(1,-20,0,18); cfgSt.Text=""; cfgSt.TextColor3=Color3.fromRGB(60,200,100); cfgSt.Font=Enum.Font.Gotham; cfgSt.TextSize=11; cfgSt.TextXAlignment=Enum.TextXAlignment.Left; cfgSt.Parent=saveCard
        local function ShowSt(msg,ok) cfgSt.Text=msg; cfgSt.TextColor3=ok and Color3.fromRGB(60,200,100) or Color3.fromRGB(200,80,60); task.delay(3,function() cfgSt.Text="" end) end
        saveNewBtn.MouseButton1Click:Connect(function() local name=nBox.Text; if name=="" then ShowSt("❌ พิมพ์ชื่อไฟล์ก่อนนะ!",false); return end; local ok=ConfigManager and ConfigManager:Save(name); if ok then ShowSt("✅ Save '"..name.."' สำเร็จ!",true); nBox.Text=""; RefreshFileList() else ShowSt("❌ Save ไม่สำเร็จ",false) end end)
        loadBtn.MouseButton1Click:Connect(function() if fileSelected=="" or fileSelected=="(ยังไม่มีไฟล์)" then ShowSt("❌ เลือกไฟล์ก่อน",false); return end; local ok=ConfigManager and ConfigManager:Load(fileSelected); if ok then ShowSt("✅ Load '"..fileSelected.."' สำเร็จ!",true) else ShowSt("❌ ไม่พบไฟล์",false) end end)
        overBtn.MouseButton1Click:Connect(function() if fileSelected=="" or fileSelected=="(ยังไม่มีไฟล์)" then ShowSt("❌ เลือกไฟล์ที่จะ Save ทับก่อน",false); return end; local ok=ConfigManager and ConfigManager:Save(fileSelected); if ok then ShowSt("✅ Save ทับ '"..fileSelected.."' สำเร็จ!",true) else ShowSt("❌ Save ทับไม่สำเร็จ",false) end end)

        sBtn.MouseButton1Click:Connect(function() SetActiveTab("_Settings") end)

        -- ================= TAB API =================
        local WindowObj = {}
        function WindowObj:CreateTab(nameOrOpts, _icon)
            local tabName, tabIcon
            if type(nameOrOpts)=="string" then tabName=nameOrOpts; tabIcon=_icon or ""
            else tabName=nameOrOpts.Name or "Tab"; tabIcon=nameOrOpts.Icon or "" end
            local label = (tabIcon~="") and (tabIcon.." "..tabName) or tabName
            local tabBtn = MakeTabBtn(label, false)
            local tabFrame = MakeSF("Frame_"..tabName)
            tabButtons[tabName] = tabBtn; tabFrames[tabName] = tabFrame
            tabBtn.MouseButton1Click:Connect(function() SetActiveTab(tabName) end)

            local TabAPI = {}
            -- fallback BaseCard
            local function BaseCardTab(h)
                if BaseCard then return BaseCard(tabFrame, h) end
                return createCard(tabFrame, h)
            end

            -- ใช้ Elements Library (หรือ fallback)
            local function useElement(name, fallbackFactory)
                if Elements and type(Elements[name]) == "function" then
                    return Elements[name]
                else
                    return fallbackFactory
                end
            end

            -- Label
            function TabAPI:AddLabel(o)
                local factory = useElement("Label", function(p,o)
                    local l = Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,24); l.Text=o.Text or ""; l.TextColor3=Theme.SubText; l.Font=Enum.Font.Gotham; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true; l.Parent=p
                    return { SetText = function(t) l.Text=t end }
                end)
                return factory(tabFrame, o)
            end

            -- Section
            function TabAPI:AddSection(o)
                local factory = useElement("Section", function(p,o) return {} end)
                return factory(tabFrame, o)
            end

            -- Button
            function TabAPI:AddButton(o)
                local factory = useElement("Button", function(p,o)
                    local card = BaseCardTab(50)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(0.6,0,0,18); nL.Text=o.Name or "Button"; nL.TextColor3=Theme.Text; nL.Font=Enum.Font.GothamBold; nL.TextSize=13; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local dL = Instance.new("TextLabel"); dL.BackgroundTransparency=1; dL.Position=UDim2.new(0,10,0,26); dL.Size=UDim2.new(0.6,0,0,16); dL.Text=o.Description or ""; dL.TextColor3=Theme.SubText; dL.Font=Enum.Font.Gotham; dL.TextSize=10; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.Parent=card
                    if o.RealtimeValue then
                        local rL = Instance.new("TextLabel"); rL.BackgroundTransparency=1; rL.Position=UDim2.new(0.58,0,0,6); rL.Size=UDim2.new(0.24,0,0,18); rL.Text=tostring(o.RealtimeValue()); rL.TextColor3=Theme.Accent; rL.Font=Enum.Font.GothamBold; rL.TextSize=11; rL.TextXAlignment=Enum.TextXAlignment.Right; rL.Parent=card
                        addUpdater(rL, function(lbl) lbl.Text=tostring(o.RealtimeValue()) end)
                    end
                    local btn = Instance.new("TextButton"); btn.BackgroundColor3=Theme.Accent; btn.Size=UDim2.new(0,52,0,26); btn.Position=UDim2.new(1,-62,0.5,-13); btn.Text="▶ RUN"; btn.TextColor3=Color3.fromRGB(255,255,255); btn.Font=Enum.Font.GothamBold; btn.TextSize=10; btn.Parent=card; CC(btn,6)
                    btn.MouseButton1Click:Connect(function() Tween(btn,{BackgroundColor3=Theme.AccentHover},0.1); task.wait(0.1); Tween(btn,{BackgroundColor3=Theme.Accent},0.1); if o.Callback then o.Callback() end end)
                    return {}
                end)
                return factory(tabFrame, o)
            end

            -- Toggle
            function TabAPI:AddToggle(o)
                local factory = useElement("Toggle", function(p,o)
                    local state = o.Default or false
                    local card = BaseCardTab(50)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(0.7,0,0,18); nL.Text=o.Name or "Toggle"; nL.TextColor3=Theme.Text; nL.Font=Enum.Font.GothamBold; nL.TextSize=13; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local dL = Instance.new("TextLabel"); dL.BackgroundTransparency=1; dL.Position=UDim2.new(0,10,0,26); dL.Size=UDim2.new(0.7,0,0,16); dL.Text=o.Description or ""; dL.TextColor3=Theme.SubText; dL.Font=Enum.Font.Gotham; dL.TextSize=10; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.Parent=card
                    local sw = Instance.new("Frame"); sw.BackgroundColor3=state and Theme.Toggle_ON or Theme.Toggle_OFF; sw.Size=UDim2.new(0,44,0,24); sw.Position=UDim2.new(1,-54,0.5,-12); sw.Parent=card; CC(sw,12)
                    local kn = Instance.new("Frame"); kn.BackgroundColor3=Color3.fromRGB(255,255,255); kn.Size=UDim2.new(0,18,0,18); kn.Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9); kn.Parent=sw; CC(kn,9)
                    local ca = Instance.new("TextButton"); ca.BackgroundTransparency=1; ca.Size=UDim2.new(1,0,1,0); ca.Text=""; ca.Parent=card
                    local function Apply(s)
                        state=s; Tween(sw,{BackgroundColor3=s and Theme.Toggle_ON or Theme.Toggle_OFF},0.2); Tween(kn,{Position=s and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.2)
                        if o.Callback then o.Callback(s) end
                    end
                    ca.MouseButton1Click:Connect(function() Apply(not state) end)
                    if o.ConfigKey and ConfigManager then ConfigManager:Register(o.ConfigKey, function() return state end, Apply) end
                    return { SetState = Apply, GetState = function() return state end }
                end)
                return factory(tabFrame, o)
            end

            -- Slider
            function TabAPI:AddSlider(o)
                local factory = useElement("Slider", function(p,o)
                    local min = o.Min or 0; local max = o.Max or 100
                    local value = math.clamp(o.Default or min, min, max)
                    local card = BaseCardTab(60)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(0.7,0,0,18); nL.Text=o.Name or "Slider"; nL.TextColor3=Theme.Text; nL.Font=Enum.Font.GothamBold; nL.TextSize=13; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local vL = Instance.new("TextLabel"); vL.BackgroundTransparency=1; vL.Position=UDim2.new(0.7,0,0,6); vL.Size=UDim2.new(0.28,0,0,18); vL.Text=tostring(value); vL.TextColor3=Theme.Accent; vL.Font=Enum.Font.GothamBold; vL.TextSize=13; vL.TextXAlignment=Enum.TextXAlignment.Right; vL.Parent=card
                    local tr = Instance.new("Frame"); tr.BackgroundColor3=Theme.Slider_BG; tr.Size=UDim2.new(1,-20,0,8); tr.Position=UDim2.new(0,10,0,36); tr.Parent=card; CC(tr,4)
                    local fi = Instance.new("Frame"); fi.BackgroundColor3=Theme.Slider_Fill; fi.Size=UDim2.new((value-min)/(max-min),0,1,0); fi.Parent=tr; CC(fi,4)
                    local drag=false
                    local function upd(pos)
                        local r=math.clamp((pos.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
                        value=math.floor(min+(max-min)*r); vL.Text=tostring(value); fi.Size=UDim2.new(r,0,1,0)
                        if o.Callback then o.Callback(value) end
                    end
                    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i.Position) end end)
                    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position) end end)
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
                    if o.ConfigKey and ConfigManager then ConfigManager:Register(o.ConfigKey, function() return value end, function(v) value=math.clamp(v,min,max); local r=(value-min)/(max-min); fi.Size=UDim2.new(r,0,1,0); vL.Text=tostring(value); if o.Callback then o.Callback(value) end end) end
                    return { GetValue=function() return value end, SetValue=function(v) value=math.clamp(v,min,max); local r=(value-min)/(max-min); fi.Size=UDim2.new(r,0,1,0); vL.Text=tostring(value); if o.Callback then o.Callback(value) end end }
                end)
                return factory(tabFrame, o)
            end

            -- Dropdown
            function TabAPI:AddDropdown(o)
                local factory = useElement("Dropdown", function(p,o)
                    local items = o.Options or {}
                    local selected = o.Default or (items[1] or "")
                    local expanded = false
                    local wrapper = Instance.new("Frame"); wrapper.BackgroundTransparency=1; wrapper.Size=UDim2.new(1,0,0,46); wrapper.ClipsDescendants=false; wrapper.Parent=p
                    local card = Instance.new("Frame"); card.BackgroundColor3=Theme.Secondary; card.Size=UDim2.new(1,0,0,46); card.ClipsDescendants=false; card.Parent=wrapper; CC(card,8); CS(card,Theme.Border)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(0.55,0,0,14); nL.Text=o.Name or "Dropdown"; nL.TextColor3=Theme.SubText; nL.Font=Enum.Font.Gotham; nL.TextSize=11; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local sL = Instance.new("TextLabel"); sL.BackgroundTransparency=1; sL.Position=UDim2.new(0,10,0,22); sL.Size=UDim2.new(0.65,0,0,18); sL.Text=selected; sL.TextColor3=Theme.Text; sL.Font=Enum.Font.GothamBold; sL.TextSize=13; sL.TextXAlignment=Enum.TextXAlignment.Left; sL.Parent=card
                    local ab = Instance.new("TextButton"); ab.BackgroundColor3=Theme.Accent; ab.Size=UDim2.new(0,30,0,30); ab.Position=UDim2.new(1,-40,0.5,-15); ab.Text="▼"; ab.TextColor3=Color3.fromRGB(255,255,255); ab.Font=Enum.Font.GothamBold; ab.TextSize=12; ab.Parent=card; CC(ab,6)
                    local maxH = 150
                    local dl = Instance.new("ScrollingFrame"); dl.BackgroundColor3=Theme.Dropdown_BG; dl.Position=UDim2.new(0,0,1,4); dl.Visible=false; dl.ZIndex=10; dl.Parent=card; dl.ScrollBarThickness=3; dl.ScrollBarImageColor3=Theme.Accent; dl.ScrollingDirection=Enum.ScrollingDirection.Y; dl.CanvasSize=UDim2.new(0,0,0,0); dl.ClipsDescendants=true; CC(dl,8); CS(dl,Theme.Border)
                    local dly = Instance.new("UIListLayout"); dly.Padding=UDim.new(0,2); dly.SortOrder=Enum.SortOrder.LayoutOrder; dly.Parent=dl
                    local dp = Instance.new("UIPadding"); dp.PaddingTop=UDim.new(0,4); dp.PaddingLeft=UDim.new(0,4); dp.PaddingRight=UDim.new(0,4); dp.Parent=dl
                    local function populate()
                        for _,c in ipairs(dl:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                        for _,item in ipairs(items) do
                            local ib = Instance.new("TextButton"); ib.BackgroundColor3=Theme.Secondary; ib.Size=UDim2.new(1,0,0,26); ib.Text=" "..item; ib.TextColor3=Theme.Text; ib.Font=Enum.Font.Gotham; ib.TextSize=12; ib.TextXAlignment=Enum.TextXAlignment.Left; ib.ZIndex=11; ib.Parent=dl; CC(ib,6)
                            ib.MouseButton1Click:Connect(function() selected=item; sL.Text=item; expanded=false; dl.Visible=false; ab.Text="▼"; if o.Callback then o.Callback(item) end end)
                        end
                        local totalH = math.min(#items*30+8, maxH); dl.Size=UDim2.new(1,0,0,totalH); dl.CanvasSize=UDim2.new(0,0,0,#items*30+8)
                    end
                    populate()
                    ab.MouseButton1Click:Connect(function() expanded=not expanded; dl.Visible=expanded; ab.Text=expanded and "▲" or "▼" end)
                    if o.ConfigKey and ConfigManager then ConfigManager:Register(o.ConfigKey, function() return selected end, function(v) selected=v; sL.Text=v; if o.Callback then o.Callback(v) end end) end
                    return { GetValue = function() return selected end, SetOptions = function(newItems) items=newItems; populate() end }
                end)
                return factory(tabFrame, o)
            end

            -- Input
            function TabAPI:AddInput(o)
                local factory = useElement("Input", function(p,o)
                    local card = BaseCardTab(60)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(1,-20,0,16); nL.Text=o.Name or "Input"; nL.TextColor3=Theme.SubText; nL.Font=Enum.Font.Gotham; nL.TextSize=11; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local iBG = Instance.new("Frame"); iBG.BackgroundColor3=Theme.Input_BG; iBG.Size=UDim2.new(1,-20,0,28); iBG.Position=UDim2.new(0,10,0,26); iBG.Parent=card; CC(iBG,6); CS(iBG,Theme.Border)
                    local box = Instance.new("TextBox"); box.BackgroundTransparency=1; box.Size=UDim2.new(1,-10,1,0); box.Position=UDim2.new(0,6,0,0); box.PlaceholderText=o.Placeholder or "พิมพ์ที่นี่..."; box.PlaceholderColor3=Theme.SubText; box.TextColor3=Theme.Text; box.Font=Enum.Font.Gotham; box.TextSize=12; box.TextXAlignment=Enum.TextXAlignment.Left; box.ClearTextOnFocus=false; box.Text=""; box.Parent=iBG
                    box.FocusLost:Connect(function(ep) if ep and o.Callback then o.Callback(box.Text) end end)
                    return { GetValue = function() return box.Text end, SetValue = function(v) box.Text=v end }
                end)
                return factory(tabFrame, o)
            end

            -- ProgressBar
            function TabAPI:AddProgressBar(o)
                local factory = useElement("ProgressBar", function(p,o)
                    local maxValue = o.Max or 100; local valueFunc = o.Value or function() return 0 end
                    local card = BaseCardTab(54)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(0.7,0,0,16); nL.Text=o.Name or "Progress"; nL.TextColor3=Theme.Text; nL.Font=Enum.Font.GothamBold; nL.TextSize=13; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local vL = Instance.new("TextLabel"); vL.BackgroundTransparency=1; vL.Position=UDim2.new(0.7,0,0,6); vL.Size=UDim2.new(0.28,0,0,16); vL.Text="0/"..tostring(maxValue); vL.TextColor3=Theme.Accent; vL.Font=Enum.Font.GothamBold; vL.TextSize=11; vL.TextXAlignment=Enum.TextXAlignment.Right; vL.Parent=card
                    local barBG = Instance.new("Frame"); barBG.BackgroundColor3=Theme.Slider_BG; barBG.Size=UDim2.new(1,-20,0,10); barBG.Position=UDim2.new(0,10,0,30); barBG.Parent=card; CC(barBG,5)
                    local barFill = Instance.new("Frame"); barFill.BackgroundColor3=Theme.Accent; barFill.Size=UDim2.new(0,0,1,0); barFill.Parent=barBG; CC(barFill,5)
                    addUpdater(card, function()
                        local cur = valueFunc(); cur = math.clamp(cur,0,maxValue); local pct = cur/maxValue
                        barFill.Size = UDim2.new(pct,0,1,0); vL.Text = math.floor(cur).."/"..maxValue
                        barFill.BackgroundColor3 = (pct>0.6 and Color3.fromRGB(60,180,100)) or (pct>0.3 and Color3.fromRGB(200,160,40)) or Color3.fromRGB(200,60,60)
                    end)
                    card.Destroying:Connect(function() removeUpdatersForElement(card) end)
                    return {}
                end)
                return factory(tabFrame, o)
            end

            -- Paragraph
            function TabAPI:AddParagraph(o)
                local factory = useElement("Paragraph", function(p,o)
                    local titleText = o.Title or ""; local contentText = o.Content or ""
                    local lines = math.max(1, math.ceil(#contentText/42)); local h = 46 + (lines*16)
                    local card = BaseCardTab(h)
                    local tL = Instance.new("TextLabel"); tL.BackgroundTransparency=1; tL.Position=UDim2.new(0,10,0,8); tL.Size=UDim2.new(1,-20,0,18); tL.Text=titleText; tL.TextColor3=Theme.Text; tL.Font=Enum.Font.GothamBold; tL.TextSize=13; tL.TextXAlignment=Enum.TextXAlignment.Left; tL.Parent=card
                    local sep = Instance.new("Frame"); sep.BackgroundColor3=Theme.Border; sep.Size=UDim2.new(1,-20,0,1); sep.Position=UDim2.new(0,10,0,28); sep.BorderSizePixel=0; sep.Parent=card
                    local cL = Instance.new("TextLabel"); cL.BackgroundTransparency=1; cL.Position=UDim2.new(0,10,0,32); cL.Size=UDim2.new(1,-20,0,h-38); cL.Text=contentText; cL.TextColor3=Theme.SubText; cL.Font=Enum.Font.Gotham; cL.TextSize=12; cL.TextXAlignment=Enum.TextXAlignment.Left; cL.TextWrapped=true; cL.Parent=card
                    return { SetTitle = function(t) tL.Text=t end, SetContent = function(t) cL.Text=t end }
                end)
                return factory(tabFrame, o)
            end

            -- ColorPicker
            function TabAPI:AddColorPicker(o)
                local factory = useElement("ColorPicker", function(p,o)
                    local defaultColor = o.Default or Color3.fromRGB(100,60,200)
                    local rVal, gVal, bVal = math.floor(defaultColor.R*255), math.floor(defaultColor.G*255), math.floor(defaultColor.B*255)
                    local card = BaseCardTab(162)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(0.6,0,0,18); nL.Text=o.Name or "ColorPicker"; nL.TextColor3=Theme.Text; nL.Font=Enum.Font.GothamBold; nL.TextSize=13; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local prev = Instance.new("Frame"); prev.BackgroundColor3=defaultColor; prev.Size=UDim2.new(0,36,0,20); prev.Position=UDim2.new(1,-46,0,6); prev.Parent=card; CC(prev,5); CS(prev,Theme.Border,1)
                    local function updateColor()
                        local c = Color3.fromRGB(rVal,gVal,bVal); prev.BackgroundColor3=c
                        if o.Callback then o.Callback(c) end
                    end
                    local function makeSlider(label,yPos,init,col,onChange)
                        local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,yPos); lbl.Size=UDim2.new(0,14,0,14); lbl.Text=label; lbl.TextColor3=col; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.Parent=card
                        local valLbl = Instance.new("TextLabel"); valLbl.BackgroundTransparency=1; valLbl.Position=UDim2.new(1,-38,0,yPos); valLbl.Size=UDim2.new(0,32,0,14); valLbl.Text=tostring(init); valLbl.TextColor3=Theme.SubText; valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=10; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=card
                        local tr = Instance.new("Frame"); tr.BackgroundColor3=Theme.Slider_BG; tr.Size=UDim2.new(1,-58,0,7); tr.Position=UDim2.new(0,26,0,yPos+4); tr.Parent=card; CC(tr,3)
                        local fi = Instance.new("Frame"); fi.BackgroundColor3=col; fi.Size=UDim2.new(init/255,0,1,0); fi.Parent=tr; CC(fi,3)
                        local drag=false
                        local function upd(pos)
                            local r = math.clamp((pos.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); local v=math.floor(r*255)
                            fi.Size=UDim2.new(r,0,1,0); valLbl.Text=tostring(v); onChange(v); updateColor()
                        end
                        tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i.Position) end end)
                        UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position) end end)
                        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
                    end
                    makeSlider("R",34,rVal,Color3.fromRGB(220,60,60),function(v) rVal=v end)
                    makeSlider("G",60,gVal,Color3.fromRGB(60,200,80),function(v) gVal=v end)
                    makeSlider("B",86,bVal,Color3.fromRGB(60,120,220),function(v) bVal=v end)
                    local hexLabel = Instance.new("TextLabel"); hexLabel.BackgroundTransparency=1; hexLabel.Position=UDim2.new(0,10,0,110); hexLabel.Size=UDim2.new(1,-20,0,16); hexLabel.Text="Color3.fromRGB("..rVal..","..gVal..","..bVal..")"; hexLabel.TextColor3=Theme.SubText; hexLabel.Font=Enum.Font.Code; hexLabel.TextSize=10; hexLabel.TextXAlignment=Enum.TextXAlignment.Left; hexLabel.Parent=card
                    local copyBtn = Instance.new("TextButton"); copyBtn.BackgroundColor3=Theme.Secondary; copyBtn.Size=UDim2.new(1,-20,0,26); copyBtn.Position=UDim2.new(0,10,0,130); copyBtn.Text="📋 Copy Color3"; copyBtn.TextColor3=Theme.Text; copyBtn.Font=Enum.Font.GothamBold; copyBtn.TextSize=11; copyBtn.Parent=card; CC(copyBtn,7); CS(copyBtn,Theme.Border,1)
                    copyBtn.MouseButton1Click:Connect(function() SetClipboard("Color3.fromRGB("..rVal..","..gVal..","..bVal..")"); local old=copyBtn.Text; copyBtn.Text="✅ คัดลอกแล้ว!"; Tween(copyBtn,{BackgroundColor3=Color3.fromRGB(30,80,40)},0.15); task.wait(1.5); copyBtn.Text=old; Tween(copyBtn,{BackgroundColor3=Theme.Secondary},0.15) end)
                    addUpdater(hexLabel, function(lbl) lbl.Text="Color3.fromRGB("..rVal..","..gVal..","..bVal..")" end)
                    hexLabel.Destroying:Connect(function() removeUpdatersForElement(hexLabel) end)
                    return { GetColor = function() return Color3.fromRGB(rVal,gVal,bVal) end }
                end)
                return factory(tabFrame, o)
            end

            -- Keybind
            function TabAPI:AddKeybind(o)
                local factory = useElement("Keybind", function(p,o)
                    local currentKey = o.Default or Enum.KeyCode.F
                    local isListening = false
                    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
                    local card = BaseCardTab(50)
                    local nL = Instance.new("TextLabel"); nL.BackgroundTransparency=1; nL.Position=UDim2.new(0,10,0,6); nL.Size=UDim2.new(0.55,0,0,18); nL.Text=o.Name or "Keybind"; nL.TextColor3=Theme.Text; nL.Font=Enum.Font.GothamBold; nL.TextSize=13; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
                    local dL = Instance.new("TextLabel"); dL.BackgroundTransparency=1; dL.Position=UDim2.new(0,10,0,26); dL.Size=UDim2.new(0.55,0,0,16); dL.Text=o.Description or ""; dL.TextColor3=Theme.SubText; dL.Font=Enum.Font.Gotham; dL.TextSize=10; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.Parent=card
                    local keyBtn = Instance.new("TextButton"); keyBtn.Size=UDim2.new(0,80,0,28); keyBtn.Position=UDim2.new(1,-90,0.5,-14); keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=11; keyBtn.TextColor3=Color3.fromRGB(255,255,255); keyBtn.Parent=card; CC(keyBtn,7)
                    if isMobile then
                        keyBtn.BackgroundColor3=Theme.Accent; keyBtn.Text="▶ กด"
                        keyBtn.MouseButton1Click:Connect(function() Tween(keyBtn,{BackgroundColor3=Theme.AccentHover},0.1); task.wait(0.1); Tween(keyBtn,{BackgroundColor3=Theme.Accent},0.15); if o.Callback then o.Callback() end end)
                    else
                        keyBtn.BackgroundColor3=Color3.fromRGB(40,36,60); keyBtn.Text="["..tostring(currentKey.Name).."]"; CS(keyBtn,Theme.Accent,1.5)
                        local function startListening()
                            if isListening then return end
                            isListening=true; keyBtn.Text="[...]"; keyBtn.BackgroundColor3=Color3.fromRGB(80,40,120)
                            local conn; conn=UserInputService.InputBegan:Connect(function(input,gp) if gp then return end; if input.UserInputType==Enum.UserInputType.Keyboard then currentKey=input.KeyCode; keyBtn.Text="["..tostring(currentKey.Name).."]"; keyBtn.BackgroundColor3=Color3.fromRGB(40,36,60); isListening=false; conn:Disconnect() end end)
                        end
                        keyBtn.MouseButton1Click:Connect(startListening)
                        UserInputService.InputBegan:Connect(function(input,gp) if gp or isListening then return end; if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==currentKey then if o.Callback then o.Callback() end end end)
                    end
                    return { GetKey = function() return currentKey end, SetKey = function(k) currentKey=k; if not isMobile then keyBtn.Text="["..tostring(k.Name).."]" end end }
                end)
                return factory(tabFrame, o)
            end

            -- Card
            function TabAPI:AddCard(o)
                local factory = useElement("Card", function(p,o)
                    local titleText = o.Title or "Card"; local contentText = o.Content or ""; local h = o.Height or 80
                    local card = BaseCardTab(h)
                    local tL = Instance.new("TextLabel"); tL.BackgroundTransparency=1; tL.Position=UDim2.new(0,10,0,8); tL.Size=UDim2.new(1,-20,0,18); tL.Text=titleText; tL.TextColor3=Theme.Text; tL.Font=Enum.Font.GothamBold; tL.TextSize=13; tL.TextXAlignment=Enum.TextXAlignment.Left; tL.Parent=card
                    local sep = Instance.new("Frame"); sep.BackgroundColor3=Theme.Border; sep.Size=UDim2.new(1,-20,0,1); sep.Position=UDim2.new(0,10,0,28); sep.BorderSizePixel=0; sep.Parent=card
                    local cL = Instance.new("TextLabel"); cL.BackgroundTransparency=1; cL.Position=UDim2.new(0,10,0,32); cL.Size=UDim2.new(1,-20,0,h-38); cL.Text=contentText; cL.TextColor3=Theme.SubText; cL.Font=Enum.Font.Gotham; cL.TextSize=12; cL.TextXAlignment=Enum.TextXAlignment.Left; cL.TextWrapped=true; cL.Parent=card
                    return { SetTitle = function(t) tL.Text=t end, SetContent = function(t) cL.Text=t end }
                end)
                return factory(tabFrame, o)
            end

            return TabAPI
        end

        function WindowObj:Notify(opts) Notification:Notify(opts) end
        function WindowObj:Show() Main.Visible=true; Main.Size=UDim2.new(0,500,0,0); Tween(Main,{Size=UDim2.new(0,500,0,350)},0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out); floatBtn.Visible=false; isOpen=true; MinBtn.Text="—" end
        function WindowObj:Hide() Tween(Main,{Size=UDim2.new(0,500,0,0)},0.25); task.delay(0.3,function() Main.Visible=false; floatBtn.Visible=true end) end
        function WindowObj:Toggle() if Main.Visible then WindowObj:Hide() else WindowObj:Show() end end
        function WindowObj:Destroy()
            pcall(function() ScreenGui:Destroy() end)
            pcall(function() floatSG:Destroy() end)
            if Notification then Notification:Clear() end
            updaters = {}
        end

        local function OpenMainUI()
            Main.Visible = true
            Main.Size = UDim2.new(0,500,0,0)
            Tween(Main,{Size=UDim2.new(0,500,0,350)},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            task.wait(0.5)
            Notification:Notify({Title="🌒 "..windowName, Content="โหลดสำเร็จแล้ว! ✨", Duration=3})
        end

        if useKey and KeySystem then
            IntroEngine.PlayIntro(loadTitle, loadSub, function()
                KeySystem.ShowKeySystem(keyOpts, OpenMainUI)
            end)
        else
            IntroEngine.PlayIntro(loadTitle, loadSub, OpenMainUI)
        end

        return WindowObj
    end

    return Window
end
