--[[
    EclipseLib-Nexus Components/BaseCard.lua
    Version: 1.0.0
    หน้าที่: สร้างการ์ดมาตรฐาน (left accent bar) ที่ทุก Element ใช้
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local MobileOptimizer = deps.MobileOptimizer

    local CC = Utils.CC
    local CS = Utils.CS

    -- BaseCard(parent, height) → return Frame
    local function BaseCard(parent, height)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = Theme.Secondary
        card.Size = UDim2.new(1, 0, 0, height)
        card.Parent = parent

        CC(card, 8)

        -- ถ้า MobileOptimizer เปิด → ลดความหนา UIStroke
        local strokeThickness = 1
        if MobileOptimizer and MobileOptimizer.Enabled then
            strokeThickness = 0.5
        end
        CS(card, Theme.Border, strokeThickness)

        -- Left Accent Bar
        local leftBar = Instance.new("Frame")
        leftBar.BackgroundColor3 = Theme.Accent
        leftBar.Size = UDim2.new(0, 3, 1, -16)
        leftBar.Position = UDim2.new(0, 0, 0, 8)
        leftBar.BorderSizePixel = 0
        leftBar.Parent = card
        CC(leftBar, 2)

        -- ถ้า MobileOptimizer ปิด → เพิ่ม UIGradient (ถ้าต้องการ)
        if not (MobileOptimizer and MobileOptimizer.Enabled) then
            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 36, 58)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 30)),
            })
            grad.Rotation = 90
            grad.Parent = card
        end

        return card
    end

    return BaseCard
end
