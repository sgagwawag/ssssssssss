-- =============================================
-- VERY BLATANT Roblox Aimbot + ESP
-- Using Orion Library (active fork)
-- Paste into any Roblox executor (Synapse, Fluxus, etc.)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Orion Library (updated fork - works in 2026)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
	Name = "VERY BLATANT Aimbot + ESP",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "BlatantOrion"
})

-- Variables
local aimbotEnabled = false
local espEnabled = false
local teamCheck = true
local aimPart = "Head"

local highlights = {}

-- ================== AIMBOT ==================
local function getClosestTarget()
	local closest = nil
	local shortest = math.huge
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer 
			and plr.Character 
			and plr.Character:FindFirstChild(aimPart) 
			and plr.Character:FindFirstChild("Humanoid") 
			and plr.Character.Humanoid.Health > 0 then
			
			if teamCheck and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
				continue
			end
			
			local part = plr.Character[aimPart]
			local dist = (Camera.CFrame.Position - part.Position).Magnitude
			
			if dist < shortest then
				shortest = dist
				closest = part
			end
		end
	end
	return closest
end

-- Blatant camera snap (no smoothing, instant lock)
RunService.RenderStepped:Connect(function()
	if aimbotEnabled then
		local target = getClosestTarget()
		if target then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
		end
	end
end)

-- ================== ESP (Highlight Wallhack) ==================
local function createHighlight(plr, char)
	if highlights[plr] then highlights[plr]:Destroy() end
	
	local hl = Instance.new("Highlight")
	hl.Name = "BlatantESP"
	hl.Adornee = char
	hl.FillColor = Color3.fromRGB(255, 0, 0)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.35
	hl.OutlineTransparency = 0
	hl.Parent = char
	highlights[plr] = hl
end

local function setupPlayerESP(plr)
	if plr == LocalPlayer then return end
	
	plr.CharacterAdded:Connect(function(char)
		if espEnabled then
			createHighlight(plr, char)
		end
	end)
	
	plr.CharacterRemoving:Connect(function()
		if highlights[plr] then
			highlights[plr]:Destroy()
			highlights[plr] = nil
		end
	end)
	
	-- Initial character if exists
	if plr.Character and espEnabled then
		createHighlight(plr, plr.Character)
	end
end

-- Setup all current + future players
for _, plr in ipairs(Players:GetPlayers()) do
	setupPlayerESP(plr)
end
Players.PlayerAdded:Connect(setupPlayerESP)

-- ================== GUI ==================
local AimbotTab = Window:MakeTab({
	Name = "Aimbot",
	Icon = "rbxassetid://6031097228",
	PremiumOnly = false
})

AimbotTab:AddToggle({
	Name = "Aimbot (INSTANT CAMERA SNAP - VERY BLATANT)",
	Default = false,
	Callback = function(val)
		aimbotEnabled = val
	end
})

AimbotTab:AddToggle({
	Name = "Team Check",
	Default = true,
	Callback = function(val)
		teamCheck = val
	end
})

AimbotTab:AddDropdown({
	Name = "Aim Part",
	Default = "Head",
	Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
	Callback = function(val)
		aimPart = val
	end
})

AimbotTab:AddButton({
	Name = "Destroy GUI",
	Callback = function()
		OrionLib:Destroy()
	end
})

local ESPTab = Window
