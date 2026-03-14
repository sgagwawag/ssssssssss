-- =============================================
-- Da Hood | FULL Celex-Inspired Orion Script (2026)
-- External-style Drawing ESP (Box + Tracer + Name + Health + Distance)
-- Aimlock (Prediction + Smoothing + FOV) + Silent Aim (Mouse.Hit redirect)
-- FULLY CODED: Fly (LinearVelocity), No placeholders
-- Inspired by Celex V3 visuals & aimlock (clean, smooth, no camera snap)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
	Name = "Da Hood | FULL Celex-Inspired (Drawing ESP + Aimlock)",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "DaHoodCelexStyle2026"
})

-- ================== VARIABLES ==================
local aimlockEnabled = false
local silentAimEnabled = false
local espEnabled = false
local showBox = true
local showTracer = true
local showName = true
local showHealth = true
local showDistance = true
local enemyOnly = true
local fovEnabled = true

local smoothing = 0.15
local prediction = 0.165
local aimHitPart = "Head"
local fovRadius = 150

local flyEnabled = false

local espCache = {}
local fovCircle = Drawing.new("Circle")
local aimlockConn = nil
local silentConn = nil
local flyVel = nil
local flyConn = nil

-- FOV Circle (external style)
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = fovRadius
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.7
fovCircle.Filled = false
fovCircle.Visible = false

-- ================== GET CLOSEST (FOV + Prediction) ==================
local function getClosestPlayer()
	local closest = nil
	local shortest = math.huge
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") 
			and plr.Character:FindFirstChild(aimHitPart) and plr.Character:FindFirstChild("Humanoid") 
			and plr.Character.Humanoid.Health > 0 then
			
			if enemyOnly and plr.Team == LocalPlayer.Team then continue end
			
			local part = plr.Character[aimHitPart]
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if not onScreen then continue end
			
			local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
			if dist > fovRadius then continue end
			
			if dist < shortest then
				shortest = dist
				closest = plr
			end
		end
	end
	return closest
end

-- ================== PREDICT POSITION ==================
local function getPredictedPosition(plr)
	if not plr or not plr.Character then return nil end
	local root = plr.Character:FindFirstChild("HumanoidRootPart")
	local hitPart = plr.Character:FindFirstChild(aimHitPart)
	if not root or not hitPart then return nil end
	
	local vel = root.AssemblyLinearVelocity
	local predicted = hitPart.Position + (vel * prediction)
	return predicted
end

-- ================== AIMLOCK (smooth + prediction) ==================
local function toggleAimlock(val)
	aimlockEnabled = val
	if val then
		aimlockConn = RunService.RenderStepped:Connect(function()
			local target = getClosestPlayer()
			if target then
				local predictedPos = getPredictedPosition(target)
				if predictedPos then
					local currentCF = Camera.CFrame
					local targetCF = CFrame.lookAt(currentCF.Position, predictedPos)
					Camera.CFrame = currentCF:Lerp(targetCF, smoothing)
				end
			end
		end)
	else
		if aimlockConn then aimlockConn:Disconnect() end
	end
end

-- ================== SILENT AIM ==================
local function toggleSilent(val)
	silentAimEnabled = val
	if val then
		silentConn = RunService.Heartbeat:Connect(function()
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
			local target = getClosestPlayer()
			if target then
				local predicted = getPredictedPosition(target)
				if predicted then
					Mouse.Hit = CFrame.new(predicted)
				end
			end
		end)
	else
		if silentConn then silentConn:Disconnect() end
	end
end

-- ================== DRAWING ESP (Celex-style) ==================
local function createESP(plr)
	if espCache[plr] then return end
	
	local box = Drawing.new("Square")
	box.Thickness = 1.5
	box.Color = Color3.fromRGB(255, 0, 0)
	box.Transparency = 1
	box.Filled = false
	
	local outline = Drawing.new("Square")
	outline.Thickness = 2.5
	outline.Color = Color3.fromRGB(0, 0, 0)
	outline.Transparency = 1
	outline.Filled = false
	
	local tracer = Drawing.new("Line")
	tracer.Thickness = 1
	tracer.Color = Color3.fromRGB(255, 255, 255)
	tracer.Transparency = 0.8
	
	local nameLabel = Drawing.new("Text")
	nameLabel.Size = 13
	nameLabel.Center = true
	nameLabel.Outline = true
	nameLabel.Color = Color3.fromRGB(255, 255, 255)
	
	local healthBar = Drawing.new("Line")
	healthBar.Thickness = 2
	healthBar.Color = Color3.fromRGB(0, 255, 0)
	
	local distanceLabel = Drawing.new("Text")
	distanceLabel.Size = 12
	distanceLabel.Center = true
	distanceLabel.Outline = true
	distanceLabel.Color = Color3.fromRGB(255, 255, 255)
	
	espCache[plr] = {
		box = box, outline = outline, tracer = tracer,
		name = nameLabel, health = healthBar, dist = distanceLabel
	}
end

local function updateESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
			if espCache[plr] then
				for _, obj in pairs(espCache[plr]) do obj.Visible = false end
			end
			continue
		end
		
		if enemyOnly and plr.Team == LocalPlayer.Team then
			if espCache[plr] then
				for _, obj in pairs(espCache[plr]) do obj.Visible = false end
			end
			continue
		end
		
		createESP(plr)
		local cache = espCache[plr]
		local root = plr.Character.HumanoidRootPart
		local humanoid = plr.Character:FindFirstChild("Humanoid")
		
		local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
		if not onScreen then
			for _, obj in pairs(cache) do obj.Visible = false end
			continue
		end
		
		local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
		local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
		
		local sizeY = math.abs(top.Y - bottom.Y)
		local sizeX = sizeY / 2.2
		
		-- Box & Outline
		if showBox then
			cache.box.Size = Vector2.new(sizeX, sizeY)
			cache.box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
			cache.box.Visible = true
			
			cache.outline.Size = cache.box.Size
			cache.outline.Position = cache.box.Position
			cache.outline.Visible = true
		else
			cache.box.Visible = false
			cache.outline.Visible = false
		end
		
		-- Tracer
		if showTracer then
			cache.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			cache.tracer.To = Vector2.new(pos.X, pos.Y + sizeY/2)
			cache.tracer.Visible = true
		else
			cache.tracer.Visible = false
		end
		
		-- Name
		if showName then
			cache.name.Text = plr.Name
			cache.name.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 18)
			cache.name.Visible = true
		else
			cache.name.Visible = false
		end
		
		-- Health Bar
		if showHealth and humanoid then
			local hp = humanoid.Health / humanoid.MaxHealth
			cache.health.From = Vector2.new(pos.X - sizeX/2 - 5, pos.Y - sizeY/2)
			cache.health.To = Vector2.new(pos.X - sizeX/2 - 5, pos.Y - sizeY/2 + sizeY * (1 - hp))
			cache.health.Color = Color3.fromRGB(255 - 255 * hp, 255 * hp, 0)
			cache.health.Visible = true
		else
			cache.health.Visible = false
		end
		
		-- Distance
		if showDistance then
			local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0)
			cache.dist.Text = dist .. " studs"
			cache.dist.Position = Vector2.new(pos.X, pos.Y + sizeY/2 + 5)
			cache.dist.Visible = true
		else
			cache.dist.Visible = false
		end
	end
end

local function cleanupESP()
	for plr, cache in pairs(espCache) do
		if not plr.Parent or not plr.Character or (plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0) then
			for _, obj in pairs(cache) do obj:Remove() end
			espCache[plr] = nil
		end
	end
end

-- ================== FLY (FULLY CODED - LinearVelocity) ==================
local function toggleFly(val)
	flyEnabled = val
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	if val then
		flyVel = Instance.new("LinearVelocity")
		flyVel.Attachment0 = Instance.new("Attachment", char.HumanoidRootPart)
		flyVel.MaxForce = math.huge
		flyVel.VectorVelocity = Vector3.new(0, 0, 0)
		flyVel.Parent = char.HumanoidRootPart
		
		flyConn = RunService.RenderStepped:Connect(function()
			if not flyEnabled or not flyVel then return end
			local cam = Workspace.CurrentCamera
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
			
			flyVel.VectorVelocity = move.Magnitude > 0 and (move.Unit * 50) or Vector3.new(0, 0, 0)
		end)
	else
		if flyVel then
			flyVel:Destroy()
			flyVel = nil
		end
		if flyConn then
			flyConn:Disconnect()
			flyConn = nil
		end
	end
end

-- ================== GUI ==================
local AimTab = Window:MakeTab({Name = "🎯 Aim", Icon = "rbxassetid://6031097228", PremiumOnly = false})

AimTab:AddToggle({Name = "Aimlock (Prediction + Smoothing)", Default = false, Callback = toggleAimlock})
AimTab:AddToggle({Name = "Silent Aim (Prediction)", Default = false, Callback = toggleSilent})
AimTab:AddSlider({Name = "Smoothing", Default = 15, Min = 1, Max = 30, Increment = 1, Callback = function(v) smoothing = v / 100 end})
AimTab:AddSlider({Name = "Prediction", Default = 16.5, Min = 5, Max = 30, Increment = 0.1, Callback = function(v) prediction = v / 100 end})
AimTab:AddDropdown({Name = "Hit Part", Default = "Head", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, Callback = function(v) aimHitPart = v end})
AimTab:AddSlider({Name = "FOV Radius", Default = 150, Min = 50, Max = 500, Increment = 10, Callback = function(v) fovRadius = v; fovCircle.Radius = v end})

local VisualsTab = Window:MakeTab({Name = "👁️ Visuals", Icon = "rbxassetid://6031097228", PremiumOnly = false})

VisualsTab:AddToggle({Name = "ESP Enabled", Default = false, Callback = function(val)
	espEnabled = val
	fovCircle.Visible = val and fovEnabled
end})
VisualsTab:AddToggle({Name = "Enemy Only", Default = true, Callback = function(v) enemyOnly = v end})
VisualsTab:AddToggle({Name = "Show Box", Default = true, Callback = function(v) showBox = v end})
VisualsTab:AddToggle({Name = "Show Tracer", Default = true, Callback = function(v) showTracer = v end})
VisualsTab:AddToggle({Name = "Show Name", Default = true, Callback = function(v) showName = v end})
VisualsTab:AddToggle({Name = "Show Health Bar", Default = true, Callback = function(v) showHealth = v end})
VisualsTab:AddToggle({Name = "Show Distance", Default = true, Callback = function(v) showDistance = v end})
VisualsTab:AddToggle({Name = "Show FOV Circle", Default = true, Callback = function(v) fovEnabled = v; fovCircle.Visible = espEnabled and v end})

local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MiscTab:AddToggle({Name = "Fly (WASD - 50 speed)", Default = false, Callback = toggleFly})

-- ================== MAIN LOOPS ==================
RunService.RenderStepped:Connect(function()
	if espEnabled then
		updateESP()
		cleanupESP()
	end
	fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function() 
		if espEnabled then createESP(plr) end 
	end)
end)

OrionLib:Init()

OrionLib:MakeNotification({
	Name = "Da Hood Celex-Inspired LOADED!",
	Content = "FULL script • Drawing ESP + Aimlock + Silent + Fly (exactly like Celex externals). Use on alt 🧢🔫",
	Image = "rbxassetid://6031097228",
	Time = 6
})
