--[[
    EclipseLib-Nexus Components/Elements/Label.lua
    หน้าที่: ข้อความธรรมดา
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme

    local function AddLabel(parent, options)
        options = options or {}
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 0, 24)
        label.Text = options.Text or ""
        label.TextColor3 = Theme.SubText
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.Parent = parent

        local API = {}
        function API:SetText(text)
            label.Text = text
        end
        return API
    end

    return AddLabel
end
