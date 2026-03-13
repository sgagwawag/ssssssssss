local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "Prison Life | Full Hub 2026",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "PrisonLifeHub"
})

local Main = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local player = game.Players.LocalPlayer

-- ==================== GUNS ====================
Main:AddButton({
    Name = "Give All Guns (M9 + Shotgun + AK)",
    Callback = function()
        local guns = {"M9", "Remington 870", "AK-47"}
        for _, gun in pairs(guns) do
            pcall(function()
                workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver[gun].ITEMPICKUP)
            end)
        end
        OrionLib:MakeNotification({Name = "Guns", Content = "All guns given!", Time = 3})
    end
})

-- ==================== INFINITE AMMO ====================
local infAmmoConn
Main:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(state)
        if state then
            infAmmoConn = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    local tool = player.Backpack:FindFirstChildWhichIsA("Tool") or player.Character:FindFirstChildWhichIsA("Tool")
                    if tool and tool:FindFirstChild("GunStates") then
                        local states = require(tool.GunStates)
                        states.MaxAmmo = math.huge
                        states.CurrentAmmo = math.huge
                        states.StoredAmmo = math.huge
                        states.FireRate = 0.001
                        states.Spread = 0
                        states.ReloadTime = 0.001
                    end
                end)
            end)
            OrionLib:MakeNotification({Name = "Infinite Ammo", Content = "ON - Hold any gun", Time = 3})
        else
            if infAmmoConn then infAmmoConn:Disconnect() end
            OrionLib:MakeNotification({Name = "Infinite Ammo", Content = "OFF", Time = 3})
        end
    end
})

-- ==================== OTHER FEATURES ====================
Main:AddToggle({
    Name = "Godmode (No Damage)",
    Default = false,
    Callback = function(v)
        if v then
            spawn(function()
                while v and task.wait(0.1) do
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.Health = 100
                    end
                end
            end)
        end
    end
})

Main:AddToggle({
    Name = "Fly (WASD + Space)",
    Default = false,
    Callback = function(v)
        _G.Fly = v
        if v then
            spawn(function()
                local root = player.Character.HumanoidRootPart
                local bv = Instance.new("BodyVelocity") bv.MaxForce = Vector3.new(1e5,1e5,1e5) bv.Parent = root
                local bg = Instance.new("BodyGyro") bg.MaxTorque = Vector3.new(1e5,1e5,1e5) bg.Parent = root
                while _G.Fly do
                    local cam = workspace.CurrentCamera
                    local dir = Vector3.new()
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    bv.Velocity = dir * 60
                    bg.CFrame = cam.CFrame
                    task.wait()
                end
                bv:Destroy() bg:Destroy()
            end)
        end
    end
})

Main:AddSlider({Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Callback = function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end
end})

Main:AddToggle({Name = "Noclip", Default = false, Callback = function(v)
    if v then
        game:GetService("RunService").Stepped:Connect(function()
            if v and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end})

Main:AddButton({Name = "Remove Handcuffs", Callback = function()
    if player.Character and player.Character:FindFirstChild("Handcuffs") then
        player.Character.Handcuffs:Destroy()
    end
end})

Main:AddButton({Name = "Arrest All Players", Callback = function()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            pcall(function()
                workspace.Remote.arrest:InvokeServer(plr.Character)
            end)
        end
    end
end})

OrionLib:MakeNotification({
    Name = "Prison Life Hub Loaded",
    Content = "Give guns + Infinite Ammo ready! Enjoy king",
    Time = 5
})
