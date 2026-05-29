--[[
    EclipseLib-Nexus Components/Elements/ColorPicker.lua
    หน้าที่: เลือกสี RGB พร้อม Copy
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local BaseCard = deps.BaseCard
    local Services = deps.Services

    local CC = Utils.CC
    local CS = Utils.CS
    local Tween = Utils.Tween
    local SetClipboard = Utils.SetClipboard
    local UserInputService = Services.UserInputService

    local function AddColorPicker(parent, options)
        options = options or {}
        local defaultColor = options.Default or Color3.fromRGB(100, 60, 200)
        local r, g, b = math.floor(defaultColor.R * 255), math.floor(defaultColor.G * 255), math.floor(defaultColor.B * 255)
        local card = BaseCard(parent, 162)

        -- ชื่อ
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

        -- Preview
        local preview = Instance.new("Frame")
        preview.BackgroundColor3 = defaultColor
        preview.Size = UDim2.new(0, 36, 0, 20)
        preview.Position = UDim2.new(1, -46, 0, 6)
        preview.Parent = card
        CC(preview, 5)
        CS(preview, Theme.Border, 1)

        local function updateColor()
            local col = Color3.fromRGB(r, g, b)
            preview.BackgroundColor3 = col
            if options.Callback then options.Callback(col) end
        end

        -- Helper สร้าง slider RGB
        local function makeSlider(label, yPos, initValue, color, onChange)
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
            valLbl.Text = tostring(initValue)
            valLbl.TextColor3 = Theme.SubText
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 10
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = card

            local track = Instance.new("Frame")
            track.BackgroundColor3 = Theme.Slider_BG
            track.Size = UDim2.new(1, -58, 0, 7)
            track.Position = UDim2.new(0, 26, 0, yPos + 4)
            track.Parent = card
            CC(track, 3)

            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = color
            fill.Size = UDim2.new(initValue / 255, 0, 1, 0)
            fill.Parent = track
            CC(fill, 3)

            local drag = false
            local function upd(pos)
                local ratio = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = math.floor(ratio * 255)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                valLbl.Text = tostring(v)
                onChange(v)
                updateColor()
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    drag = true
                    upd(input.Position)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    upd(input.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    drag = false
                end
            end)
        end

        makeSlider("R", 34, r, Color3.fromRGB(220, 60, 60), function(v) r = v end)
        makeSlider("G", 60, g, Color3.fromRGB(60, 200, 80), function(v) g = v end)
        makeSlider("B", 86, b, Color3.fromRGB(60, 120, 220), function(v) b = v end)

        -- Hex label
        local hexLabel = Instance.new("TextLabel")
        hexLabel.BackgroundTransparency = 1
        hexLabel.Position = UDim2.new(0, 10, 0, 110)
        hexLabel.Size = UDim2.new(1, -20, 0, 16)
        hexLabel.Text = "Color3.fromRGB(" .. r .. "," .. g .. "," .. b .. ")"
        hexLabel.TextColor3 = Theme.SubText
        hexLabel.Font = Enum.Font.Code
        hexLabel.TextSize = 10
        hexLabel.TextXAlignment = Enum.TextXAlignment.Left
        hexLabel.Parent = card

        -- ปุ่ม Copy
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
            SetClipboard("Color3.fromRGB(" .. r .. "," .. g .. "," .. b .. ")")
            local old = copyBtn.Text
            copyBtn.Text = "✅ คัดลอกแล้ว!"
            Tween(copyBtn, { BackgroundColor3 = Color3.fromRGB(30, 80, 40) }, 0.15)
            task.wait(1.5)
            copyBtn.Text = old
            Tween(copyBtn, { BackgroundColor3 = Theme.Secondary }, 0.15)
        end)

        -- Updater สำหรับ hex
        if deps.MemoryGuard then
            deps.MemoryGuard:Register(hexLabel, function(lbl)
                lbl.Text = "Color3.fromRGB(" .. r .. "," .. g .. "," .. b .. ")"
            end)
        end

        local API = {}
        function API:GetColor()
            return Color3.fromRGB(r, g, b)
        end
        return API
    end

    return AddColorPicker
end
