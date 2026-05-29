```markdown
# 🌌 EclipseLib-Nexus · คัมภีร์จันทราเดือด (ฉบับเต็ม)

**EclipseLib-Nexus** คือ UI Library สำหรับ Roblox Exploiter ระดับจักรวาล  
หลอมรวมจาก EclipseLib ดั้งเดิมของ **wino444** สู่ขุมพลังขั้นเทพโดย **Deekseek AI Lab**  
เน้น **มือถือ**, **โมดูลาร์**, **Anti‑Cheat Bypass** และ **ความยืดหยุ่นสูงสุด**  

---

## 📂 โครงสร้างที่ต้องมี

1. ดาวน์โหลดหรือโคลนโปรเจกต์ **EclipseLib-Nexus** ทั้งหมดไว้ในโฟลเดอร์ `EclipseLib-Nexus/` (ชื่อต้องตรงตามนี้)  
2. วางโฟลเดอร์ดังกล่าวไว้ใน `workspace` หรือ path ที่ Executor ของคุณอ่านไฟล์ได้  
3. ตรวจสอบว่า Executor รองรับ `readfile`, `isfile`, `makefolder`, `writefile`, `loadstring`

> **หมายเหตุ:** ต้องใช้ Executor ระดับสูง เช่น Codex, Fluxus, Delta, Hydrogen เป็นต้น

---

## ⚡ การติดตั้ง (Installation)

### วิธีที่ 1: โหลดจากไฟล์ในเครื่อง
```lua
local EclipseLib = loadstring(readfile("EclipseLib-Nexus/Loader.lua"))()
```

วิธีที่ 2: โหลดจาก GitHub (Raw)

```lua
local EclipseLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/EclipseLib-Nexus/main/Loader.lua"))()
```

---

🏗️ ตัวอย่าง Script เริ่มต้น (Full Template)

```lua
-- โหลด Library
local EclipseLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/EclipseLib-Nexus/main/Loader.lua"))()

-- สร้างหน้าต่างหลัก
local Window = EclipseLib:CreateWindow({
    Name = "My Script Hub",
    LoadingTitle = "🌒 EclipseLib-Nexus",
    LoadingSubtitle = "Created by Deekseek AI Lab",
    KeySystem = true, -- เปิดระบบ Key
    Key = {"1234", "5678"}, -- รายการ Key ที่ยอมรับ
    KeyTitle = "🔑 ใส่ Key",
    KeyDescription = "กรอก Key เพื่อเข้าใช้งาน",
    KeyLink = "https://discord.gg/example",
    ConfigurationSaving = {
        FolderName = "MyScript"
    }
})

-- สร้างแท็บ
local MainTab = Window:CreateTab("🏠 หน้าหลัก")
local FarmTab = Window:CreateTab("🌾 ฟาร์ม")
local CombatTab = Window:CreateTab("⚔️ ต่อสู้")
local VisualTab = Window:CreateTab("👁️ มองเห็น")
local TeleportTab = Window:CreateTab("🌀 วาร์ป")

-- ===== หน้าหลัก =====
MainTab:AddLabel({ Text = "ยินดีต้อนรับสู่ Script Hub ฉบับสมบูรณ์!" })
MainTab:AddSection({ Name = "ข้อมูลผู้ใช้" })

MainTab:AddParagraph({
    Title = "เกี่ยวกับ",
    Content = "สคริปต์นี้รวมฟีเจอร์เด็ด ๆ มากมาย ใช้ EclipseLib-Nexus UI ระดับตำนาน"
})

MainTab:AddButton({
    Name = "ดาวน์โหลดอัปเดต",
    Description = "เช็คเวอร์ชันล่าสุด",
    Callback = function()
        -- ใส่โค้ดอัปเดต
        print("กำลังอัปเดต...")
    end
})

-- ===== ฟาร์ม =====
FarmTab:AddSection({ Name = "Auto Farm" })

local autoFarmToggle = FarmTab:AddToggle({
    Name = "เปิด/ปิด Auto Farm",
    Description = "ฟาร์มเงินและ EXP อัตโนมัติ",
    Default = false,
    Callback = function(state)
        if state then
            -- เริ่มฟาร์ม
            print("เริ่มฟาร์ม")
        else
            -- หยุดฟาร์ม
            print("หยุดฟาร์ม")
        end
    end,
    ConfigKey = "AutoFarm"
})

FarmTab:AddSlider({
    Name = "ระยะฟาร์ม",
    Min = 5,
    Max = 50,
    Default = 20,
    Callback = function(value)
        print("ระยะ:", value)
    end,
    ConfigKey = "FarmDistance"
})

-- ===== ต่อสู้ =====
CombatTab:AddSection({ Name = "Aimbot" })

CombatTab:AddToggle({
    Name = "Aimbot",
    Description = "เล็งอัตโนมัติไปที่ศัตรู",
    Default = false,
    Callback = function(state)
        -- กระทำกับ Aimbot
    end,
    ConfigKey = "Aimbot"
})

CombatTab:AddDropdown({
    Name = "ส่วนที่เล็ง",
    Options = {"หัว", "ตัว", "ขา"},
    Default = "หัว",
    Callback = function(part)
        print("เล็งไปที่:", part)
    end,
    ConfigKey = "AimPart"
})

CombatTab:AddKeybind({
    Name = "ปุ่มยิง",
    Default = Enum.KeyCode.E,
    Callback = function()
        print("ยิง!")
    end
})

-- ===== มองเห็น =====
VisualTab:AddSection({ Name = "ESP" })

VisualTab:AddToggle({
    Name = "ESP Players",
    Default = false,
    Callback = function(state)
        -- เปิด/ปิด ESP
    end,
    ConfigKey = "ESP"
})

VisualTab:AddColorPicker({
    Name = "สี ESP",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(color)
        print("เปลี่ยนสีเป็น:", color)
    end
})

-- ===== วาร์ป =====
TeleportTab:AddSection({ Name = "จุดวาร์ป" })

TeleportTab:AddButton({
    Name = "วาร์ปไปหอคอย",
    Description = "เทเลพอร์ตไปยังตำแหน่งสำคัญ",
    Callback = function()
        -- โค้ดวาร์ป
        print("วาร์ปแล้ว!")
    end
})

TeleportTab:AddInput({
    Name = "วาร์ปไปยัง Player",
    Placeholder = "พิมพ์ชื่อผู้เล่น",
    Callback = function(text)
        print("วาร์ปไปหา:", text)
    end
})

-- ===== การแจ้งเตือน =====
Window:Notify({
    Title = "โหลดสำเร็จ!",
    Content = "EclipseLib-Nexus พร้อมใช้งานแล้ว",
    Duration = 3
})

-- เปิด MobileOptimizer ถ้าเป็นมือถือ
if EclipseLib.MobileOptimizer then
    EclipseLib.MobileOptimizer:AutoDetect()
end
```

---

📑 การสร้างแท็บ (Tab)

```lua
local MainTab = Window:CreateTab("🏠 หน้าหลัก")
local FarmTab = Window:CreateTab({ Name = "🌾 ฟาร์ม", Icon = "🌾" })
```

---

🧩 Elements ทั้งหมด พร้อมตัวอย่าง

1. Label

```lua
MainTab:AddLabel({ Text = "ยินดีต้อนรับสู่ EclipseLib-Nexus" })
```

2. Section

```lua
MainTab:AddSection({ Name = "ข้อมูลทั่วไป" })
```

3. Button

```lua
MainTab:AddButton({
    Name = "กดเพื่อเริ่ม",
    Description = "คำอธิบายปุ่ม",
    Callback = function()
        print("กดแล้ว!")
    end,
    RealtimeValue = function()
        return os.time() -- แสดงเวลาปัจจุบัน
    end
})
```

4. Toggle (สวิทช์)

```lua
local myToggle = MainTab:AddToggle({
    Name = "เปิดระบบอัตโนมัติ",
    Description = "เปิด/ปิดฟีเจอร์",
    Default = false,
    Callback = function(state)
        print("สถานะ:", state)
    end,
    ConfigKey = "MyToggle" -- บันทึกใน Config
})

-- API
myToggle:SetState(true)
print(myToggle:GetState()) -- true
```

5. Slider

```lua
local mySlider = MainTab:AddSlider({
    Name = "ความเร็ว",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("ค่าปัจจุบัน:", value)
    end,
    ConfigKey = "Speed"
})

-- API
print(mySlider:GetValue()) -- 50
mySlider:SetValue(75)
```

6. Dropdown

```lua
local myDropdown = MainTab:AddDropdown({
    Name = "เลือกอาวุธ",
    Options = {"ดาบ", "ธนู", "เวทมนตร์"},
    Default = "ดาบ",
    Callback = function(selected)
        print("เลือก:", selected)
    end,
    ConfigKey = "Weapon"
})

-- API
print(myDropdown:GetValue()) -- "ดาบ"
myDropdown:SetOptions({"ปืน", "ระเบิด", "มีด"})
```

7. Input

```lua
local myInput = MainTab:AddInput({
    Name = "ใส่ชื่อ",
    Placeholder = "พิมพ์ที่นี่...",
    Callback = function(text)
        print("ข้อความ:", text)
    end
})

-- API
print(myInput:GetValue()) -- คืนข้อความ
myInput:SetValue("Eclipse")
```

8. ProgressBar

```lua
MainTab:AddProgressBar({
    Name = "EXP",
    Max = 100,
    Value = function()
        -- ฟังก์ชันคืนค่าปัจจุบัน (อัปเดตอัตโนมัติ)
        return game.Players.LocalPlayer:FindFirstChild("Exp") and game.Players.LocalPlayer.Exp.Value or 0
    end
})
```

9. Paragraph

```lua
local myPara = MainTab:AddParagraph({
    Title = "เกี่ยวกับ",
    Content = "นี่คือตัวอย่างข้อความยาวหลายบรรทัด"
})

myPara:SetTitle("หัวข้อใหม่")
myPara:SetContent("เนื้อหาใหม่")
```

10. ColorPicker

```lua
local myColor = MainTab:AddColorPicker({
    Name = "สีตัวละคร",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("สี:", color)
    end
})

-- API
print(myColor:GetColor()) -- Color3
```

11. Keybind

```lua
local myKeybind = MainTab:AddKeybind({
    Name = "เปิดสคริปต์",
    Description = "กดปุ่มนี้เพื่อทำงาน",
    Default = Enum.KeyCode.F,
    Callback = function()
        print("กดคีย์แล้ว!")
    end
})

-- API
print(myKeybind:GetKey()) -- Enum.KeyCode.F
myKeybind:SetKey(Enum.KeyCode.G)
```

12. Card

```lua
local myCard = MainTab:AddCard({
    Title = "หมายเหตุ",
    Content = "ข้อความในการ์ด",
    Height = 100
})

myCard:SetTitle("หัวข้อใหม่")
myCard:SetContent("เนื้อหาใหม่")
```

---

🔔 Notification (การแจ้งเตือน)

```lua
Window:Notify({
    Title = "สำเร็จ",
    Content = "โหลดสคริปต์สมบูรณ์!",
    Duration = 3
})

-- หรือเรียกจาก EclipseLib โดยตรง
EclipseLib:Notify({ Title = "ทดสอบ", Content = "Hello" })
```

---

📱 MobileOptimizer

```lua
-- เปิด/ปิดด้วยตนเอง
EclipseLib.MobileOptimizer:Toggle(true) -- เปิด
EclipseLib.MobileOptimizer:Toggle(false) -- ปิด

-- ตรวจสอบสถานะ
print(EclipseLib.MobileOptimizer:GetStatus())

-- Auto-Detect (แนะนำให้ใช้ครั้งแรก)
EclipseLib.MobileOptimizer:AutoDetect()
```

ใน Settings Tab มี Toggle ให้ผู้ใช้ปรับเอง

---

💾 Config (บันทึก/โหลด)

```lua
EclipseLib.ConfigManager:SetFolder("MyScript")

-- ลงทะเบียนค่า
EclipseLib.ConfigManager:Register("AutoFarm", 
    function() return autoFarmToggle:GetState() end,
    function(v) autoFarmToggle:SetState(v) end
)

EclipseLib.ConfigManager:Register("Speed", 
    function() return speedSlider:GetValue() end,
    function(v) speedSlider:SetValue(v) end
)

-- บันทึก
EclipseLib.ConfigManager:Save("MyConfig")

-- โหลด
EclipseLib.ConfigManager:Load("MyConfig")

-- รายการไฟล์
for _, f in ipairs(EclipseLib.ConfigManager:GetSaveList()) do
    print(f)
end
```

---

🔑 KeySystem

```lua
EclipseLib.KeySystem.ShowKeySystem({
    Key = {"1234", "5678"},
    KeyTitle = "🔑 ใส่ Key",
    KeyDescription = "กรอก Key เพื่อเข้าใช้",
    KeyLink = "https://discord.gg/getkey",
    SaveFolder = "MyKeys"
}, function()
    print("Key ถูกต้อง!")
end)
```

---

🎨 Theme

```lua
-- เปลี่ยน Preset
EclipseLib.Theme.ApplyPreset(EclipseLib.Theme.Presets[2]) -- 🌊 Ocean

-- เปลี่ยนสี Accent เอง
EclipseLib.Theme.ApplyAccent(Color3.fromRGB(255, 100, 50))

-- Reset
EclipseLib.Theme.ResetToDefault()
```

---

🛡️ Shield Modules

โมดูล หน้าที่
Obfuscator สุ่มชื่อ Instance, พรางตาจาก Anti-Cheat
MemoryGuard จัดการ Updater กลาง ป้องกัน Memory Leak
MobileOptimizer ลดลูกเล่นหนัก ๆ บนมือถือ

```lua
-- เปิด Obfuscator (ทำงานอัตโนมัติ)
EclipseLib.Obfuscator:Enable()

-- เช็คสถานะ MobileOptimizer
if EclipseLib.MobileOptimizer:GetStatus() then
    print("โหมดประหยัดทำงานอยู่")
end
```

---

⚙️ การตั้งค่าเริ่มต้น

ใน Settings Tab มี UI สำหรับปรับ:

· 🎨 Preset Themes (Eclipse, Ocean, Forest, Inferno, Sakura, Midnight)
· 🖌️ Custom Accent Color (RGB Slider)
· 📏 ขนาด UI (เล็ก/กลาง/ใหญ่)
· 🔔 ตำแหน่ง Notification
· 🌗 ความโปร่งใส UI
· 🔔 ระบบคิว Notification
· 📱 โหมดประหยัดมือถือ
· 💾 บันทึก/โหลด Config
· 🔄 Reset ทั้งหมด

---

🧠 เคล็ดลับสำหรับนักพัฒนา

· แยกไฟล์: หากต้องการแก้ไข Element ใด ๆ ให้เข้าไปที่ Components/Elements/
· Shield: ถ้าไม่ต้องการ Obfuscator ให้ลบหรือไม่ต้อง require ใน Loader.lua
· Mobile: ควรเปิด MobileOptimizer ทุกครั้งบนมือถือ (Auto-Detect จะช่วย)

---

👑 เครดิต

· EclipseLib ดั้งเดิม – wino444
· EclipseLib-Nexus – Deekseek AI Lab (ตามคำสั่งจูซิง)
· ขับเคลื่อนด้วยความมืดและความเร็วสูงสุด 🔥🌑



· หมายเหตุ: อย่าคาดหวังมาก แม้ แต่ ฉันที่ สร้างขึ้นมา ไม่ค่อย คาดหวังว่า จะสมบูรณ์แบบ เพราะยังไง จะใช้ แบบส่วนตัวอยู่แล้ว

---
