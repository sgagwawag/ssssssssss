local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "Blatant Aim + Box ESP",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "BlatantHub"
})

-- Main Tab
local MainTab = Window:Tab("Main", "rbxassetid://4483362458")

-- Variables
local Enabled = false
local aimSmooth = 0.04          -- very blatant / near-instant snap
local aimFOV = 180
local autoShoot = true

local espBoxes = {}
local espNames = {}

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = aimFOV
fovCircle.Color = Color3.fromRGB(255, 80, 255)
fovCircle.Transparency = 0.7
fovCircle.Filled = false
fovCircle.Visible = false

-- Create box for player (only enemies)
local function CreateBox(plr)
    if plr == game.Players.LocalPlayer or espBoxes[plr] then return end
    if plr.Team == game.Players.LocalPlayer.Team then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 80, 255)
    box.Transparency = 0.9
    box.Filled = false
    box.Visible = false

    local nametag = Drawing.new("Text")
    nametag.Size = 14
    nametag.Color = Color3.new(1,1,1)
    nametag.Outline = true
    nametag.Center = true
    nametag.Visible = false

    espBoxes[plr] = box
    espNames[plr] = nametag
end

-- Main loop: ESP + Aimbot + Auto Shoot
RunService.RenderStepped:Connect(function()
    if not Enabled then
        fovCircle.Visible = false
        return
    end

    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Visible = true

    local closest = nil
    local closestDist = aimFOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == game.Players.LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Head") then continue end
        if plr.Team == game.Players.LocalPlayer.Team then continue end

        local head = plr.Character.Head
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local headPos, visible = Camera:WorldToViewportPoint(head.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude

        -- Box ESP update
        if espBoxes[plr] then
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local headP = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legP  = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))

            local height = math.abs(headP.Y - legP.Y)
            local width  = height * 0.55

            espBoxes[plr].Size     = Vector2.new(width, height)
            espBoxes[plr].Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
            espBoxes[plr].Visible  = visible

            espNames[plr].Text     = plr.Name .. " [" .. math.floor(plr.Character.Humanoid.Health) .. "]"
            espNames[plr].Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 16)
            espNames[plr].Visible  = visible
        end

        -- Find aim target
        if visible and dist < closestDist then
            closestDist = dist
            closest = head
        end
    end

    -- Blatant aimlock + auto shoot
    if closest and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetCF = CFrame.new(Camera.CFrame.Position, closest.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimSmooth)

        if autoShoot then
            local tool = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end)

-- UI Controls
MainTab:AddToggle({
    Name = "Enable Blatant Aimbot + Box ESP + Auto Shoot",
    Default = false,
    Callback = function(state)
        Enabled = state
        fovCircle.Visible = state

        if state then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer then
                    CreateBox(plr)
                end
            end

            Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function()
                    if Enabled then CreateBox(plr) end
                end)
            end)
        else
            for _, b in pairs(espBoxes) do b:Remove() end
            for _, t in pairs(espNames) do t:Remove() end
            espBoxes = {}
            espNames = {}
        end
    end
})

MainTab:AddSlider({
    Name = "Aim Smoothness (lower = snappier)",
    Min = 1,
    Max = 50,
    Default = 5,
    Increment = 1,
    Callback = function(v)
        aimSmooth = v / 100
    end
})

MainTab:AddSlider({
    Name = "Aim FOV",
    Min = 50,
    Max = 400,
    Default = 180,
    Increment = 10,
    Callback = function(v)
        aimFOV = v
        fovCircle.Radius = v
    end
})

MainTab:AddToggle({
    Name = "Auto Shoot (when locked)",
    Default = true,
    Callback = function(state)
        autoShoot = state
    end
})

OrionLib:MakeNotification({
    Name = "Loaded",
    Content = "Blatant Aimbot + Box ESP • Hold RMB to aim + shoot",
    Time = 5
})

print("Blatant aimbot + box ESP loaded – use the UI toggle")
