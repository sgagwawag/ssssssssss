-- DOORS | ImGui Style ESP Hub (Linoria) – Delta Mobile Ready 2026

local Linoria = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

local Window = Linoria:CreateWindow({
    Name = "DOORS | ImGui ESP Hub",
    Size = UDim2.new(0, 460, 0, 600),
    Theme = "Dark" -- ImGui clean dark look
})

-- Variables
local entityESP = false
local itemESP = false
local highlights = {}

local entities = {"RushMoving", "AmbushMoving", "Seek", "FigureRig", "Screech", "Eyes", "Halt", "Dupe", "Jack", "Timothy", "Snare"}
local items = {"KeyObtain", "LeverForGate", "LiveHintBook", "Battery", "Flashlight", "Lighter", "Crucifix", "Lockpick", "Fuse", "Wardrobe", "Bed"}

-- ==================== ESP FUNCTIONS ====================
local function createESP(part, color, text)
    if part:FindFirstChild("ESP_Highlight") then return end
    
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.Parent = part
    
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 4, 0)
    bg.AlwaysOnTop = true
    bg.Parent = part:FindFirstChild("Head") or part
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bg
    
    table.insert(highlights, {hl, bg})
end

local function updateESP()
    while true do
        task.wait(0.8)
        if not (entityESP or itemESP) then continue end
        
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, obj in pairs(room:GetDescendants()) do
                -- Entity ESP
                if entityESP then
                    for _, name in pairs(entities) do
                        if obj.Name == name or obj:FindFirstChild(name) then
                            createESP(obj, Color3.fromRGB(255, 50, 50), obj.Name .. " ⚠️")
                        end
                    end
                end
                
                -- Item ESP
                if itemESP then
                    for _, name in pairs(items) do
                        if obj.Name == name or string.find(obj.Name, name) then
                            local col = (name == "KeyObtain" or name == "Crucifix") and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 255, 100)
                            createESP(obj, col, name)
                        end
                    end
                end
            end
        end
    end
end

-- ==================== UI TABS ====================
local Visuals = Window:CreateTab("Visuals 👁️")

Visuals:CreateToggle({
    Name = "Entity ESP (Rush, Ambush, Figure, Seek...)",
    Default = false,
    Callback = function(v) entityESP = v end
})

Visuals:CreateToggle({
    Name = "Item ESP (Keys, Levers, Crucifix, Batteries...)",
    Default = false,
    Callback = function(v) itemESP = v end
})

Visuals:CreateToggle({
    Name = "Fullbright (No Darkness)",
    Default = false,
    Callback = function(v)
        game.Lighting.Brightness = v and 2 or 1
        game.Lighting.ClockTime = v and 12 or 20
        game.Lighting.FogEnd = v and 999999 or 100
    end
})

local Movement = Window:CreateTab("Movement ⚡")

Movement:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(v)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

Movement:CreateToggle({
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

-- Start ESP loop
spawn(updateESP)

Linoria:Notify("DOORS ESP Hub Loaded", "Entity + Item ESP active • Use on alt account", 5)

print("DOORS ImGui-style ESP loaded • Press RightCtrl to open menu")
