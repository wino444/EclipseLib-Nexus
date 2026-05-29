--[[
    EclipseLib-Nexus Components/Elements/Input.lua
    หน้าที่: ช่องกรอกข้อความ
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard

    local CC = Utils.CC
    local CS = Utils.CS

    local function AddInput(parent, options)
        options = options or {}
        local card = BaseCard(parent, 60)

        -- ชื่อ
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(1, -20, 0, 16)
        nameLabel.Text = options.Name or "Input"
        nameLabel.TextColor3 = Theme.SubText
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- พื้นหลังช่องกรอก
        local inputBg = Instance.new("Frame")
        inputBg.BackgroundColor3 = Theme.Input_BG
        inputBg.Size = UDim2.new(1, -20, 0, 28)
        inputBg.Position = UDim2.new(0, 10, 0, 26)
        inputBg.Parent = card
        CC(inputBg, 6)
        CS(inputBg, Theme.Border)

        -- TextBox
        local textBox = Instance.new("TextBox")
        textBox.BackgroundTransparency = 1
        textBox.Size = UDim2.new(1, -10, 1, 0)
        textBox.Position = UDim2.new(0, 6, 0, 0)
        textBox.PlaceholderText = options.Placeholder or "พิมพ์ที่นี่..."
        textBox.PlaceholderColor3 = Theme.SubText
        textBox.TextColor3 = Theme.Text
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 12
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.ClearTextOnFocus = false
        textBox.Text = ""
        textBox.Parent = inputBg

        -- Callback เมื่อกด Enter หรือ FocusLost
        textBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and options.Callback then
                options.Callback(textBox.Text)
            end
        end)

        local API = {}
        function API:GetValue()
            return textBox.Text
        end
        function API:SetValue(value)
            textBox.Text = value
        end
        return API
    end

    return AddInput
end
