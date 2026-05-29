--[[
    EclipseLib-Nexus Components/Elements.lua
    ห้องสมุด Elements ครบทั้ง 12 ฟังก์ชัน
    รับ deps แล้วคืนตาราง factory functions
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local ConfigManager = deps.ConfigManager
    local MemoryGuard = deps.MemoryGuard
    local Services = deps.Services

    local CC = Utils.CC
    local CS = Utils.CS
    local Tween = Utils.Tween
    local SetClipboard = Utils.SetClipboard
    local UserInputService = Services.UserInputService

    local Elements = {}

    -- ❶ Label
    Elements.Label = function(parent, options)
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

        return {
            SetText = function(t) label.Text = t end
        }
    end

    -- ❷ Section
    Elements.Section = function(parent, options)
        options = options or {}
        local sectionFrame = Instance.new("Frame")
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.Size = UDim2.new(1, 0, 0, 28)
        sectionFrame.Parent = parent

        local line = Instance.new("Frame")
        line.BackgroundColor3 = Theme.Border
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.BorderSizePixel = 0
        line.Parent = sectionFrame

        local bg = Instance.new("Frame")
        bg.BackgroundColor3 = Theme.Background
        bg.AutomaticSize = Enum.AutomaticSize.X
        bg.Size = UDim2.new(0, 0, 1, 0)
        bg.Parent = sectionFrame

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.AutomaticSize = Enum.AutomaticSize.X
        label.Size = UDim2.new(0, 0, 1, 0)
        label.Text = " " .. (options.Name or "Section") .. " "
        label.TextColor3 = Theme.Accent
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.Parent = bg

        return {}
    end

    -- ❸ Button
    Elements.Button = function(parent, options)
        options = options or {}
        local card = BaseCard(parent, 50)

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

        return {}
    end

    -- ❹ Toggle
    Elements.Toggle = function(parent, options)
        options = options or {}
        local state = options.Default or false
        local card = BaseCard(parent, 50)

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

        local switchBg = Instance.new("Frame")
        switchBg.BackgroundColor3 = state and Theme.Toggle_ON or Theme.Toggle_OFF
        switchBg.Size = UDim2.new(0, 44, 0, 24)
        switchBg.Position = UDim2.new(1, -54, 0.5, -12)
        switchBg.Parent = card
        CC(switchBg, 12)

        local knob = Instance.new("Frame")
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        knob.Parent = switchBg
        CC(knob, 9)

        local clickBtn = Instance.new("TextButton")
        clickBtn.BackgroundTransparency = 1
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.Text = ""
        clickBtn.Parent = card

        local function Apply(s)
            state = s
            Tween(switchBg, { BackgroundColor3 = s and Theme.Toggle_ON or Theme.Toggle_OFF }, 0.2)
            Tween(knob, { Position = s and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.2)
            if options.Callback then options.Callback(s) end
        end

        clickBtn.MouseButton1Click:Connect(function() Apply(not state) end)

        if options.ConfigKey and ConfigManager then
            ConfigManager:Register(options.ConfigKey, function() return state end, Apply)
        end

        return {
            SetState = Apply,
            GetState = function() return state end
        }
    end

    -- ❺ Slider
    Elements.Slider = function(parent, options)
        options = options or {}
        local min = options.Min or 0
        local max = options.Max or 100
        local value = math.clamp(options.Default or min, min, max)
        local card = BaseCard(parent, 60)

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

        local track = Instance.new("Frame")
        track.BackgroundColor3 = Theme.Slider_BG
        track.Size = UDim2.new(1, -20, 0, 8)
        track.Position = UDim2.new(0, 10, 0, 36)
        track.Parent = card
        CC(track, 4)

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Theme.Slider_Fill
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        fill.Parent = track
        CC(fill, 4)

        local dragging = false
        local function upd(pos)
            local relX = pos.X - track.AbsolutePosition.X
            local ratio = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * ratio)
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            if options.Callback then options.Callback(value) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                upd(input.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                upd(input.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        if options.ConfigKey and ConfigManager then
            ConfigManager:Register(options.ConfigKey, function() return value end, function(v)
                value = math.clamp(v, min, max)
                local ratio = (value - min) / (max - min)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                valueLabel.Text = tostring(value)
                if options.Callback then options.Callback(value) end
            end)
        end

        return {
            GetValue = function() return value end,
            SetValue = function(v)
                value = math.clamp(v, min, max)
                local ratio = (value - min) / (max - min)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                valueLabel.Text = tostring(value)
                if options.Callback then options.Callback(value) end
            end
        }
    end

    -- ❻ Dropdown
    Elements.Dropdown = function(parent, options)
        options = options or {}
        local items = options.Options or {}
        local selected = options.Default or (items[1] or "")
        local expanded = false

        local wrapper = Instance.new("Frame")
        wrapper.BackgroundTransparency = 1
        wrapper.Size = UDim2.new(1, 0, 0, 46)
        wrapper.ClipsDescendants = false
        wrapper.Parent = parent

        local card = Instance.new("Frame")
        card.BackgroundColor3 = Theme.Secondary
        card.Size = UDim2.new(1, 0, 0, 46)
        card.ClipsDescendants = false
        card.Parent = wrapper
        CC(card, 8)
        CS(card, Theme.Border)

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
                MemoryGuard:Register(realtimeLabel, function(lbl) lbl.Text = tostring(options.RealtimeValue()) end)
            end
        end

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

        local function populate()
            for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            for _, item in ipairs(items) do
                local ib = Instance.new("TextButton")
                ib.BackgroundColor3 = Theme.Secondary
                ib.Size = UDim2.new(1, 0, 0, 26)
                ib.Text = " " .. item
                ib.TextColor3 = Theme.Text
                ib.Font = Enum.Font.Gotham
                ib.TextSize = 12
                ib.TextXAlignment = Enum.TextXAlignment.Left
                ib.ZIndex = 11
                ib.Parent = listFrame
                CC(ib, 6)
                ib.MouseButton1Click:Connect(function()
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
        populate()

        toggleBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            listFrame.Visible = expanded
            toggleBtn.Text = expanded and "▲" or "▼"
        end)

        if options.ConfigKey and ConfigManager then
            ConfigManager:Register(options.ConfigKey, function() return selected end, function(v)
                selected = v
                selectedLabel.Text = v
                if options.Callback then options.Callback(v) end
            end)
        end

        return {
            GetValue = function() return selected end,
            SetOptions = function(newItems)
                items = newItems
                populate()
            end
        }
    end

    -- ❼ Input
    Elements.Input = function(parent, options)
        options = options or {}
        local card = BaseCard(parent, 60)

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

        local inputBg = Instance.new("Frame")
        inputBg.BackgroundColor3 = Theme.Input_BG
        inputBg.Size = UDim2.new(1, -20, 0, 28)
        inputBg.Position = UDim2.new(0, 10, 0, 26)
        inputBg.Parent = card
        CC(inputBg, 6)
        CS(inputBg, Theme.Border)

        local box = Instance.new("TextBox")
        box.BackgroundTransparency = 1
        box.Size = UDim2.new(1, -10, 1, 0)
        box.Position = UDim2.new(0, 6, 0, 0)
        box.PlaceholderText = options.Placeholder or "พิมพ์ที่นี่..."
        box.PlaceholderColor3 = Theme.SubText
        box.TextColor3 = Theme.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.Text = ""
        box.Parent = inputBg

        box.FocusLost:Connect(function(enterPressed)
            if enterPressed and options.Callback then options.Callback(box.Text) end
        end)

        return {
            GetValue = function() return box.Text end,
            SetValue = function(v) box.Text = v end
        }
    end

    -- ❽ ProgressBar
    Elements.ProgressBar = function(parent, options)
        options = options or {}
        local maxValue = options.Max or 100
        local valueFunc = options.Value or function() return 0 end
        local card = BaseCard(parent, 54)

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

        local barBg = Instance.new("Frame")
        barBg.BackgroundColor3 = Theme.Slider_BG
        barBg.Size = UDim2.new(1, -20, 0, 10)
        barBg.Position = UDim2.new(0, 10, 0, 30)
        barBg.Parent = card
        CC(barBg, 5)

        local barFill = Instance.new("Frame")
        barFill.BackgroundColor3 = Theme.Accent
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.Parent = barBg
        CC(barFill, 5)

        if MemoryGuard then
            MemoryGuard:Register(card, function()
                local cur = valueFunc()
                cur = math.clamp(cur, 0, maxValue)
                local pct = cur / maxValue
                barFill.Size = UDim2.new(pct, 0, 1, 0)
                valueLabel.Text = math.floor(cur) .. "/" .. maxValue
                barFill.BackgroundColor3 = (pct > 0.6 and Color3.fromRGB(60,180,100)) or (pct > 0.3 and Color3.fromRGB(200,160,40)) or Color3.fromRGB(200,60,60)
            end)
        end

        return {}
    end

    -- ❾ Paragraph
    Elements.Paragraph = function(parent, options)
        options = options or {}
        local titleText = options.Title or ""
        local contentText = options.Content or ""
        local lines = math.max(1, math.ceil(#contentText / 42))
        local h = 46 + (lines * 16)
        local card = BaseCard(parent, h)

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

        local sep = Instance.new("Frame")
        sep.BackgroundColor3 = Theme.Border
        sep.Size = UDim2.new(1, -20, 0, 1)
        sep.Position = UDim2.new(0, 10, 0, 28)
        sep.BorderSizePixel = 0
        sep.Parent = card

        local contentLabel = Instance.new("TextLabel")
        contentLabel.BackgroundTransparency = 1
        contentLabel.Position = UDim2.new(0, 10, 0, 32)
        contentLabel.Size = UDim2.new(1, -20, 0, h - 38)
        contentLabel.Text = contentText
        contentLabel.TextColor3 = Theme.SubText
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.TextSize = 12
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextWrapped = true
        contentLabel.Parent = card

        return {
            SetTitle = function(t) titleLabel.Text = t end,
            SetContent = function(t) contentLabel.Text = t end
        }
    end

    -- ❿ ColorPicker
    Elements.ColorPicker = function(parent, options)
        options = options or {}
        local defaultColor = options.Default or Color3.fromRGB(100, 60, 200)
        local rVal = math.floor(defaultColor.R * 255)
        local gVal = math.floor(defaultColor.G * 255)
        local bVal = math.floor(defaultColor.B * 255)
        local card = BaseCard(parent, 162)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.6, 0, 0, 18)
        nameLabel.Text = options.Name or "ColorPicker"
        nameLabel.TextColor3 = Theme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        local preview = Instance.new("Frame")
        preview.BackgroundColor3 = defaultColor
        preview.Size = UDim2.new(0, 36, 0, 20)
        preview.Position = UDim2.new(1, -46, 0, 6)
        preview.Parent = card
        CC(preview, 5)
        CS(preview, Theme.Border, 1)

        local function updateColor()
            local c = Color3.fromRGB(rVal, gVal, bVal)
            preview.BackgroundColor3 = c
            if options.Callback then options.Callback(c) end
        end

        local function makeSlider(label, yPos, init, color, onChange)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.new(0, 10, 0, yPos)
            lbl.Size = UDim2.new(0, 14, 0, 14)
            lbl.Text = label
            lbl.TextColor3 = color
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.Parent = card

            local valLbl = Instance.new("TextLabel")
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(1, -38, 0, yPos)
            valLbl.Size = UDim2.new(0, 32, 0, 14)
            valLbl.Text = tostring(init)
            valLbl.TextColor3 = Theme.SubText
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 10
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = card

            local tr = Instance.new("Frame")
            tr.BackgroundColor3 = Theme.Slider_BG
            tr.Size = UDim2.new(1, -58, 0, 7)
            tr.Position = UDim2.new(0, 26, 0, yPos + 4)
            tr.Parent = card
            CC(tr, 3)

            local fi = Instance.new("Frame")
            fi.BackgroundColor3 = color
            fi.Size = UDim2.new(init / 255, 0, 1, 0)
            fi.Parent = tr
            CC(fi, 3)

            local drag = false
            local function upd(pos)
                local r = math.clamp((pos.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
                local v = math.floor(r * 255)
                fi.Size = UDim2.new(r, 0, 1, 0)
                valLbl.Text = tostring(v)
                onChange(v)
                updateColor()
            end
            tr.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i.Position) end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position) end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
            end)
        end

        makeSlider("R", 34, rVal, Color3.fromRGB(220,60,60), function(v) rVal = v end)
        makeSlider("G", 60, gVal, Color3.fromRGB(60,200,80), function(v) gVal = v end)
        makeSlider("B", 86, bVal, Color3.fromRGB(60,120,220), function(v) bVal = v end)

        local hexLabel = Instance.new("TextLabel")
        hexLabel.BackgroundTransparency = 1
        hexLabel.Position = UDim2.new(0, 10, 0, 110)
        hexLabel.Size = UDim2.new(1, -20, 0, 16)
        hexLabel.Text = "Color3.fromRGB(" .. rVal .. "," .. gVal .. "," .. bVal .. ")"
        hexLabel.TextColor3 = Theme.SubText
        hexLabel.Font = Enum.Font.Code
        hexLabel.TextSize = 10
        hexLabel.TextXAlignment = Enum.TextXAlignment.Left
        hexLabel.Parent = card

        local copyBtn = Instance.new("TextButton")
        copyBtn.BackgroundColor3 = Theme.Secondary
        copyBtn.Size = UDim2.new(1, -20, 0, 26)
        copyBtn.Position = UDim2.new(0, 10, 0, 130)
        copyBtn.Text = "📋 Copy Color3"
        copyBtn.TextColor3 = Theme.Text
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 11
        copyBtn.Parent = card
        CC(copyBtn, 7)
        CS(copyBtn, Theme.Border, 1)

        copyBtn.MouseButton1Click:Connect(function()
            SetClipboard("Color3.fromRGB(" .. rVal .. "," .. gVal .. "," .. bVal .. ")")
            local old = copyBtn.Text
            copyBtn.Text = "✅ คัดลอกแล้ว!"
            Tween(copyBtn, { BackgroundColor3 = Color3.fromRGB(30, 80, 40) }, 0.15)
            task.wait(1.5)
            copyBtn.Text = old
            Tween(copyBtn, { BackgroundColor3 = Theme.Secondary }, 0.15)
        end)

        if MemoryGuard then
            MemoryGuard:Register(hexLabel, function(lbl)
                lbl.Text = "Color3.fromRGB(" .. rVal .. "," .. gVal .. "," .. bVal .. ")"
            end)
        end

        return {
            GetColor = function() return Color3.fromRGB(rVal, gVal, bVal) end
        }
    end

    -- ⓫ Keybind
    Elements.Keybind = function(parent, options)
        options = options or {}
        local currentKey = options.Default or Enum.KeyCode.F
        local isListening = false
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local card = BaseCard(parent, 50)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.Size = UDim2.new(0.55, 0, 0, 18)
        nameLabel.Text = options.Name or "Keybind"
        nameLabel.TextColor3 = Theme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 10, 0, 26)
        descLabel.Size = UDim2.new(0.55, 0, 0, 16)
        descLabel.Text = options.Description or ""
        descLabel.TextColor3 = Theme.SubText
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 10
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = card

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.new(0, 80, 0, 28)
        keyBtn.Position = UDim2.new(1, -90, 0.5, -14)
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.TextSize = 11
        keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        keyBtn.Parent = card
        CC(keyBtn, 7)

        if isMobile then
            keyBtn.BackgroundColor3 = Theme.Accent
            keyBtn.Text = "▶ กด"
            keyBtn.MouseButton1Click:Connect(function()
                Tween(keyBtn, { BackgroundColor3 = Theme.AccentHover }, 0.1)
                task.wait(0.1)
                Tween(keyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
                if options.Callback then options.Callback() end
            end)
        else
            keyBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
            keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
            CS(keyBtn, Theme.Accent, 1.5)
            local function startListening()
                if isListening then return end
                isListening = true
                keyBtn.Text = "[...]"
                keyBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
                        keyBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
                        isListening = false
                        conn:Disconnect()
                    end
                end)
            end
            keyBtn.MouseButton1Click:Connect(startListening)
            UserInputService.InputBegan:Connect(function(input, gp)
                if gp or isListening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    if options.Callback then options.Callback() end
                end
            end)
        end

        return {
            GetKey = function() return currentKey end,
            SetKey = function(k)
                currentKey = k
                if not isMobile then keyBtn.Text = "[" .. tostring(k.Name) .. "]" end
            end
        }
    end

    -- ⓬ Card
    Elements.Card = function(parent, options)
        options = options or {}
        local titleText = options.Title or "Card"
        local contentText = options.Content or ""
        local h = options.Height or 80
        local card = BaseCard(parent, h)

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

        local sep = Instance.new("Frame")
        sep.BackgroundColor3 = Theme.Border
        sep.Size = UDim2.new(1, -20, 0, 1)
        sep.Position = UDim2.new(0, 10, 0, 28)
        sep.BorderSizePixel = 0
        sep.Parent = card

        local contentLabel = Instance.new("TextLabel")
        contentLabel.BackgroundTransparency = 1
        contentLabel.Position = UDim2.new(0, 10, 0, 32)
        contentLabel.Size = UDim2.new(1, -20, 0, h - 38)
        contentLabel.Text = contentText
        contentLabel.TextColor3 = Theme.SubText
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.TextSize = 12
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextWrapped = true
        contentLabel.Parent = card

        return {
            SetTitle = function(t) titleLabel.Text = t end,
            SetContent = function(t) contentLabel.Text = t end
        }
    end

    return Elements
end
