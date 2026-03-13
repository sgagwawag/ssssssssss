-- UNIVERSAL ESP + NEAREST PLAYER AIMBOT (3D Lock-On) - Ready for loadstring
if not game:IsLoaded() then game.Loaded:Wait() end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "Universal ESP + Nearest Aimbot",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalNearestHub"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Variables
local ESP_ENABLED = false
local AIM_ENABLED = false
local AIM_SMOOTHNESS = 0.18
local MAX_AIM_DISTANCE = 250
local AIM_PART = "Head"
local TEAM_CHECK = true

local highlights = {}
local aimConnection = nil

-- ==================== ESP ====================
local function addESP(plr)
    if highlights[plr] or plr == game.Players.LocalPlayer then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    if not char then return end
    
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 80, 255)
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.45
    hl.Parent = char
    
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 220, 0, 60)
    bg.StudsOffset = Vector3.new(0, 3.5, 0)
    bg.AlwaysOnTop = true
    bg.Parent = char:FindFirstChild("Head") or char
    
    local nameLabel = Instance.new("TextLabel", bg)
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextScaled = true
    
    local distLabel = Instance.new("TextLabel", bg)
    distLabel.Size = UDim2.new(1,0,0.5,0)
    distLabel.Position = UDim2.new(0,0,0.5,0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.new(1,1,0)
    distLabel.TextScaled = true
    
    highlights[plr] = {hl, bg, distLabel}
end

MainTab:AddToggle({
    Name = "ESP (Highlight + Name + Distance)",
    Default = false,
    Callback = function(v)
        ESP_ENABLED = v
        OrionLib:MakeNotification({Name = "ESP", Content = v and "ON" or "OFF", Time = 3})
        if v then
            for _, plr in pairs(game.Players:GetPlayers()) do spawn(function() addESP(plr) end) end
        else
            for _, data in pairs(highlights) do for _, obj in ipairs(data) do obj:Destroy() end end
            highlights = {}
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if not ESP_ENABLED then return end
    for plr, data in pairs(highlights) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            data[3].Text = "Dist: " .. math.floor(d)
        end
    end
end)

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() if ESP_ENABLED then addESP(plr) end end)
end)

-- ==================== NEAREST PLAYER AIMBOT (3D Lock) ====================
MainTab:AddToggle({
    Name = "Aimbot - Lock on Nearest Player",
    Default = false,
    Callback = function(v)
        AIM_ENABLED = v
        OrionLib:MakeNotification({Name = "Nearest Aimbot", Content = v and "ON (locks nearest)" or "OFF", Time = 3})
        
        if v then
            aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not AIM_ENABLED then return end
                
                local myRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                
                local closestPart = nil
                local closestDist = MAX_AIM_DISTANCE
                
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr == game.Players.LocalPlayer or not plr.Character or not plr.Character:FindFirstChild(AIM_PART) then continue end
                    if TEAM_CHECK and plr.Team == game.Players.LocalPlayer.Team then continue end
                    
                    local part = plr.Character[AIM_PART]
                    local dist = (part.Position - myRoot.Position).Magnitude
                    
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = part
                    end
                end
                
                if closestPart then
                    local targetCF = CFrame.new(workspace.CurrentCamera.CFrame.Position, closestPart.Position)
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetCF, AIM_SMOOTHNESS)
                end
            end)
        else
            if aimConnection then aimConnection:Disconnect() end
        end
    end
})

-- Settings
MainTab:AddSlider({Name = "Aimbot Smoothness", Min = 0.05, Max = 0.6, Default = 0.18, Increment = 0.01, Callback = function(v) AIM_SMOOTHNESS = v end})
MainTab:AddSlider({Name = "Max Aim Distance (studs)", Min = 50, Max = 500, Default = 250, Increment = 10, Callback = function(v) MAX_AIM_DISTANCE = v end})
MainTab:AddDropdown({Name = "Aim Part", Default = "Head", Options = {"Head","UpperTorso","HumanoidRootPart","LowerTorso"}, Callback = function(v) AIM_PART = v end})
MainTab:AddToggle({Name = "Team Check", Default = true, Callback = function(v) TEAM_CHECK = v end})

print("Universal Nearest Aimbot loaded - locks on the closest player in 3D space")
