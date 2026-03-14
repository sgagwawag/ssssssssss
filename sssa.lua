-- =============================================
-- Da Hood | FIXED Celex-Inspired Orion Script (2026 - ESP WORKING)
-- Drawing ESP now forces creation + better visibility handling
-- Aimlock / Silent / Fly unchanged
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
	Name = "Da Hood | FIXED Celex-Style ESP + Aim (2026)",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "DaHoodCelexFixed2026"
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
local enemyOnly = true          -- set to false to show EVERYONE
local fovEnabled = true

local smoothing = 0.15
local prediction = 0.165
local aimHitPart = "Head"
local fovRadius = 150

local flyEnabled = false

local espCache = {}
local fovCircle = Drawing.new("Circle")
local aimlockConn, silentConn, flyVel, flyConn

fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = fovRadius
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.7
fovCircle.Filled = false
fovCircle.Visible = false

-- ================== HELPERS ==================
local function getClosestPlayer()
	local closest, shortest = nil, math.huge
	local mousePos = Vector2.new(Mouse.X, Mouse.Y + 36) -- adjust for topbar if needed

	for _, plr in Players:GetPlayers() do
		if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
		if enemyOnly and plr.Team == LocalPlayer.Team then continue end

		local root = plr.Character.HumanoidRootPart
		local part = plr.Character:FindFirstChild(aimHitPart) or root
		local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
		if dist < fovRadius and dist < shortest then
			shortest = dist
			closest = plr
		end
	end
	return closest
end

local function getPredictedPosition(plr)
	local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	local part = plr.Character and plr.Character:FindFirstChild(aimHitPart) or root
	if not root or not part then return nil end
	return part.Position + (root.AssemblyLinearVelocity * prediction)
end

-- ================== AIMLOCK ==================
local function toggleAimlock(val)
	aimlockEnabled = val
	if val then
		aimlockConn = RunService.RenderStepped:Connect(function()
			local target = getClosestPlayer()
			if target then
				local pred = getPredictedPosition(target)
				if pred then
					local cf = Camera.CFrame
					Camera.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, pred), smoothing)
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
				local pred = getPredictedPosition(target)
				if pred then Mouse.Hit = CFrame.new(pred) end
			end
		end)
	else
		if silentConn then silentConn:Disconnect() end
	end
end

-- ================== ESP CORE ==================
local function createOrUpdateESP(plr)
	if espCache[plr] then return espCache[plr] end

	local box = Drawing.new("Square") box.Thickness = 1.5 box.Filled = false box.Transparency = 1
	local outline = Drawing.new("Square") outline.Thickness = 3 outline.Color = Color3.new(0,0,0) outline.Filled = false outline.Transparency = 1
	local tracer = Drawing.new("Line") tracer.Thickness = 1.2 tracer.Transparency = 0.75
	local nameTxt = Drawing.new("Text") nameTxt.Size = 14 nameTxt.Center = true nameTxt.Outline = true nameTxt.Transparency = 1
	local healthLine = Drawing.new("Line") healthLine.Thickness = 2
	local distTxt = Drawing.new("Text") distTxt.Size = 12 distTxt.Center = true distTxt.Outline = true distTxt.Transparency = 1

	local cache = {box=box, outline=outline, tracer=tracer, name=nameTxt, health=healthLine, dist=distTxt}
	espCache[plr] = cache
	return cache
end

local function updateESP()
	if not espEnabled then return end

	for _, plr in Players:GetPlayers() do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
			if espCache[plr] then for k,v in pairs(espCache[plr]) do v.Visible = false end end
			continue
		end

		if enemyOnly and plr.Team == LocalPlayer.Team then
			if espCache[plr] then for k,v in pairs(espCache[plr]) do v.Visible = false end end
			continue
		end

		local cache = createOrUpdateESP(plr)
		local root = char.HumanoidRootPart
		local hum = char.Humanoid

		local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
		if not onScreen then
			for k,v in pairs(cache) do v.Visible = false end
			continue
		end

		local headPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0,2.8,0))
		local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3.5,0))

		local height = math.abs(headPos.Y - legPos.Y)
		local width = height * 0.45

		local boxPos = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)

		-- Color logic
		local mainColor = enemyOnly and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,255,50)

		cache.box.Size       = Vector2.new(width, height)
		cache.box.Position   = boxPos
		cache.box.Color      = mainColor
		cache.box.Visible    = showBox

		cache.outline.Size       = cache.box.Size
		cache.outline.Position   = cache.box.Position
		cache.outline.Visible    = showBox

		cache.tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
		cache.tracer.To      = Vector2.new(rootPos.X, rootPos.Y + height/2)
		cache.tracer.Color   = mainColor
		cache.tracer.Visible = showTracer

		cache.name.Text      = plr.Name
		cache.name.Position  = Vector2.new(rootPos.X, boxPos.Y - 20)
		cache.name.Color     = mainColor
		cache.name.Visible   = showName

		local hp = hum.Health / hum.MaxHealth
		cache.health.From    = Vector2.new(boxPos.X - 6, boxPos.Y)
		cache.health.To      = Vector2.new(boxPos.X - 6, boxPos.Y + height * (1 - hp))
		cache.health.Color   = Color3.fromRGB(255 * (1-hp), 255 * hp, 0)
		cache.health.Visible = showHealth

		local distVal = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 999)
		cache.dist.Text      = tostring(distVal) .. " studs"
		cache.dist.Position  = Vector2.new(rootPos.X, boxPos.Y + height + 5)
		cache.dist.Color     = mainColor
		cache.dist.Visible   = showDistance
	end
end

local function forceRefreshESP()
	for _, plr in Players:GetPlayers() do
		if plr ~= LocalPlayer and plr.Character then
			createOrUpdateESP(plr)
		end
	end
end

-- Cleanup
local function cleanupESP()
	for plr, cache in pairs(espCache) do
		if not plr or not plr.Parent or not plr.Character or plr.Character.Humanoid.Health <= 0 then
			for _, obj in pairs(cache) do obj:Remove() end
			espCache[plr] = nil
		end
	end
end

-- ================== FLY (unchanged) ==================
local function toggleFly(val)
	flyEnabled = val
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	if val then
		flyVel = Instance.new("LinearVelocity", char.HumanoidRootPart)
		flyVel.Attachment0 = Instance.new("Attachment", char.HumanoidRootPart)
		flyVel.MaxForce = Vector3.new(1e9,1e9,1e9)

		flyConn = RunService.RenderStepped:Connect(function()
			if not flyEnabled then return end
			local move = Vector3.new()
			local cam = Camera.CFrame
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
			flyVel.VectorVelocity = move.Unit * 55
		end)
	else
		if flyVel then flyVel:Destroy() end
		if flyConn then flyConn:Disconnect() end
	end
end

-- ================== GUI ==================
local AimTab = Window:MakeTab({Name = "Aim", Icon = "rbxassetid://6031097228", PremiumOnly = false})

AimTab:AddToggle({Name = "Aimlock", Default = false, Callback = toggleAimlock})
AimTab:AddToggle({Name = "Silent Aim", Default = false, Callback = toggleSilent})
AimTab:AddSlider({Name = "Smoothing", Default = 15, Min = 1, Max = 30, Increment = 1, Callback = function(v) smoothing = v/100 end})
AimTab:AddSlider({Name = "Prediction", Default = 16.5, Min = 5, Max = 30, Increment = 0.1, Callback = function(v) prediction = v/100 end})
AimTab:AddDropdown({Name = "Aim Part", Default = "Head", Options = {"Head","HumanoidRootPart","UpperTorso"}, Callback = function(v) aimHitPart = v end})
AimTab:AddSlider({Name = "FOV", Default = 150, Min = 50, Max = 600, Increment = 10, Callback = function(v) fovRadius = v fovCircle.Radius = v end})

local VisTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://6031097228", PremiumOnly = false})

VisTab:AddToggle({Name = "ESP Enabled", Default = false, Callback = function(val)
	espEnabled = val
	fovCircle.Visible = val and fovEnabled
	if val then
		forceRefreshESP()
		OrionLib:MakeNotification({Name = "ESP Activated", Content = "Should now show boxes/tracers (check enemyOnly setting)", Time = 4})
	else
		for _, cache in pairs(espCache) do for k,v in pairs(cache) do v.Visible = false end end
	end
end})

VisTab:AddToggle({Name = "Enemy Only (recommended)", Default = true, Callback = function(v) enemyOnly = v forceRefreshESP() end})
VisTab:AddToggle({Name = "Box", Default = true, Callback = function(v) showBox = v end})
VisTab:AddToggle({Name = "Tracer", Default = true, Callback = function(v) showTracer = v end})
VisTab:AddToggle({Name = "Name", Default = true, Callback = function(v) showName = v end})
VisTab:AddToggle({Name = "Health Bar", Default = true, Callback = function(v) showHealth = v end})
VisTab:AddToggle({Name = "Distance", Default = true, Callback = function(v) showDistance = v end})
VisTab:AddToggle({Name = "FOV Circle", Default = true, Callback = function(v) fovEnabled = v fovCircle.Visible = espEnabled and v end})

local MoveTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://6031097228", PremiumOnly = false})
MoveTab:AddToggle({Name = "Fly (WASD)", Default = false, Callback = toggleFly})

-- ================== LOOPS ==================
RunService.RenderStepped:Connect(function()
	updateESP()
	cleanupESP()
	fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end)

-- Auto-refresh on players/characters
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5) -- small delay for full load
		if espEnabled then createOrUpdateESP(plr) end
	end)
end)

for _, plr in Players:GetPlayers() do
	if plr.Character then
		task.spawn(function()
			task.wait(1)
			if espEnabled then createOrUpdateESP(plr) end
		end)
	end
end

OrionLib:Init()

OrionLib:MakeNotification({
	Name = "FIXED Script Loaded!",
	Content = "ESP should now appear properly. Toggle Visuals → ESP Enabled. Use alt account.",
	Time = 8
})
