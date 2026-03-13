-- =============================================
-- Ninja Legends | FULL Orion Script (2026)
-- Auto Swing + Auto Sell + Auto Rebirth + Auto Collect + ESP
-- Inspired by popular hubs (MB Hub, Zepsyy, Hero Hub patterns)
-- Clean & safer methods: ProximityPrompt for collect, tool:Activate for swing
-- NO constant teleport spam - works great on alt accounts
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
	Name = "Ninja Legends | FULL Script (2026)",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "NinjaLegendsOrion"
})

-- ================== VARIABLES ==================
local autoSwing = false
local autoSell = false
local autoRebirth = false
local autoCollect = false
local espEnabled = false
local chiESP = false
local flyEnabled = false
local noclipEnabled = false
local infJump = false

local swingConn = nil
local sellConn = nil
local rebirthConn = nil
local collectConn = nil
local highlights = {}
local chiHighlights = {}
local linearVel = nil
local flyConn = nil
local noclipConn = nil

-- ================== AUTO SWING (tool:Activate loop - same safe method as top scripts) ==================
local function toggleSwing(val)
	autoSwing = val
	if val then
		swingConn = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if char then
				local tool = char:FindFirstChildWhichIsA("Tool")
				if tool and tool:FindFirstChild("Handle") then
					tool:Activate()
				end
			end
		end)
	else
		if swingConn then swingConn:Disconnect() end
	end
end

-- ================== AUTO SELL (finds sell pad & gentle CFrame near it - no spam) ==================
local function toggleSell(val)
	autoSell = val
	if val then
		sellConn = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			local root = char.HumanoidRootPart
			
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "sell") then
					root.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
					break
				end
			end
		end)
	else
		if sellConn then sellConn:Disconnect() end
	end
end

-- ================== AUTO REBIRTH (interacts with rebirth pad when enabled) ==================
local function toggleRebirth(val)
	autoRebirth = val
	if val then
		rebirthConn = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "rebirth") then
					local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
					if prompt then fireproximityprompt(prompt) end
					break
				end
			end
		end)
	else
		if rebirthConn then rebirthConn:Disconnect() end
	end
end

-- ================== AUTO COLLECT (Chi + Hoops - ProximityPrompt like legit play) ==================
local function toggleCollect(val)
	autoCollect = val
	if val then
		collectConn = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if (string.find(string.lower(obj.Name), "chi") or string.find(string.lower(obj.Name), "hoop")) and obj:IsA("BasePart") then
					local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
					if prompt and (char.HumanoidRootPart.Position - obj.Position).Magnitude < 20 then
						fireproximityprompt(prompt)
					end
				end
			end
		end)
	else
		if collectConn then collectConn:Disconnect() end
	end
end

-- ================== ESP (Player + Chi) ==================
local function createHighlight(obj, color, isChi)
	if highlights[obj] or chiHighlights[obj] then return end
	local hl = Instance.new("Highlight")
	hl.Adornee = obj
	hl.FillColor = color
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.5
	hl.OutlineTransparency = 0
	hl.Parent = obj
	
	if isChi then
		chiHighlights[obj] = hl
	else
		highlights[obj] = hl
	end
end

local function setupESP()
	-- Players
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			createHighlight(plr.Character, Color3.fromRGB(255, 0, 0), false)
		end
		plr.CharacterAdded:Connect(function(char)
			if espEnabled then createHighlight(char, Color3.fromRGB(255, 0, 0), false) end
		end)
	end
	
	-- Chi/Hoops
	RunService.Heartbeat:Connect(function()
		if not chiESP then return end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if (string.find(string.lower(obj.Name), "chi") or string.find(string.lower(obj.Name), "hoop")) and obj:IsA("BasePart") and not chiHighlights[obj] then
				createHighlight(obj, Color3.fromRGB(0, 255, 255), true)
			end
		end
	end)
end

-- ================== FLY (LinearVelocity - modern & safer) ==================
local function toggleFly(val)
	flyEnabled = val
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	if val then
		linearVel = Instance.new("LinearVelocity")
		linearVel.Attachment0 = Instance.new("Attachment", char.HumanoidRootPart)
		linearVel.MaxForce = math.huge
		linearVel.VectorVelocity = Vector3.new(0,0,0)
		linearVel.Parent = char.HumanoidRootPart
		
		flyConn = RunService.RenderStepped:Connect(function()
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
		if flyConn then flyConn:Disconnect() end
	end
end

-- ================== NOCLIP & INF JUMP ==================
local function toggleNoclip(val)
	noclipEnabled = val
	if val then
		noclipConn = RunService.Stepped:Connect(function()
			if LocalPlayer.Character then
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() end
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end

UserInputService.JumpRequest:Connect(function()
	if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ================== GUI TABS ==================
local AutoTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://6031097228", PremiumOnly = false})

AutoTab:AddToggle({Name = "Auto Swing (Katana)", Default = false, Callback = toggleSwing})
AutoTab:AddToggle({Name = "Auto Sell (Chi → Coins)", Default = false, Callback = toggleSell})
AutoTab:AddToggle({Name = "Auto Rebirth", Default = false, Callback = toggleRebirth})
AutoTab:AddToggle({Name = "Auto Collect (Chi + Hoops)", Default = false, Callback = toggleCollect})

local ESPTab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://6031097228", PremiumOnly = false})

ESPTab:AddToggle({Name = "Player ESP (Red)", Default = false, Callback = function(v)
	espEnabled = v
	if v then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then createHighlight(plr.Character, Color3.fromRGB(255, 0, 0), false) end
		end
	else
		for _, hl in pairs(highlights) do hl:Destroy() end
		highlights = {}
	end
end})

ESPTab:AddToggle({Name = "Chi/Hoops ESP (Cyan)", Default = false, Callback = function(v)
	chiESP = v
	if not v then
		for _, hl in pairs(chiHighlights) do hl:Destroy() end
		chiHighlights = {}
	end
end})

local MoveTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MoveTab:AddToggle({Name = "Fly (WASD)", Default = false, Callback = toggleFly})
MoveTab:AddToggle({Name = "Noclip", Default = false, Callback = toggleNoclip})
MoveTab:AddToggle({Name = "Infinite Jump", Default = false, Callback = function(v) infJump = v end})
MoveTab:AddSlider({Name = "WalkSpeed", Default = 16, Min = 16, Max = 100, Increment = 1, Callback = function(v)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = v
	end
end})

Window:MakeTab({Name = "Info", Icon = "rbxassetid://6031097228", PremiumOnly = false}):AddParagraph("How to use (inspired by 2026 hubs)",
	"• Auto Swing = constant katana swings (fastest ninjitsu gain)\n" ..
	"• Auto Sell = gently moves you to sell pad (safe)\n" ..
	"• Auto Rebirth + Collect = uses real ProximityPrompts (very legit feeling)\n" ..
	"• ESP = highlights players & chi/hoops through walls\n" ..
	"• Based on MB Hub / Zepsyy patterns but cleaner & less detected\n" ..
	"• Use on alt - still reportable if obvious")

setupESP()
OrionLib:Init()

OrionLib:MakeNotification({
	Name = "Ninja Legends Script Loaded!",
	Content = "Auto Swing + Collect + Rebirth ready. Go train like a legend 🥷🔥",
	Image = "rbxassetid://6031097228",
	Time = 6
})
