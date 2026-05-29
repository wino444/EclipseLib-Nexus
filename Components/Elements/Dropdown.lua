--[[
    EclipseLib-Nexus Components/Elements/Dropdown.lua
    หน้าที่: รายการเลือก (ConfigKey + RealtimeValue)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local ConfigManager = deps.ConfigManager
    local MemoryGuard = deps.MemoryGuard

    local CC = Utils.CC
    local CS = Utils.CS
    local Tween = Utils.Tween

    local function AddDropdown(parent, options)
        options = options or {}
        local items = options.Options or {}
        local selected = options.Default or (items[1] or "")
        local expanded = false

        -- Wrapper (เพื่อให้ dropdown list ล้นออกมาได้)
        local wrapper = Instance.new("Frame")
        wrapper.BackgroundTransparency = 1
        wrapper.Size = UDim2.new(1, 0, 0, 46)
        wrapper.ClipsDescendants = false
        wrapper.Parent = parent

        -- Card
        local card = Instance.new("Frame")
        card.BackgroundColor3 = Theme.Secondary
        card.Size = UDim2.new(1, 0, 0, 46)
        card.ClipsDescendants = false
        card.Parent = wrapper
        CC(card, 8)
        CS(card, Theme.Border)

        -- ชื่อ
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.55, 0, 0, 14)
        nameLabel.Text = options.Name or "Dropdown"
        nameLabel.TextColor3 = Theme.SubText
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- ค่าที่เลือก
        local selectedLabel = Instance.new("TextLabel")
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.Position = UDim2.new(0, 10, 0, 22)
        selectedLabel.Size = UDim2.new(0.65, 0, 0, 18)
        selectedLabel.Text = selected
        selectedLabel.TextColor3 = Theme.Text
        selectedLabel.Font = Enum.Font.GothamBold
        selectedLabel.TextSize = 13
        selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
        selectedLabel.Parent = card

        -- RealtimeValue (ถ้ามี)
        if options.RealtimeValue then
            local realtimeLabel = Instance.new("TextLabel")
            realtimeLabel.BackgroundTransparency = 1
            realtimeLabel.Position = UDim2.new(0.6, 0, 0, 22)
            realtimeLabel.Size = UDim2.new(0.2, 0, 0, 18)
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

        -- ปุ่มเปิด/ปิด
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.BackgroundColor3 = Theme.Accent
        toggleBtn.Size = UDim2.new(0, 30, 0, 30)
        toggleBtn.Position = UDim2.new(1, -40, 0.5, -15)
        toggleBtn.Text = "▼"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 12
        toggleBtn.Parent = card
        CC(toggleBtn, 6)

        -- List
        local maxHeight = 150
        local listFrame = Instance.new("ScrollingFrame")
        listFrame.BackgroundColor3 = Theme.Dropdown_BG
        listFrame.Position = UDim2.new(0, 0, 1, 4)
        listFrame.Visible = false
        listFrame.ZIndex = 10
        listFrame.Parent = card
        listFrame.ScrollBarThickness = 3
        listFrame.ScrollBarImageColor3 = Theme.Accent
        listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        listFrame.ClipsDescendants = true
        CC(listFrame, 8)
        CS(listFrame, Theme.Border)

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = listFrame

        local listPadding = Instance.new("UIPadding")
        listPadding.PaddingTop = UDim.new(0, 4)
        listPadding.PaddingLeft = UDim.new(0, 4)
        listPadding.PaddingRight = UDim.new(0, 4)
        listPadding.Parent = listFrame

        -- ฟังก์ชันเติมรายการ
        local function populateList()
            -- ลบของเก่า
            for _, child in ipairs(listFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, item in ipairs(items) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.BackgroundColor3 = Theme.Secondary
                itemBtn.Size = UDim2.new(1, 0, 0, 26)
                itemBtn.Text = " " .. item
                itemBtn.TextColor3 = Theme.Text
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.TextSize = 12
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                itemBtn.ZIndex = 11
                itemBtn.Parent = listFrame
                CC(itemBtn, 6)

                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    selectedLabel.Text = item
                    expanded = false
                    listFrame.Visible = false
                    toggleBtn.Text = "▼"
                    if options.Callback then options.Callback(item) end
                end)
            end
            local totalH = math.min(#items * 30 + 8, maxHeight)
            listFrame.Size = UDim2.new(1, 0, 0, totalH)
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 30 + 8)
        end

        populateList()

        toggleBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            listFrame.Visible = expanded
            toggleBtn.Text = expanded and "▲" or "▼"
        end)

        -- ConfigKey
        if options.ConfigKey and ConfigManager then
            ConfigManager:Register(options.ConfigKey, function() return selected end, function(v)
                selected = v
                selectedLabel.Text = v
                if options.Callback then options.Callback(v) end
            end)
        end

        -- API
        local API = {}
        function API:GetValue() return selected end
        function API:SetOptions(newOptions)
            items = newOptions
            populateList()
        end
        return API
    end

    return AddDropdown
end
