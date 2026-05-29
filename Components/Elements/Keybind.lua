--[[
    EclipseLib-Nexus Components/Elements/Keybind.lua
    หน้าที่: ปุ่มลัด (รองรับมือถือ)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local Services = deps.Services

    local CC = Utils.CC
    local CS = Utils.CS
    local Tween = Utils.Tween
    local UserInputService = Services.UserInputService

    local function AddKeybind(parent, options)
        options = options or {}
        local currentKey = options.Default or Enum.KeyCode.F
        local isListening = false
        local isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
        local card = BaseCard(parent, 50)

        -- ชื่อ
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.55, 0, 0, 18)
        nameLabel.Text = options.Name or "Keybind"
        nameLabel.TextColor3 = Theme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- คำอธิบาย
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 10, 0, 26)
        descLabel.Size = UDim2.new(0.55, 0, 0, 16)
        descLabel.Text = options.Description or ""
        descLabel.TextColor3 = Theme.SubText
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 10
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = card

        -- ปุ่มแสดง Key
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
                if options.Callback then options.Callback() end
            end)
        else
            keyBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
            keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
            CS(keyBtn, Theme.Accent, 1.5)

            local function startListening()
                if isListening then return end
                isListening = true
                keyBtn.Text = "[...]"
                keyBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
                local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
                        keyBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
                        isListening = false
                        conn:Disconnect()
                    end
                end)
            end

            keyBtn.MouseButton1Click:Connect(startListening)

            -- ตรวจจับการกดคีย์เพื่อเรียก callback
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed or isListening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    if options.Callback then options.Callback() end
                end
            end)
        end

        local API = {}
        function API:GetKey() return currentKey end
        function API:SetKey(key)
            currentKey = key
            if not isMobile then
                keyBtn.Text = "[" .. tostring(key.Name) .. "]"
            end
        end
        return API
    end

    return AddKeybind
end
