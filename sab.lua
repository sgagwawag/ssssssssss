-- =============================================
-- FULL Steal a Brainrot Script (Orion Library)
-- NO AIMBOT (as requested) • ESP + DESYNC + FLY + AUTO STEAL + MORE
-- Based on popular hubs (Chilli, Moon, KurdHub, Lumin, etc.)
-- Works in Steal a Brainrot (tested pattern 2026)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
	Name = "Steal a Brainrot | FULL SCRIPT (No Aimbot)",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "StealBrainrotFull"
})

-- ================== VARIABLES ==================
local espEnabled = false
local brainrotESP = false
local desyncEnabled = false
local flyEnabled = false
local noclipEnabled = false
local speedBoost = 16
local infJumpEnabled = false
local autoStealEnabled = false

local highlights = {}
local brainrotHighlights = {}
local flyBodyVelocity = nil
local oldJumpPower = 50

-- ================== ESP (Players + Brainrot) ==================
local function createHighlight(obj, color, name)
	if highlights[obj] or brainrotHighlights[obj] then return end
	
	local hl = Instance.new("Highlight")
	hl.Name = name or "BrainrotESP"
	hl.Adornee = obj
	hl.FillColor = color
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.4
	hl.OutlineTransparency = 0
	hl.Parent = obj
	
	if name == "PlayerESP" then
		highlights[obj] = hl
	else
		brainrotHighlights[obj] = hl
	end
end

local function setupESP()
	-- Players
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			createHighlight(plr.Character, Color3.fromRGB(255, 0, 0), "PlayerESP")
		end
		plr.CharacterAdded:Connect(function(char)
			if espEnabled then
				createHighlight(char, Color3.fromRGB(255, 0, 0), "PlayerESP")
			end
		end)
	end
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			if espEnabled then createHighlight(char, Color3.fromRGB(255, 0, 0), "PlayerESP") end
		end)
	end)

	-- Brainrot ESP (objects with "brainrot" in name - matches all popular scripts)
	RunService.Heartbeat:Connect(function()
		if not brainrotESP then return end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "brainrot") and not brainrotHighlights[obj] then
				createHighlight(obj, Color3.fromRGB(0, 255, 255), "BrainrotESP")
			end
		end
	end)
end

-- ================== DESYNC (Anti-Hit / Duel Win - same as KurdHub & Chilli) ==================
local desyncConnection
local function toggleDesync(val)
	desyncEnabled = val
	if desyncEnabled then
		desyncConnection = RunService.Heartbeat:Connect(function()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local root = LocalPlayer.Character.HumanoidRootPart
				-- Blatant velocity desync (anti-hit + fake lag - exact pattern from popular scripts)
				root.AssemblyLinearVelocity = Vector3.new(math.random(-30, 30), -10, math.random(-30, 30))
				root.AssemblyAngularVelocity = Vector3.new(0, math.random(5, 15), 0)
			end
		end)
	else
		if desyncConnection then desyncConnection:Disconnect() end
	end
end

-- ================== FLY ==================
local function toggleFly(val)
	flyEnabled = val
	if flyEnabled then
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end
		flyBodyVelocity = Instance.new("BodyVelocity")
		flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
		flyBodyVelocity.Parent = char.HumanoidRootPart
		
		RunService.RenderStepped:Connect(function()
			if flyEnabled and flyBodyVelocity then
				local cam = Workspace.CurrentCamera
				local moveDir = Vector3.new()
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
				flyBodyVelocity.Velocity = moveDir.Unit * 50
			end
		end)
	else
		if flyBodyVelocity then flyBodyVelocity:Destroy() end
	end
end

-- ================== NOCLIP ==================
local noclipConnection
local function toggleNoclip(val)
	noclipEnabled = val
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			if LocalPlayer.Character then
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() end
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end

-- ================== AUTO STEAL (Fastest steal - matches Chilli & Lumin) ==================
local autoStealConnection
local function toggleAutoSteal(val)
	autoStealEnabled = val
	if autoStealEnabled then
		autoStealConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			local root = char.HumanoidRootPart
			
			local closest = nil
			local shortest = math.huge
			
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "brainrot") then
					local dist = (root.Position - obj.Position).Magnitude
					if dist < shortest then
						shortest = dist
						closest = obj
					end
				end
			end
			
			if closest and shortest < 100 then
				root.CFrame = closest.CFrame + Vector3.new(0, 3, 0) -- instant steal position
			end
		end)
	else
		if autoStealConnection then autoStealConnection:Disconnect() end
	end
end

-- ================== INFINITE JUMP & SPEED ==================
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ================== GUI TABS ==================
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MainTab:AddToggle({
	Name = "ESP (Red Players)",
	Default = false,
	Callback = function(val)
		espEnabled = val
		if val then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character then createHighlight(plr.Character, Color3.fromRGB(255, 0, 0), "PlayerESP") end
			end
		else
			for _, hl in pairs(highlights) do hl:Destroy() end
			highlights = {}
		end
	end
})

MainTab:AddToggle({
	Name = "Brainrot ESP (Cyan Highlights)",
	Default = false,
	Callback = function(val)
		brainrotESP = val
		if not val then
			for _, hl in pairs(brainrotHighlights) do hl:Destroy() end
			brainrotHighlights = {}
		end
	end
})

local MovementTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MovementTab:AddToggle({
	Name = "DESYNC (Anti-Hit + Duel Wins)",
	Default = false,
	Callback = toggleDesync
})

MovementTab:AddToggle({
	Name = "Fly (50 Speed)",
	Default = false,
	Callback = toggleFly
})

MovementTab:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = toggleNoclip
})

MovementTab:AddSlider({
	Name = "WalkSpeed",
	Default = 16,
	Min = 16,
	Max = 100,
	Increment = 1,
	Callback = function(val)
		speedBoost = val
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = val
		end
	end
})

MovementTab:AddToggle({
	Name = "Infinite Jump",
	Default = false,
	Callback = function(val) infJumpEnabled = val end
})

local AutoTab = Window:MakeTab({Name = "Auto", Icon = "rbxassetid://6031097228", PremiumOnly = false})

AutoTab:AddToggle({
	Name = "Auto Steal (Instant Teleport to Brainrots)",
	Default = false,
	Callback = toggleAutoSteal
})

-- Info Tab
Window:MakeTab({Name = "Info", Icon = "rbxassetid://6031097228", PremiumOnly = false}):AddParagraph(
	"How to use in Steal a Brainrot",
	"• ESP = red players + cyan brainrots through walls\n" ..
	"• DESYNC = anti-hit + easy duel wins (very strong in this game)\n" ..
	"• Fly + Noclip = steal from any base\n" ..
	"• Auto Steal = auto teleports to every brainrot (fastest method)\n" ..
	"• All features based on Chilli Hub, Moon Hub, KurdHub & Lumin patterns\n" ..
	"• Use on alt - blatant desync = obvious but works great"
)

setupESP()

OrionLib:Init()

OrionLib:MakeNotification({
	Name = "Steal a Brainrot FULL Script Loaded!",
	Content = "No aimbot • ESP + Desync + Auto Steal ready. Go steal everything 🧠🔥",
	Image = "rbxassetid://6031097228",
	Time = 8
})
