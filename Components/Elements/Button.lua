--[[
    EclipseLib-Nexus Components/Elements/Button.lua
    หน้าที่: ปุ่มกด (Callback + RealtimeValue)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local MemoryGuard = deps.MemoryGuard

    local CC = Utils.CC
    local Tween = Utils.Tween

    local function AddButton(parent, options)
        options = options or {}
        local card = BaseCard(parent, 50)

        -- ชื่อปุ่ม
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.6, 0, 0, 18)
        nameLabel.Text = options.Name or "Button"
        nameLabel.TextColor3 = Theme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- คำอธิบาย
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 10, 0, 26)
        descLabel.Size = UDim2.new(0.6, 0, 0, 16)
        descLabel.Text = options.Description or ""
        descLabel.TextColor3 = Theme.SubText
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 10
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = card

        -- RealtimeValue (ถ้ามี)
        if options.RealtimeValue then
            local realtimeLabel = Instance.new("TextLabel")
            realtimeLabel.BackgroundTransparency = 1
            realtimeLabel.Position = UDim2.new(0.58, 0, 0, 6)
            realtimeLabel.Size = UDim2.new(0.24, 0, 0, 18)
            realtimeLabel.Text = tostring(options.RealtimeValue())
            realtimeLabel.TextColor3 = Theme.Accent
            realtimeLabel.Font = Enum.Font.GothamBold
            realtimeLabel.TextSize = 11
            realtimeLabel.TextXAlignment = Enum.TextXAlignment.Right
            realtimeLabel.Parent = card

            if MemoryGuard then
                MemoryGuard:Register(realtimeLabel, function(lbl)
                    lbl.Text = tostring(options.RealtimeValue())
                end)
            end
        end

        -- ปุ่ม RUN
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
            if options.Callback then options.Callback() end
        end)

        -- ไม่มี API พิเศษ (callback ทำงานทันที)
        return {}
    end

    return AddButton
end
