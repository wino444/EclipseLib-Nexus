--[[
    EclipseLib-Nexus Components/Elements/Toggle.lua
    หน้าที่: สวิทช์เปิด/ปิด (ConfigKey)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local ConfigManager = deps.ConfigManager

    local CC = Utils.CC
    local Tween = Utils.Tween

    local function AddToggle(parent, options)
        options = options or {}
        local state = options.Default or false
        local card = BaseCard(parent, 50)

        -- ชื่อ
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.7, 0, 0, 18)
        nameLabel.Text = options.Name or "Toggle"
        nameLabel.TextColor3 = Theme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- คำอธิบาย
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 10, 0, 26)
        descLabel.Size = UDim2.new(0.7, 0, 0, 16)
        descLabel.Text = options.Description or ""
        descLabel.TextColor3 = Theme.SubText
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 10
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = card

        -- Switch background
        local switchBg = Instance.new("Frame")
        switchBg.BackgroundColor3 = state and Theme.Toggle_ON or Theme.Toggle_OFF
        switchBg.Size = UDim2.new(0, 44, 0, 24)
        switchBg.Position = UDim2.new(1, -54, 0.5, -12)
        switchBg.Parent = card
        CC(switchBg, 12)

        -- Switch knob
        local knob = Instance.new("Frame")
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        knob.Parent = switchBg
        CC(knob, 9)

        -- ปุ่มโปร่งใสคลิกได้
        local clickBtn = Instance.new("TextButton")
        clickBtn.BackgroundTransparency = 1
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.Text = ""
        clickBtn.Parent = card

        -- ฟังก์ชัน Apply
        local function Apply(newState)
            state = newState
            Tween(switchBg, { BackgroundColor3 = state and Theme.Toggle_ON or Theme.Toggle_OFF }, 0.2)
            Tween(knob, { Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.2)
            if options.Callback then options.Callback(state) end
        end

        clickBtn.MouseButton1Click:Connect(function()
            Apply(not state)
        end)

        -- ConfigKey
        if options.ConfigKey and ConfigManager then
            ConfigManager:Register(options.ConfigKey, function() return state end, Apply)
        end

        -- API
        local API = {}
        function API:SetState(s) Apply(s) end
        function API:GetState() return state end
        return API
    end

    return AddToggle
end
