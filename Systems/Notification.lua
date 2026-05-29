--[[
    EclipseLib-Nexus Systems/Notification.lua
    Version: 1.0.0
    หน้าที่: ระบบแจ้งเตือน EONotify (คิว, ตำแหน่ง, UI)
]]

return function(deps)
    local Utils = deps.Utils
    local Theme = deps.Theme.Theme -- ตาราง Theme ปัจจุบัน
    local Services = deps.Services

    local TweenService = Services.TweenService

    local NotifSystem = {}
    local NotifQueue = {}
    local NotifQueueBusy = false
    local NotifQueueEnabled = true
    local NotifHolder = nil

    -- สร้างหรือคืน NotifHolder
    local function ensureHolder()
        if NotifHolder and NotifHolder.Parent then return NotifHolder end
        local gui = Instance.new("ScreenGui")
        gui.Name = Utils._randomName("eclipse_notif_")
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 10000
        pcall(function() gui.Parent = Services.CoreGui end)
        if not gui.Parent then gui.Parent = Services.LocalPlayer.PlayerGui end
        NotifHolder = gui
        return gui
    end

    -- สร้าง Notification แต่ละอัน
    local function createNotif(gui, data)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 70)
        frame.Position = UDim2.new(1, 10, 1, -90)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundColor3 = Theme.Notif_BG
        frame.BorderSizePixel = 0
        frame.Parent = gui
        Utils.CC(frame, 12)
        Utils.CS(frame, Theme.Notif_Border, 2)

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 40, 1, 0)
        icon.Position = UDim2.new(0, 5, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "🌒"
        icon.TextScaled = true
        icon.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -55, 0, 28)
        title.Position = UDim2.new(0, 50, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = data.Title or "EclipseLib"
        title.TextColor3 = Theme.Accent
        title.Font = Enum.Font.GothamBold
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, -55, 0, 28)
        msg.Position = UDim2.new(0, 50, 0, 30)
        msg.BackgroundTransparency = 1
        msg.Text = data.Content or ""
        msg.TextColor3 = Theme.Text
        msg.Font = Enum.Font.Gotham
        msg.TextSize = 13
        msg.TextXAlignment = Enum.TextXAlignment.Left
        msg.TextWrapped = true
        msg.Parent = frame

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 3)
        bar.Position = UDim2.new(0, 0, 1, -3)
        bar.BackgroundColor3 = Theme.Accent
        bar.BorderSizePixel = 0
        bar.Parent = frame
        Utils.CC(bar, 4)

        -- Slide in
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, -10, 1, -90)
        }):Play()

        -- Progress shrink
        local duration = data.Duration or 3
        TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 3)
        }):Play()

        -- Slide out
        task.delay(duration, function()
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 300, 1, -90)
            }):Play()
            task.wait(0.3)
            frame:Destroy()
            NotifQueueBusy = false
            showNext()
        end)
    end

    -- จัดการคิว
    function showNext()
        if not NotifQueueEnabled then
            while #NotifQueue > 0 do
                local data = table.remove(NotifQueue, 1)
                createNotif(ensureHolder(), data)
            end
            return
        end
        if NotifQueueBusy or #NotifQueue == 0 then return end
        NotifQueueBusy = true
        local data = table.remove(NotifQueue, 1)
        createNotif(ensureHolder(), data)
    end

    -- API หลัก
    function NotifSystem:Notify(opts)
        opts = opts or {}
        table.insert(NotifQueue, {
            Title = opts.Title or opts.title or "EclipseLib",
            Content = opts.Content or opts.text or "",
            Duration = opts.Duration or opts.duration or 3,
        })
        if NotifQueueEnabled then
            showNext()
        else
            local data = table.remove(NotifQueue, 1)
            createNotif(ensureHolder(), data)
        end
    end

    function NotifSystem:SetPosition(udim2)
        ensureHolder().Position = udim2
    end

    function NotifSystem:SetQueueEnabled(bool)
        NotifQueueEnabled = bool
    end

    function NotifSystem:Clear()
        NotifQueue = {}
        NotifQueueBusy = false
    end

    return NotifSystem
end
