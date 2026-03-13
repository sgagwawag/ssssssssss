local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "DOORS | ESP Hub 2026",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DoorsESP"
})

local MainTab = Window:MakeTab({
    Name = "ESP & Visuals",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

-- Variables
local EntityESP = false
local ItemESP = false
local espObjects = {}

-- Entity & Item names (updated for current DOORS 2026 - Hotel + Mines)
local entities = {"RushMoving", "AmbushMoving", "SeekMoving", "FigureRig", "Screech", "Eyes", "Halt", "Dupe", "Jack", "Timothy", "Snare"}
local items = {"KeyObtain", "Crucifix", "Battery", "Flashlight", "Lighter", "Lockpick", "LiveHintBook", "Fuse", "LeverForGate", "Wardrobe", "Bed"}

-- Create ESP highlight + label
local function addESP(obj, color, labelText)
    if obj:FindFirstChild("DOORS_ESP") then return end
    
    local hl = Instance.new("Highlight")
    hl.Name = "DOORS_ESP"
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.Parent = obj
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DOORS_Label"
    billboard.Size = UDim2.new(0, 180, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj.PrimaryPart or obj:FindFirstChild("Main") or obj
    
    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = labelText
    text.TextColor3 = color
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    
    table.insert(espObjects, {hl = hl, gui = billboard})
end

-- Main ESP update loop
spawn(function()
    while true do
        task.wait(1)
        if not (EntityESP or ItemESP) then continue end
        
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, descendant in pairs(room:GetDescendants()) do
                -- Entity check
                if EntityESP then
                    for _, ent in ipairs(entities) do
                        if descendant.Name == ent or descendant:FindFirstChild(ent) then
                            local displayName = ent:gsub("Moving", ""):gsub("Rig", "")
                            addESP(descendant, Color3.fromRGB(255, 40, 40), displayName .. " ⚠️")
                        end
                    end
                end
                
                -- Item check
                if ItemESP then
                    for _, itm in ipairs(items) do
                        if descendant.Name == itm or string.find(descendant.Name:lower(), itm:lower()) then
                            local col = (itm == "KeyObtain" or itm == "Crucifix") and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 255, 150)
                            addESP(descendant, col, itm)
                        end
                    end
                end
            end
        end
    end
end)

-- Toggles
MainTab:AddToggle({
    Name = "Entity ESP (Rush, Ambush, Figure, Seek, Screech...)",
    Default = false,
    Callback = function(v) EntityESP = v end
})

MainTab:AddToggle({
    Name = "Item ESP (Keys, Crucifix, Battery, Books...)",
    Default = false,
    Callback = function(v) ItemESP = v end
})

MainTab:AddToggle({
    Name = "Fullbright (No Darkness)",
    Default = false,
    Callback = function(v)
        game.Lighting.Brightness = v and 3 or 1
        game.Lighting.ClockTime = v and 12 or 18
        game.Lighting.FogEnd = v and 99999 or 100
    end
})

-- Movement tab extras
local MoveTab = Window:MakeTab({Name = "Movement"})

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

OrionLib:MakeNotification({
    Name = "DOORS Hub Loaded",
    Content = "Entity & Item ESP ready • Toggle in menu",
    Time = 5
})

print("DOORS ESP Hub loaded - Use alt account")
