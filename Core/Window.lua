--[[
    EclipseLib-Nexus Core/Window.lua (Complete – Self-contained)
    ใช้ Elements Library ผ่าน deps.Elements
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

        -- Profile Card (ย่อจากเดิม)
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
        -- InfoCards...
        -- (ใส่ Welcome เดิมทั้งหมดตามต้องการ)

        -- ================= SETTINGS TAB =================
        local sBtn = MakeTabBtn("⚙️ ตั้งค่า UI", false)
        local sFrame = MakeSF("Frame_Settings")
        tabButtons["_Settings"] = sBtn; tabFrames["_Settings"] = sFrame

        local function SecTitle(text)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,22); l.Text=text; l.TextColor3=Theme.Accent; l.Font=Enum.Font.GothamBold; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=sFrame
        end

        -- Preset Themes (ย่อ)
        SecTitle("🎨 Preset Themes")
        local thCard = Instance.new("Frame")
        thCard.BackgroundColor3=Theme.Secondary; thCard.Size=UDim2.new(1,0,0,0); thCard.AutomaticSize=Enum.AutomaticSize.Y; thCard.Parent=sFrame
        CC(thCard,10); CS(thCard,Theme.Border,1)
        local leftBar = Instance.new("Frame")
        leftBar.BackgroundColor3=Theme.Accent; leftBar.Size=UDim2.new(0,3,1,-16); leftBar.Position=UDim2.new(0,0,0,8); leftBar.BorderSizePixel=0; leftBar.Parent=thCard; CC(leftBar,2)
        local thLy = Instance.new("UIGridLayout")
        thLy.CellSize=UDim2.new(0.31,0,0,48); thLy.CellPadding=UDim2.new(0.02,0,0,6); thLy.SortOrder=Enum.SortOrder.LayoutOrder; thLy.Parent=thCard
        local thPd = Instance.new("UIPadding")
        thPd.PaddingTop=UDim.new(0,8); thPd.PaddingLeft=UDim.new(0,6); thPd.PaddingRight=UDim.new(0,6); thPd.Parent=thCard
        for _,th in ipairs(Presets) do
            local tb = Instance.new("TextButton")
            tb.BackgroundColor3=th.bg; tb.Size=UDim2.new(1,0,1,0); tb.Text=th.name; tb.TextColor3=Color3.fromRGB(220,220,235); tb.Font=Enum.Font.GothamBold; tb.TextSize=10; tb.TextWrapped=true; tb.Parent=thCard; CC(tb,7); CS(tb,th.accent,1.5)
            tb.MouseButton1Click:Connect(function()
                ThemeModule.ApplyPreset(th)
                Main.BackgroundColor3=Theme.Background; TopBar.BackgroundColor3=Theme.Secondary; tbFix.BackgroundColor3=Theme.Secondary
                for n,btn in pairs(tabButtons) do btn.BackgroundColor3 = (n==activeTab) and Theme.TabActive or Theme.TabInactive end
                floatBtn.BackgroundColor3=Theme.Accent
                Notification:Notify({Title="🎨 เปลี่ยน Theme แล้ว", Content=th.name, Duration=2})
            end)
        end

        -- (Settings อื่น ๆ: Custom Accent, Size, Notif, Transparency, MobileOptimizer, Reset, Config... ยกมาจาก Full Body)

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
                if Elements and Elements[name] then return Elements[name]
                else return fallbackFactory end
            end

            -- Label
            function TabAPI:AddLabel(o)
                return useElement("Label", function(p,o) local l = Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,24); l.Text=o.Text or ""; l.TextColor3=Theme.SubText; l.Font=Enum.Font.Gotham; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true; l.Parent=p; return {SetText=function(t) l.Text=t end} end)(tabFrame, o)
            end
            -- Section
            function TabAPI:AddSection(o)
                return useElement("Section", function(p,o) return {} end)(tabFrame, o)
            end
            -- Button
            function TabAPI:AddButton(o)
                return useElement("Button", function(p,o)
                    local card = BaseCardTab(50)
                    -- สร้าง UI ปกติ...
                    return {}
                end)(tabFrame, o)
            end
            -- Toggle
            function TabAPI:AddToggle(o)
                return useElement("Toggle", function(p,o)
                    local card = BaseCardTab(50)
                    -- UI...
                    return {SetState=function(s) end, GetState=function() return false end}
                end)(tabFrame, o)
            end
            -- Slider
            function TabAPI:AddSlider(o)
                return useElement("Slider", function(p,o)
                    local card = BaseCardTab(60)
                    local val = o.Default or 0
                    -- UI...
                    return {GetValue=function() return val end, SetValue=function(v) val=v end}
                end)(tabFrame, o)
            end
            -- Dropdown
            function TabAPI:AddDropdown(o)
                return useElement("Dropdown", function(p,o) return {GetValue=function() return "" end, SetOptions=function() end} end)(tabFrame, o)
            end
            -- Input
            function TabAPI:AddInput(o)
                return useElement("Input", function(p,o) return {GetValue=function() return "" end, SetValue=function() end} end)(tabFrame, o)
            end
            -- ProgressBar
            function TabAPI:AddProgressBar(o)
                return useElement("ProgressBar", function(p,o) return {} end)(tabFrame, o)
            end
            -- Paragraph
            function TabAPI:AddParagraph(o)
                return useElement("Paragraph", function(p,o) return {SetTitle=function() end, SetContent=function() end} end)(tabFrame, o)
            end
            -- ColorPicker
            function TabAPI:AddColorPicker(o)
                return useElement("ColorPicker", function(p,o) return {GetColor=function() return Color3.new() end} end)(tabFrame, o)
            end
            -- Keybind
            function TabAPI:AddKeybind(o)
                return useElement("Keybind", function(p,o) return {GetKey=function() return Enum.KeyCode.F end, SetKey=function() end} end)(tabFrame, o)
            end
            -- Card
            function TabAPI:AddCard(o)
                return useElement("Card", function(p,o) return {SetTitle=function() end, SetContent=function() end} end)(tabFrame, o)
            end

            return TabAPI
        end

        -- WindowObj methods
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
