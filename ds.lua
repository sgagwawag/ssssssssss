-- SIMPLE BLAZING AIMBOT + BOX ESP + FOV CIRCLE + AUTO SHOOT
-- Toggle everything ON/OFF with E key
-- Team check enabled • Super blatant snap aim • Auto shoots when locked

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local ENABLED     = false
local aimSmooth   = 0.06          -- SUPER SNAPPY / BLATANT (lower = faster snap)
local aimFOV      = 140           -- Aim range (smaller = more legit, bigger = easier)

local espBoxes    = {}
local espNames    = {}
local fovCircle   = nil

print("🔥 Press E to toggle Blatant Aim + Box ESP + Auto Shoot")

-- Create FOV Circle
fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = aimFOV
fovCircle.Color = Color3.fromRGB(255, 80, 255)
fovCircle.Transparency = 0.7
fovCircle.Filled = false
fovCircle.Visible = false

-- Box ESP (only enemies)
local function createBoxESP(plr)
    if plr == LocalPlayer or espBoxes[plr] then return end
    if plr.Team == LocalPlayer.Team then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 80, 255)
    box.Transparency = 0.9
    box.Filled = false
    box.Visible = false

    local nameTag = Drawing.new("Text")
    nameTag.Size = 14
    nameTag.Color = Color3.new(1,1,1)
    nameTag.Outline = true
    nameTag.Center = true
    nameTag.Visible = false

    espBoxes[plr] = box
    espNames[plr] = nameTag
end

-- Update ESP + Aimlock + Auto Shoot loop
RunService.RenderStepped:Connect(function()
    if not ENABLED then return end

    -- Update FOV circle
    fovCircle.Position = UserInput:GetMouseLocation()
    fovCircle.Visible = true

    local closestTarget = nil
    local closestDist = aimFOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Head") then continue end
        if plr.Team == LocalPlayer.Team then continue end

        local head = plr.Character.Head
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local mousePos = UserInput:GetMouseLocation()
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

        -- Box ESP update
        if espBoxes[plr] then
            local root = plr.Character.HumanoidRootPart
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legPos  = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))

            local height = math.abs(headPos.Y - legPos.Y)
            local width  = height * 0.55

            espBoxes[plr].Size     = Vector2.new(width, height)
            espBoxes[plr].Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
            espBoxes[plr].Visible  = onScreen

            espNames[plr].Text     = plr.Name .. " [" .. math.floor(plr.Character.Humanoid.Health) .. "]"
            espNames[plr].Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 16)
            espNames[plr].Visible  = onScreen
        end

        -- Aimbot target
        if onScreen and dist < closestDist then
            closestDist = dist
            closestTarget = head
        end
    end

    -- Blatant Aimlock + Auto Shoot
    if closestTarget and UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetCF = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimSmooth)

        -- AUTO SHOOT (fires whatever gun/tool you are holding)
        local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
        if tool then
            tool:Activate()
        end
    end
end)

-- Toggle with E key
UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        ENABLED = not ENABLED
        fovCircle.Visible = ENABLED

        print("Blatant Aim + Box ESP + Auto Shoot: " .. (ENABLED and "ON 🔥" or "OFF"))

        if ENABLED then
            -- Create ESP for current players
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then createBoxESP(plr) end
            end
            -- New players
            Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function() if ENABLED then createBoxESP(plr) end end)
            end)
        else
            -- Cleanup ESP
            for _, box in pairs(espBoxes) do box:Remove() end
            for _, txt in pairs(espNames) do txt:Remove() end
            espBoxes = {}
            espNames = {}
        end
    end
end)

-- Auto create ESP when players join
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() if ENABLED then createBoxESP(plr) end end)
end)

print("Script loaded! Press E to toggle everything.")
