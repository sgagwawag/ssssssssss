-- Simple Aimlock + Box ESP GUI for DOORS / FPS games – Kavo UI Library
-- No Orion, clean dark theme, mobile touch friendly

local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Kavo:CreateLib("Simple Aim & ESP", "DarkTheme")

-- ──────────────────────────────────────────────────────────────
-- Main Tab
-- ──────────────────────────────────────────────────────────────
local Main = Window:NewTab("Main")
local MainSection = Main:NewSection("Features")

local boxEspEnabled = false
local aimlockEnabled = false
local aimSmooth = 0.14
local espBoxes = {}
local espNames = {}

-- Box ESP function
local function addBoxESP(plr)
    if plr == game.Players.LocalPlayer or espBoxes[plr] then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 80, 255)
    box.Transparency = 0.9
    box.Filled = false
    box.Visible = false

    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Color = Color3.new(1,1,1)
    nameText.Outline = true
    nameText.Center = true
    nameText.Visible = false

    espBoxes[plr] = box
    espNames[plr] = nameText

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not boxEspEnabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.Humanoid.Health <= 0 then
            box.Visible = false
            nameText.Visible = false
            return
        end

        local root = plr.Character.HumanoidRootPart
        local head = plr.Character:FindFirstChild("Head")
        if not head then return end

        local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
        if not onScreen then 
            box.Visible = false
            nameText.Visible = false
            return 
        end

        local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local legPos = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))

        local height = math.abs(headPos.Y - legPos.Y)
        local width = height * 0.55

        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        box.Visible = true

        nameText.Text = plr.Name .. " [" .. math.floor(plr.Character.Humanoid.Health) .. "]"
        nameText.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 16)
        nameText.Visible = true
    end)

    plr.CharacterRemoving:Connect(function()
        if espBoxes[plr] then
            espBoxes[plr]:Remove()
            espNames[plr]:Remove()
            conn:Disconnect()
            espBoxes[plr] = nil
            espNames[plr] = nil
        end
    end)
end

-- Toggle Box ESP
MainSection:NewToggle("Box ESP + Name/Health", "Shows 2D boxes around players", function(state)
    boxEspEnabled = state

    if state then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character then
                addBoxESP(plr)
            end
        end

        game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                if boxEspEnabled then addBoxESP(plr) end
            end)
        end)
    else
        for _, box in pairs(espBoxes) do box:Remove() end
        for _, txt in pairs(espNames) do txt:Remove() end
        espBoxes = {}
        espNames = {}
    end
end)

-- Aimlock toggle + logic
local aimlockConn
MainSection:NewToggle("Aimlock (hold right mouse)", "Smooth camera lock to closest enemy head", function(state)
    aimlockEnabled = state

    if state then
        aimlockConn = game:GetService("RunService").RenderStepped:Connect(function()
            if not aimlockEnabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

            local closest = nil
            local closestDist = 9999

            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr == game.Players.LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Head") then continue end

                local head = plr.Character.Head
                local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if visible and dist < closestDist then
                    closestDist = dist
                    closest = head
                end
            end

            if closest then
                local targetCF = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetCF, aimSmooth)
            end
        end)
    else
        if aimlockConn then aimlockConn:Disconnect() end
    end
end)

-- Extra toggle for smoothness
MainSection:NewSlider("Aimlock Smoothness", "Lower = snappier aim", 100, 1, function(value)
    aimSmooth = value / 100  -- 0.01 to 1.00
end, 14)  -- default 0.14

Kavo:ToggleUI()  -- optional: auto open/close with insert key or whatever your executor binds

print("Simple Aimlock + Box ESP GUI loaded – hold right mouse to aimlock")
