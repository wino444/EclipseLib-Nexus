--[[
    EclipseLib-Nexus Components/Elements/Paragraph.lua
    หน้าที่: ข้อความยาวหลายบรรทัด
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard

    local function AddParagraph(parent, options)
        options = options or {}
        local titleText = options.Title or ""
        local contentText = options.Content or ""
        local lines = math.max(1, math.ceil(#contentText / 42))
        local height = 46 + (lines * 16)
        local card = BaseCard(parent, height)

        -- หัวข้อ
        local titleLabel = Instance.new("TextLabel")
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.new(0, 10, 0, 8)
        titleLabel.Size = UDim2.new(1, -20, 0, 18)
        titleLabel.Text = titleText
        titleLabel.TextColor3 = Theme.Text
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 13
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = card

        -- เส้นคั่น
        local sep = Instance.new("Frame")
        sep.BackgroundColor3 = Theme.Border
        sep.Size = UDim2.new(1, -20, 0, 1)
        sep.Position = UDim2.new(0, 10, 0, 28)
        sep.BorderSizePixel = 0
        sep.Parent = card

        -- เนื้อหา
        local contentLabel = Instance.new("TextLabel")
        contentLabel.BackgroundTransparency = 1
        contentLabel.Position = UDim2.new(0, 10, 0, 32)
        contentLabel.Size = UDim2.new(1, -20, 0, height - 38)
        contentLabel.Text = contentText
        contentLabel.TextColor3 = Theme.SubText
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.TextSize = 12
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextWrapped = true
        contentLabel.Parent = card

        local API = {}
        function API:SetTitle(t)
            titleLabel.Text = t
        end
        function API:SetContent(t)
            contentLabel.Text = t
            -- recalculate height? (optional)
        end
        return API
    end

    return AddParagraph
end
