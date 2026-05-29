--[[
    EclipseLib-Nexus Components/Elements/Section.lua
    หน้าที่: หัวข้อคั่น (เส้น + ชื่อ)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme

    local function AddSection(parent, options)
        options = options or {}
        local sectionFrame = Instance.new("Frame")
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.Size = UDim2.new(1, 0, 0, 28)
        sectionFrame.Parent = parent

        -- เส้น
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Theme.Border
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.BorderSizePixel = 0
        line.Parent = sectionFrame

        -- พื้นหลังข้อความ
        local bg = Instance.new("Frame")
        bg.BackgroundColor3 = Theme.Background
        bg.AutomaticSize = Enum.AutomaticSize.X
        bg.Size = UDim2.new(0, 0, 1, 0)
        bg.Parent = sectionFrame

        -- ข้อความ
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.AutomaticSize = Enum.AutomaticSize.X
        label.Size = UDim2.new(0, 0, 1, 0)
        label.Text = " " .. (options.Name or "Section") .. " "
        label.TextColor3 = Theme.Accent
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.Parent = bg

        -- ไม่มี API (static)
        return {}
    end

    return AddSection
end
