--[[
    EclipseLib-Nexus Components/TabFrame.lua
    Version: 1.0.0
    หน้าที่: ScrollingFrame สำหรับเนื้อหาแต่ละแท็บ
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme

    local TabFrame = {}

    function TabFrame.Create(parent, name)
        local sf = Instance.new("ScrollingFrame")
        sf.Name = name or "TabFrame"
        sf.BackgroundTransparency = 1
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ScrollBarThickness = 3
        sf.ScrollBarImageColor3 = Theme.Accent
        sf.Visible = false
        sf.Parent = parent

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = sf

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.Parent = sf

        -- อัปเดต CanvasSize อัตโนมัติ
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        -- API
        local self = setmetatable({}, { __index = TabFrame })
        self.Frame = sf

        return self
    end

    function TabFrame:AddElement(elementFrame)
        elementFrame.Parent = self.Frame
    end

    function TabFrame:Show()
        self.Frame.Visible = true
    end

    function TabFrame:Hide()
        self.Frame.Visible = false
    end

    function TabFrame:IsVisible()
        return self.Frame.Visible
    end

    return TabFrame
end
