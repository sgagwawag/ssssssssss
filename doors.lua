local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "DOORS | ESP + Utility 2026",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DoorsOrionHub"
})

-- ──────────────────────────────────────────────────────────────
-- VISUALS TAB
-- ──────────────────────────────────────────────────────────────
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local EntityESP = false
local ItemESP   = false
local espTable  = {}

-- Common entity & item names in current DOORS (Hotel + Mines floors)
local entities = {
    "RushMoving", "AmbushMoving", "SeekMoving", "FigureRig",
    "Screech", "Eyes", "Halt", "Dupe", "Jack", "Timothy", "Snare"
}

local items = {
    "KeyObtain", "Crucifix", "Battery", "Flashlight", "Lighter",
    "Lockpick", "LiveHintBook", "Fuse", "LeverForGate",
    "Wardrobe", "Bed", "ElectricalBox"
}

-- Simple ESP creator
local function CreateESP(parent, color, text)
    if parent:FindFirstChild("OrionESP") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "OrionESP"
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.Adornee = parent
    hl.Parent = parent

    local bg = Instance.new("BillboardGui")
    bg.Name = "OrionLabel"
    bg.Size = UDim2.new(0, 180, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3.2, 0)
    bg.AlwaysOnTop = true
    bg.Parent = parent:FindFirstChildWhichIsA("BasePart") or parent

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold

    table.insert(espTable, {hl = hl, gui = bg})
end

-- Main scanning loop
spawn(function()
    while true do
        task.wait(0.9)

        if not (EntityESP or ItemESP) then continue end

        for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
            for _, obj in ipairs(room:GetDescendants()) do
                -- Entity ESP
                if EntityESP then
                    for _, name in ipairs(entities) do
                        if obj.Name == name or obj:FindFirstChild(name) then
                            local display = name:gsub("Moving",""):gsub("Rig","")
                            CreateESP(obj, Color3.fromRGB(255, 60, 60), display .. " ⚠")
                        end
                    end
                end

                -- Item ESP
                if ItemESP then
                    for _, name in ipairs(items) do
                        if obj.Name == name or string.find(obj.Name:lower(), name:lower()) then
                            local col = (name == "KeyObtain" or name == "Crucifix") and
                                        Color3.fromRGB(255, 215, 0) or
                                        Color3.fromRGB(0, 255, 140)
                            CreateESP(obj, col, name)
                        end
                    end
                end
            end
        end
    end
end)

-- ──────────────────────────────────────────────────────────────
-- TOGGLES
-- ──────────────────────────────────────────────────────────────
VisualsTab:AddToggle({
    Name = "Entity ESP (Rush, Ambush, Figure, Seek, Screech…)",
    Default = false,
    Callback = function(v)
        EntityESP = v
        OrionLib:MakeNotification({
            Name = "Entity ESP",
            Content = v and "Enabled" or "Disabled",
            Time = 3
        })
    end
})

VisualsTab:AddToggle({
    Name = "Item & Tool ESP (Keys, Crucifix, Battery…)",
    Default = false,
    Callback = function(v)
        ItemESP = v
        OrionLib:MakeNotification({
            Name = "Item ESP",
            Content = v and "Enabled" or "Disabled",
            Time = 3
        })
    end
})

VisualsTab:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(v)
        game.Lighting.Brightness   = v and 2.5 or 1
        game.Lighting.ClockTime    = v and 12 or 18
        game.Lighting.FogEnd       = v and 999999 or 100
        game.Lighting.GlobalShadows = not v
    end
})

-- ──────────────────────────────────────────────────────────────
-- MOVEMENT TAB
-- ──────────────────────────────────────────────────────────────
local MoveTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

MoveTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 120,
    Default = 16,
    Increment = 1,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

MoveTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        if state then
            game:GetService("RunService").Stepped:Connect(function()
                if state and game.Players.LocalPlayer.Character then
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    end
})

-- Cleanup old ESP when disabled (optional quality of life)
game:GetService("RunService").Heartbeat:Connect(function()
    if not (EntityESP or ItemESP) then
        for _, v in ipairs(espTable) do
            if v.hl then pcall(function() v.hl:Destroy() end) end
            if v.gui then pcall(function() v.gui:Destroy() end) end
        end
        espTable = {}
    end
end)

OrionLib:MakeNotification({
    Name = "DOORS Hub Loaded",
    Content = "Entity + Item ESP • Fullbright • Noclip • Speed",
    Time = 5
})

print("DOORS Orion ESP hub loaded")
