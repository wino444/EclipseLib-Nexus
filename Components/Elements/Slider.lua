--[[
    EclipseLib-Nexus Components/Elements/Slider.lua
    หน้าที่: ตัวเลื่อน (ConfigKey)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local ConfigManager = deps.ConfigManager
    local Services = deps.Services

    local CC = Utils.CC
    local UserInputService = Services.UserInputService

    local function AddSlider(parent, options)
        options = options or {}
        local min = options.Min or 0
        local max = options.Max or 100
        local value = math.clamp(options.Default or min, min, max)
        local card = BaseCard(parent, 60)

        -- ชื่อ
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.7, 0, 0, 18)
        nameLabel.Text = options.Name or "Slider"
        nameLabel.TextColor3 = Theme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- ค่าปัจจุบัน
        local valueLabel = Instance.new("TextLabel")
        valueLabel.BackgroundTransparency = 1
        valueLabel.Position = UDim2.new(0.7, 0, 0, 6)
        valueLabel.Size = UDim2.new(0.28, 0, 0, 18)
        valueLabel.Text = tostring(value)
        valueLabel.TextColor3 = Theme.Accent
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 13
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = card

        -- Track
        local track = Instance.new("Frame")
        track.BackgroundColor3 = Theme.Slider_BG
        track.Size = UDim2.new(1, -20, 0, 8)
        track.Position = UDim2.new(0, 10, 0, 36)
        track.Parent = card
        CC(track, 4)

        -- Fill
        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Theme.Slider_Fill
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        fill.Parent = track
        CC(fill, 4)

        -- การลาก
        local dragging = false
        local function updateFromPosition(inputPosition)
            local relX = inputPosition.X - track.AbsolutePosition.X
            local ratio = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            local newVal = math.floor(min + (max - min) * ratio)
            value = newVal
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            if options.Callback then options.Callback(value) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromPosition(input.Position)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromPosition(input.Position)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        -- ConfigKey
        if options.ConfigKey and ConfigManager then
            ConfigManager:Register(options.ConfigKey, function() return value end, function(v)
                value = math.clamp(v, min, max)
                local ratio = (value - min) / (max - min)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                valueLabel.Text = tostring(value)
                if options.Callback then options.Callback(value) end
            end)
        end

        -- API
        local API = {}
        function API:GetValue() return value end
        function API:SetValue(v)
            value = math.clamp(v, min, max)
            local ratio = (value - min) / (max - min)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if options.Callback then options.Callback(value) end
        end
        return API
    end

    return AddSlider
end
