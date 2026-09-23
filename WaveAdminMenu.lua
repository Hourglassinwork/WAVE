local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gameDefaults = {gravity = workspace.Gravity}
do
	local startingCharacter = player.Character or player.CharacterAdded:Wait()
	local startingHumanoid = startingCharacter:FindFirstChildOfClass("Humanoid") or startingCharacter:WaitForChild("Humanoid")
	gameDefaults.walkSpeed = startingHumanoid.WalkSpeed
	gameDefaults.useJumpPower = startingHumanoid.UseJumpPower
	gameDefaults.jumpHeight = startingHumanoid.JumpHeight
	gameDefaults.jumpPower = startingHumanoid.JumpPower
	while not workspace.CurrentCamera do
		workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
	end
	gameDefaults.fieldOfView = workspace.CurrentCamera.FieldOfView
end
RunService:UnbindFromRenderStep("WaveAdminAimbot")
RunService:UnbindFromRenderStep("WaveAdminAimbotFOVCircle")
RunService:UnbindFromRenderStep("WaveAdminTriggerBot")
RunService:UnbindFromRenderStep("WaveAdminFieldOfView")

for _, existing in ipairs(playerGui:GetChildren()) do
	if existing.Name == "WaveAdminMenu" or existing.Name == "WaveAimbotCircle" or existing.Name == "WaveActiveCheats" then
		existing:Destroy()
	end
end
for _, existing in ipairs(workspace:GetChildren()) do
	if string.sub(existing.Name, 1, 13) == "WaveWaypoint_" then existing:Destroy() end
end
for _, targetPlayer in ipairs(Players:GetPlayers()) do
	local character = targetPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		for _, existing in ipairs(rootPart:GetChildren()) do
			if existing.Name == "WavePlayerTrail" or existing.Name == "WaveTrailLeft" or existing.Name == "WaveTrailRight" then
				existing:Destroy()
			end
		end
	end
end

local colors = {
	background = Color3.fromRGB(3, 6, 14),
	panel = Color3.fromRGB(13, 18, 31),
	sidebar = Color3.fromRGB(8, 12, 23),
	card = Color3.fromRGB(20, 27, 44),
	cardTop = Color3.fromRGB(27, 36, 58),
	cardHover = Color3.fromRGB(31, 41, 66),
	input = Color3.fromRGB(8, 13, 25),
	border = Color3.fromRGB(74, 91, 132),
	accent = Color3.fromRGB(112, 96, 255),
	accent2 = Color3.fromRGB(53, 211, 196),
	accentSoft = Color3.fromRGB(48, 43, 112),
	switchOff = Color3.fromRGB(48, 60, 88),
	text = Color3.fromRGB(243, 246, 255),
	muted = Color3.fromRGB(155, 168, 197),
	faint = Color3.fromRGB(93, 107, 139),
	success = Color3.fromRGB(69, 224, 166),
	danger = Color3.fromRGB(255, 91, 122),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveAdminMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 20
screenGui.Parent = playerGui

local activeHud = {enabled = true}
activeHud.gui = Instance.new("ScreenGui")
activeHud.gui.Name = "WaveActiveCheats"
activeHud.gui.ResetOnSpawn = false
activeHud.gui.IgnoreGuiInset = false
activeHud.gui.DisplayOrder = 18
activeHud.gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
pcall(function()
	activeHud.gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
end)
activeHud.gui.Parent = playerGui

activeHud.panel = Instance.new("Frame")
activeHud.panel.Name = "ActiveCheatsPanel"
activeHud.panel.Position = UDim2.fromOffset(12, 12)
activeHud.panel.Size = UDim2.fromOffset(190, 56)
activeHud.panel.BackgroundColor3 = colors.panel
activeHud.panel.BackgroundTransparency = 0.16
activeHud.panel.BorderSizePixel = 0
activeHud.panel.Parent = activeHud.gui
activeHud.panelCorner = Instance.new("UICorner")
activeHud.panelCorner.CornerRadius = UDim.new(0, 9)
activeHud.panelCorner.Parent = activeHud.panel

activeHud.stroke = Instance.new("UIStroke")
activeHud.stroke.Color = colors.border
activeHud.stroke.Transparency = 0.35
activeHud.stroke.Thickness = 1
activeHud.stroke.Parent = activeHud.panel

activeHud.accent = Instance.new("Frame")
activeHud.accent.Name = "Accent"
activeHud.accent.Position = UDim2.fromOffset(0, 9)
activeHud.accent.Size = UDim2.new(0, 3, 1, -18)
activeHud.accent.BackgroundColor3 = colors.accent
activeHud.accent.BorderSizePixel = 0
activeHud.accent.Parent = activeHud.panel
activeHud.accentCorner = Instance.new("UICorner")
activeHud.accentCorner.CornerRadius = UDim.new(0, 2)
activeHud.accentCorner.Parent = activeHud.accent

activeHud.header = Instance.new("TextLabel")
activeHud.header.Name = "Header"
activeHud.header.Position = UDim2.fromOffset(13, 8)
activeHud.header.Size = UDim2.new(1, -24, 0, 16)
activeHud.header.BackgroundTransparency = 1
activeHud.header.Font = Enum.Font.GothamBold
activeHud.header.Text = "WAVE  //  ACTIVE"
activeHud.header.TextColor3 = colors.text
activeHud.header.TextSize = 10
activeHud.header.TextXAlignment = Enum.TextXAlignment.Left
activeHud.header.Parent = activeHud.panel

activeHud.list = Instance.new("TextLabel")
activeHud.list.Name = "EnabledList"
activeHud.list.Position = UDim2.fromOffset(13, 29)
activeHud.list.Size = UDim2.new(1, -24, 0, 16)
activeHud.list.BackgroundTransparency = 1
activeHud.list.Font = Enum.Font.GothamMedium
activeHud.list.Text = "NONE ENABLED"
activeHud.list.TextColor3 = colors.muted
activeHud.list.TextSize = 9
activeHud.list.TextWrapped = false
activeHud.list.TextXAlignment = Enum.TextXAlignment.Left
activeHud.list.TextYAlignment = Enum.TextYAlignment.Top
activeHud.list.Parent = activeHud.panel

local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = colors.background
backdrop.BackgroundTransparency = 0.22
backdrop.BorderSizePixel = 0
backdrop.Visible = false
backdrop.Parent = screenGui

do
	local backdropGradient = Instance.new("UIGradient")
	backdropGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.background),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 43)),
	})
	backdropGradient.Rotation = 35
	backdropGradient.Parent = backdrop
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.82, 0.78)
panel.BackgroundColor3 = colors.panel
panel.BorderSizePixel = 0
panel.Visible = false
panel.ClipsDescendants = true
panel.Parent = screenGui

do
	local panelConstraint = Instance.new("UISizeConstraint")
	panelConstraint.MinSize = Vector2.new(410, 390)
	panelConstraint.MaxSize = Vector2.new(880, 620)
	panelConstraint.Parent = panel

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 18)
	panelCorner.Parent = panel

	local panelGradient = Instance.new("UIGradient")
	panelGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 23, 39)),
		ColorSequenceKeypoint.new(0.55, colors.panel),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 15, 28)),
	})
	panelGradient.Rotation = 28
	panelGradient.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = colors.accent
	panelStroke.Transparency = 0.28
	panelStroke.Thickness = 1.3
	panelStroke.Parent = panel
end

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = panel

local openSound = Instance.new("Sound")
openSound.Name = "MenuScissorOpenSound"
openSound.SoundId = "rbxassetid://9118817829"
openSound.Volume = 0.14
openSound.PlaybackSpeed = 1.04
openSound:SetAttribute("Cooldown", 0.24)
openSound.Parent = SoundService

local closeSound = Instance.new("Sound")
closeSound.Name = "MenuCloseSound"
closeSound.SoundId = "rbxassetid://9118823101"
closeSound.Volume = 0.1
closeSound.PlaybackSpeed = 0.88
closeSound:SetAttribute("Cooldown", 0.18)
closeSound.Parent = SoundService

local clickSound = Instance.new("Sound")
clickSound.Name = "MenuClickSound"
clickSound.SoundId = "rbxassetid://6042053626"
clickSound.Volume = 0.075
clickSound.PlaybackSpeed = 1.02
clickSound:SetAttribute("Cooldown", 0.035)
clickSound.Parent = SoundService

local hoverSound = Instance.new("Sound")
hoverSound.Name = "MenuHoverSound"
hoverSound.SoundId = "rbxassetid://104530151078585"
hoverSound.Volume = 0.014
hoverSound.PlaybackSpeed = 1.12
hoverSound:SetAttribute("Cooldown", 0.065)
hoverSound.Parent = SoundService

local function playSound(sound)
	if not sound or sound.SoundId == "" then return end
	local now = os.clock()
	local cooldown = sound:GetAttribute("Cooldown") or 0
	if now - (sound:GetAttribute("LastPlayed") or 0) < cooldown then return end
	sound:SetAttribute("LastPlayed", now)
	local voice = sound:Clone()
	voice.Name = sound.Name .. "Voice"
	voice.Volume *= 0.96 + math.random() * 0.05
	voice.PlaybackSpeed *= 0.985 + math.random() * 0.03
	voice.Parent = SoundService
	voice:Play()
	voice.Ended:Once(function()
		voice:Destroy()
	end)
	task.delay(3, function()
		if voice.Parent then voice:Destroy() end
	end)
end

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 178, 1, 0)
sidebar.BackgroundColor3 = colors.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = panel

do
	local sidebarGradient = Instance.new("UIGradient")
	sidebarGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 18, 34)),
		ColorSequenceKeypoint.new(1, colors.sidebar),
	})
	sidebarGradient.Rotation = 90
	sidebarGradient.Parent = sidebar

	local sidebarLine = Instance.new("Frame")
	sidebarLine.Name = "Divider"
	sidebarLine.Position = UDim2.new(1, -1, 0, 0)
	sidebarLine.Size = UDim2.new(0, 1, 1, 0)
	sidebarLine.BackgroundColor3 = colors.border
	sidebarLine.BackgroundTransparency = 0.45
	sidebarLine.BorderSizePixel = 0
	sidebarLine.Parent = sidebar
end

local brand = Instance.new("TextLabel")
brand.Name = "Brand"
brand.Position = UDim2.fromOffset(22, 22)
brand.Size = UDim2.new(1, -44, 0, 30)
brand.BackgroundTransparency = 1
brand.Font = Enum.Font.GothamBold
brand.Text = "WAVE"
brand.TextColor3 = colors.text
brand.TextSize = 22
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = sidebar

do
	local brandGradient = Instance.new("UIGradient")
	brandGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.text),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(176, 168, 255)),
		ColorSequenceKeypoint.new(1, colors.accent2),
	})
	brandGradient.Parent = brand
end

local brandAccent = Instance.new("Frame")
brandAccent.Position = UDim2.fromOffset(22, 57)
brandAccent.Size = UDim2.fromOffset(28, 3)
brandAccent.BackgroundColor3 = colors.accent
brandAccent.BorderSizePixel = 0
brandAccent.Parent = sidebar

do
	local brandAccentGradient = Instance.new("UIGradient")
	brandAccentGradient.Color = ColorSequence.new(colors.accent, colors.accent2)
	brandAccentGradient.Parent = brandAccent
end

local brandSub = Instance.new("TextLabel")
brandSub.Position = UDim2.fromOffset(22, 68)
brandSub.Size = UDim2.new(1, -44, 0, 20)
brandSub.BackgroundTransparency = 1
brandSub.Font = Enum.Font.Gotham
brandSub.Text = "ADMIN CONTROL"
brandSub.TextColor3 = colors.faint
brandSub.TextSize = 10
brandSub.TextXAlignment = Enum.TextXAlignment.Left
brandSub.Parent = sidebar

local tabs = {}
local tabNames = {"Movement", "Visuals", "Combat", "Utility", "Customize"}
local tabLabels = {Movement = "MOVEMENT", Visuals = "VISUALS", Combat = "COMBAT", Utility = "UTILITY", Customize = "CUSTOMIZE"}
local tabIndexes = {Movement = 1, Visuals = 2, Combat = 3, Utility = 4, Customize = 5}
local activeTabName = "Movement"
local themeSystem = {}
local presetSystem = {}
local settings = {textScale = 1, ctrlHoldSeconds = 0.5, lastCtrlTap = 0}
themeSystem.favoriteSystem = {items = {}, states = {}, displayCards = {}}
themeSystem.keybindSystem = {items = {}, byKey = {}}
themeSystem.searchSystem = {selectedCategory = "All", categoryByCard = {}}
themeSystem.waypoints = {items = {}, cards = {}, markers = {}, nextId = 0, selectedHue = 0.53, walkGeneration = 0}

local function makeTab(tabName, index)
	local tab = Instance.new("TextButton")
	tab.Name = tabName .. "Tab"
	tab.Position = UDim2.fromOffset(14, 104 + (index - 1) * 46)
	tab.Size = UDim2.new(1, -28, 0, 40)
	tab.BackgroundColor3 = colors.sidebar
	tab.BorderSizePixel = 0
	tab.AutoButtonColor = false
	tab.Font = Enum.Font.GothamMedium
	tab.Text = tabLabels[tabName]
	tab.TextColor3 = Color3.fromRGB(175, 188, 214)
	tab.TextSize = 11
	tab.TextXAlignment = Enum.TextXAlignment.Left
	tab.Parent = sidebar
	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingLeft = UDim.new(0, 34)
	tabPadding.Parent = tab

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 10)
	tabCorner.Parent = tab
	local categoryDot = Instance.new("Frame")
	categoryDot.Name = "CategoryDot"
	categoryDot.AnchorPoint = Vector2.new(0.5, 0.5)
	categoryDot.Position = UDim2.new(0, 17, 0.5, 0)
	categoryDot.Size = UDim2.fromOffset(7, 7)
	categoryDot.BackgroundColor3 = colors.accent
	categoryDot.BackgroundTransparency = index == 1 and 0 or 0.58
	categoryDot.BorderSizePixel = 0
	categoryDot.Parent = tab
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = categoryDot
	tab.MouseEnter:Connect(function()
		if activeTabName ~= tabName then
			TweenService:Create(tab, TweenInfo.new(0.16), {
				BackgroundColor3 = colors.card,
				TextColor3 = colors.text,
			}):Play()
		end
	end)
	tab.MouseLeave:Connect(function()
		if activeTabName ~= tabName then
			TweenService:Create(tab, TweenInfo.new(0.16), {
				BackgroundColor3 = colors.sidebar,
				TextColor3 = colors.muted,
			}):Play()
		end
	end)

	tabs[tabName] = tab
	return tab
end

for index, tabName in ipairs(tabNames) do
	makeTab(tabName, index)
end

local selectionBar = Instance.new("Frame")
selectionBar.Name = "SelectionBar"
selectionBar.Position = UDim2.fromOffset(14, 112)
selectionBar.Size = UDim2.fromOffset(3, 24)
selectionBar.BackgroundColor3 = colors.accent
selectionBar.BorderSizePixel = 0
selectionBar.ZIndex = 3
selectionBar.Parent = sidebar
do
	local selectionGradient = Instance.new("UIGradient")
	selectionGradient.Color = ColorSequence.new(colors.accent, colors.accent2)
	selectionGradient.Rotation = 90
	selectionGradient.Parent = selectionBar
	local selectionBarCorner = Instance.new("UICorner")
	selectionBarCorner.CornerRadius = UDim.new(1, 0)
	selectionBarCorner.Parent = selectionBar
end

local sidebarFooter = Instance.new("TextLabel")
sidebarFooter.Position = UDim2.new(0, 22, 1, -55)
sidebarFooter.Size = UDim2.new(1, -44, 0, 35)
sidebarFooter.BackgroundColor3 = colors.input
sidebarFooter.BackgroundTransparency = 0.32
sidebarFooter.Font = Enum.Font.Gotham
sidebarFooter.Text = "HOLD CTRL 0.5 SEC OR DOUBLE TAP  •  TAP TO CLOSE"
sidebarFooter.TextColor3 = colors.faint
sidebarFooter.TextSize = 9
sidebarFooter.TextWrapped = true
sidebarFooter.TextXAlignment = Enum.TextXAlignment.Left
sidebarFooter.Parent = sidebar
do
	local footerCorner = Instance.new("UICorner")
	footerCorner.CornerRadius = UDim.new(0, 8)
	footerCorner.Parent = sidebarFooter
	local footerPadding = Instance.new("UIPadding")
	footerPadding.PaddingLeft = UDim.new(0, 10)
	footerPadding.Parent = sidebarFooter
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Position = UDim2.new(0, 178, 0, 0)
main.Size = UDim2.new(1, -178, 1, 0)
main.BackgroundTransparency = 1
main.Parent = panel

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Position = UDim2.fromOffset(28, 22)
topBar.Size = UDim2.new(1, -56, 0, 58)
topBar.BackgroundTransparency = 1
topBar.Parent = main

do
	local headerDivider = Instance.new("Frame")
	headerDivider.Name = "HeaderDivider"
	headerDivider.Position = UDim2.new(0, 28, 0, 86)
	headerDivider.Size = UDim2.new(1, -56, 0, 1)
	headerDivider.BackgroundColor3 = colors.border
	headerDivider.BackgroundTransparency = 0.56
	headerDivider.BorderSizePixel = 0
	headerDivider.Parent = main
	local headerGradient = Instance.new("UIGradient")
	headerGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0.8),
	})
	headerGradient.Parent = headerDivider
end

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -50, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Player controls"
title.TextColor3 = colors.text
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Position = UDim2.fromOffset(0, 31)
subtitle.Size = UDim2.new(1, -20, 0, 20)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Adjust movement settings for your character."
subtitle.TextColor3 = colors.muted
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, 0, 0, 0)
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.BackgroundColor3 = colors.card
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Text = "×"
closeButton.Font = Enum.Font.GothamMedium
closeButton.TextSize = 20
closeButton.TextYAlignment = Enum.TextYAlignment.Center
closeButton.TextColor3 = colors.muted
closeButton.Parent = topBar
do
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton
end

local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.AnchorPoint = Vector2.new(1, 0)
resetButton.Position = UDim2.new(1, -40, 0, 0)
resetButton.Size = UDim2.fromOffset(32, 32)
resetButton.BackgroundColor3 = colors.card
resetButton.BorderSizePixel = 0
resetButton.AutoButtonColor = false
resetButton.Text = ""
resetButton.Parent = topBar
do
	local resetCorner = Instance.new("UICorner")
	resetCorner.CornerRadius = UDim.new(0, 8)
	resetCorner.Parent = resetButton
end

-- Loop/refresh icon built from shapes, since Roblox's default fonts don't
-- contain arrow/loop unicode glyphs (they render as an empty box otherwise).
do
	local loopIcon = Instance.new("Frame")
	loopIcon.Name = "LoopIcon"
	loopIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	loopIcon.Position = UDim2.fromScale(0.5, 0.5)
	loopIcon.Size = UDim2.fromOffset(16, 16)
	loopIcon.BackgroundColor3 = colors.muted
	loopIcon.BorderSizePixel = 0
	loopIcon.Parent = resetButton
	local loopIconCorner = Instance.new("UICorner")
	loopIconCorner.CornerRadius = UDim.new(1, 0)
	loopIconCorner.Parent = loopIcon

	local loopIconHole = Instance.new("Frame")
	loopIconHole.Name = "Hole"
	loopIconHole.AnchorPoint = Vector2.new(0.5, 0.5)
	loopIconHole.Position = UDim2.fromScale(0.5, 0.5)
	loopIconHole.Size = UDim2.fromOffset(9, 9)
	loopIconHole.BackgroundColor3 = colors.card
	loopIconHole.BorderSizePixel = 0
	loopIconHole.ZIndex = 2
	loopIconHole.Parent = loopIcon
	local loopIconHoleCorner = Instance.new("UICorner")
	loopIconHoleCorner.CornerRadius = UDim.new(1, 0)
	loopIconHoleCorner.Parent = loopIconHole

	local loopIconGap = Instance.new("Frame")
	loopIconGap.Name = "Gap"
	loopIconGap.AnchorPoint = Vector2.new(0.5, 0.5)
	loopIconGap.Position = UDim2.new(0.5, 6, 0.5, -6)
	loopIconGap.Size = UDim2.fromOffset(9, 9)
	loopIconGap.BackgroundColor3 = colors.card
	loopIconGap.BorderSizePixel = 0
	loopIconGap.ZIndex = 2
	loopIconGap.Parent = loopIcon

	local loopIconArrow = Instance.new("Frame")
	loopIconArrow.Name = "Arrow"
	loopIconArrow.AnchorPoint = Vector2.new(0.5, 0.5)
	loopIconArrow.Position = UDim2.new(0.5, 5, 0.5, -3)
	loopIconArrow.Size = UDim2.fromOffset(5, 5)
	loopIconArrow.Rotation = 45
	loopIconArrow.BackgroundColor3 = colors.muted
	loopIconArrow.BorderSizePixel = 0
	loopIconArrow.ZIndex = 3
	loopIconArrow.Parent = loopIcon
end

local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Position = UDim2.fromOffset(28, 96)
content.Size = UDim2.new(1, -56, 1, -126)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = colors.accent
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

do
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingBottom = UDim.new(0, 12)
	contentPadding.Parent = content

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 12)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = content
end

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function addCard(name, height, order)
	local card = Instance.new("Frame")
	card.Name = name
	card.Size = UDim2.new(1, -3, 0, height)
	card.BackgroundColor3 = colors.card
	card.BorderSizePixel = 0
	card.LayoutOrder = order
	card.Active = true
	card.ClipsDescendants = true
	card.Parent = content
	addCorner(card, 12)

	local cardGradient = Instance.new("UIGradient")
	cardGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.cardTop),
		ColorSequenceKeypoint.new(0.42, colors.card),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 22, 38)),
	})
	cardGradient.Rotation = 12
	cardGradient.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = colors.border
	cardStroke.Transparency = 0.62
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local accentRail = Instance.new("Frame")
	accentRail.Name = "AccentRail"
	accentRail.Position = UDim2.fromOffset(0, 16)
	accentRail.Size = UDim2.new(0, 2, 1, -32)
	accentRail.BackgroundColor3 = colors.accent
	accentRail.BackgroundTransparency = 0.38
	accentRail.BorderSizePixel = 0
	accentRail.Parent = card
	addCorner(accentRail, 2)
	local railGradient = Instance.new("UIGradient")
	railGradient.Color = ColorSequence.new(colors.accent, colors.accent2)
	railGradient.Rotation = 90
	railGradient.Parent = accentRail

	card.MouseEnter:Connect(function()
		TweenService:Create(cardStroke, TweenInfo.new(0.18), {Transparency = 0.2, Color = colors.accent}):Play()
		TweenService:Create(accentRail, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(cardStroke, TweenInfo.new(0.18), {Transparency = 0.62, Color = colors.border}):Play()
		TweenService:Create(accentRail, TweenInfo.new(0.18), {BackgroundTransparency = 0.38}):Play()
	end)
	return card
end

local function addCardTitle(card, heading, description)
	local headingLabel = Instance.new("TextLabel")
	headingLabel.Name = "CardHeading"
	headingLabel.Position = UDim2.fromOffset(17, 14)
	headingLabel.Size = UDim2.new(1, -34, 0, 22)
	headingLabel.BackgroundTransparency = 1
	headingLabel.Font = Enum.Font.GothamBold
	headingLabel.Text = heading
	headingLabel.TextColor3 = colors.text
	headingLabel.TextSize = 14
	headingLabel.TextXAlignment = Enum.TextXAlignment.Left
	headingLabel.Parent = card

	local descriptionLabel = Instance.new("TextLabel")
	descriptionLabel.Name = "CardDescription"
	descriptionLabel.Position = UDim2.fromOffset(17, 38)
	descriptionLabel.Size = UDim2.new(1, -34, 0, 18)
	descriptionLabel.BackgroundTransparency = 1
	descriptionLabel.Font = Enum.Font.Gotham
	descriptionLabel.Text = description
	descriptionLabel.TextColor3 = colors.muted
	descriptionLabel.TextSize = 10
	descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
	descriptionLabel.Parent = card
	return headingLabel, descriptionLabel
end

local function addInput(card, name, position, defaultText, suffix)
	local box = Instance.new("TextBox")
	box.Name = name
	box.Position = position
	box.Size = UDim2.new(1, -34, 0, 38)
	box.BackgroundColor3 = colors.input
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.GothamMedium
	box.Text = defaultText
	box.TextSize = 13
	box.TextColor3 = colors.text
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = card
	addCorner(box, 9)

	local boxGradient = Instance.new("UIGradient")
	-- A colored UIGradient on a TextBox also tints its text. Keep it neutral so
	-- entered values retain their high-contrast TextColor3 on every theme.
	boxGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	boxGradient.Rotation = 90
	boxGradient.Parent = box

	local boxPadding = Instance.new("UIPadding")
	boxPadding.PaddingLeft = UDim.new(0, 18)
	boxPadding.PaddingRight = UDim.new(0, 48)
	boxPadding.Parent = box

	local unit = Instance.new("TextLabel")
	unit.Position = UDim2.new(1, -54, 0, 0)
	unit.Size = UDim2.fromOffset(42, 38)
	unit.BackgroundTransparency = 1
	unit.Font = Enum.Font.Gotham
	unit.Text = suffix
	unit.TextColor3 = Color3.fromRGB(157, 172, 198)
	unit.TextSize = 11
	unit.TextXAlignment = Enum.TextXAlignment.Right
	unit.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = colors.accent
	stroke.Transparency = 0.72
	stroke.Thickness = 1
	stroke.Parent = box
	box.Focused:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.08, Thickness = 1.4}):Play()
	end)
	box.FocusLost:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.72, Thickness = 1}):Play()
	end)
	return box
end

themeSystem.panic = {}
themeSystem.panic.card = addCard("PanicCard", 86, 0)
addCardTitle(themeSystem.panic.card, "Panic", "Turn every cheat off and restore default character values.")
themeSystem.panic.button = Instance.new("TextButton")
themeSystem.panic.button.Name = "PanicButton"
themeSystem.panic.button.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.panic.button.Position = UDim2.new(1, -17, 0, 49)
themeSystem.panic.button.Size = UDim2.fromOffset(72, 28)
themeSystem.panic.button.BackgroundColor3 = colors.danger
themeSystem.panic.button.BorderSizePixel = 0
themeSystem.panic.button.AutoButtonColor = false
themeSystem.panic.button.Font = Enum.Font.GothamBold
themeSystem.panic.button.Text = "PANIC"
themeSystem.panic.button.TextColor3 = colors.text
themeSystem.panic.button.TextSize = 10
themeSystem.panic.button.Parent = themeSystem.panic.card
addCorner(themeSystem.panic.button, 7)

local speedCard = addCard("MovementCard", 118, 1)
addCardTitle(speedCard, "Movement speed", "How quickly your character walks.")
local speedBox = addInput(speedCard, "SpeedBox", UDim2.fromOffset(17, 68), tostring(gameDefaults.walkSpeed), "STUDS")

local jumpCard = addCard("JumpCard", 118, 2)
addCardTitle(jumpCard, "Jump strength", "Uses this game's preferred jump height or jump power mode.")
local jumpBox = addInput(
	jumpCard,
	"JumpBox",
	UDim2.fromOffset(17, 68),
	tostring(gameDefaults.useJumpPower and gameDefaults.jumpPower or gameDefaults.jumpHeight),
	gameDefaults.useJumpPower and "POWER" or "HEIGHT"
)

local gravityCard = addCard("GravityCard", 142, 3)
addCardTitle(gravityCard, "Gravity", "Adjust the world's gravity from -100 to 1000.")

local gravityValue = gameDefaults.gravity
local gravityTrack = Instance.new("Frame")
gravityTrack.Name = "GravityTrack"
gravityTrack.Position = UDim2.fromOffset(17, 82)
gravityTrack.Size = UDim2.new(1, -34, 0, 6)
gravityTrack.BackgroundColor3 = colors.switchOff
gravityTrack.BorderSizePixel = 0
gravityTrack.Parent = gravityCard
addCorner(gravityTrack, 3)

local gravityFill = Instance.new("Frame")
gravityFill.Name = "GravityFill"
gravityFill.Size = UDim2.new((gravityValue + 100) / 1100, 0, 1, 0)
gravityFill.BackgroundColor3 = colors.accent
gravityFill.BorderSizePixel = 0
gravityFill.Parent = gravityTrack
addCorner(gravityFill, 3)

local gravityKnob = Instance.new("TextButton")
gravityKnob.Name = "GravityKnob"
gravityKnob.AnchorPoint = Vector2.new(0.5, 0.5)
gravityKnob.Position = UDim2.new((gravityValue + 100) / 1100, 0, 0.5, 0)
gravityKnob.Size = UDim2.fromOffset(18, 18)
gravityKnob.BackgroundColor3 = colors.text
gravityKnob.BorderSizePixel = 0
gravityKnob.AutoButtonColor = false
gravityKnob.Text = ""
gravityKnob.Parent = gravityTrack
addCorner(gravityKnob, 9)

local gravityLabel = Instance.new("TextLabel")
gravityLabel.Position = UDim2.fromOffset(17, 98)
gravityLabel.Size = UDim2.new(1, -34, 0, 22)
gravityLabel.BackgroundTransparency = 1
gravityLabel.Font = Enum.Font.GothamMedium
gravityLabel.Text = string.format("%.1f", gameDefaults.gravity)
gravityLabel.TextColor3 = colors.text
gravityLabel.TextSize = 12
gravityLabel.TextXAlignment = Enum.TextXAlignment.Center
gravityLabel.Parent = gravityCard

local utilityCard = addCard("UtilityCard", 86, 4)
addCardTitle(utilityCard, "Noclip", "Walk through walls while enabled.")

local flyCard = addCard("FlyCard", 86, 5)
addCardTitle(flyCard, "Fly", "WASD to move, E to rise, and Q to descend.")

local godCard = addCard("GodCard", 86, 6)
addCardTitle(godCard, "God mode", "Continuously restore your health to maximum.")

local vehicleFlyCard = addCard("VehicleFlyCard", 86, 7)
addCardTitle(vehicleFlyCard, "Vehicle fly", "WASD to move, E to rise, and Q to descend while seated.")

local fullBrightCard = addCard("FullBrightCard", 86, 8)
addCardTitle(fullBrightCard, "Full bright", "Keep the map clearly lit in dark areas.")

local freecamCard = addCard("FreecamCard", 86, 9)
addCardTitle(freecamCard, "Freecam", "WASD move, E/Q height, hold right mouse to look.")

local zoom = {}
zoom.card = addCard("ZoomCard", 86, 10)
addCardTitle(zoom.card, "Zoom", "Unlock third-person camera and mouse-wheel zoom.")

local teleportClick = {}
teleportClick.card = addCard("ClickTeleportCard", 86, 11)
addCardTitle(teleportClick.card, "Click Teleport", "Teleport to any place you left-click in the world.")

local gotoPlayer = {}
gotoPlayer.card = addCard("GoToCard", 118, 12)
gotoPlayer.card.ClipsDescendants = true
addCardTitle(gotoPlayer.card, "GoTo", "Choose a player and teleport beside them.")

gotoPlayer.selectButton = Instance.new("TextButton")
gotoPlayer.selectButton.Name = "PlayerSelectButton"
gotoPlayer.selectButton.Position = UDim2.fromOffset(17, 68)
gotoPlayer.selectButton.Size = UDim2.new(1, -34, 0, 38)
gotoPlayer.selectButton.BackgroundColor3 = colors.input
gotoPlayer.selectButton.BorderSizePixel = 0
gotoPlayer.selectButton.AutoButtonColor = false
gotoPlayer.selectButton.Font = Enum.Font.GothamMedium
gotoPlayer.selectButton.Text = "Select a player"
gotoPlayer.selectButton.TextColor3 = colors.text
gotoPlayer.selectButton.TextSize = 12
gotoPlayer.selectButton.TextXAlignment = Enum.TextXAlignment.Left
gotoPlayer.selectButton.TextTruncate = Enum.TextTruncate.AtEnd
gotoPlayer.selectButton.Parent = gotoPlayer.card
addCorner(gotoPlayer.selectButton, 7)

gotoPlayer.selectPadding = Instance.new("UIPadding")
gotoPlayer.selectPadding.PaddingLeft = UDim.new(0, 12)
gotoPlayer.selectPadding.PaddingRight = UDim.new(0, 36)
gotoPlayer.selectPadding.Parent = gotoPlayer.selectButton

gotoPlayer.arrow = Instance.new("TextLabel")
gotoPlayer.arrow.Name = "Arrow"
gotoPlayer.arrow.AnchorPoint = Vector2.new(1, 0.5)
gotoPlayer.arrow.Position = UDim2.new(1, -12, 0.5, 0)
gotoPlayer.arrow.Size = UDim2.fromOffset(18, 20)
gotoPlayer.arrow.BackgroundTransparency = 1
gotoPlayer.arrow.Font = Enum.Font.GothamBold
gotoPlayer.arrow.Text = "v"
gotoPlayer.arrow.TextColor3 = colors.muted
gotoPlayer.arrow.TextSize = 12
gotoPlayer.arrow.Parent = gotoPlayer.selectButton

gotoPlayer.listFrame = Instance.new("ScrollingFrame")
gotoPlayer.listFrame.Name = "PlayerList"
gotoPlayer.listFrame.Position = UDim2.fromOffset(17, 112)
gotoPlayer.listFrame.Size = UDim2.new(1, -34, 0, 0)
gotoPlayer.listFrame.BackgroundColor3 = colors.input
gotoPlayer.listFrame.BorderSizePixel = 0
gotoPlayer.listFrame.ScrollBarThickness = 3
gotoPlayer.listFrame.ScrollBarImageColor3 = colors.accent
gotoPlayer.listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
gotoPlayer.listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
gotoPlayer.listFrame.Visible = false
gotoPlayer.listFrame.Parent = gotoPlayer.card
addCorner(gotoPlayer.listFrame, 7)

gotoPlayer.listPadding = Instance.new("UIPadding")
gotoPlayer.listPadding.PaddingTop = UDim.new(0, 5)
gotoPlayer.listPadding.PaddingBottom = UDim.new(0, 5)
gotoPlayer.listPadding.PaddingLeft = UDim.new(0, 5)
gotoPlayer.listPadding.PaddingRight = UDim.new(0, 5)
gotoPlayer.listPadding.Parent = gotoPlayer.listFrame

gotoPlayer.listLayout = Instance.new("UIListLayout")
gotoPlayer.listLayout.Padding = UDim.new(0, 5)
gotoPlayer.listLayout.SortOrder = Enum.SortOrder.LayoutOrder
gotoPlayer.listLayout.Parent = gotoPlayer.listFrame

local spectate = {}
spectate.card = addCard("SpectateCard", 118, 13)
spectate.card.ClipsDescendants = true
addCardTitle(spectate.card, "Spectate", "Choose a player and watch through their character camera.")

spectate.selectButton = Instance.new("TextButton")
spectate.selectButton.Name = "SpectatePlayerSelectButton"
spectate.selectButton.Position = UDim2.fromOffset(17, 68)
spectate.selectButton.Size = UDim2.new(1, -34, 0, 38)
spectate.selectButton.BackgroundColor3 = colors.input
spectate.selectButton.BorderSizePixel = 0
spectate.selectButton.AutoButtonColor = false
spectate.selectButton.Font = Enum.Font.GothamMedium
spectate.selectButton.Text = "Select a player"
spectate.selectButton.TextColor3 = colors.text
spectate.selectButton.TextSize = 12
spectate.selectButton.TextXAlignment = Enum.TextXAlignment.Left
spectate.selectButton.TextTruncate = Enum.TextTruncate.AtEnd
spectate.selectButton.Parent = spectate.card
addCorner(spectate.selectButton, 7)

spectate.selectPadding = Instance.new("UIPadding")
spectate.selectPadding.PaddingLeft = UDim.new(0, 12)
spectate.selectPadding.PaddingRight = UDim.new(0, 36)
spectate.selectPadding.Parent = spectate.selectButton

spectate.arrow = Instance.new("TextLabel")
spectate.arrow.Name = "Arrow"
spectate.arrow.AnchorPoint = Vector2.new(1, 0.5)
spectate.arrow.Position = UDim2.new(1, -12, 0.5, 0)
spectate.arrow.Size = UDim2.fromOffset(18, 20)
spectate.arrow.BackgroundTransparency = 1
spectate.arrow.Font = Enum.Font.GothamBold
spectate.arrow.Text = "v"
spectate.arrow.TextColor3 = colors.muted
spectate.arrow.TextSize = 12
spectate.arrow.Parent = spectate.selectButton

spectate.listFrame = Instance.new("ScrollingFrame")
spectate.listFrame.Name = "SpectatePlayerList"
spectate.listFrame.Position = UDim2.fromOffset(17, 112)
spectate.listFrame.Size = UDim2.new(1, -34, 0, 0)
spectate.listFrame.BackgroundColor3 = colors.input
spectate.listFrame.BorderSizePixel = 0
spectate.listFrame.ScrollBarThickness = 3
spectate.listFrame.ScrollBarImageColor3 = colors.accent
spectate.listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
spectate.listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
spectate.listFrame.Visible = false
spectate.listFrame.Parent = spectate.card
addCorner(spectate.listFrame, 7)

spectate.listPadding = Instance.new("UIPadding")
spectate.listPadding.PaddingTop = UDim.new(0, 5)
spectate.listPadding.PaddingBottom = UDim.new(0, 5)
spectate.listPadding.PaddingLeft = UDim.new(0, 5)
spectate.listPadding.PaddingRight = UDim.new(0, 5)
spectate.listPadding.Parent = spectate.listFrame

spectate.listLayout = Instance.new("UIListLayout")
spectate.listLayout.Padding = UDim.new(0, 5)
spectate.listLayout.SortOrder = Enum.SortOrder.LayoutOrder
spectate.listLayout.Parent = spectate.listFrame

spectate.exitButton = Instance.new("TextButton")
spectate.exitButton.Name = "ExitSpectateButton"
spectate.exitButton.AnchorPoint = Vector2.new(1, 0)
spectate.exitButton.Position = UDim2.new(1, -24, 0, 24)
spectate.exitButton.Size = UDim2.fromOffset(38, 38)
spectate.exitButton.BackgroundColor3 = colors.danger
spectate.exitButton.BorderSizePixel = 0
spectate.exitButton.AutoButtonColor = false
spectate.exitButton.Font = Enum.Font.GothamBold
spectate.exitButton.Text = "X"
spectate.exitButton.TextColor3 = colors.text
spectate.exitButton.TextSize = 15
spectate.exitButton.Visible = false
spectate.exitButton.ZIndex = 100
spectate.exitButton.Parent = screenGui
addCorner(spectate.exitButton, 10)

local leave = {}
leave.card = addCard("LeaveCard", 86, 14)
addCardTitle(leave.card, "Leave", "Disconnect your player from the current game.")

leave.button = Instance.new("TextButton")
leave.button.Name = "LeaveButton"
leave.button.AnchorPoint = Vector2.new(1, 0.5)
leave.button.Position = UDim2.new(1, -17, 0, 49)
leave.button.Size = UDim2.fromOffset(68, 28)
leave.button.BackgroundColor3 = colors.danger
leave.button.BorderSizePixel = 0
leave.button.AutoButtonColor = false
leave.button.Font = Enum.Font.GothamBold
leave.button.Text = "LEAVE"
leave.button.TextColor3 = colors.text
leave.button.TextSize = 10
leave.button.Parent = leave.card
addCorner(leave.button, 7)

local rejoin = {}
rejoin.card = addCard("RejoinCard", 86, 15)
addCardTitle(rejoin.card, "Rejoin", "Reconnect to this same game server.")

rejoin.button = Instance.new("TextButton")
rejoin.button.Name = "RejoinButton"
rejoin.button.AnchorPoint = Vector2.new(1, 0.5)
rejoin.button.Position = UDim2.new(1, -17, 0, 49)
rejoin.button.Size = UDim2.fromOffset(76, 28)
rejoin.button.BackgroundColor3 = colors.accent
rejoin.button.BorderSizePixel = 0
rejoin.button.AutoButtonColor = false
rejoin.button.Font = Enum.Font.GothamBold
rejoin.button.Text = "REJOIN"
rejoin.button.TextColor3 = colors.text
rejoin.button.TextSize = 10
rejoin.button.Parent = rejoin.card
addCorner(rejoin.button, 7)

local serverHop = {}
serverHop.card = addCard("ServerHopCard", 86, 16)
addCardTitle(serverHop.card, "Server Hop", "Join a different public server for this game.")

serverHop.button = Instance.new("TextButton")
serverHop.button.Name = "ServerHopButton"
serverHop.button.AnchorPoint = Vector2.new(1, 0.5)
serverHop.button.Position = UDim2.new(1, -17, 0, 49)
serverHop.button.Size = UDim2.fromOffset(76, 28)
serverHop.button.BackgroundColor3 = colors.accent
serverHop.button.BorderSizePixel = 0
serverHop.button.AutoButtonColor = false
serverHop.button.Font = Enum.Font.GothamBold
serverHop.button.Text = "HOP"
serverHop.button.TextColor3 = colors.text
serverHop.button.TextSize = 10
serverHop.button.Parent = serverHop.card
addCorner(serverHop.button, 7)

local freeze = {}
freeze.card = addCard("FreezeCard", 86, 17)
addCardTitle(freeze.card, "Freeze", "Lock your character in its current position.")

local spin = {}
spin.card = addCard("SpinCard", 118, 18)
addCardTitle(spin.card, "Spin", "0 stops; hold right mouse to orbit and scroll to zoom.")
spin.box = addInput(spin.card, "SpinBox", UDim2.fromOffset(17, 68), "0", "SPEED")
spin.value = 0
spin.card.ClipsDescendants = true

spin.dropdownButton = Instance.new("TextButton")
spin.dropdownButton.Name = "AntiflingDropdownButton"
spin.dropdownButton.AnchorPoint = Vector2.new(1, 0)
spin.dropdownButton.Position = UDim2.new(1, -17, 0, 14)
spin.dropdownButton.Size = UDim2.fromOffset(28, 24)
spin.dropdownButton.BackgroundColor3 = colors.input
spin.dropdownButton.BorderSizePixel = 0
spin.dropdownButton.AutoButtonColor = false
spin.dropdownButton.Font = Enum.Font.GothamBold
spin.dropdownButton.Text = "v"
spin.dropdownButton.TextColor3 = colors.muted
spin.dropdownButton.TextSize = 12
spin.dropdownButton.Parent = spin.card
addCorner(spin.dropdownButton, 7)

spin.antiflingRow = Instance.new("Frame")
spin.antiflingRow.Name = "AntiflingRow"
spin.antiflingRow.Position = UDim2.fromOffset(17, 128)
spin.antiflingRow.Size = UDim2.new(1, -34, 0, 60)
spin.antiflingRow.BackgroundColor3 = colors.input
spin.antiflingRow.BorderSizePixel = 0
spin.antiflingRow.Visible = false
spin.antiflingRow.Parent = spin.card
addCorner(spin.antiflingRow, 8)

spin.antiflingTitle = Instance.new("TextLabel")
spin.antiflingTitle.Position = UDim2.fromOffset(12, 8)
spin.antiflingTitle.Size = UDim2.new(1, -76, 0, 18)
spin.antiflingTitle.BackgroundTransparency = 1
spin.antiflingTitle.Font = Enum.Font.GothamMedium
spin.antiflingTitle.Text = "Antifling"
spin.antiflingTitle.TextColor3 = colors.faint
spin.antiflingTitle.TextSize = 11
spin.antiflingTitle.TextXAlignment = Enum.TextXAlignment.Left
spin.antiflingTitle.Parent = spin.antiflingRow

spin.antiflingDescription = Instance.new("TextLabel")
spin.antiflingDescription.Position = UDim2.fromOffset(12, 29)
spin.antiflingDescription.Size = UDim2.new(1, -76, 0, 18)
spin.antiflingDescription.BackgroundTransparency = 1
spin.antiflingDescription.Font = Enum.Font.Gotham
spin.antiflingDescription.Text = "Limit sudden launch velocity."
spin.antiflingDescription.TextColor3 = colors.faint
spin.antiflingDescription.TextSize = 9
spin.antiflingDescription.TextXAlignment = Enum.TextXAlignment.Left
spin.antiflingDescription.Parent = spin.antiflingRow

spin.antiflingToggle = Instance.new("TextButton")
spin.antiflingToggle.Name = "AntiflingToggle"
spin.antiflingToggle.AnchorPoint = Vector2.new(1, 0.5)
spin.antiflingToggle.Position = UDim2.new(1, -10, 0, 28)
spin.antiflingToggle.Size = UDim2.fromOffset(44, 24)
spin.antiflingToggle.BackgroundColor3 = colors.input
spin.antiflingToggle.BorderSizePixel = 0
spin.antiflingToggle.AutoButtonColor = false
spin.antiflingToggle.Text = ""
spin.antiflingToggle.Active = false
spin.antiflingToggle.Parent = spin.antiflingRow
addCorner(spin.antiflingToggle, 12)

spin.antiflingKnob = Instance.new("Frame")
spin.antiflingKnob.Name = "Knob"
spin.antiflingKnob.AnchorPoint = Vector2.new(0, 0.5)
spin.antiflingKnob.Position = UDim2.new(0, 3, 0.5, 0)
spin.antiflingKnob.Size = UDim2.fromOffset(18, 18)
spin.antiflingKnob.BackgroundColor3 = colors.faint
spin.antiflingKnob.BorderSizePixel = 0
spin.antiflingKnob.Parent = spin.antiflingToggle
addCorner(spin.antiflingKnob, 9)

spin.antiflingStatus = Instance.new("TextLabel")
spin.antiflingStatus.AnchorPoint = Vector2.new(1, 0)
spin.antiflingStatus.Position = UDim2.new(1, -12, 0, 45)
spin.antiflingStatus.Size = UDim2.fromOffset(56, 12)
spin.antiflingStatus.BackgroundTransparency = 1
spin.antiflingStatus.Font = Enum.Font.Gotham
spin.antiflingStatus.Text = "LOCKED"
spin.antiflingStatus.TextColor3 = colors.faint
spin.antiflingStatus.TextSize = 8
spin.antiflingStatus.TextXAlignment = Enum.TextXAlignment.Right
spin.antiflingStatus.Parent = spin.antiflingRow

local floatCard = addCard("FloatCard", 86, 19)
addCardTitle(floatCard, "Float", "Float in place; press E to rise and Q to descend.")

local infiniteJumpCard = addCard("InfiniteJumpCard", 86, 20)
addCardTitle(infiniteJumpCard, "Infinite jump", "Jump again as many times as you want while airborne.")

local espCard = addCard("ESPCard", 86, 21)
addCardTitle(espCard, "Player ESP", "Highlight every other player through walls.")
espCard.ClipsDescendants = true

themeSystem.aimbot = {
	enabled = false,
	maxWorldDistance = 150,
	maxScreenDistance = 240,
	smoothness = 18,
	defaultSmoothness = 18,
	smoothingSpeed = 8,
	dropdownOpen = false,
	radiusDropdownOpen = false,
	fovCircleEnabled = false,
	fovRadius = 240,
	defaultFovRadius = 240,
}
themeSystem.aimbot.card = addCard("AimbotCard", 142, 22)
addCardTitle(themeSystem.aimbot.card, "Aimbot", "Aim nearby opponents; higher smoothness tracks more softly.")
themeSystem.aimbot.card.ClipsDescendants = true
themeSystem.aimbot.valueLabel = Instance.new("TextLabel")
themeSystem.aimbot.valueLabel.Name = "SmoothnessValue"
themeSystem.aimbot.valueLabel.Position = UDim2.fromOffset(17, 82)
themeSystem.aimbot.valueLabel.Size = UDim2.new(1, -34, 0, 16)
themeSystem.aimbot.valueLabel.BackgroundTransparency = 1
themeSystem.aimbot.valueLabel.Font = Enum.Font.GothamMedium
themeSystem.aimbot.valueLabel.Text = "SMOOTHNESS 18"
themeSystem.aimbot.valueLabel.TextColor3 = colors.text
themeSystem.aimbot.valueLabel.TextSize = 10
themeSystem.aimbot.valueLabel.TextXAlignment = Enum.TextXAlignment.Center
themeSystem.aimbot.valueLabel.Parent = themeSystem.aimbot.card
themeSystem.aimbot.track = Instance.new("Frame")
themeSystem.aimbot.track.Name = "SmoothnessTrack"
themeSystem.aimbot.track.Position = UDim2.fromOffset(17, 112)
themeSystem.aimbot.track.Size = UDim2.new(1, -34, 0, 6)
themeSystem.aimbot.track.BackgroundColor3 = colors.switchOff
themeSystem.aimbot.track.BorderSizePixel = 0
themeSystem.aimbot.track.Active = true
themeSystem.aimbot.track.Parent = themeSystem.aimbot.card
addCorner(themeSystem.aimbot.track, 3)
themeSystem.aimbot.fill = Instance.new("Frame")
themeSystem.aimbot.fill.Name = "SmoothnessFill"
themeSystem.aimbot.fill.Size = UDim2.new(17 / 24, 0, 1, 0)
themeSystem.aimbot.fill.BackgroundColor3 = colors.accent
themeSystem.aimbot.fill.BorderSizePixel = 0
themeSystem.aimbot.fill.Parent = themeSystem.aimbot.track
addCorner(themeSystem.aimbot.fill, 3)
themeSystem.aimbot.knob = Instance.new("TextButton")
themeSystem.aimbot.knob.Name = "SmoothnessKnob"
themeSystem.aimbot.knob.AnchorPoint = Vector2.new(0.5, 0.5)
themeSystem.aimbot.knob.Position = UDim2.new(17 / 24, 0, 0.5, 0)
themeSystem.aimbot.knob.Size = UDim2.fromOffset(18, 18)
themeSystem.aimbot.knob.BackgroundColor3 = colors.text
themeSystem.aimbot.knob.BorderSizePixel = 0
themeSystem.aimbot.knob.AutoButtonColor = false
themeSystem.aimbot.knob.Text = ""
themeSystem.aimbot.knob.Parent = themeSystem.aimbot.track
addCorner(themeSystem.aimbot.knob, 9)

themeSystem.aimbot.dropdownButton = Instance.new("TextButton")
themeSystem.aimbot.dropdownButton.Name = "DropdownButton"
themeSystem.aimbot.dropdownButton.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.aimbot.dropdownButton.Position = UDim2.new(1, -70, 0, 49)
themeSystem.aimbot.dropdownButton.Size = UDim2.fromOffset(28, 24)
themeSystem.aimbot.dropdownButton.BackgroundColor3 = colors.input
themeSystem.aimbot.dropdownButton.BorderSizePixel = 0
themeSystem.aimbot.dropdownButton.AutoButtonColor = false
themeSystem.aimbot.dropdownButton.Font = Enum.Font.GothamBold
themeSystem.aimbot.dropdownButton.Text = "v"
themeSystem.aimbot.dropdownButton.TextColor3 = colors.muted
themeSystem.aimbot.dropdownButton.TextSize = 12
themeSystem.aimbot.dropdownButton.Parent = themeSystem.aimbot.card
addCorner(themeSystem.aimbot.dropdownButton, 7)

themeSystem.aimbot.fovRow = Instance.new("Frame")
themeSystem.aimbot.fovRow.Name = "FOVCircleRow"
themeSystem.aimbot.fovRow.Position = UDim2.fromOffset(17, 142)
themeSystem.aimbot.fovRow.Size = UDim2.new(1, -34, 0, 60)
themeSystem.aimbot.fovRow.BackgroundColor3 = colors.input
themeSystem.aimbot.fovRow.BorderSizePixel = 0
themeSystem.aimbot.fovRow.Visible = false
themeSystem.aimbot.fovRow.Parent = themeSystem.aimbot.card
addCorner(themeSystem.aimbot.fovRow, 8)

themeSystem.aimbot.fovTitle = Instance.new("TextLabel")
themeSystem.aimbot.fovTitle.Position = UDim2.fromOffset(12, 8)
themeSystem.aimbot.fovTitle.Size = UDim2.new(1, -132, 0, 18)
themeSystem.aimbot.fovTitle.BackgroundTransparency = 1
themeSystem.aimbot.fovTitle.Font = Enum.Font.GothamMedium
themeSystem.aimbot.fovTitle.Text = "Aimbot Radius"
themeSystem.aimbot.fovTitle.TextColor3 = colors.text
themeSystem.aimbot.fovTitle.TextSize = 11
themeSystem.aimbot.fovTitle.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.aimbot.fovTitle.Parent = themeSystem.aimbot.fovRow

themeSystem.aimbot.fovDescription = Instance.new("TextLabel")
themeSystem.aimbot.fovDescription.Position = UDim2.fromOffset(12, 29)
themeSystem.aimbot.fovDescription.Size = UDim2.new(1, -132, 0, 18)
themeSystem.aimbot.fovDescription.BackgroundTransparency = 1
themeSystem.aimbot.fovDescription.Font = Enum.Font.Gotham
themeSystem.aimbot.fovDescription.Text = "Show a visual radius around your mouse."
themeSystem.aimbot.fovDescription.TextColor3 = colors.muted
themeSystem.aimbot.fovDescription.TextSize = 9
themeSystem.aimbot.fovDescription.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.aimbot.fovDescription.Parent = themeSystem.aimbot.fovRow

themeSystem.aimbot.radiusDropdownButton = Instance.new("TextButton")
themeSystem.aimbot.radiusDropdownButton.Name = "RadiusDropdownButton"
themeSystem.aimbot.radiusDropdownButton.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.aimbot.radiusDropdownButton.Position = UDim2.new(1, -120, 0, 28)
themeSystem.aimbot.radiusDropdownButton.Size = UDim2.fromOffset(28, 24)
themeSystem.aimbot.radiusDropdownButton.BackgroundColor3 = colors.card
themeSystem.aimbot.radiusDropdownButton.BorderSizePixel = 0
themeSystem.aimbot.radiusDropdownButton.AutoButtonColor = false
themeSystem.aimbot.radiusDropdownButton.Font = Enum.Font.GothamBold
themeSystem.aimbot.radiusDropdownButton.Text = "v"
themeSystem.aimbot.radiusDropdownButton.TextColor3 = colors.muted
themeSystem.aimbot.radiusDropdownButton.TextSize = 12
themeSystem.aimbot.radiusDropdownButton.Parent = themeSystem.aimbot.fovRow
addCorner(themeSystem.aimbot.radiusDropdownButton, 7)

themeSystem.aimbot.fovToggle = Instance.new("TextButton")
themeSystem.aimbot.fovToggle.Name = "FOVCircleToggle"
themeSystem.aimbot.fovToggle.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.aimbot.fovToggle.Position = UDim2.new(1, -10, 0, 28)
themeSystem.aimbot.fovToggle.Size = UDim2.fromOffset(44, 24)
themeSystem.aimbot.fovToggle.BackgroundColor3 = colors.switchOff
themeSystem.aimbot.fovToggle.BorderSizePixel = 0
themeSystem.aimbot.fovToggle.AutoButtonColor = false
themeSystem.aimbot.fovToggle.Text = ""
themeSystem.aimbot.fovToggle.Parent = themeSystem.aimbot.fovRow
addCorner(themeSystem.aimbot.fovToggle, 12)

themeSystem.aimbot.fovKnob = Instance.new("Frame")
themeSystem.aimbot.fovKnob.Name = "Knob"
themeSystem.aimbot.fovKnob.AnchorPoint = Vector2.new(0, 0.5)
themeSystem.aimbot.fovKnob.Position = UDim2.new(0, 3, 0.5, 0)
themeSystem.aimbot.fovKnob.Size = UDim2.fromOffset(18, 18)
themeSystem.aimbot.fovKnob.BackgroundColor3 = Color3.fromRGB(231, 238, 250)
themeSystem.aimbot.fovKnob.BorderSizePixel = 0
themeSystem.aimbot.fovKnob.Parent = themeSystem.aimbot.fovToggle
addCorner(themeSystem.aimbot.fovKnob, 9)

themeSystem.aimbot.fovStatus = Instance.new("TextLabel")
themeSystem.aimbot.fovStatus.AnchorPoint = Vector2.new(1, 0)
themeSystem.aimbot.fovStatus.Position = UDim2.new(1, -12, 0, 45)
themeSystem.aimbot.fovStatus.Size = UDim2.fromOffset(56, 12)
themeSystem.aimbot.fovStatus.BackgroundTransparency = 1
themeSystem.aimbot.fovStatus.Font = Enum.Font.Gotham
themeSystem.aimbot.fovStatus.Text = "OFF"
themeSystem.aimbot.fovStatus.TextColor3 = colors.faint
themeSystem.aimbot.fovStatus.TextSize = 8
themeSystem.aimbot.fovStatus.TextXAlignment = Enum.TextXAlignment.Right
themeSystem.aimbot.fovStatus.Parent = themeSystem.aimbot.fovRow

themeSystem.aimbot.fovValueLabel = Instance.new("TextLabel")
themeSystem.aimbot.fovValueLabel.Position = UDim2.fromOffset(12, 58)
themeSystem.aimbot.fovValueLabel.Size = UDim2.new(1, -24, 0, 16)
themeSystem.aimbot.fovValueLabel.BackgroundTransparency = 1
themeSystem.aimbot.fovValueLabel.Font = Enum.Font.GothamMedium
themeSystem.aimbot.fovValueLabel.Text = "RADIUS 240 PX"
themeSystem.aimbot.fovValueLabel.TextColor3 = colors.text
themeSystem.aimbot.fovValueLabel.TextSize = 9
themeSystem.aimbot.fovValueLabel.TextXAlignment = Enum.TextXAlignment.Center
themeSystem.aimbot.fovValueLabel.Parent = themeSystem.aimbot.fovRow
themeSystem.aimbot.fovValueLabel.Visible = false

themeSystem.aimbot.fovTrack = Instance.new("Frame")
themeSystem.aimbot.fovTrack.Name = "FOVRadiusTrack"
themeSystem.aimbot.fovTrack.Position = UDim2.fromOffset(12, 86)
themeSystem.aimbot.fovTrack.Size = UDim2.new(1, -24, 0, 6)
themeSystem.aimbot.fovTrack.BackgroundColor3 = colors.switchOff
themeSystem.aimbot.fovTrack.BorderSizePixel = 0
themeSystem.aimbot.fovTrack.Active = true
themeSystem.aimbot.fovTrack.Parent = themeSystem.aimbot.fovRow
themeSystem.aimbot.fovTrack.Visible = false
addCorner(themeSystem.aimbot.fovTrack, 3)

themeSystem.aimbot.fovFill = Instance.new("Frame")
themeSystem.aimbot.fovFill.Name = "FOVRadiusFill"
themeSystem.aimbot.fovFill.Size = UDim2.new(190 / 450, 0, 1, 0)
themeSystem.aimbot.fovFill.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
themeSystem.aimbot.fovFill.BorderSizePixel = 0
themeSystem.aimbot.fovFill.Parent = themeSystem.aimbot.fovTrack
addCorner(themeSystem.aimbot.fovFill, 3)

themeSystem.aimbot.fovSliderKnob = Instance.new("TextButton")
themeSystem.aimbot.fovSliderKnob.Name = "FOVRadiusKnob"
themeSystem.aimbot.fovSliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
themeSystem.aimbot.fovSliderKnob.Position = UDim2.new(190 / 450, 0, 0.5, 0)
themeSystem.aimbot.fovSliderKnob.Size = UDim2.fromOffset(18, 18)
themeSystem.aimbot.fovSliderKnob.BackgroundColor3 = colors.text
themeSystem.aimbot.fovSliderKnob.BorderSizePixel = 0
themeSystem.aimbot.fovSliderKnob.AutoButtonColor = false
themeSystem.aimbot.fovSliderKnob.Text = ""
themeSystem.aimbot.fovSliderKnob.Parent = themeSystem.aimbot.fovTrack
addCorner(themeSystem.aimbot.fovSliderKnob, 9)

themeSystem.aimbot.circleGui = Instance.new("ScreenGui")
themeSystem.aimbot.circleGui.Name = "WaveAimbotCircle"
themeSystem.aimbot.circleGui.ResetOnSpawn = false
themeSystem.aimbot.circleGui.IgnoreGuiInset = true
themeSystem.aimbot.circleGui.DisplayOrder = 19
themeSystem.aimbot.circleGui.Parent = playerGui
themeSystem.aimbot.circle = Instance.new("Frame")
themeSystem.aimbot.circle.Name = "FOVCircle"
themeSystem.aimbot.circle.AnchorPoint = Vector2.new(0.5, 0.5)
themeSystem.aimbot.circle.Size = UDim2.fromOffset(480, 480)
themeSystem.aimbot.circle.BackgroundTransparency = 1
themeSystem.aimbot.circle.BorderSizePixel = 0
themeSystem.aimbot.circle.Visible = false
themeSystem.aimbot.circle.Parent = themeSystem.aimbot.circleGui
addCorner(themeSystem.aimbot.circle, 1000)
themeSystem.aimbot.circleStroke = Instance.new("UIStroke")
themeSystem.aimbot.circleStroke.Name = "CircleOutline"
themeSystem.aimbot.circleStroke.Color = Color3.fromRGB(255, 65, 65)
themeSystem.aimbot.circleStroke.Thickness = 2
themeSystem.aimbot.circleStroke.Transparency = 0
themeSystem.aimbot.circleStroke.Parent = themeSystem.aimbot.circle

themeSystem.triggerBot = {enabled = false, lastClick = 0}
themeSystem.triggerBot.card = addCard("TriggerBotCard", 86, 23)
addCardTitle(themeSystem.triggerBot.card, "Trigger Bot", "Click automatically when your cursor is over another player.")

local fieldOfView = {enabled = false, value = gameDefaults.fieldOfView}
fieldOfView.card = addCard("FieldOfViewCard", 142, 24)
addCardTitle(fieldOfView.card, "Field of view", "Increase or decrease how much the camera can see.")
fieldOfView.valueLabel = Instance.new("TextLabel")
fieldOfView.valueLabel.Position = UDim2.fromOffset(17, 82)
fieldOfView.valueLabel.Size = UDim2.new(1, -34, 0, 16)
fieldOfView.valueLabel.BackgroundTransparency = 1
fieldOfView.valueLabel.Font = Enum.Font.GothamMedium
fieldOfView.valueLabel.Text = string.format("%d°", math.floor(fieldOfView.value + 0.5))
fieldOfView.valueLabel.TextColor3 = colors.text
fieldOfView.valueLabel.TextSize = 10
fieldOfView.valueLabel.TextXAlignment = Enum.TextXAlignment.Center
fieldOfView.valueLabel.Parent = fieldOfView.card
fieldOfView.track = Instance.new("Frame")
fieldOfView.track.Name = "FieldOfViewTrack"
fieldOfView.track.Position = UDim2.fromOffset(17, 112)
fieldOfView.track.Size = UDim2.new(1, -34, 0, 6)
fieldOfView.track.BackgroundColor3 = colors.switchOff
fieldOfView.track.BorderSizePixel = 0
fieldOfView.track.Active = true
fieldOfView.track.Parent = fieldOfView.card
addCorner(fieldOfView.track, 3)
fieldOfView.fill = Instance.new("Frame")
fieldOfView.fill.Name = "FieldOfViewFill"
fieldOfView.fill.Size = UDim2.new(math.clamp((fieldOfView.value - 30) / 90, 0, 1), 0, 1, 0)
fieldOfView.fill.BackgroundColor3 = colors.accent
fieldOfView.fill.BorderSizePixel = 0
fieldOfView.fill.Parent = fieldOfView.track
addCorner(fieldOfView.fill, 3)
fieldOfView.knob = Instance.new("TextButton")
fieldOfView.knob.Name = "FieldOfViewKnob"
fieldOfView.knob.AnchorPoint = Vector2.new(0.5, 0.5)
fieldOfView.knob.Position = UDim2.new(math.clamp((fieldOfView.value - 30) / 90, 0, 1), 0, 0.5, 0)
fieldOfView.knob.Size = UDim2.fromOffset(18, 18)
fieldOfView.knob.BackgroundColor3 = colors.text
fieldOfView.knob.BorderSizePixel = 0
fieldOfView.knob.AutoButtonColor = false
fieldOfView.knob.Text = ""
fieldOfView.knob.Parent = fieldOfView.track
addCorner(fieldOfView.knob, 9)

local invisibility = {enabled = false}
invisibility.card = addCard("InvisibilityCard", 86, 25)
addCardTitle(invisibility.card, "Invisibility", "Experimental character desync similar to Infinite Yield.")

local walkfling = {enabled = false, generation = 0}
walkfling.card = addCard("WalkflingCard", 86, 26)
addCardTitle(walkfling.card, "Walkfling", "Use extreme velocity pulses to fling players you touch.")

themeSystem.healthDisplay = {enabled = false, guis = {}, characterConnections = {}}
themeSystem.healthDisplay.card = addCard("HealthDisplayCard", 86, 27)
addCardTitle(themeSystem.healthDisplay.card, "Health Display", "Show each player's current health above their character.")

themeSystem.waveTags = {enabled = false, guis = {}, playerConnections = {}}
themeSystem.waveTags.card = addCard("WaveTagsCard", 86, 28)
addCardTitle(themeSystem.waveTags.card, "WAVE Tags", "Identify WAVE users and the WAVE owner above their characters.")

themeSystem.instantPrompts = {enabled = false, prompts = setmetatable({}, {__mode = "k"})}
themeSystem.instantPrompts.card = addCard("InstantPromptsCard", 86, 29)
addCardTitle(themeSystem.instantPrompts.card, "Instant Prompts", "Remove the hold time from ProximityPrompt interactions.")

themeSystem.coordinates = {enabled = false}
themeSystem.coordinates.card = addCard("ShowCoordinatesCard", 86, 30)
addCardTitle(themeSystem.coordinates.card, "Show Coordinates", "Display your character's live X, Y, and Z position.")

themeSystem.autoSell = {enabled = false, interval = 8, generation = 0}
themeSystem.autoSell.card = addCard("AutoSellCard", 152, 31)
addCardTitle(themeSystem.autoSell.card, "Make Your Own Auto Sell", "Record a sell location, then visit it automatically every 8 seconds.")
themeSystem.autoSell.locationRow = Instance.new("TextButton")
themeSystem.autoSell.locationRow.Name = "SetSellLocationRow"
themeSystem.autoSell.locationRow.Position = UDim2.fromOffset(17, 88)
themeSystem.autoSell.locationRow.Size = UDim2.new(1, -34, 0, 50)
themeSystem.autoSell.locationRow.BackgroundColor3 = colors.input
themeSystem.autoSell.locationRow.BorderSizePixel = 0
themeSystem.autoSell.locationRow.AutoButtonColor = false
themeSystem.autoSell.locationRow.Text = ""
themeSystem.autoSell.locationRow.Parent = themeSystem.autoSell.card
addCorner(themeSystem.autoSell.locationRow, 8)
themeSystem.autoSell.locationTitle = Instance.new("TextLabel")
themeSystem.autoSell.locationTitle.Position = UDim2.fromOffset(12, 6)
themeSystem.autoSell.locationTitle.Size = UDim2.new(1, -84, 0, 17)
themeSystem.autoSell.locationTitle.BackgroundTransparency = 1
themeSystem.autoSell.locationTitle.Font = Enum.Font.GothamBold
themeSystem.autoSell.locationTitle.Text = "Set Current Location"
themeSystem.autoSell.locationTitle.TextColor3 = colors.text
themeSystem.autoSell.locationTitle.TextSize = 10
themeSystem.autoSell.locationTitle.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.autoSell.locationTitle.Parent = themeSystem.autoSell.locationRow
themeSystem.autoSell.locationDescription = Instance.new("TextLabel")
themeSystem.autoSell.locationDescription.Position = UDim2.fromOffset(12, 25)
themeSystem.autoSell.locationDescription.Size = UDim2.new(1, -84, 0, 16)
themeSystem.autoSell.locationDescription.BackgroundTransparency = 1
themeSystem.autoSell.locationDescription.Font = Enum.Font.Gotham
themeSystem.autoSell.locationDescription.Text = "Stand in the sell zone, then press here."
themeSystem.autoSell.locationDescription.TextColor3 = colors.muted
themeSystem.autoSell.locationDescription.TextSize = 8
themeSystem.autoSell.locationDescription.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.autoSell.locationDescription.TextTruncate = Enum.TextTruncate.AtEnd
themeSystem.autoSell.locationDescription.Parent = themeSystem.autoSell.locationRow

themeSystem.randomize = {}
themeSystem.randomize.card = addCard("RandomizeCard", 96, 32)
addCardTitle(themeSystem.randomize.card, "Randomize Everything", "Randomize cheats, values, settings, and theme without touching saved data.")
themeSystem.randomize.button = Instance.new("TextButton")
themeSystem.randomize.button.Name = "RandomizeButton"
themeSystem.randomize.button.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.randomize.button.Position = UDim2.new(1, -17, 0, 60)
themeSystem.randomize.button.Size = UDim2.fromOffset(104, 32)
themeSystem.randomize.button.BackgroundColor3 = colors.accent
themeSystem.randomize.button.BorderSizePixel = 0
themeSystem.randomize.button.AutoButtonColor = false
themeSystem.randomize.button.Font = Enum.Font.GothamBold
themeSystem.randomize.button.Text = "RANDOMIZE"
themeSystem.randomize.button.TextColor3 = colors.text
themeSystem.randomize.button.TextSize = 9
themeSystem.randomize.button.Parent = themeSystem.randomize.card
addCorner(themeSystem.randomize.button, 8)

themeSystem.playerTrails = {enabled = false, color = Color3.fromRGB(60, 220, 255), hue = 0.52, trails = {}, characterConnections = {}}
themeSystem.playerTrails.card = addCard("PlayerTrailsCard", 138, 33)
addCardTitle(themeSystem.playerTrails.card, "Player Trails", "Show colored movement trails behind other players; walls block them normally.")
themeSystem.playerTrails.colorLabel = Instance.new("TextLabel")
themeSystem.playerTrails.colorLabel.Position = UDim2.fromOffset(17, 91)
themeSystem.playerTrails.colorLabel.Size = UDim2.fromOffset(72, 18)
themeSystem.playerTrails.colorLabel.BackgroundTransparency = 1
themeSystem.playerTrails.colorLabel.Font = Enum.Font.GothamBold
themeSystem.playerTrails.colorLabel.Text = "TRAIL COLOR"
themeSystem.playerTrails.colorLabel.TextColor3 = colors.muted
themeSystem.playerTrails.colorLabel.TextSize = 8
themeSystem.playerTrails.colorLabel.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.playerTrails.colorLabel.Parent = themeSystem.playerTrails.card
themeSystem.playerTrails.colorTrack = Instance.new("Frame")
themeSystem.playerTrails.colorTrack.Name = "TrailHueTrack"
themeSystem.playerTrails.colorTrack.Position = UDim2.fromOffset(94, 95)
themeSystem.playerTrails.colorTrack.Size = UDim2.new(1, -145, 0, 10)
themeSystem.playerTrails.colorTrack.BackgroundColor3 = Color3.new(1, 1, 1)
themeSystem.playerTrails.colorTrack.BorderSizePixel = 0
themeSystem.playerTrails.colorTrack.Active = true
themeSystem.playerTrails.colorTrack.Parent = themeSystem.playerTrails.card
addCorner(themeSystem.playerTrails.colorTrack, 5)
themeSystem.playerTrails.colorGradient = Instance.new("UIGradient")
themeSystem.playerTrails.colorGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0.82, 1)),
	ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 0.82, 1)),
	ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 0.82, 1)),
	ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 0.82, 1)),
	ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 0.82, 1)),
	ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 0.82, 1)),
	ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 0.82, 1)),
})
themeSystem.playerTrails.colorGradient.Parent = themeSystem.playerTrails.colorTrack
themeSystem.playerTrails.colorKnob = Instance.new("Frame")
themeSystem.playerTrails.colorKnob.AnchorPoint = Vector2.new(0.5, 0.5)
themeSystem.playerTrails.colorKnob.Position = UDim2.new(themeSystem.playerTrails.hue, 0, 0.5, 0)
themeSystem.playerTrails.colorKnob.Size = UDim2.fromOffset(16, 16)
themeSystem.playerTrails.colorKnob.BackgroundColor3 = Color3.new(1, 1, 1)
themeSystem.playerTrails.colorKnob.BorderSizePixel = 0
themeSystem.playerTrails.colorKnob.ZIndex = 4
themeSystem.playerTrails.colorKnob.Parent = themeSystem.playerTrails.colorTrack
addCorner(themeSystem.playerTrails.colorKnob, 8)
themeSystem.playerTrails.colorKnobStroke = Instance.new("UIStroke")
themeSystem.playerTrails.colorKnobStroke.Color = colors.background
themeSystem.playerTrails.colorKnobStroke.Thickness = 2
themeSystem.playerTrails.colorKnobStroke.Parent = themeSystem.playerTrails.colorKnob
themeSystem.playerTrails.colorPreview = Instance.new("Frame")
themeSystem.playerTrails.colorPreview.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.playerTrails.colorPreview.Position = UDim2.new(1, -17, 0, 100)
themeSystem.playerTrails.colorPreview.Size = UDim2.fromOffset(24, 24)
themeSystem.playerTrails.colorPreview.BackgroundColor3 = themeSystem.playerTrails.color
themeSystem.playerTrails.colorPreview.BorderSizePixel = 0
themeSystem.playerTrails.colorPreview.Parent = themeSystem.playerTrails.card
addCorner(themeSystem.playerTrails.colorPreview, 12)
themeSystem.playerTrails.colorPreviewStroke = Instance.new("UIStroke")
themeSystem.playerTrails.colorPreviewStroke.Color = colors.text
themeSystem.playerTrails.colorPreviewStroke.Transparency = 0.2
themeSystem.playerTrails.colorPreviewStroke.Parent = themeSystem.playerTrails.colorPreview

themeSystem.playerInspector = {selected = nil, open = false, optionCount = 0}
themeSystem.playerInspector.card = addCard("PlayerInspectorCard", 340, 34)
addCardTitle(themeSystem.playerInspector.card, "Player Inspector", "Inspect a player and use quick actions without leaving this card.")
themeSystem.playerInspector.card.ClipsDescendants = true

themeSystem.playerInspector.selectButton = Instance.new("TextButton")
themeSystem.playerInspector.selectButton.Name = "InspectorPlayerSelectButton"
themeSystem.playerInspector.selectButton.Position = UDim2.fromOffset(17, 68)
themeSystem.playerInspector.selectButton.Size = UDim2.new(1, -34, 0, 38)
themeSystem.playerInspector.selectButton.BackgroundColor3 = colors.input
themeSystem.playerInspector.selectButton.BorderSizePixel = 0
themeSystem.playerInspector.selectButton.AutoButtonColor = false
themeSystem.playerInspector.selectButton.Font = Enum.Font.GothamMedium
themeSystem.playerInspector.selectButton.Text = "Select a player"
themeSystem.playerInspector.selectButton.TextColor3 = colors.text
themeSystem.playerInspector.selectButton.TextSize = 12
themeSystem.playerInspector.selectButton.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.playerInspector.selectButton.TextTruncate = Enum.TextTruncate.AtEnd
themeSystem.playerInspector.selectButton.Parent = themeSystem.playerInspector.card
addCorner(themeSystem.playerInspector.selectButton, 7)
themeSystem.playerInspector.selectPadding = Instance.new("UIPadding")
themeSystem.playerInspector.selectPadding.PaddingLeft = UDim.new(0, 12)
themeSystem.playerInspector.selectPadding.PaddingRight = UDim.new(0, 36)
themeSystem.playerInspector.selectPadding.Parent = themeSystem.playerInspector.selectButton
themeSystem.playerInspector.arrow = Instance.new("TextLabel")
themeSystem.playerInspector.arrow.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.playerInspector.arrow.Position = UDim2.new(1, -12, 0.5, 0)
themeSystem.playerInspector.arrow.Size = UDim2.fromOffset(18, 20)
themeSystem.playerInspector.arrow.BackgroundTransparency = 1
themeSystem.playerInspector.arrow.Font = Enum.Font.GothamBold
themeSystem.playerInspector.arrow.Text = "v"
themeSystem.playerInspector.arrow.TextColor3 = colors.muted
themeSystem.playerInspector.arrow.TextSize = 12
themeSystem.playerInspector.arrow.Parent = themeSystem.playerInspector.selectButton

themeSystem.playerInspector.listFrame = Instance.new("ScrollingFrame")
themeSystem.playerInspector.listFrame.Name = "InspectorPlayerList"
themeSystem.playerInspector.listFrame.Position = UDim2.fromOffset(17, 112)
themeSystem.playerInspector.listFrame.Size = UDim2.new(1, -34, 0, 0)
themeSystem.playerInspector.listFrame.BackgroundColor3 = colors.input
themeSystem.playerInspector.listFrame.BorderSizePixel = 0
themeSystem.playerInspector.listFrame.ScrollBarThickness = 3
themeSystem.playerInspector.listFrame.ScrollBarImageColor3 = colors.accent
themeSystem.playerInspector.listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
themeSystem.playerInspector.listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
themeSystem.playerInspector.listFrame.Visible = false
themeSystem.playerInspector.listFrame.ZIndex = 10
themeSystem.playerInspector.listFrame.Parent = themeSystem.playerInspector.card
addCorner(themeSystem.playerInspector.listFrame, 7)
themeSystem.playerInspector.listPadding = Instance.new("UIPadding")
themeSystem.playerInspector.listPadding.PaddingTop = UDim.new(0, 5)
themeSystem.playerInspector.listPadding.PaddingBottom = UDim.new(0, 5)
themeSystem.playerInspector.listPadding.PaddingLeft = UDim.new(0, 5)
themeSystem.playerInspector.listPadding.PaddingRight = UDim.new(0, 5)
themeSystem.playerInspector.listPadding.Parent = themeSystem.playerInspector.listFrame
themeSystem.playerInspector.listLayout = Instance.new("UIListLayout")
themeSystem.playerInspector.listLayout.Padding = UDim.new(0, 5)
themeSystem.playerInspector.listLayout.SortOrder = Enum.SortOrder.LayoutOrder
themeSystem.playerInspector.listLayout.Parent = themeSystem.playerInspector.listFrame

themeSystem.playerInspector.avatar = Instance.new("ImageLabel")
themeSystem.playerInspector.avatar.Name = "InspectorAvatar"
themeSystem.playerInspector.avatar.Position = UDim2.fromOffset(17, 120)
themeSystem.playerInspector.avatar.Size = UDim2.fromOffset(68, 68)
themeSystem.playerInspector.avatar.BackgroundColor3 = colors.input
themeSystem.playerInspector.avatar.BorderSizePixel = 0
themeSystem.playerInspector.avatar.Image = ""
themeSystem.playerInspector.avatar.Parent = themeSystem.playerInspector.card
addCorner(themeSystem.playerInspector.avatar, 12)
themeSystem.playerInspector.avatarStroke = Instance.new("UIStroke")
themeSystem.playerInspector.avatarStroke.Color = colors.border
themeSystem.playerInspector.avatarStroke.Transparency = 0.35
themeSystem.playerInspector.avatarStroke.Parent = themeSystem.playerInspector.avatar

themeSystem.playerInspector.nameLabel = Instance.new("TextLabel")
themeSystem.playerInspector.nameLabel.Position = UDim2.fromOffset(99, 117)
themeSystem.playerInspector.nameLabel.Size = UDim2.new(1, -116, 0, 22)
themeSystem.playerInspector.nameLabel.BackgroundTransparency = 1
themeSystem.playerInspector.nameLabel.Font = Enum.Font.GothamBold
themeSystem.playerInspector.nameLabel.Text = "NO PLAYER SELECTED"
themeSystem.playerInspector.nameLabel.TextColor3 = colors.text
themeSystem.playerInspector.nameLabel.TextSize = 13
themeSystem.playerInspector.nameLabel.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.playerInspector.nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
themeSystem.playerInspector.nameLabel.Parent = themeSystem.playerInspector.card

themeSystem.playerInspector.userLabel = Instance.new("TextLabel")
themeSystem.playerInspector.userLabel.Position = UDim2.fromOffset(99, 140)
themeSystem.playerInspector.userLabel.Size = UDim2.new(1, -116, 0, 16)
themeSystem.playerInspector.userLabel.BackgroundTransparency = 1
themeSystem.playerInspector.userLabel.Font = Enum.Font.Gotham
themeSystem.playerInspector.userLabel.Text = "Choose someone from the list above"
themeSystem.playerInspector.userLabel.TextColor3 = colors.muted
themeSystem.playerInspector.userLabel.TextSize = 10
themeSystem.playerInspector.userLabel.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.playerInspector.userLabel.TextTruncate = Enum.TextTruncate.AtEnd
themeSystem.playerInspector.userLabel.Parent = themeSystem.playerInspector.card

themeSystem.playerInspector.statsLabel = Instance.new("TextLabel")
themeSystem.playerInspector.statsLabel.Position = UDim2.fromOffset(99, 160)
themeSystem.playerInspector.statsLabel.Size = UDim2.new(1, -116, 0, 30)
themeSystem.playerInspector.statsLabel.BackgroundTransparency = 1
themeSystem.playerInspector.statsLabel.Font = Enum.Font.GothamMedium
themeSystem.playerInspector.statsLabel.Text = "HEALTH --   •   DISTANCE --   •   TEAM --"
themeSystem.playerInspector.statsLabel.TextColor3 = colors.faint
themeSystem.playerInspector.statsLabel.TextSize = 9
themeSystem.playerInspector.statsLabel.TextWrapped = true
themeSystem.playerInspector.statsLabel.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.playerInspector.statsLabel.TextYAlignment = Enum.TextYAlignment.Top
themeSystem.playerInspector.statsLabel.Parent = themeSystem.playerInspector.card

for index, actionData in ipairs({
	{"goto", "GO TO", "Teleport beside the selected player."},
	{"spectate", "SPECTATE", "Watch through the selected player's camera."},
	{"waypoint", "SAVE WAYPOINT", "Save the selected player's current location."},
}) do
	local row = Instance.new("Frame")
	row.Name = "Inspector" .. actionData[1] .. "Row"
	row.Position = UDim2.fromOffset(17, 202 + (index - 1) * 38)
	row.Size = UDim2.new(1, -34, 0, 32)
	row.BackgroundColor3 = colors.input
	row.BorderSizePixel = 0
	row.Parent = themeSystem.playerInspector.card
	addCorner(row, 7)
	local button = Instance.new("TextButton")
	button.Name = "Inspector" .. actionData[1] .. "Button"
	button.Size = UDim2.new(1, -64, 1, 0)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamBold
	button.Text = actionData[2]
	button.TextColor3 = colors.text
	button.TextSize = 9
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = row
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 11)
	padding.Parent = button
	row:SetAttribute("InspectorDescription", actionData[3])
	themeSystem.playerInspector[actionData[1] .. "Row"] = row
	themeSystem.playerInspector[actionData[1] .. "Button"] = button
end

themeSystem.playerInspector.status = Instance.new("TextLabel")
themeSystem.playerInspector.status.Position = UDim2.fromOffset(17, 318)
themeSystem.playerInspector.status.Size = UDim2.new(1, -34, 0, 14)
themeSystem.playerInspector.status.BackgroundTransparency = 1
themeSystem.playerInspector.status.Font = Enum.Font.Gotham
themeSystem.playerInspector.status.Text = "SELECT A PLAYER TO BEGIN"
themeSystem.playerInspector.status.TextColor3 = colors.faint
themeSystem.playerInspector.status.TextSize = 8
themeSystem.playerInspector.status.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.playerInspector.status.Parent = themeSystem.playerInspector.card

local creditsCard = addCard("CreditsCard", 112, 35)
addCardTitle(creditsCard, "Created by Hourglassinthemaking", "The sole owner and creator of WAVE.")
local creditsText = Instance.new("TextLabel")
creditsText.Position = UDim2.fromOffset(17, 68)
creditsText.Size = UDim2.new(1, -34, 0, 38)
creditsText.BackgroundTransparency = 1
creditsText.Font = Enum.Font.GothamMedium
creditsText.Text = "HOURGLASSINTHEMAKING   •   OWNER / CREATOR"
creditsText.TextColor3 = colors.text
creditsText.TextSize = 12
creditsText.TextWrapped = true
creditsText.TextXAlignment = Enum.TextXAlignment.Left
creditsText.TextYAlignment = Enum.TextYAlignment.Top
creditsText.Parent = creditsCard
creditsCard.Visible = false

local changesCard = addCard("ChangesCard", 118, 6)
addCardTitle(changesCard, "Changes", "Current version status.")
local changesText = Instance.new("TextLabel")
changesText.Position = UDim2.fromOffset(17, 68)
changesText.Size = UDim2.new(1, -34, 0, 28)
changesText.BackgroundTransparency = 1
changesText.Font = Enum.Font.GothamBold
changesText.Text = "POLISHED BUILD"
changesText.TextColor3 = colors.accent
changesText.TextSize = 18
changesText.TextXAlignment = Enum.TextXAlignment.Left
changesText.Parent = changesCard
changesCard.Visible = false

settings.textCard = addCard("SettingsTextSizeCard", 142, 0)
addCardTitle(settings.textCard, "UI text size", "Adjust the size of text throughout the entire menu.")
settings.textTrack = Instance.new("Frame")
settings.textTrack.Name = "TextSizeTrack"
settings.textTrack.Position = UDim2.fromOffset(17, 86)
settings.textTrack.Size = UDim2.new(1, -34, 0, 6)
settings.textTrack.BackgroundColor3 = colors.switchOff
settings.textTrack.BorderSizePixel = 0
settings.textTrack.Active = true
settings.textTrack.Parent = settings.textCard
addCorner(settings.textTrack, 3)
settings.textFill = Instance.new("Frame")
settings.textFill.Name = "TextSizeFill"
settings.textFill.Size = UDim2.new(1 / 3, 0, 1, 0)
settings.textFill.BackgroundColor3 = colors.accent
settings.textFill.BorderSizePixel = 0
settings.textFill.Parent = settings.textTrack
addCorner(settings.textFill, 3)
settings.textKnob = Instance.new("TextButton")
settings.textKnob.Name = "TextSizeKnob"
settings.textKnob.AnchorPoint = Vector2.new(0.5, 0.5)
settings.textKnob.Position = UDim2.new(1 / 3, 0, 0.5, 0)
settings.textKnob.Size = UDim2.fromOffset(18, 18)
settings.textKnob.BackgroundColor3 = colors.text
settings.textKnob.BorderSizePixel = 0
settings.textKnob.AutoButtonColor = false
settings.textKnob.Text = ""
settings.textKnob.Parent = settings.textTrack
addCorner(settings.textKnob, 9)
settings.textValue = Instance.new("TextLabel")
settings.textValue.Position = UDim2.fromOffset(17, 102)
settings.textValue.Size = UDim2.new(1, -34, 0, 22)
settings.textValue.BackgroundTransparency = 1
settings.textValue.Font = Enum.Font.GothamMedium
settings.textValue.Text = "100%"
settings.textValue.TextColor3 = colors.text
settings.textValue.TextSize = 12
settings.textValue.TextXAlignment = Enum.TextXAlignment.Center
settings.textValue.Parent = settings.textCard
settings.textCard.Visible = false

settings.ctrlCard = addCard("SettingsCtrlHoldCard", 142, 1)
addCardTitle(settings.ctrlCard, "Ctrl hold duration", "Hold Ctrl for this long or double tap it within half a second.")
settings.ctrlTrack = Instance.new("Frame")
settings.ctrlTrack.Name = "CtrlHoldTrack"
settings.ctrlTrack.Position = UDim2.fromOffset(17, 86)
settings.ctrlTrack.Size = UDim2.new(1, -34, 0, 6)
settings.ctrlTrack.BackgroundColor3 = colors.switchOff
settings.ctrlTrack.BorderSizePixel = 0
settings.ctrlTrack.Active = true
settings.ctrlTrack.Parent = settings.ctrlCard
addCorner(settings.ctrlTrack, 3)
settings.ctrlFill = Instance.new("Frame")
settings.ctrlFill.Name = "CtrlHoldFill"
settings.ctrlFill.Size = UDim2.new(1 / 3, 0, 1, 0)
settings.ctrlFill.BackgroundColor3 = colors.accent
settings.ctrlFill.BorderSizePixel = 0
settings.ctrlFill.Parent = settings.ctrlTrack
addCorner(settings.ctrlFill, 3)
settings.ctrlKnob = Instance.new("TextButton")
settings.ctrlKnob.Name = "CtrlHoldKnob"
settings.ctrlKnob.AnchorPoint = Vector2.new(0.5, 0.5)
settings.ctrlKnob.Position = UDim2.new(1 / 3, 0, 0.5, 0)
settings.ctrlKnob.Size = UDim2.fromOffset(18, 18)
settings.ctrlKnob.BackgroundColor3 = colors.text
settings.ctrlKnob.BorderSizePixel = 0
settings.ctrlKnob.AutoButtonColor = false
settings.ctrlKnob.Text = ""
settings.ctrlKnob.Parent = settings.ctrlTrack
addCorner(settings.ctrlKnob, 9)
settings.ctrlValue = Instance.new("TextLabel")
settings.ctrlValue.Position = UDim2.fromOffset(17, 102)
settings.ctrlValue.Size = UDim2.new(1, -34, 0, 22)
settings.ctrlValue.BackgroundTransparency = 1
settings.ctrlValue.Font = Enum.Font.GothamMedium
settings.ctrlValue.Text = "0.5 SECONDS"
settings.ctrlValue.TextColor3 = colors.text
settings.ctrlValue.TextSize = 12
settings.ctrlValue.TextXAlignment = Enum.TextXAlignment.Center
settings.ctrlValue.Parent = settings.ctrlCard
settings.ctrlCard.Visible = false

settings.activeHudCard = addCard("SettingsActiveHudCard", 86, 2)
addCardTitle(settings.activeHudCard, "Enabled cheats overlay", "Show the compact list of enabled cheats at the top left.")
settings.activeHudCard.Visible = false

themeSystem.themes = {
	{
		name = "Supernova",
		description = "Hot pink, violet, and solar orange.",
		palette = {
			background = Color3.fromRGB(10, 3, 20), panel = Color3.fromRGB(25, 10, 42), sidebar = Color3.fromRGB(16, 7, 29),
			card = Color3.fromRGB(39, 16, 61), cardTop = Color3.fromRGB(55, 22, 80), cardHover = Color3.fromRGB(67, 27, 95),
			input = Color3.fromRGB(19, 7, 31), border = Color3.fromRGB(131, 73, 160), accent = Color3.fromRGB(255, 72, 165),
			accent2 = Color3.fromRGB(255, 174, 73), accentSoft = Color3.fromRGB(94, 28, 82), switchOff = Color3.fromRGB(72, 42, 84),
			text = Color3.fromRGB(255, 245, 252), muted = Color3.fromRGB(207, 164, 198), faint = Color3.fromRGB(133, 88, 132),
			success = Color3.fromRGB(96, 232, 168), danger = Color3.fromRGB(255, 84, 111),
		},
	},
	{
		name = "Default",
		description = "The signature violet and teal Wave look.",
		palette = {
			background = Color3.fromRGB(3, 6, 14), panel = Color3.fromRGB(13, 18, 31), sidebar = Color3.fromRGB(8, 12, 23),
			card = Color3.fromRGB(20, 27, 44), cardTop = Color3.fromRGB(27, 36, 58), cardHover = Color3.fromRGB(31, 41, 66),
			input = Color3.fromRGB(8, 13, 25), border = Color3.fromRGB(74, 91, 132), accent = Color3.fromRGB(112, 96, 255),
			accent2 = Color3.fromRGB(53, 211, 196), accentSoft = Color3.fromRGB(48, 43, 112), switchOff = Color3.fromRGB(48, 60, 88),
			text = Color3.fromRGB(243, 246, 255), muted = Color3.fromRGB(155, 168, 197), faint = Color3.fromRGB(93, 107, 139),
			success = Color3.fromRGB(69, 224, 166), danger = Color3.fromRGB(255, 91, 122),
		},
	},
	{
		name = "Eclipse",
		description = "Near-black surfaces with a golden corona.",
		palette = {
			background = Color3.fromRGB(4, 4, 5), panel = Color3.fromRGB(15, 15, 17), sidebar = Color3.fromRGB(9, 9, 11),
			card = Color3.fromRGB(25, 24, 25), cardTop = Color3.fromRGB(35, 33, 31), cardHover = Color3.fromRGB(45, 42, 37),
			input = Color3.fromRGB(10, 10, 11), border = Color3.fromRGB(104, 91, 61), accent = Color3.fromRGB(242, 183, 64),
			accent2 = Color3.fromRGB(255, 111, 61), accentSoft = Color3.fromRGB(85, 60, 24), switchOff = Color3.fromRGB(62, 59, 52),
			text = Color3.fromRGB(250, 246, 231), muted = Color3.fromRGB(185, 177, 151), faint = Color3.fromRGB(112, 106, 91),
			success = Color3.fromRGB(120, 218, 145), danger = Color3.fromRGB(255, 93, 83),
		},
	},
	{
		name = "Aqua",
		description = "Clear ocean blues and bright cyan highlights.",
		palette = {
			background = Color3.fromRGB(2, 10, 17), panel = Color3.fromRGB(7, 25, 38), sidebar = Color3.fromRGB(4, 17, 29),
			card = Color3.fromRGB(10, 38, 54), cardTop = Color3.fromRGB(13, 52, 72), cardHover = Color3.fromRGB(16, 63, 84),
			input = Color3.fromRGB(3, 20, 31), border = Color3.fromRGB(49, 113, 139), accent = Color3.fromRGB(37, 197, 255),
			accent2 = Color3.fromRGB(47, 239, 205), accentSoft = Color3.fromRGB(15, 84, 112), switchOff = Color3.fromRGB(34, 79, 99),
			text = Color3.fromRGB(237, 253, 255), muted = Color3.fromRGB(145, 204, 216), faint = Color3.fromRGB(76, 132, 149),
			success = Color3.fromRGB(54, 230, 169), danger = Color3.fromRGB(255, 100, 129),
		},
	},
	{
		name = "Radioactive",
		description = "Toxic green energy over deep graphite.",
		palette = {
			background = Color3.fromRGB(3, 7, 3), panel = Color3.fromRGB(12, 20, 13), sidebar = Color3.fromRGB(7, 14, 8),
			card = Color3.fromRGB(20, 33, 20), cardTop = Color3.fromRGB(29, 47, 28), cardHover = Color3.fromRGB(38, 59, 35),
			input = Color3.fromRGB(8, 16, 8), border = Color3.fromRGB(74, 117, 65), accent = Color3.fromRGB(126, 255, 67),
			accent2 = Color3.fromRGB(221, 255, 63), accentSoft = Color3.fromRGB(52, 91, 30), switchOff = Color3.fromRGB(54, 76, 49),
			text = Color3.fromRGB(244, 255, 236), muted = Color3.fromRGB(171, 205, 151), faint = Color3.fromRGB(98, 132, 85),
			success = Color3.fromRGB(104, 255, 118), danger = Color3.fromRGB(255, 82, 82),
		},
	},
	{
		name = "Nebula",
		description = "Deep-space indigo with electric starlight.",
		palette = {
			background = Color3.fromRGB(5, 4, 18), panel = Color3.fromRGB(17, 14, 42), sidebar = Color3.fromRGB(10, 8, 29),
			card = Color3.fromRGB(27, 23, 61), cardTop = Color3.fromRGB(39, 31, 83), cardHover = Color3.fromRGB(48, 38, 99),
			input = Color3.fromRGB(11, 9, 30), border = Color3.fromRGB(87, 76, 151), accent = Color3.fromRGB(130, 102, 255),
			accent2 = Color3.fromRGB(70, 155, 255), accentSoft = Color3.fromRGB(55, 42, 124), switchOff = Color3.fromRGB(58, 52, 99),
			text = Color3.fromRGB(246, 244, 255), muted = Color3.fromRGB(174, 164, 216), faint = Color3.fromRGB(105, 94, 157),
			success = Color3.fromRGB(71, 224, 181), danger = Color3.fromRGB(255, 91, 145),
		},
	},
	{
		name = "Rose Quartz",
		description = "Smoky plum with soft rose-gold accents.",
		palette = {
			background = Color3.fromRGB(12, 6, 11), panel = Color3.fromRGB(31, 18, 29), sidebar = Color3.fromRGB(21, 11, 20),
			card = Color3.fromRGB(48, 28, 44), cardTop = Color3.fromRGB(64, 37, 57), cardHover = Color3.fromRGB(77, 44, 68),
			input = Color3.fromRGB(23, 12, 21), border = Color3.fromRGB(139, 91, 120), accent = Color3.fromRGB(244, 139, 178),
			accent2 = Color3.fromRGB(255, 194, 151), accentSoft = Color3.fromRGB(103, 55, 82), switchOff = Color3.fromRGB(83, 57, 74),
			text = Color3.fromRGB(255, 244, 249), muted = Color3.fromRGB(216, 174, 194), faint = Color3.fromRGB(145, 101, 123),
			success = Color3.fromRGB(93, 226, 163), danger = Color3.fromRGB(255, 91, 120),
		},
	},
	{
		name = "Ember",
		description = "Charcoal, flame orange, and molten red.",
		palette = {
			background = Color3.fromRGB(10, 5, 3), panel = Color3.fromRGB(29, 16, 11), sidebar = Color3.fromRGB(19, 10, 7),
			card = Color3.fromRGB(45, 25, 17), cardTop = Color3.fromRGB(61, 34, 22), cardHover = Color3.fromRGB(75, 41, 25),
			input = Color3.fromRGB(20, 10, 6), border = Color3.fromRGB(137, 78, 48), accent = Color3.fromRGB(255, 119, 48),
			accent2 = Color3.fromRGB(255, 61, 72), accentSoft = Color3.fromRGB(105, 48, 23), switchOff = Color3.fromRGB(84, 54, 40),
			text = Color3.fromRGB(255, 246, 238), muted = Color3.fromRGB(218, 177, 151), faint = Color3.fromRGB(143, 101, 77),
			success = Color3.fromRGB(105, 226, 139), danger = Color3.fromRGB(255, 62, 69),
		},
	},
	{
		name = "Frostbite",
		description = "Icy navy glass with frozen-blue highlights.",
		palette = {
			background = Color3.fromRGB(2, 8, 16), panel = Color3.fromRGB(10, 25, 40), sidebar = Color3.fromRGB(5, 16, 29),
			card = Color3.fromRGB(17, 39, 58), cardTop = Color3.fromRGB(24, 53, 76), cardHover = Color3.fromRGB(31, 65, 90),
			input = Color3.fromRGB(5, 19, 31), border = Color3.fromRGB(83, 133, 164), accent = Color3.fromRGB(107, 203, 255),
			accent2 = Color3.fromRGB(187, 247, 255), accentSoft = Color3.fromRGB(38, 89, 123), switchOff = Color3.fromRGB(51, 83, 105),
			text = Color3.fromRGB(244, 253, 255), muted = Color3.fromRGB(170, 211, 226), faint = Color3.fromRGB(100, 147, 166),
			success = Color3.fromRGB(86, 232, 191), danger = Color3.fromRGB(255, 103, 137),
		},
	},
	{
		name = "Synthwave",
		description = "Retro neon magenta and cyan after dark.",
		palette = {
			background = Color3.fromRGB(7, 2, 19), panel = Color3.fromRGB(20, 8, 43), sidebar = Color3.fromRGB(12, 4, 29),
			card = Color3.fromRGB(34, 13, 64), cardTop = Color3.fromRGB(48, 18, 85), cardHover = Color3.fromRGB(59, 23, 101),
			input = Color3.fromRGB(14, 5, 32), border = Color3.fromRGB(119, 68, 163), accent = Color3.fromRGB(255, 53, 192),
			accent2 = Color3.fromRGB(39, 232, 255), accentSoft = Color3.fromRGB(91, 29, 112), switchOff = Color3.fromRGB(69, 44, 96),
			text = Color3.fromRGB(253, 244, 255), muted = Color3.fromRGB(204, 163, 221), faint = Color3.fromRGB(126, 87, 153),
			success = Color3.fromRGB(59, 242, 186), danger = Color3.fromRGB(255, 73, 122),
		},
	},
	{
		name = "Obsidian",
		description = "Minimal black stone with cool silver light.",
		palette = {
			background = Color3.fromRGB(2, 3, 5), panel = Color3.fromRGB(11, 13, 17), sidebar = Color3.fromRGB(7, 8, 11),
			card = Color3.fromRGB(21, 24, 30), cardTop = Color3.fromRGB(30, 34, 42), cardHover = Color3.fromRGB(40, 45, 55),
			input = Color3.fromRGB(7, 9, 12), border = Color3.fromRGB(89, 100, 118), accent = Color3.fromRGB(174, 190, 218),
			accent2 = Color3.fromRGB(105, 133, 179), accentSoft = Color3.fromRGB(57, 67, 84), switchOff = Color3.fromRGB(54, 61, 72),
			text = Color3.fromRGB(246, 248, 252), muted = Color3.fromRGB(176, 184, 199), faint = Color3.fromRGB(104, 113, 129),
			success = Color3.fromRGB(102, 220, 170), danger = Color3.fromRGB(244, 91, 111),
		},
	},
}

themeSystem.cards = {}
themeSystem.currentName = "Default"

function themeSystem.mapColor(value, previousPalette, nextPalette)
	for key, previousColor in pairs(previousPalette) do
		if value == previousColor and nextPalette[key] then
			return nextPalette[key]
		end
	end
	return value
end

function themeSystem.mapTextColor(value, previousPalette, nextPalette)
	for _, key in ipairs({"text", "muted", "faint", "success", "danger", "accent", "accent2"}) do
		if value == previousPalette[key] and nextPalette[key] then
			return nextPalette[key]
		end
	end
	return themeSystem.mapColor(value, previousPalette, nextPalette)
end

function themeSystem.readableText(preferred, background)
	local foregroundLuminance = preferred.R * 0.2126 + preferred.G * 0.7152 + preferred.B * 0.0722
	local backgroundLuminance = background.R * 0.2126 + background.G * 0.7152 + background.B * 0.0722
	if math.abs(foregroundLuminance - backgroundLuminance) >= 0.42 then
		return preferred
	end
	return backgroundLuminance < 0.5 and Color3.fromRGB(245, 249, 255) or Color3.fromRGB(16, 22, 31)
end

function themeSystem.apply(theme)
	local previousPalette = {}
	for key, value in pairs(colors) do
		previousPalette[key] = value
	end
	for key, value in pairs(theme.palette) do
		colors[key] = value
	end

	for _, instance in ipairs(screenGui:GetDescendants()) do
		if not instance:GetAttribute("ThemePreview") then
			if instance:IsA("GuiObject") then
				instance.BackgroundColor3 = themeSystem.mapColor(instance.BackgroundColor3, previousPalette, colors)
			end
			if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
				instance.TextColor3 = themeSystem.mapTextColor(instance.TextColor3, previousPalette, colors)
			end
			if instance:IsA("TextBox") then
				instance.TextColor3 = themeSystem.readableText(colors.text, colors.input)
				instance.PlaceholderColor3 = themeSystem.readableText(colors.muted, colors.input)
			end
			if instance:IsA("UIStroke") then
				instance.Color = themeSystem.mapColor(instance.Color, previousPalette, colors)
			end
			if instance:IsA("TextButton") then
				local restingColor = instance:GetAttribute("WaveRestingColor")
				if typeof(restingColor) == "Color3" then
					instance:SetAttribute("WaveRestingColor", themeSystem.mapColor(restingColor, previousPalette, colors))
				end
			end

			if instance:IsA("UIGradient") then
				local parent = instance.Parent
				if parent == backdrop then
					instance.Color = ColorSequence.new(colors.background, colors.background:Lerp(colors.accent, 0.2))
				elseif parent == panel then
					instance.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, colors.panel:Lerp(colors.text, 0.035)),
						ColorSequenceKeypoint.new(0.55, colors.panel),
						ColorSequenceKeypoint.new(1, colors.panel:Lerp(colors.background, 0.38)),
					})
				elseif parent == sidebar then
					instance.Color = ColorSequence.new(colors.sidebar:Lerp(colors.card, 0.2), colors.sidebar)
				elseif parent == brand then
					instance.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, colors.text),
						ColorSequenceKeypoint.new(0.55, colors.accent:Lerp(colors.text, 0.35)),
						ColorSequenceKeypoint.new(1, colors.accent2),
					})
				elseif parent == brandAccent or parent == selectionBar or parent.Name == "AccentRail" then
					instance.Color = ColorSequence.new(colors.accent, colors.accent2)
				elseif parent:IsA("Frame") and parent.Parent == content then
					instance.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, colors.cardTop),
						ColorSequenceKeypoint.new(0.42, colors.card),
						ColorSequenceKeypoint.new(1, colors.card:Lerp(colors.background, 0.3)),
					})
				elseif parent:IsA("TextBox") then
					instance.Color = ColorSequence.new(Color3.new(1, 1, 1))
				end
			end
		end
	end

	themeSystem.currentName = theme.name
	themeSystem.currentTheme = theme
	for _, themeCard in pairs(themeSystem.cards) do
		local active = themeCard.theme == theme or themeCard.theme.name == theme.name
		themeCard.button.Text = active and "ACTIVE" or "APPLY"
		themeCard.button.BackgroundColor3 = active and colors.success or colors.accent
		themeCard.button:SetAttribute("WaveRestingColor", themeCard.button.BackgroundColor3)
	end
end

function themeSystem.styleButton(button)
	button:SetAttribute("WavePolished", true)
	button:SetAttribute("WaveRestingColor", button.BackgroundColor3)
	local stroke = Instance.new("UIStroke")
	stroke.Color = colors.border
	stroke.Transparency = 0.62
	stroke.Parent = button
	button.MouseEnter:Connect(function()
		local restingColor = button:GetAttribute("WaveRestingColor") or button.BackgroundColor3
		TweenService:Create(button, TweenInfo.new(0.14), {BackgroundColor3 = restingColor:Lerp(Color3.new(1, 1, 1), 0.12)}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.14), {Transparency = 0.2, Color = colors.accent2}):Play()
	end)
	button.MouseLeave:Connect(function()
		local restingColor = button:GetAttribute("WaveRestingColor") or button.BackgroundColor3
		TweenService:Create(button, TweenInfo.new(0.14), {BackgroundColor3 = restingColor}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.14), {Transparency = 0.62, Color = colors.border}):Play()
	end)
	if themeSystem.enhanceButton then
		themeSystem.enhanceButton(button)
	end
end

function themeSystem.createCard(theme, index)
	local custom = theme.customId ~= nil
	local card = addCard("Theme_" .. string.gsub(theme.name, " ", "") .. (theme.customId or ""), 112, index)
	card:SetAttribute("WaveOriginalOrder", index)
	addCardTitle(card, theme.name, theme.description)
	card.Visible = false

	if not custom then
		local previewColors = {theme.palette.accent, theme.palette.accent2, theme.palette.cardTop, theme.palette.text}
		for swatchIndex, swatchColor in ipairs(previewColors) do
			local swatch = Instance.new("Frame")
			swatch.Name = "Preview" .. swatchIndex
			swatch.Position = UDim2.fromOffset(17 + (swatchIndex - 1) * 19, 73)
			swatch.Size = UDim2.fromOffset(14, 14)
			swatch.BackgroundColor3 = swatchColor
			swatch.BorderSizePixel = 0
			swatch:SetAttribute("ThemePreview", true)
			swatch.Parent = card
			addCorner(swatch, 7)
			local swatchStroke = Instance.new("UIStroke")
			swatchStroke.Color = Color3.fromRGB(255, 255, 255)
			swatchStroke.Transparency = 0.72
			swatchStroke.Parent = swatch
		end
	end

	local applyButton = Instance.new("TextButton")
	applyButton.Name = "ThemeApplyButton_" .. string.gsub(theme.name, " ", "")
	applyButton.AnchorPoint = Vector2.new(1, 0.5)
	applyButton.Position = custom and UDim2.new(1, -51, 0, 80) or UDim2.new(1, -17, 0, 80)
	applyButton.Size = custom and UDim2.new(1, -68, 0, 28) or UDim2.fromOffset(72, 28)
	applyButton.BackgroundColor3 = themeSystem.currentTheme == theme and colors.success or colors.accent
	applyButton.BorderSizePixel = 0
	applyButton.AutoButtonColor = false
	applyButton.Font = Enum.Font.GothamBold
	applyButton.Text = themeSystem.currentTheme == theme and "ACTIVE" or "APPLY"
	applyButton.TextColor3 = colors.text
	applyButton.TextSize = 9
	applyButton.Parent = card
	addCorner(applyButton, 8)
	themeSystem.styleButton(applyButton)

	local cardKey = custom and ("Custom_" .. theme.customId) or theme.name
	themeSystem.cards[cardKey] = {card = card, button = applyButton, theme = theme}
	if themeSystem.favoriteSystem.registerTheme then
		themeSystem.favoriteSystem.registerTheme(cardKey, themeSystem.cards[cardKey], index)
	end
	applyButton.Activated:Connect(function()
		playSound(clickSound)
		themeSystem.apply(theme)
	end)

	if custom then
		local menuButton = Instance.new("TextButton")
		menuButton.Name = "CustomThemeMenuButton"
		menuButton.AnchorPoint = Vector2.new(1, 0.5)
		menuButton.Position = UDim2.new(1, -17, 0, 80)
		menuButton.Size = UDim2.fromOffset(28, 28)
		menuButton.BackgroundColor3 = colors.cardHover
		menuButton.BorderSizePixel = 0
		menuButton.AutoButtonColor = false
		menuButton.Font = Enum.Font.GothamBold
		menuButton.Text = "..."
		menuButton.TextColor3 = colors.text
		menuButton.TextSize = 13
		menuButton.Parent = card
		addCorner(menuButton, 8)
		themeSystem.styleButton(menuButton)

		local managementFrame = Instance.new("Frame")
		managementFrame.Name = "CustomThemeManagement"
		managementFrame.Position = UDim2.fromOffset(17, 118)
		managementFrame.Size = UDim2.new(1, -34, 0, 65)
		managementFrame.BackgroundTransparency = 1
		managementFrame.Visible = false
		managementFrame.Parent = card

		local function makeManageButton(name, text, position, size, backgroundColor)
			local button = Instance.new("TextButton")
			button.Name = name
			button.Position = position
			button.Size = size
			button.BackgroundColor3 = backgroundColor
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = Enum.Font.GothamBold
			button.Text = text
			button.TextColor3 = colors.text
			button.TextSize = 8
			button.Parent = managementFrame
			addCorner(button, 8)
			themeSystem.styleButton(button)
			return button
		end

		local editButton = makeManageButton("EditThemeButton", "EDIT", UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -3, 0, 28), colors.cardHover)
		local duplicateButton = makeManageButton("DuplicateThemeButton", "DUPLICATE", UDim2.new(0.5, 3, 0, 0), UDim2.new(0.5, -3, 0, 28), colors.cardHover)
		local renameButton = makeManageButton("RenameThemeButton", "RENAME", UDim2.new(0, 0, 0, 36), UDim2.new(0.5, -3, 0, 28), colors.cardHover)
		local removeButton = makeManageButton("RemoveThemeButton", "DELETE", UDim2.new(0.5, 3, 0, 36), UDim2.new(0.5, -3, 0, 28), colors.danger)
		menuButton.Activated:Connect(function()
			playSound(clickSound)
			local open = not managementFrame.Visible
			managementFrame.Visible = open
			menuButton.Text = open and "^" or "..."
			card.Size = UDim2.new(1, -3, 0, open and 194 or 112)
		end)
		editButton.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.editCustom(theme, false)
		end)
		duplicateButton.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.duplicateCustom(theme)
		end)
		renameButton.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.editCustom(theme, true)
		end)
		removeButton.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.removeCustom(theme)
		end)
	end
end

function themeSystem.setCardsVisible(visible)
	if themeSystem.editor and themeSystem.editor.card then
		themeSystem.editor.card.Visible = visible
	end
	for _, themeCard in pairs(themeSystem.cards) do
		themeCard.card.Visible = visible
	end
end

for index, theme in ipairs(themeSystem.themes) do
	if theme.name == "Default" then
		themeSystem.currentTheme = theme
	end
	themeSystem.createCard(theme, 100 + index)
end

themeSystem.customThemes = {}
themeSystem.nextCustomId = 0

function themeSystem.colorToHex(color)
	return string.format(
		"#%02X%02X%02X",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
	)
end

function themeSystem.hexToColor(text)
	local cleaned = string.upper(string.gsub(string.gsub(text or "", "#", ""), "%s", ""))
	if #cleaned == 3 then
		cleaned = string.sub(cleaned, 1, 1) .. string.sub(cleaned, 1, 1)
			.. string.sub(cleaned, 2, 2) .. string.sub(cleaned, 2, 2)
			.. string.sub(cleaned, 3, 3) .. string.sub(cleaned, 3, 3)
	end
	if #cleaned ~= 6 or string.find(cleaned, "[^0-9A-F]") then
		return nil
	end
	return Color3.fromRGB(
		tonumber(string.sub(cleaned, 1, 2), 16),
		tonumber(string.sub(cleaned, 3, 4), 16),
		tonumber(string.sub(cleaned, 5, 6), 16)
	)
end

function themeSystem.nameIsUsed(name, ignoredTheme)
	local lowered = string.lower(name)
	for _, theme in ipairs(themeSystem.themes) do
		if string.lower(theme.name) == lowered then
			return true
		end
	end
	for _, theme in ipairs(themeSystem.customThemes) do
		if theme ~= ignoredTheme and string.lower(theme.name) == lowered then
			return true
		end
	end
	return false
end

function themeSystem.uniqueName(baseName)
	local candidate = baseName
	local suffix = 2
	while themeSystem.nameIsUsed(candidate, nil) do
		candidate = baseName .. " " .. suffix
		suffix += 1
	end
	return candidate
end

function themeSystem.copyPalette(palette)
	local copy = {}
	for key, value in pairs(palette) do
		copy[key] = value
	end
	return copy
end

function themeSystem.buildPaletteFromEditor()
	local parsed = {}
	for _, key in ipairs({"background", "panel", "sidebar", "card", "input", "accent", "accent2", "text"}) do
		local color = themeSystem.editor.fields[key].color
		if not color then
			return nil, key
		end
		parsed[key] = color
	end

	return {
		background = parsed.background,
		panel = parsed.panel,
		sidebar = parsed.sidebar,
		card = parsed.card,
		cardTop = parsed.card:Lerp(parsed.text, 0.1),
		cardHover = parsed.card:Lerp(parsed.accent, 0.18),
		input = parsed.input,
		border = parsed.card:Lerp(parsed.accent, 0.42),
		accent = parsed.accent,
		accent2 = parsed.accent2,
		accentSoft = parsed.background:Lerp(parsed.accent, 0.34),
		switchOff = parsed.input:Lerp(parsed.text, 0.24),
		text = parsed.text,
		muted = parsed.text:Lerp(parsed.card, 0.42),
		faint = parsed.text:Lerp(parsed.card, 0.66),
		success = Color3.fromRGB(69, 224, 166),
		danger = Color3.fromRGB(255, 91, 122),
	}, nil
end

function themeSystem.refreshEditorSwatch(key)
	local field = themeSystem.editor.fields[key]
	if not field or not field.swatch then
		return
	end
	field.swatch.BackgroundColor3 = field.color
	if field.rgbLabel then
		field.rgbLabel.Text = string.format(
			"R %d   G %d   B %d",
			math.floor(field.color.R * 255 + 0.5),
			math.floor(field.color.G * 255 + 0.5),
			math.floor(field.color.B * 255 + 0.5)
		)
	end
end

function themeSystem.setEditorOpen(open)
	themeSystem.editor.open = open
	themeSystem.editor.body.Visible = open
	themeSystem.editor.card.Size = UDim2.new(1, -3, 0, open and 670 or 86)
	themeSystem.editor.createButton.Text = open and "CLOSE" or "CREATE"
	if not open then
		themeSystem.editor.editingTheme = nil
		themeSystem.editor.status.Text = ""
	end
end

function themeSystem.loadEditor(theme, focusName)
	themeSystem.editor.editingTheme = theme
	themeSystem.editor.fields.name.box.Text = theme and theme.name or themeSystem.uniqueName("My Theme")
	local sourcePalette = theme and theme.palette or colors
	for _, key in ipairs({"background", "panel", "sidebar", "card", "input", "accent", "accent2", "text"}) do
		themeSystem.editor.fields[key].color = sourcePalette[key]
		themeSystem.refreshEditorSwatch(key)
	end
	themeSystem.selectEditorColor("accent")
	themeSystem.editor.status.Text = theme and ("EDITING  " .. string.upper(theme.name)) or "CREATING A NEW CUSTOM THEME"
	themeSystem.editor.status.TextColor3 = colors.accent2
	themeSystem.setEditorOpen(true)
	content.CanvasPosition = Vector2.zero
	if focusName then
		task.defer(function()
			themeSystem.editor.fields.name.box:CaptureFocus()
		end)
	end
end

function themeSystem.editCustom(theme, focusName)
	themeSystem.loadEditor(theme, focusName)
end

function themeSystem.rebuildCustomCards()
	local keysToRemove = {}
	for key, themeCard in pairs(themeSystem.cards) do
		if themeCard.theme.customId then
			table.insert(keysToRemove, key)
			themeCard.card:Destroy()
		end
	end
	for _, key in ipairs(keysToRemove) do
		themeSystem.cards[key] = nil
	end
	for index, theme in ipairs(themeSystem.customThemes) do
		themeSystem.createCard(theme, index)
		themeSystem.cards["Custom_" .. theme.customId].card.Visible = activeTabName == "Customize"
	end
end

function themeSystem.duplicateCustom(theme)
	themeSystem.nextCustomId += 1
	local duplicate = {
		name = themeSystem.uniqueName(theme.name .. " Copy"),
		description = "Custom theme duplicated from " .. theme.name .. ".",
		palette = themeSystem.copyPalette(theme.palette),
		customId = tostring(themeSystem.nextCustomId),
	}
	table.insert(themeSystem.customThemes, duplicate)
	themeSystem.rebuildCustomCards()
end

function themeSystem.removeCustom(theme)
	if themeSystem.favoriteSystem.unregister then
		themeSystem.favoriteSystem.unregister("theme:Custom_" .. theme.customId)
	end
	if themeSystem.currentTheme == theme then
		for _, fixedTheme in ipairs(themeSystem.themes) do
			if fixedTheme.name == "Default" then
				themeSystem.apply(fixedTheme)
				break
			end
		end
	end
	for index, customTheme in ipairs(themeSystem.customThemes) do
		if customTheme == theme then
			table.remove(themeSystem.customThemes, index)
			break
		end
	end
	if themeSystem.editor.editingTheme == theme then
		themeSystem.setEditorOpen(false)
	end
	themeSystem.rebuildCustomCards()
end

function themeSystem.saveEditor()
	local name = string.gsub(themeSystem.editor.fields.name.box.Text, "^%s*(.-)%s*$", "%1")
	if name == "" then
		themeSystem.editor.status.Text = "ENTER A THEME NAME"
		themeSystem.editor.status.TextColor3 = colors.danger
		return
	end
	if themeSystem.nameIsUsed(name, themeSystem.editor.editingTheme) then
		themeSystem.editor.status.Text = "THAT NAME IS ALREADY USED"
		themeSystem.editor.status.TextColor3 = colors.danger
		return
	end

	local palette, invalidKey = themeSystem.buildPaletteFromEditor()
	if not palette then
		themeSystem.editor.status.Text = "CHECK THE " .. string.upper(invalidKey) .. " HEX COLOR"
		themeSystem.editor.status.TextColor3 = colors.danger
		return
	end

	local theme = themeSystem.editor.editingTheme
	local createdNew = theme == nil
	local wasActive = theme and themeSystem.currentTheme == theme
	if theme then
		theme.name = name
		theme.palette = palette
		theme.description = "Custom theme created in the Wave editor."
	else
		themeSystem.nextCustomId += 1
		theme = {
			name = name,
			description = "Custom theme created in the Wave editor.",
			palette = palette,
			customId = tostring(themeSystem.nextCustomId),
		}
		table.insert(themeSystem.customThemes, theme)
	end

	themeSystem.rebuildCustomCards()
	if wasActive or createdNew then
		themeSystem.apply(theme)
	end
	themeSystem.setEditorOpen(false)
end

function themeSystem.updatePickerVisual()
	local field = themeSystem.editor.fields[themeSystem.editor.selectedKey]
	if not field then
		return
	end
	local hue, saturation, value = field.color:ToHSV()
	themeSystem.editor.hue = hue
	themeSystem.editor.saturation = saturation
	themeSystem.editor.value = value
	local radius = 59 * saturation
	local angle = hue * math.pi * 2
	themeSystem.editor.wheelMarker.Position = UDim2.fromOffset(75 + math.cos(angle) * radius, 75 + math.sin(angle) * radius)
	themeSystem.editor.wheelCenter.BackgroundColor3 = Color3.fromHSV(hue, math.max(0.25, saturation), value)
	themeSystem.editor.brightnessGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(hue, saturation, 1))
	themeSystem.editor.brightnessMarker.Position = UDim2.new(value, 0, 0.5, 0)
	themeSystem.editor.selectedLabel.Text = "PICKING  " .. string.upper(themeSystem.editor.selectedKey)
	themeSystem.editor.selectedRGB.Text = string.format(
		"R %d   G %d   B %d   •   BRIGHTNESS BELOW",
		math.floor(field.color.R * 255 + 0.5),
		math.floor(field.color.G * 255 + 0.5),
		math.floor(field.color.B * 255 + 0.5)
	)
	themeSystem.refreshEditorSwatch(themeSystem.editor.selectedKey)
end

function themeSystem.selectEditorColor(key)
	themeSystem.editor.selectedKey = key
	for fieldKey, field in pairs(themeSystem.editor.fields) do
		if field.button then
			field.button.BackgroundColor3 = fieldKey == key and colors.accentSoft or colors.input
			field.button:SetAttribute("WaveRestingColor", field.button.BackgroundColor3)
		end
	end
	themeSystem.updatePickerVisual()
end

function themeSystem.updateWheelFromPosition(position)
	local wheel = themeSystem.editor.wheelInput
	local center = wheel.AbsolutePosition + wheel.AbsoluteSize / 2
	local offset = Vector2.new(position.X, position.Y) - center
	local radius = math.min(wheel.AbsoluteSize.X, wheel.AbsoluteSize.Y) / 2 - 12
	local hue = (math.atan2(offset.Y, offset.X) / (math.pi * 2)) % 1
	local saturation = math.clamp(offset.Magnitude / radius, 0, 1)
	local field = themeSystem.editor.fields[themeSystem.editor.selectedKey]
	field.color = Color3.fromHSV(hue, saturation, themeSystem.editor.value or 1)
	themeSystem.updatePickerVisual()
end

function themeSystem.updateBrightnessFromPosition(position)
	local slider = themeSystem.editor.brightnessInput
	local value = math.clamp((position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
	local field = themeSystem.editor.fields[themeSystem.editor.selectedKey]
	field.color = Color3.fromHSV(themeSystem.editor.hue or 0, themeSystem.editor.saturation or 0, value)
	themeSystem.updatePickerVisual()
end

function themeSystem.buildEditor()
	themeSystem.editor = {fields = {}, open = false}
	themeSystem.editor.card = addCard("CustomThemeBuilder", 86, 0)
	addCardTitle(themeSystem.editor.card, "Custom Theme", "Pick each labeled color visually—no codes needed.")
	themeSystem.editor.card.Visible = false

	themeSystem.editor.createButton = Instance.new("TextButton")
	themeSystem.editor.createButton.Name = "CreateCustomThemeButton"
	themeSystem.editor.createButton.AnchorPoint = Vector2.new(1, 0.5)
	themeSystem.editor.createButton.Position = UDim2.new(1, -17, 0, 49)
	themeSystem.editor.createButton.Size = UDim2.fromOffset(72, 28)
	themeSystem.editor.createButton.BackgroundColor3 = colors.accent
	themeSystem.editor.createButton.BorderSizePixel = 0
	themeSystem.editor.createButton.AutoButtonColor = false
	themeSystem.editor.createButton.Font = Enum.Font.GothamBold
	themeSystem.editor.createButton.Text = "CREATE"
	themeSystem.editor.createButton.TextColor3 = colors.text
	themeSystem.editor.createButton.TextSize = 9
	themeSystem.editor.createButton.Parent = themeSystem.editor.card
	addCorner(themeSystem.editor.createButton, 8)
	themeSystem.styleButton(themeSystem.editor.createButton)

	themeSystem.editor.body = Instance.new("Frame")
	themeSystem.editor.body.Name = "EditorBody"
	themeSystem.editor.body.Position = UDim2.fromOffset(0, 86)
	themeSystem.editor.body.Size = UDim2.new(1, 0, 0, 568)
	themeSystem.editor.body.BackgroundTransparency = 1
	themeSystem.editor.body.Visible = false
	themeSystem.editor.body.Parent = themeSystem.editor.card

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Position = UDim2.fromOffset(17, 0)
	nameLabel.Size = UDim2.new(1, -34, 0, 15)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = "THEME NAME"
	nameLabel.TextColor3 = colors.muted
	nameLabel.TextSize = 9
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = themeSystem.editor.body

	local nameBox = Instance.new("TextBox")
	nameBox.Name = "CustomTheme_name"
	nameBox.Position = UDim2.fromOffset(17, 18)
	nameBox.Size = UDim2.new(1, -34, 0, 29)
	nameBox.BackgroundColor3 = colors.input
	nameBox.BorderSizePixel = 0
	nameBox.ClearTextOnFocus = false
	nameBox.Font = Enum.Font.GothamMedium
	nameBox.Text = ""
	nameBox.TextColor3 = colors.text
	nameBox.TextSize = 11
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.Parent = themeSystem.editor.body
	addCorner(nameBox, 7)
	local namePadding = Instance.new("UIPadding")
	namePadding.PaddingLeft = UDim.new(0, 11)
	namePadding.PaddingRight = UDim.new(0, 11)
	namePadding.Parent = nameBox
	themeSystem.editor.fields.name = {box = nameBox}

	local fieldDefinitions = {
		{"background", "BACKGROUND  — screen overlay"},
		{"panel", "PANEL  — main menu window"},
		{"sidebar", "SIDEBAR  — navigation column"},
		{"card", "CARDS  — cheat and theme tiles"},
		{"input", "INPUTS  — boxes and dropdowns"},
		{"accent", "PRIMARY ACCENT  — switches"},
		{"accent2", "SECONDARY ACCENT  — gradients"},
		{"text", "MAIN TEXT  — titles and labels"},
	}

	for index, definition in ipairs(fieldDefinitions) do
		local key, labelText = definition[1], definition[2]
		local button = Instance.new("TextButton")
		button.Name = "PickColor_" .. key
		button.Position = UDim2.fromOffset(17, 53 + (index - 1) * 29)
		button.Size = UDim2.new(1, -34, 0, 25)
		button.BackgroundColor3 = colors.input
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Font = Enum.Font.GothamMedium
		button.Text = labelText
		button.TextColor3 = colors.text
		button.TextSize = 8
		button.TextTruncate = Enum.TextTruncate.AtEnd
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = themeSystem.editor.body
		addCorner(button, 7)
		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0, 9)
		padding.PaddingRight = UDim.new(0, 34)
		padding.Parent = button

		local swatch = Instance.new("Frame")
		swatch.AnchorPoint = Vector2.new(1, 0.5)
		swatch.Position = UDim2.new(1, -7, 0.5, 0)
		swatch.Size = UDim2.fromOffset(16, 16)
		swatch.BackgroundColor3 = colors.accent
		swatch.BorderSizePixel = 0
		swatch:SetAttribute("ThemePreview", true)
		swatch.Parent = button
		addCorner(swatch, 5)
		local swatchStroke = Instance.new("UIStroke")
		swatchStroke.Color = Color3.fromRGB(255, 255, 255)
		swatchStroke.Transparency = 0.66
		swatchStroke.Parent = swatch

		themeSystem.editor.fields[key] = {button = button, swatch = swatch, color = colors[key]}
		button.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.selectEditorColor(key)
		end)
	end

	themeSystem.editor.selectedLabel = Instance.new("TextLabel")
	themeSystem.editor.selectedLabel.Position = UDim2.fromOffset(17, 287)
	themeSystem.editor.selectedLabel.Size = UDim2.new(1, -34, 0, 16)
	themeSystem.editor.selectedLabel.BackgroundTransparency = 1
	themeSystem.editor.selectedLabel.Font = Enum.Font.GothamBold
	themeSystem.editor.selectedLabel.Text = "PICKING PRIMARY ACCENT"
	themeSystem.editor.selectedLabel.TextColor3 = colors.accent2
	themeSystem.editor.selectedLabel.TextSize = 9
	themeSystem.editor.selectedLabel.TextXAlignment = Enum.TextXAlignment.Center
	themeSystem.editor.selectedLabel.Parent = themeSystem.editor.body

	themeSystem.editor.wheelFrame = Instance.new("Frame")
	themeSystem.editor.wheelFrame.Name = "ColorWheel"
	themeSystem.editor.wheelFrame.AnchorPoint = Vector2.new(0.5, 0)
	themeSystem.editor.wheelFrame.Position = UDim2.new(0.5, 0, 0, 305)
	themeSystem.editor.wheelFrame.Size = UDim2.fromOffset(150, 150)
	themeSystem.editor.wheelFrame.BackgroundTransparency = 1
	themeSystem.editor.wheelFrame.Parent = themeSystem.editor.body

	for segmentIndex = 0, 47 do
		local hue = segmentIndex / 48
		local angle = hue * math.pi * 2
		local segment = Instance.new("Frame")
		segment.AnchorPoint = Vector2.new(0.5, 0.5)
		segment.Position = UDim2.fromOffset(75 + math.cos(angle) * 67, 75 + math.sin(angle) * 67)
		segment.Size = UDim2.fromOffset(9, 17)
		segment.Rotation = math.deg(angle) + 90
		segment.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		segment.BorderSizePixel = 0
		segment:SetAttribute("ThemePreview", true)
		segment.Parent = themeSystem.editor.wheelFrame
		addCorner(segment, 4)
	end

	themeSystem.editor.wheelCenter = Instance.new("Frame")
	themeSystem.editor.wheelCenter.AnchorPoint = Vector2.new(0.5, 0.5)
	themeSystem.editor.wheelCenter.Position = UDim2.fromScale(0.5, 0.5)
	themeSystem.editor.wheelCenter.Size = UDim2.fromOffset(108, 108)
	themeSystem.editor.wheelCenter.BackgroundColor3 = colors.accent
	themeSystem.editor.wheelCenter.BorderSizePixel = 0
	themeSystem.editor.wheelCenter:SetAttribute("ThemePreview", true)
	themeSystem.editor.wheelCenter.Parent = themeSystem.editor.wheelFrame
	addCorner(themeSystem.editor.wheelCenter, 54)

	themeSystem.editor.wheelInput = Instance.new("TextButton")
	themeSystem.editor.wheelInput.Name = "ColorWheelInput"
	themeSystem.editor.wheelInput.Size = UDim2.fromScale(1, 1)
	themeSystem.editor.wheelInput.BackgroundTransparency = 1
	themeSystem.editor.wheelInput.Text = ""
	themeSystem.editor.wheelInput.ZIndex = 5
	themeSystem.editor.wheelInput:SetAttribute("WavePolished", true)
	themeSystem.editor.wheelInput.Parent = themeSystem.editor.wheelFrame

	themeSystem.editor.wheelMarker = Instance.new("Frame")
	themeSystem.editor.wheelMarker.AnchorPoint = Vector2.new(0.5, 0.5)
	themeSystem.editor.wheelMarker.Size = UDim2.fromOffset(10, 10)
	themeSystem.editor.wheelMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	themeSystem.editor.wheelMarker.BorderSizePixel = 0
	themeSystem.editor.wheelMarker.ZIndex = 6
	themeSystem.editor.wheelMarker.Parent = themeSystem.editor.wheelFrame
	addCorner(themeSystem.editor.wheelMarker, 5)
	local markerStroke = Instance.new("UIStroke")
	markerStroke.Color = Color3.fromRGB(20, 24, 34)
	markerStroke.Thickness = 2
	markerStroke.Parent = themeSystem.editor.wheelMarker

	themeSystem.editor.selectedRGB = Instance.new("TextLabel")
	themeSystem.editor.selectedRGB.Position = UDim2.fromOffset(17, 456)
	themeSystem.editor.selectedRGB.Size = UDim2.new(1, -34, 0, 15)
	themeSystem.editor.selectedRGB.BackgroundTransparency = 1
	themeSystem.editor.selectedRGB.Font = Enum.Font.GothamMedium
	themeSystem.editor.selectedRGB.Text = "R 0   G 0   B 0"
	themeSystem.editor.selectedRGB.TextColor3 = colors.muted
	themeSystem.editor.selectedRGB.TextSize = 8
	themeSystem.editor.selectedRGB.TextXAlignment = Enum.TextXAlignment.Center
	themeSystem.editor.selectedRGB.Parent = themeSystem.editor.body

	themeSystem.editor.brightnessInput = Instance.new("TextButton")
	themeSystem.editor.brightnessInput.Name = "BrightnessSlider"
	themeSystem.editor.brightnessInput.Position = UDim2.fromOffset(17, 475)
	themeSystem.editor.brightnessInput.Size = UDim2.new(1, -34, 0, 12)
	themeSystem.editor.brightnessInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	themeSystem.editor.brightnessInput.BorderSizePixel = 0
	themeSystem.editor.brightnessInput.Text = ""
	themeSystem.editor.brightnessInput:SetAttribute("WavePolished", true)
	themeSystem.editor.brightnessInput.Parent = themeSystem.editor.body
	addCorner(themeSystem.editor.brightnessInput, 6)
	themeSystem.editor.brightnessGradient = Instance.new("UIGradient")
	themeSystem.editor.brightnessGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), colors.accent)
	themeSystem.editor.brightnessGradient.Parent = themeSystem.editor.brightnessInput
	themeSystem.editor.brightnessMarker = Instance.new("Frame")
	themeSystem.editor.brightnessMarker.AnchorPoint = Vector2.new(0.5, 0.5)
	themeSystem.editor.brightnessMarker.Size = UDim2.fromOffset(8, 18)
	themeSystem.editor.brightnessMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	themeSystem.editor.brightnessMarker.BorderSizePixel = 0
	themeSystem.editor.brightnessMarker.Parent = themeSystem.editor.brightnessInput
	addCorner(themeSystem.editor.brightnessMarker, 4)

	themeSystem.editor.saveButton = Instance.new("TextButton")
	themeSystem.editor.saveButton.Name = "SaveCustomThemeButton"
	themeSystem.editor.saveButton.Position = UDim2.new(0, 17, 0, 501)
	themeSystem.editor.saveButton.Size = UDim2.new(0.5, -20, 0, 30)
	themeSystem.editor.saveButton.BackgroundColor3 = colors.success
	themeSystem.editor.saveButton.BorderSizePixel = 0
	themeSystem.editor.saveButton.AutoButtonColor = false
	themeSystem.editor.saveButton.Font = Enum.Font.GothamBold
	themeSystem.editor.saveButton.Text = "SAVE THEME"
	themeSystem.editor.saveButton.TextColor3 = colors.text
	themeSystem.editor.saveButton.TextSize = 9
	themeSystem.editor.saveButton.Parent = themeSystem.editor.body
	addCorner(themeSystem.editor.saveButton, 8)
	themeSystem.styleButton(themeSystem.editor.saveButton)

	themeSystem.editor.cancelButton = Instance.new("TextButton")
	themeSystem.editor.cancelButton.Name = "CancelCustomThemeButton"
	themeSystem.editor.cancelButton.Position = UDim2.new(0.5, 3, 0, 501)
	themeSystem.editor.cancelButton.Size = UDim2.new(0.5, -20, 0, 30)
	themeSystem.editor.cancelButton.BackgroundColor3 = colors.cardHover
	themeSystem.editor.cancelButton.BorderSizePixel = 0
	themeSystem.editor.cancelButton.AutoButtonColor = false
	themeSystem.editor.cancelButton.Font = Enum.Font.GothamBold
	themeSystem.editor.cancelButton.Text = "CANCEL"
	themeSystem.editor.cancelButton.TextColor3 = colors.text
	themeSystem.editor.cancelButton.TextSize = 9
	themeSystem.editor.cancelButton.Parent = themeSystem.editor.body
	addCorner(themeSystem.editor.cancelButton, 8)
	themeSystem.styleButton(themeSystem.editor.cancelButton)

	themeSystem.editor.status = Instance.new("TextLabel")
	themeSystem.editor.status.Position = UDim2.fromOffset(17, 539)
	themeSystem.editor.status.Size = UDim2.new(1, -34, 0, 18)
	themeSystem.editor.status.BackgroundTransparency = 1
	themeSystem.editor.status.Font = Enum.Font.GothamBold
	themeSystem.editor.status.Text = ""
	themeSystem.editor.status.TextColor3 = colors.accent2
	themeSystem.editor.status.TextSize = 8
	themeSystem.editor.status.TextXAlignment = Enum.TextXAlignment.Center
	themeSystem.editor.status.Parent = themeSystem.editor.body

	themeSystem.editor.wheelInput.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			themeSystem.editor.draggingWheel = true
			themeSystem.updateWheelFromPosition(input.Position)
		end
	end)
	themeSystem.editor.brightnessInput.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			themeSystem.editor.draggingBrightness = true
			themeSystem.updateBrightnessFromPosition(input.Position)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if themeSystem.editor.draggingWheel then
				themeSystem.updateWheelFromPosition(input.Position)
			elseif themeSystem.editor.draggingBrightness then
				themeSystem.updateBrightnessFromPosition(input.Position)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			themeSystem.editor.draggingWheel = false
			themeSystem.editor.draggingBrightness = false
		end
	end)

	themeSystem.editor.createButton.Activated:Connect(function()
		playSound(clickSound)
		if themeSystem.editor.open then
			themeSystem.setEditorOpen(false)
		else
			themeSystem.loadEditor(nil, false)
		end
	end)
	themeSystem.editor.saveButton.Activated:Connect(function()
		playSound(clickSound)
		themeSystem.saveEditor()
	end)
	themeSystem.editor.cancelButton.Activated:Connect(function()
		playSound(clickSound)
		themeSystem.setEditorOpen(false)
	end)
end

themeSystem.buildEditor()

local flyToggle = Instance.new("TextButton")
flyToggle.Name = "FlyToggle"
flyToggle.AnchorPoint = Vector2.new(1, 0.5)
flyToggle.Position = UDim2.new(1, -17, 0, 49)
flyToggle.Size = UDim2.fromOffset(44, 24)
flyToggle.BackgroundColor3 = colors.switchOff
flyToggle.BorderSizePixel = 0
flyToggle.AutoButtonColor = false
flyToggle.Text = ""
flyToggle.Parent = flyCard
addCorner(flyToggle, 12)

local flyKnob = Instance.new("Frame")
flyKnob.Name = "Knob"
flyKnob.AnchorPoint = Vector2.new(0, 0.5)
flyKnob.Position = UDim2.new(0, 3, 0.5, 0)
flyKnob.Size = UDim2.fromOffset(18, 18)
flyKnob.BackgroundColor3 = Color3.fromRGB(231, 238, 250)
flyKnob.BorderSizePixel = 0
flyKnob.Parent = flyToggle
addCorner(flyKnob, 9)

local flyStatus = Instance.new("TextLabel")
flyStatus.Name = "Status"
flyStatus.Position = UDim2.fromOffset(17, 62)
flyStatus.Size = UDim2.new(1, -80, 0, 16)
flyStatus.BackgroundTransparency = 1
flyStatus.Font = Enum.Font.Gotham
flyStatus.Text = "OFF"
flyStatus.TextColor3 = colors.faint
flyStatus.TextSize = 9
flyStatus.TextXAlignment = Enum.TextXAlignment.Left
flyStatus.Parent = flyCard

local godToggle = Instance.new("TextButton")
godToggle.Name = "GodModeToggle"
godToggle.AnchorPoint = Vector2.new(1, 0.5)
godToggle.Position = UDim2.new(1, -17, 0, 49)
godToggle.Size = UDim2.fromOffset(44, 24)
godToggle.BackgroundColor3 = colors.switchOff
godToggle.BorderSizePixel = 0
godToggle.AutoButtonColor = false
godToggle.Text = ""
godToggle.Parent = godCard
addCorner(godToggle, 12)

local godKnob = Instance.new("Frame")
godKnob.Name = "Knob"
godKnob.AnchorPoint = Vector2.new(0, 0.5)
godKnob.Position = UDim2.new(0, 3, 0.5, 0)
godKnob.Size = UDim2.fromOffset(18, 18)
godKnob.BackgroundColor3 = Color3.fromRGB(231, 238, 250)
godKnob.BorderSizePixel = 0
godKnob.Parent = godToggle
addCorner(godKnob, 9)

local godStatus = Instance.new("TextLabel")
godStatus.Name = "Status"
godStatus.Position = UDim2.fromOffset(17, 62)
godStatus.Size = UDim2.new(1, -80, 0, 16)
godStatus.BackgroundTransparency = 1
godStatus.Font = Enum.Font.Gotham
godStatus.Text = "OFF"
godStatus.TextColor3 = colors.faint
godStatus.TextSize = 9
godStatus.TextXAlignment = Enum.TextXAlignment.Left
godStatus.Parent = godCard

local function createSwitch(card, name)
	local switch = Instance.new("TextButton")
	switch.Name = name .. "Toggle"
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -17, 0, 49)
	switch.Size = UDim2.fromOffset(44, 24)
	switch.BackgroundColor3 = colors.switchOff
	switch.BorderSizePixel = 0
	switch.AutoButtonColor = false
	switch.Text = ""
	switch.Parent = card
	addCorner(switch, 12)

	local switchKnob = Instance.new("Frame")
	switchKnob.Name = "Knob"
	switchKnob.AnchorPoint = Vector2.new(0, 0.5)
	switchKnob.Position = UDim2.new(0, 3, 0.5, 0)
	switchKnob.Size = UDim2.fromOffset(18, 18)
	switchKnob.BackgroundColor3 = Color3.fromRGB(231, 238, 250)
	switchKnob.BorderSizePixel = 0
	switchKnob.Parent = switch
	addCorner(switchKnob, 9)

	local switchStatus = Instance.new("TextLabel")
	switchStatus.Name = "Status"
	switchStatus.Position = UDim2.fromOffset(17, 62)
	switchStatus.Size = UDim2.new(1, -80, 0, 16)
	switchStatus.BackgroundTransparency = 1
	switchStatus.Font = Enum.Font.Gotham
	switchStatus.Text = "OFF"
	switchStatus.TextColor3 = colors.faint
	switchStatus.TextSize = 9
	switchStatus.TextXAlignment = Enum.TextXAlignment.Left
	switchStatus.Parent = card
	return switch, switchKnob, switchStatus
end

local switchUI = {
	vehicleFly = {},
	fullBright = {},
	float = {},
	infiniteJump = {},
	esp = {},
	aimbot = {},
	triggerBot = {},
	fieldOfView = {},
	invisibility = {},
		walkfling = {},
		healthDisplay = {},
		waveTags = {},
		instantPrompts = {},
		coordinates = {},
		autoSell = {},
		playerTrails = {},
		activeHud = {},
	zoom = {},
	teleportClick = {},
	freeze = {},
}
switchUI.vehicleFly[1], switchUI.vehicleFly[2], switchUI.vehicleFly[3] = createSwitch(vehicleFlyCard, "VehicleFly")
switchUI.fullBright[1], switchUI.fullBright[2], switchUI.fullBright[3] = createSwitch(fullBrightCard, "FullBright")
local freecamUI = {}
freecamUI[1], freecamUI[2], freecamUI[3] = createSwitch(freecamCard, "Freecam")
switchUI.zoom[1], switchUI.zoom[2], switchUI.zoom[3] = createSwitch(zoom.card, "Zoom")
switchUI.teleportClick[1], switchUI.teleportClick[2], switchUI.teleportClick[3] = createSwitch(teleportClick.card, "ClickTeleport")
switchUI.freeze[1], switchUI.freeze[2], switchUI.freeze[3] = createSwitch(freeze.card, "Freeze")
switchUI.float[1], switchUI.float[2], switchUI.float[3] = createSwitch(floatCard, "Float")
switchUI.infiniteJump[1], switchUI.infiniteJump[2], switchUI.infiniteJump[3] = createSwitch(infiniteJumpCard, "InfiniteJump")
switchUI.esp[1], switchUI.esp[2], switchUI.esp[3] = createSwitch(espCard, "ESP")
switchUI.aimbot[1], switchUI.aimbot[2], switchUI.aimbot[3] = createSwitch(themeSystem.aimbot.card, "Aimbot")
switchUI.triggerBot[1], switchUI.triggerBot[2], switchUI.triggerBot[3] = createSwitch(themeSystem.triggerBot.card, "TriggerBot")
switchUI.fieldOfView[1], switchUI.fieldOfView[2], switchUI.fieldOfView[3] = createSwitch(fieldOfView.card, "FieldOfView")
switchUI.invisibility[1], switchUI.invisibility[2], switchUI.invisibility[3] = createSwitch(invisibility.card, "Invisibility")
switchUI.walkfling[1], switchUI.walkfling[2], switchUI.walkfling[3] = createSwitch(walkfling.card, "Walkfling")
switchUI.healthDisplay[1], switchUI.healthDisplay[2], switchUI.healthDisplay[3] = createSwitch(themeSystem.healthDisplay.card, "HealthDisplay")
switchUI.waveTags[1], switchUI.waveTags[2], switchUI.waveTags[3] = createSwitch(themeSystem.waveTags.card, "WaveTags")
switchUI.instantPrompts[1], switchUI.instantPrompts[2], switchUI.instantPrompts[3] = createSwitch(themeSystem.instantPrompts.card, "InstantPrompts")
switchUI.coordinates[1], switchUI.coordinates[2], switchUI.coordinates[3] = createSwitch(themeSystem.coordinates.card, "ShowCoordinates")
switchUI.autoSell[1], switchUI.autoSell[2], switchUI.autoSell[3] = createSwitch(themeSystem.autoSell.card, "AutoSell")
switchUI.playerTrails[1], switchUI.playerTrails[2], switchUI.playerTrails[3] = createSwitch(themeSystem.playerTrails.card, "PlayerTrails")
switchUI.activeHud[1], switchUI.activeHud[2], switchUI.activeHud[3] = createSwitch(settings.activeHudCard, "ActiveHud")

local espDropdownButton = Instance.new("TextButton")
espDropdownButton.Name = "DropdownButton"
espDropdownButton.AnchorPoint = Vector2.new(1, 0.5)
espDropdownButton.Position = UDim2.new(1, -70, 0, 49)
espDropdownButton.Size = UDim2.fromOffset(28, 24)
espDropdownButton.BackgroundColor3 = colors.input
espDropdownButton.BorderSizePixel = 0
espDropdownButton.AutoButtonColor = false
espDropdownButton.Font = Enum.Font.GothamBold
espDropdownButton.Text = "v"
espDropdownButton.TextColor3 = colors.muted
espDropdownButton.TextSize = 12
espDropdownButton.Parent = espCard
addCorner(espDropdownButton, 7)

local nametagRow = Instance.new("Frame")
nametagRow.Name = "NametagRow"
nametagRow.Position = UDim2.fromOffset(17, 88)
nametagRow.Size = UDim2.new(1, -34, 0, 60)
nametagRow.BackgroundColor3 = colors.input
nametagRow.BorderSizePixel = 0
nametagRow.Visible = false
nametagRow.Parent = espCard
addCorner(nametagRow, 8)

local nametagTitle = Instance.new("TextLabel")
nametagTitle.Position = UDim2.fromOffset(12, 8)
nametagTitle.Size = UDim2.new(1, -76, 0, 18)
nametagTitle.BackgroundTransparency = 1
nametagTitle.Font = Enum.Font.GothamMedium
nametagTitle.Text = "Nametags"
nametagTitle.TextColor3 = colors.text
nametagTitle.TextSize = 11
nametagTitle.TextXAlignment = Enum.TextXAlignment.Left
nametagTitle.Parent = nametagRow

local nametagDescription = Instance.new("TextLabel")
nametagDescription.Position = UDim2.fromOffset(12, 29)
nametagDescription.Size = UDim2.new(1, -76, 0, 18)
nametagDescription.BackgroundTransparency = 1
nametagDescription.Font = Enum.Font.Gotham
nametagDescription.Text = "Show player name and distance."
nametagDescription.TextColor3 = colors.muted
nametagDescription.TextSize = 9
nametagDescription.TextXAlignment = Enum.TextXAlignment.Left
nametagDescription.Parent = nametagRow

local nametagToggle = Instance.new("TextButton")
nametagToggle.Name = "NametagToggle"
nametagToggle.AnchorPoint = Vector2.new(1, 0.5)
nametagToggle.Position = UDim2.new(1, -10, 0, 28)
nametagToggle.Size = UDim2.fromOffset(44, 24)
nametagToggle.BackgroundColor3 = colors.input
nametagToggle.BorderSizePixel = 0
nametagToggle.AutoButtonColor = false
nametagToggle.Text = ""
nametagToggle.Parent = nametagRow
addCorner(nametagToggle, 12)

local nametagKnob = Instance.new("Frame")
nametagKnob.Name = "Knob"
nametagKnob.AnchorPoint = Vector2.new(0, 0.5)
nametagKnob.Position = UDim2.new(0, 3, 0.5, 0)
nametagKnob.Size = UDim2.fromOffset(18, 18)
nametagKnob.BackgroundColor3 = colors.faint
nametagKnob.BorderSizePixel = 0
nametagKnob.Parent = nametagToggle
addCorner(nametagKnob, 9)

local nametagStatus = Instance.new("TextLabel")
nametagStatus.AnchorPoint = Vector2.new(1, 0)
nametagStatus.Position = UDim2.new(1, -12, 0, 45)
nametagStatus.Size = UDim2.fromOffset(56, 12)
nametagStatus.BackgroundTransparency = 1
nametagStatus.Font = Enum.Font.Gotham
nametagStatus.Text = "LOCKED"
nametagStatus.TextColor3 = colors.faint
nametagStatus.TextSize = 8
nametagStatus.TextXAlignment = Enum.TextXAlignment.Right
nametagStatus.Parent = nametagRow

local toggle = Instance.new("TextButton")
toggle.Name = "NoclipToggle"
toggle.AnchorPoint = Vector2.new(1, 0.5)
toggle.Position = UDim2.new(1, -17, 0, 49)
toggle.Size = UDim2.fromOffset(44, 24)
toggle.BackgroundColor3 = colors.switchOff
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = false
toggle.Text = ""
toggle.Parent = utilityCard
addCorner(toggle, 12)

local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.AnchorPoint = Vector2.new(0, 0.5)
knob.Position = UDim2.new(0, 3, 0.5, 0)
knob.Size = UDim2.fromOffset(18, 18)
knob.BackgroundColor3 = Color3.fromRGB(231, 238, 250)
knob.BorderSizePixel = 0
knob.Parent = toggle
addCorner(knob, 9)

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Position = UDim2.fromOffset(17, 62)
status.Size = UDim2.new(1, -80, 0, 16)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "OFF"
status.TextColor3 = colors.faint
status.TextSize = 9
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = utilityCard

local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.Position = UDim2.fromOffset(28, 8)
hint.Size = UDim2.new(1, -56, 0, 18)
hint.BackgroundTransparency = 1
hint.Font = Enum.Font.Gotham
hint.Text = "FIVE FOCUSED CATEGORIES  •  SEARCH ANY TAB  •  KEYBINDS ON EVERY ACTION"
hint.TextColor3 = colors.faint
hint.TextSize = 10
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = main

local function showTabLegacy(tabName)
	local tabChanged = activeTabName ~= tabName
	activeTabName = tabName
	if tabChanged then
		content.CanvasPosition = Vector2.zero
	end
	if tabName ~= "Home" and gotoPlayer.setOpen then
		gotoPlayer.setOpen(false)
	end
	if tabName ~= "Home" and spectate.setOpen then
		spectate.setOpen(false)
	end
	if tabName ~= "Home" and themeSystem.playerInspector.setOpen then
		themeSystem.playerInspector.setOpen(false)
	end
	if themeSystem.setCardsVisible then
		themeSystem.setCardsVisible(tabName == "Themes")
	end
	if presetSystem.setCardsVisible then
		presetSystem.setCardsVisible(tabName == "Presets")
	end
	if themeSystem.favoriteSystem.setCardsVisible then
		themeSystem.favoriteSystem.setCardsVisible(tabName == "Favorites")
	end
	if themeSystem.waypoints.setCardsVisible then
		themeSystem.waypoints.setCardsVisible(tabName == "Waypoints")
	end
	settings.textCard.Visible = tabName == "Settings"
	settings.ctrlCard.Visible = tabName == "Settings"
	settings.activeHudCard.Visible = tabName == "Settings"
	fieldOfView.card.Visible = tabName == "Home"
	invisibility.card.Visible = tabName == "Home"
	walkfling.card.Visible = tabName == "Home"
	themeSystem.healthDisplay.card.Visible = tabName == "Home"
	themeSystem.waveTags.card.Visible = tabName == "Home"
	themeSystem.instantPrompts.card.Visible = tabName == "Home"
	themeSystem.coordinates.card.Visible = tabName == "Home"
	themeSystem.autoSell.card.Visible = tabName == "Home"
	themeSystem.randomize.card.Visible = tabName == "Home"
	themeSystem.playerTrails.card.Visible = tabName == "Home"
	themeSystem.playerInspector.card.Visible = tabName == "Home"
	for name, tab in pairs(tabs) do
		local selected = name == tabName
		tab.BackgroundColor3 = selected and colors.accentSoft or colors.sidebar
		tab.TextColor3 = selected and colors.text or colors.muted
	end
	local targetPosition = UDim2.fromOffset(14, 111 + (tabIndexes[tabName] - 1) * 38)
	TweenService:Create(selectionBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPosition}):Play()
	if tabName == "Home" then
		title.Text = "Home"
		subtitle.Text = "Access your admin cheats and character controls."
		speedCard.Visible = true
		jumpCard.Visible = true
		gravityCard.Visible = true
		utilityCard.Visible = true
		flyCard.Visible = true
		godCard.Visible = true
		vehicleFlyCard.Visible = true
		fullBrightCard.Visible = true
		freecamCard.Visible = true
		zoom.card.Visible = true
		teleportClick.card.Visible = true
		gotoPlayer.card.Visible = true
		spectate.card.Visible = true
		leave.card.Visible = true
		rejoin.card.Visible = true
		serverHop.card.Visible = true
		freeze.card.Visible = true
		spin.card.Visible = true
		floatCard.Visible = true
		infiniteJumpCard.Visible = true
		espCard.Visible = true
		creditsCard.Visible = false
		changesCard.Visible = false
	elseif tabName == "Waypoints" then
		title.Text = "Waypoints"
		subtitle.Text = "Save, customize, and travel to your favorite locations."
		speedCard.Visible = false
		jumpCard.Visible = false
		gravityCard.Visible = false
		utilityCard.Visible = false
		flyCard.Visible = false
		godCard.Visible = false
		vehicleFlyCard.Visible = false
		fullBrightCard.Visible = false
		freecamCard.Visible = false
		zoom.card.Visible = false
		teleportClick.card.Visible = false
		gotoPlayer.card.Visible = false
		spectate.card.Visible = false
		leave.card.Visible = false
		rejoin.card.Visible = false
		serverHop.card.Visible = false
		freeze.card.Visible = false
		spin.card.Visible = false
		floatCard.Visible = false
		infiniteJumpCard.Visible = false
		espCard.Visible = false
		creditsCard.Visible = false
		changesCard.Visible = false
	elseif tabName == "Favorites" then
		title.Text = "Favorites"
		subtitle.Text = "Your favorite cheats, waypoints, themes, and presets in one place."
		speedCard.Visible = false
		jumpCard.Visible = false
		gravityCard.Visible = false
		utilityCard.Visible = false
		flyCard.Visible = false
		godCard.Visible = false
		vehicleFlyCard.Visible = false
		fullBrightCard.Visible = false
		freecamCard.Visible = false
		zoom.card.Visible = false
		teleportClick.card.Visible = false
		gotoPlayer.card.Visible = false
		spectate.card.Visible = false
		leave.card.Visible = false
		rejoin.card.Visible = false
		serverHop.card.Visible = false
		freeze.card.Visible = false
		spin.card.Visible = false
		floatCard.Visible = false
		infiniteJumpCard.Visible = false
		espCard.Visible = false
		creditsCard.Visible = false
		changesCard.Visible = false
	elseif tabName == "Themes" then
		title.Text = "Themes"
		subtitle.Text = "Scroll through styles and apply one instantly."
		speedCard.Visible = false
		jumpCard.Visible = false
		gravityCard.Visible = false
		utilityCard.Visible = false
		flyCard.Visible = false
		godCard.Visible = false
		vehicleFlyCard.Visible = false
		fullBrightCard.Visible = false
		freecamCard.Visible = false
		zoom.card.Visible = false
		teleportClick.card.Visible = false
		gotoPlayer.card.Visible = false
		spectate.card.Visible = false
		leave.card.Visible = false
		rejoin.card.Visible = false
		serverHop.card.Visible = false
		freeze.card.Visible = false
		spin.card.Visible = false
		floatCard.Visible = false
		infiniteJumpCard.Visible = false
		espCard.Visible = false
		creditsCard.Visible = false
		changesCard.Visible = false
	elseif tabName == "Presets" then
		title.Text = "Presets"
		subtitle.Text = "Save and restore cheat setups with their active theme."
		speedCard.Visible = false
		jumpCard.Visible = false
		gravityCard.Visible = false
		utilityCard.Visible = false
		flyCard.Visible = false
		godCard.Visible = false
		vehicleFlyCard.Visible = false
		fullBrightCard.Visible = false
		freecamCard.Visible = false
		zoom.card.Visible = false
		teleportClick.card.Visible = false
		gotoPlayer.card.Visible = false
		spectate.card.Visible = false
		leave.card.Visible = false
		rejoin.card.Visible = false
		serverHop.card.Visible = false
		freeze.card.Visible = false
		spin.card.Visible = false
		floatCard.Visible = false
		infiniteJumpCard.Visible = false
		espCard.Visible = false
		creditsCard.Visible = false
		changesCard.Visible = false
	elseif tabName == "Settings" then
		title.Text = "Settings"
		subtitle.Text = "Adjust menu readability and controls."
		speedCard.Visible = false
		jumpCard.Visible = false
		gravityCard.Visible = false
		utilityCard.Visible = false
		flyCard.Visible = false
		godCard.Visible = false
		vehicleFlyCard.Visible = false
		fullBrightCard.Visible = false
		freecamCard.Visible = false
		zoom.card.Visible = false
		teleportClick.card.Visible = false
		gotoPlayer.card.Visible = false
		spectate.card.Visible = false
		leave.card.Visible = false
		rejoin.card.Visible = false
		serverHop.card.Visible = false
		freeze.card.Visible = false
		spin.card.Visible = false
		floatCard.Visible = false
		infiniteJumpCard.Visible = false
		espCard.Visible = false
		creditsCard.Visible = false
		changesCard.Visible = false
	elseif tabName == "Credits" then
		title.Text = "Credits"
		subtitle.Text = "People and tools behind this menu."
		speedCard.Visible = false
		jumpCard.Visible = false
		gravityCard.Visible = false
		utilityCard.Visible = false
		flyCard.Visible = false
		godCard.Visible = false
		vehicleFlyCard.Visible = false
		fullBrightCard.Visible = false
		freecamCard.Visible = false
		zoom.card.Visible = false
		teleportClick.card.Visible = false
		gotoPlayer.card.Visible = false
		spectate.card.Visible = false
		leave.card.Visible = false
		rejoin.card.Visible = false
		serverHop.card.Visible = false
		freeze.card.Visible = false
		spin.card.Visible = false
		floatCard.Visible = false
		infiniteJumpCard.Visible = false
		espCard.Visible = false
		creditsCard.Visible = true
		changesCard.Visible = false
	else
		title.Text = "Changes"
		subtitle.Text = "Current release information."
		speedCard.Visible = false
		jumpCard.Visible = false
		gravityCard.Visible = false
		utilityCard.Visible = false
		flyCard.Visible = false
		godCard.Visible = false
		vehicleFlyCard.Visible = false
		fullBrightCard.Visible = false
		freecamCard.Visible = false
		zoom.card.Visible = false
		teleportClick.card.Visible = false
		gotoPlayer.card.Visible = false
		spectate.card.Visible = false
		leave.card.Visible = false
		rejoin.card.Visible = false
		serverHop.card.Visible = false
		freeze.card.Visible = false
		spin.card.Visible = false
		floatCard.Visible = false
		infiniteJumpCard.Visible = false
		espCard.Visible = false
		creditsCard.Visible = false
		changesCard.Visible = true
	end
	if themeSystem.searchSystem.updateLayout then
		if tabChanged and themeSystem.searchSystem.box then
			themeSystem.searchSystem.box.Text = ""
		end
		themeSystem.searchSystem.updateLayout()
		themeSystem.searchSystem.apply()
	end
	if themeSystem.animateVisibleCards then
		themeSystem.animateVisibleCards()
	end
end

local function showTab(tabName)
	local aliases = {
		Home = "Movement", Waypoints = "Utility", Favorites = "Customize", Themes = "Customize",
		Presets = "Customize", Settings = "Customize", Credits = "Customize", Changes = "Customize",
	}
	tabName = aliases[tabName] or tabName
	if not tabIndexes[tabName] then tabName = "Movement" end
	local tabChanged = activeTabName ~= tabName
	activeTabName = tabName
	if tabChanged then content.CanvasPosition = Vector2.zero end
	if gotoPlayer.setOpen then gotoPlayer.setOpen(false) end
	if spectate.setOpen then spectate.setOpen(false) end
	if themeSystem.playerInspector.setOpen then themeSystem.playerInspector.setOpen(false) end

	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("Frame") then child.Visible = false end
	end
	local customize = tabName == "Customize"
	if themeSystem.setCardsVisible then themeSystem.setCardsVisible(customize) end
	if presetSystem.setCardsVisible then presetSystem.setCardsVisible(customize) end
	if themeSystem.favoriteSystem.setCardsVisible then themeSystem.favoriteSystem.setCardsVisible(customize) end
	if themeSystem.waypoints.setCardsVisible then themeSystem.waypoints.setCardsVisible(tabName == "Movement" or tabName == "Utility") end
	settings.textCard.Visible = customize
	settings.ctrlCard.Visible = customize
	settings.activeHudCard.Visible = customize
	creditsCard.Visible = customize
	changesCard.Visible = customize

	local cardsByTab = {
		Movement = {speedCard, jumpCard, gravityCard, utilityCard, flyCard, vehicleFlyCard, floatCard, infiniteJumpCard, teleportClick.card, gotoPlayer.card, freeze.card},
		Visuals = {fullBrightCard, freecamCard, zoom.card, fieldOfView.card, espCard, themeSystem.healthDisplay.card, themeSystem.waveTags.card, themeSystem.coordinates.card, themeSystem.playerTrails.card, spectate.card},
		Combat = {themeSystem.panic.card, godCard, freeze.card, spin.card, themeSystem.aimbot.card, themeSystem.triggerBot.card, invisibility.card, walkfling.card, espCard, themeSystem.healthDisplay.card, themeSystem.playerInspector.card},
		Utility = {themeSystem.panic.card, teleportClick.card, gotoPlayer.card, spectate.card, themeSystem.playerInspector.card, themeSystem.instantPrompts.card, themeSystem.autoSell.card, themeSystem.randomize.card, leave.card, rejoin.card, serverHop.card, themeSystem.coordinates.card},
	}
	for _, card in ipairs(cardsByTab[tabName] or {}) do card.Visible = true end

	if customize then
		settings.textCard.LayoutOrder = 0
		settings.ctrlCard.LayoutOrder = 1
		settings.activeHudCard.LayoutOrder = 2
		for index, card in ipairs(themeSystem.favoriteSystem.displayCards or {}) do card.LayoutOrder = 20 + index end
		if themeSystem.favoriteSystem.emptyCard then themeSystem.favoriteSystem.emptyCard.LayoutOrder = 20 end
		if presetSystem.builder then presetSystem.builder.LayoutOrder = 200 end
		for index, card in ipairs(presetSystem.cards or {}) do card.LayoutOrder = 210 + index end
		if themeSystem.editor and themeSystem.editor.card then themeSystem.editor.card.LayoutOrder = 400 end
		for _, themeCard in pairs(themeSystem.cards or {}) do themeCard.card.LayoutOrder = 410 + (themeCard.card:GetAttribute("WaveOriginalOrder") or 0) end
		creditsCard.LayoutOrder = 900
		changesCard.LayoutOrder = 901
	end
	if tabName == "Movement" or tabName == "Utility" then
		themeSystem.waypoints.builder.LayoutOrder = 200
		for index, card in ipairs(themeSystem.waypoints.cards or {}) do card.LayoutOrder = 210 + index end
	end

	for name, tab in pairs(tabs) do
		local selected = name == tabName
		tab.BackgroundColor3 = selected and colors.accentSoft or colors.sidebar
		tab.TextColor3 = selected and colors.text or colors.muted
		local dot = tab:FindFirstChild("CategoryDot")
		if dot then TweenService:Create(dot, TweenInfo.new(0.18), {BackgroundTransparency = selected and 0 or 0.58}):Play() end
	end
	TweenService:Create(selectionBar, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(14, 112 + (tabIndexes[tabName] - 1) * 46),
	}):Play()
	local headings = {
		Movement = {"Movement", "Movement, flight, and travel controls."},
		Visuals = {"Visuals", "Camera, lighting, awareness, and display tools."},
		Combat = {"Combat", "Targeting, protection, and character combat tools."},
		Utility = {"Utility", "Players, waypoints, automation, safety, and server actions."},
		Customize = {"Customize", "Favorites, presets, themes, settings, and your WAVE credits."},
	}
	title.Text = headings[tabName][1]
	subtitle.Text = headings[tabName][2]
	if themeSystem.searchSystem.box then themeSystem.searchSystem.box.PlaceholderText = "Search " .. string.lower(tabName) .. "..." end
	if themeSystem.searchSystem.updateLayout then
		if tabChanged and themeSystem.searchSystem.box then themeSystem.searchSystem.box.Text = "" end
		themeSystem.searchSystem.updateLayout()
		themeSystem.searchSystem.apply()
	end
	if themeSystem.animateVisibleCards then themeSystem.animateVisibleCards() end
end

function settings.applyTextToInstance(instance)
	if not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) or instance.TextScaled then
		return
	end
	local baseSize = instance:GetAttribute("WaveBaseTextSize")
	if type(baseSize) ~= "number" then
		baseSize = instance.TextSize
		instance:SetAttribute("WaveBaseTextSize", baseSize)
	end
	instance.TextSize = math.clamp(math.floor(baseSize * settings.textScale + 0.5), 6, 36)
end

function settings.setTextScale(value)
	settings.textScale = math.clamp(math.floor((value / 0.05) + 0.5) * 0.05, 0.75, 1.5)
	local alpha = (settings.textScale - 0.75) / 0.75
	settings.textFill.Size = UDim2.new(alpha, 0, 1, 0)
	settings.textKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
	settings.textValue.Text = string.format("%d%%", math.floor(settings.textScale * 100 + 0.5))
	for _, instance in ipairs(screenGui:GetDescendants()) do
		settings.applyTextToInstance(instance)
	end
end

function settings.setCtrlHoldSeconds(value)
	settings.ctrlHoldSeconds = math.clamp(math.floor((value / 0.25) + 0.5) * 0.25, 0.5, 5)
	local alpha = (settings.ctrlHoldSeconds - 0.5) / 4.5
	settings.ctrlFill.Size = UDim2.new(alpha, 0, 1, 0)
	settings.ctrlKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
	local formatted = string.format("%.2f", settings.ctrlHoldSeconds):gsub("0+$", ""):gsub("%.$", "")
	settings.ctrlValue.Text = formatted .. (settings.ctrlHoldSeconds == 1 and " SECOND" or " SECONDS")
	sidebarFooter.Text = "HOLD CTRL " .. formatted .. " SEC OR DOUBLE TAP  •  TAP TO CLOSE"
end

function settings.updateSlider(kind, input)
	local track = kind == "text" and settings.textTrack or settings.ctrlTrack
	if track.AbsoluteSize.X <= 0 then
		return
	end
	local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
	if kind == "text" then
		settings.setTextScale(0.75 + alpha * 0.75)
	else
		settings.setCtrlHoldSeconds(0.5 + alpha * 4.5)
	end
end

function settings.beginSlider(kind, input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		settings.dragging = kind
		settings.updateSlider(kind, input)
	end
end

settings.textTrack.InputBegan:Connect(function(input)
	settings.beginSlider("text", input)
end)
settings.textKnob.InputBegan:Connect(function(input)
	settings.beginSlider("text", input)
end)
settings.ctrlTrack.InputBegan:Connect(function(input)
	settings.beginSlider("ctrl", input)
end)
settings.ctrlKnob.InputBegan:Connect(function(input)
	settings.beginSlider("ctrl", input)
end)
UserInputService.InputChanged:Connect(function(input)
	if settings.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		settings.updateSlider(settings.dragging, input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		settings.dragging = nil
	end
end)
screenGui.DescendantAdded:Connect(function(instance)
	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		task.defer(function()
			if instance.Parent then
				settings.applyTextToInstance(instance)
			end
		end)
	end
end)
settings.setTextScale(1)
settings.setCtrlHoldSeconds(0.5)

local function applySpeed()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local speed = tonumber(speedBox.Text)
	if humanoid and speed then
		humanoid.WalkSpeed = math.max(0, speed)
		speedBox.Text = tostring(humanoid.WalkSpeed)
	end
end

local function applyJump()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local jumpValue = tonumber(jumpBox.Text)
	if humanoid and jumpValue then
		humanoid.UseJumpPower = gameDefaults.useJumpPower
		if gameDefaults.useJumpPower then
			humanoid.JumpPower = math.max(0, jumpValue)
			jumpBox.Text = tostring(humanoid.JumpPower)
		else
			humanoid.JumpHeight = math.max(0, jumpValue)
			jumpBox.Text = tostring(humanoid.JumpHeight)
		end
	end
end

local function setGravity(value)
	gravityValue = math.clamp(value, -100, 1000)
	workspace.Gravity = gravityValue
	local alpha = (gravityValue + 100) / 1100
	gravityFill.Size = UDim2.new(alpha, 0, 1, 0)
	gravityKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
	gravityLabel.Text = string.format("%.1f", gravityValue)
end

local function applyCharacterSettings()
	applySpeed()
	applyJump()
	setGravity(gravityValue)
end

for tabName, tab in pairs(tabs) do
	tab.Activated:Connect(function()
		playSound(clickSound)
		showTab(tabName)
	end)
end

speedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		applySpeed()
	end
end)

jumpBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		applyJump()
	end
end)

local gravityDragging = false
local gravityTouchInput

local function updateGravityFromInput(input)
	if gravityTrack.AbsoluteSize.X <= 0 then
		return
	end
	local relativeX = math.clamp(input.Position.X - gravityTrack.AbsolutePosition.X, 0, gravityTrack.AbsoluteSize.X)
	local alpha = relativeX / gravityTrack.AbsoluteSize.X
	setGravity(-100 + alpha * 1100)
end

local function beginGravityDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		gravityDragging = true
		gravityTouchInput = nil
		updateGravityFromInput(input)
	elseif input.UserInputType == Enum.UserInputType.Touch then
		gravityDragging = true
		gravityTouchInput = input
		updateGravityFromInput(input)
	end
end

gravityTrack.InputBegan:Connect(function(input)
	beginGravityDrag(input)
end)

gravityKnob.InputBegan:Connect(function(input)
	beginGravityDrag(input)
end)

UserInputService.InputChanged:Connect(function(input)
	if not gravityDragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input == gravityTouchInput then
		updateGravityFromInput(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == gravityTouchInput then
		gravityDragging = false
		gravityTouchInput = nil
	end
end)

player.CharacterAdded:Connect(function()
	task.wait()
	applyCharacterSettings()
end)

local function setNoclipVisual(enabled)
	local target = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	local color = enabled and colors.accent or colors.switchOff
	status.Text = enabled and "ON" or "OFF"
	status.TextColor3 = enabled and colors.success or colors.faint
	TweenService:Create(knob, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = target, Rotation = enabled and 360 or 0}):Play()
	TweenService:Create(toggle, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = color}):Play()
end

local noclipEnabled = false
local noclipConnection
local characterCollisionStates = {}

local function setCharacterCollision(noclipping)
	local character = player.Character
	if not character then
		return
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if noclipping then
				if characterCollisionStates[descendant] == nil then
					characterCollisionStates[descendant] = descendant.CanCollide
				end
				descendant.CanCollide = false
			elseif characterCollisionStates[descendant] ~= nil then
				descendant.CanCollide = characterCollisionStates[descendant]
			end
		end
	end

	if not noclipping then
		table.clear(characterCollisionStates)
	end
end

local function setWallNoclip(enabled)
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	setCharacterCollision(false)
	if not enabled then
		return
	end

	setCharacterCollision(true)
	noclipConnection = RunService.Stepped:Connect(function()
		if noclipEnabled then
			setCharacterCollision(true)
		end
	end)
end

toggle.Activated:Connect(function()
	playSound(clickSound)
	noclipEnabled = not noclipEnabled
	setNoclipVisual(noclipEnabled)
	setWallNoclip(noclipEnabled)
end)

local flyEnabled = false
local flyConnection
local flyVelocity
local flyGyro
local flySavedState

local function setFlyVisual(enabled)
	local target = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	local color = enabled and colors.accent or colors.switchOff
	flyStatus.Text = enabled and "ON" or "OFF"
	flyStatus.TextColor3 = enabled and colors.success or colors.faint
	TweenService:Create(flyKnob, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = target, Rotation = enabled and 360 or 0}):Play()
	TweenService:Create(flyToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = color}):Play()
end

local function stopFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if flyVelocity then
		flyVelocity:Destroy()
		flyVelocity = nil
	end
	if flyGyro then
		flyGyro:Destroy()
		flyGyro = nil
	end
	if flySavedState then
		if flySavedState.rootPart and flySavedState.rootPart.Parent then
			flySavedState.rootPart.AssemblyLinearVelocity = flySavedState.linearVelocity
			flySavedState.rootPart.AssemblyAngularVelocity = flySavedState.angularVelocity
		end
		flySavedState = nil
	end
end

local function setFly(enabled)
	stopFly()
	if not enabled then
		flyEnabled = false
		setFlyVisual(false)
		return
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then
		flyEnabled = false
		setFlyVisual(false)
		return
	end

	flyEnabled = true
	flySavedState = {
		rootPart = rootPart,
		linearVelocity = rootPart.AssemblyLinearVelocity,
		angularVelocity = rootPart.AssemblyAngularVelocity,
	}
	flyVelocity = Instance.new("BodyVelocity")
	flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyVelocity.Velocity = Vector3.zero
	flyVelocity.Parent = rootPart

	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	flyGyro.P = 10000
	flyGyro.CFrame = rootPart.CFrame
	flyGyro.Parent = rootPart

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flyEnabled or not rootPart.Parent then
			setFly(false)
			return
		end
		local camera = workspace.CurrentCamera
		local direction = humanoid.MoveDirection
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			vertical += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			vertical -= 1
		end
		local cameraDirection = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
		local cameraRight = camera and camera.CFrame.RightVector or Vector3.new(1, 0, 0)
		local forwardInput = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
		forwardInput -= UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
		local rightInput = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
		rightInput -= UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0
		local movementDirection = cameraDirection * forwardInput + cameraRight * rightInput
		local movement = Vector3.zero
		if movementDirection.Magnitude > 0 then
			movement += movementDirection.Unit * 60
		end
		movement += Vector3.new(0, vertical * 60, 0)
		flyVelocity.Velocity = movement
		flyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + cameraDirection)
	end)
	setFlyVisual(true)
end

flyToggle.Activated:Connect(function()
	playSound(clickSound)
	setFly(not flyEnabled)
end)

local godModeEnabled = false
local godModeConnection

local function setSimpleSwitchVisual(toggleButton, knob, statusLabel, enabled)
	local target = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	local color = enabled and colors.accent or colors.switchOff
	statusLabel.Text = enabled and "ON" or "OFF"
	statusLabel.TextColor3 = enabled and colors.success or colors.faint
	TweenService:Create(knob, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = target, Rotation = enabled and 360 or 0}):Play()
	TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = color}):Play()
end

local function setGodModeVisual(enabled)
	local target = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	local color = enabled and colors.accent or colors.switchOff
	godStatus.Text = enabled and "ON" or "OFF"
	godStatus.TextColor3 = enabled and colors.success or colors.faint
	TweenService:Create(godKnob, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = target, Rotation = enabled and 360 or 0}):Play()
	TweenService:Create(godToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = color}):Play()
end

local function setGodMode(enabled)
	godModeEnabled = enabled
	if godModeConnection then
		godModeConnection:Disconnect()
		godModeConnection = nil
	end

	if enabled then
		godModeConnection = RunService.Heartbeat:Connect(function()
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
	end

	setGodModeVisual(enabled)
end

godToggle.Activated:Connect(function()
	playSound(clickSound)
	setGodMode(not godModeEnabled)
end)

local fullBrightEnabled = false
local fullBrightConnection
local originalLightingSettings
local originalFullBrightEffects = {}

local function neutralizeDarkeningEffect(descendant)
	if descendant:IsA("PostEffect") then
		if originalFullBrightEffects[descendant] == nil then
			originalFullBrightEffects[descendant] = {
				kind = "PostEffect",
				Enabled = descendant.Enabled,
			}
		end
		descendant.Enabled = false
	elseif descendant:IsA("Atmosphere") then
		if originalFullBrightEffects[descendant] == nil then
			originalFullBrightEffects[descendant] = {
				kind = "Atmosphere",
				Density = descendant.Density,
				Haze = descendant.Haze,
				Glare = descendant.Glare,
			}
		end
		descendant.Density = 0
		descendant.Haze = 0
		descendant.Glare = 0
	end
end

local function applyFullBrightLighting()
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.ExposureCompensation = 0
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)
	Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
	Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
	Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
	Lighting.GlobalShadows = false
	Lighting.FogStart = 0
	Lighting.FogEnd = 1000000

	for _, descendant in ipairs(Lighting:GetDescendants()) do
		neutralizeDarkeningEffect(descendant)
	end
	local camera = workspace.CurrentCamera
	if camera then
		for _, descendant in ipairs(camera:GetDescendants()) do
			neutralizeDarkeningEffect(descendant)
		end
	end
end

local function setFullBright(enabled)
	if fullBrightConnection then
		fullBrightConnection:Disconnect()
		fullBrightConnection = nil
	end

	if enabled then
		table.clear(originalFullBrightEffects)
		originalLightingSettings = {
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			ExposureCompensation = Lighting.ExposureCompensation,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			ColorShift_Top = Lighting.ColorShift_Top,
			ColorShift_Bottom = Lighting.ColorShift_Bottom,
			GlobalShadows = Lighting.GlobalShadows,
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd,
		}
		fullBrightEnabled = true
		applyFullBrightLighting()
		fullBrightConnection = RunService.RenderStepped:Connect(applyFullBrightLighting)
	else
		fullBrightEnabled = false
		if originalLightingSettings then
			Lighting.Brightness = originalLightingSettings.Brightness
			Lighting.ClockTime = originalLightingSettings.ClockTime
			Lighting.ExposureCompensation = originalLightingSettings.ExposureCompensation
			Lighting.Ambient = originalLightingSettings.Ambient
			Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient
			Lighting.ColorShift_Top = originalLightingSettings.ColorShift_Top
			Lighting.ColorShift_Bottom = originalLightingSettings.ColorShift_Bottom
			Lighting.GlobalShadows = originalLightingSettings.GlobalShadows
			Lighting.FogStart = originalLightingSettings.FogStart
			Lighting.FogEnd = originalLightingSettings.FogEnd
			originalLightingSettings = nil
		end
		for descendant, settings in pairs(originalFullBrightEffects) do
			if descendant.Parent then
				if settings.kind == "PostEffect" then
					descendant.Enabled = settings.Enabled
				else
					descendant.Density = settings.Density
					descendant.Haze = settings.Haze
					descendant.Glare = settings.Glare
				end
			end
		end
		table.clear(originalFullBrightEffects)
	end

	setSimpleSwitchVisual(switchUI.fullBright[1], switchUI.fullBright[2], switchUI.fullBright[3], fullBrightEnabled)
end

switchUI.fullBright[1].Activated:Connect(function()
	playSound(clickSound)
	setFullBright(not fullBrightEnabled)
end)

local freecamState = {
	enabled = false,
	renderConnection = nil,
	inputBeganConnection = nil,
	inputChangedConnection = nil,
	inputEndedConnection = nil,
	savedState = nil,
	position = Vector3.zero,
	pitch = 0,
	yaw = 0,
	rotating = false,
}

function freecamState.disconnectConnections()
	if freecamState.renderConnection then
		freecamState.renderConnection:Disconnect()
		freecamState.renderConnection = nil
	end
	if freecamState.inputBeganConnection then
		freecamState.inputBeganConnection:Disconnect()
		freecamState.inputBeganConnection = nil
	end
	if freecamState.inputChangedConnection then
		freecamState.inputChangedConnection:Disconnect()
		freecamState.inputChangedConnection = nil
	end
	if freecamState.inputEndedConnection then
		freecamState.inputEndedConnection:Disconnect()
		freecamState.inputEndedConnection = nil
	end
	ContextActionService:UnbindAction("WaveFreecamControls")
end

function freecamState.sinkControls()
	return Enum.ContextActionResult.Sink
end

function freecamState.setEnabled(enabled)
	freecamState.disconnectConnections()

	if not enabled then
		freecamState.enabled = false
		freecamState.rotating = false
		if freecamState.savedState then
			local camera = workspace.CurrentCamera
			if camera then
				camera.CameraType = freecamState.savedState.CameraType
				local savedSubject = freecamState.savedState.CameraSubject
				if not savedSubject or not savedSubject.Parent then
					local character = player.Character
					savedSubject = character and character:FindFirstChildOfClass("Humanoid")
				end
				camera.CameraSubject = savedSubject
				camera.CFrame = freecamState.savedState.CFrame
				camera.Focus = freecamState.savedState.Focus
			end
			UserInputService.MouseBehavior = freecamState.savedState.MouseBehavior
			UserInputService.MouseIconEnabled = freecamState.savedState.MouseIconEnabled
			freecamState.savedState = nil
		end
		setSimpleSwitchVisual(freecamUI[1], freecamUI[2], freecamUI[3], false)
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		freecamState.enabled = false
		setSimpleSwitchVisual(freecamUI[1], freecamUI[2], freecamUI[3], false)
		return
	end

	freecamState.savedState = {
		CameraType = camera.CameraType,
		CameraSubject = camera.CameraSubject,
		CFrame = camera.CFrame,
		Focus = camera.Focus,
		MouseBehavior = UserInputService.MouseBehavior,
		MouseIconEnabled = UserInputService.MouseIconEnabled,
	}
	freecamState.position = camera.CFrame.Position
	freecamState.pitch, freecamState.yaw = camera.CFrame:ToOrientation()
	freecamState.rotating = false
	freecamState.enabled = true
	camera.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

	ContextActionService:BindActionAtPriority(
		"WaveFreecamControls",
		freecamState.sinkControls,
		false,
		Enum.ContextActionPriority.High.Value + 10,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,
		Enum.KeyCode.E,
		Enum.KeyCode.Q,
		Enum.KeyCode.LeftShift,
		Enum.UserInputType.MouseButton2
	)

	freecamState.inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		if freecamState.enabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
			freecamState.rotating = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end
	end)

	freecamState.inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if freecamState.enabled and freecamState.rotating and input.UserInputType == Enum.UserInputType.MouseMovement then
			freecamState.yaw -= input.Delta.X * 0.0025
			freecamState.pitch = math.clamp(freecamState.pitch - input.Delta.Y * 0.0025, math.rad(-89), math.rad(89))
		end
	end)

	freecamState.inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			freecamState.rotating = false
			if freecamState.enabled then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end
		end
	end)

	freecamState.renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
		if not freecamState.enabled then
			return
		end

		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		currentCamera.CameraType = Enum.CameraType.Scriptable

		local right = 0
		local forward = 0
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			right += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			right -= 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			forward += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			forward -= 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			vertical += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			vertical -= 1
		end

		local rotation = CFrame.fromOrientation(freecamState.pitch, freecamState.yaw, 0)
		local movement = Vector3.new(right, vertical, -forward)
		if movement.Magnitude > 1 then
			movement = movement.Unit
		end
		local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 120 or 40
		freecamState.position += rotation:VectorToWorldSpace(movement) * speed * deltaTime

		currentCamera.CFrame = CFrame.new(freecamState.position) * rotation
		currentCamera.Focus = currentCamera.CFrame * CFrame.new(0, 0, -512)

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:Move(Vector3.zero, false)
		end
	end)

	setSimpleSwitchVisual(freecamUI[1], freecamUI[2], freecamUI[3], true)
end

freecamUI[1].Activated:Connect(function()
	playSound(clickSound)
	local enableFreecam = not freecamState.enabled
	if enableFreecam and spin.releaseCamera then
		spin.releaseCamera()
	end
	freecamState.setEnabled(enableFreecam)
	if not enableFreecam and spin.value ~= 0 and spin.startCamera then
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			spin.startCamera(rootPart)
		end
	end
end)

function zoom.apply()
	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 128
end

function zoom.setEnabled(enabled)
	if zoom.connection then
		zoom.connection:Disconnect()
		zoom.connection = nil
	end

	if enabled then
		if not zoom.enabled then
			zoom.savedState = {
				CameraMode = player.CameraMode,
				CameraMinZoomDistance = player.CameraMinZoomDistance,
				CameraMaxZoomDistance = player.CameraMaxZoomDistance,
			}
		end

		zoom.enabled = true
		zoom.apply()
		zoom.connection = RunService.RenderStepped:Connect(zoom.apply)
	else
		zoom.enabled = false
		if zoom.savedState then
			player.CameraMode = zoom.savedState.CameraMode
			player.CameraMinZoomDistance = zoom.savedState.CameraMinZoomDistance
			player.CameraMaxZoomDistance = zoom.savedState.CameraMaxZoomDistance
			zoom.savedState = nil
		end
	end

	setSimpleSwitchVisual(switchUI.zoom[1], switchUI.zoom[2], switchUI.zoom[3], zoom.enabled)
end

switchUI.zoom[1].Activated:Connect(function()
	playSound(clickSound)
	zoom.setEnabled(not zoom.enabled)
end)

function teleportClick.setEnabled(enabled)
	if teleportClick.connection then
		teleportClick.connection:Disconnect()
		teleportClick.connection = nil
	end

	teleportClick.enabled = enabled
	if enabled then
		teleportClick.mouse = teleportClick.mouse or player:GetMouse()
		teleportClick.connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if gameProcessedEvent or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not character or not rootPart or not teleportClick.mouse.Target then
				return
			end

			local destination = teleportClick.mouse.Hit.Position + Vector3.new(0, 3, 0)
			character:PivotTo(CFrame.new(destination) * (rootPart.CFrame - rootPart.Position))
		end)
	end

	setSimpleSwitchVisual(
		switchUI.teleportClick[1],
		switchUI.teleportClick[2],
		switchUI.teleportClick[3],
		teleportClick.enabled
	)
end

switchUI.teleportClick[1].Activated:Connect(function()
	playSound(clickSound)
	teleportClick.setEnabled(not teleportClick.enabled)
end)

function gotoPlayer.teleportTo(targetPlayer)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local targetCharacter = targetPlayer and targetPlayer.Character
	local targetRootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
	if not character or not rootPart or not targetRootPart then
		gotoPlayer.selectButton.Text = "Player unavailable"
		return
	end

	character:PivotTo(targetRootPart.CFrame * CFrame.new(3, 0, 3))
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	gotoPlayer.selectButton.Text = targetPlayer.DisplayName
	gotoPlayer.setOpen(false)
end

function gotoPlayer.rebuildList()
	for _, child in ipairs(gotoPlayer.listFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local availablePlayers = {}
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			table.insert(availablePlayers, targetPlayer)
		end
	end
	table.sort(availablePlayers, function(firstPlayer, secondPlayer)
		return string.lower(firstPlayer.Name) < string.lower(secondPlayer.Name)
	end)

	gotoPlayer.optionCount = #availablePlayers
	if #availablePlayers == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Name = "NoPlayers"
		emptyLabel.Size = UDim2.new(1, 0, 0, 28)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.Text = "No other players"
		emptyLabel.TextColor3 = colors.faint
		emptyLabel.TextSize = 11
		emptyLabel.Parent = gotoPlayer.listFrame
		return
	end

	for index, targetPlayer in ipairs(availablePlayers) do
		local option = Instance.new("TextButton")
		option.Name = "PlayerOption_" .. targetPlayer.Name
		option.Size = UDim2.new(1, 0, 0, 28)
		option.BackgroundColor3 = colors.card
		option.BorderSizePixel = 0
		option.AutoButtonColor = false
		option.Font = Enum.Font.GothamMedium
		option.Text = targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")"
		option.TextColor3 = colors.text
		option.TextSize = 11
		option.LayoutOrder = index
		option.Parent = gotoPlayer.listFrame
		addCorner(option, 6)
		if themeSystem.enhanceButton then themeSystem.enhanceButton(option) end
		local optionStroke = Instance.new("UIStroke")
		optionStroke.Color = colors.border
		optionStroke.Transparency = 0.72
		optionStroke.Parent = option
		option.MouseEnter:Connect(function()
			TweenService:Create(option, TweenInfo.new(0.14), {BackgroundColor3 = colors.cardHover}):Play()
			TweenService:Create(optionStroke, TweenInfo.new(0.14), {Transparency = 0.28, Color = colors.accent}):Play()
		end)
		option.MouseLeave:Connect(function()
			TweenService:Create(option, TweenInfo.new(0.14), {BackgroundColor3 = colors.card}):Play()
			TweenService:Create(optionStroke, TweenInfo.new(0.14), {Transparency = 0.72, Color = colors.border}):Play()
		end)

		option.Activated:Connect(function()
			playSound(clickSound)
			gotoPlayer.teleportTo(targetPlayer)
		end)
	end
end

function gotoPlayer.setOpen(open)
	gotoPlayer.open = open
	if open then
		if spectate.setOpen then
			spectate.setOpen(false)
		end
		gotoPlayer.rebuildList()
		local visibleRows = math.clamp(gotoPlayer.optionCount, 1, 5)
		local listHeight = visibleRows * 33 + 5
		gotoPlayer.listFrame.Visible = true
		TweenService:Create(gotoPlayer.listFrame, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -34, 0, listHeight)}):Play()
		TweenService:Create(gotoPlayer.card, TweenInfo.new(0.27, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -3, 0, 124 + listHeight)}):Play()
	else
		TweenService:Create(gotoPlayer.listFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, -34, 0, 0)}):Play()
		local collapse = TweenService:Create(gotoPlayer.card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -3, 0, 118)})
		collapse:Play()
		collapse.Completed:Once(function()
			if not gotoPlayer.open then gotoPlayer.listFrame.Visible = false end
		end)
	end
	gotoPlayer.arrow.Text = open and "^" or "v"
end

gotoPlayer.selectButton.Activated:Connect(function()
	playSound(clickSound)
	gotoPlayer.setOpen(not gotoPlayer.open)
end)

function spectate.stop()
	if spectate.characterConnection then
		spectate.characterConnection:Disconnect()
		spectate.characterConnection = nil
	end
	spectate.target = nil
	spectate.exitButton.Visible = false
	spectate.selectButton.Text = "Select a player"
	if spectate.savedCameraState then
		local camera = workspace.CurrentCamera
		if camera then
			local savedSubject = spectate.savedCameraState.CameraSubject
			if not savedSubject or not savedSubject.Parent then
				local character = player.Character
				savedSubject = character and character:FindFirstChildOfClass("Humanoid")
			end
			camera.CameraType = spectate.savedCameraState.CameraType
			camera.CameraSubject = savedSubject
			camera.CFrame = spectate.savedCameraState.CFrame
			camera.Focus = spectate.savedCameraState.Focus
		end
		spectate.savedCameraState = nil
	end
end

function spectate.watchCharacter(targetPlayer, character)
	if spectate.target ~= targetPlayer then
		return
	end
	local humanoid = character and (character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5))
	local camera = workspace.CurrentCamera
	if spectate.target == targetPlayer and humanoid and camera then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end
end

function spectate.setTarget(targetPlayer)
	if not targetPlayer or targetPlayer == player or targetPlayer.Parent ~= Players then
		spectate.selectButton.Text = "Player unavailable"
		return
	end
	if freecamState.enabled then
		freecamState.setEnabled(false)
	end
	if spin.releaseCamera then
		spin.releaseCamera()
	end
	if not spectate.target then
		local camera = workspace.CurrentCamera
		if camera then
			spectate.savedCameraState = {
				CameraType = camera.CameraType,
				CameraSubject = camera.CameraSubject,
				CFrame = camera.CFrame,
				Focus = camera.Focus,
			}
		end
	end
	if spectate.characterConnection then
		spectate.characterConnection:Disconnect()
	end
	spectate.target = targetPlayer
	spectate.selectButton.Text = targetPlayer.DisplayName
	spectate.exitButton.Visible = true
	spectate.setOpen(false)
	spectate.watchCharacter(targetPlayer, targetPlayer.Character)
	spectate.characterConnection = targetPlayer.CharacterAdded:Connect(function(character)
		spectate.watchCharacter(targetPlayer, character)
	end)
end

function spectate.rebuildList()
	for _, child in ipairs(spectate.listFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local availablePlayers = {}
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			table.insert(availablePlayers, targetPlayer)
		end
	end
	table.sort(availablePlayers, function(firstPlayer, secondPlayer)
		return string.lower(firstPlayer.Name) < string.lower(secondPlayer.Name)
	end)

	spectate.optionCount = #availablePlayers
	if #availablePlayers == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Name = "NoPlayers"
		emptyLabel.Size = UDim2.new(1, 0, 0, 28)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.Text = "No other players"
		emptyLabel.TextColor3 = colors.faint
		emptyLabel.TextSize = 11
		emptyLabel.Parent = spectate.listFrame
		return
	end

	for index, targetPlayer in ipairs(availablePlayers) do
		local option = Instance.new("TextButton")
		option.Name = "SpectatePlayerOption_" .. targetPlayer.Name
		option.Size = UDim2.new(1, 0, 0, 28)
		option.BackgroundColor3 = colors.card
		option.BorderSizePixel = 0
		option.AutoButtonColor = false
		option.Font = Enum.Font.GothamMedium
		option.Text = targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")"
		option.TextColor3 = colors.text
		option.TextSize = 11
		option.LayoutOrder = index
		option.Parent = spectate.listFrame
		addCorner(option, 6)
		if themeSystem.enhanceButton then themeSystem.enhanceButton(option) end
		local optionStroke = Instance.new("UIStroke")
		optionStroke.Color = colors.border
		optionStroke.Transparency = 0.72
		optionStroke.Parent = option
		option.MouseEnter:Connect(function()
			TweenService:Create(option, TweenInfo.new(0.14), {BackgroundColor3 = colors.cardHover}):Play()
			TweenService:Create(optionStroke, TweenInfo.new(0.14), {Transparency = 0.28, Color = colors.accent}):Play()
		end)
		option.MouseLeave:Connect(function()
			TweenService:Create(option, TweenInfo.new(0.14), {BackgroundColor3 = colors.card}):Play()
			TweenService:Create(optionStroke, TweenInfo.new(0.14), {Transparency = 0.72, Color = colors.border}):Play()
		end)
		option.Activated:Connect(function()
			playSound(clickSound)
			spectate.setTarget(targetPlayer)
		end)
	end
end

function spectate.setOpen(open)
	spectate.open = open
	if open then
		gotoPlayer.setOpen(false)
		spectate.rebuildList()
		local visibleRows = math.clamp(spectate.optionCount, 1, 5)
		local listHeight = visibleRows * 33 + 5
		spectate.listFrame.Visible = true
		TweenService:Create(spectate.listFrame, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -34, 0, listHeight)}):Play()
		TweenService:Create(spectate.card, TweenInfo.new(0.27, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -3, 0, 124 + listHeight)}):Play()
	else
		TweenService:Create(spectate.listFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, -34, 0, 0)}):Play()
		local collapse = TweenService:Create(spectate.card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -3, 0, 118)})
		collapse:Play()
		collapse.Completed:Once(function()
			if not spectate.open then spectate.listFrame.Visible = false end
		end)
	end
	spectate.arrow.Text = open and "^" or "v"
end

spectate.selectButton.Activated:Connect(function()
	playSound(clickSound)
	spectate.setOpen(not spectate.open)
end)

spectate.exitButton.Activated:Connect(function()
	playSound(clickSound)
	spectate.stop()
end)

Players.PlayerAdded:Connect(function()
	if gotoPlayer.open then
		task.defer(function()
			if gotoPlayer.open then
				gotoPlayer.setOpen(true)
			end
		end)
	end
	if spectate.open then
		task.defer(function()
			if spectate.open then
				spectate.setOpen(true)
			end
		end)
	end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if spectate.target == leavingPlayer then
		spectate.stop()
	end
	if gotoPlayer.open then
		task.defer(function()
			if gotoPlayer.open then
				gotoPlayer.setOpen(true)
			end
		end)
	end
	if spectate.open then
		task.defer(function()
			if spectate.open then
				spectate.setOpen(true)
			end
		end)
	end
end)

function themeSystem.playerInspector.setStatus(message, success)
	themeSystem.playerInspector.status.Text = string.upper(message)
	themeSystem.playerInspector.status.TextColor3 = success == nil and colors.faint or (success and colors.success or colors.danger)
end

function themeSystem.playerInspector.updateActions()
	local available = themeSystem.playerInspector.selected ~= nil and themeSystem.playerInspector.selected.Parent == Players
	for _, button in ipairs({themeSystem.playerInspector.gotoButton, themeSystem.playerInspector.spectateButton, themeSystem.playerInspector.waypointButton}) do
		button.Active = available
		button.Selectable = available
		button.TextColor3 = available and colors.text or colors.faint
	end
end

function themeSystem.playerInspector.setSelected(targetPlayer)
	if not targetPlayer or targetPlayer == player or targetPlayer.Parent ~= Players then
		themeSystem.playerInspector.selected = nil
		themeSystem.playerInspector.selectButton.Text = "Select a player"
		themeSystem.playerInspector.nameLabel.Text = "NO PLAYER SELECTED"
		themeSystem.playerInspector.userLabel.Text = "Choose someone from the list above"
		themeSystem.playerInspector.statsLabel.Text = "HEALTH --   •   DISTANCE --   •   TEAM --"
		themeSystem.playerInspector.avatar.Image = ""
		themeSystem.playerInspector.setStatus("Select a player to begin")
		themeSystem.playerInspector.updateActions()
		return
	end

	themeSystem.playerInspector.selected = targetPlayer
	themeSystem.playerInspector.selectButton.Text = targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")"
	themeSystem.playerInspector.nameLabel.Text = string.upper(targetPlayer.DisplayName)
	themeSystem.playerInspector.userLabel.Text = "@" .. targetPlayer.Name .. "   •   USER ID " .. tostring(targetPlayer.UserId)
	themeSystem.playerInspector.setStatus("Player selected", true)
	themeSystem.playerInspector.updateActions()
	themeSystem.playerInspector.setOpen(false)
	local selection = targetPlayer
	task.spawn(function()
		local success, image = pcall(function()
			return Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if success and themeSystem.playerInspector.selected == selection then
			themeSystem.playerInspector.avatar.Image = image
		end
	end)
end

function themeSystem.playerInspector.rebuildList()
	for _, child in ipairs(themeSystem.playerInspector.listFrame:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	local availablePlayers = {}
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then table.insert(availablePlayers, targetPlayer) end
	end
	table.sort(availablePlayers, function(firstPlayer, secondPlayer)
		return string.lower(firstPlayer.Name) < string.lower(secondPlayer.Name)
	end)
	themeSystem.playerInspector.optionCount = #availablePlayers
	if #availablePlayers == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Name = "NoPlayers"
		emptyLabel.Size = UDim2.new(1, 0, 0, 28)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.Text = "No other players"
		emptyLabel.TextColor3 = colors.faint
		emptyLabel.TextSize = 11
		emptyLabel.ZIndex = 11
		emptyLabel.Parent = themeSystem.playerInspector.listFrame
		return
	end
	for index, targetPlayer in ipairs(availablePlayers) do
		local option = Instance.new("TextButton")
		option.Name = "InspectorPlayerOption_" .. targetPlayer.Name
		option.Size = UDim2.new(1, 0, 0, 28)
		option.BackgroundColor3 = colors.card
		option.BorderSizePixel = 0
		option.AutoButtonColor = false
		option.Font = Enum.Font.GothamMedium
		option.Text = targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")"
		option.TextColor3 = colors.text
		option.TextSize = 11
		option.LayoutOrder = index
		option.ZIndex = 11
		option.Parent = themeSystem.playerInspector.listFrame
		addCorner(option, 6)
		if themeSystem.enhanceButton then themeSystem.enhanceButton(option) end
		option.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.playerInspector.setSelected(targetPlayer)
		end)
	end
end

function themeSystem.playerInspector.setOpen(open)
	open = open == true
	themeSystem.playerInspector.open = open
	local listHeight = open and (math.clamp(themeSystem.playerInspector.optionCount, 1, 5) * 33 + 5) or 0
	if open then
		gotoPlayer.setOpen(false)
		spectate.setOpen(false)
		themeSystem.playerInspector.rebuildList()
		listHeight = math.clamp(themeSystem.playerInspector.optionCount, 1, 5) * 33 + 5
		themeSystem.playerInspector.listFrame.Visible = true
	end
	local duration = open and 0.24 or 0.18
	TweenService:Create(themeSystem.playerInspector.listFrame, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -34, 0, listHeight)}):Play()
	TweenService:Create(themeSystem.playerInspector.card, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -3, 0, 340 + listHeight)}):Play()
	TweenService:Create(themeSystem.playerInspector.avatar, TweenInfo.new(duration), {Position = UDim2.fromOffset(17, 120 + listHeight)}):Play()
	TweenService:Create(themeSystem.playerInspector.nameLabel, TweenInfo.new(duration), {Position = UDim2.fromOffset(99, 117 + listHeight)}):Play()
	TweenService:Create(themeSystem.playerInspector.userLabel, TweenInfo.new(duration), {Position = UDim2.fromOffset(99, 140 + listHeight)}):Play()
	TweenService:Create(themeSystem.playerInspector.statsLabel, TweenInfo.new(duration), {Position = UDim2.fromOffset(99, 160 + listHeight)}):Play()
	for index, row in ipairs({themeSystem.playerInspector.gotoRow, themeSystem.playerInspector.spectateRow, themeSystem.playerInspector.waypointRow}) do
		TweenService:Create(row, TweenInfo.new(duration), {Position = UDim2.fromOffset(17, 202 + (index - 1) * 38 + listHeight)}):Play()
	end
	TweenService:Create(themeSystem.playerInspector.status, TweenInfo.new(duration), {Position = UDim2.fromOffset(17, 318 + listHeight)}):Play()
	themeSystem.playerInspector.arrow.Text = open and "^" or "v"
	if not open then
		task.delay(duration, function()
			if not themeSystem.playerInspector.open then themeSystem.playerInspector.listFrame.Visible = false end
		end)
	end
end

function themeSystem.playerInspector.goToSelected()
	local targetPlayer = themeSystem.playerInspector.selected
	local ownCharacter = player.Character
	local targetCharacter = targetPlayer and targetPlayer.Character
	if not targetPlayer or targetPlayer.Parent ~= Players or not (ownCharacter and ownCharacter:FindFirstChild("HumanoidRootPart")) or not (targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")) then
		themeSystem.playerInspector.setSelected(nil)
		themeSystem.playerInspector.setStatus("Player is unavailable", false)
		return false
	end
	gotoPlayer.teleportTo(targetPlayer)
	themeSystem.playerInspector.setStatus("Teleported beside " .. targetPlayer.DisplayName, true)
	return true
end

function themeSystem.playerInspector.spectateSelected()
	local targetPlayer = themeSystem.playerInspector.selected
	local targetCharacter = targetPlayer and targetPlayer.Character
	if not targetPlayer or targetPlayer.Parent ~= Players or not (targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")) then
		themeSystem.playerInspector.setSelected(nil)
		themeSystem.playerInspector.setStatus("Player is unavailable", false)
		return false
	end
	spectate.setTarget(targetPlayer)
	themeSystem.playerInspector.setStatus("Spectating " .. targetPlayer.DisplayName, true)
	return true
end

function themeSystem.playerInspector.saveWaypoint()
	local targetPlayer = themeSystem.playerInspector.selected
	local targetCharacter = targetPlayer and targetPlayer.Character
	local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		themeSystem.playerInspector.setStatus("Player position is unavailable", false)
		return false
	end
	themeSystem.waypoints.nextId += 1
	local item = {
		id = tostring(themeSystem.waypoints.nextId),
		name = targetPlayer.DisplayName .. " Location",
		color = themeSystem.waypoints.selectedColor or Color3.fromHSV(themeSystem.waypoints.selectedHue, 0.82, 1),
		cframe = {targetRoot.CFrame:GetComponents()},
	}
	table.insert(themeSystem.waypoints.items, item)
	themeSystem.waypoints.createMarker(item)
	themeSystem.waypoints.rebuildCards()
	themeSystem.playerInspector.setStatus("Waypoint saved at " .. targetPlayer.DisplayName, true)
	return true
end

themeSystem.playerInspector.selectButton.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.playerInspector.setOpen(not themeSystem.playerInspector.open)
end)
themeSystem.playerInspector.gotoButton.Activated:Connect(function() playSound(clickSound) themeSystem.playerInspector.goToSelected() end)
themeSystem.playerInspector.spectateButton.Activated:Connect(function() playSound(clickSound) themeSystem.playerInspector.spectateSelected() end)
themeSystem.playerInspector.waypointButton.Activated:Connect(function() playSound(clickSound) themeSystem.playerInspector.saveWaypoint() end)

RunService.Heartbeat:Connect(function()
	if os.clock() - (themeSystem.playerInspector.lastUpdate or 0) < 0.2 then return end
	themeSystem.playerInspector.lastUpdate = os.clock()
	local targetPlayer = themeSystem.playerInspector.selected
	if not targetPlayer then return end
	if targetPlayer.Parent ~= Players then themeSystem.playerInspector.setSelected(nil) return end
	local targetCharacter = targetPlayer.Character
	local humanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
	local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
	local ownCharacter = player.Character
	local ownRoot = ownCharacter and ownCharacter:FindFirstChild("HumanoidRootPart")
	local healthText = humanoid and string.format("%d/%d", math.max(0, math.floor(humanoid.Health + 0.5)), math.max(0, math.floor(humanoid.MaxHealth + 0.5))) or "--"
	local distanceText = targetRoot and ownRoot and tostring(math.floor((targetRoot.Position - ownRoot.Position).Magnitude + 0.5)) .. " studs" or "--"
	local teamText = targetPlayer.Team and targetPlayer.Team.Name or "None"
	themeSystem.playerInspector.statsLabel.Text = "HEALTH " .. healthText .. "   •   DISTANCE " .. distanceText .. "   •   TEAM " .. teamText
end)

Players.PlayerAdded:Connect(function()
	if themeSystem.playerInspector.open then task.defer(function() themeSystem.playerInspector.setOpen(true) end) end
end)
Players.PlayerRemoving:Connect(function(leavingPlayer)
	if themeSystem.playerInspector.selected == leavingPlayer then themeSystem.playerInspector.setSelected(nil) end
	if themeSystem.playerInspector.open then task.defer(function() themeSystem.playerInspector.setOpen(true) end) end
end)

themeSystem.playerInspector.updateActions()

leave.button.Activated:Connect(function()
	playSound(clickSound)
	player:Kick("You left the game.")
end)

function rejoin.resetButtonLater()
	task.delay(5, function()
		if rejoin.button.Parent then
			rejoin.busy = false
			rejoin.button.Text = "REJOIN"
		end
	end)
end

rejoin.button.Activated:Connect(function()
	if rejoin.busy then
		return
	end
	playSound(clickSound)
	rejoin.busy = true
	rejoin.button.Text = "JOINING..."

	local success = pcall(function()
		if game.JobId ~= "" then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
		else
			TeleportService:Teleport(game.PlaceId, player)
		end
	end)
	if not success then
		rejoin.button.Text = "FAILED"
	end
	rejoin.resetButtonLater()
end)

function serverHop.resetButtonLater()
	task.delay(5, function()
		if serverHop.button.Parent then
			serverHop.busy = false
			serverHop.button.Text = "HOP"
		end
	end)
end

function serverHop.getServerPage(cursor)
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	if cursor and cursor ~= "" then
		url ..= "&cursor=" .. HttpService:UrlEncode(cursor)
	end

	local requestWorked, response = pcall(function()
		return game:HttpGet(url)
	end)
	if not requestWorked then
		response = HttpService:GetAsync(url)
	end
	return HttpService:JSONDecode(response)
end

function serverHop.findAndJoin()
	if serverHop.busy then
		return
	end
	playSound(clickSound)
	serverHop.busy = true
	serverHop.button.Text = "SEARCHING..."

	task.spawn(function()
		local success, foundServer = pcall(function()
			local cursor = nil
			for _ = 1, 10 do
				local page = serverHop.getServerPage(cursor)
				for _, server in ipairs(page.data or {}) do
					if server.id ~= game.JobId and server.playing < server.maxPlayers then
						serverHop.button.Text = "JOINING..."
						TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
						return true
					end
				end

				cursor = page.nextPageCursor
				if not cursor or cursor == "" then
					break
				end
			end
			return false
		end)

		if not success then
			serverHop.button.Text = "FAILED"
		elseif not foundServer then
			serverHop.button.Text = "NO SERVER"
		end
		serverHop.resetButtonLater()
	end)
end

serverHop.button.Activated:Connect(serverHop.findAndJoin)

function freeze.releaseRoot()
	if freeze.rootPart and freeze.rootPart.Parent then
		freeze.rootPart.Anchored = freeze.originalAnchored == true
		if freeze.originalLinearVelocity then
			freeze.rootPart.AssemblyLinearVelocity = freeze.originalLinearVelocity
		end
		if freeze.originalAngularVelocity then
			freeze.rootPart.AssemblyAngularVelocity = freeze.originalAngularVelocity
		end
	end
	freeze.rootPart = nil
	freeze.originalAnchored = nil
	freeze.originalLinearVelocity = nil
	freeze.originalAngularVelocity = nil
end

function freeze.applyToCharacter(character)
	freeze.releaseRoot()
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	freeze.rootPart = rootPart
	freeze.originalAnchored = rootPart.Anchored
	freeze.originalLinearVelocity = rootPart.AssemblyLinearVelocity
	freeze.originalAngularVelocity = rootPart.AssemblyAngularVelocity
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	rootPart.Anchored = true
end

function freeze.setEnabled(enabled)
	if freeze.characterConnection then
		freeze.characterConnection:Disconnect()
		freeze.characterConnection = nil
	end

	freeze.enabled = enabled
	if enabled then
		freeze.applyToCharacter(player.Character)
		freeze.characterConnection = player.CharacterAdded:Connect(function(character)
			local rootPart = character:WaitForChild("HumanoidRootPart", 5)
			if freeze.enabled and rootPart then
				freeze.applyToCharacter(character)
			end
		end)
	else
		freeze.releaseRoot()
	end

	setSimpleSwitchVisual(switchUI.freeze[1], switchUI.freeze[2], switchUI.freeze[3], freeze.enabled)
end

switchUI.freeze[1].Activated:Connect(function()
	playSound(clickSound)
	freeze.setEnabled(not freeze.enabled)
end)

function spin.releaseCamera()
	if spin.cameraConnection then
		spin.cameraConnection:Disconnect()
		spin.cameraConnection = nil
	end
	if spin.cameraInputBeganConnection then
		spin.cameraInputBeganConnection:Disconnect()
		spin.cameraInputBeganConnection = nil
	end
	if spin.cameraInputChangedConnection then
		spin.cameraInputChangedConnection:Disconnect()
		spin.cameraInputChangedConnection = nil
	end
	if spin.cameraInputEndedConnection then
		spin.cameraInputEndedConnection:Disconnect()
		spin.cameraInputEndedConnection = nil
	end
	spin.cameraRotating = false
	if spin.cameraState then
		local camera = workspace.CurrentCamera
		if camera then
			local savedSubject = spin.cameraState.CameraSubject
			if not savedSubject or not savedSubject.Parent then
				local character = player.Character
				savedSubject = character and character:FindFirstChildOfClass("Humanoid")
			end
			camera.CFrame = spin.cameraState.CFrame
			camera.Focus = spin.cameraState.Focus
			camera.CameraSubject = savedSubject
			camera.CameraType = spin.cameraState.CameraType
		end
		UserInputService.MouseBehavior = spin.cameraState.MouseBehavior
		UserInputService.MouseIconEnabled = spin.cameraState.MouseIconEnabled
		spin.cameraState = nil
	end
end

function spin.startCamera(rootPart)
	spin.releaseCamera()
	if freecamState.enabled then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	spin.cameraState = {
		CameraType = camera.CameraType,
		CameraSubject = camera.CameraSubject,
		CFrame = camera.CFrame,
		Focus = camera.Focus,
		MouseBehavior = UserInputService.MouseBehavior,
		MouseIconEnabled = UserInputService.MouseIconEnabled,
	}
	local focusPosition = rootPart.Position + Vector3.new(0, 2, 0)
	spin.cameraDistance = (camera.CFrame.Position - focusPosition).Magnitude
	if spin.cameraDistance < 3 then
		spin.cameraDistance = 10
	end
	spin.cameraDistance = math.clamp(spin.cameraDistance, 3, 50)
	spin.cameraPitch, spin.cameraYaw = camera.CFrame:ToOrientation()
	spin.cameraPitch = math.clamp(spin.cameraPitch, math.rad(-80), math.rad(80))
	spin.cameraRotating = false
	camera.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

	spin.cameraInputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		if spin.value ~= 0 and input.UserInputType == Enum.UserInputType.MouseButton2 then
			spin.cameraRotating = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end
	end)

	spin.cameraInputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			spin.cameraDistance = math.clamp(spin.cameraDistance - input.Position.Z * 2, 3, 50)
		elseif spin.cameraRotating and input.UserInputType == Enum.UserInputType.MouseMovement then
			spin.cameraYaw -= input.Delta.X * 0.0025
			spin.cameraPitch = math.clamp(spin.cameraPitch - input.Delta.Y * 0.0025, math.rad(-80), math.rad(80))
		end
	end)

	spin.cameraInputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			spin.cameraRotating = false
			if spin.value ~= 0 and not freecamState.enabled then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end
		end
	end)

	spin.cameraConnection = RunService.RenderStepped:Connect(function()
		if spin.value == 0 or not rootPart.Parent then
			return
		end
		local currentCamera = workspace.CurrentCamera
		if not currentCamera or freecamState.enabled then
			return
		end
		local currentFocus = rootPart.Position + Vector3.new(0, 2, 0)
		local cameraRotation = CFrame.fromOrientation(spin.cameraPitch, spin.cameraYaw, 0)
		local cameraPosition = currentFocus - cameraRotation.LookVector * spin.cameraDistance
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = CFrame.lookAt(cameraPosition, currentFocus)
		currentCamera.Focus = CFrame.new(currentFocus)
	end)
end

function spin.setDropdownOpen(open)
	spin.dropdownOpen = open
	if open then spin.antiflingRow.Visible = true end
	spin.dropdownButton.Text = open and "^" or "v"
	local resize = TweenService:Create(spin.card, TweenInfo.new(0.25, open and Enum.EasingStyle.Back or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -3, 0, open and 198 or 118)})
	resize:Play()
	if not open then
		resize.Completed:Once(function()
			if not spin.dropdownOpen then spin.antiflingRow.Visible = false end
		end)
	end
end

function spin.updateAntiflingVisual()
	local available = spin.value ~= 0
	spin.antiflingToggle.Active = available
	spin.antiflingToggle.Selectable = available

	if not available then
		spin.antiflingToggle.BackgroundColor3 = colors.input
		spin.antiflingKnob.Position = UDim2.new(0, 3, 0.5, 0)
		spin.antiflingKnob.BackgroundColor3 = colors.faint
		spin.antiflingTitle.TextColor3 = colors.faint
		spin.antiflingDescription.TextColor3 = colors.faint
		spin.antiflingStatus.Text = "LOCKED"
		spin.antiflingStatus.TextColor3 = colors.faint
		return
	end

	spin.antiflingTitle.TextColor3 = colors.text
	spin.antiflingDescription.TextColor3 = colors.muted
	spin.antiflingToggle.BackgroundColor3 = spin.antiflingEnabled and colors.accent or colors.switchOff
	spin.antiflingKnob.Position = spin.antiflingEnabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	spin.antiflingKnob.BackgroundColor3 = Color3.fromRGB(231, 238, 250)
	spin.antiflingStatus.Text = spin.antiflingEnabled and "ON" or "OFF"
	spin.antiflingStatus.TextColor3 = spin.antiflingEnabled and colors.success or colors.faint
end

function spin.setAntifling(enabled)
	if spin.antiflingConnection then
		spin.antiflingConnection:Disconnect()
		spin.antiflingConnection = nil
	end
	if spin.antiflingHumanoid and spin.antiflingHumanoid.Parent then
		if spin.savedFallingDownEnabled ~= nil then
			spin.antiflingHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, spin.savedFallingDownEnabled)
		end
		if spin.savedRagdollEnabled ~= nil then
			spin.antiflingHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, spin.savedRagdollEnabled)
		end
	end
	spin.antiflingHumanoid = nil
	spin.savedFallingDownEnabled = nil
	spin.savedRagdollEnabled = nil

	enabled = enabled and spin.value ~= 0
	spin.antiflingEnabled = enabled
	if not enabled then
		spin.updateAntiflingVisual()
		return
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then
		spin.antiflingEnabled = false
		spin.updateAntiflingVisual()
		return
	end

	spin.antiflingHumanoid = humanoid
	spin.savedFallingDownEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
	spin.savedRagdollEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Ragdoll)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

	spin.antiflingConnection = RunService.Heartbeat:Connect(function()
		if spin.value == 0 or not rootPart.Parent or not humanoid.Parent then
			spin.setAntifling(false)
			return
		end

		local linearVelocity = rootPart.AssemblyLinearVelocity
		if linearVelocity.Magnitude > 75 then
			rootPart.AssemblyLinearVelocity = linearVelocity.Unit * 40
		end
		rootPart.AssemblyAngularVelocity = Vector3.new(0, spin.value, 0)

		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)

	spin.updateAntiflingVisual()
end

function spin.stop()
	if spin.setAntifling then
		spin.setAntifling(false)
	end
	spin.releaseCamera()
	if spin.constraint then
		spin.constraint:Destroy()
		spin.constraint = nil
	end
	if spin.attachment then
		spin.attachment:Destroy()
		spin.attachment = nil
	end
	if spin.uprightGyro then
		spin.uprightGyro:Destroy()
		spin.uprightGyro = nil
	end
	if spin.humanoid and spin.humanoid.Parent and spin.savedAutoRotate ~= nil then
		spin.humanoid.AutoRotate = spin.savedAutoRotate
	end
	spin.humanoid = nil
	spin.savedAutoRotate = nil

	local character = player.Character
	local currentRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if currentRootPart then
		local oldConstraint = currentRootPart:FindFirstChild("WaveSpinAngularVelocity")
		if oldConstraint then
			oldConstraint:Destroy()
		end
		local oldAttachment = currentRootPart:FindFirstChild("WaveSpinAttachment")
		if oldAttachment then
			oldAttachment:Destroy()
		end
		local oldGyro = currentRootPart:FindFirstChild("WaveSpinUprightGyro")
		if oldGyro then
			oldGyro:Destroy()
		end
	end
	if spin.rootPart and spin.rootPart.Parent then
		if spin.savedLinearVelocity then
			spin.rootPart.AssemblyLinearVelocity = spin.savedLinearVelocity
		end
		if spin.savedAngularVelocity then
			spin.rootPart.AssemblyAngularVelocity = spin.savedAngularVelocity
		end
	end
	spin.rootPart = nil
	spin.savedLinearVelocity = nil
	spin.savedAngularVelocity = nil
end

function spin.setValue(value)
	local numberValue = tonumber(value)
	if not numberValue then
		spin.box.Text = tostring(spin.value)
		return
	end

	numberValue = math.clamp(numberValue, -500, 500)
	if math.abs(numberValue) < 0.001 then
		numberValue = 0
	end

	local restoreAntifling = spin.antiflingEnabled and numberValue ~= 0
	spin.stop()
	spin.value = numberValue
	spin.box.Text = string.format("%g", numberValue)
	if numberValue == 0 then
		spin.updateAntiflingVisual()
		return
	end
	spin.setDropdownOpen(true)
	spin.updateAntiflingVisual()

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then
		return
	end

	spin.rootPart = rootPart
	spin.savedLinearVelocity = rootPart.AssemblyLinearVelocity
	spin.savedAngularVelocity = rootPart.AssemblyAngularVelocity
	spin.humanoid = humanoid
	spin.savedAutoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false

	spin.attachment = Instance.new("Attachment")
	spin.attachment.Name = "WaveSpinAttachment"
	spin.attachment.Parent = rootPart

	spin.constraint = Instance.new("AngularVelocity")
	spin.constraint.Name = "WaveSpinAngularVelocity"
	spin.constraint.Attachment0 = spin.attachment
	spin.constraint.RelativeTo = Enum.ActuatorRelativeTo.World
	spin.constraint.AngularVelocity = Vector3.new(0, numberValue, 0)
	spin.constraint.MaxTorque = math.huge
	spin.constraint.Parent = rootPart

	spin.uprightGyro = Instance.new("BodyGyro")
	spin.uprightGyro.Name = "WaveSpinUprightGyro"
	spin.uprightGyro.MaxTorque = Vector3.new(math.huge, 0, math.huge)
	spin.uprightGyro.P = 100000
	spin.uprightGyro.D = 1000
	spin.uprightGyro.CFrame = CFrame.fromOrientation(0, math.rad(rootPart.Orientation.Y), 0)
	spin.uprightGyro.Parent = rootPart

	spin.startCamera(rootPart)
	if restoreAntifling then
		spin.setAntifling(true)
	end
end

spin.box.FocusLost:Connect(function()
	spin.setValue(spin.box.Text)
end)

spin.dropdownButton.Activated:Connect(function()
	playSound(clickSound)
	spin.setDropdownOpen(not spin.dropdownOpen)
end)

spin.antiflingToggle.Activated:Connect(function()
	if spin.value == 0 then
		return
	end
	playSound(clickSound)
	spin.setAntifling(not spin.antiflingEnabled)
end)

local vehicleFlyEnabled = false
local vehicleFlyConnection
local vehicleFlyVelocity
local vehicleFlyGyro
local vehicleFlySavedState

local function getVehicleSeat()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	if seat and seat:IsA("VehicleSeat") then
		return seat
	end
	return nil
end

local function stopVehicleFly()
	if vehicleFlyConnection then
		vehicleFlyConnection:Disconnect()
		vehicleFlyConnection = nil
	end
	if vehicleFlyVelocity then
		vehicleFlyVelocity:Destroy()
		vehicleFlyVelocity = nil
	end
	if vehicleFlyGyro then
		vehicleFlyGyro:Destroy()
		vehicleFlyGyro = nil
	end
	if vehicleFlySavedState then
		if vehicleFlySavedState.seat and vehicleFlySavedState.seat.Parent then
			vehicleFlySavedState.seat.AssemblyLinearVelocity = vehicleFlySavedState.linearVelocity
			vehicleFlySavedState.seat.AssemblyAngularVelocity = vehicleFlySavedState.angularVelocity
		end
		vehicleFlySavedState = nil
	end
end

local function setVehicleFly(enabled)
	stopVehicleFly()
	if not enabled then
		vehicleFlyEnabled = false
		setSimpleSwitchVisual(switchUI.vehicleFly[1], switchUI.vehicleFly[2], switchUI.vehicleFly[3], false)
		return
	end

	local seat = getVehicleSeat()
	local vehicle = seat and seat:FindFirstAncestorOfClass("Model")
	if not seat or not vehicle then
		vehicleFlyEnabled = false
		setSimpleSwitchVisual(switchUI.vehicleFly[1], switchUI.vehicleFly[2], switchUI.vehicleFly[3], false)
		return
	end

	vehicleFlyEnabled = true
	vehicleFlySavedState = {
		seat = seat,
		linearVelocity = seat.AssemblyLinearVelocity,
		angularVelocity = seat.AssemblyAngularVelocity,
	}
	vehicleFlyVelocity = Instance.new("BodyVelocity")
	vehicleFlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	vehicleFlyVelocity.Velocity = Vector3.zero
	vehicleFlyVelocity.Parent = seat

	vehicleFlyGyro = Instance.new("BodyGyro")
	vehicleFlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	vehicleFlyGyro.P = 10000
	vehicleFlyGyro.CFrame = seat.CFrame
	vehicleFlyGyro.Parent = seat

	vehicleFlyConnection = RunService.RenderStepped:Connect(function()
		if not vehicleFlyEnabled or not seat.Parent or getVehicleSeat() ~= seat then
			setVehicleFly(false)
			return
		end
		local camera = workspace.CurrentCamera
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local direction = humanoid and humanoid.MoveDirection or Vector3.zero
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			vertical += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			vertical -= 1
		end
		local cameraDirection = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
		local cameraRight = camera and camera.CFrame.RightVector or Vector3.new(1, 0, 0)
		local forwardInput = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
		forwardInput -= UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
		local rightInput = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
		rightInput -= UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0
		local movementDirection = cameraDirection * forwardInput + cameraRight * rightInput
		local movement = Vector3.zero
		if movementDirection.Magnitude > 0 then
			movement += movementDirection.Unit * 70
		end
		movement += Vector3.new(0, vertical * 70, 0)
		vehicleFlyVelocity.Velocity = movement
		vehicleFlyGyro.CFrame = CFrame.lookAt(seat.Position, seat.Position + cameraDirection)
	end)
	setSimpleSwitchVisual(switchUI.vehicleFly[1], switchUI.vehicleFly[2], switchUI.vehicleFly[3], true)
end

switchUI.vehicleFly[1].Activated:Connect(function()
	playSound(clickSound)
	setVehicleFly(not vehicleFlyEnabled)
end)

local floatEnabled = false
local floatConnection
local floatVelocity
local floatSavedState

local function stopFloat()
	if floatConnection then
		floatConnection:Disconnect()
		floatConnection = nil
	end
	if floatVelocity then
		floatVelocity:Destroy()
		floatVelocity = nil
	end
	if floatSavedState then
		if floatSavedState.rootPart and floatSavedState.rootPart.Parent then
			floatSavedState.rootPart.AssemblyLinearVelocity = floatSavedState.linearVelocity
			floatSavedState.rootPart.AssemblyAngularVelocity = floatSavedState.angularVelocity
		end
		floatSavedState = nil
	end
end

local function setFloat(enabled)
	stopFloat()
	if not enabled then
		floatEnabled = false
		setSimpleSwitchVisual(switchUI.float[1], switchUI.float[2], switchUI.float[3], false)
		return
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		floatEnabled = false
		setSimpleSwitchVisual(switchUI.float[1], switchUI.float[2], switchUI.float[3], false)
		return
	end

	floatEnabled = true
	floatSavedState = {
		rootPart = rootPart,
		linearVelocity = rootPart.AssemblyLinearVelocity,
		angularVelocity = rootPart.AssemblyAngularVelocity,
	}
	floatVelocity = Instance.new("BodyVelocity")
	floatVelocity.MaxForce = Vector3.new(0, math.huge, 0)
	floatVelocity.Velocity = Vector3.new(0, 0, 0)
	floatVelocity.Parent = rootPart
	floatConnection = RunService.RenderStepped:Connect(function()
		if not floatEnabled or not rootPart.Parent then
			setFloat(false)
			return
		end
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			vertical = 45
		elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			vertical = -45
		end
		floatVelocity.Velocity = Vector3.new(0, vertical, 0)
	end)
	setSimpleSwitchVisual(switchUI.float[1], switchUI.float[2], switchUI.float[3], true)
end

switchUI.float[1].Activated:Connect(function()
	playSound(clickSound)
	setFloat(not floatEnabled)
end)

local infiniteJumpEnabled = false
local infiniteJumpConnection

local function setInfiniteJump(enabled)
	infiniteJumpEnabled = enabled
	if infiniteJumpConnection then
		infiniteJumpConnection:Disconnect()
		infiniteJumpConnection = nil
	end

	if enabled then
		infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end

	setSimpleSwitchVisual(switchUI.infiniteJump[1], switchUI.infiniteJump[2], switchUI.infiniteJump[3], enabled)
end

switchUI.infiniteJump[1].Activated:Connect(function()
	playSound(clickSound)
	setInfiniteJump(not infiniteJumpEnabled)
end)

local espEnabled = false
local nametagsEnabled = false
local espDropdownOpen = false
local espHighlights = {}
local espCharacterConnections = {}
local nametagGuis = {}
local nametagUpdateConnection
local nametagEpoch = 0
local nametagGenerations = {}

local function setESPDropdownOpen(open)
	espDropdownOpen = open
	if open then nametagRow.Visible = true end
	espDropdownButton.Text = open and "^" or "v"
	local resize = TweenService:Create(espCard, TweenInfo.new(0.25, open and Enum.EasingStyle.Back or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -3, 0, open and 160 or 86)})
	resize:Play()
	if not open then
		resize.Completed:Once(function()
			if not espDropdownOpen then nametagRow.Visible = false end
		end)
	end
end

local function setNametagSwitchVisual()
	if not espEnabled then
		nametagToggle.Active = false
		nametagToggle.Selectable = false
		nametagToggle.BackgroundColor3 = colors.input
		nametagKnob.Position = UDim2.new(0, 3, 0.5, 0)
		nametagKnob.BackgroundColor3 = colors.faint
		nametagTitle.TextColor3 = colors.faint
		nametagDescription.TextColor3 = colors.faint
		nametagStatus.Text = "LOCKED"
		nametagStatus.TextColor3 = colors.faint
		return
	end

	nametagToggle.Active = true
	nametagToggle.Selectable = true
	nametagTitle.TextColor3 = colors.text
	nametagDescription.TextColor3 = colors.muted
	nametagToggle.BackgroundColor3 = nametagsEnabled and colors.accent or colors.switchOff
	nametagKnob.Position = nametagsEnabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	nametagKnob.BackgroundColor3 = Color3.fromRGB(231, 238, 250)
	nametagStatus.Text = nametagsEnabled and "ON" or "OFF"
	nametagStatus.TextColor3 = nametagsEnabled and colors.success or colors.faint
end

local function removeNametag(targetPlayer)
	nametagGenerations[targetPlayer] = (nametagGenerations[targetPlayer] or 0) + 1
	local data = nametagGuis[targetPlayer]
	if data then
		data.gui:Destroy()
		nametagGuis[targetPlayer] = nil
	end
end

local function addNametag(targetPlayer, character)
	if not espEnabled or not nametagsEnabled or targetPlayer == player then
		return
	end

	removeNametag(targetPlayer)
	local generation = nametagGenerations[targetPlayer]
	local epoch = nametagEpoch

	task.spawn(function()
		local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
		if not head
			or not espEnabled
			or not nametagsEnabled
			or nametagEpoch ~= epoch
			or nametagGenerations[targetPlayer] ~= generation
			or targetPlayer.Character ~= character then
			return
		end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "WavePlayerNametag"
		billboard.Adornee = head
		billboard.Size = UDim2.fromOffset(180, 48)
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.Parent = character

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.Text = targetPlayer.Name .. "\n-- studs"
		label.TextColor3 = colors.text
		label.TextSize = 14
		label.TextStrokeColor3 = colors.background
		label.TextStrokeTransparency = 0.2
		label.TextWrapped = true
		label.Parent = billboard

		nametagGuis[targetPlayer] = {
			gui = billboard,
			label = label,
			character = character,
		}
	end)
end

local function stopNametagUpdates()
	if nametagUpdateConnection then
		nametagUpdateConnection:Disconnect()
		nametagUpdateConnection = nil
	end
end

local function startNametagUpdates()
	stopNametagUpdates()
	nametagUpdateConnection = RunService.RenderStepped:Connect(function()
		if not espEnabled or not nametagsEnabled then
			return
		end

		local localCharacter = player.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
		if not localRoot then
			return
		end

		for targetPlayer, data in pairs(nametagGuis) do
			local targetRoot = data.character and data.character:FindFirstChild("HumanoidRootPart")
			if data.gui.Parent and targetRoot then
				local distance = (localRoot.Position - targetRoot.Position).Magnitude
				data.label.Text = string.format("%s\n%d studs", targetPlayer.Name, math.floor(distance + 0.5))
			end
		end
	end)
end

local function setNametags(enabled)
	enabled = enabled and espEnabled
	nametagsEnabled = enabled

	if enabled then
		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			if targetPlayer ~= player and targetPlayer.Character then
				addNametag(targetPlayer, targetPlayer.Character)
			end
		end
		startNametagUpdates()
	else
		nametagEpoch += 1
		stopNametagUpdates()
		for _, data in pairs(nametagGuis) do
			data.gui:Destroy()
		end
		table.clear(nametagGuis)
		table.clear(nametagGenerations)
	end

	setNametagSwitchVisual()
end

local function removeESPHighlight(targetPlayer)
	local highlight = espHighlights[targetPlayer]
	if highlight then
		highlight:Destroy()
		espHighlights[targetPlayer] = nil
	end
end

local function addESPHighlight(targetPlayer, character)
	if not espEnabled or targetPlayer == player then
		return
	end

	removeESPHighlight(targetPlayer)

	local highlight = Instance.new("Highlight")
	highlight.Name = "WavePlayerESP"
	highlight.Adornee = character
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = colors.accent
	highlight.FillTransparency = 0.45
	highlight.OutlineColor = colors.text
	highlight.OutlineTransparency = 0
	highlight.Parent = character
	espHighlights[targetPlayer] = highlight
end

local function watchESPPlayer(targetPlayer)
	if targetPlayer == player then
		return
	end

	if espCharacterConnections[targetPlayer] then
		espCharacterConnections[targetPlayer]:Disconnect()
	end

	espCharacterConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(function(character)
		addESPHighlight(targetPlayer, character)
		if nametagsEnabled then
			addNametag(targetPlayer, character)
		end
	end)

	if targetPlayer.Character then
		addESPHighlight(targetPlayer, targetPlayer.Character)
		if nametagsEnabled then
			addNametag(targetPlayer, targetPlayer.Character)
		end
	end
end

local function setESP(enabled)
	espEnabled = enabled

	if enabled then
		setESPDropdownOpen(true)
		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			watchESPPlayer(targetPlayer)
		end
	else
		setNametags(false)
		for _, highlight in pairs(espHighlights) do
			highlight:Destroy()
		end
		table.clear(espHighlights)
		for _, connection in pairs(espCharacterConnections) do
			connection:Disconnect()
		end
		table.clear(espCharacterConnections)
	end

	setSimpleSwitchVisual(switchUI.esp[1], switchUI.esp[2], switchUI.esp[3], enabled)
	setNametagSwitchVisual()
end

Players.PlayerAdded:Connect(function(targetPlayer)
	if espEnabled then
		watchESPPlayer(targetPlayer)
	end
end)

Players.PlayerRemoving:Connect(function(targetPlayer)
	removeESPHighlight(targetPlayer)
	removeNametag(targetPlayer)
	nametagGenerations[targetPlayer] = nil
	local connection = espCharacterConnections[targetPlayer]
	if connection then
		connection:Disconnect()
		espCharacterConnections[targetPlayer] = nil
	end
end)

espDropdownButton.Activated:Connect(function()
	playSound(clickSound)
	setESPDropdownOpen(not espDropdownOpen)
end)

nametagToggle.Activated:Connect(function()
	if not espEnabled then
		return
	end
	playSound(clickSound)
	setNametags(not nametagsEnabled)
end)

switchUI.esp[1].Activated:Connect(function()
	playSound(clickSound)
	setESP(not espEnabled)
end)

function themeSystem.healthDisplay.clearPlayer(targetPlayer)
	local data = themeSystem.healthDisplay.guis[targetPlayer]
	if data then
		if data.healthConnection then data.healthConnection:Disconnect() end
		if data.maxHealthConnection then data.maxHealthConnection:Disconnect() end
		if data.gui then data.gui:Destroy() end
		themeSystem.healthDisplay.guis[targetPlayer] = nil
	end
end

function themeSystem.healthDisplay.addPlayer(targetPlayer, character)
	if not themeSystem.healthDisplay.enabled then return end
	themeSystem.healthDisplay.clearPlayer(targetPlayer)
	task.spawn(function()
		local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
		if not head or not humanoid or not themeSystem.healthDisplay.enabled or targetPlayer.Character ~= character then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "WaveHealthDisplay"
		billboard.Adornee = head
		billboard.Size = UDim2.fromOffset(170, 28)
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 4.25, 0)
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.Parent = character

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextSize = 13
		label.TextStrokeColor3 = colors.background
		label.TextStrokeTransparency = 0.15
		label.Parent = billboard

		local function update()
			local maximum = math.max(humanoid.MaxHealth, 1)
			local health = math.clamp(humanoid.Health, 0, maximum)
			local ratio = health / maximum
			label.Text = string.format("%d / %d HP", math.floor(health + 0.5), math.floor(maximum + 0.5))
			label.TextColor3 = Color3.fromRGB(255, 88, 105):Lerp(Color3.fromRGB(74, 235, 155), ratio)
		end

		update()
		themeSystem.healthDisplay.guis[targetPlayer] = {
			gui = billboard,
			healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(update),
			maxHealthConnection = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update),
		}
	end)
end

function themeSystem.healthDisplay.watchPlayer(targetPlayer)
	local oldConnection = themeSystem.healthDisplay.characterConnections[targetPlayer]
	if oldConnection then oldConnection:Disconnect() end
	themeSystem.healthDisplay.characterConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(function(character)
		themeSystem.healthDisplay.addPlayer(targetPlayer, character)
	end)
	if targetPlayer.Character then
		themeSystem.healthDisplay.addPlayer(targetPlayer, targetPlayer.Character)
	end
end

function themeSystem.healthDisplay.setEnabled(enabled)
	themeSystem.healthDisplay.enabled = enabled == true
	if themeSystem.healthDisplay.enabled then
		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			themeSystem.healthDisplay.watchPlayer(targetPlayer)
		end
	else
		for _, data in pairs(themeSystem.healthDisplay.guis) do
			if data.healthConnection then data.healthConnection:Disconnect() end
			if data.maxHealthConnection then data.maxHealthConnection:Disconnect() end
			if data.gui then data.gui:Destroy() end
		end
		for _, connection in pairs(themeSystem.healthDisplay.characterConnections) do connection:Disconnect() end
		table.clear(themeSystem.healthDisplay.guis)
		table.clear(themeSystem.healthDisplay.characterConnections)
	end
	setSimpleSwitchVisual(switchUI.healthDisplay[1], switchUI.healthDisplay[2], switchUI.healthDisplay[3], themeSystem.healthDisplay.enabled)
end

function themeSystem.waveTags.isWaveUser(targetPlayer)
	if string.upper(targetPlayer.Name) == "IHAMGAY" then return true, true end
	return targetPlayer:GetAttribute("WaveUser") == true or targetPlayer:GetAttribute("WaveMenuLoaded") == true, false
end

function themeSystem.waveTags.clearPlayer(targetPlayer)
	local gui = themeSystem.waveTags.guis[targetPlayer]
	if gui then gui:Destroy() end
	themeSystem.waveTags.guis[targetPlayer] = nil
end

function themeSystem.waveTags.refreshPlayer(targetPlayer, character)
	themeSystem.waveTags.clearPlayer(targetPlayer)
	if not themeSystem.waveTags.enabled then return end
	local isWaveUser, isOwner = themeSystem.waveTags.isWaveUser(targetPlayer)
	if not isWaveUser then return end
	task.spawn(function()
		local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
		if not head or not themeSystem.waveTags.enabled or targetPlayer.Character ~= character then return end
		local stillWaveUser, stillOwner = themeSystem.waveTags.isWaveUser(targetPlayer)
		if not stillWaveUser then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "WaveUserTag"
		billboard.Adornee = head
		billboard.Size = UDim2.fromOffset(190, 26)
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 5.35, 0)
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.Parent = character

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBlack
		label.Text = stillOwner and "★  WAVE OWNER  ★" or "◆  WAVE USER  ◆"
		label.TextColor3 = stillOwner and Color3.fromRGB(255, 205, 66) or colors.accent2
		label.TextSize = 14
		label.TextStrokeColor3 = colors.background
		label.TextStrokeTransparency = 0.08
		label.Parent = billboard
		themeSystem.waveTags.guis[targetPlayer] = billboard
	end)
end

function themeSystem.waveTags.watchPlayer(targetPlayer)
	local oldConnections = themeSystem.waveTags.playerConnections[targetPlayer]
	if oldConnections then
		for _, connection in ipairs(oldConnections) do connection:Disconnect() end
	end
	local connections = {}
	table.insert(connections, targetPlayer.CharacterAdded:Connect(function(character)
		themeSystem.waveTags.refreshPlayer(targetPlayer, character)
	end))
	for _, attributeName in ipairs({"WaveUser", "WaveMenuLoaded"}) do
		table.insert(connections, targetPlayer:GetAttributeChangedSignal(attributeName):Connect(function()
			if targetPlayer.Character then themeSystem.waveTags.refreshPlayer(targetPlayer, targetPlayer.Character) end
		end))
	end
	themeSystem.waveTags.playerConnections[targetPlayer] = connections
	if targetPlayer.Character then themeSystem.waveTags.refreshPlayer(targetPlayer, targetPlayer.Character) end
end

function themeSystem.waveTags.setEnabled(enabled)
	themeSystem.waveTags.enabled = enabled == true
	if themeSystem.waveTags.enabled then
		for _, targetPlayer in ipairs(Players:GetPlayers()) do themeSystem.waveTags.watchPlayer(targetPlayer) end
	else
		for _, gui in pairs(themeSystem.waveTags.guis) do gui:Destroy() end
		for _, connections in pairs(themeSystem.waveTags.playerConnections) do
			for _, connection in ipairs(connections) do connection:Disconnect() end
		end
		table.clear(themeSystem.waveTags.guis)
		table.clear(themeSystem.waveTags.playerConnections)
	end
	setSimpleSwitchVisual(switchUI.waveTags[1], switchUI.waveTags[2], switchUI.waveTags[3], themeSystem.waveTags.enabled)
end

pcall(function() player:SetAttribute("WaveMenuLoaded", true) end)
task.defer(function()
	local presenceRemote = ReplicatedStorage:FindFirstChild("WaveUserPresence")
	if presenceRemote and presenceRemote:IsA("RemoteEvent") then
		pcall(function() presenceRemote:FireServer(true) end)
	end
end)

Players.PlayerAdded:Connect(function(targetPlayer)
	if themeSystem.healthDisplay.enabled then themeSystem.healthDisplay.watchPlayer(targetPlayer) end
	if themeSystem.waveTags.enabled then themeSystem.waveTags.watchPlayer(targetPlayer) end
end)

Players.PlayerRemoving:Connect(function(targetPlayer)
	themeSystem.healthDisplay.clearPlayer(targetPlayer)
	local healthConnection = themeSystem.healthDisplay.characterConnections[targetPlayer]
	if healthConnection then healthConnection:Disconnect() end
	themeSystem.healthDisplay.characterConnections[targetPlayer] = nil
	themeSystem.waveTags.clearPlayer(targetPlayer)
	local tagConnections = themeSystem.waveTags.playerConnections[targetPlayer]
	if tagConnections then for _, connection in ipairs(tagConnections) do connection:Disconnect() end end
	themeSystem.waveTags.playerConnections[targetPlayer] = nil
end)

switchUI.healthDisplay[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.healthDisplay.setEnabled(not themeSystem.healthDisplay.enabled)
end)

switchUI.waveTags[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.waveTags.setEnabled(not themeSystem.waveTags.enabled)
end)

function themeSystem.instantPrompts.apply(prompt)
	if not themeSystem.instantPrompts.enabled or not prompt:IsA("ProximityPrompt") then return end
	if themeSystem.instantPrompts.prompts[prompt] then return end
	local data = {holdDuration = prompt.HoldDuration, changing = false}
	themeSystem.instantPrompts.prompts[prompt] = data
	data.connection = prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
		if themeSystem.instantPrompts.enabled and not data.changing and prompt.HoldDuration ~= 0 then
			data.changing = true
			prompt.HoldDuration = 0
			data.changing = false
		end
	end)
	data.changing = true
	prompt.HoldDuration = 0
	data.changing = false
end

function themeSystem.instantPrompts.setEnabled(enabled)
	themeSystem.instantPrompts.enabled = enabled == true
	if themeSystem.instantPrompts.enabled then
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") then themeSystem.instantPrompts.apply(descendant) end
		end
		if themeSystem.instantPrompts.descendantConnection then themeSystem.instantPrompts.descendantConnection:Disconnect() end
		themeSystem.instantPrompts.descendantConnection = workspace.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("ProximityPrompt") then themeSystem.instantPrompts.apply(descendant) end
		end)
	else
		if themeSystem.instantPrompts.descendantConnection then
			themeSystem.instantPrompts.descendantConnection:Disconnect()
			themeSystem.instantPrompts.descendantConnection = nil
		end
		for prompt, data in pairs(themeSystem.instantPrompts.prompts) do
			if data.connection then data.connection:Disconnect() end
			if prompt.Parent then
				pcall(function() prompt.HoldDuration = data.holdDuration end)
			end
		end
		table.clear(themeSystem.instantPrompts.prompts)
	end
	setSimpleSwitchVisual(switchUI.instantPrompts[1], switchUI.instantPrompts[2], switchUI.instantPrompts[3], themeSystem.instantPrompts.enabled)
end

switchUI.instantPrompts[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.instantPrompts.setEnabled(not themeSystem.instantPrompts.enabled)
end)

themeSystem.coordinates.frame = Instance.new("Frame")
themeSystem.coordinates.frame.Name = "WaveCoordinatesDisplay"
themeSystem.coordinates.frame.AnchorPoint = Vector2.new(1, 0)
themeSystem.coordinates.frame.Position = UDim2.new(1, -18, 0, 64)
themeSystem.coordinates.frame.Size = UDim2.fromOffset(236, 58)
themeSystem.coordinates.frame.BackgroundColor3 = colors.panel
themeSystem.coordinates.frame.BackgroundTransparency = 0.08
themeSystem.coordinates.frame.BorderSizePixel = 0
themeSystem.coordinates.frame.Visible = false
themeSystem.coordinates.frame.ZIndex = 80
themeSystem.coordinates.frame.Parent = screenGui
addCorner(themeSystem.coordinates.frame, 10)

themeSystem.coordinates.stroke = Instance.new("UIStroke")
themeSystem.coordinates.stroke.Color = colors.accent
themeSystem.coordinates.stroke.Transparency = 0.25
themeSystem.coordinates.stroke.Thickness = 1.2
themeSystem.coordinates.stroke.Parent = themeSystem.coordinates.frame

themeSystem.coordinates.title = Instance.new("TextLabel")
themeSystem.coordinates.title.Position = UDim2.fromOffset(12, 7)
themeSystem.coordinates.title.Size = UDim2.new(1, -24, 0, 15)
themeSystem.coordinates.title.BackgroundTransparency = 1
themeSystem.coordinates.title.Font = Enum.Font.GothamBold
themeSystem.coordinates.title.Text = "POSITION"
themeSystem.coordinates.title.TextColor3 = colors.muted
themeSystem.coordinates.title.TextSize = 9
themeSystem.coordinates.title.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.coordinates.title.ZIndex = 81
themeSystem.coordinates.title.Parent = themeSystem.coordinates.frame

themeSystem.coordinates.value = Instance.new("TextLabel")
themeSystem.coordinates.value.Position = UDim2.fromOffset(12, 24)
themeSystem.coordinates.value.Size = UDim2.new(1, -24, 0, 25)
themeSystem.coordinates.value.BackgroundTransparency = 1
themeSystem.coordinates.value.Font = Enum.Font.Code
themeSystem.coordinates.value.Text = "X  --    Y  --    Z  --"
themeSystem.coordinates.value.TextColor3 = colors.text
themeSystem.coordinates.value.TextSize = 13
themeSystem.coordinates.value.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.coordinates.value.ZIndex = 81
themeSystem.coordinates.value.Parent = themeSystem.coordinates.frame

function themeSystem.coordinates.update()
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local position = rootPart.Position
		themeSystem.coordinates.value.Text = string.format("X  %.1f    Y  %.1f    Z  %.1f", position.X, position.Y, position.Z)
	else
		themeSystem.coordinates.value.Text = "X  --    Y  --    Z  --"
	end
end

function themeSystem.coordinates.setEnabled(enabled)
	themeSystem.coordinates.enabled = enabled == true
	if themeSystem.coordinates.connection then
		themeSystem.coordinates.connection:Disconnect()
		themeSystem.coordinates.connection = nil
	end
	themeSystem.coordinates.frame.Visible = themeSystem.coordinates.enabled
	if themeSystem.coordinates.enabled then
		themeSystem.coordinates.update()
		themeSystem.coordinates.connection = RunService.RenderStepped:Connect(themeSystem.coordinates.update)
	end
	setSimpleSwitchVisual(switchUI.coordinates[1], switchUI.coordinates[2], switchUI.coordinates[3], themeSystem.coordinates.enabled)
end

switchUI.coordinates[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.coordinates.setEnabled(not themeSystem.coordinates.enabled)
end)

function themeSystem.autoSell.updateLocationText()
	if themeSystem.autoSell.sellCFrame then
		local position = themeSystem.autoSell.sellCFrame.Position
		themeSystem.autoSell.locationDescription.Text = string.format("SAVED  X %.0f  Y %.0f  Z %.0f  •  EVERY %.1fs", position.X, position.Y, position.Z, themeSystem.autoSell.interval)
		themeSystem.autoSell.locationDescription.TextColor3 = colors.success
	else
		themeSystem.autoSell.locationDescription.Text = "Stand in the sell zone, then press here."
		themeSystem.autoSell.locationDescription.TextColor3 = colors.muted
	end
end

function themeSystem.autoSell.setLocation()
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end
	themeSystem.autoSell.sellCFrame = rootPart.CFrame
	themeSystem.autoSell.updateLocationText()
	return true
end

function themeSystem.autoSell.setInterval(value)
	themeSystem.autoSell.interval = math.clamp(tonumber(value) or themeSystem.autoSell.interval, 1, 120)
	themeSystem.autoSell.updateLocationText()
end

function themeSystem.autoSell.visit()
	if themeSystem.autoSell.visiting or not themeSystem.autoSell.sellCFrame then return end
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid or humanoid.Health <= 0 then return end
	themeSystem.autoSell.visiting = true
	local returnCFrame = rootPart.CFrame
	rootPart.CFrame = themeSystem.autoSell.sellCFrame
	task.wait(0.65)
	if rootPart.Parent and humanoid.Health > 0 then rootPart.CFrame = returnCFrame end
	themeSystem.autoSell.visiting = false
end

function themeSystem.autoSell.setEnabled(enabled)
	enabled = enabled == true
	if enabled and not themeSystem.autoSell.sellCFrame then
		themeSystem.autoSell.enabled = false
		setSimpleSwitchVisual(switchUI.autoSell[1], switchUI.autoSell[2], switchUI.autoSell[3], false)
		switchUI.autoSell[3].Text = "SET LOCATION"
		switchUI.autoSell[3].TextColor3 = colors.danger
		return false
	end
	themeSystem.autoSell.enabled = enabled
	themeSystem.autoSell.generation += 1
	local generation = themeSystem.autoSell.generation
	setSimpleSwitchVisual(switchUI.autoSell[1], switchUI.autoSell[2], switchUI.autoSell[3], enabled)
	if enabled then
		task.spawn(function()
			while themeSystem.autoSell.enabled and themeSystem.autoSell.generation == generation do
				themeSystem.autoSell.visit()
				local elapsed = 0
				while elapsed < themeSystem.autoSell.interval and themeSystem.autoSell.enabled and themeSystem.autoSell.generation == generation do
					elapsed += task.wait(math.min(0.25, themeSystem.autoSell.interval - elapsed))
				end
			end
		end)
	end
	return true
end

themeSystem.autoSell.locationRow.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.autoSell.setLocation()
end)

switchUI.autoSell[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.autoSell.setEnabled(not themeSystem.autoSell.enabled)
end)

function themeSystem.playerTrails.setColor(color)
	if typeof(color) ~= "Color3" then return end
	themeSystem.playerTrails.color = color
	themeSystem.playerTrails.hue = select(1, color:ToHSV())
	themeSystem.playerTrails.colorKnob.Position = UDim2.new(themeSystem.playerTrails.hue, 0, 0.5, 0)
	themeSystem.playerTrails.colorPreview.BackgroundColor3 = color
	for _, data in pairs(themeSystem.playerTrails.trails) do
		if data.trail and data.trail.Parent then data.trail.Color = ColorSequence.new(color) end
	end
end

function themeSystem.playerTrails.setHue(hue)
	hue = math.clamp(tonumber(hue) or 0, 0, 1)
	themeSystem.playerTrails.setColor(Color3.fromHSV(hue, 0.82, 1))
end

function themeSystem.playerTrails.updateHueFromInput(input)
	local width = math.max(themeSystem.playerTrails.colorTrack.AbsoluteSize.X, 1)
	themeSystem.playerTrails.setHue((input.Position.X - themeSystem.playerTrails.colorTrack.AbsolutePosition.X) / width)
end

themeSystem.playerTrails.colorTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		themeSystem.playerTrails.colorDragging = true
		themeSystem.playerTrails.colorTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
		themeSystem.playerTrails.updateHueFromInput(input)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if themeSystem.playerTrails.colorDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == themeSystem.playerTrails.colorTouch) then
		themeSystem.playerTrails.updateHueFromInput(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == themeSystem.playerTrails.colorTouch then
		themeSystem.playerTrails.colorDragging = false
		themeSystem.playerTrails.colorTouch = nil
	end
end)

function themeSystem.playerTrails.clearPlayer(targetPlayer)
	local data = themeSystem.playerTrails.trails[targetPlayer]
	if data then
		if data.trail then data.trail:Destroy() end
		if data.attachment0 then data.attachment0:Destroy() end
		if data.attachment1 then data.attachment1:Destroy() end
		themeSystem.playerTrails.trails[targetPlayer] = nil
	end
end

function themeSystem.playerTrails.addPlayer(targetPlayer, character)
	if not themeSystem.playerTrails.enabled or targetPlayer == player then return end
	themeSystem.playerTrails.clearPlayer(targetPlayer)
	task.spawn(function()
		local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
		if not rootPart or not themeSystem.playerTrails.enabled or targetPlayer.Character ~= character then return end
		local attachment0 = Instance.new("Attachment")
		attachment0.Name = "WaveTrailLeft"
		attachment0.Position = Vector3.new(-0.65, -1.35, 0.3)
		attachment0.Parent = rootPart
		local attachment1 = Instance.new("Attachment")
		attachment1.Name = "WaveTrailRight"
		attachment1.Position = Vector3.new(0.65, -1.35, 0.3)
		attachment1.Parent = rootPart
		local trail = Instance.new("Trail")
		trail.Name = "WavePlayerTrail"
		trail.Attachment0 = attachment0
		trail.Attachment1 = attachment1
		trail.Color = ColorSequence.new(themeSystem.playerTrails.color)
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.12),
			NumberSequenceKeypoint.new(0.72, 0.45),
			NumberSequenceKeypoint.new(1, 1),
		})
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		})
		trail.Lifetime = 3.5
		trail.MinLength = 0.08
		trail.FaceCamera = true
		trail.LightEmission = 0
		trail.LightInfluence = 1
		trail.Parent = rootPart
		themeSystem.playerTrails.trails[targetPlayer] = {trail = trail, attachment0 = attachment0, attachment1 = attachment1}
	end)
end

function themeSystem.playerTrails.watchPlayer(targetPlayer)
	if targetPlayer == player then return end
	local oldConnection = themeSystem.playerTrails.characterConnections[targetPlayer]
	if oldConnection then oldConnection:Disconnect() end
	themeSystem.playerTrails.characterConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(function(character)
		themeSystem.playerTrails.addPlayer(targetPlayer, character)
	end)
	if targetPlayer.Character then themeSystem.playerTrails.addPlayer(targetPlayer, targetPlayer.Character) end
end

function themeSystem.playerTrails.setEnabled(enabled)
	themeSystem.playerTrails.enabled = enabled == true
	if themeSystem.playerTrails.enabled then
		for _, targetPlayer in ipairs(Players:GetPlayers()) do themeSystem.playerTrails.watchPlayer(targetPlayer) end
	else
		local trackedPlayers = {}
		for targetPlayer in pairs(themeSystem.playerTrails.trails) do table.insert(trackedPlayers, targetPlayer) end
		for _, targetPlayer in ipairs(trackedPlayers) do themeSystem.playerTrails.clearPlayer(targetPlayer) end
		for _, connection in pairs(themeSystem.playerTrails.characterConnections) do connection:Disconnect() end
		table.clear(themeSystem.playerTrails.characterConnections)
	end
	setSimpleSwitchVisual(switchUI.playerTrails[1], switchUI.playerTrails[2], switchUI.playerTrails[3], themeSystem.playerTrails.enabled)
end

Players.PlayerAdded:Connect(function(targetPlayer)
	if themeSystem.playerTrails.enabled then themeSystem.playerTrails.watchPlayer(targetPlayer) end
end)
Players.PlayerRemoving:Connect(function(targetPlayer)
	themeSystem.playerTrails.clearPlayer(targetPlayer)
	local connection = themeSystem.playerTrails.characterConnections[targetPlayer]
	if connection then connection:Disconnect() end
	themeSystem.playerTrails.characterConnections[targetPlayer] = nil
end)

switchUI.playerTrails[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.playerTrails.setEnabled(not themeSystem.playerTrails.enabled)
end)

function themeSystem.aimbot.isOpponent(targetPlayer)
	if targetPlayer == player then
		return false
	end
	if player.Team and targetPlayer.Team and not player.Neutral and not targetPlayer.Neutral then
		return player.Team ~= targetPlayer.Team
	end
	return true
end

function themeSystem.aimbot.findTarget(camera)
	local mousePosition = UserInputService:GetMouseLocation()
	local closestPart
	local closestDistance = themeSystem.aimbot.maxScreenDistance
	local localCharacter = player.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local origin = localRoot and localRoot.Position or camera.CFrame.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = localCharacter and {localCharacter} or {}
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if themeSystem.aimbot.isOpponent(targetPlayer) then
			local character = targetPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local targetPart = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
			local worldDistance = targetPart and (targetPart.Position - origin).Magnitude or math.huge
			if humanoid and humanoid.Health > 0 and targetPart and worldDistance <= themeSystem.aimbot.maxWorldDistance then
				local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				if onScreen and screenPosition.Z > 0 then
					local direction = targetPart.Position - camera.CFrame.Position
					local obstruction = workspace:Raycast(camera.CFrame.Position, direction, raycastParams)
					local visible = not obstruction or obstruction.Instance:IsDescendantOf(character)
					if visible then
						local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closestPart = targetPart
						end
					end
				end
			end
		end
	end
	return closestPart
end

function themeSystem.aimbot.setSmoothness(value)
	themeSystem.aimbot.smoothness = math.clamp(math.floor((tonumber(value) or themeSystem.aimbot.defaultSmoothness) + 0.5), 1, 25)
	themeSystem.aimbot.smoothingSpeed = 26 - themeSystem.aimbot.smoothness
	local alpha = (themeSystem.aimbot.smoothness - 1) / 24
	themeSystem.aimbot.fill.Size = UDim2.new(alpha, 0, 1, 0)
	themeSystem.aimbot.knob.Position = UDim2.new(alpha, 0, 0.5, 0)
	themeSystem.aimbot.valueLabel.Text = "SMOOTHNESS " .. tostring(themeSystem.aimbot.smoothness)
end

function themeSystem.aimbot.updateSmoothnessFromInput(input)
	if themeSystem.aimbot.track.AbsoluteSize.X <= 0 then
		return
	end
	local alpha = math.clamp(
		(input.Position.X - themeSystem.aimbot.track.AbsolutePosition.X) / themeSystem.aimbot.track.AbsoluteSize.X,
		0,
		1
	)
	themeSystem.aimbot.setSmoothness(1 + alpha * 24)
end

function themeSystem.aimbot.beginSmoothnessDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		themeSystem.aimbot.dragging = true
		themeSystem.aimbot.touchInput = nil
		themeSystem.aimbot.updateSmoothnessFromInput(input)
	elseif input.UserInputType == Enum.UserInputType.Touch then
		themeSystem.aimbot.dragging = true
		themeSystem.aimbot.touchInput = input
		themeSystem.aimbot.updateSmoothnessFromInput(input)
	end
end

themeSystem.aimbot.track.InputBegan:Connect(themeSystem.aimbot.beginSmoothnessDrag)
themeSystem.aimbot.knob.InputBegan:Connect(themeSystem.aimbot.beginSmoothnessDrag)
UserInputService.InputChanged:Connect(function(input)
	if themeSystem.aimbot.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == themeSystem.aimbot.touchInput) then
		themeSystem.aimbot.updateSmoothnessFromInput(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == themeSystem.aimbot.touchInput then
		themeSystem.aimbot.dragging = false
		themeSystem.aimbot.touchInput = nil
	end
end)
themeSystem.aimbot.setSmoothness(themeSystem.aimbot.smoothness)

function themeSystem.aimbot.setDropdownOpen(open)
	themeSystem.aimbot.dropdownOpen = open == true
	themeSystem.aimbot.fovRow.Visible = themeSystem.aimbot.dropdownOpen
	themeSystem.aimbot.dropdownButton.Text = themeSystem.aimbot.dropdownOpen and "^" or "v"
	if not themeSystem.aimbot.dropdownOpen then
		themeSystem.aimbot.radiusDropdownOpen = false
		themeSystem.aimbot.radiusDropdownButton.Text = "v"
		themeSystem.aimbot.fovValueLabel.Visible = false
		themeSystem.aimbot.fovTrack.Visible = false
		themeSystem.aimbot.fovRow.Size = UDim2.new(1, -34, 0, 60)
	end
	themeSystem.aimbot.card.Size = UDim2.new(
		1,
		-3,
		0,
		themeSystem.aimbot.dropdownOpen and (themeSystem.aimbot.radiusDropdownOpen and 270 or 216) or 142
	)
end

function themeSystem.aimbot.setRadiusDropdownOpen(open)
	themeSystem.aimbot.radiusDropdownOpen = open == true and themeSystem.aimbot.dropdownOpen
	themeSystem.aimbot.radiusDropdownButton.Text = themeSystem.aimbot.radiusDropdownOpen and "^" or "v"
	themeSystem.aimbot.fovValueLabel.Visible = themeSystem.aimbot.radiusDropdownOpen
	themeSystem.aimbot.fovTrack.Visible = themeSystem.aimbot.radiusDropdownOpen
	themeSystem.aimbot.fovRow.Size = UDim2.new(1, -34, 0, themeSystem.aimbot.radiusDropdownOpen and 112 or 60)
	themeSystem.aimbot.card.Size = UDim2.new(1, -3, 0, themeSystem.aimbot.radiusDropdownOpen and 270 or 216)
end

function themeSystem.aimbot.setFovRadius(value)
	themeSystem.aimbot.fovRadius = math.clamp(math.floor((tonumber(value) or themeSystem.aimbot.defaultFovRadius) + 0.5), 50, 500)
	themeSystem.aimbot.maxScreenDistance = themeSystem.aimbot.fovRadius
	local alpha = (themeSystem.aimbot.fovRadius - 50) / 450
	themeSystem.aimbot.fovFill.Size = UDim2.new(alpha, 0, 1, 0)
	themeSystem.aimbot.fovSliderKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
	themeSystem.aimbot.fovValueLabel.Text = "RADIUS " .. tostring(themeSystem.aimbot.fovRadius) .. " PX"
	themeSystem.aimbot.circle.Size = UDim2.fromOffset(themeSystem.aimbot.fovRadius * 2, themeSystem.aimbot.fovRadius * 2)
end

function themeSystem.aimbot.setFovCircleEnabled(enabled)
	RunService:UnbindFromRenderStep("WaveAdminAimbotFOVCircle")
	themeSystem.aimbot.fovCircleEnabled = enabled == true
	themeSystem.aimbot.circle.Visible = themeSystem.aimbot.fovCircleEnabled
	if themeSystem.aimbot.fovCircleEnabled then
		RunService:BindToRenderStep("WaveAdminAimbotFOVCircle", Enum.RenderPriority.Camera.Value + 3, function()
			if not themeSystem.aimbot.fovCircleEnabled then
				return
			end
			local mousePosition = UserInputService:GetMouseLocation()
			themeSystem.aimbot.circle.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
		end)
	end
	setSimpleSwitchVisual(
		themeSystem.aimbot.fovToggle,
		themeSystem.aimbot.fovKnob,
		themeSystem.aimbot.fovStatus,
		themeSystem.aimbot.fovCircleEnabled
	)
end

function themeSystem.aimbot.updateFovRadiusFromInput(input)
	if themeSystem.aimbot.fovTrack.AbsoluteSize.X <= 0 then
		return
	end
	local alpha = math.clamp(
		(input.Position.X - themeSystem.aimbot.fovTrack.AbsolutePosition.X) / themeSystem.aimbot.fovTrack.AbsoluteSize.X,
		0,
		1
	)
	themeSystem.aimbot.setFovRadius(50 + alpha * 450)
end

function themeSystem.aimbot.beginFovRadiusDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		themeSystem.aimbot.fovDragging = true
		themeSystem.aimbot.fovTouchInput = nil
		themeSystem.aimbot.updateFovRadiusFromInput(input)
	elseif input.UserInputType == Enum.UserInputType.Touch then
		themeSystem.aimbot.fovDragging = true
		themeSystem.aimbot.fovTouchInput = input
		themeSystem.aimbot.updateFovRadiusFromInput(input)
	end
end

themeSystem.aimbot.dropdownButton.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.aimbot.setDropdownOpen(not themeSystem.aimbot.dropdownOpen)
end)
themeSystem.aimbot.radiusDropdownButton.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.aimbot.setRadiusDropdownOpen(not themeSystem.aimbot.radiusDropdownOpen)
end)
themeSystem.aimbot.fovToggle.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.aimbot.setFovCircleEnabled(not themeSystem.aimbot.fovCircleEnabled)
end)
themeSystem.aimbot.fovTrack.InputBegan:Connect(themeSystem.aimbot.beginFovRadiusDrag)
themeSystem.aimbot.fovSliderKnob.InputBegan:Connect(themeSystem.aimbot.beginFovRadiusDrag)
UserInputService.InputChanged:Connect(function(input)
	if themeSystem.aimbot.fovDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == themeSystem.aimbot.fovTouchInput) then
		themeSystem.aimbot.updateFovRadiusFromInput(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == themeSystem.aimbot.fovTouchInput then
		themeSystem.aimbot.fovDragging = false
		themeSystem.aimbot.fovTouchInput = nil
	end
end)
themeSystem.aimbot.setDropdownOpen(false)
themeSystem.aimbot.setFovRadius(themeSystem.aimbot.fovRadius)
themeSystem.aimbot.setFovCircleEnabled(false)

function themeSystem.aimbot.moveMouseToward(camera, targetPart, deltaTime)
	local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
	if not onScreen or screenPosition.Z <= 0 then
		return
	end
	local currentPosition = UserInputService:GetMouseLocation()
	local targetPosition = Vector2.new(screenPosition.X, screenPosition.Y)
	local smoothAlpha = 1 - math.exp(-themeSystem.aimbot.smoothingSpeed * math.clamp(deltaTime, 0, 0.1))
	local movement = (targetPosition - currentPosition) * smoothAlpha
	local moveX = math.round(movement.X)
	local moveY = math.round(movement.Y)
	if moveX == 0 and moveY == 0 then
		return
	end

	if type(mousemoverel) == "function" then
		pcall(mousemoverel, moveX, moveY)
	elseif type(mousemoveabs) == "function" then
		pcall(mousemoveabs, math.round(currentPosition.X + moveX), math.round(currentPosition.Y + moveY))
	else
		pcall(function()
			game:GetService("VirtualInputManager"):SendMouseMoveEvent(
				math.round(currentPosition.X + moveX),
				math.round(currentPosition.Y + moveY),
				game
			)
		end)
	end
end

function themeSystem.aimbot.setEnabled(enabled)
	RunService:UnbindFromRenderStep("WaveAdminAimbot")
	themeSystem.aimbot.enabled = enabled == true
	if themeSystem.aimbot.enabled then
		RunService:BindToRenderStep("WaveAdminAimbot", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
			if not themeSystem.aimbot.enabled or panel.Visible or freecamState.enabled or spin.value ~= 0 then
				return
			end
			local camera = workspace.CurrentCamera
			if not camera then
				return
			end
			local targetPart = themeSystem.aimbot.findTarget(camera)
			if targetPart and targetPart.Parent then
				themeSystem.aimbot.moveMouseToward(camera, targetPart, deltaTime)
			end
		end)
	end
	setSimpleSwitchVisual(switchUI.aimbot[1], switchUI.aimbot[2], switchUI.aimbot[3], themeSystem.aimbot.enabled)
end

switchUI.aimbot[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.aimbot.setEnabled(not themeSystem.aimbot.enabled)
end)

function fieldOfView.setValue(value)
	fieldOfView.value = math.clamp(math.floor((tonumber(value) or gameDefaults.fieldOfView) + 0.5), 30, 120)
	local alpha = (fieldOfView.value - 30) / 90
	fieldOfView.fill.Size = UDim2.new(alpha, 0, 1, 0)
	fieldOfView.knob.Position = UDim2.new(alpha, 0, 0.5, 0)
	fieldOfView.valueLabel.Text = tostring(fieldOfView.value) .. "°"
	if fieldOfView.enabled and workspace.CurrentCamera then
		workspace.CurrentCamera.FieldOfView = fieldOfView.value
	end
end

function fieldOfView.setEnabled(enabled)
	RunService:UnbindFromRenderStep("WaveAdminFieldOfView")
	if enabled then
		local camera = workspace.CurrentCamera
		if not camera then
			fieldOfView.enabled = false
			setSimpleSwitchVisual(switchUI.fieldOfView[1], switchUI.fieldOfView[2], switchUI.fieldOfView[3], false)
			return
		end
		if not fieldOfView.enabled then
			fieldOfView.savedValue = camera.FieldOfView
		end
		fieldOfView.enabled = true
		camera.FieldOfView = fieldOfView.value
		RunService:BindToRenderStep("WaveAdminFieldOfView", Enum.RenderPriority.Camera.Value + 2, function()
			local currentCamera = workspace.CurrentCamera
			if fieldOfView.enabled and currentCamera then
				currentCamera.FieldOfView = fieldOfView.value
			end
		end)
	else
		fieldOfView.enabled = false
		local camera = workspace.CurrentCamera
		if camera and fieldOfView.savedValue then
			camera.FieldOfView = fieldOfView.savedValue
		end
		fieldOfView.savedValue = nil
	end
	setSimpleSwitchVisual(
		switchUI.fieldOfView[1],
		switchUI.fieldOfView[2],
		switchUI.fieldOfView[3],
		fieldOfView.enabled
	)
end

function fieldOfView.updateFromInput(input)
	if fieldOfView.track.AbsoluteSize.X <= 0 then
		return
	end
	local alpha = math.clamp((input.Position.X - fieldOfView.track.AbsolutePosition.X) / fieldOfView.track.AbsoluteSize.X, 0, 1)
	fieldOfView.setValue(30 + alpha * 90)
end

function fieldOfView.beginDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not fieldOfView.enabled then
			fieldOfView.setEnabled(true)
		end
		fieldOfView.dragging = true
		fieldOfView.touchInput = nil
		fieldOfView.updateFromInput(input)
	elseif input.UserInputType == Enum.UserInputType.Touch then
		if not fieldOfView.enabled then
			fieldOfView.setEnabled(true)
		end
		fieldOfView.dragging = true
		fieldOfView.touchInput = input
		fieldOfView.updateFromInput(input)
	end
end

fieldOfView.track.InputBegan:Connect(fieldOfView.beginDrag)
fieldOfView.knob.InputBegan:Connect(fieldOfView.beginDrag)
UserInputService.InputChanged:Connect(function(input)
	if fieldOfView.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == fieldOfView.touchInput) then
		fieldOfView.updateFromInput(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == fieldOfView.touchInput then
		fieldOfView.dragging = false
		fieldOfView.touchInput = nil
	end
end)
switchUI.fieldOfView[1].Activated:Connect(function()
	playSound(clickSound)
	fieldOfView.setEnabled(not fieldOfView.enabled)
end)
fieldOfView.setValue(fieldOfView.value)

function invisibility.disconnect()
	if invisibility.diedConnection then
		invisibility.diedConnection:Disconnect()
		invisibility.diedConnection = nil
	end
end

function invisibility.restore()
	invisibility.disconnect()
	local clone = invisibility.cloneCharacter
	local original = invisibility.originalCharacter
	local returnCFrame = invisibility.originalCFrame
	if clone and clone.Parent then
		returnCFrame = clone:GetPivot()
	end

	if original then
		original.Archivable = invisibility.originalArchivable == true
		if original.Parent then
			original.Parent = workspace
			if returnCFrame then
				original:PivotTo(returnCFrame)
			end
			local originalRoot = original:FindFirstChild("HumanoidRootPart")
			if originalRoot and invisibility.originalRootAnchored ~= nil then
				originalRoot.Anchored = invisibility.originalRootAnchored
			end
			player.Character = original
			local humanoid = original:FindFirstChildOfClass("Humanoid")
			local camera = workspace.CurrentCamera
			if camera then
				camera.CameraType = invisibility.savedCameraType or Enum.CameraType.Custom
				if humanoid then
					camera.CameraSubject = humanoid
				end
			end
		end
	end
	if clone and clone.Parent then
		clone:Destroy()
	end

	invisibility.enabled = false
	invisibility.cloneCharacter = nil
	invisibility.originalCharacter = nil
	invisibility.originalArchivable = nil
	invisibility.originalRootAnchored = nil
	invisibility.originalCFrame = nil
	invisibility.savedCameraType = nil
	setSimpleSwitchVisual(
		switchUI.invisibility[1],
		switchUI.invisibility[2],
		switchUI.invisibility[3],
		false
	)
end

function invisibility.setEnabled(enabled)
	if not enabled then
		invisibility.restore()
		return
	end
	if invisibility.enabled then
		return
	end

	if freecamState.enabled then
		freecamState.setEnabled(false)
	end
	spectate.stop()
	if spin.value ~= 0 then
		spin.setValue(0)
	end
	if flyEnabled then
		setFly(false)
	end
	if vehicleFlyEnabled then
		setVehicleFly(false)
	end
	if floatEnabled then
		setFloat(false)
	end
	if freeze.enabled then
		freeze.setEnabled(false)
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or humanoid.Health <= 0 or not rootPart then
		setSimpleSwitchVisual(switchUI.invisibility[1], switchUI.invisibility[2], switchUI.invisibility[3], false)
		return
	end

	invisibility.originalCharacter = character
	invisibility.originalArchivable = character.Archivable
	invisibility.originalRootAnchored = rootPart.Anchored
	invisibility.originalCFrame = character:GetPivot()
	invisibility.savedCameraType = workspace.CurrentCamera and workspace.CurrentCamera.CameraType or Enum.CameraType.Custom
	character.Archivable = true
	local clone = character:Clone()
	clone.Name = character.Name
	invisibility.cloneCharacter = clone
	invisibility.enabled = true

	local success = pcall(function()
		clone.Parent = workspace
		clone:PivotTo(invisibility.originalCFrame)
		local camera = workspace.CurrentCamera
		player.Character = clone
		local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
		if camera and cloneHumanoid then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = cloneHumanoid
		end
		rootPart.Anchored = true
		character:PivotTo(invisibility.originalCFrame * CFrame.new(0, -150, 0))
		task.wait(0.1)
		character.Parent = Lighting
		if cloneHumanoid then
			invisibility.diedConnection = cloneHumanoid.Died:Connect(function()
				if invisibility.enabled then
					invisibility.restore()
				end
			end)
		end
	end)

	if not success then
		invisibility.restore()
		return
	end
	setSimpleSwitchVisual(
		switchUI.invisibility[1],
		switchUI.invisibility[2],
		switchUI.invisibility[3],
		true
	)
end

switchUI.invisibility[1].Activated:Connect(function()
	playSound(clickSound)
	invisibility.setEnabled(not invisibility.enabled)
end)

function walkfling.setEnabled(enabled)
	if enabled and walkfling.enabled then
		return
	end
	walkfling.generation += 1
	if walkfling.diedConnection then
		walkfling.diedConnection:Disconnect()
		walkfling.diedConnection = nil
	end

	if not enabled then
		walkfling.enabled = false
		if walkfling.lastRoot and walkfling.lastRoot.Parent and walkfling.lastVelocity then
			walkfling.lastRoot.AssemblyLinearVelocity = walkfling.lastVelocity
		end
		walkfling.lastRoot = nil
		walkfling.lastVelocity = nil
		if walkfling.enabledNoclip and noclipEnabled then
			noclipEnabled = false
			setNoclipVisual(false)
			setWallNoclip(false)
		end
		walkfling.enabledNoclip = false
		setSimpleSwitchVisual(switchUI.walkfling[1], switchUI.walkfling[2], switchUI.walkfling[3], false)
		return
	end

	if invisibility.enabled or invisibility.originalCharacter then
		invisibility.restore()
	end
	if spin.value ~= 0 then
		spin.setValue(0)
	end
	if flyEnabled then
		setFly(false)
	end
	if vehicleFlyEnabled then
		setVehicleFly(false)
	end
	if floatEnabled then
		setFloat(false)
	end
	if freeze.enabled then
		freeze.setEnabled(false)
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or humanoid.Health <= 0 or not rootPart then
		setSimpleSwitchVisual(switchUI.walkfling[1], switchUI.walkfling[2], switchUI.walkfling[3], false)
		return
	end

	walkfling.enabledNoclip = not noclipEnabled
	if walkfling.enabledNoclip then
		noclipEnabled = true
		setNoclipVisual(true)
		setWallNoclip(true)
	end
	walkfling.enabled = true
	local thisGeneration = walkfling.generation
	walkfling.diedConnection = humanoid.Died:Connect(function()
		if walkfling.enabled then
			walkfling.setEnabled(false)
		end
	end)

	task.spawn(function()
		local verticalOffset = 0.1
		while walkfling.enabled and walkfling.generation == thisGeneration do
			RunService.Heartbeat:Wait()
			if not walkfling.enabled or walkfling.generation ~= thisGeneration then
				break
			end
			local currentCharacter = player.Character
			local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
			if currentRoot and currentRoot.Parent then
				local velocity = currentRoot.AssemblyLinearVelocity
				walkfling.lastRoot = currentRoot
				walkfling.lastVelocity = velocity
				currentRoot.AssemblyLinearVelocity = velocity * 10000 + Vector3.new(0, 10000, 0)
				RunService.RenderStepped:Wait()
				if not walkfling.enabled or walkfling.generation ~= thisGeneration then
					break
				end
				if currentRoot.Parent then
					currentRoot.AssemblyLinearVelocity = velocity
				end
				RunService.Stepped:Wait()
				if not walkfling.enabled or walkfling.generation ~= thisGeneration then
					break
				end
				if currentRoot.Parent then
					currentRoot.AssemblyLinearVelocity = velocity + Vector3.new(0, verticalOffset, 0)
					verticalOffset *= -1
				end
			end
		end
	end)

	setSimpleSwitchVisual(switchUI.walkfling[1], switchUI.walkfling[2], switchUI.walkfling[3], true)
end

switchUI.walkfling[1].Activated:Connect(function()
	playSound(clickSound)
	walkfling.setEnabled(not walkfling.enabled)
end)

themeSystem.triggerBot.mouse = player:GetMouse()

function themeSystem.triggerBot.clickMouse()
	if type(mouse1click) == "function" then
		pcall(mouse1click)
		return
	end
	pcall(function()
		local virtualInput = game:GetService("VirtualInputManager")
		local mousePosition = UserInputService:GetMouseLocation()
		virtualInput:SendMouseButtonEvent(mousePosition.X, mousePosition.Y, 0, true, game, 0)
		virtualInput:SendMouseButtonEvent(mousePosition.X, mousePosition.Y, 0, false, game, 0)
	end)
end

function themeSystem.triggerBot.setEnabled(enabled)
	RunService:UnbindFromRenderStep("WaveAdminTriggerBot")
	themeSystem.triggerBot.enabled = enabled == true
	themeSystem.triggerBot.lastClick = 0
	if themeSystem.triggerBot.enabled then
		RunService:BindToRenderStep("WaveAdminTriggerBot", Enum.RenderPriority.Camera.Value + 2, function()
			if not themeSystem.triggerBot.enabled or panel.Visible then
				return
			end
			local targetPart = themeSystem.triggerBot.mouse.Target
			local character = targetPart and targetPart:FindFirstAncestorOfClass("Model")
			local targetPlayer = character and Players:GetPlayerFromCharacter(character)
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if targetPlayer and targetPlayer ~= player and humanoid and humanoid.Health > 0 then
				local now = os.clock()
				if now - themeSystem.triggerBot.lastClick >= 0.12 then
					themeSystem.triggerBot.lastClick = now
					themeSystem.triggerBot.clickMouse()
				end
			end
		end)
	end
	setSimpleSwitchVisual(
		switchUI.triggerBot[1],
		switchUI.triggerBot[2],
		switchUI.triggerBot[3],
		themeSystem.triggerBot.enabled
	)
end

switchUI.triggerBot[1].Activated:Connect(function()
	playSound(clickSound)
	themeSystem.triggerBot.setEnabled(not themeSystem.triggerBot.enabled)
end)

local function resetToDefaults()
	if walkfling.enabled then
		walkfling.setEnabled(false)
	end
	if themeSystem.healthDisplay.enabled then
		themeSystem.healthDisplay.setEnabled(false)
	end
	if themeSystem.waveTags.enabled then
		themeSystem.waveTags.setEnabled(false)
	end
	if themeSystem.instantPrompts.enabled then
		themeSystem.instantPrompts.setEnabled(false)
	end
	if themeSystem.coordinates.enabled then
		themeSystem.coordinates.setEnabled(false)
	end
	if themeSystem.autoSell.enabled then
		themeSystem.autoSell.setEnabled(false)
	end
	if themeSystem.playerTrails.enabled then
		themeSystem.playerTrails.setEnabled(false)
	end
	if invisibility.enabled or invisibility.originalCharacter then
		invisibility.restore()
	end
	speedBox.Text = tostring(gameDefaults.walkSpeed)
	jumpBox.Text = tostring(gameDefaults.useJumpPower and gameDefaults.jumpPower or gameDefaults.jumpHeight)
	applySpeed()
	applyJump()
	setGravity(gameDefaults.gravity)

	if noclipEnabled then
		noclipEnabled = false
		setNoclipVisual(false)
		setWallNoclip(false)
	end
	if flyEnabled then
		setFly(false)
	end
	if godModeEnabled then
		setGodMode(false)
	end
	if fullBrightEnabled then
		setFullBright(false)
	end
	spectate.stop()
	if freecamState.enabled then
		freecamState.setEnabled(false)
	end
	if zoom.enabled then
		zoom.setEnabled(false)
	end
	if teleportClick.enabled then
		teleportClick.setEnabled(false)
	end
	gotoPlayer.selectButton.Text = "Select a player"
	gotoPlayer.setOpen(false)
	spectate.setOpen(false)
	if freeze.enabled then
		freeze.setEnabled(false)
	end
	spin.setValue(0)
	if vehicleFlyEnabled then
		setVehicleFly(false)
	end
	if floatEnabled then
		setFloat(false)
	end
	if infiniteJumpEnabled then
		setInfiniteJump(false)
	end
	if espEnabled then
		setESP(false)
	end
	if themeSystem.aimbot.enabled then
		themeSystem.aimbot.setEnabled(false)
	end
	if themeSystem.aimbot.fovCircleEnabled then
		themeSystem.aimbot.setFovCircleEnabled(false)
	end
	themeSystem.aimbot.setFovRadius(themeSystem.aimbot.defaultFovRadius)
	themeSystem.aimbot.setDropdownOpen(false)
	themeSystem.aimbot.setSmoothness(themeSystem.aimbot.defaultSmoothness)
	if fieldOfView.enabled then
		fieldOfView.setEnabled(false)
	end
	fieldOfView.setValue(gameDefaults.fieldOfView)
	if themeSystem.triggerBot.enabled then
		themeSystem.triggerBot.setEnabled(false)
	end
	activeHud.setEnabled(true)
end

function themeSystem.randomize.run()
	local random = Random.new()
	local function coin(chance)
		return random:NextNumber() < (chance or 0.5)
	end

	resetToDefaults()
	local availableThemes = themeSystem.themes or {}
	if #availableThemes > 0 then
		themeSystem.apply(availableThemes[random:NextInteger(1, #availableThemes)])
	end

	settings.setTextScale(random:NextInteger(15, 30) / 20)
	settings.setCtrlHoldSeconds(random:NextInteger(2, 20) / 4)
	speedBox.Text = tostring(math.floor(math.max(1, gameDefaults.walkSpeed * random:NextNumber(0.6, 3.25)) + 0.5))
	jumpBox.Text = tostring(math.floor(math.max(1, (gameDefaults.useJumpPower and gameDefaults.jumpPower or gameDefaults.jumpHeight) * random:NextNumber(0.65, 2.5)) * 10 + 0.5) / 10)
	applySpeed()
	applyJump()
	setGravity(random:NextInteger(80, 260))

	noclipEnabled = coin(0.45)
	setNoclipVisual(noclipEnabled)
	setWallNoclip(noclipEnabled)
	setFly(coin(0.35))
	setGodMode(coin(0.4))
	setVehicleFly(coin(0.3))
	setFullBright(coin(0.5))
	zoom.setEnabled(coin(0.5))
	teleportClick.setEnabled(coin(0.35))
	freeze.setEnabled(coin(0.25))
	setFloat(coin(0.35))
	setInfiniteJump(coin(0.5))

	local randomSpin = coin(0.55) and random:NextInteger(4, 40) or 0
	spin.setValue(randomSpin)
	spin.setAntifling(randomSpin ~= 0 and coin(0.65))
	if randomSpin == 0 then
		freecamState.setEnabled(coin(0.3))
	end

	local randomESP = coin(0.55)
	setESP(randomESP)
	setNametags(randomESP and coin(0.65))
	themeSystem.aimbot.setSmoothness(random:NextInteger(5, 70))
	themeSystem.aimbot.setFovRadius(random:NextInteger(100, 480))
	themeSystem.aimbot.setFovCircleEnabled(coin(0.5))
	themeSystem.aimbot.setEnabled(coin(0.35))
	themeSystem.triggerBot.setEnabled(coin(0.3))
	fieldOfView.setValue(random:NextInteger(45, 110))
	fieldOfView.setEnabled(coin(0.65))
	themeSystem.healthDisplay.setEnabled(coin(0.5))
	themeSystem.waveTags.setEnabled(coin(0.5))
	themeSystem.instantPrompts.setEnabled(coin(0.5))
	themeSystem.coordinates.setEnabled(coin(0.5))
	themeSystem.playerTrails.setHue(random:NextNumber())
	themeSystem.playerTrails.setEnabled(coin(0.55))
	if themeSystem.autoSell.sellCFrame then
		themeSystem.autoSell.setInterval(random:NextInteger(2, 30))
		themeSystem.autoSell.setEnabled(coin(0.35))
	end
	activeHud.setEnabled(coin(0.8))

	if coin(0.25) then invisibility.setEnabled(true) end
	if coin(0.3) then walkfling.setEnabled(true) end
	themeSystem.randomize.button.Text = "RANDOMIZED!"
	task.delay(1.2, function()
		if themeSystem.randomize.button.Parent then themeSystem.randomize.button.Text = "RANDOMIZE" end
	end)
end

themeSystem.randomize.button.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.randomize.run()
end)

resetButton.Activated:Connect(function()
	playSound(clickSound)
	resetToDefaults()
end)

themeSystem.panic.button.Activated:Connect(function()
	playSound(clickSound)
	resetToDefaults()
end)

player.CharacterAdded:Connect(function()
	local restoreSpinAntifling = spin.antiflingEnabled
	if flyEnabled then
		setFly(false)
	end
	if vehicleFlyEnabled then
		setVehicleFly(false)
	end
	if floatEnabled then
		setFloat(false)
	end
	if noclipEnabled then
		task.wait()
		setWallNoclip(true)
	end
	if spin.value ~= 0 then
		task.wait()
		spin.setValue(spin.value)
		if restoreSpinAntifling then
			spin.setAntifling(true)
		end
	end
end)

local openTween
local closeTween
local isOpen = false
local menuMouse = {}
RunService:UnbindFromRenderStep("WaveAdminMenuMouseUnlock")
RunService:UnbindFromRenderStep("WaveAdminMenuMouseStateTracker")

if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
	menuMouse.restingState = {
		MouseBehavior = UserInputService.MouseBehavior,
		MouseIconEnabled = UserInputService.MouseIconEnabled,
	}
end

RunService:BindToRenderStep(
	"WaveAdminMenuMouseStateTracker",
	Enum.RenderPriority.Last.Value - 1,
	function()
		if not isOpen and not (themeSystem.commandBar and themeSystem.commandBar.open) and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			menuMouse.restingState = {
				MouseBehavior = UserInputService.MouseBehavior,
				MouseIconEnabled = UserInputService.MouseIconEnabled,
			}
		end
	end
)

function menuMouse.unlock()
	RunService:UnbindFromRenderStep("WaveAdminMenuMouseUnlock")
	if not menuMouse.savedState then
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			if menuMouse.restingState then
				menuMouse.savedState = {
					MouseBehavior = menuMouse.restingState.MouseBehavior,
					MouseIconEnabled = menuMouse.restingState.MouseIconEnabled,
				}
			elseif player.CameraMode == Enum.CameraMode.LockFirstPerson then
				menuMouse.savedState = {
					MouseBehavior = Enum.MouseBehavior.LockCenter,
					MouseIconEnabled = false,
				}
			else
				menuMouse.savedState = {
					MouseBehavior = Enum.MouseBehavior.Default,
					MouseIconEnabled = true,
				}
			end
		else
			menuMouse.savedState = {
				MouseBehavior = UserInputService.MouseBehavior,
				MouseIconEnabled = UserInputService.MouseIconEnabled,
			}
		end
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	RunService:BindToRenderStep(
		"WaveAdminMenuMouseUnlock",
		Enum.RenderPriority.Last.Value,
		function()
			if isOpen or (themeSystem.commandBar and themeSystem.commandBar.open) then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end
		end
	)
end

function menuMouse.restore()
	RunService:UnbindFromRenderStep("WaveAdminMenuMouseUnlock")
	local savedState = menuMouse.savedState
	menuMouse.savedState = nil
	if not savedState then
		return
	end
	UserInputService.MouseBehavior = savedState.MouseBehavior
	UserInputService.MouseIconEnabled = savedState.MouseIconEnabled
end

local function setOpen(nextOpen)
	if nextOpen == isOpen then
		return
	end
	isOpen = nextOpen
	if openTween then
		openTween:Cancel()
	end
	if closeTween then
		closeTween:Cancel()
	end

	if nextOpen then
		if themeSystem.commandBar and themeSystem.commandBar.open and themeSystem.commandBar.setOpen then
			themeSystem.commandBar.setOpen(false)
		end
		menuMouse.unlock()
		backdrop.Visible = true
		panel.Visible = true
		scale.Scale = 0.88
		panel.Position = UDim2.fromScale(0.5, 0.53)
		backdrop.BackgroundTransparency = 1
		playSound(openSound)
		openTween = TweenService:Create(scale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
		openTween:Play()
		TweenService:Create(panel, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
		TweenService:Create(backdrop, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.22}):Play()
	else
		if themeSystem.searchSystem.box then
			themeSystem.searchSystem.box:ReleaseFocus()
		end
		if themeSystem.keybindSystem.stopListening then
			themeSystem.keybindSystem.stopListening()
		end
		menuMouse.restore()
		playSound(closeSound)
		closeTween = TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.88})
		closeTween:Play()
		TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, 0.53)}):Play()
		local fade = TweenService:Create(backdrop, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
		fade:Play()
		fade.Completed:Once(function()
			if not isOpen then
				backdrop.Visible = false
				panel.Visible = false
			end
		end)
	end
end

closeButton.Activated:Connect(function()
	playSound(clickSound)
	setOpen(false)
end)

local menuToggleHold = nil

local function handleMenuToggle(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		if isOpen then
			menuToggleHold = nil
			settings.lastCtrlTap = 0
			setOpen(false)
		else
			local now = os.clock()
			if settings.lastCtrlTap > 0 and now - settings.lastCtrlTap <= 0.5 then
				menuToggleHold = nil
				settings.lastCtrlTap = 0
				settings.ctrlPressStarted = nil
				settings.holdOpened = false
				setOpen(true)
				return Enum.ContextActionResult.Sink
			end

			local thisHold = now
			menuToggleHold = thisHold
			settings.ctrlPressStarted = now
			settings.holdOpened = false
			task.delay(settings.ctrlHoldSeconds, function()
				if menuToggleHold == thisHold and not isOpen then
					settings.holdOpened = true
					settings.lastCtrlTap = 0
					setOpen(true)
				end
			end)
		end
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		if menuToggleHold then
			local now = os.clock()
			local heldFor = now - (settings.ctrlPressStarted or now)
			local wasTap = not settings.holdOpened and not isOpen and inputState == Enum.UserInputState.End and heldFor < settings.ctrlHoldSeconds
			menuToggleHold = nil
			if wasTap then
				settings.lastCtrlTap = now
			elseif not settings.holdOpened and not isOpen and inputState == Enum.UserInputState.End and heldFor >= settings.ctrlHoldSeconds then
				settings.lastCtrlTap = 0
				setOpen(true)
			end
		end
		settings.ctrlPressStarted = nil
		settings.holdOpened = false
	end
	return Enum.ContextActionResult.Sink
end

presetSystem.presets = {}
presetSystem.cards = {}
presetSystem.nextId = 0
presetSystem.storageFile = "WaveAdminMenu_Presets.json"

function presetSystem.encodeForStorage(value)
	if typeof(value) == "Color3" then
		return {
			__waveType = "Color3",
			r = value.R,
			g = value.G,
			b = value.B,
		}
	end
	if type(value) == "table" then
		local encoded = {}
		for key, nestedValue in pairs(value) do
			encoded[key] = presetSystem.encodeForStorage(nestedValue)
		end
		return encoded
	end
	return value
end

function presetSystem.decodeFromStorage(value)
	if type(value) ~= "table" then
		return value
	end
	if value.__waveType == "Color3" then
		return Color3.new(
			math.clamp(tonumber(value.r) or 0, 0, 1),
			math.clamp(tonumber(value.g) or 0, 0, 1),
			math.clamp(tonumber(value.b) or 0, 0, 1)
		)
	end
	local decoded = {}
	for key, nestedValue in pairs(value) do
		decoded[key] = presetSystem.decodeFromStorage(nestedValue)
	end
	return decoded
end

function presetSystem.storageAvailable()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

function presetSystem.saveToDisk()
	if not presetSystem.storageAvailable() then
		return false
	end
	local success = pcall(function()
		local payload = presetSystem.encodeForStorage({
			version = 1,
			nextId = presetSystem.nextId,
			presets = presetSystem.presets,
		})
		writefile(presetSystem.storageFile, HttpService:JSONEncode(payload))
	end)
	return success
end

function presetSystem.loadFromDisk()
	if not presetSystem.storageAvailable() then
		return false
	end
	local fileCheckSucceeded, fileExists = pcall(isfile, presetSystem.storageFile)
	if not fileCheckSucceeded or not fileExists then
		return false
	end

	local success, payload = pcall(function()
		return HttpService:JSONDecode(readfile(presetSystem.storageFile))
	end)
	if not success or type(payload) ~= "table" or type(payload.presets) ~= "table" then
		return false
	end

	local decodedPresets = presetSystem.decodeFromStorage(payload.presets)
	local loadedPresets = {}
	local highestId = tonumber(payload.nextId) or 0
	for index, savedPreset in ipairs(decodedPresets) do
		if type(savedPreset) == "table" and type(savedPreset.name) == "string" and type(savedPreset.state) == "table" then
			if savedPreset.id == nil then
				highestId += 1
				savedPreset.id = tostring(highestId)
			else
				highestId = math.max(highestId, tonumber(savedPreset.id) or index)
				savedPreset.id = tostring(savedPreset.id)
			end
			table.insert(loadedPresets, savedPreset)
		end
	end

	presetSystem.presets = loadedPresets
	presetSystem.nextId = highestId
	presetSystem.rebuildCards()
	presetSystem.setStatus(string.format("LOADED %d SAVED PRESET%s", #loadedPresets, #loadedPresets == 1 and "" or "S"), true)
	return true
end

function presetSystem.captureState()
	local activeTheme = themeSystem.currentTheme
	local capturedState = {
		theme = {
			name = activeTheme and activeTheme.name or "Default",
			palette = themeSystem.copyPalette(activeTheme and activeTheme.palette or colors),
		},
		favorites = {},
		keybinds = {},
		noclip = noclipEnabled,
		fly = flyEnabled,
		godMode = godModeEnabled,
		vehicleFly = vehicleFlyEnabled,
		fullBright = fullBrightEnabled,
		freecam = freecamState.enabled == true,
		zoom = zoom.enabled == true,
		teleportClick = teleportClick.enabled == true,
		freeze = freeze.enabled == true,
		spinValue = spin.value,
		antifling = spin.antiflingEnabled == true,
		float = floatEnabled,
		infiniteJump = infiniteJumpEnabled,
		esp = espEnabled,
		nametags = nametagsEnabled,
		aimbot = themeSystem.aimbot.enabled == true,
		aimbotSmoothness = themeSystem.aimbot.smoothness,
		aimbotRadius = themeSystem.aimbot.fovCircleEnabled == true,
		aimbotRadiusSize = themeSystem.aimbot.fovRadius,
		fieldOfView = fieldOfView.enabled == true,
		fieldOfViewValue = fieldOfView.value,
		invisibility = invisibility.enabled == true,
		walkfling = walkfling.enabled == true,
		healthDisplay = themeSystem.healthDisplay.enabled == true,
		waveTags = themeSystem.waveTags.enabled == true,
		instantPrompts = themeSystem.instantPrompts.enabled == true,
		coordinates = themeSystem.coordinates.enabled == true,
		autoSell = themeSystem.autoSell.enabled == true,
		autoSellInterval = themeSystem.autoSell.interval,
		playerTrails = themeSystem.playerTrails.enabled == true,
		playerTrailsColor = {themeSystem.playerTrails.color.R, themeSystem.playerTrails.color.G, themeSystem.playerTrails.color.B},
		triggerBot = themeSystem.triggerBot.enabled == true,
		spectateUserId = spectate.target and spectate.target.UserId or nil,
		uiTextScale = settings.textScale,
		ctrlHoldSeconds = settings.ctrlHoldSeconds,
		activeHudVisible = activeHud.enabled == true,
		waypoints = themeSystem.waypoints.serialize(),
	}
	if themeSystem.autoSell.sellCFrame then
		capturedState.autoSellLocation = {themeSystem.autoSell.sellCFrame:GetComponents()}
	end
	for key, favorited in pairs(themeSystem.favoriteSystem.states) do
		if favorited then
			capturedState.favorites[key] = true
		end
	end
	for id, item in pairs(themeSystem.keybindSystem.items) do
		if item.keyCode then
			capturedState.keybinds[id] = item.keyCode.Name
		end
	end
	return capturedState
end

function presetSystem.enabledCount(state)
	local count = 0
	for _, key in ipairs({
		"noclip", "fly", "godMode", "vehicleFly", "fullBright", "freecam", "zoom",
			"teleportClick", "freeze", "antifling", "float", "infiniteJump", "esp", "nametags", "aimbot", "aimbotRadius", "fieldOfView", "invisibility", "walkfling", "healthDisplay", "waveTags", "instantPrompts", "coordinates", "autoSell", "playerTrails", "triggerBot",
	}) do
		if state[key] then
			count += 1
		end
	end
	if (state.spinValue or 0) ~= 0 then
		count += 1
	end
	if state.spectateUserId then
		count += 1
	end
	return count
end

function presetSystem.loadState(state)
	if not state then
		return
	end

	if state.theme and state.theme.palette then
		themeSystem.apply({
			name = state.theme.name or "Preset Theme",
			palette = themeSystem.copyPalette(state.theme.palette),
		})
	end
	settings.setTextScale(tonumber(state.uiTextScale) or 1)
	settings.setCtrlHoldSeconds(tonumber(state.ctrlHoldSeconds) or 0.5)
	activeHud.setEnabled(state.activeHudVisible ~= false)
	if walkfling.enabled then
		walkfling.setEnabled(false)
	end
	if invisibility.enabled or invisibility.originalCharacter then
		invisibility.restore()
	end

	if noclipEnabled ~= (state.noclip == true) then
		noclipEnabled = state.noclip == true
		setNoclipVisual(noclipEnabled)
		setWallNoclip(noclipEnabled)
	end

	setFly(state.fly == true)
	setGodMode(state.godMode == true)
	setVehicleFly(state.vehicleFly == true)
	if fullBrightEnabled ~= (state.fullBright == true) then
		setFullBright(state.fullBright == true)
	end
	teleportClick.setEnabled(state.teleportClick == true)
	freeze.setEnabled(state.freeze == true)
	setFloat(state.float == true)
	setInfiniteJump(state.infiniteJump == true)

	spectate.stop()
	if freecamState.enabled then
		freecamState.setEnabled(false)
	end
	spin.setValue(state.spinValue or 0)
	spin.setAntifling(state.antifling == true)
	zoom.setEnabled(state.zoom == true)
	if state.freecam then
		freecamState.setEnabled(true)
	end

	setESP(state.esp == true)
	setNametags(state.esp == true and state.nametags == true)
	themeSystem.aimbot.setSmoothness(tonumber(state.aimbotSmoothness) or themeSystem.aimbot.defaultSmoothness)
	themeSystem.aimbot.setFovRadius(tonumber(state.aimbotRadiusSize or state.aimbotFovRadius) or themeSystem.aimbot.defaultFovRadius)
	themeSystem.aimbot.setFovCircleEnabled(state.aimbotRadius == true or state.aimbotFovCircle == true)
	themeSystem.aimbot.setEnabled(state.aimbot == true)
	fieldOfView.setValue(tonumber(state.fieldOfViewValue) or gameDefaults.fieldOfView)
	fieldOfView.setEnabled(state.fieldOfView == true)
	themeSystem.triggerBot.setEnabled(state.triggerBot == true)
	invisibility.setEnabled(state.invisibility == true)
	walkfling.setEnabled(state.walkfling == true)
	themeSystem.healthDisplay.setEnabled(state.healthDisplay == true)
	themeSystem.waveTags.setEnabled(state.waveTags == true)
	themeSystem.instantPrompts.setEnabled(state.instantPrompts == true)
	themeSystem.coordinates.setEnabled(state.coordinates == true)
	themeSystem.autoSell.setEnabled(false)
	if type(state.autoSellLocation) == "table" and #state.autoSellLocation >= 3 then
		local success, savedCFrame = pcall(function() return CFrame.new(table.unpack(state.autoSellLocation)) end)
		themeSystem.autoSell.sellCFrame = success and savedCFrame or nil
	else
		themeSystem.autoSell.sellCFrame = nil
	end
	themeSystem.autoSell.setInterval(tonumber(state.autoSellInterval) or 8)
	themeSystem.autoSell.updateLocationText()
	themeSystem.autoSell.setEnabled(state.autoSell == true)
	local trailColor = type(state.playerTrailsColor) == "table" and state.playerTrailsColor or {}
	themeSystem.playerTrails.setColor(Color3.new(
		math.clamp(tonumber(trailColor[1]) or 0.24, 0, 1),
		math.clamp(tonumber(trailColor[2]) or 0.86, 0, 1),
		math.clamp(tonumber(trailColor[3]) or 1, 0, 1)
	))
	themeSystem.playerTrails.setEnabled(state.playerTrails == true)
	if state.spectateUserId then
		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			if targetPlayer.UserId == state.spectateUserId then
				spectate.setTarget(targetPlayer)
				break
			end
		end
	end
	themeSystem.waypoints.loadSerialized(state.waypoints)
	if state.favorites and themeSystem.favoriteSystem.restore then
		themeSystem.favoriteSystem.restore(state.favorites)
	end
	if state.keybinds and themeSystem.keybindSystem.restore then
		themeSystem.keybindSystem.restore(state.keybinds)
	end
end

function presetSystem.setStatus(message, good)
	if not presetSystem.status then
		return
	end
	presetSystem.status.Text = message
	presetSystem.status.TextColor3 = good and colors.success or colors.danger
end

function presetSystem.rebuildCards()
	for _, card in ipairs(presetSystem.cards) do
		card:Destroy()
	end
	table.clear(presetSystem.cards)

	for index, preset in ipairs(presetSystem.presets) do
		local card = addCard("SavedPreset" .. index, 112, 20 + index)
		local enabledCount = presetSystem.enabledCount(preset.state)
		local themeName = preset.state.theme and preset.state.theme.name or "Default"
		addCardTitle(
			card,
			preset.name,
			string.format("%d active cheat%s  |  %s theme", enabledCount, enabledCount == 1 and "" or "s", themeName)
		)

		local loadButton = Instance.new("TextButton")
		loadButton.Name = "LoadPresetButton"
		loadButton.AnchorPoint = Vector2.new(0, 1)
		loadButton.Position = UDim2.new(0, 17, 1, -12)
		loadButton.Size = UDim2.new(0.5, -23, 0, 30)
		loadButton.BackgroundColor3 = colors.accent
		loadButton.BorderSizePixel = 0
		loadButton.Font = Enum.Font.GothamBold
		loadButton.Text = "LOAD"
		loadButton.TextColor3 = colors.text
		loadButton.TextSize = 11
		loadButton.Parent = card
		addCorner(loadButton, 8)
		themeSystem.styleButton(loadButton)

		local deleteButton = Instance.new("TextButton")
		deleteButton.Name = "DeletePresetButton"
		deleteButton.AnchorPoint = Vector2.new(1, 1)
		deleteButton.Position = UDim2.new(1, -17, 1, -12)
		deleteButton.Size = UDim2.new(0.5, -23, 0, 30)
		deleteButton.BackgroundColor3 = colors.danger
		deleteButton.BorderSizePixel = 0
		deleteButton.Font = Enum.Font.GothamBold
		deleteButton.Text = "DELETE"
		deleteButton.TextColor3 = colors.text
		deleteButton.TextSize = 11
		deleteButton.Parent = card
		addCorner(deleteButton, 8)
		themeSystem.styleButton(deleteButton)

		loadButton.Activated:Connect(function()
			playSound(clickSound)
			presetSystem.loadState(preset.state)
			presetSystem.setStatus("LOADED " .. string.upper(preset.name), true)
		end)
		deleteButton.Activated:Connect(function()
			playSound(clickSound)
			if themeSystem.favoriteSystem.unregister then
				themeSystem.favoriteSystem.unregister("preset:" .. preset.id)
			end
			for presetIndex, savedPreset in ipairs(presetSystem.presets) do
				if savedPreset == preset then
					table.remove(presetSystem.presets, presetIndex)
					break
				end
			end
			presetSystem.setStatus("DELETED " .. string.upper(preset.name), true)
			presetSystem.saveToDisk()
			presetSystem.rebuildCards()
		end)

		card.Visible = activeTabName == "Customize"
		table.insert(presetSystem.cards, card)
		if themeSystem.favoriteSystem.registerPreset then
			themeSystem.favoriteSystem.registerPreset(preset, card, 20 + index)
		end
	end
end

function presetSystem.saveCurrent()
	local name = string.gsub(presetSystem.nameBox.Text or "", "^%s*(.-)%s*$", "%1")
	if name == "" then
		presetSystem.setStatus("ENTER A PRESET NAME", false)
		return
	end

	local existingPreset
	for _, preset in ipairs(presetSystem.presets) do
		if string.lower(preset.name) == string.lower(name) then
			existingPreset = preset
			break
		end
	end

	if existingPreset then
		existingPreset.name = name
		existingPreset.state = presetSystem.captureState()
		presetSystem.setStatus("UPDATED " .. string.upper(name), true)
	else
		presetSystem.nextId += 1
		table.insert(presetSystem.presets, {
			id = tostring(presetSystem.nextId),
			name = name,
			state = presetSystem.captureState(),
		})
		presetSystem.setStatus("SAVED " .. string.upper(name), true)
	end

	presetSystem.nameBox.Text = ""
	presetSystem.saveToDisk()
	presetSystem.rebuildCards()
end

function presetSystem.setCardsVisible(visible)
	if presetSystem.builder then
		presetSystem.builder.Visible = visible
	end
	for _, card in ipairs(presetSystem.cards) do
		card.Visible = visible
	end
end

presetSystem.builder = addCard("PresetBuilder", 126, 0)
addCardTitle(presetSystem.builder, "Save Preset", "Captures cheats, theme, favorites, and keybinds.")

presetSystem.nameBox = Instance.new("TextBox")
presetSystem.nameBox.Name = "PresetNameBox"
presetSystem.nameBox.Position = UDim2.fromOffset(17, 67)
presetSystem.nameBox.Size = UDim2.new(1, -126, 0, 32)
presetSystem.nameBox.BackgroundColor3 = colors.input
presetSystem.nameBox.BorderSizePixel = 0
presetSystem.nameBox.ClearTextOnFocus = false
presetSystem.nameBox.Font = Enum.Font.Gotham
presetSystem.nameBox.PlaceholderText = "Preset name"
presetSystem.nameBox.PlaceholderColor3 = colors.faint
presetSystem.nameBox.Text = ""
presetSystem.nameBox.TextColor3 = colors.text
presetSystem.nameBox.TextSize = 11
presetSystem.nameBox.TextXAlignment = Enum.TextXAlignment.Left
presetSystem.nameBox.Parent = presetSystem.builder
addCorner(presetSystem.nameBox, 8)
do
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = presetSystem.nameBox
end

presetSystem.saveButton = Instance.new("TextButton")
presetSystem.saveButton.Name = "SavePresetButton"
presetSystem.saveButton.AnchorPoint = Vector2.new(1, 0)
presetSystem.saveButton.Position = UDim2.new(1, -17, 0, 67)
presetSystem.saveButton.Size = UDim2.fromOffset(82, 32)
presetSystem.saveButton.BackgroundColor3 = colors.accent
presetSystem.saveButton.BorderSizePixel = 0
presetSystem.saveButton.Font = Enum.Font.GothamBold
presetSystem.saveButton.Text = "SAVE"
presetSystem.saveButton.TextColor3 = colors.text
presetSystem.saveButton.TextSize = 11
presetSystem.saveButton.Parent = presetSystem.builder
addCorner(presetSystem.saveButton, 8)
themeSystem.styleButton(presetSystem.saveButton)

presetSystem.status = Instance.new("TextLabel")
presetSystem.status.Name = "PresetStatus"
presetSystem.status.Position = UDim2.fromOffset(17, 104)
presetSystem.status.Size = UDim2.new(1, -34, 0, 13)
presetSystem.status.BackgroundTransparency = 1
presetSystem.status.Font = Enum.Font.GothamBold
presetSystem.status.Text = "READY TO SAVE"
presetSystem.status.TextColor3 = colors.faint
presetSystem.status.TextSize = 9
presetSystem.status.TextXAlignment = Enum.TextXAlignment.Left
presetSystem.status.Parent = presetSystem.builder

presetSystem.saveButton.Activated:Connect(function()
	playSound(clickSound)
	presetSystem.saveCurrent()
end)
presetSystem.nameBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		presetSystem.saveCurrent()
	end
end)
presetSystem.builder.Visible = false

function themeSystem.favoriteSystem.updateStar(item)
	if not item or not item.star or not item.star.Parent then
		return
	end
	local favorited = themeSystem.favoriteSystem.states[item.key] == true
	item.star.Text = favorited and "★" or "☆"
	item.star.TextColor3 = Color3.fromRGB(255, 205, 48)
	item.star.TextTransparency = favorited and 0 or 0.08
	item.star:SetAttribute("Favorited", favorited)
end

function themeSystem.favoriteSystem.applyOrder(item)
	if not item or not item.card or not item.card.Parent then
		return
	end
	if themeSystem.favoriteSystem.states[item.key] then
		item.card.LayoutOrder = -1000 + item.baseOrder
	else
		item.card.LayoutOrder = item.baseOrder
	end
end

function themeSystem.favoriteSystem.attachStar(item)
	if not item.card or not item.card.Parent then
		return
	end
	if item.star and item.star.Parent then
		item.star:Destroy()
	end

	local heading = item.card:FindFirstChild("CardHeading")
	local description = item.card:FindFirstChild("CardDescription")
	if heading then
		heading.Position = UDim2.fromOffset(50, heading.Position.Y.Offset)
		heading.Size = UDim2.new(1, -67, 0, heading.Size.Y.Offset)
	end
	if description then
		description.Position = UDim2.fromOffset(50, description.Position.Y.Offset)
		description.Size = UDim2.new(1, -67, 0, description.Size.Y.Offset)
	end

	local star = Instance.new("TextButton")
	star.Name = "FavoriteStar"
	star.Position = UDim2.fromOffset(15, 11)
	star.Size = UDim2.fromOffset(27, 27)
	star.BackgroundTransparency = 1
	star.BorderSizePixel = 0
	star.AutoButtonColor = false
	star.Font = Enum.Font.GothamBold
	star.Text = "☆"
	star.TextColor3 = Color3.fromRGB(255, 205, 48)
	star.TextSize = 22
	star.ZIndex = 8
	star:SetAttribute("WavePolished", true)
	star.Parent = item.card
	item.star = star
	themeSystem.favoriteSystem.updateStar(item)

	star.MouseEnter:Connect(function()
		TweenService:Create(star, TweenInfo.new(0.12), {TextSize = 25}):Play()
	end)
	star.MouseLeave:Connect(function()
		TweenService:Create(star, TweenInfo.new(0.12), {TextSize = 22}):Play()
	end)
	star.Activated:Connect(function()
		playSound(clickSound)
		themeSystem.favoriteSystem.setFavorite(item.key, not themeSystem.favoriteSystem.states[item.key])
	end)
end

function themeSystem.favoriteSystem.register(key, titleText, category, tabName, card, baseOrder)
	local item = themeSystem.favoriteSystem.items[key]
	if not item then
		item = {key = key}
		themeSystem.favoriteSystem.items[key] = item
	end
	item.title = titleText
	item.category = category
	item.tab = tabName
	item.card = card
	item.baseOrder = baseOrder or card.LayoutOrder
	themeSystem.favoriteSystem.attachStar(item)
	themeSystem.favoriteSystem.applyOrder(item)
	if themeSystem.favoriteSystem.ready then
		themeSystem.favoriteSystem.refresh()
	end
	return item
end

function themeSystem.favoriteSystem.registerTheme(cardKey, themeCard, baseOrder)
	return themeSystem.favoriteSystem.register(
		"theme:" .. cardKey,
		themeCard.theme.name,
		"THEME",
		"Themes",
		themeCard.card,
		baseOrder
	)
end

function themeSystem.favoriteSystem.registerPreset(preset, card, baseOrder)
	return themeSystem.favoriteSystem.register(
		"preset:" .. preset.id,
		preset.name,
		"PRESET",
		"Presets",
		card,
		baseOrder
	)
end

function themeSystem.favoriteSystem.unregister(key)
	local item = themeSystem.favoriteSystem.items[key]
	if item and item.star and item.star.Parent then
		item.star:Destroy()
	end
	themeSystem.favoriteSystem.items[key] = nil
	themeSystem.favoriteSystem.states[key] = nil
	if themeSystem.favoriteSystem.ready then
		themeSystem.favoriteSystem.refresh()
	end
end

function themeSystem.favoriteSystem.setFavorite(key, favorited)
	local item = themeSystem.favoriteSystem.items[key]
	if not item then
		return
	end
	themeSystem.favoriteSystem.states[key] = favorited == true or nil
	themeSystem.favoriteSystem.updateStar(item)
	themeSystem.favoriteSystem.applyOrder(item)
	themeSystem.favoriteSystem.refresh()
end

function themeSystem.favoriteSystem.restore(savedFavorites)
	table.clear(themeSystem.favoriteSystem.states)
	for key, favorited in pairs(savedFavorites or {}) do
		if favorited and themeSystem.favoriteSystem.items[key] then
			themeSystem.favoriteSystem.states[key] = true
		end
	end
	for _, item in pairs(themeSystem.favoriteSystem.items) do
		themeSystem.favoriteSystem.updateStar(item)
		themeSystem.favoriteSystem.applyOrder(item)
	end
	themeSystem.favoriteSystem.refresh()
end

function themeSystem.favoriteSystem.openItem(item)
	if not item or not item.card or not item.card.Parent then
		return
	end
	local assignedTabs = themeSystem.searchSystem.tabsByCard and themeSystem.searchSystem.tabsByCard[item.card]
	showTab(assignedTabs and assignedTabs[1] or item.tab)
	task.defer(function()
		if item.card and item.card.Parent and item.card.Visible then
			local offset = item.card.AbsolutePosition.Y - content.AbsolutePosition.Y + content.CanvasPosition.Y - 8
			content.CanvasPosition = Vector2.new(0, math.max(0, offset))
		end
	end)
end

function themeSystem.favoriteSystem.refresh()
	for _, card in ipairs(themeSystem.favoriteSystem.displayCards) do
		card:Destroy()
	end
	table.clear(themeSystem.favoriteSystem.displayCards)

	local favorites = {}
	for key, favorited in pairs(themeSystem.favoriteSystem.states) do
		local item = favorited and themeSystem.favoriteSystem.items[key]
		if item and item.card and item.card.Parent then
			table.insert(favorites, item)
		end
	end
		local categoryOrder = {CHEAT = 1, WAYPOINT = 2, THEME = 3, PRESET = 4}
	table.sort(favorites, function(a, b)
		local aCategory = categoryOrder[a.category] or 99
		local bCategory = categoryOrder[b.category] or 99
		if aCategory == bCategory then
			return string.lower(a.title) < string.lower(b.title)
		end
		return aCategory < bCategory
	end)

	for index, item in ipairs(favorites) do
		local card = addCard("FavoriteItem_" .. index, 86, index)
		local heading, description = addCardTitle(card, item.title, item.category .. "  |  FAVORITE")
		heading.Position = UDim2.fromOffset(50, heading.Position.Y.Offset)
		heading.Size = UDim2.new(1, -142, 0, heading.Size.Y.Offset)
		description.Position = UDim2.fromOffset(50, description.Position.Y.Offset)
		description.Size = UDim2.new(1, -142, 0, description.Size.Y.Offset)

		local star = Instance.new("TextButton")
		star.Name = "FavoriteStar"
		star.Position = UDim2.fromOffset(15, 11)
		star.Size = UDim2.fromOffset(27, 27)
		star.BackgroundTransparency = 1
		star.BorderSizePixel = 0
		star.AutoButtonColor = false
		star.Font = Enum.Font.GothamBold
		star.Text = "★"
		star.TextColor3 = Color3.fromRGB(255, 205, 48)
		star.TextSize = 22
		star.ZIndex = 8
		star:SetAttribute("WavePolished", true)
		star.Parent = card

		local openButton = Instance.new("TextButton")
		openButton.Name = "OpenFavoriteButton"
		openButton.AnchorPoint = Vector2.new(1, 0.5)
		openButton.Position = UDim2.new(1, -17, 0.5, 0)
		openButton.Size = UDim2.fromOffset(70, 30)
		openButton.BackgroundColor3 = colors.accent
		openButton.BorderSizePixel = 0
		openButton.AutoButtonColor = false
		openButton.Font = Enum.Font.GothamBold
		openButton.Text = "OPEN"
		openButton.TextColor3 = colors.text
		openButton.TextSize = 10
		openButton.Parent = card
		addCorner(openButton, 8)
		themeSystem.styleButton(openButton)

		star.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.favoriteSystem.setFavorite(item.key, false)
		end)
		openButton.Activated:Connect(function()
			playSound(clickSound)
			themeSystem.favoriteSystem.openItem(item)
		end)

		card.Visible = activeTabName == "Customize"
		table.insert(themeSystem.favoriteSystem.displayCards, card)
	end

	if themeSystem.favoriteSystem.emptyCard then
		themeSystem.favoriteSystem.emptyCard.Visible = activeTabName == "Customize" and #favorites == 0
	end
end

function themeSystem.favoriteSystem.setCardsVisible(visible)
	for _, card in ipairs(themeSystem.favoriteSystem.displayCards) do
		card.Visible = visible
	end
	if themeSystem.favoriteSystem.emptyCard then
		local hasFavorites = false
		for key, favorited in pairs(themeSystem.favoriteSystem.states) do
			if favorited and themeSystem.favoriteSystem.items[key] then
				hasFavorites = true
				break
			end
		end
		themeSystem.favoriteSystem.emptyCard.Visible = visible and not hasFavorites
	end
end

themeSystem.waypoints.builder = addCard("WaypointBuilder", 190, 0)
addCardTitle(themeSystem.waypoints.builder, "Create Waypoint", "Stand at a location, choose its name and color, then save it.")
themeSystem.waypoints.builder.Visible = false

themeSystem.waypoints.nameBox = Instance.new("TextBox")
themeSystem.waypoints.nameBox.Name = "WaypointNameBox"
themeSystem.waypoints.nameBox.Position = UDim2.fromOffset(17, 66)
themeSystem.waypoints.nameBox.Size = UDim2.new(0.54, -22, 0, 36)
themeSystem.waypoints.nameBox.BackgroundColor3 = colors.input
themeSystem.waypoints.nameBox.BorderSizePixel = 0
themeSystem.waypoints.nameBox.ClearTextOnFocus = false
themeSystem.waypoints.nameBox.Font = Enum.Font.GothamMedium
themeSystem.waypoints.nameBox.PlaceholderText = "Waypoint name"
themeSystem.waypoints.nameBox.PlaceholderColor3 = colors.faint
themeSystem.waypoints.nameBox.Text = ""
themeSystem.waypoints.nameBox.TextColor3 = colors.text
themeSystem.waypoints.nameBox.TextSize = 11
themeSystem.waypoints.nameBox.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.waypoints.nameBox.Parent = themeSystem.waypoints.builder
addCorner(themeSystem.waypoints.nameBox, 8)
themeSystem.waypoints.namePadding = Instance.new("UIPadding")
themeSystem.waypoints.namePadding.PaddingLeft = UDim.new(0, 12)
themeSystem.waypoints.namePadding.PaddingRight = UDim.new(0, 12)
themeSystem.waypoints.namePadding.Parent = themeSystem.waypoints.nameBox

themeSystem.waypoints.colorLabel = Instance.new("TextLabel")
themeSystem.waypoints.colorLabel.Position = UDim2.new(0.57, 0, 0, 58)
themeSystem.waypoints.colorLabel.Size = UDim2.new(0.43, -17, 0, 14)
themeSystem.waypoints.colorLabel.BackgroundTransparency = 1
themeSystem.waypoints.colorLabel.Font = Enum.Font.GothamBold
themeSystem.waypoints.colorLabel.Text = "MARKER COLOR"
themeSystem.waypoints.colorLabel.TextColor3 = colors.muted
themeSystem.waypoints.colorLabel.TextSize = 8
themeSystem.waypoints.colorLabel.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.waypoints.colorLabel.Parent = themeSystem.waypoints.builder

themeSystem.waypoints.colorTrack = Instance.new("Frame")
themeSystem.waypoints.colorTrack.Name = "WaypointHueTrack"
themeSystem.waypoints.colorTrack.Position = UDim2.new(0.57, 0, 0, 81)
themeSystem.waypoints.colorTrack.Size = UDim2.new(0.43, -52, 0, 10)
themeSystem.waypoints.colorTrack.BackgroundColor3 = Color3.new(1, 1, 1)
themeSystem.waypoints.colorTrack.BorderSizePixel = 0
themeSystem.waypoints.colorTrack.Active = true
themeSystem.waypoints.colorTrack.Parent = themeSystem.waypoints.builder
addCorner(themeSystem.waypoints.colorTrack, 5)
themeSystem.waypoints.colorGradient = Instance.new("UIGradient")
themeSystem.waypoints.colorGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0.82, 1)),
	ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 0.82, 1)),
	ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 0.82, 1)),
	ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 0.82, 1)),
	ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 0.82, 1)),
	ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 0.82, 1)),
	ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 0.82, 1)),
})
themeSystem.waypoints.colorGradient.Parent = themeSystem.waypoints.colorTrack
themeSystem.waypoints.colorKnob = Instance.new("Frame")
themeSystem.waypoints.colorKnob.Name = "HueKnob"
themeSystem.waypoints.colorKnob.AnchorPoint = Vector2.new(0.5, 0.5)
themeSystem.waypoints.colorKnob.Position = UDim2.new(themeSystem.waypoints.selectedHue, 0, 0.5, 0)
themeSystem.waypoints.colorKnob.Size = UDim2.fromOffset(16, 16)
themeSystem.waypoints.colorKnob.BackgroundColor3 = Color3.new(1, 1, 1)
themeSystem.waypoints.colorKnob.BorderSizePixel = 0
themeSystem.waypoints.colorKnob.ZIndex = 4
themeSystem.waypoints.colorKnob.Parent = themeSystem.waypoints.colorTrack
addCorner(themeSystem.waypoints.colorKnob, 8)
themeSystem.waypoints.colorKnobStroke = Instance.new("UIStroke")
themeSystem.waypoints.colorKnobStroke.Color = colors.background
themeSystem.waypoints.colorKnobStroke.Thickness = 2
themeSystem.waypoints.colorKnobStroke.Parent = themeSystem.waypoints.colorKnob
themeSystem.waypoints.colorPreview = Instance.new("Frame")
themeSystem.waypoints.colorPreview.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.waypoints.colorPreview.Position = UDim2.new(1, -17, 0, 86)
themeSystem.waypoints.colorPreview.Size = UDim2.fromOffset(24, 24)
themeSystem.waypoints.colorPreview.BackgroundColor3 = Color3.fromHSV(themeSystem.waypoints.selectedHue, 0.82, 1)
themeSystem.waypoints.colorPreview.BorderSizePixel = 0
themeSystem.waypoints.colorPreview.Parent = themeSystem.waypoints.builder
addCorner(themeSystem.waypoints.colorPreview, 12)
themeSystem.waypoints.colorPreviewStroke = Instance.new("UIStroke")
themeSystem.waypoints.colorPreviewStroke.Color = colors.text
themeSystem.waypoints.colorPreviewStroke.Transparency = 0.2
themeSystem.waypoints.colorPreviewStroke.Parent = themeSystem.waypoints.colorPreview

themeSystem.waypoints.saveButton = Instance.new("TextButton")
themeSystem.waypoints.saveButton.Name = "SaveWaypointButton"
themeSystem.waypoints.saveButton.Position = UDim2.fromOffset(17, 116)
themeSystem.waypoints.saveButton.Size = UDim2.new(1, -34, 0, 38)
themeSystem.waypoints.saveButton.BackgroundColor3 = colors.accent
themeSystem.waypoints.saveButton.BorderSizePixel = 0
themeSystem.waypoints.saveButton.AutoButtonColor = false
themeSystem.waypoints.saveButton.Font = Enum.Font.GothamBold
themeSystem.waypoints.saveButton.Text = "SAVE CURRENT POSITION"
themeSystem.waypoints.saveButton.TextColor3 = colors.text
themeSystem.waypoints.saveButton.TextSize = 10
themeSystem.waypoints.saveButton.Parent = themeSystem.waypoints.builder
addCorner(themeSystem.waypoints.saveButton, 8)
themeSystem.styleButton(themeSystem.waypoints.saveButton)

themeSystem.waypoints.status = Instance.new("TextLabel")
themeSystem.waypoints.status.Position = UDim2.fromOffset(17, 160)
themeSystem.waypoints.status.Size = UDim2.new(1, -34, 0, 16)
themeSystem.waypoints.status.BackgroundTransparency = 1
themeSystem.waypoints.status.Font = Enum.Font.GothamMedium
themeSystem.waypoints.status.Text = "READY"
themeSystem.waypoints.status.TextColor3 = colors.muted
themeSystem.waypoints.status.TextSize = 8
themeSystem.waypoints.status.TextXAlignment = Enum.TextXAlignment.Center
themeSystem.waypoints.status.Parent = themeSystem.waypoints.builder

function themeSystem.waypoints.setStatus(message, good)
	themeSystem.waypoints.status.Text = string.upper(tostring(message or ""))
	themeSystem.waypoints.status.TextColor3 = good == false and colors.danger or (good == true and colors.success or colors.muted)
end

function themeSystem.waypoints.setHue(hue)
	themeSystem.waypoints.selectedHue = math.clamp(tonumber(hue) or 0, 0, 1)
	themeSystem.waypoints.selectedColor = Color3.fromHSV(themeSystem.waypoints.selectedHue, 0.82, 1)
	themeSystem.waypoints.colorKnob.Position = UDim2.new(themeSystem.waypoints.selectedHue, 0, 0.5, 0)
	themeSystem.waypoints.colorPreview.BackgroundColor3 = themeSystem.waypoints.selectedColor
end

function themeSystem.waypoints.updateHueFromInput(input)
	local width = math.max(themeSystem.waypoints.colorTrack.AbsoluteSize.X, 1)
	themeSystem.waypoints.setHue((input.Position.X - themeSystem.waypoints.colorTrack.AbsolutePosition.X) / width)
end

themeSystem.waypoints.colorTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		themeSystem.waypoints.colorDragging = true
		themeSystem.waypoints.colorTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
		themeSystem.waypoints.updateHueFromInput(input)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if themeSystem.waypoints.colorDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == themeSystem.waypoints.colorTouch) then
		themeSystem.waypoints.updateHueFromInput(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == themeSystem.waypoints.colorTouch then
		themeSystem.waypoints.colorDragging = false
		themeSystem.waypoints.colorTouch = nil
	end
end)

function themeSystem.waypoints.getCFrame(item)
	if not item or type(item.cframe) ~= "table" or #item.cframe < 3 then return nil end
	local success, value = pcall(function() return CFrame.new(table.unpack(item.cframe)) end)
	return success and value or nil
end

function themeSystem.waypoints.findById(id)
	for _, item in ipairs(themeSystem.waypoints.items) do
		if item.id == id then return item end
	end
end

function themeSystem.waypoints.findByName(name)
	name = string.lower(tostring(name or ""))
	if name == "" then return nil end
	for _, item in ipairs(themeSystem.waypoints.items) do
		if string.lower(item.name) == name then return item end
	end
	for _, item in ipairs(themeSystem.waypoints.items) do
		if string.sub(string.lower(item.name), 1, #name) == name then return item end
	end
end

function themeSystem.waypoints.clearMarker(item)
	local marker = themeSystem.waypoints.markers[item.id]
	if marker then marker:Destroy() end
	themeSystem.waypoints.markers[item.id] = nil
end

function themeSystem.waypoints.createMarker(item)
	themeSystem.waypoints.clearMarker(item)
	local savedCFrame = themeSystem.waypoints.getCFrame(item)
	if not savedCFrame then return end
	local markerPart = Instance.new("Part")
	markerPart.Name = "WaveWaypoint_" .. tostring(item.id)
	markerPart.Size = Vector3.new(0.1, 0.1, 0.1)
	markerPart.CFrame = savedCFrame
	markerPart.Anchored = true
	markerPart.CanCollide = false
	markerPart.CanQuery = false
	markerPart.CanTouch = false
	markerPart.CastShadow = false
	markerPart.Transparency = 1
	markerPart.Parent = workspace
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "WaypointMarker"
	billboard.Adornee = markerPart
	billboard.Size = UDim2.fromOffset(230, 42)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.2, 0)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.Parent = markerPart
	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 6, 0.5, 0)
	dot.Size = UDim2.fromOffset(16, 16)
	dot.BackgroundColor3 = item.color
	dot.BorderSizePixel = 0
	dot.Parent = billboard
	addCorner(dot, 8)
	local dotStroke = Instance.new("UIStroke")
	dotStroke.Color = Color3.new(1, 1, 1)
	dotStroke.Transparency = 0.18
	dotStroke.Thickness = 1.5
	dotStroke.Parent = dot
	local label = Instance.new("TextLabel")
	label.Position = UDim2.fromOffset(30, 0)
	label.Size = UDim2.new(1, -32, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = item.name
	label.TextColor3 = item.color
	label.TextSize = 14
	label.TextStrokeColor3 = colors.background
	label.TextStrokeTransparency = 0.08
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = billboard
	themeSystem.waypoints.markers[item.id] = markerPart
end

function themeSystem.waypoints.rebuildMarkers()
	for _, marker in pairs(themeSystem.waypoints.markers) do marker:Destroy() end
	table.clear(themeSystem.waypoints.markers)
	for _, item in ipairs(themeSystem.waypoints.items) do themeSystem.waypoints.createMarker(item) end
end

function themeSystem.waypoints.teleport(item)
	local targetCFrame = themeSystem.waypoints.getCFrame(item)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not targetCFrame or not rootPart then return false end
	themeSystem.waypoints.walkGeneration += 1
	rootPart.CFrame = targetCFrame + Vector3.new(0, 3, 0)
	return true
end

function themeSystem.waypoints.walk(item)
	local targetCFrame = themeSystem.waypoints.getCFrame(item)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not targetCFrame or not rootPart or not humanoid then return false end
	themeSystem.waypoints.walkGeneration += 1
	local generation = themeSystem.waypoints.walkGeneration
	task.spawn(function()
		local path = PathfindingService:CreatePath({AgentCanJump = true, AgentCanClimb = true})
		local success = pcall(function() path:ComputeAsync(rootPart.Position, targetCFrame.Position) end)
		if not success or path.Status ~= Enum.PathStatus.Success then
			themeSystem.waypoints.setStatus("No walkable route found", false)
			return
		end
		for _, pathPoint in ipairs(path:GetWaypoints()) do
			if themeSystem.waypoints.walkGeneration ~= generation or humanoid.Health <= 0 then return end
			if pathPoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
			humanoid:MoveTo(pathPoint.Position)
			if not humanoid.MoveToFinished:Wait() then
				themeSystem.waypoints.setStatus("Walk was blocked", false)
				return
			end
		end
		themeSystem.waypoints.setStatus("Reached " .. item.name, true)
	end)
	return true
end

function themeSystem.waypoints.edit(item)
	themeSystem.waypoints.editingId = item.id
	themeSystem.waypoints.nameBox.Text = item.name
	local hue = select(1, item.color:ToHSV())
	themeSystem.waypoints.setHue(hue)
	themeSystem.waypoints.saveButton.Text = "SAVE NAME & COLOR"
	themeSystem.waypoints.setStatus("Editing keeps the saved position", nil)
	showTab("Waypoints")
	content.CanvasPosition = Vector2.zero
end

function themeSystem.waypoints.delete(item)
	themeSystem.waypoints.walkGeneration += 1
	if themeSystem.waypoints.editingId == item.id then themeSystem.waypoints.editingId = nil end
	themeSystem.favoriteSystem.unregister("waypoint:" .. item.id)
	themeSystem.waypoints.clearMarker(item)
	for index, savedItem in ipairs(themeSystem.waypoints.items) do
		if savedItem == item then table.remove(themeSystem.waypoints.items, index) break end
	end
	themeSystem.waypoints.rebuildCards()
	themeSystem.waypoints.setStatus("Waypoint deleted", true)
end

function themeSystem.waypoints.rebuildCards()
	for _, card in ipairs(themeSystem.waypoints.cards) do card:Destroy() end
	table.clear(themeSystem.waypoints.cards)
	for index, item in ipairs(themeSystem.waypoints.items) do
		local card = addCard("SavedWaypoint_" .. tostring(item.id), 136, 10 + index)
		local savedCFrame = themeSystem.waypoints.getCFrame(item)
		local position = savedCFrame and savedCFrame.Position or Vector3.zero
		local heading, description = addCardTitle(card, item.name, string.format("X %.1f   Y %.1f   Z %.1f", position.X, position.Y, position.Z))
		local colorDot = Instance.new("Frame")
		colorDot.Position = UDim2.fromOffset(51, 18)
		colorDot.Size = UDim2.fromOffset(14, 14)
		colorDot.BackgroundColor3 = item.color
		colorDot.BorderSizePixel = 0
		colorDot.Parent = card
		addCorner(colorDot, 7)
		local actions = Instance.new("Frame")
		actions.Position = UDim2.fromOffset(17, 84)
		actions.Size = UDim2.new(1, -34, 0, 36)
		actions.BackgroundTransparency = 1
		actions.Parent = card
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = actions
		local function makeAction(name, text, color, order, callback)
			local button = Instance.new("TextButton")
			button.Name = name
			button.Size = UDim2.new(0.25, -5, 1, 0)
			button.BackgroundColor3 = color
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = Enum.Font.GothamBold
			button.Text = text
			button.TextColor3 = colors.text
			button.TextSize = 8
			button.LayoutOrder = order
			button.Parent = actions
			addCorner(button, 7)
			themeSystem.styleButton(button)
			button.Activated:Connect(function() playSound(clickSound) callback() end)
		end
		makeAction("TeleportWaypoint", "TELEPORT", colors.accent, 1, function()
			if themeSystem.waypoints.teleport(item) then themeSystem.waypoints.setStatus("Teleported to " .. item.name, true) end
		end)
		makeAction("WalkWaypoint", "WALK", colors.accentSoft, 2, function()
			if themeSystem.waypoints.walk(item) then themeSystem.waypoints.setStatus("Walking to " .. item.name, nil) end
		end)
		makeAction("EditWaypoint", "EDIT", colors.input, 3, function() themeSystem.waypoints.edit(item) end)
		makeAction("DeleteWaypoint", "DELETE", colors.danger, 4, function() themeSystem.waypoints.delete(item) end)
		card.Visible = activeTabName == "Movement" or activeTabName == "Utility"
		table.insert(themeSystem.waypoints.cards, card)
		themeSystem.favoriteSystem.register("waypoint:" .. item.id, item.name, "WAYPOINT", "Waypoints", card, 10 + index)
		heading.Position = UDim2.fromOffset(76, heading.Position.Y.Offset)
		heading.Size = UDim2.new(1, -93, 0, heading.Size.Y.Offset)
		description.Position = UDim2.fromOffset(76, description.Position.Y.Offset)
		description.Size = UDim2.new(1, -93, 0, description.Size.Y.Offset)
	end
end

function themeSystem.waypoints.saveCurrent()
	local name = string.gsub(themeSystem.waypoints.nameBox.Text or "", "^%s*(.-)%s*$", "%1")
	if name == "" then themeSystem.waypoints.setStatus("Enter a waypoint name", false) return false end
	local color = themeSystem.waypoints.selectedColor or Color3.fromHSV(themeSystem.waypoints.selectedHue, 0.82, 1)
	if themeSystem.waypoints.editingId then
		local item = themeSystem.waypoints.findById(themeSystem.waypoints.editingId)
		if not item then themeSystem.waypoints.editingId = nil return false end
		item.name = name
		item.color = color
		themeSystem.waypoints.createMarker(item)
		themeSystem.waypoints.editingId = nil
		themeSystem.waypoints.saveButton.Text = "SAVE CURRENT POSITION"
		themeSystem.waypoints.nameBox.Text = ""
		themeSystem.waypoints.rebuildCards()
		themeSystem.waypoints.setStatus("Waypoint updated", true)
		return true
	end
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then themeSystem.waypoints.setStatus("Character is not ready", false) return false end
	themeSystem.waypoints.nextId += 1
	local item = {
		id = tostring(themeSystem.waypoints.nextId),
		name = name,
		color = color,
		cframe = {rootPart.CFrame:GetComponents()},
	}
	table.insert(themeSystem.waypoints.items, item)
	themeSystem.waypoints.nameBox.Text = ""
	themeSystem.waypoints.createMarker(item)
	themeSystem.waypoints.rebuildCards()
	themeSystem.waypoints.setStatus("Waypoint saved", true)
	return true
end

function themeSystem.waypoints.serialize()
	local serialized = {}
	for _, item in ipairs(themeSystem.waypoints.items) do
		table.insert(serialized, {
			id = item.id,
			name = item.name,
			cframe = table.clone(item.cframe),
			color = {item.color.R, item.color.G, item.color.B},
		})
	end
	return serialized
end

function themeSystem.waypoints.loadSerialized(savedItems)
	for _, item in ipairs(themeSystem.waypoints.items) do
		themeSystem.favoriteSystem.unregister("waypoint:" .. item.id)
	end
	for _, marker in pairs(themeSystem.waypoints.markers) do marker:Destroy() end
	table.clear(themeSystem.waypoints.markers)
	table.clear(themeSystem.waypoints.items)
	themeSystem.waypoints.nextId = 0
	for index, saved in ipairs(type(savedItems) == "table" and savedItems or {}) do
		if type(saved) == "table" and type(saved.name) == "string" and type(saved.cframe) == "table" and #saved.cframe >= 3 then
			local id = tostring(saved.id or index)
			local colorData = type(saved.color) == "table" and saved.color or {}
			local color = Color3.new(
				math.clamp(tonumber(colorData[1]) or 0.18, 0, 1),
				math.clamp(tonumber(colorData[2]) or 0.82, 0, 1),
				math.clamp(tonumber(colorData[3]) or 1, 0, 1)
			)
			table.insert(themeSystem.waypoints.items, {id = id, name = saved.name, cframe = table.clone(saved.cframe), color = color})
			themeSystem.waypoints.nextId = math.max(themeSystem.waypoints.nextId, tonumber(id) or index)
		end
	end
	themeSystem.waypoints.rebuildMarkers()
	themeSystem.waypoints.rebuildCards()
end

function themeSystem.waypoints.setCardsVisible(visible)
	themeSystem.waypoints.builder.Visible = visible
	for _, card in ipairs(themeSystem.waypoints.cards) do card.Visible = visible end
end

themeSystem.waypoints.saveButton.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.waypoints.saveCurrent()
end)
themeSystem.waypoints.setHue(themeSystem.waypoints.selectedHue)

themeSystem.favoriteSystem.emptyCard = addCard("FavoritesEmpty", 86, 0)
addCardTitle(themeSystem.favoriteSystem.emptyCard, "No favorites yet", "Click any yellow outline star to add it here.")
themeSystem.favoriteSystem.emptyCard.Visible = false

themeSystem.favoriteSystem.cheatItems = {
	{"cheat:panic", "Panic", themeSystem.panic.card, 0},
	{"cheat:movement", "Movement Speed", speedCard, 1},
	{"cheat:jump", "Jump Height", jumpCard, 2},
	{"cheat:gravity", "Gravity", gravityCard, 3},
	{"cheat:noclip", "Noclip", utilityCard, 4},
	{"cheat:fly", "Fly", flyCard, 5},
	{"cheat:god", "God Mode", godCard, 6},
	{"cheat:vehiclefly", "Vehicle Fly", vehicleFlyCard, 7},
	{"cheat:fullbright", "Full Bright", fullBrightCard, 8},
	{"cheat:freecam", "Freecam", freecamCard, 9},
	{"cheat:zoom", "Zoom", zoom.card, 10},
	{"cheat:clickteleport", "Click Teleport", teleportClick.card, 11},
	{"cheat:goto", "GoTo", gotoPlayer.card, 12},
	{"cheat:spectate", "Spectate", spectate.card, 13},
	{"cheat:leave", "Leave", leave.card, 14},
	{"cheat:rejoin", "Rejoin", rejoin.card, 15},
	{"cheat:serverhop", "Server Hop", serverHop.card, 16},
	{"cheat:freeze", "Freeze", freeze.card, 17},
	{"cheat:spin", "Spin", spin.card, 18},
	{"cheat:float", "Float", floatCard, 19},
	{"cheat:infinitejump", "Infinite Jump", infiniteJumpCard, 20},
	{"cheat:esp", "ESP", espCard, 21},
	{"cheat:aimbot", "Aimbot", themeSystem.aimbot.card, 22},
	{"cheat:triggerbot", "Trigger Bot", themeSystem.triggerBot.card, 23},
	{"cheat:fieldofview", "Field of View", fieldOfView.card, 24},
	{"cheat:invisibility", "Invisibility", invisibility.card, 25},
		{"cheat:walkfling", "Walkfling", walkfling.card, 26},
		{"cheat:healthdisplay", "Health Display", themeSystem.healthDisplay.card, 27},
		{"cheat:wavetags", "WAVE Tags", themeSystem.waveTags.card, 28},
		{"cheat:instantprompts", "Instant Prompts", themeSystem.instantPrompts.card, 29},
		{"cheat:coordinates", "Show Coordinates", themeSystem.coordinates.card, 30},
		{"cheat:autosell", "Make Your Own Auto Sell", themeSystem.autoSell.card, 31},
		{"cheat:randomize", "Randomize Everything", themeSystem.randomize.card, 32},
		{"cheat:playertrails", "Player Trails", themeSystem.playerTrails.card, 33},
		{"cheat:playerinspector", "Player Inspector", themeSystem.playerInspector.card, 34},
	}

for _, cheatData in ipairs(themeSystem.favoriteSystem.cheatItems) do
	themeSystem.favoriteSystem.register(cheatData[1], cheatData[2], "CHEAT", "Home", cheatData[3], cheatData[4])
end
for cardKey, themeCard in pairs(themeSystem.cards) do
	themeSystem.favoriteSystem.registerTheme(cardKey, themeCard, themeCard.card.LayoutOrder)
end
themeSystem.favoriteSystem.ready = true
presetSystem.loadFromDisk()
themeSystem.favoriteSystem.refresh()

function themeSystem.keybindSystem.updateBox(item)
	if not item or not item.box or not item.box.Parent then
		return
	end
	item.box.Text = item.keyCode and string.upper(item.keyCode.Name) or "NONE"
	item.box.TextColor3 = item.keyCode and colors.text or colors.muted
	item.box.BackgroundColor3 = colors.input
end

function themeSystem.keybindSystem.stopListening()
	local item = themeSystem.keybindSystem.listening
	themeSystem.keybindSystem.listening = nil
	if item then
		themeSystem.keybindSystem.updateBox(item)
	end
end

function themeSystem.keybindSystem.beginListening(item)
	if themeSystem.keybindSystem.listening and themeSystem.keybindSystem.listening ~= item then
		themeSystem.keybindSystem.updateBox(themeSystem.keybindSystem.listening)
	end
	themeSystem.keybindSystem.listening = item
	item.box.Text = "PRESS"
	item.box.TextColor3 = colors.text
	item.box.BackgroundColor3 = colors.accentSoft
end

function themeSystem.keybindSystem.assign(item, keyCode)
	if item.keyCode then
		themeSystem.keybindSystem.byKey[item.keyCode] = nil
	end
	if keyCode then
		local previousItem = themeSystem.keybindSystem.byKey[keyCode]
		if previousItem and previousItem ~= item then
			previousItem.keyCode = nil
			themeSystem.keybindSystem.updateBox(previousItem)
		end
		item.keyCode = keyCode
		themeSystem.keybindSystem.byKey[keyCode] = item
	else
		item.keyCode = nil
	end
	themeSystem.keybindSystem.listening = nil
	themeSystem.keybindSystem.updateBox(item)
end

function themeSystem.keybindSystem.restore(savedKeybinds)
	table.clear(themeSystem.keybindSystem.byKey)
	for _, item in pairs(themeSystem.keybindSystem.items) do
		item.keyCode = nil
		themeSystem.keybindSystem.updateBox(item)
	end
	for id, keyName in pairs(savedKeybinds or {}) do
		local item = themeSystem.keybindSystem.items[id]
		local keyCode = type(keyName) == "string" and Enum.KeyCode[keyName] or nil
			if item and keyCode and keyCode ~= Enum.KeyCode.LeftControl and keyCode ~= Enum.KeyCode.RightControl and keyCode ~= Enum.KeyCode.Tab then
			themeSystem.keybindSystem.assign(item, keyCode)
		end
	end
end

function themeSystem.keybindSystem.makeBox(item, parent, position, size)
	local box = Instance.new("TextButton")
	box.Name = "CheatKeybindBox"
	box.AnchorPoint = Vector2.new(1, 0)
	box.Position = position
	box.Size = size
	box.BackgroundColor3 = colors.input
	box.BorderSizePixel = 0
	box.AutoButtonColor = false
	box.Font = Enum.Font.GothamBold
	box.Text = "NONE"
	box.TextColor3 = colors.muted
	box.TextSize = 8
	box.TextTruncate = Enum.TextTruncate.AtEnd
	box.ZIndex = 8
	box:SetAttribute("WavePolished", true)
	box.Parent = parent
	addCorner(box, 6)
	local stroke = Instance.new("UIStroke")
	stroke.Color = colors.border
	stroke.Transparency = 0.5
	stroke.Parent = box
	box.MouseEnter:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.08, Color = colors.accent2}):Play()
	end)
	box.MouseLeave:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.5, Color = colors.border}):Play()
	end)
	box.Activated:Connect(function()
		playSound(clickSound)
		themeSystem.keybindSystem.beginListening(item)
	end)
	item.box = box
	return box
end

function themeSystem.keybindSystem.registerCard(id, card, action)
	local item = {id = id, card = card, action = action}
	themeSystem.keybindSystem.items[id] = item
	local heading = card:FindFirstChild("CardHeading")
	if heading then
		heading.Size = UDim2.new(1, -137, 0, heading.Size.Y.Offset)
	end
	themeSystem.keybindSystem.makeBox(
		item,
		card,
		UDim2.new(1, -15, 0, 11),
		UDim2.fromOffset(58, 25)
	)
	return item
end

function themeSystem.keybindSystem.registerNested(id, parent, titleLabel, descriptionLabel, action)
	local item = {id = id, card = parent, action = action}
	themeSystem.keybindSystem.items[id] = item
	if titleLabel then
		titleLabel.Size = UDim2.new(1, -132, 0, titleLabel.Size.Y.Offset)
	end
	if descriptionLabel then
		descriptionLabel.Size = UDim2.new(1, -132, 0, descriptionLabel.Size.Y.Offset)
	end
	themeSystem.keybindSystem.makeBox(
		item,
		parent,
		UDim2.new(1, -62, 0, 8),
		UDim2.fromOffset(52, 22)
	)
	return item
end

themeSystem.keybindSystem.registerCard("noclip", utilityCard, function()
	playSound(clickSound)
	noclipEnabled = not noclipEnabled
	setNoclipVisual(noclipEnabled)
	setWallNoclip(noclipEnabled)
end)
themeSystem.keybindSystem.registerCard("panic", themeSystem.panic.card, function()
	playSound(clickSound)
	resetToDefaults()
end)
themeSystem.keybindSystem.registerCard("fly", flyCard, function()
	playSound(clickSound)
	setFly(not flyEnabled)
end)
themeSystem.keybindSystem.registerCard("god", godCard, function()
	playSound(clickSound)
	setGodMode(not godModeEnabled)
end)
themeSystem.keybindSystem.registerCard("vehicleFly", vehicleFlyCard, function()
	playSound(clickSound)
	setVehicleFly(not vehicleFlyEnabled)
end)
themeSystem.keybindSystem.registerCard("fullBright", fullBrightCard, function()
	playSound(clickSound)
	setFullBright(not fullBrightEnabled)
end)
themeSystem.keybindSystem.registerCard("freecam", freecamCard, function()
	playSound(clickSound)
	local enableFreecam = not freecamState.enabled
	if enableFreecam and spin.releaseCamera then
		spin.releaseCamera()
	end
	freecamState.setEnabled(enableFreecam)
	if not enableFreecam and spin.value ~= 0 and spin.startCamera then
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			spin.startCamera(rootPart)
		end
	end
end)
themeSystem.keybindSystem.registerCard("zoom", zoom.card, function()
	playSound(clickSound)
	zoom.setEnabled(not zoom.enabled)
end)
themeSystem.keybindSystem.registerCard("clickTeleport", teleportClick.card, function()
	playSound(clickSound)
	teleportClick.setEnabled(not teleportClick.enabled)
end)
themeSystem.keybindSystem.registerCard("goto", gotoPlayer.card, function()
	playSound(clickSound)
	setOpen(true)
	showTab("Home")
	gotoPlayer.setOpen(not gotoPlayer.open)
end)
themeSystem.keybindSystem.registerCard("spectate", spectate.card, function()
	playSound(clickSound)
	if spectate.target then
		spectate.stop()
	else
		setOpen(true)
		showTab("Home")
		spectate.setOpen(not spectate.open)
	end
end)
themeSystem.keybindSystem.registerCard("leave", leave.card, function()
	playSound(clickSound)
	player:Kick("You left the game.")
end)
themeSystem.keybindSystem.registerCard("rejoin", rejoin.card, function()
	if rejoin.busy then
		return
	end
	playSound(clickSound)
	rejoin.busy = true
	rejoin.button.Text = "JOINING..."
	local success = pcall(function()
		if game.JobId ~= "" then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
		else
			TeleportService:Teleport(game.PlaceId, player)
		end
	end)
	if not success then
		rejoin.button.Text = "FAILED"
	end
	rejoin.resetButtonLater()
end)
themeSystem.keybindSystem.registerCard("serverHop", serverHop.card, serverHop.findAndJoin)
themeSystem.keybindSystem.registerCard("freeze", freeze.card, function()
	playSound(clickSound)
	freeze.setEnabled(not freeze.enabled)
end)
themeSystem.keybindSystem.registerNested("antifling", spin.antiflingRow, spin.antiflingTitle, spin.antiflingDescription, function()
	if spin.value == 0 then
		return
	end
	playSound(clickSound)
	spin.setAntifling(not spin.antiflingEnabled)
end)
themeSystem.keybindSystem.registerCard("float", floatCard, function()
	playSound(clickSound)
	setFloat(not floatEnabled)
end)
themeSystem.keybindSystem.registerCard("infiniteJump", infiniteJumpCard, function()
	playSound(clickSound)
	setInfiniteJump(not infiniteJumpEnabled)
end)
themeSystem.keybindSystem.registerCard("esp", espCard, function()
	playSound(clickSound)
	setESP(not espEnabled)
end)
themeSystem.keybindSystem.registerCard("aimbot", themeSystem.aimbot.card, function()
	playSound(clickSound)
	themeSystem.aimbot.setEnabled(not themeSystem.aimbot.enabled)
end)
themeSystem.keybindSystem.registerNested(
	"aimbotRadius",
	themeSystem.aimbot.fovRow,
	themeSystem.aimbot.fovTitle,
	themeSystem.aimbot.fovDescription,
	function()
		playSound(clickSound)
		themeSystem.aimbot.setFovCircleEnabled(not themeSystem.aimbot.fovCircleEnabled)
	end
)
themeSystem.keybindSystem.registerCard("triggerBot", themeSystem.triggerBot.card, function()
	playSound(clickSound)
	themeSystem.triggerBot.setEnabled(not themeSystem.triggerBot.enabled)
end)
themeSystem.keybindSystem.registerCard("fieldOfView", fieldOfView.card, function()
	playSound(clickSound)
	fieldOfView.setEnabled(not fieldOfView.enabled)
end)
themeSystem.keybindSystem.registerCard("invisibility", invisibility.card, function()
	playSound(clickSound)
	invisibility.setEnabled(not invisibility.enabled)
end)
themeSystem.keybindSystem.registerCard("walkfling", walkfling.card, function()
	playSound(clickSound)
	walkfling.setEnabled(not walkfling.enabled)
end)
themeSystem.keybindSystem.registerCard("healthDisplay", themeSystem.healthDisplay.card, function()
	playSound(clickSound)
	themeSystem.healthDisplay.setEnabled(not themeSystem.healthDisplay.enabled)
end)
themeSystem.keybindSystem.registerCard("waveTags", themeSystem.waveTags.card, function()
	playSound(clickSound)
	themeSystem.waveTags.setEnabled(not themeSystem.waveTags.enabled)
end)
themeSystem.keybindSystem.registerCard("instantPrompts", themeSystem.instantPrompts.card, function()
	playSound(clickSound)
	themeSystem.instantPrompts.setEnabled(not themeSystem.instantPrompts.enabled)
end)
themeSystem.keybindSystem.registerCard("coordinates", themeSystem.coordinates.card, function()
	playSound(clickSound)
	themeSystem.coordinates.setEnabled(not themeSystem.coordinates.enabled)
end)
themeSystem.keybindSystem.registerCard("autoSell", themeSystem.autoSell.card, function()
	playSound(clickSound)
	themeSystem.autoSell.setEnabled(not themeSystem.autoSell.enabled)
end)
themeSystem.keybindSystem.registerNested(
	"setSellLocation",
	themeSystem.autoSell.locationRow,
	themeSystem.autoSell.locationTitle,
	themeSystem.autoSell.locationDescription,
	function()
		playSound(clickSound)
		themeSystem.autoSell.setLocation()
	end
)
themeSystem.keybindSystem.registerCard("saveWaypoint", themeSystem.waypoints.builder, function()
	playSound(clickSound)
	themeSystem.waypoints.saveCurrent()
end)
themeSystem.keybindSystem.registerCard("randomize", themeSystem.randomize.card, function()
	playSound(clickSound)
	themeSystem.randomize.run()
end)
themeSystem.keybindSystem.registerCard("playerTrails", themeSystem.playerTrails.card, function()
	playSound(clickSound)
	themeSystem.playerTrails.setEnabled(not themeSystem.playerTrails.enabled)
end)
themeSystem.keybindSystem.registerCard("playerInspector", themeSystem.playerInspector.card, function()
	playSound(clickSound)
	setOpen(true)
	showTab("Home")
	themeSystem.playerInspector.setOpen(not themeSystem.playerInspector.open)
end)
themeSystem.keybindSystem.registerNested("inspectorGoTo", themeSystem.playerInspector.gotoRow, nil, nil, function()
	playSound(clickSound)
	themeSystem.playerInspector.goToSelected()
end)
themeSystem.keybindSystem.registerNested("inspectorSpectate", themeSystem.playerInspector.spectateRow, nil, nil, function()
	playSound(clickSound)
	themeSystem.playerInspector.spectateSelected()
end)
themeSystem.keybindSystem.registerNested("inspectorWaypoint", themeSystem.playerInspector.waypointRow, nil, nil, function()
	playSound(clickSound)
	themeSystem.playerInspector.saveWaypoint()
end)
themeSystem.keybindSystem.registerCard("activeHud", settings.activeHudCard, function()
	playSound(clickSound)
	activeHud.setEnabled(not activeHud.enabled)
end)
themeSystem.keybindSystem.registerNested("nametags", nametagRow, nametagTitle, nametagDescription, function()
	if not espEnabled then
		return
	end
	playSound(clickSound)
	setNametags(not nametagsEnabled)
end)

themeSystem.commandBar = {open = false, commands = {}, usages = {}}
themeSystem.commandBar.frame = Instance.new("Frame")
themeSystem.commandBar.frame.Name = "WaveCommandBar"
themeSystem.commandBar.frame.AnchorPoint = Vector2.new(0.5, 0)
themeSystem.commandBar.frame.Position = UDim2.new(0.5, 0, 0, 18)
themeSystem.commandBar.frame.Size = UDim2.fromOffset(540, 48)
themeSystem.commandBar.frame.BackgroundColor3 = colors.panel
themeSystem.commandBar.frame.BorderSizePixel = 0
themeSystem.commandBar.frame.Visible = false
themeSystem.commandBar.frame.ZIndex = 100
themeSystem.commandBar.frame.Parent = screenGui
addCorner(themeSystem.commandBar.frame, 12)
themeSystem.commandBar.stroke = Instance.new("UIStroke")
themeSystem.commandBar.stroke.Color = colors.accent
themeSystem.commandBar.stroke.Thickness = 1.5
themeSystem.commandBar.stroke.Transparency = 0.12
themeSystem.commandBar.stroke.Parent = themeSystem.commandBar.frame

themeSystem.commandBar.prompt = Instance.new("TextLabel")
themeSystem.commandBar.prompt.Position = UDim2.fromOffset(15, 0)
themeSystem.commandBar.prompt.Size = UDim2.fromOffset(26, 48)
themeSystem.commandBar.prompt.BackgroundTransparency = 1
themeSystem.commandBar.prompt.Font = Enum.Font.GothamBlack
themeSystem.commandBar.prompt.Text = "/"
themeSystem.commandBar.prompt.TextColor3 = colors.accent2
themeSystem.commandBar.prompt.TextSize = 19
themeSystem.commandBar.prompt.ZIndex = 101
themeSystem.commandBar.prompt.Parent = themeSystem.commandBar.frame

themeSystem.commandBar.box = Instance.new("TextBox")
themeSystem.commandBar.box.Name = "CommandInput"
themeSystem.commandBar.box.Position = UDim2.fromOffset(42, 5)
themeSystem.commandBar.box.Size = UDim2.new(1, -52, 0, 38)
themeSystem.commandBar.box.BackgroundTransparency = 1
themeSystem.commandBar.box.ClearTextOnFocus = false
themeSystem.commandBar.box.Font = Enum.Font.GothamMedium
themeSystem.commandBar.box.PlaceholderText = "Type a command — /cmds shows every command"
themeSystem.commandBar.box.PlaceholderColor3 = colors.faint
themeSystem.commandBar.box.Text = ""
themeSystem.commandBar.box.TextColor3 = colors.text
themeSystem.commandBar.box.TextSize = 13
themeSystem.commandBar.box.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.commandBar.box.ZIndex = 101
themeSystem.commandBar.box.Parent = themeSystem.commandBar.frame

themeSystem.commandBar.results = Instance.new("ScrollingFrame")
themeSystem.commandBar.results.Name = "CommandResults"
themeSystem.commandBar.results.Position = UDim2.fromOffset(0, 56)
themeSystem.commandBar.results.Size = UDim2.new(1, 0, 0, 230)
themeSystem.commandBar.results.BackgroundColor3 = colors.panel
themeSystem.commandBar.results.BorderSizePixel = 0
themeSystem.commandBar.results.ScrollBarThickness = 3
themeSystem.commandBar.results.ScrollBarImageColor3 = colors.accent
themeSystem.commandBar.results.AutomaticCanvasSize = Enum.AutomaticSize.Y
themeSystem.commandBar.results.CanvasSize = UDim2.new()
themeSystem.commandBar.results.Visible = false
themeSystem.commandBar.results.ZIndex = 100
themeSystem.commandBar.results.Parent = themeSystem.commandBar.frame
addCorner(themeSystem.commandBar.results, 12)
themeSystem.commandBar.resultsStroke = Instance.new("UIStroke")
themeSystem.commandBar.resultsStroke.Color = colors.border
themeSystem.commandBar.resultsStroke.Transparency = 0.25
themeSystem.commandBar.resultsStroke.Parent = themeSystem.commandBar.results

themeSystem.commandBar.resultText = Instance.new("TextLabel")
themeSystem.commandBar.resultText.Position = UDim2.fromOffset(14, 12)
themeSystem.commandBar.resultText.Size = UDim2.new(1, -28, 0, 18)
themeSystem.commandBar.resultText.AutomaticSize = Enum.AutomaticSize.Y
themeSystem.commandBar.resultText.BackgroundTransparency = 1
themeSystem.commandBar.resultText.Font = Enum.Font.Code
themeSystem.commandBar.resultText.Text = ""
themeSystem.commandBar.resultText.TextColor3 = colors.text
themeSystem.commandBar.resultText.TextSize = 12
themeSystem.commandBar.resultText.TextWrapped = true
themeSystem.commandBar.resultText.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.commandBar.resultText.TextYAlignment = Enum.TextYAlignment.Top
themeSystem.commandBar.resultText.ZIndex = 101
themeSystem.commandBar.resultText.Parent = themeSystem.commandBar.results

function themeSystem.commandBar.setResult(message, good)
	themeSystem.commandBar.results.Visible = true
	themeSystem.commandBar.results.CanvasPosition = Vector2.zero
	themeSystem.commandBar.resultText.Text = tostring(message or "")
	themeSystem.commandBar.resultText.TextColor3 = good == false and colors.danger or colors.text
end

function themeSystem.commandBar.setOpen(open)
	open = open == true
	if open == themeSystem.commandBar.open then return end
	themeSystem.commandBar.open = open
	if open then
		themeSystem.commandBar.frame.Visible = true
		themeSystem.commandBar.frame.Position = UDim2.new(0.5, 0, 0, 8)
		themeSystem.commandBar.frame.BackgroundTransparency = 1
		themeSystem.commandBar.results.Visible = false
		themeSystem.commandBar.usedMouseUnlock = not isOpen
		if themeSystem.commandBar.usedMouseUnlock then menuMouse.unlock() end
		TweenService:Create(themeSystem.commandBar.frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 0, 18), BackgroundTransparency = 0,
		}):Play()
		task.defer(function()
			if themeSystem.commandBar.open then themeSystem.commandBar.box:CaptureFocus() end
		end)
	else
		themeSystem.commandBar.box:ReleaseFocus()
		themeSystem.commandBar.results.Visible = false
		themeSystem.commandBar.frame.Visible = false
		if themeSystem.commandBar.usedMouseUnlock and not isOpen then menuMouse.restore() end
		themeSystem.commandBar.usedMouseUnlock = false
	end
end

function themeSystem.commandBar.register(name, usage, callback)
	themeSystem.commandBar.commands[string.lower(name)] = callback
	table.insert(themeSystem.commandBar.usages, usage)
end

function themeSystem.commandBar.runKeybind(id)
	local item = themeSystem.keybindSystem.items[id]
	if not item or not item.action then return false, "COMMAND IS NOT AVAILABLE" end
	local success, errorMessage = pcall(item.action)
	if not success then return false, "COMMAND FAILED: " .. tostring(errorMessage) end
	return true, "DONE"
end

function themeSystem.commandBar.findPlayer(query)
	query = string.lower(table.concat(query or {}, " "))
	if query == "" then return nil end
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if string.lower(targetPlayer.Name) == query or string.lower(targetPlayer.DisplayName) == query then return targetPlayer end
	end
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if string.sub(string.lower(targetPlayer.Name), 1, #query) == query or string.sub(string.lower(targetPlayer.DisplayName), 1, #query) == query then return targetPlayer end
	end
end

function themeSystem.commandBar.registerToggle(name, usage, keybindId, stateGetter)
	themeSystem.commandBar.register(name, usage, function(arguments)
		local requested = arguments[1] and string.lower(arguments[1]) or nil
		local current = stateGetter()
		if requested == "on" and current then return true, string.upper(name) .. " IS ALREADY ON" end
		if requested == "off" and not current then return true, string.upper(name) .. " IS ALREADY OFF" end
		if requested == nil or requested == "toggle" or (requested == "on" and not current) or (requested == "off" and current) then
			local success, message = themeSystem.commandBar.runKeybind(keybindId)
			if not success then return false, message end
			return true, string.upper(name) .. " " .. (stateGetter() and "ON" or "OFF")
		end
		return false, "USE ON, OFF, OR LEAVE IT BLANK TO TOGGLE"
	end)
end

themeSystem.commandBar.register("cmds", "/cmds", function()
	table.sort(themeSystem.commandBar.usages)
	themeSystem.commandBar.setResult("WAVE COMMANDS\n\n" .. table.concat(themeSystem.commandBar.usages, "\n"), true)
	return true
end)
themeSystem.commandBar.register("panic", "/panic", function() return themeSystem.commandBar.runKeybind("panic") end)
themeSystem.commandBar.register("menu", "/menu", function() setOpen(not isOpen) return true, "MENU TOGGLED" end)
themeSystem.commandBar.registerToggle("noclip", "/noclip [on|off]", "noclip", function() return noclipEnabled end)
themeSystem.commandBar.registerToggle("fly", "/fly [on|off]", "fly", function() return flyEnabled end)
themeSystem.commandBar.registerToggle("god", "/god [on|off]", "god", function() return godModeEnabled end)
themeSystem.commandBar.registerToggle("vehiclefly", "/vehiclefly [on|off]", "vehicleFly", function() return vehicleFlyEnabled end)
themeSystem.commandBar.registerToggle("fullbright", "/fullbright [on|off]", "fullBright", function() return fullBrightEnabled end)
themeSystem.commandBar.registerToggle("freecam", "/freecam [on|off]", "freecam", function() return freecamState.enabled end)
themeSystem.commandBar.registerToggle("zoom", "/zoom [on|off]", "zoom", function() return zoom.enabled end)
themeSystem.commandBar.registerToggle("clicktp", "/clicktp [on|off]", "clickTeleport", function() return teleportClick.enabled end)
themeSystem.commandBar.registerToggle("freeze", "/freeze [on|off]", "freeze", function() return freeze.enabled end)
themeSystem.commandBar.registerToggle("antifling", "/antifling [on|off]", "antifling", function() return spin.antiflingEnabled end)
themeSystem.commandBar.registerToggle("float", "/float [on|off]", "float", function() return floatEnabled end)
themeSystem.commandBar.registerToggle("infinitejump", "/infinitejump [on|off]", "infiniteJump", function() return infiniteJumpEnabled end)
themeSystem.commandBar.registerToggle("esp", "/esp [on|off]", "esp", function() return espEnabled end)
themeSystem.commandBar.registerToggle("aimbot", "/aimbot [on|off]", "aimbot", function() return themeSystem.aimbot.enabled end)
themeSystem.commandBar.registerToggle("aimbotradius", "/aimbotradius [on|off]", "aimbotRadius", function() return themeSystem.aimbot.fovCircleEnabled end)
themeSystem.commandBar.registerToggle("triggerbot", "/triggerbot [on|off]", "triggerBot", function() return themeSystem.triggerBot.enabled end)
themeSystem.commandBar.registerToggle("invisibility", "/invisibility [on|off]", "invisibility", function() return invisibility.enabled end)
themeSystem.commandBar.registerToggle("walkfling", "/walkfling [on|off]", "walkfling", function() return walkfling.enabled end)
themeSystem.commandBar.registerToggle("health", "/health [on|off]", "healthDisplay", function() return themeSystem.healthDisplay.enabled end)
themeSystem.commandBar.registerToggle("wavetags", "/wavetags [on|off]", "waveTags", function() return themeSystem.waveTags.enabled end)
themeSystem.commandBar.registerToggle("instantprompts", "/instantprompts [on|off]", "instantPrompts", function() return themeSystem.instantPrompts.enabled end)
themeSystem.commandBar.commands.instantprompt = themeSystem.commandBar.commands.instantprompts
themeSystem.commandBar.registerToggle("coordinates", "/coordinates [on|off]", "coordinates", function() return themeSystem.coordinates.enabled end)
themeSystem.commandBar.commands.coords = themeSystem.commandBar.commands.coordinates
themeSystem.commandBar.registerToggle("autosell", "/autosell [on|off]", "autoSell", function() return themeSystem.autoSell.enabled end)
themeSystem.commandBar.register("setsell", "/setsell", function()
	if not themeSystem.autoSell.setLocation() then return false, "CHARACTER IS NOT READY" end
	return true, "SELL LOCATION SAVED"
end)
themeSystem.commandBar.register("sellinterval", "/sellinterval <1-120>", function(arguments)
	local value = tonumber(arguments[1])
	if not value then return false, "ENTER AN INTERVAL FROM 1 TO 120 SECONDS" end
	themeSystem.autoSell.setInterval(value)
	return true, string.format("AUTO SELL INTERVAL SET TO %.1f SECONDS", themeSystem.autoSell.interval)
end)
themeSystem.commandBar.register("waypoints", "/waypoints", function()
	setOpen(true)
	showTab("Waypoints")
	return true, "WAYPOINTS OPENED"
end)
themeSystem.commandBar.register("setwaypoint", "/setwaypoint <name>", function(arguments)
	local name = table.concat(arguments, " ")
	if name == "" then return false, "ENTER A WAYPOINT NAME" end
	themeSystem.waypoints.editingId = nil
	themeSystem.waypoints.nameBox.Text = name
	if not themeSystem.waypoints.saveCurrent() then return false, "WAYPOINT COULD NOT BE SAVED" end
	return true, "WAYPOINT SAVED: " .. name
end)
themeSystem.commandBar.register("waypoint", "/waypoint <name>", function(arguments)
	local item = themeSystem.waypoints.findByName(table.concat(arguments, " "))
	if not item then return false, "WAYPOINT NOT FOUND" end
	if not themeSystem.waypoints.teleport(item) then return false, "CHARACTER IS NOT READY" end
	return true, "TELEPORTED TO " .. item.name
end)
themeSystem.commandBar.register("walkwaypoint", "/walkwaypoint <name>", function(arguments)
	local item = themeSystem.waypoints.findByName(table.concat(arguments, " "))
	if not item then return false, "WAYPOINT NOT FOUND" end
	if not themeSystem.waypoints.walk(item) then return false, "CHARACTER IS NOT READY" end
	return true, "WALKING TO " .. item.name
end)
themeSystem.commandBar.register("deletewaypoint", "/deletewaypoint <name>", function(arguments)
	local item = themeSystem.waypoints.findByName(table.concat(arguments, " "))
	if not item then return false, "WAYPOINT NOT FOUND" end
	local name = item.name
	themeSystem.waypoints.delete(item)
	return true, "WAYPOINT DELETED: " .. name
end)
themeSystem.commandBar.register("randomize", "/randomize", function()
	themeSystem.randomize.run()
	return true, "EVERYTHING RANDOMIZED"
end)
themeSystem.commandBar.registerToggle("playertrails", "/playertrails [on|off]", "playerTrails", function() return themeSystem.playerTrails.enabled end)
themeSystem.commandBar.commands.trails = themeSystem.commandBar.commands.playertrails
themeSystem.commandBar.register("trailcolor", "/trailcolor <0-360>", function(arguments)
	local degrees = tonumber(arguments[1])
	if not degrees then return false, "ENTER A COLOR HUE FROM 0 TO 360" end
	themeSystem.playerTrails.setHue((degrees % 360) / 360)
	return true, "TRAIL COLOR UPDATED"
end)
themeSystem.commandBar.register("inspect", "/inspect <player>", function(arguments)
	local targetPlayer = themeSystem.commandBar.findPlayer(arguments)
	if not targetPlayer or targetPlayer == player then return false, "PLAYER NOT FOUND" end
	themeSystem.playerInspector.setSelected(targetPlayer)
	setOpen(true)
	showTab("Home")
	return true, "INSPECTING " .. string.upper(targetPlayer.DisplayName)
end)
themeSystem.commandBar.register("inspectgoto", "/inspectgoto", function()
	local success = themeSystem.playerInspector.goToSelected()
	return success, success and "TELEPORTED" or "SELECT AN AVAILABLE PLAYER FIRST"
end)
themeSystem.commandBar.register("inspectspectate", "/inspectspectate", function()
	local success = themeSystem.playerInspector.spectateSelected()
	return success, success and "SPECTATING" or "SELECT AN AVAILABLE PLAYER FIRST"
end)
themeSystem.commandBar.register("inspectwaypoint", "/inspectwaypoint", function()
	local success = themeSystem.playerInspector.saveWaypoint()
	return success, success and "WAYPOINT SAVED" or "SELECT AN AVAILABLE PLAYER FIRST"
end)
themeSystem.commandBar.registerToggle("activehud", "/activehud [on|off]", "activeHud", function() return activeHud.enabled end)

themeSystem.commandBar.register("nametags", "/nametags [on|off]", function(arguments)
	if not espEnabled then return false, "TURN ESP ON FIRST" end
	local requested = arguments[1] and string.lower(arguments[1]) or nil
	if requested == "on" and nametagsEnabled then return true, "NAMETAGS ARE ALREADY ON" end
	if requested == "off" and not nametagsEnabled then return true, "NAMETAGS ARE ALREADY OFF" end
	if requested and requested ~= "on" and requested ~= "off" and requested ~= "toggle" then return false, "USE ON, OFF, OR LEAVE IT BLANK TO TOGGLE" end
	setNametags(not nametagsEnabled)
	return true, "NAMETAGS " .. (nametagsEnabled and "ON" or "OFF")
end)

themeSystem.commandBar.register("speed", "/speed <number|default>", function(arguments)
	local value = string.lower(arguments[1] or "") == "default" and gameDefaults.walkSpeed or tonumber(arguments[1])
	if not value then return false, "ENTER A VALID SPEED" end
	speedBox.Text = tostring(math.max(0, value))
	applySpeed()
	return true, "SPEED SET TO " .. speedBox.Text
end)
themeSystem.commandBar.register("jump", "/jump <number|default>", function(arguments)
	local defaultJump = gameDefaults.useJumpPower and gameDefaults.jumpPower or gameDefaults.jumpHeight
	local value = string.lower(arguments[1] or "") == "default" and defaultJump or tonumber(arguments[1])
	if not value then return false, "ENTER A VALID JUMP VALUE" end
	jumpBox.Text = tostring(math.max(0, value))
	applyJump()
	return true, "JUMP SET TO " .. jumpBox.Text
end)
themeSystem.commandBar.register("gravity", "/gravity <number|default>", function(arguments)
	local value = string.lower(arguments[1] or "") == "default" and gameDefaults.gravity or tonumber(arguments[1])
	if not value then return false, "ENTER A VALID GRAVITY" end
	setGravity(value)
	return true, "GRAVITY SET TO " .. gravityLabel.Text
end)
themeSystem.commandBar.register("spin", "/spin <0-100>", function(arguments)
	local value = tonumber(arguments[1])
	if not value then return false, "ENTER A VALID SPIN SPEED" end
	spin.setValue(value)
	return true, "SPIN SET TO " .. tostring(spin.value)
end)
themeSystem.commandBar.register("smoothness", "/smoothness <1-100>", function(arguments)
	local value = tonumber(arguments[1])
	if not value then return false, "ENTER A VALID SMOOTHNESS" end
	themeSystem.aimbot.setSmoothness(value)
	return true, "AIMBOT SMOOTHNESS SET TO " .. tostring(themeSystem.aimbot.smoothness)
end)
themeSystem.commandBar.register("aimradius", "/aimradius <60-600>", function(arguments)
	local value = tonumber(arguments[1])
	if not value then return false, "ENTER A VALID AIMBOT RADIUS" end
	themeSystem.aimbot.setFovRadius(value)
	return true, "AIMBOT RADIUS SET TO " .. tostring(themeSystem.aimbot.fovRadius)
end)
themeSystem.commandBar.register("fov", "/fov <30-120|default|on|off>", function(arguments)
	local requested = string.lower(arguments[1] or "")
	if requested == "on" or requested == "off" or requested == "toggle" or requested == "" then
		local shouldToggle = requested == "" or requested == "toggle" or (requested == "on" and not fieldOfView.enabled) or (requested == "off" and fieldOfView.enabled)
		if shouldToggle then themeSystem.commandBar.runKeybind("fieldOfView") end
		return true, "FIELD OF VIEW " .. (fieldOfView.enabled and "ON" or "OFF")
	end
	local value = requested == "default" and gameDefaults.fieldOfView or tonumber(arguments[1])
	if not value then return false, "ENTER A VALID FIELD OF VIEW, ON, OR OFF" end
	fieldOfView.setValue(value)
	fieldOfView.setEnabled(true)
	return true, "FIELD OF VIEW SET TO " .. tostring(fieldOfView.value)
end)
themeSystem.commandBar.register("goto", "/goto <player>", function(arguments)
	local targetPlayer = themeSystem.commandBar.findPlayer(arguments)
	if not targetPlayer then return false, "PLAYER NOT FOUND" end
	gotoPlayer.teleportTo(targetPlayer)
	return true, "TELEPORTED TO " .. targetPlayer.Name
end)
themeSystem.commandBar.register("spectate", "/spectate <player|off>", function(arguments)
	if string.lower(arguments[1] or "") == "off" then spectate.stop() return true, "SPECTATE OFF" end
	local targetPlayer = themeSystem.commandBar.findPlayer(arguments)
	if not targetPlayer or targetPlayer == player then return false, "PLAYER NOT FOUND" end
	spectate.setTarget(targetPlayer)
	return true, "SPECTATING " .. targetPlayer.Name
end)
themeSystem.commandBar.register("leave", "/leave", function() return themeSystem.commandBar.runKeybind("leave") end)
themeSystem.commandBar.register("rejoin", "/rejoin", function() return themeSystem.commandBar.runKeybind("rejoin") end)
themeSystem.commandBar.register("serverhop", "/serverhop", function() return themeSystem.commandBar.runKeybind("serverHop") end)

function themeSystem.commandBar.execute(text)
	local cleaned = string.gsub(tostring(text or ""), "^%s*/?", "")
	cleaned = string.gsub(cleaned, "%s+$", "")
	if cleaned == "" then return end
	local pieces = string.split(cleaned, " ")
	local commandName = string.lower(table.remove(pieces, 1) or "")
	for index = #pieces, 1, -1 do if pieces[index] == "" then table.remove(pieces, index) end end
	local callback = themeSystem.commandBar.commands[commandName]
	if not callback then
		themeSystem.commandBar.setResult("UNKNOWN COMMAND: /" .. commandName .. "\nType /cmds to see every command.", false)
		return
	end
	local success, result, message = pcall(callback, pieces)
	if not success then
		themeSystem.commandBar.setResult("COMMAND FAILED: " .. tostring(result), false)
	elseif message then
		themeSystem.commandBar.setResult(message, result ~= false)
	end
end

themeSystem.commandBar.box.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	local entered = themeSystem.commandBar.box.Text
	themeSystem.commandBar.box.Text = ""
	themeSystem.commandBar.execute(entered)
	task.defer(function()
		if themeSystem.commandBar.open then themeSystem.commandBar.box:CaptureFocus() end
	end)
end)

function themeSystem.commandBar.handleTab(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		playSound(clickSound)
		themeSystem.commandBar.setOpen(not themeSystem.commandBar.open)
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority(
	"WaveCommandBarToggle",
	themeSystem.commandBar.handleTab,
	false,
	Enum.ContextActionPriority.High.Value + 1,
	Enum.KeyCode.Tab
)

themeSystem.commandBar.escapeConnection = UserInputService.InputBegan:Connect(function(input)
	if themeSystem.commandBar.open and input.KeyCode == Enum.KeyCode.Escape then
		themeSystem.commandBar.setOpen(false)
	end
end)

themeSystem.keybindSystem.inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	local listeningItem = themeSystem.keybindSystem.listening
	if listeningItem then
		if input.KeyCode == Enum.KeyCode.Escape then
			themeSystem.keybindSystem.stopListening()
		elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
			themeSystem.keybindSystem.assign(listeningItem, nil)
		elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Tab then
			listeningItem.box.Text = "RESERVED"
			task.delay(0.7, function()
				if themeSystem.keybindSystem.listening == listeningItem then
					listeningItem.box.Text = "PRESS"
				end
			end)
		elseif input.KeyCode ~= Enum.KeyCode.Unknown then
			themeSystem.keybindSystem.assign(listeningItem, input.KeyCode)
		end
		return
	end

	if gameProcessedEvent or UserInputService:GetFocusedTextBox() then
		return
	end
	local item = themeSystem.keybindSystem.byKey[input.KeyCode]
	if item and item.action then
		task.spawn(function()
			pcall(item.action)
		end)
	end
end)

function themeSystem.searchSystem.cardTab(card)
	for _, tabName in ipairs(tabNames) do
		if themeSystem.searchSystem.cardBelongs(card, tabName) then return tabName end
	end
	return nil
end

function themeSystem.searchSystem.cardBelongs(card, tabName)
	local assignedTabs = themeSystem.searchSystem.tabsByCard and themeSystem.searchSystem.tabsByCard[card]
	if assignedTabs and table.find(assignedTabs, tabName) then return true end
	local name = card.Name
	if card == creditsCard or card == changesCard or card == settings.textCard or card == settings.ctrlCard or card == settings.activeHudCard then
		return tabName == "Customize"
	end
	if name == "CustomThemeBuilder" or string.sub(name, 1, 6) == "Theme_" or name == "PresetBuilder" or string.sub(name, 1, 11) == "SavedPreset" or name == "FavoritesEmpty" or string.sub(name, 1, 13) == "FavoriteItem_" then
		return tabName == "Customize"
	end
	if name == "WaypointBuilder" or string.sub(name, 1, 14) == "SavedWaypoint_" then
		return tabName == "Movement" or tabName == "Utility"
	end
	return false
end

function themeSystem.searchSystem.updateCategoryButtons()
	for category, button in pairs(themeSystem.searchSystem.categoryButtons or {}) do
		local selected = category == themeSystem.searchSystem.selectedCategory
		button.BackgroundColor3 = selected and colors.accentSoft or colors.input
		button.TextColor3 = selected and colors.text or colors.muted
		button:SetAttribute("WaveRestingColor", button.BackgroundColor3)
	end
end

function themeSystem.searchSystem.apply()
	if not themeSystem.searchSystem.box then
		return
	end
	local query = string.lower(string.gsub(themeSystem.searchSystem.box.Text or "", "^%s*(.-)%s*$", "%1"))
	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("Frame") then
			local cardTab = themeSystem.searchSystem.cardTab(child)
			if cardTab then
				local visible = themeSystem.searchSystem.cardBelongs(child, activeTabName)
				if visible and query ~= "" then
					local heading = child:FindFirstChild("CardHeading")
					local description = child:FindFirstChild("CardDescription")
					local searchableText = string.lower(
						(heading and heading.Text or child.Name)
							.. " "
							.. (description and description.Text or "")
							.. " "
							.. (themeSystem.searchSystem.categoryByCard[child] or "")
					)
					visible = string.find(searchableText, query, 1, true) ~= nil
				end
				child.Visible = visible
			end
		end
	end
end

function themeSystem.searchSystem.updateLayout()
	if not themeSystem.searchSystem.categoryBar then
		return
	end
	themeSystem.searchSystem.categoryBar.Visible = false
	content.Position = UDim2.fromOffset(28, 140)
	content.Size = UDim2.new(1, -56, 1, -170)
end

themeSystem.searchSystem.searchFrame = Instance.new("Frame")
themeSystem.searchSystem.searchFrame.Name = "SearchFrame"
themeSystem.searchSystem.searchFrame.Position = UDim2.fromOffset(28, 96)
themeSystem.searchSystem.searchFrame.Size = UDim2.new(1, -56, 0, 34)
themeSystem.searchSystem.searchFrame.BackgroundColor3 = colors.input
themeSystem.searchSystem.searchFrame.BorderSizePixel = 0
themeSystem.searchSystem.searchFrame.Parent = main
addCorner(themeSystem.searchSystem.searchFrame, 9)
themeSystem.searchSystem.searchStroke = Instance.new("UIStroke")
themeSystem.searchSystem.searchStroke.Color = colors.border
themeSystem.searchSystem.searchStroke.Transparency = 0.52
themeSystem.searchSystem.searchStroke.Parent = themeSystem.searchSystem.searchFrame

themeSystem.searchSystem.box = Instance.new("TextBox")
themeSystem.searchSystem.box.Name = "MenuSearchBox"
themeSystem.searchSystem.box.Size = UDim2.new(1, -38, 1, 0)
themeSystem.searchSystem.box.BackgroundTransparency = 1
themeSystem.searchSystem.box.BorderSizePixel = 0
themeSystem.searchSystem.box.ClearTextOnFocus = false
themeSystem.searchSystem.box.Font = Enum.Font.GothamMedium
themeSystem.searchSystem.box.PlaceholderText = "Search this tab..."
themeSystem.searchSystem.box.PlaceholderColor3 = colors.faint
themeSystem.searchSystem.box.Text = ""
themeSystem.searchSystem.box.TextColor3 = colors.text
themeSystem.searchSystem.box.TextSize = 11
themeSystem.searchSystem.box.TextXAlignment = Enum.TextXAlignment.Left
themeSystem.searchSystem.box.Parent = themeSystem.searchSystem.searchFrame
themeSystem.searchSystem.searchPadding = Instance.new("UIPadding")
themeSystem.searchSystem.searchPadding.PaddingLeft = UDim.new(0, 12)
themeSystem.searchSystem.searchPadding.PaddingRight = UDim.new(0, 8)
themeSystem.searchSystem.searchPadding.Parent = themeSystem.searchSystem.box

themeSystem.searchSystem.clearButton = Instance.new("TextButton")
themeSystem.searchSystem.clearButton.Name = "ClearSearchButton"
themeSystem.searchSystem.clearButton.AnchorPoint = Vector2.new(1, 0.5)
themeSystem.searchSystem.clearButton.Position = UDim2.new(1, -5, 0.5, 0)
themeSystem.searchSystem.clearButton.Size = UDim2.fromOffset(28, 26)
themeSystem.searchSystem.clearButton.BackgroundTransparency = 1
themeSystem.searchSystem.clearButton.BorderSizePixel = 0
themeSystem.searchSystem.clearButton.AutoButtonColor = false
themeSystem.searchSystem.clearButton.Font = Enum.Font.GothamBold
themeSystem.searchSystem.clearButton.Text = "×"
themeSystem.searchSystem.clearButton.TextColor3 = colors.muted
themeSystem.searchSystem.clearButton.TextSize = 17
themeSystem.searchSystem.clearButton:SetAttribute("WavePolished", true)
themeSystem.searchSystem.clearButton.Parent = themeSystem.searchSystem.searchFrame

themeSystem.searchSystem.categoryBar = Instance.new("ScrollingFrame")
themeSystem.searchSystem.categoryBar.Name = "CategoryBar"
themeSystem.searchSystem.categoryBar.Position = UDim2.fromOffset(28, 136)
themeSystem.searchSystem.categoryBar.Size = UDim2.new(1, -56, 0, 28)
themeSystem.searchSystem.categoryBar.BackgroundTransparency = 1
themeSystem.searchSystem.categoryBar.BorderSizePixel = 0
themeSystem.searchSystem.categoryBar.ScrollBarThickness = 0
themeSystem.searchSystem.categoryBar.ScrollingDirection = Enum.ScrollingDirection.X
themeSystem.searchSystem.categoryBar.AutomaticCanvasSize = Enum.AutomaticSize.X
themeSystem.searchSystem.categoryBar.CanvasSize = UDim2.new(0, 0, 0, 0)
themeSystem.searchSystem.categoryBar.Parent = main
themeSystem.searchSystem.categoryLayout = Instance.new("UIListLayout")
themeSystem.searchSystem.categoryLayout.FillDirection = Enum.FillDirection.Horizontal
themeSystem.searchSystem.categoryLayout.Padding = UDim.new(0, 7)
themeSystem.searchSystem.categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
themeSystem.searchSystem.categoryLayout.Parent = themeSystem.searchSystem.categoryBar
themeSystem.searchSystem.categoryButtons = {}
themeSystem.searchSystem.categories = {"All", "Movement", "Visual", "Combat", "Teleport", "Player", "Server", "Safety"}

for index, category in ipairs(themeSystem.searchSystem.categories) do
	local button = Instance.new("TextButton")
	button.Name = "Category" .. category
	button.Size = UDim2.fromOffset(category == "Movement" and 82 or 70, 28)
	button.BackgroundColor3 = category == "All" and colors.accentSoft or colors.input
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamBold
	button.Text = string.upper(category)
	button.TextColor3 = category == "All" and colors.text or colors.muted
	button.TextSize = 8
	button.LayoutOrder = index
	button.Parent = themeSystem.searchSystem.categoryBar
	addCorner(button, 7)
	themeSystem.styleButton(button)
	themeSystem.searchSystem.categoryButtons[category] = button
	button.Activated:Connect(function()
		playSound(clickSound)
		themeSystem.searchSystem.selectedCategory = category
		themeSystem.searchSystem.updateCategoryButtons()
		content.CanvasPosition = Vector2.zero
		themeSystem.searchSystem.apply()
	end)
end

themeSystem.searchSystem.categoryByCard[themeSystem.panic.card] = "Safety"
themeSystem.searchSystem.categoryByCard[speedCard] = "Movement"
themeSystem.searchSystem.categoryByCard[jumpCard] = "Movement"
themeSystem.searchSystem.categoryByCard[gravityCard] = "Movement"
themeSystem.searchSystem.categoryByCard[utilityCard] = "Movement"
themeSystem.searchSystem.categoryByCard[flyCard] = "Movement"
themeSystem.searchSystem.categoryByCard[vehicleFlyCard] = "Movement"
themeSystem.searchSystem.categoryByCard[floatCard] = "Movement"
themeSystem.searchSystem.categoryByCard[infiniteJumpCard] = "Movement"
themeSystem.searchSystem.categoryByCard[fullBrightCard] = "Visual"
themeSystem.searchSystem.categoryByCard[freecamCard] = "Visual"
themeSystem.searchSystem.categoryByCard[zoom.card] = "Visual"
themeSystem.searchSystem.categoryByCard[espCard] = "Visual"
themeSystem.searchSystem.categoryByCard[themeSystem.aimbot.card] = "Combat"
themeSystem.searchSystem.categoryByCard[themeSystem.triggerBot.card] = "Combat"
themeSystem.searchSystem.categoryByCard[fieldOfView.card] = "Visual"
themeSystem.searchSystem.categoryByCard[invisibility.card] = "Player"
themeSystem.searchSystem.categoryByCard[walkfling.card] = "Combat"
themeSystem.searchSystem.categoryByCard[themeSystem.healthDisplay.card] = "Visual"
themeSystem.searchSystem.categoryByCard[themeSystem.waveTags.card] = "Visual"
themeSystem.searchSystem.categoryByCard[themeSystem.instantPrompts.card] = "Player"
themeSystem.searchSystem.categoryByCard[themeSystem.coordinates.card] = "Visual"
themeSystem.searchSystem.categoryByCard[themeSystem.autoSell.card] = "Teleport"
themeSystem.searchSystem.categoryByCard[themeSystem.randomize.card] = "Safety"
themeSystem.searchSystem.categoryByCard[themeSystem.playerTrails.card] = "Visual"
themeSystem.searchSystem.categoryByCard[themeSystem.playerInspector.card] = "Player"
themeSystem.searchSystem.categoryByCard[teleportClick.card] = "Teleport"
themeSystem.searchSystem.categoryByCard[gotoPlayer.card] = "Teleport"
themeSystem.searchSystem.categoryByCard[spectate.card] = "Visual"
themeSystem.searchSystem.categoryByCard[godCard] = "Player"
themeSystem.searchSystem.categoryByCard[freeze.card] = "Player"
themeSystem.searchSystem.categoryByCard[spin.card] = "Player"
themeSystem.searchSystem.categoryByCard[leave.card] = "Server"
themeSystem.searchSystem.categoryByCard[rejoin.card] = "Server"
themeSystem.searchSystem.categoryByCard[serverHop.card] = "Server"

themeSystem.searchSystem.tabsByCard = {
	[themeSystem.panic.card] = {"Combat", "Utility"},
	[speedCard] = {"Movement"}, [jumpCard] = {"Movement"}, [gravityCard] = {"Movement"},
	[utilityCard] = {"Movement"}, [flyCard] = {"Movement"}, [vehicleFlyCard] = {"Movement"},
	[floatCard] = {"Movement"}, [infiniteJumpCard] = {"Movement"},
	[fullBrightCard] = {"Visuals"}, [freecamCard] = {"Visuals"}, [zoom.card] = {"Movement", "Visuals"},
	[teleportClick.card] = {"Movement", "Utility"}, [gotoPlayer.card] = {"Movement", "Utility"},
	[spectate.card] = {"Visuals", "Utility"}, [godCard] = {"Combat"}, [freeze.card] = {"Movement", "Combat"},
	[spin.card] = {"Combat"}, [espCard] = {"Visuals", "Combat"}, [themeSystem.aimbot.card] = {"Combat"},
	[themeSystem.triggerBot.card] = {"Combat"}, [fieldOfView.card] = {"Visuals"},
	[invisibility.card] = {"Combat"}, [walkfling.card] = {"Combat"},
	[themeSystem.healthDisplay.card] = {"Visuals", "Combat"}, [themeSystem.waveTags.card] = {"Visuals"},
	[themeSystem.instantPrompts.card] = {"Utility"}, [themeSystem.coordinates.card] = {"Visuals", "Utility"},
	[themeSystem.autoSell.card] = {"Utility"}, [themeSystem.randomize.card] = {"Utility"},
	[themeSystem.playerTrails.card] = {"Visuals"}, [themeSystem.playerInspector.card] = {"Combat", "Utility"},
	[leave.card] = {"Utility"}, [rejoin.card] = {"Utility"}, [serverHop.card] = {"Utility"},
}

themeSystem.searchSystem.box:GetPropertyChangedSignal("Text"):Connect(function()
	content.CanvasPosition = Vector2.zero
	themeSystem.searchSystem.apply()
end)
themeSystem.searchSystem.box.Focused:Connect(function()
	TweenService:Create(themeSystem.searchSystem.searchStroke, TweenInfo.new(0.14), {Transparency = 0.08, Color = colors.accent}):Play()
end)
themeSystem.searchSystem.box.FocusLost:Connect(function()
	TweenService:Create(themeSystem.searchSystem.searchStroke, TweenInfo.new(0.14), {Transparency = 0.52, Color = colors.border}):Play()
end)
themeSystem.searchSystem.clearButton.Activated:Connect(function()
	playSound(clickSound)
	themeSystem.searchSystem.box.Text = ""
	themeSystem.searchSystem.box:ReleaseFocus()
end)
themeSystem.searchSystem.childConnection = content.ChildAdded:Connect(function(child)
	if child:IsA("Frame") then
		task.defer(themeSystem.searchSystem.apply)
	end
end)
themeSystem.searchSystem.updateCategoryButtons()
themeSystem.searchSystem.updateLayout()

ContextActionService:BindActionAtPriority(
	"WaveAdminMenuToggle",
	handleMenuToggle,
	false,
	Enum.ContextActionPriority.High.Value,
	Enum.KeyCode.LeftControl
)

function activeHud.setEnabled(enabled)
	activeHud.enabled = enabled == true
	activeHud.gui.Enabled = activeHud.enabled
	setSimpleSwitchVisual(
		switchUI.activeHud[1],
		switchUI.activeHud[2],
		switchUI.activeHud[3],
		activeHud.enabled
	)
end

switchUI.activeHud[1].Activated:Connect(function()
	playSound(clickSound)
	activeHud.setEnabled(not activeHud.enabled)
end)

function activeHud.collect()
	local enabled = {}
	local function add(name)
		table.insert(enabled, name)
	end
	if noclipEnabled then add("NOCLIP") end
	if flyEnabled then add("FLY") end
	if godModeEnabled then add("GOD MODE") end
	if vehicleFlyEnabled then add("VEHICLE FLY") end
	if fullBrightEnabled then add("FULL BRIGHT") end
	if freecamState.enabled then add("FREECAM") end
	if zoom.enabled then add("ZOOM") end
	if teleportClick.enabled then add("CLICK TELEPORT") end
	if freeze.enabled then add("FREEZE") end
	if spin.value ~= 0 then add("SPIN  [" .. tostring(spin.value) .. "]") end
	if spin.antiflingEnabled then add("ANTIFLING") end
	if floatEnabled then add("FLOAT") end
	if infiniteJumpEnabled then add("INFINITE JUMP") end
	if espEnabled then add("ESP") end
	if nametagsEnabled then add("NAMETAGS") end
	if themeSystem.aimbot.enabled then add("AIMBOT") end
	if themeSystem.aimbot.fovCircleEnabled then
		add("AIMBOT RADIUS  [" .. tostring(themeSystem.aimbot.fovRadius) .. " PX]")
	end
	if themeSystem.triggerBot.enabled then add("TRIGGER BOT") end
	if fieldOfView.enabled then add("FIELD OF VIEW  [" .. tostring(fieldOfView.value) .. "°]") end
	if invisibility.enabled then add("INVISIBILITY") end
	if walkfling.enabled then add("WALKFLING") end
	if themeSystem.healthDisplay.enabled then add("HEALTH DISPLAY") end
	if themeSystem.waveTags.enabled then add("WAVE TAGS") end
	if themeSystem.instantPrompts.enabled then add("INSTANT PROMPTS") end
	if themeSystem.coordinates.enabled then add("COORDINATES") end
	if themeSystem.autoSell.enabled then add(string.format("AUTO SELL  [%.1fs]", themeSystem.autoSell.interval)) end
	if themeSystem.playerTrails.enabled then add("PLAYER TRAILS") end
	if spectate.target then add("SPECTATE  [" .. spectate.target.Name .. "]") end
	return enabled
end

function activeHud.update()
	local enabled = activeHud.collect()
	local hasEnabled = #enabled > 0
	local listHeight = hasEnabled and (#enabled * 15) or 14
	local nextText = hasEnabled and table.concat(enabled, "\n") or "NONE ENABLED"
	local changed = activeHud.list.Text ~= nextText
	activeHud.list.Text = nextText
	activeHud.list.TextColor3 = hasEnabled and colors.text or colors.muted
	activeHud.list.Size = UDim2.new(1, -24, 0, listHeight)
	local targetSize = UDim2.fromOffset(190, 39 + listHeight)
	if changed then
		TweenService:Create(activeHud.panel, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize, BackgroundTransparency = 0.1}):Play()
		activeHud.accent.BackgroundTransparency = 0
		TweenService:Create(activeHud.accent, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.18}):Play()
	else
		activeHud.panel.Size = targetSize
	end
	activeHud.panel.BackgroundColor3 = colors.panel
	activeHud.stroke.Color = colors.border
	activeHud.accent.BackgroundColor3 = colors.accent
	activeHud.header.TextColor3 = colors.text
end

task.spawn(function()
	while activeHud.gui.Parent do
		activeHud.update()
		task.wait(0.15)
	end
end)

local function polishButton(button)
	if button:GetAttribute("WavePolished") then
		return
	end
	button:SetAttribute("WavePolished", true)

	if string.find(button.Name, "Tab$") then
		return
	end

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = colors.border
	buttonStroke.Transparency = 0.62
	buttonStroke.Thickness = 1
	buttonStroke.Parent = button

	if string.find(button.Name, "Toggle") then
		local toggleKnob = button:FindFirstChild("Knob")
		if toggleKnob and toggleKnob:IsA("GuiObject") then
			local knobGradient = Instance.new("UIGradient")
			knobGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 204, 232))
			knobGradient.Rotation = 90
			knobGradient.Parent = toggleKnob
			local knobStroke = Instance.new("UIStroke")
			knobStroke.Color = Color3.fromRGB(255, 255, 255)
			knobStroke.Transparency = 0.58
			knobStroke.Parent = toggleKnob
		end
		button.MouseEnter:Connect(function()
			TweenService:Create(buttonStroke, TweenInfo.new(0.14), {Transparency = 0.18, Color = colors.accent2}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(buttonStroke, TweenInfo.new(0.14), {Transparency = 0.62, Color = colors.border}):Play()
		end)
		return
	end

	button:SetAttribute("WaveRestingColor", button.BackgroundColor3)
	button.MouseEnter:Connect(function()
		local restingColor = button:GetAttribute("WaveRestingColor") or button.BackgroundColor3
		TweenService:Create(button, TweenInfo.new(0.14), {BackgroundColor3 = restingColor:Lerp(Color3.new(1, 1, 1), 0.12)}):Play()
		TweenService:Create(buttonStroke, TweenInfo.new(0.14), {Transparency = 0.2, Color = colors.accent2}):Play()
	end)
	button.MouseLeave:Connect(function()
		local restingColor = button:GetAttribute("WaveRestingColor") or button.BackgroundColor3
		TweenService:Create(button, TweenInfo.new(0.14), {BackgroundColor3 = restingColor}):Play()
		TweenService:Create(buttonStroke, TweenInfo.new(0.14), {Transparency = 0.62, Color = colors.border}):Play()
	end)
end

function themeSystem.enhanceButton(button)
	if button:GetAttribute("WavePremiumMotion") then return end
	button:SetAttribute("WavePremiumMotion", true)
	local buttonScale = button:FindFirstChildOfClass("UIScale")
	if not buttonScale then
		buttonScale = Instance.new("UIScale")
		buttonScale.Scale = 1
		buttonScale.Parent = button
	end
	button.MouseEnter:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1.025}):Play()
		local now = os.clock()
		if now - (themeSystem.lastHoverSound or 0) > 0.045 then
			themeSystem.lastHoverSound = now
			playSound(hoverSound)
		end
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.955}):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.025}):Play()
	end)
	button.Activated:Connect(function()
		local pulse = Instance.new("UIStroke")
		pulse.Name = "ActivationPulse"
		pulse.Color = colors.accent2
		pulse.Transparency = 0.08
		pulse.Thickness = 1.5
		pulse.Parent = button
		local pulseTween = TweenService:Create(pulse, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 1, Thickness = 5})
		pulseTween:Play()
		pulseTween.Completed:Once(function() pulse:Destroy() end)
		TweenService:Create(buttonScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
end

function themeSystem.animateVisibleCards()
	local order = 0
	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("Frame") and child.Visible and child.LayoutOrder >= 0 then
			order += 1
			local cardScale = child:FindFirstChild("WaveEntranceScale")
			if not cardScale then
				cardScale = Instance.new("UIScale")
				cardScale.Name = "WaveEntranceScale"
				cardScale.Parent = child
			end
			cardScale.Scale = 0.965
			task.delay(math.min((order - 1) * 0.018, 0.16), function()
				if child.Parent and child.Visible then
					TweenService:Create(cardScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
				end
			end)
		end
	end
end

for _, descendant in ipairs(screenGui:GetDescendants()) do
	if descendant:IsA("TextButton") then
		polishButton(descendant)
		themeSystem.enhanceButton(descendant)
	end
end
showTab("Home")
setNoclipVisual(false)
setGodModeVisual(false)
setSimpleSwitchVisual(switchUI.fullBright[1], switchUI.fullBright[2], switchUI.fullBright[3], false)
setSimpleSwitchVisual(freecamUI[1], freecamUI[2], freecamUI[3], false)
setSimpleSwitchVisual(switchUI.zoom[1], switchUI.zoom[2], switchUI.zoom[3], false)
setSimpleSwitchVisual(switchUI.teleportClick[1], switchUI.teleportClick[2], switchUI.teleportClick[3], false)
gotoPlayer.setOpen(false)
spectate.setOpen(false)
setSimpleSwitchVisual(switchUI.freeze[1], switchUI.freeze[2], switchUI.freeze[3], false)
spin.setValue(0)
spin.setDropdownOpen(false)
spin.updateAntiflingVisual()
setSimpleSwitchVisual(switchUI.vehicleFly[1], switchUI.vehicleFly[2], switchUI.vehicleFly[3], false)
setSimpleSwitchVisual(switchUI.float[1], switchUI.float[2], switchUI.float[3], false)
setSimpleSwitchVisual(switchUI.infiniteJump[1], switchUI.infiniteJump[2], switchUI.infiniteJump[3], false)
setSimpleSwitchVisual(switchUI.esp[1], switchUI.esp[2], switchUI.esp[3], false)
setSimpleSwitchVisual(switchUI.aimbot[1], switchUI.aimbot[2], switchUI.aimbot[3], false)
setSimpleSwitchVisual(switchUI.triggerBot[1], switchUI.triggerBot[2], switchUI.triggerBot[3], false)
setSimpleSwitchVisual(switchUI.fieldOfView[1], switchUI.fieldOfView[2], switchUI.fieldOfView[3], false)
setSimpleSwitchVisual(switchUI.invisibility[1], switchUI.invisibility[2], switchUI.invisibility[3], false)
setSimpleSwitchVisual(switchUI.walkfling[1], switchUI.walkfling[2], switchUI.walkfling[3], false)
setSimpleSwitchVisual(switchUI.healthDisplay[1], switchUI.healthDisplay[2], switchUI.healthDisplay[3], false)
setSimpleSwitchVisual(switchUI.waveTags[1], switchUI.waveTags[2], switchUI.waveTags[3], false)
setSimpleSwitchVisual(switchUI.instantPrompts[1], switchUI.instantPrompts[2], switchUI.instantPrompts[3], false)
setSimpleSwitchVisual(switchUI.coordinates[1], switchUI.coordinates[2], switchUI.coordinates[3], false)
setSimpleSwitchVisual(switchUI.autoSell[1], switchUI.autoSell[2], switchUI.autoSell[3], false)
setSimpleSwitchVisual(switchUI.playerTrails[1], switchUI.playerTrails[2], switchUI.playerTrails[3], false)
themeSystem.autoSell.updateLocationText()
activeHud.setEnabled(true)
setESPDropdownOpen(false)
setNametagSwitchVisual()
print("[WaveAdminMenu] Polished menu created")
setOpen(false)
