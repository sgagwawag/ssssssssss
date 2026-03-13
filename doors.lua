-- Simple DOORS / Universal FPS GUI – Box ESP + Aimlock
-- No external libraries, no tabs, no complicated UI

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local LocalPlayer   = Players.LocalPlayer
local Camera        = workspace.CurrentCamera

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "SimpleAimGUI"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 180)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = sg

-- Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(40,40,50)
title.Text = "Simple Aim & ESP"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Draggable
local dragging, dragInput, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInput.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Content frame
local content = Instance.new("Frame")
content.Size = UDim2.new(1,0,1,-30)
content.Position = UDim2.new(0,0,0,30)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0,8)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = content

-- Helper function for toggles
local function createToggle(name, yOffset, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.92, 0, 0, 32)
    toggle.Position = UDim2.new(0.04, 0, 0, yOffset)
    toggle.BackgroundColor3 = Color3.fromRGB(45,45,55)
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 15
    toggle.Parent = content

    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = name .. ": " .. (enabled and "ON" or "OFF")
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(60,140,80) or Color3.fromRGB(45,45,55)
        callback(enabled)
    end)

    return toggle
end

-- ──────────────────────
-- Box ESP
-- ──────────────────────
local boxEspEnabled = false
local boxConnections = {}

local function createBox(plr)
    if plr == LocalPlayer or boxConnections[plr] then return end

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

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not boxEspEnabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then
            box.Visible = false
            nameTag.Visible = false
            return
        end

        local root = plr.Character.HumanoidRootPart
        local head = plr.Character:FindFirstChild("Head")
        if not head then return end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            box.Visible = false
            nameTag.Visible = false
            return
        end

        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))

        local height = math.abs(headPos.Y - legPos.Y)
        local width = height * 0.55

        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        box.Visible = true

        nameTag.Text = plr.Name .. " [" .. math.floor(plr.Character.Humanoid.Health) .. "]"
        nameTag.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 16)
        nameTag.Visible = true
    end)

    boxConnections[plr] = {box = box, name = nameTag, conn = conn}

    plr.CharacterRemoving:Connect(function()
        if boxConnections[plr] then
            boxConnections[plr].conn:Disconnect()
            boxConnections[plr].box:Remove()
            boxConnections[plr].name:Remove()
            boxConnections[plr] = nil
        end
    end)
end

-- Box ESP toggle
createToggle("Box ESP", 10, function(enabled)
    boxEspEnabled = enabled

    if enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                createBox(plr)
            end
        end

        Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                if boxEspEnabled then createBox(plr) end
            end)
        end)
    else
        for _, data in pairs(boxConnections) do
            data.conn:Disconnect()
            data.box:Remove()
            data.name:Remove()
        end
        boxConnections = {}
    end
end)

-- ──────────────────────
-- Aimlock
-- ──────────────────────
local aimlockEnabled = false
local aimPart = "Head"
local aimSmooth = 0.14

createToggle("Aimlock (hold right mouse)", 50, function(enabled)
    aimlockEnabled = enabled
end)

RunService.RenderStepped:Connect(function()
    if not aimlockEnabled then return end

    if not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local closest = nil
    local closestDist = 9999

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild(aimPart) then continue end

        local part = plr.Character[aimPart]
        local screenPos, visible = Camera:WorldToViewportPoint(part.Position)
        local mousePos = UserInput:GetMouseLocation()
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

        if visible and dist < closestDist then
            closestDist = dist
            closest = part
        end
    end

    if closest then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimSmooth)
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

print("Simple Aimlock + Box ESP GUI loaded")
