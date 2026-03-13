-- Simple Aimlock + Box ESP – Toggle with E key
-- Hold right mouse button to activate aimlock when enabled

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local LocalPlayer  = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

local ESP_ENABLED  = false
local AIM_ENABLED  = false
local aimSmooth    = 0.13           -- lower = snappier, higher = smoother/legit
local espBoxes     = {}
local espNames     = {}

print("[E] to toggle ESP + Aimlock")

-- ──────────────────────────────────────────────────────────────
-- Box ESP (2D boxes + name/health)
-- ──────────────────────────────────────────────────────────────
local function addBox(plr)
    if plr == LocalPlayer or espBoxes[plr] then return end

    local box = Drawing.new("Square")
    box.Thickness   = 2
    box.Color       = Color3.fromRGB(255, 80, 255)
    box.Transparency = 0.85
    box.Filled      = false
    box.Visible     = false

    local nametag = Drawing.new("Text")
    nametag.Size    = 14
    nametag.Color   = Color3.new(1,1,1)
    nametag.Outline = true
    nametag.Center  = true
    nametag.Visible = false

    espBoxes[plr] = box
    espNames[plr] = nametag

    local conn = RunService.RenderStepped:Connect(function()
        if not ESP_ENABLED or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.Humanoid.Health <= 0 then
            box.Visible = false
            nametag.Visible = false
            return
        end

        local root = plr.Character.HumanoidRootPart
        local head = plr.Character:FindFirstChild("Head")
        if not head then return end

        local rootPos, visible = Camera:WorldToViewportPoint(root.Position)
        if not visible then
            box.Visible = false
            nametag.Visible = false
            return
        end

        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local legPos  = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))

        local height = math.abs(headPos.Y - legPos.Y)
        local width  = height * 0.55

        box.Size     = Vector2.new(width, height)
        box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        box.Visible  = true

        nametag.Text     = plr.Name .. " [" .. math.floor(plr.Character.Humanoid.Health) .. "]"
        nametag.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 16)
        nametag.Visible  = true
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

-- ──────────────────────────────────────────────────────────────
-- Aimlock (camera smooth lock – hold right mouse)
-- ──────────────────────────────────────────────────────────────
local aimConn
local function toggleAim(state)
    AIM_ENABLED = state

    if state then
        aimConn = RunService.RenderStepped:Connect(function()
            if not AIM_ENABLED or not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

            local closest = nil
            local closestDist = 9999

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Head") then continue end

                local head = plr.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local mousePos = UserInput:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if onScreen and dist < closestDist then
                    closestDist = dist
                    closest = head
                end
            end

            if closest then
                local target = CFrame.new(Camera.CFrame.Position, closest.Position)
                Camera.CFrame = Camera.CFrame:Lerp(target, aimSmooth)
            end
        end)
    else
        if aimConn then aimConn:Disconnect() end
    end
end

-- ──────────────────────────────────────────────────────────────
-- Toggle everything with E
-- ──────────────────────────────────────────────────────────────
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        ESP_ENABLED = not ESP_ENABLED
        AIM_ENABLED = ESP_ENABLED   -- both toggle together

        print("ESP + Aimlock: " .. (ESP_ENABLED and "ON" or "OFF"))

        if ESP_ENABLED then
            -- enable ESP for all current players
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    addBox(plr)
                end
            end
            -- listen for new players
            Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function()
                    if ESP_ENABLED then addBox(plr) end
                end)
            end)
        else
            -- disable ESP
            for _, box in pairs(espBoxes) do box:Remove() end
            for _, txt in pairs(espNames) do txt:Remove() end
            espBoxes = {}
            espNames = {}
        end

        toggleAim(ESP_ENABLED)
    end
end)

print("Loaded – Press E to toggle Box ESP + Aimlock")
print("(hold right mouse button to aimlock when enabled)")
