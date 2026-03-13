-- Universal Rivals ESP + Aimbot (Orion UI) - 2026 mobile/PC compatible
-- Paste into Pastebin/GitHub → use loadstring(game:HttpGet("your_raw_link"))()

if not game:IsLoaded() then game.Loaded:Wait() end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "Universal ESP + Aimbot",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHub"
})

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main Features",
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
function addESP(plr)
    if highlights[plr] or plr == game.Players.LocalPlayer then return end
    
    local char = plr.Character or plr.CharacterAdded:Wait()
    if not char then return end
    
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 80, 255)
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.Parent = char
    
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 220, 0, 60)
    bg.StudsOffset = Vector3.new(0, 3.5, 0)
    bg.AlwaysOnTop = true
    bg.Parent = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
    
    local nameLabel = Instance.new("TextLabel", bg)
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    
    local distLabel = Instance.new("TextLabel", bg)
    distLabel.Size = UDim2.new(1,0,0.5,0)
    distLabel.Position = UDim2.new(0,0,0.5,0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.new(1,1,0)
    distLabel.TextScaled = true
    
    highlights[plr] = {hl, bg, distLabel}
end

-- ESP toggle
MainTab:AddToggle({
    Name = "Player ESP (Highlight + Name + Distance)",
    Default = false,
    Callback = function(Value)
        ESP_ENABLED = Value
        OrionLib:MakeNotification({
            Name = "ESP",
            Content = Value and "Enabled" or "Disabled",
            Time = 3
        })
        
        if Value then
            for _, plr in pairs(game.Players:GetPlayers()) do
                spawn(function() addESP(plr) end)
            end
        else
            for _, data in pairs(highlights) do
                for _, obj in ipairs(data) do obj:Destroy() end
            end
            highlights = {}
        end
    end
})

-- Distance update
game:GetService("RunService").RenderStepped:Connect(function()
    if not ESP_ENABLED then return end
    for plr, data in pairs(highlights) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            data[3].Text = "Dist: " .. math.floor(dist) .. " studs"
        end
    end
end)

-- Auto-add new players
game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() if ESP_ENABLED then addESP(plr) end end)
end)

-- ==================== AIMBOT ====================
MainTab:AddToggle({
    Name = "Smooth Aimbot (Camera)",
    Default = false,
    Callback = function(Value)
        AIM_ENABLED = Value
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = Value and "Enabled" or "Disabled",
            Time = 3
        })
        
        if Value then
            aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not AIM_ENABLED then return end
                
                local closest, closestDist = nil, AIM_FOV
                
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr == game.Players.LocalPlayer or not plr.Character or not plr.Character:FindFirstChild(AIM_PART) then continue end
                    if TEAM_CHECK and plr.Team == game.Players.LocalPlayer.Team then continue end
                    
                    local part = plr.Character[AIM_PART]
                    local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if visible and dist < closestDist then
                        closestDist = dist
                        closest = part
                    end
                end
                
                if closest then
                    local targetCF = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetCF, AIM_SMOOTHNESS)
                end
            end)
        else
            if aimConnection then aimConnection:Disconnect() aimConnection = nil end
        end
    end
})

-- Settings
MainTab:AddSlider({
    Name = "Aimbot Smoothness (lower = snappier)",
    Min = 0.05,
    Max = 0.6,
    Default = 0.15,
    Increment = 0.01,
    Callback = function(v) AIM_SMOOTHNESS = v end
})

MainTab:AddSlider({
    Name = "Aimbot FOV",
    Min = 40,
    Max = 500,
    Default = 150,
    Increment = 5,
    Callback = function(v) AIM_FOV = v end
})

MainTab:AddDropdown({
    Name = "Aim Part",
    Default = "Head",
    Options = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
    Callback = function(v) AIM_PART = v end
})

MainTab:AddToggle({
    Name = "Team Check (Don't aim teammates)",
    Default = true,
    Callback = function(v) TEAM_CHECK = v end
})

print("Universal ESP + Aimbot loaded - works in most FPS games with humanoid characters")
