-- =============================================
-- Prison Life | FULL Orion Script + Pastebin KEY SYSTEM (2026)
-- ESP (team colored) + Blatant Aimbot + Fly + Noclip + Infinite Ammo + Remove Doors
-- Inspired by top 2025/2026 scripts (FlashHub, NexusHub, Weshky, Nova Hub patterns)
-- Safe methods: ProximityPrompt where possible, LinearVelocity fly, simple ammo loop
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ================== ORION LIBRARY ==================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
	Name = "Prison Life | FULL Script + Pastebin Key",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "PrisonLifeOrion2026"
})

-- ================== PASTEBIN KEY SYSTEM ==================
local verified = false
local pastebinUrl = "https://pastebin.com/raw/wLxmppde" -- ← CHANGE THIS!

-- HOW TO SET UP YOUR KEY:
-- 1. Go to pastebin.com → New Paste
-- 2. Put your keys ONE PER LINE (example below):
-- PRISON2026
-- GROKKEY
-- AFafafaf
-- 3. Set to "Unlisted" or Public → Create Paste
-- 4. Copy the RAW link[](https://pastebin.com/raw/XXXXXX)
-- 5. Replace "YOURPASTEIDHERE" above with your code
-- 6. Re-execute script

local KeyTab = Window:MakeTab({
	Name = "🔑 Key System (Pastebin)",
	Icon = "rbxassetid://6031097228",
	PremiumOnly = false
})

KeyTab:AddTextbox({
	Name = "Enter Key",
	Default = "",
	TextDisappear = true,
	Callback = function(val)
		getgenv().EnteredKey = val
	end
})

KeyTab:AddButton({
	Name = "Verify Key (fetches from your Pastebin)",
	Callback = function()
		if pastebinUrl == "https://pastebin.com/raw/YOURPASTEIDHERE" then
			OrionLib:MakeNotification({Name = "❌ Setup Required", Content = "Replace the pastebinUrl in the script first!", Time = 5})
			return
		end
		
		local success, keysRaw = pcall(function()
			return game:HttpGet(pastebinUrl)
		end)
		
		if not success then
			OrionLib:MakeNotification({Name = "❌ Pastebin Error", Content = "Cannot reach your Pastebin. Check link!", Time = 5})
			return
		end
		
		local keys = string.split(keysRaw, "\n")
		local cleanKeys = {}
		for _, k in ipairs(keys) do
			local trimmed = k:match("^%s*(.-)%s*$")
			if trimmed ~= "" then table.insert(cleanKeys, trimmed) end
		end
		
		if table.find(cleanKeys, getgenv().EnteredKey) then
			verified = true
			OrionLib:MakeNotification({
				Name = "✅ Key Verified!",
				Content = "Prison Life cheats unlocked. Go cause chaos 🔥",
				Image = "rbxassetid://6031097228",
				Time = 5
			})
		else
			OrionLib:MakeNotification({
				Name = "❌ Wrong Key",
				Content = "Key not in your Pastebin list!",
				Time = 5
			})
		end
	end
})

KeyTab:AddButton({
	Name = "Get Free Key (Discord Example)",
	Callback = function()
		setclipboard("https://discord.gg/yourserver") -- replace if you have one
		OrionLib:MakeNotification({Name = "📋 Copied", Content = "Discord link copied (make your own for real keys)", Time = 3})
	end
})

-- ================== VARIABLES ==================
local aimbotEnabled = false
local espEnabled = false
local flyEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local infAmmoEnabled = false
local speedValue = 16

local highlights = {}
local aimConn = nil
local flyVel = nil
local flyConn = nil
local noclipConn = nil
local ammoConn = nil

-- ================== BLATANT AIMBOT (instant camera snap - same as top Prison Life scripts) ==================
local function getClosestTarget()
	local closest = nil
	local shortest = math.huge
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") 
			and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			
			-- Team check (don't aim at same team)
			if plr.Team == LocalPlayer.Team then continue end
			
			local dist = (Camera.CFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude
			if dist < shortest then
				shortest = dist
				closest = plr.Character.HumanoidRootPart
			end
		end
	end
	return closest
end

-- ================== ESP (Team Colored - Guards red, Prisoners blue, Criminals yellow) ==================
local function createHighlight(plr, char)
	if highlights[plr] then highlights[plr]:Destroy() end
	
	local color = Color3.fromRGB(255, 0, 0) -- default red
	if plr.Team then
		if plr.Team.Name == "Guards" then color = Color3.fromRGB(255, 0, 0)
		elseif plr.Team.Name == "Prisoners" then color = Color3.fromRGB(0, 100, 255)
		elseif plr.Team.Name == "Criminals" then color = Color3.fromRGB(255, 255, 0) end
	end
	
	local hl = Instance.new("Highlight")
	hl.Adornee = char
	hl.FillColor = color
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.4
	hl.OutlineTransparency = 0
	hl.Parent = char
	highlights[plr] = hl
end

local function setupESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if plr.Character then createHighlight(plr, plr.Character) end
			plr.CharacterAdded:Connect(function(char)
				if espEnabled and verified then createHighlight(plr, char) end
			end)
		end
	end
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			if espEnabled and verified then createHighlight(plr, char) end
		end)
	end)
end

-- ================== FLY (LinearVelocity - modern & less detected) ==================
local function toggleFly(val)
	flyEnabled = val
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	if val then
		flyVel = Instance.new("LinearVelocity")
		flyVel.Attachment0 = Instance.new("Attachment", char.HumanoidRootPart)
		flyVel.MaxForce = math.huge
		flyVel.Parent = char.HumanoidRootPart
		
		flyConn = RunService.RenderStepped:Connect(function()
			if not flyEnabled then return end
			local cam = Workspace.CurrentCamera
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			flyVel.VectorVelocity = move.Unit * 50
		end)
	else
		if flyVel then flyVel:Destroy() end
		if flyConn then flyConn:Disconnect() end
	end
end

-- ================== NOCLIP ==================
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

-- ================== INFINITE AMMO ==================
local function toggleInfAmmo(val)
	infAmmoEnabled = val
	if val then
		ammoConn = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if not char then return end
			local tool = char:FindFirstChildWhichIsA("Tool")
			if tool then
				for _, v in ipairs(tool:GetDescendants()) do
					if v.Name == "Ammo" or v.Name == "CurrentAmmo" or v.Name == "Bullets" then
						v.Value = 999
					end
				end
			end
		end)
	else
		if ammoConn then ammoConn:Disconnect() end
	end
end

-- ================== REMOVE ALL DOORS (super common in Prison Life scripts) ==================
local function removeDoors()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name:lower():find("door") or obj.Name:lower():find("cell") then
			if obj:IsA("BasePart") then
				obj.CanCollide = false
				obj.Transparency = 0.7
			elseif obj:IsA("Model") then
				for _, p in ipairs(obj:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanCollide = false
						p.Transparency = 0.7
					end
				end
			end
		end
	end
	OrionLib:MakeNotification({Name = "Doors Removed!", Content = "All doors are now noclipped!", Time = 4})
end

-- ================== GUI (locked behind key) ==================
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MainTab:AddToggle({
	Name = "Aimbot (INSTANT CAMERA SNAP - VERY BLATANT)",
	Default = false,
	Callback = function(val)
		if not verified then OrionLib:MakeNotification({Name = "Key Required!", Content = "Verify key first!", Time = 3}) return end
		aimbotEnabled = val
		if val then
			aimConn = RunService.RenderStepped:Connect(function()
				if aimbotEnabled then
					local target = getClosestTarget()
					if target then
						Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
					end
				end
			end)
		else
			if aimConn then aimConn:Disconnect() end
		end
	end
})

MainTab:AddToggle({
	Name = "ESP (Team Colored Wallhack)",
	Default = false,
	Callback = function(val)
		if not verified then OrionLib:MakeNotification({Name = "Key Required!", Content = "Verify key first!", Time = 3}) return end
		espEnabled = val
		if val then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then createHighlight(plr, plr.Character) end
			end
		else
			for _, hl in pairs(highlights) do hl:Destroy() end
			highlights = {}
		end
	end
})

local MoveTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://6031097228", PremiumOnly = false})

MoveTab:AddToggle({Name = "Fly (WASD - 50 speed)", Default = false, Callback = function(v) if verified then toggleFly(v) else OrionLib:MakeNotification({Name = "Key Required!", Content = "Verify key first!", Time = 3}) end end})
MoveTab:AddToggle({Name = "Noclip", Default = false, Callback = function(v) if verified then toggleNoclip(v) else OrionLib:MakeNotification({Name = "Key Required!", Content = "Verify key first!", Time = 3}) end end})
MoveTab:AddToggle({Name = "Infinite Jump", Default = false, Callback = function(v) infJumpEnabled = v end})
MoveTab:AddSlider({Name = "WalkSpeed", Default = 16, Min = 16, Max = 100, Increment = 1, Callback = function(v)
	speedValue = v
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = v
	end
end})

local ExtraTab = Window:MakeTab({Name = "Extras", Icon = "rbxassetid://6031097228", PremiumOnly = false})

ExtraTab:AddToggle({Name = "Infinite Ammo (works on all guns)", Default = false, Callback = function(v) if verified then toggleInfAmmo(v) else OrionLib:MakeNotification({Name = "Key Required!", Content = "Verify key first!", Time = 3}) end end})
ExtraTab:AddButton({Name = "Remove All Doors (instant escape)", Callback = function() if verified then removeDoors() else OrionLib:MakeNotification({Name = "Key Required!", Content = "Verify key first!", Time = 3}) end end})

-- ================== INFINITE JUMP ==================
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ================== AIMBOT LOOP (separate for clean toggle) ==================
RunService.RenderStepped:Connect(function()
	if aimbotEnabled and verified then
		local target = getClosestTarget()
		if target then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
		end
	end
end)

setupESP()
OrionLib:Init()

OrionLib:MakeNotification({
	Name = "Prison Life Script Loaded!",
	Content = "Enter key in Key System tab (your Pastebin) → then go wild 🥷🔫",
	Image = "rbxassetid://6031097228",
	Time = 8
})
