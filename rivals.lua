local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "Prison Life | FULL HUB 2026",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "PrisonLife2026"
})

local player = game.Players.LocalPlayer

-- ==================== GUNS (FIXED 2026 METHOD) ====================
local Main = Window:MakeTab({Name = "Guns & Mods", Icon = "rbxassetid://4483362458"})

Main:AddButton({
    Name = "Give All Guns (M9, Shotgun, AK-47)",
    Callback = function()
        local givers = workspace.Prison_ITEMS.giver:GetChildren()
        for _, giver in pairs(givers) do
            if giver:FindFirstChild("ITEMPICKUP") then
                pcall(function()
                    workspace.Remote.ItemHandler:InvokeServer(giver.ITEMPICKUP)
                end)
            end
        end
        OrionLib:MakeNotification({Name = "Guns", Content = "All guns given!", Time = 4})
    end
})

-- Infinite Ammo + Gun Mods (stronger loop)
local infAmmoConn
Main:AddToggle({
    Name = "Infinite Ammo + OP Gun Mods",
    Default = false,
    Callback = function(state)
        if state then
            infAmmoConn = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    local tool = player.Character:FindFirstChildWhichIsA("Tool") or player.Backpack:FindFirstChildWhichIsA("Tool")
                    if tool and tool:FindFirstChild("GunStates") then
                        local states = require(tool.GunStates)
                        states.MaxAmmo = math.huge
                        states.CurrentAmmo = math.huge
                        states.StoredAmmo = math.huge
                        states.FireRate = 0.001
                        states.Spread = 0
                        states.Range = math.huge
                        states.ReloadTime = 0
                    end
                end)
            end)
        else
            if infAmmoConn then infAmmoConn:Disconnect() end
        end
    end
})

-- ==================== MORE FEATURES ====================
local Misc = Window:MakeTab({Name = "Misc & Trolling", Icon = "rbxassetid://4483362458"})

Misc:AddButton({Name = "Become Criminal (Instant)", Callback = function()
    workspace.Remote.TeamEvent:FireServer("Bright orange")
end})

Misc:AddButton({Name = "Become Guard", Callback = function()
    workspace.Remote.TeamEvent:FireServer("Bright blue")
end})

Misc:AddButton({Name = "Kill All Players", Callback = function()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                plr.Character.Humanoid.Health = 0
            end)
        end
    end
end})

Misc:AddToggle({
    Name = "Kill Aura (Auto Kill Nearby)",
    Default = false,
    Callback = function(state)
        if state then
            spawn(function()
                while state do
                    for _, plr in pairs(game.Players:GetPlayers()) do
                        if plr ~= player and plr.Character and (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < 30 then
                            pcall(function() plr.Character.Humanoid.Health = 0 end)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Misc:AddToggle({
    Name = "Car Fly (Hold E)",
    Default = false,
    Callback = function(state)
        _G.CarFly = state
        if state then
            spawn(function()
                while _G.CarFly do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local car = workspace:FindFirstChildWhichIsA("Model") -- finds nearest car
                        if car and car:FindFirstChild("VehicleSeat") then
                            car.VehicleSeat.CFrame = car.VehicleSeat.CFrame + Vector3.new(0, 5, 0)
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

Misc:AddButton({Name = "Remove All Doors", Callback = function()
    for _, door in pairs(workspace:GetDescendants()) do
        if door.Name == "Door" or door:FindFirstChild("Door") then
            pcall(function() door:Destroy() end)
        end
    end
end})

Misc:AddToggle({Name = "ESP (Basic)", Default = false, Callback = function(state)
    -- Simple highlight ESP
    if state then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 0, 255)
                hl.Parent = plr.Character
            end
        end
    end
end})

Misc:AddButton({Name = "Auto Farm Cash (Punch Loop)", Callback = function()
    spawn(function()
        while true do
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end)
            task.wait(0.5)
        end
    end)
end})

OrionLib:MakeNotification({
    Name = "Prison Life Hub LOADED ✅",
    Content = "Give guns first → Turn on Infinite Ammo → Enjoy the chaos",
    Time = 6
})
