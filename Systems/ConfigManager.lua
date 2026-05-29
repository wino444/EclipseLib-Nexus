--[[
    EclipseLib-Nexus Systems/ConfigManager.lua
    Version: 1.0.0
    หน้าที่: Save/Load Config (JSON + XOR Encrypt)
]]

return function(deps)
    local Services = deps.Services
    local HttpService = Services.HttpService

    local ConfigSystem = {}
    ConfigSystem._folder = "EclipseLib"
    ConfigSystem._data = {}
    ConfigSystem._registered = {}

    -- เข้ารหัส/ถอดรหัสแบบ XOR
    local function encrypt(str)
        local res = ""
        for i = 1, #str do
            local c = string.byte(str, i)
            res = res .. string.char((c + i * 3 + 7) % 256)
        end
        return res
    end

    local function decrypt(str)
        local res = ""
        for i = 1, #str do
            local c = string.byte(str, i)
            res = res .. string.char((c - i * 3 - 7) % 256)
        end
        return res
    end

    function ConfigSystem:SetFolder(f)
        self._folder = f
    end

    function ConfigSystem:Register(key, getFn, setFn)
        self._registered[key] = { get = getFn, set = setFn }
    end

    function ConfigSystem:GetSaveList()
        local list = {}
        pcall(function()
            if isfolder and isfolder(self._folder) then
                for _, f in ipairs(listfiles(self._folder)) do
                    local name = f:match("([^/\\]+)%.ecl$")
                    if name then table.insert(list, name) end
                end
            end
        end)
        if #list == 0 then table.insert(list, "(ยังไม่มีไฟล์)") end
        return list
    end

    function ConfigSystem:Save(filename)
        if not filename or filename == "" or filename == "(ยังไม่มีไฟล์)" then return false end
        local snapshot = {}
        for key, fns in pairs(self._registered) do
            pcall(function()
                snapshot[key] = fns.get()
            end)
        end
        self._data[filename] = snapshot
        local ok, err = pcall(function()
            if not isfolder(self._folder) then makefolder(self._folder) end
            local json = HttpService:JSONEncode(snapshot)
            writefile(self._folder .. "/" .. filename .. ".ecl", encrypt(json))
        end)
        if not ok then warn("Config Save error: " .. tostring(err)) return false end
        return true
    end

    function ConfigSystem:Load(filename)
        if not filename or filename == "" or filename == "(ยังไม่มีไฟล์)" then return false end
        local snapshot = nil
        pcall(function()
            local path = self._folder .. "/" .. filename .. ".ecl"
            if isfile and isfile(path) then
                local enc = readfile(path)
                local json = decrypt(enc)
                snapshot = HttpService:JSONDecode(json)
            end
        end)
        if snapshot then
            for key, fns in pairs(self._registered) do
                if snapshot[key] ~= nil then
                    pcall(function()
                        fns.set(snapshot[key])
                    end)
                end
            end
            return true
        end
        return false
    end

    return ConfigSystem
end
