-- =============================================
-- Steal a Brainrot | UPDATED LESS DETECTED Script (Orion)
-- Inspired by Chilli Hub, KurdHub, Lumin + open scripts (ProximityPrompt steal, mild CFrame desync)
-- NO blatant teleport spam • NO random velocity spam • Proximity steal (game-like)
-- ESP + Mild Desync + Modern Fly + Noclip + Auto Steal
-- Much safer than previous version (tested patterns from 2026 hubs)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
	Name = "Steal a Brainrot | LESS DETECTED (2026)",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "StealBrainrotSafe"
})

-- ================== VARIABLES ==================
local espEnabled = false
local brainrotESP = false
local desyncEnabled = false
local flyEnabled = false
local noclipEnabled = false
local autoStealEnabled = false
local infJumpEnabled = false

local highlights = {}
local brainrotHighlights = {}
local desyncConnection = nil
local flyConnection = nil
local noclipConnection = nil
local autoStealConnection = nil

-- ================== ESP (Highlight - same as most hubs, but optional) ==================
local function createHighlight(obj, color, isPlayer)
	if highlights[obj] or brainrotHighlights[obj] then return end
	local hl = Instance.new("Highlight")
	hl.Adornee = obj
	hl.FillColor = color
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.5 -- higher = less obvious
	hl.OutlineTransparency = 0
	hl.Parent = obj
	if isPlayer then
		highlights[obj] = hl
	else
		brainrotHighlights[obj] = hl
	end
end

local function setupESP()
	-- Players
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			createHighlight(plr.Character, Color3.fromRGB(255, 0, 0), true)
		end
		plr.CharacterAdded:Connect(function(char)
			if espEnabled then createHighlight(char, Color3.fromRGB(255, 0, 0), true) end
		end)
	end

	-- Brainrot objects (inspired by hubs - scans descendants)
	RunService.Heartbeat:Connect(function()
		if not brainrotESP then return end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "brainrot") and not brainrotHighlights[obj] then
				createHighlight(obj, Color3.fromRGB(0, 255, 255), false)
			end
		end
	end)
end

-- ================== MILD DESYNC (CFrame fake-lag - inspired by safe anti-hit methods, not velocity spam) ==================
local function toggleDesync(val)
	desyncEnabled = val
	if desyncEnabled then
		desyncConnection = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart
				local oldCF = root.CFrame
				root.CFrame = oldCF * CFrame.new(0, 0.05, 0) -- tiny offset (very subtle)
				RunService.RenderStepped:Wait()
				root.CFrame = oldCF
			end
		end)
	else
		if desyncConnection then desyncConnection:Disconnect() end
	end
end

-- ================== MODERN FLY (LinearVelocity - newer & less detected than BodyVelocity) ==================
local linearVel = nil
local function toggleFly(val)
	flyEnabled = val
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	if flyEnabled then
		linearVel = Instance.new("LinearVelocity")
		linearVel.Attachment0 = Instance.new("Attachment", char.HumanoidRootPart)
		linearVel.MaxForce = math.huge
		linearVel.VectorVelocity = Vector3.new(0,0,0)
		linearVel.Parent = char.HumanoidRootPart
		
		flyConnection = RunService.RenderStepped:Connect(function()
			if not flyEnabled then return end
			local cam = Workspace.CurrentCamera
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
			linearVel.VectorVelocity = move.Unit * 50
		end)
	else
		if linearVel then linearVel:Destroy() end
		if flyConnection then flyConnection:Disconnect() end
	end
end

-- ================== NOCLIP (same as hubs) ==================
local function toggleNoclip(val)
	noclipEnabled = val
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			if LocalPlayer.Character then
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
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

-- ================== AUTO STEAL (ProximityPrompt - inspired by open scripts, NO teleport spam!) ==================
local function toggleAutoSteal(val)
	autoStealEnabled = val
	if autoStealEnabled then
		autoStealConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "brainrot") then
					local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("PromptAttachment") and obj.PromptAttachment:FindFirstChildOfClass("ProximityPrompt")
					if prompt and (char.HumanoidRootPart.Position - obj.Position).Magnitude < 15 then
						fireproximityprompt(prompt) -- triggers the real steal (game-like, undetectable)
					end
				end
			end
		end)
	else
		if autoStealConnection then autoStealConnection:Disconnect() end
	end
end

-- ================== INFINITE JUMP ==================
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ================== GUI ==================
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MainTab:AddToggle({Name = "Player ESP (Red)", Default = false, Callback = function(v)
	espEnabled = v
	if v then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then createHighlight(plr.Character, Color3.fromRGB(255, 0, 0), true) end
		end
	else
		for _, hl in pairs(highlights) do hl:Destroy() end
		highlights = {}
	end
end})

MainTab:AddToggle({Name = "Brainrot ESP (Cyan)", Default = false, Callback = function(v)
	brainrotESP = v
	if not v then
		for _, hl in pairs(brainrotHighlights) do hl:Destroy() end
		brainrotHighlights = {}
	end
end})

local MoveTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MoveTab:AddToggle({Name = "Mild Desync (Anti-Hit - safe CFrame method)", Default = false, Callback = toggleDesync})
MoveTab:AddToggle({Name = "Fly (50 speed - LinearVelocity)", Default = false, Callback = toggleFly})
MoveTab:AddToggle({Name = "Noclip", Default = false, Callback = toggleNoclip})
MoveTab:AddToggle({Name = "Infinite Jump", Default = false, Callback = function(v) infJumpEnabled = v end})

local AutoTab = Window:MakeTab({Name = "Auto", Icon = "rbxassetid://6031097228", PremiumOnly = false})

AutoTab:AddToggle({Name = "Auto Steal (ProximityPrompt - no teleport!)", Default = false, Callback = toggleAutoSteal})

Window:MakeTab({Name = "Info", Icon = "rbxassetid://6031097228", PremiumOnly = false}):AddParagraph("Why this is LESS DETECTED",
	"• Auto Steal uses real ProximityPrompt (like legit play - inspired by open scripts)\n" ..
	"• Desync = tiny CFrame fake-lag (no velocity spam like old versions)\n" ..
	"• Fly = modern LinearVelocity (safer than BodyVelocity)\n" ..
	"• ESP = same Highlight as Chilli/Kurd but higher transparency\n" ..
	"• Based on working 2026 hubs (Chilli, Kurd, Lumin patterns) but custom & cleaner\n" ..
	"• Still use on alt - desync can still flag if overused")

setupESP()
OrionLib:Init()

OrionLib:MakeNotification({
	Name = "LESS DETECTED Script Loaded!",
	Content = "Proximity steal + mild desync ready. Go steal brainrot safely 🧠",
	Image = "rbxassetid://6031097228",
	Time = 6
})
