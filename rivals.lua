local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "Rivals | ESP + Aimbot",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "RivalsHub2026"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Variables
local ESP_ENABLED = false
local AIM_ENABLED = false
local AIM_SMOOTHNESS = 0.15
local AIM_FOV = 150
local AIM_PART = "Head"
local TEAM_CHECK = true

local highlights = {}
local aimConnection = nil

-- ==================== ESP ====================
Tab:AddToggle({
    Name = "ESP (Highlight + Name + Distance)",
    Default = false,
    Callback = function(Value)
        ESP_ENABLED = Value
        
        if Value then
            OrionLib:MakeNotification({Name = "ESP", Content = "Enabled", Time = 3})
            
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character then
                    spawn(function() addESP(plr) end)
                end
            end
        else
            OrionLib:MakeNotification({Name = "ESP", Content = "Disabled", Time = 3})
            for _, v in pairs(highlights) do v:Destroy() end
            highlights = {}
        end
    end
})

function addESP(plr)
    if highlights[plr] then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 50, 255)
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.4
    hl.Parent = plr.Character
    
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0,200,0,60)
    bg.StudsOffset = Vector3.new(0,3,0)
    bg.AlwaysOnTop = true
    bg.Parent = plr.Character:FindFirstChild("Head") or plr.Character
    
    local name = Instance.new("TextLabel", bg)
    name.Size = UDim2.new(1,0,0.5,0)
    name.BackgroundTransparency = 1
    name.Text = plr.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.TextScaled = true
    
    local dist = Instance.new("TextLabel", bg)
    dist.Size = UDim2.new(1,0,0.5,0)
    dist.Position = UDim2.new(0,0,0.5,0)
    dist.BackgroundTransparency = 1
    dist.TextColor3 = Color3.new(1,1,0)
    dist.TextScaled = true
    
    highlights[plr] = {hl, bg, dist}
end

-- Update distance loop
game:GetService("RunService").RenderStepped:Connect(function()
    if not ESP_ENABLED then return end
    for plr, data in pairs(highlights) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            data[3].Text = "Dist: " .. math.floor(d)
        end
    end
end)

-- ==================== AIMBOT ====================
Tab:AddToggle({
    Name = "Aimbot (Camera)",
    Default = false,
    Callback = function(Value)
        AIM_ENABLED = Value
        
        if Value then
            OrionLib:MakeNotification({Name = "Aimbot", Content = "Enabled - Hold mouse to aim", Time = 3})
            
            aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not AIM_ENABLED then return end
                
                local closest = nil
                local closestDist = AIM_FOV
                
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr == game.Players.LocalPlayer or not plr.Character or not plr.Character:FindFirstChild(AIM_PART) then continue end
                    if TEAM_CHECK and plr.Team == game.Players.LocalPlayer.Team then continue end
                    
                    local part = plr.Character[AIM_PART]
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if onScreen and dist < closestDist then
                        closestDist = dist
                        closest = part
                    end
                end
                
                if closest then
                    local targetCFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetCFrame, AIM_SMOOTHNESS)
                end
            end)
        else
            OrionLib:MakeNotification({Name = "Aimbot", Content = "Disabled", Time = 3})
            if aimConnection then aimConnection:Disconnect() end
        end
    end
})

-- Settings
Tab:AddSlider({
    Name = "Aimbot Smoothness",
    Min = 0.05,
    Max = 0.5,
    Default = 0.15,
    Increment = 0.01,
    Callback = function(Value) AIM_SMOOTHNESS = Value end
})

Tab:AddSlider({
    Name = "Aimbot FOV",
    Min = 50,
    Max = 400,
    Default = 150,
    Increment = 10,
    Callback = function(Value) AIM_FOV = Value end
})

Tab:AddDropdown({
    Name = "Aim Part",
    Default = "Head",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    Callback = function(Value) AIM_PART = Value end
})

Tab:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(Value) TEAM_CHECK = Value end
})

print("Rivals ESP + Aimbot loaded! Open the Orion menu and toggle.")
