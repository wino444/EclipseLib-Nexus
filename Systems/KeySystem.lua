--[[
    EclipseLib-Nexus Systems/KeySystem.lua
    Version: 1.0.0
    หน้าที่: UI ใส่ Key, ตรวจสอบ, เข้ารหัสเก็บ Key
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local Services = deps.Services
    local Notification = deps.Notification -- สำหรับแจ้งเตือน (ถ้าต้องการ)

    local Tween = Utils.Tween
    local CC = Utils.CC
    local CS = Utils.CS
    local SetClipboard = Utils.SetClipboard
    local _randomName = Utils._randomName
    local MakeScreenGui = Utils.MakeScreenGui

    local TweenService = Services.TweenService
    local UserInputService = Services.UserInputService

    -- XOR Encrypt/Decrypt สำหรับ Key
    local function encryptKey(str, seed)
        seed = seed or 12345
        local res = ""
        for i = 1, #str do
            local c = str:sub(i, i)
            res = res .. string.char((string.byte(c) + seed + i) % 256)
        end
        return res
    end

    local function decryptKey(enc, seed)
        seed = seed or 12345
        local res = ""
        for i = 1, #enc do
            local c = enc:sub(i, i)
            res = res .. string.char((string.byte(c) - seed - i) % 256)
        end
        return res
    end

    local function ShowKeySystem(opts, onSuccess)
        local keyList = opts.Key or {}
        local keyTitle = opts.KeyTitle or "🔑 ใส่ Key"
        local keyDesc = opts.KeyDescription or "กรอก Key เพื่อใช้งาน"
        local keyLink = opts.KeyLink or ""
        local saveFolder = opts.SaveFolder or "EclipseLib"
        local keyFile = saveFolder .. "/.eclipse_key.dat"

        local function checkSavedKey()
            local ok, saved = pcall(function()
                if not isfolder(saveFolder) then return nil end
                if not isfile(keyFile) then return nil end
                return readfile(keyFile)
            end)
            if not ok or not saved then return false end
            local decrypted = decryptKey(saved)
            for _, k in ipairs(keyList) do
                if k == decrypted then return true end
            end
            pcall(function() delfile(keyFile) end)
            return false
        end

        local function saveKey(key)
            pcall(function()
                if not isfolder(saveFolder) then makefolder(saveFolder) end
                writefile(keyFile, encryptKey(key))
            end)
        end

        if checkSavedKey() then
            onSuccess()
            return
        end

        -- GUI
        local sg = MakeScreenGui(_randomName("eclipse_key_"), 10001)
        local bgO = Instance.new("Frame")
        bgO.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bgO.BackgroundTransparency = 1
        bgO.Size = UDim2.new(1, 0, 1, 0)
        bgO.Parent = sg

        local card = Instance.new("Frame")
        card.BackgroundColor3 = Theme.Background
        card.Size = UDim2.new(0, 320, 0, 300)
        card.Position = UDim2.new(0.5, -160, 0.5, -150)
        card.BackgroundTransparency = 1
        card.Parent = sg
        CC(card, 14)
        CS(card, Theme.Accent, 1.5)

        local gb = Instance.new("Frame")
        gb.BackgroundColor3 = Theme.Accent
        gb.Size = UDim2.new(1, 0, 0, 3)
        gb.BorderSizePixel = 0
        gb.Parent = card

        local iL = Instance.new("TextLabel")
        iL.BackgroundTransparency = 1
        iL.Position = UDim2.new(0, 0, 0, 16)
        iL.Size = UDim2.new(1, 0, 0, 36)
        iL.Text = "🔑"
        iL.TextSize = 28
        iL.Font = Enum.Font.GothamBold
        iL.TextTransparency = 1
        iL.Parent = card

        local tL = Instance.new("TextLabel")
        tL.BackgroundTransparency = 1
        tL.Position = UDim2.new(0, 0, 0, 54)
        tL.Size = UDim2.new(1, 0, 0, 24)
        tL.Text = keyTitle
        tL.TextColor3 = Theme.Text
        tL.TextTransparency = 1
        tL.Font = Enum.Font.GothamBold
        tL.TextSize = 16
        tL.Parent = card

        local dL = Instance.new("TextLabel")
        dL.BackgroundTransparency = 1
        dL.Position = UDim2.new(0, 16, 0, 80)
        dL.Size = UDim2.new(1, -32, 0, 30)
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
        iBG.Size = UDim2.new(1, -32, 0, 36)
        iBG.Position = UDim2.new(0, 16, 0, 118)
        iBG.Parent = card
        CC(iBG, 8)
        CS(iBG, Theme.Border)

        local iBox = Instance.new("TextBox")
        iBox.BackgroundTransparency = 1
        iBox.Size = UDim2.new(1, -12, 1, 0)
        iBox.Position = UDim2.new(0, 8, 0, 0)
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
        stL.Position = UDim2.new(0, 16, 0, 160)
        stL.Size = UDim2.new(1, -32, 0, 16)
        stL.Text = ""
        stL.TextColor3 = Color3.fromRGB(200, 60, 60)
        stL.Font = Enum.Font.Gotham
        stL.TextSize = 11
        stL.Parent = card

        local rememberKey = true
        local remRow = Instance.new("Frame")
        remRow.BackgroundTransparency = 1
        remRow.Size = UDim2.new(1, -32, 0, 24)
        remRow.Position = UDim2.new(0, 16, 0, 182)
        remRow.Parent = card

        local remLbl = Instance.new("TextLabel")
        remLbl.BackgroundTransparency = 1
        remLbl.Size = UDim2.new(1, -46, 1, 0)
        remLbl.Text = "💾 จำ Key ไว้ (ไม่ต้องใส่ทุกครั้ง)"
        remLbl.TextColor3 = Theme.SubText
        remLbl.Font = Enum.Font.Gotham
        remLbl.TextSize = 10
        remLbl.TextXAlignment = Enum.TextXAlignment.Left
        remLbl.Parent = remRow

        local remBG = Instance.new("Frame")
        remBG.BackgroundColor3 = Theme.Toggle_ON
        remBG.Size = UDim2.new(0, 36, 0, 20)
        remBG.Position = UDim2.new(1, -38, 0.5, -10)
        remBG.Parent = remRow
        CC(remBG, 10)

        local remKnob = Instance.new("Frame")
        remKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        remKnob.Size = UDim2.new(0, 14, 0, 14)
        remKnob.Position = UDim2.new(1, -17, 0.5, -7)
        remKnob.Parent = remBG
        CC(remKnob, 7)

        local remBtn = Instance.new("TextButton")
        remBtn.BackgroundTransparency = 1
        remBtn.Size = UDim2.new(1, 0, 1, 0)
        remBtn.Text = ""
        remBtn.Parent = remRow

        remBtn.MouseButton1Click:Connect(function()
            rememberKey = not rememberKey
            Tween(remBG, { BackgroundColor3 = rememberKey and Theme.Toggle_ON or Theme.Toggle_OFF }, 0.2)
            Tween(remKnob, { Position = rememberKey and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.2)
        end)

        local glB = Instance.new("TextButton")
        glB.BackgroundColor3 = Theme.Secondary
        glB.BackgroundTransparency = 1
        glB.Size = UDim2.new(0, 120, 0, 34)
        glB.Position = UDim2.new(0, 16, 0, 214)
        glB.Text = "🔗 Get Key"
        glB.TextColor3 = Theme.Accent
        glB.TextTransparency = 1
        glB.Font = Enum.Font.GothamBold
        glB.TextSize = 12
        glB.Parent = card
        CC(glB, 8)
        CS(glB, Theme.Accent, 1)

        local suB = Instance.new("TextButton")
        suB.BackgroundColor3 = Theme.Accent
        suB.BackgroundTransparency = 1
        suB.Size = UDim2.new(0, 130, 0, 34)
        suB.Position = UDim2.new(1, -146, 0, 214)
        suB.Text = "✅ ยืนยัน Key"
        suB.TextColor3 = Color3.fromRGB(255, 255, 255)
        suB.TextTransparency = 1
        suB.Font = Enum.Font.GothamBold
        suB.TextSize = 12
        suB.Parent = card
        CC(suB, 8)

        -- Animations
        task.spawn(function()
            Tween(bgO, { BackgroundTransparency = 0.5 }, 0.3)
            Tween(card, { BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(0.15)
            for _, o in ipairs({ iL, tL, dL, glB, suB }) do
                Tween(o, { TextTransparency = 0 }, 0.3)
                pcall(function() Tween(o, { BackgroundTransparency = 0 }, 0.3) end)
                task.wait(0.05)
            end
            Tween(iBG, { BackgroundTransparency = 0 }, 0.3)
            Tween(iBox, { TextTransparency = 0 }, 0.3)
        end)

        glB.MouseButton1Click:Connect(function()
            SetClipboard(keyLink)
            local old = glB.Text
            glB.Text = "✅ คัดลอกแล้ว!"
            Tween(glB, { BackgroundColor3 = Color3.fromRGB(30, 80, 40) }, 0.2)
            task.wait(2)
            glB.Text = old
            Tween(glB, { BackgroundColor3 = Theme.Secondary }, 0.2)
        end)

        suB.MouseButton1Click:Connect(function()
            local entered = iBox.Text
            local valid = false
            for _, k in ipairs(keyList) do
                if k == entered then valid = true; break end
            end
            if valid then
                if rememberKey then saveKey(entered) end
                stL.TextColor3 = Color3.fromRGB(60, 200, 100)
                stL.Text = rememberKey and "✅ Key ถูกต้อง! จำไว้แล้ว 💾" or "✅ Key ถูกต้อง!"
                task.wait(0.5)
                for i = 1, 3 do
                    Tween(bgO, { BackgroundTransparency = i % 2 == 0 and 0.5 or 0.1 }, 0.06)
                    task.wait(0.06)
                end
                Tween(card, { BackgroundTransparency = 1, Size = UDim2.new(0, 320, 0, 0) }, 0.25)
                Tween(bgO, { BackgroundTransparency = 1 }, 0.3)
                task.wait(0.35)
                sg:Destroy()
                onSuccess()
            else
                stL.TextColor3 = Color3.fromRGB(200, 60, 60)
                stL.Text = "❌ Key ไม่ถูกต้อง ลองใหม่!"
                Tween(iBG, { BackgroundColor3 = Color3.fromRGB(60, 20, 20) }, 0.12)
                local op = iBG.Position
                for i = 1, 4 do
                    Tween(iBG, { Position = UDim2.new(op.X.Scale, op.X.Offset + (i % 2 == 0 and 6 or -6), op.Y.Scale, op.Y.Offset) }, 0.05)
                    task.wait(0.05)
                end
                Tween(iBG, { Position = op, BackgroundColor3 = Theme.Input_BG }, 0.1)
            end
        end)
    end

    return { ShowKeySystem = ShowKeySystem }
end
