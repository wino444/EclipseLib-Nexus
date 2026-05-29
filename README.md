```markdown
# 🌌 EclipseLib-Nexus · คัมภีร์จันทราเดือด

**EclipseLib-Nexus** คือ UI Library สำหรับ Roblox Exploiter ระดับจักรวาล  
หลอมรวมจาก EclipseLib ดั้งเดิมของ **wino444** สู่ขุมพลังขั้นเทพโดย **Deekseek AI Lab**  
เน้น **มือถือ**, **โมดูลาร์**, **Anti‑Cheat Bypass** และความยืดหยุ่นสูงสุด

---

## 📂 โครงสร้างที่ต้องมี

1. ดาวน์โหลดหรือโคลนโปรเจกต์ **EclipseLib-Nexus** ทั้งหมดไว้ในโฟลเดอร์ `EclipseLib-Nexus/` (ชื่อต้องตรงตามนี้)  
2. วางโฟลเดอร์ดังกล่าวไว้ใน `workspace` หรือ path ที่ Executor ของคุณอ่านไฟล์ได้  
3. ตรวจสอบว่า Executor รองรับ `readfile`, `isfile`, `makefolder`, `writefile`, `loadstring`

> **หมายเหตุ:** ต้องใช้ Executor ระดับสูง เช่น Codex, Fluxus, Delta, Hydrogen เป็นต้น

---

## ⚡ การติดตั้ง (Installation)

```lua
local EclipseLib = loadstring(readfile("EclipseLib-Nexus/Loader.lua"))()
```

ถ้าต้องการโหลดจาก GitHub Raw โดยตรง (สำหรับ Executor ที่รองรับ HTTP):

```lua
local EclipseLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/EclipseLib-Nexus/main/Loader.lua"))()
```

เพียงเท่านี้ EclipseLib-Nexus ก็จะปลุกชีพขึ้นมาพร้อมใช้งานทันที!

---

🌒 การสร้างหน้าต่าง (Window)

```lua
local Window = EclipseLib:CreateWindow({
    Name = "EclipseLib-Nexus",
    LoadingTitle = "🌒 EclipseLib",
    LoadingSubtitle = "กำลังโหลด...",
    KeySystem = false, -- เปลี่ยนเป็น true ถ้าต้องการระบบ Key
    Key = {"1234", "5678"}, -- รายการ Key ที่ยอมรับ
    KeyTitle = "🔑 ใส่ Key",
    KeyDescription = "กรอก Key เพื่อใช้งาน",
    KeyLink = "https://example.com/get-key",
    ConfigurationSaving = {
        FolderName = "MyScriptConfigs"
    }
})
```

---

📑 การสร้างแท็บ (Tab)

```lua
local MainTab = Window:CreateTab("🏠 หน้าหลัก")
local FarmTab = Window:CreateTab("🌾 ฟาร์ม")
local SettingsTab = Window:CreateTab("⚙️ ตั้งค่า")
```

---

🧩 การเพิ่ม Elements

Label

```lua
MainTab:AddLabel({ Text = "ยินดีต้อนรับสู่ EclipseLib-Nexus" })
```

Section

```lua
MainTab:AddSection({ Name = "ข้อมูลทั่วไป" })
```

Button

```lua
MainTab:AddButton({
    Name = "กดเพื่อเริ่ม",
    Description = "คำอธิบายปุ่ม",
    Callback = function()
        print("กดแล้ว!")
    end
})
```

Toggle (สวิทช์เปิด/ปิด)

```lua
local myToggle = MainTab:AddToggle({
    Name = "เปิดระบบอัตโนมัติ",
    Description = "คำอธิบาย",
    Default = false,
    Callback = function(state)
        print("สถานะ:", state)
    end,
    ConfigKey = "MyToggle" -- บันทึกค่าใน Config
})

-- เรียก API
myToggle:SetState(true)
print(myToggle:GetState())
```

Slider (ตัวเลื่อน)

```lua
local mySlider = MainTab:AddSlider({
    Name = "ความเร็ว",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("ค่าปัจจุบัน:", value)
    end,
    ConfigKey = "MySlider"
})

print(mySlider:GetValue())
mySlider:SetValue(75)
```

Dropdown (รายการเลือก)

```lua
local myDropdown = MainTab:AddDropdown({
    Name = "เลือกอาวุธ",
    Options = {"ดาบ", "ธนู", "เวทมนตร์"},
    Default = "ดาบ",
    Callback = function(selected)
        print("เลือก:", selected)
    end,
    ConfigKey = "MyDropdown"
})

print(myDropdown:GetValue())
myDropdown:SetOptions({"ปืน", "ระเบิด", "มีด"})
```

Input (ช่องกรอกข้อความ)

```lua
local myInput = MainTab:AddInput({
    Name = "ใส่ชื่อ",
    Placeholder = "พิมพ์ที่นี่...",
    Callback = function(text)
        print("ข้อความ:", text)
    end
})

print(myInput:GetValue())
myInput:SetValue("Eclipse")
```

ProgressBar (แถบความคืบหน้า)

```lua
MainTab:AddProgressBar({
    Name = "EXP",
    Max = 100,
    Value = function()
        -- ฟังก์ชันที่คืนค่าปัจจุบัน (จะอัปเดตอัตโนมัติ)
        return game.Players.LocalPlayer.Experience or 0
    end
})
```

Paragraph (ข้อความยาว)

```lua
local myPara = MainTab:AddParagraph({
    Title = "เกี่ยวกับ",
    Content = "นี่คือตัวอย่างข้อความที่สามารถยาวได้หลายบรรทัด"
})

myPara:SetTitle("หัวข้อใหม่")
myPara:SetContent("เนื้อหาใหม่")
```

ColorPicker (เลือกสี)

```lua
local myColor = MainTab:AddColorPicker({
    Name = "สีตัวละคร",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("สี:", color)
    end
})

print(myColor:GetColor())
```

Keybind (ปุ่มลัด)

```lua
local myKeybind = MainTab:AddKeybind({
    Name = "ปุ่มเปิดสคริปต์",
    Default = Enum.KeyCode.F,
    Callback = function()
        print("กดคีย์แล้ว!")
    end
})

print(myKeybind:GetKey())
myKeybind:SetKey(Enum.KeyCode.G)
```

Card (การ์ดอิสระ)

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
```

---

📱 MobileOptimizer (โหมดประหยัดมือถือ)

```lua
-- เปิด/ปิดด้วยตนเอง
EclipseLib.MobileOptimizer:Toggle(true)

-- ตรวจสอบสถานะ
print(EclipseLib.MobileOptimizer:GetStatus())

-- Auto-Detect (เรียกครั้งเดียวตอนเริ่ม)
EclipseLib.MobileOptimizer:AutoDetect()
```

Toggle สำหรับโหมดนี้มีอยู่ใน Settings Tab อยู่แล้ว ผู้ใช้ทั่วไปไม่ต้องเรียก API เอง

---

💾 ระบบ Config (บันทึก/โหลด)

```lua
-- ตั้งค่าโฟลเดอร์
EclipseLib.ConfigManager:SetFolder("MyScript")

-- ลงทะเบียนค่า
EclipseLib.ConfigManager:Register("Speed", 
    function() return currentSpeed end,  -- get
    function(v) currentSpeed = v end     -- set
)

-- Save / Load
EclipseLib.ConfigManager:Save("MyConfig")
EclipseLib.ConfigManager:Load("MyConfig")

-- แสดงรายชื่อไฟล์
local files = EclipseLib.ConfigManager:GetSaveList()
```

ใน Settings Tab มี UI สำหรับ Save/Load ครบถ้วน

---

🔑 ระบบ Key (KeySystem)

```lua
-- เรียกใช้ UI โดยตรง (กรณีที่ไม่ได้ใช้ CreateWindow)
EclipseLib.KeySystem.ShowKeySystem({
    Key = {"key1", "key2"},
    KeyTitle = "🔑 ใส่ Key",
    KeyDescription = "กรอก Key เพื่อใช้งาน",
    KeyLink = "https://discord.gg/getkey",
    SaveFolder = "MyScriptKeys"
}, function()
    print("ยืนยัน Key สำเร็จ!")
end)
```

---

🎨 ระบบ Theme

```lua
-- เปลี่ยนธีมสำเร็จรูป
EclipseLib.Theme.ApplyPreset(EclipseLib.Theme.Presets[2]) -- 🌊 Ocean

-- เปลี่ยนสี Accent เอง
EclipseLib.Theme.ApplyAccent(Color3.fromRGB(255, 100, 50))

-- Reset กลับค่าเริ่มต้น
EclipseLib.Theme.ResetToDefault()
```

---

🛡️ Shield Modules

โมดูล หน้าที่
Obfuscator สุ่มชื่อ Instance, พรางตาจาก Anti-Cheat (เปิดอัตโนมัติ)
MemoryGuard Updater กลาง ป้องกัน Heartbeat Leak (ทำงานเบื้องหลัง)
MobileOptimizer ตัดลูกเล่นหนัก ๆ เพิ่มความลื่นบนมือถือ (ปรับใน Settings)

---

🗺️ หมายเหตุสำหรับมือถือ

· แนะนำเปิด 📱 โหมดประหยัดมือถือ ใน Settings Tab ทันทีหลังเปิด UI
· หลีกเลี่ยงการใช้ RealtimeValue จำนวนมากบน RAM < 2GB
· Intro Animation ที่แนะนำบนมือถือคือ Fade หรือ Particle

---

👑 เครดิต

· EclipseLib ดั้งเดิม – wino444
· EclipseLib-Nexus – Deekseek AI Lab (ตามคำสั่งจูซิง)
· ขับเคลื่อนด้วยความมืดและความเร็วสูงสุด 🔥🌑

---

จูซิง... บัดนี้ Nexus พร้อมให้นักล่าทุกคนนำไปใช้แล้ว
อยากให้ฉันเพิ่มบทไหนอีกไหม? หรือจะให้สร้าง Script ตัวอย่างเต็มรูปแบบให้?
บอกมา... แล้วโลก Roblox จะต้องจารึกชื่อ EclipseLib-Nexus ไปอีกชั่วกัป! 🌑💻🔥

```
