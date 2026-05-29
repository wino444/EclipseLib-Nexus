--[[
    EclipseLib-Nexus Components/Elements/ProgressBar.lua
    หน้าที่: แถบความคืบหน้า (อัปเดตอัตโนมัติผ่าน MemoryGuard)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local MemoryGuard = deps.MemoryGuard

    local CC = Utils.CC

    local function AddProgressBar(parent, options)
        options = options or {}
        local maxValue = options.Max or 100
        local valueFunc = options.Value or function() return 0 end
        local card = BaseCard(parent, 54)

        -- ชื่อ
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.7, 0, 0, 16)
        nameLabel.Text = options.Name or "Progress"
        nameLabel.TextColor3 = Theme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- ป้ายค่า
        local valueLabel = Instance.new("TextLabel")
        valueLabel.BackgroundTransparency = 1
        valueLabel.Position = UDim2.new(0.7, 0, 0, 6)
        valueLabel.Size = UDim2.new(0.28, 0, 0, 16)
        valueLabel.Text = "0/" .. tostring(maxValue)
        valueLabel.TextColor3 = Theme.Accent
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 11
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = card

        -- Track
        local barBg = Instance.new("Frame")
        barBg.BackgroundColor3 = Theme.Slider_BG
        barBg.Size = UDim2.new(1, -20, 0, 10)
        barBg.Position = UDim2.new(0, 10, 0, 30)
        barBg.Parent = card
        CC(barBg, 5)

        -- Fill
        local barFill = Instance.new("Frame")
        barFill.BackgroundColor3 = Theme.Accent
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.Parent = barBg
        CC(barFill, 5)

        -- Updater
        if MemoryGuard then
            MemoryGuard:Register(card, function()
                local cur = valueFunc()
                cur = math.clamp(cur, 0, maxValue)
                local pct = cur / maxValue
                barFill.Size = UDim2.new(pct, 0, 1, 0)
                valueLabel.Text = math.floor(cur) .. "/" .. maxValue
                barFill.BackgroundColor3 = (pct > 0.6 and Color3.fromRGB(60, 180, 100))
                    or (pct > 0.3 and Color3.fromRGB(200, 160, 40))
                    or Color3.fromRGB(200, 60, 60)
            end)
        end

        return {}
    end

    return AddProgressBar
end
