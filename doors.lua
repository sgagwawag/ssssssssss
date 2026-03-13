local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "DOORS | ESP + Utility",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DoorsHub"
})

-- ────────────────────────────────────────────────
-- Use :Tab instead of :MakeTab
-- ────────────────────────────────────────────────

local Visuals = Window:Tab("Visuals", "rbxassetid://4483362458")

local EntityESP = false
local ItemESP = false
local espTable = {}

-- (keep your entities/items tables the same)

local function CreateESP(parent, color, text)
    -- same function as before
end

spawn(function()
    while true do
        task.wait(0.9)
        if not (EntityESP or ItemESP) then continue end
        -- same scanning loop as before
    end
end)

Visuals:AddToggle({
    Name = "Entity ESP (Rush, Ambush, Figure, Seek, etc)",
    Default = false,
    Callback = function(v) EntityESP = v end
})

Visuals:AddToggle({
    Name = "Item ESP (Keys, Crucifix, Battery, etc)",
    Default = false,
    Callback = function(v) ItemESP = v end
})

Visuals:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(v)
        game.Lighting.Brightness = v and 3 or 1
        game.Lighting.ClockTime = v and 12 or 18
        game.Lighting.FogEnd = v and 999999 or 100
    end
})

local Movement = Window:Tab("Movement", "rbxassetid://4483362458")

Movement:AddSlider({
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

Movement:AddToggle({
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
    Name = "Loaded",
    Content = "DOORS ESP + Movement • Use alt account",
    Time = 5
})
