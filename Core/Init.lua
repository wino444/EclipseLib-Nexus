--[[
    EclipseLib-Nexus Core/Init.lua
    Version: 1.0.0
    หน้าที่: SafeGlobal, ตรวจสอบ getgenv(), ดึง Services ทั้งหมด
]]

local Init = {}

-- ===== SafeGlobal (getgenv() First) =====
local hasGenv = false
pcall(function()
    local probe = "_EclipseProbe_" .. tostring(math.random(100000, 999999))
    getgenv()[probe] = true
    if getgenv()[probe] == true then
        hasGenv = true
        getgenv()[probe] = nil
    end
end)

local ENV = hasGenv and getgenv() or _G

local SafeGlobal = {}
SafeGlobal._env = ENV
SafeGlobal._hasGenv = hasGenv

function SafeGlobal:Set(key, value)
    if hasGenv then
        pcall(function()
            getgenv()[key] = value
        end)
    else
        _G[key] = value
    end
end

function SafeGlobal:Get(key, defaultValue)
    if hasGenv then
        local success, result = pcall(function()
            return getgenv()[key]
        end)
        if success and result ~= nil then
            return result
        end
    else
        if _G[key] ~= nil then
            return _G[key]
        end
    end
    return defaultValue
end

function SafeGlobal:Delete(key)
    if hasGenv then
        pcall(function()
            getgenv()[key] = nil
        end)
    else
        _G[key] = nil
    end
end

-- ===== Services (cloneref ถ้ามี) =====
local cloneref = cloneref or function(obj) return obj end
local hookfunction = hookfunction or function(a, b) return a end

local Services = {
    TweenService = cloneref(game:GetService("TweenService")),
    UserInputService = cloneref(game:GetService("UserInputService")),
    RunService = cloneref(game:GetService("RunService")),
    CoreGui = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui"),
    Players = cloneref(game:GetService("Players")),
    HttpService = cloneref(game:GetService("HttpService")),
    TextService = cloneref(game:GetService("TextService")),
    MarketplaceService = cloneref(game:GetService("MarketplaceService")),
    TeleportService = cloneref(game:GetService("TeleportService")),
}
Services.LocalPlayer = Services.Players.LocalPlayer

-- ===== ส่งออก =====
Init.SafeGlobal = SafeGlobal
Init.Services = Services
Init.hasGenv = hasGenv
Init.cloneref = cloneref
Init.hookfunction = hookfunction

return Init
