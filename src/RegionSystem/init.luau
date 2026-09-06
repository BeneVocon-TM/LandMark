local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Config = require(script.Config)
local RegionSystem = {}
local current, connection, gui, panel, title, description
local theme, lightingTween
local titleTweens = {}
local sounds = {}
local originalLighting = {}
local titleVersion = 0
local starting

local lightingProperties = {
	Ambient = true, OutdoorAmbient = true, Brightness = true, ClockTime = true,
	FogColor = true, FogStart = true, FogEnd = true, ExposureCompensation = true,
	ColorShift_Top = true, ColorShift_Bottom = true,
}

RegionSystem.Entered = Instance.new("BindableEvent")
RegionSystem.Entered.Name = "Entered"
RegionSystem.Entered.Parent = script
RegionSystem.Exited = Instance.new("BindableEvent")
RegionSystem.Exited.Name = "Exited"
RegionSystem.Exited.Parent = script

local function option(region, key)
	local value = region[key]
	if value == nil then
		return Config.Defaults[key]
	end
	return value
end

local function enabled(value)
	return type(value) == "table" and value.Enabled ~= false
end

local function createLabel(name, y, height, size, font)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 20, 0, y)
	label.Size = UDim2.new(1, -40, 0, height)
	label.Font = font
	label.TextSize = size
	label.TextColor3 = Color3.fromRGB(245, 247, 250)
	label.TextStrokeColor3 = Color3.fromRGB(12, 14, 17)
	label.TextStrokeTransparency = 0.5
	label.TextWrapped = true
	label.Text = ""
	label.Parent = panel
	return label
end

local function createUI(playerGui)
	gui = Instance.new("ScreenGui")
	gui.Name = "RegionUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 20
	panel = Instance.new("CanvasGroup")
	panel.Name = "Banner"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.fromScale(0.5, 0.16)
	panel.Size = UDim2.new(0.88, 0, 0, 160)
	panel.BackgroundTransparency = 1
	panel.GroupTransparency = 1
	panel.Visible = false
	panel.Parent = gui
	local size = Instance.new("UISizeConstraint")
	size.MaxSize = Vector2.new(700, 160)
	size.Parent = panel
	title = createLabel("RegionName", 0, 64, 52, Enum.Font.Garamond)
	title.TextColor3 = Color3.fromRGB(250, 246, 235)
	title.TextScaled = true
	local titleSize = Instance.new("UITextSizeConstraint")
	titleSize.MinTextSize = 22
	titleSize.MaxTextSize = 52
	titleSize.Parent = title
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.AnchorPoint = Vector2.new(0.5, 0.5)
	divider.Position = UDim2.new(0.5, 0, 0, 82)
	divider.Size = UDim2.new(0.62, 0, 0, 18)
	divider.BackgroundTransparency = 1
	divider.Parent = panel
	local diamond = Instance.new("Frame")
	diamond.Name = "Diamond"
	diamond.AnchorPoint = Vector2.new(0.5, 0.5)
	diamond.Position = UDim2.fromScale(0.5, 0.5)
	diamond.Size = UDim2.fromOffset(12, 12)
	diamond.Rotation = 45
	diamond.BorderSizePixel = 0
	diamond.BackgroundColor3 = Color3.fromRGB(244, 235, 211)
	diamond.Parent = divider
	for _, side in { "Left", "Right" } do
		local line = Instance.new("Frame")
		line.Name = side .. "Line"
		local left = side == "Left"
		line.AnchorPoint = Vector2.new(left and 1 or 0, 0.5)
		line.Position = UDim2.new(0.5, left and -9 or 9, 0.5, 0)
		line.Size = UDim2.new(0.5, -9, 0, 1)
		line.BorderSizePixel = 0
		line.BackgroundColor3 = diamond.BackgroundColor3
		line.BackgroundTransparency = 0.15
		line.Parent = divider
	end
	description = createLabel("Description", 103, 46, 17, Enum.Font.Gotham)
	description.TextColor3 = Color3.fromRGB(232, 231, 225)
	description.TextScaled = true
	local descriptionSize = Instance.new("UITextSizeConstraint")
	descriptionSize.MinTextSize = 11
	descriptionSize.MaxTextSize = 17
	descriptionSize.Parent = description
	gui.Parent = playerGui
end

local function cancelTitleTweens()
	for _, tween in titleTweens do tween:Cancel() end
	table.clear(titleTweens)
end

local function animateTitle(object, duration, properties, delay)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, delay or 0)
	local tween = TweenService:Create(object, info, properties)
	table.insert(titleTweens, tween)
	tween:Play()
end

local function hideTitle()
	titleVersion += 1
	cancelTitleTweens()
	if panel then
		panel.GroupTransparency = 1
		panel.Visible = false
	end
end

local function showTitle(region, entering, version)
	local settings = option(region, entering and "Intro" or "Outro")
	if not enabled(settings) or version ~= titleVersion or not gui then return end
	local fade = math.max(Config.FadeTime, 0)
	local offset = entering and -8 or 8
	local diamond = panel.Divider.Diamond
	local lines = { panel.Divider.LeftLine, panel.Divider.RightLine }
	cancelTitleTweens()
	panel.Position = UDim2.new(0.5, 0, 0.16, offset)
	panel.GroupTransparency = 1
	panel.Visible = true
	title.Position = UDim2.new(0, 20, 0, 12)
	title.TextTransparency = 1
	title.TextStrokeTransparency = 1
	title.Text = option(region, "Name")
	description.Position = UDim2.new(0, 20, 0, 113)
	description.TextTransparency = 1
	description.TextStrokeTransparency = 1
	description.Text = option(region, "Description")
	diamond.Size = UDim2.fromOffset(0, 0)
	diamond.Rotation = entering and -45 or 135
	diamond.BackgroundTransparency = 1
	for _, line in lines do line.Size = UDim2.fromOffset(0, 1) end
	panel:SetAttribute("Direction", entering and "Entering" or "Leaving")
	animateTitle(panel, fade, { Position = UDim2.fromScale(0.5, 0.16), GroupTransparency = 0 })
	animateTitle(title, fade * 0.8, { Position = UDim2.new(0, 20, 0, 0), TextTransparency = 0, TextStrokeTransparency = 0.5 })
	animateTitle(diamond, fade * 0.8, { Size = UDim2.fromOffset(12, 12), Rotation = 45, BackgroundTransparency = 0 })
	for _, line in lines do
		animateTitle(line, fade * 0.8, { Size = UDim2.new(0.5, -9, 0, 1) }, fade * 0.2)
	end
	animateTitle(description, fade * 0.7, { Position = UDim2.new(0, 20, 0, 103), TextTransparency = 0, TextStrokeTransparency = 0.5 }, fade * 0.3)
	task.wait(fade + math.max(settings.Duration or 2, 0))
	if version ~= titleVersion or not gui then return end
	cancelTitleTweens()
	animateTitle(panel, fade, { Position = UDim2.new(0.5, 0, 0.16, offset), GroupTransparency = 1 })
	animateTitle(title, fade, { Position = UDim2.new(0, 20, 0, 12), TextTransparency = 1, TextStrokeTransparency = 1 })
	animateTitle(description, fade * 0.8, { Position = UDim2.new(0, 20, 0, 113), TextTransparency = 1, TextStrokeTransparency = 1 })
	animateTitle(diamond, fade * 0.8, { Size = UDim2.fromOffset(0, 0), Rotation = entering and -45 or 135, BackgroundTransparency = 1 })
	for _, line in lines do animateTitle(line, fade * 0.7, { Size = UDim2.fromOffset(0, 1) }) end
	task.wait(fade)
	if version == titleVersion and panel then
		cancelTitleTweens()
		panel.Visible = false
	end
end

local function clearSounds()
	for sound in sounds do sound:Destroy() end
	table.clear(sounds)
	if theme then theme:Destroy() end
	theme = nil
end

local function playSound(settings, regionId, name, looped)
	if not enabled(settings) then return nil end
	local id = tostring(settings.SoundId or "")
	local template
	if id == "" then
		local audio = script:FindFirstChild("Audio")
		local regionAudio = audio and audio:FindFirstChild(tostring(regionId))
		local defaultAudio = audio and audio:FindFirstChild("Default")
		template = regionAudio and regionAudio:FindFirstChild(name)
		if not template or not template:IsA("Sound") or template.SoundId == "" then
			template = defaultAudio and defaultAudio:FindFirstChild(name)
		end
		if not template or not template:IsA("Sound") then return nil end
		id = template.SoundId
	end
	local number = id:match("^%d+$") or id:match("^rbxassetid://(%d+)$")
	local builtIn = id:match("^rbxasset://sounds/%S+$")
	if (not number and not builtIn) or tonumber(number) == 0 then return nil end
	local sound = template and template:Clone() or Instance.new("Sound")
	sound.Name = "Region" .. name
	sound.PlayOnRemove = false
	sound:Stop()
	sound.TimePosition = 0
	 sound.SoundId = number and "rbxassetid://" .. number or id
	if settings.Volume ~= nil then sound.Volume = math.clamp(settings.Volume, 0, 10) end
	sound.Looped = looped
	sound.Parent = SoundService
	if not looped then
		sounds[sound] = true
		sound.Ended:Once(function() sound:Destroy() end)
		sound.Destroying:Once(function() sounds[sound] = nil end)
		Debris:AddItem(sound, 120)
	end
	sound:Play()
	return sound
end

local function applyLighting(settings)
	if lightingTween then lightingTween:Cancel() end
	local target = table.clone(originalLighting)
	local active = enabled(settings)
	if active then
		for property, value in settings do
			if lightingProperties[property] and typeof(value) == typeof(Lighting[property]) then
				if originalLighting[property] == nil then originalLighting[property] = Lighting[property] end
				target[property] = value
			end
		end
	end
	if next(target) == nil then return end
	local tween = TweenService:Create(Lighting, TweenInfo.new(math.max(Config.LightingTransition, 0)), target)
	lightingTween = tween
	tween.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed and lightingTween == tween and not active then
			table.clear(originalLighting)
		end
	end)
	tween:Play()
end

local function transition(nextRegion, silent)
	local previous = current
	if previous and nextRegion and previous.id == nextRegion.id then
		current = nextRegion
		return
	end
	if not previous and not nextRegion then
		if silent then
			hideTitle()
			clearSounds()
		end
		return
	end
	current = nextRegion
	hideTitle()
	clearSounds()
	applyLighting(nextRegion and option(nextRegion.config, "Lighting") or false)
	if gui then gui:SetAttribute("CurrentRegion", nextRegion and tostring(nextRegion.id) or nil) end
	if previous then
		if not silent then playSound(option(previous.config, "OutroMusic"), previous.id, "Outro", false) end
		RegionSystem.Exited:Fire(previous.id, previous.config, previous.part)
	end
	if nextRegion then
		playSound(option(nextRegion.config, "IntroMusic"), nextRegion.id, "Intro", false)
		theme = playSound(option(nextRegion.config, "Theme"), nextRegion.id, "Theme", true)
		RegionSystem.Entered:Fire(nextRegion.id, nextRegion.config, nextRegion.part)
	end
	if silent then return end
	local version = titleVersion
	task.spawn(function()
		if previous then showTitle(previous.config, false, version) end
		if nextRegion then showTitle(nextRegion.config, true, version) end
	end)
end

local function findRegion(player, overlap)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or not character:FindFirstChild("HumanoidRootPart") then
		return nil, true
	end
	local folder = workspace:FindFirstChild("Regions")
	if not folder then return nil, false end
	local body = {}
	for _, part in character:GetChildren() do
		if part:IsA("BasePart") then table.insert(body, part) end
	end
	overlap.FilterDescendantsInstances = body
	local best, bestPriority
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part:GetAttribute("Enabled") == false then continue end
		if #workspace:GetPartsInPart(part, overlap) == 0 then continue end
		local id = part:GetAttribute("RegionId") or part
		local config = Config.Regions[id] or Config.Defaults
		local priority = option(config, "Priority")
		local keepCurrent = current and id == current.id
		if not best or priority > bestPriority or (priority == bestPriority and keepCurrent) then
			best = { id = id, part = part, config = config }
			bestPriority = priority
		end
	end
	return best, false
end

function RegionSystem.Start()
	assert(RunService:IsClient(), "RegionSystem.Start must run from a LocalScript")
	if connection or starting then return RegionSystem end
	local token = {}
	starting = token
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	if starting ~= token then return RegionSystem end
	createUI(playerGui)
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Include
	overlap.MaxParts = 1
	overlap.RespectCanCollide = false
	local elapsed = 0
	connection = RunService.Heartbeat:Connect(function(delta)
		elapsed += delta
		if elapsed < math.max(Config.CheckInterval, 0.03) then return end
		elapsed = 0
		local nextRegion, silent = findRegion(player, overlap)
		transition(nextRegion, silent)
	end)
	starting = nil
	return RegionSystem
end

function RegionSystem.GetCurrentRegion()
	if current then return current.id, current.config, current.part end
	return nil
end

function RegionSystem.Stop()
	starting = nil
	if connection then connection:Disconnect() end
	connection = nil
	current = nil
	hideTitle()
	clearSounds()
	if lightingTween then lightingTween:Cancel() end
	lightingTween = nil
	for property, value in originalLighting do Lighting[property] = value end
	table.clear(originalLighting)
	if gui then gui:Destroy() end
	gui, panel, title, description = nil, nil, nil, nil
end

return RegionSystem
