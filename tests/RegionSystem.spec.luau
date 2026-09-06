return function()
	local Players = game:GetService("Players")
	local Lighting = game:GetService("Lighting")
	local SoundService = game:GetService("SoundService")
	local storage = game:GetService("ReplicatedStorage")
	local system = require(storage.RegionSystem)
	local config = require(storage.RegionSystem.Config)
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local originalPivot, wasAnchored = character:GetPivot(), root.Anchored
	local savedFade, savedLighting = config.FadeTime, config.LightingTransition
	local originalFolder = workspace:WaitForChild("Regions")
	local fixture = Instance.new("Folder")
	fixture.Name = "RegionSystemTest"
	fixture.Parent = originalFolder
	local results = {}
	local entered, exited = 0, 0
	local enteredConnection = system.Entered.Event:Connect(function() entered += 1 end)
	local exitedConnection = system.Exited.Event:Connect(function() exited += 1 end)

	local function check(name, condition, details)
		table.insert(results, { name = name, passed = condition == true, details = details })
		assert(condition, name)
	end

	local function move(position, duration)
		character:PivotTo(CFrame.new(position))
		root.AssemblyLinearVelocity = Vector3.zero
		task.wait(duration or 0.25)
	end

	local function sameColor(a, b)
		return math.abs(a.R - b.R) < 0.0001 and math.abs(a.G - b.G) < 0.0001 and math.abs(a.B - b.B) < 0.0001
	end

	local function part(id, position, size, angle)
		local region = Instance.new("Part")
		region.Name = "Part"
		region.Anchored = true
		region.CanCollide = false
		region.CanTouch = false
		region.Transparency = 1
		region.Size = size or Vector3.new(20, 20, 20)
		region.CFrame = CFrame.new(position) * CFrame.Angles(0, angle or 0, 0)
		region:SetAttribute("RegionId", id)
		region.Parent = fixture
		return region
	end

	local function region(name, lighting)
		return {
			Name = name, Description = name .. " description", Priority = 0,
			Intro = { Enabled = true, Duration = 0.5 },
			Outro = { Enabled = true, Duration = 0.15 },
			IntroMusic = false, OutroMusic = false, Theme = false,
			Lighting = lighting or false,
		}
	end

	local ok, failure = xpcall(function()
		system.Stop()
		root.Anchored = true
		config.FadeTime = 0.03
		config.LightingTransition = 0.1
		local outside = Vector3.new(950, 100, 1000)
		local center = Vector3.new(1000, 100, 1000)
		local brightness, clockTime = Lighting.Brightness, Lighting.ClockTime
		local ambient = Lighting.Ambient
		local a = region("Test A", { Enabled = true, Brightness = 1.1, ClockTime = 6 })
		local b = region("Test B", { Enabled = true, Ambient = Color3.fromRGB(10, 20, 30) })
		config.Regions.__TestA = a
		config.Regions.__TestB = b
		local first = part("__TestA", center)
		move(outside)
		system.Start()
		system.Start()
		local uiCount = 0
		for _, object in player.PlayerGui:GetChildren() do
			if object.Name == "RegionUI" then uiCount += 1 end
		end
		check("Start is idempotent", uiCount == 1)
		move(center)
		check("Entry detected with CanTouch disabled", system.GetCurrentRegion() == "__TestA" and entered == 1)
		local banner = player.PlayerGui.RegionUI.Banner
		check("Upper-center English entry title and description", banner.Visible and banner.RegionName.Text == "Test A" and banner.Description.Text == "Test A description" and banner.Position == UDim2.fromScale(0.5, 0.16) and banner.AnchorPoint == Vector2.new(0.5, 0) and banner.BackgroundTransparency == 1 and banner:GetAttribute("Direction") == "Entering")
		check("Lighting applied", math.abs(Lighting.Brightness - 1.1) < 0.01 and math.abs(Lighting.ClockTime - 6) < 0.01)
		task.wait(0.4)
		check("Staying inside does not repeat entry", entered == 1 and exited == 0)
		move(outside, 0.15)
		check("Exit title shows region name and description", system.GetCurrentRegion() == nil and exited == 1 and banner.Visible and banner:GetAttribute("Direction") == "Leaving" and banner.RegionName.Text == "Test A" and banner.Description.Text == "Test A description")
		task.wait(0.3)
		check("Lighting restored on exit", math.abs(Lighting.Brightness - brightness) < 0.01 and math.abs(Lighting.ClockTime - clockTime) < 0.01)
		local second = part("__TestA", center + Vector3.new(18, 0, 0))
		move(center)
		local groupedEntry, groupedExit = entered, exited
		move(center + Vector3.new(9, 0, 0))
		move(center + Vector3.new(18, 0, 0))
		check("Same ID parts form one continuous region", entered == groupedEntry and exited == groupedExit)
		second:Destroy()
		move(center)
		local nested = part("__TestB", center, Vector3.new(8, 20, 8), math.rad(35))
		task.wait(0.2)
		check("Equal priority retains current region", system.GetCurrentRegion() == "__TestA")
		b.Priority = 5
		task.wait(0.25)
		check("Higher priority rotated region wins", system.GetCurrentRegion() == "__TestB")
		check("A-only lighting restored on A to B", math.abs(Lighting.Brightness - brightness) < 0.01 and math.abs(Lighting.ClockTime - clockTime) < 0.01 and sameColor(Lighting.Ambient, b.Lighting.Ambient))
		nested:Destroy()
		task.wait(0.25)
		check("Removing active part falls back to containing region", system.GetCurrentRegion() == "__TestA")
		check("B-only lighting restored on B to A", sameColor(Lighting.Ambient, ambient))
		move(outside)
		a.Intro = false
		a.Outro = { Enabled = false }
		a.Lighting = false
		move(center)
		check("Optional lighting and titles disable independently", system.GetCurrentRegion() == "__TestA" and not banner.Visible and math.abs(Lighting.Brightness - brightness) < 0.01)
		first:SetAttribute("Enabled", false)
		task.wait(0.2)
		check("Disabled part exits region", system.GetCurrentRegion() == nil)
		first:SetAttribute("Enabled", true)
		a.Intro = { Enabled = true, Duration = 1 }
		a.Outro = { Enabled = true, Duration = 1 }
		a.Theme = { Enabled = true, SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3", Volume = 0 }
		a.IntroMusic = { Enabled = true, SoundId = "rbxasset://sounds/action_falling.ogg", Volume = 0 }
		a.OutroMusic = { Enabled = true, SoundId = "rbxasset://sounds/action_falling.ogg", Volume = 0 }
		move(outside)
		move(center)
		local music = SoundService:FindFirstChild("RegionTheme")
		check("Theme creates a playing loop inside region", music and music.Looped and music.IsPlaying)
		check("Intro sound plays once", SoundService:FindFirstChild("RegionIntro") ~= nil)
		move(outside, 0.15)
		check("Exit immediately stops theme and intro", not SoundService:FindFirstChild("RegionTheme") and not SoundService:FindFirstChild("RegionIntro"))
		check("Exit sound created", SoundService:FindFirstChild("RegionOutro") ~= nil)
		move(center, 0.15)
		move(outside, 0.15)
		move(center, 0.2)
		task.wait(0.45)
		check("Rapid transitions do not revive stale outro", banner:GetAttribute("Direction") == "Entering" and system.GetCurrentRegion() == "__TestA")
		local themeCount = 0
		for _, sound in SoundService:GetChildren() do
			if sound.Name == "RegionTheme" then themeCount += 1 end
		end
		check("Rapid transitions keep one theme", themeCount == 1)
		originalFolder.Parent = storage
		task.wait(0.2)
		check("Removing Regions folder clears occupancy", system.GetCurrentRegion() == nil)
		originalFolder.Parent = workspace
		task.wait(0.2)
		check("Restoring Regions folder resumes detection", system.GetCurrentRegion() == "__TestA")
		system.Stop()
		check("Stop cleans UI sounds and state", not player.PlayerGui:FindFirstChild("RegionUI") and not SoundService:FindFirstChild("RegionTheme") and not SoundService:FindFirstChild("RegionIntro") and not SoundService:FindFirstChild("RegionOutro") and system.GetCurrentRegion() == nil)
		system.Start()
		task.wait(0.25)
		check("Restart detects occupied region", system.GetCurrentRegion() == "__TestA")
		move(outside, 0.15)
		local parent = humanoid.Parent
		humanoid.Parent = storage
		task.wait(0.2)
		check("Missing humanoid during outro clears effects", not player.PlayerGui.RegionUI.Banner.Visible and not SoundService:FindFirstChild("RegionOutro"))
		humanoid.Parent = parent
		move(center)
		check("Character recovery reenters region", system.GetCurrentRegion() == "__TestA")
	end, debug.traceback)

	system.Stop()
	if humanoid and humanoid.Parent ~= character then humanoid.Parent = character end
	originalFolder.Parent = workspace
	fixture:Destroy()
	config.Regions.__TestA = nil
	config.Regions.__TestB = nil
	config.FadeTime, config.LightingTransition = savedFade, savedLighting
	enteredConnection:Disconnect()
	exitedConnection:Disconnect()
	if character.Parent and root.Parent then
		character:PivotTo(originalPivot)
		root.Anchored = wasAnchored
	end
	system.Start()
	return { passed = ok, results = results, failure = not ok and failure or nil }
end
