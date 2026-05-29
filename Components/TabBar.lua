--[[
    EclipseLib-Nexus Components/TabBar.lua
    Version: 1.0.0
    หน้าที่: แถบแท็บ (Tab Bar) พร้อมปุ่มและ Indicator
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme
    local Services = deps.Services

    local CC = Utils.CC
    local CS = Utils.CS
    local Tween = Utils.Tween

    local TabBar = {}

    function TabBar.Create(parent)
        local self = setmetatable({}, { __index = TabBar })

        -- ScrollingFrame สำหรับแท็บ
        self.Container = Instance.new("ScrollingFrame")
        self.Container.BackgroundColor3 = Theme.Secondary
        self.Container.Size = UDim2.new(1, 0, 1, 0)
        self.Container.ScrollBarThickness = 2
        self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
        self.Container.ScrollingDirection = Enum.ScrollingDirection.Y
        self.Container.Parent = parent
        CS(self.Container, Theme.Border, 1)

        -- Layout
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = self.Container

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingLeft = UDim.new(0, 5)
        padding.PaddingRight = UDim.new(0, 5)
        padding.Parent = self.Container

        -- อัปเดต CanvasSize
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            self.Container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
        end)

        self.Tabs = {} -- {name -> button}
        self.Indicator = {} -- {name -> indicator}
        self.ActiveTab = nil

        return self
    end

    function TabBar:AddTab(name, icon, callback)
        if self.Tabs[name] then return end

        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Theme.TabInactive
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.Text = (icon or "") .. " " .. name
        btn.TextColor3 = Theme.SubText
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextWrapped = true
        btn.Parent = self.Container
        CC(btn, 8)

        -- Indicator เส้นซ้าย
        local ind = Instance.new("Frame")
        ind.BackgroundColor3 = Theme.Accent
        ind.Size = UDim2.new(0, 3, 1, -8)
        ind.Position = UDim2.new(0, 0, 0, 4)
        ind.BorderSizePixel = 0
        ind.Visible = false
        ind.Parent = btn
        CC(ind, 2)

        self.Tabs[name] = btn
        self.Indicator[name] = ind

        btn.MouseButton1Click:Connect(function()
            self:SetActive(name)
            if callback then callback(name) end
        end)

        return btn
    end

    function TabBar:SetActive(name)
        for tabName, btn in pairs(self.Tabs) do
            local isAct = (tabName == name)
            Tween(btn, { BackgroundColor3 = isAct and Theme.TabActive or Theme.TabInactive }, 0.2)
            btn.TextColor3 = isAct and Color3.fromRGB(255, 255, 255) or Theme.SubText
            if self.Indicator[tabName] then
                self.Indicator[tabName].Visible = isAct
            end
        end
        self.ActiveTab = name
    end

    function TabBar:GetActive()
        return self.ActiveTab
    end

    function TabBar:RemoveTab(name)
        local btn = self.Tabs[name]
        if btn then
            btn:Destroy()
            self.Tabs[name] = nil
            self.Indicator[name] = nil
        end
    end

    return TabBar
end
