--[[
    EclipseLib-Nexus Core/Utils.lua
    Version: 1.0.0
    หน้าที่: ฟังก์ชันช่วยทั้งหมด (Tween, Corner, Stroke, Drag, Clipboard, ScreenGui)
]]

local Utils = {}
local TweenService, UserInputService, RunService, CoreGui, LocalPlayer

-- รับ Services จากภายนอก (เรียกโดย Loader หลัง Init)
function Utils.Inject(services)
    TweenService = services.TweenService
    UserInputService = services.UserInputService
    RunService = services.RunService
    CoreGui = services.CoreGui
    LocalPlayer = services.LocalPlayer
end

-- ===== Tween =====
function Utils.Tween(obj, props, t, style, dir)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(
            t or 0.2,
            style or Enum.EasingStyle.Quad,
            dir or Enum.EasingDirection.Out
        ),
        props
    )
    tw:Play()
    return tw
end

function Utils.TweenWait(obj, props, t, style, dir)
    local tw = Utils.Tween(obj, props, t, style, dir)
    tw.Completed:Wait()
end

-- ===== UICorner =====
function Utils.CC(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- ===== UIStroke =====
function Utils.CS(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 40, 80)
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

-- ===== Draggable (Leak-Free) =====
function Utils.MakeDraggable(frame, handle)
    local dragConnection, endConnection
    local dragStart, startPos

    local function startDrag(input)
        dragStart = input.Position
        startPos = frame.Position
        dragConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        endConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragConnection then dragConnection:Disconnect(); dragConnection = nil end
                if endConnection then endConnection:Disconnect(); endConnection = nil end
            end
        end)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)
end

-- ===== Clipboard =====
function Utils.SetClipboard(text)
    pcall(function()
        if setclipboard then
            setclipboard(text)
        elseif toclipboard then
            toclipboard(text)
        elseif Clipboard and Clipboard.set then
            Clipboard.set(text)
        end
    end)
end

-- ===== Random Name (Anti-Cheat) =====
function Utils._randomName(prefix)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local rnd = ""
    math.randomseed(os.time() + math.random(1, 10000))
    for _ = 1, 12 do
        rnd = rnd .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return (prefix or "el_") .. rnd
end

-- ===== MakeScreenGui =====
function Utils.MakeScreenGui(name, order)
    local sg = Instance.new("ScreenGui")
    sg.Name = name or Utils._randomName("eclipse_")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = order or 999
    pcall(function()
        sg.Parent = CoreGui
    end)
    if not sg.Parent then
        pcall(function()
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end)
    end
    return sg
end

return Utils
