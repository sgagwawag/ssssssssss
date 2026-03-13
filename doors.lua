-- DOORS | Orion Library Hub (fixed tab syntax 2026 version)
-- Use :Tab instead of :MakeTab on most current Orion forks

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "DOORS | ESP + Utilities",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DoorsOrion2026"
})

-- ──────────────────────────────────────────────────────────────
-- Visuals Tab
-- ──────────────────────────────────────────────────────────────
local VisualsTab = Window:Tab("Visuals", "rbxassetid://4483362458")

local EntityESP = false
local ItemESP = false
local espObjects = {}

-- Entity names (current as of 2026 - includes common variants)
local entities = {
    "RushMoving", "AmbushMoving", "SeekMoving", "FigureRig",
    "Screech", "Eyes", "Halt", "Dupe", "Jack", "Timothy", "Snare"
}

-- Item / interactable names
local items = {
    "KeyObtain", "Crucifix", "Battery", "Flashlight", "Lighter",
    "Lockpick", "LiveHintBook", "Fuse", "LeverForGate",
    "Wardrobe", "Bed", "ElectricalBox"
}

local function CreateESP(parent, color, labelText)
    if parent:FindFirstChild("DOORS_ESP_HL") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "DOORS_ESP_HL"
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.Adornee = parent
    hl.Parent = parent

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DOORS_ESP_LABEL"
    billboard.Size = UDim2.new(0, 180, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = parent:FindFirstChild("Main") or parent:FindFirstChild("Head") or parent

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    table.insert(espObjects, {hl = hl, gui = billboard})
end

-- Scanning loop
spawn(function()
    while true do
        task.wait(0.8)
        if not (EntityESP or ItemESP) then continue end

        for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
            for _, descendant in ipairs(room:GetDescendants()) do
                -- Entity ESP
                if EntityESP then
                    for _, entName in ipairs(entities) do
                        if descendant.Name == entName or descendant:FindFirstChild(entName) then
                            local cleanName = entName:gsub("Moving", ""):gsub("Rig", "")
                            CreateESP(descendant, Color3.fromRGB(255, 60, 60), cleanName .. " ⚠")
                        end
                    end
                end

                -- Item ESP
                if ItemESP then
                    for _, itemName in ipairs(items) do
                        if descendant.Name == itemName or string.find(descendant.Name:lower(), itemName:lower()) then
                            local col = (itemName == "KeyObtain" or itemName == "Crucifix") and 
                                        Color3.fromRGB(255, 215, 0) or 
                                        Color3.fromRGB(0, 255, 140)
                            CreateESP(descendant, col, itemName)
                        end
                    end
                end
            end
        end
    end
end)

VisualsTab:AddToggle({
    Name = "Entity ESP (Rush / Ambush / Figure / Seek / Screech / Eyes / Halt...)",
    Default = false,
    Callback = function(v)
        EntityESP = v
        OrionLib:MakeNotification({
            Name = "Entity ESP",
            Content = v and "Activated" or "Deactivated",
            Time = 3
        })
    end
})

VisualsTab:AddToggle({
    Name = "Item ESP (Keys / Crucifix / Battery / Books / Lockers...)",
    Default = false,
    Callback = function(v)
        ItemESP = v
        OrionLib:MakeNotification({
            Name = "Item ESP",
            Content = v and "Activated" or "Deactivated",
            Time = 3
        })
    end
})

VisualsTab:AddToggle({
    Name = "Fullbright (remove darkness)",
    Default = false,
    Callback = function(v)
        game.Lighting.Brightness   = v and 2.8 or 1
        game.Lighting.ClockTime    = v and 12 or 18
        game.Lighting.FogEnd       = v and 999999 or 100
        game.Lighting.GlobalShadows = not v
    end
})

-- ──────────────────────────────────────────────────────────────
-- Movement Tab
-- ──────────────────────────────────────────────────────────────
local MoveTab = Window:Tab("Movement", "rbxassetid://4483362458")

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
    Callback = function(v)
        if v then
            game:GetService("RunService").Stepped:Connect(function()
                if v and game.Players.LocalPlayer.Character then
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    end
})

-- Cleanup when ESP off
game:GetService("RunService").Heartbeat:Connect(function()
    if not (EntityESP or ItemESP) then
        for _, entry in ipairs(espObjects) do
            pcall(function()
                entry.hl:Destroy()
                entry.gui:Destroy()
            end)
        end
        espObjects = {}
    end
end)

OrionLib:MakeNotification({
    Name = "DOORS Hub Ready",
    Content = "Toggle Entity / Item ESP in Visuals tab • Use alt account",
    Time = 6
})

print("DOORS Orion ESP loaded - tabs should appear now")
