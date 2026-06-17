local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ==========================================
-- 1. DATA & ANTI-LAG CACHE
-- ==========================================
local fruitsData = {} 
local knownFruitsFolders = {}
local ignoredPlot = nil
local isToggled = false
local skyTpDistance = 100 -- Default distance

-- Find existing Fruits folders
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("Folder") and obj.Name == "Fruits" then
		knownFruitsFolders[obj] = true
	end
end

-- Catch new Fruits folders dynamically
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Folder") and obj.Name == "Fruits" then
		knownFruitsFolders[obj] = true
	end
end)

-- ==========================================
-- 2. PREMIUM UI CREATION (100x Better UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowAGardenHackV3"
ScreenGui.ResetOnSpawn = false

-- Use CoreGui if exploiting, otherwise PlayerGui
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 320)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(70, 70, 90)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 30)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "🌱 Grow a Garden 2 Hack"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Credit Label
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, -40, 0, 15)
Credit.Position = UDim2.new(0, 20, 0, 32)
Credit.BackgroundTransparency = 1
Credit.Text = "made by leo1333877"
Credit.TextColor3 = Color3.fromRGB(150, 150, 170)
Credit.TextSize = 12
Credit.Font = Enum.Font.GothamMedium
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.Parent = MainFrame

-- Status Light
local StatusLight = Instance.new("Frame")
StatusLight.Size = UDim2.new(0, 14, 0, 14)
StatusLight.Position = UDim2.new(1, -5, 0.5, -2)
StatusLight.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
StatusLight.Parent = Title
Instance.new("UICorner", StatusLight).CornerRadius = UDim.new(1, 0)

-- Close (X) Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0, 15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Base Scan Button
local ScanBaseBtn = Instance.new("TextButton")
ScanBaseBtn.Size = UDim2.new(0.9, 0, 0, 38)
ScanBaseBtn.Position = UDim2.new(0.05, 0, 0, 65)
ScanBaseBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
ScanBaseBtn.Text = "🔍 Scan My Base (Stand in it)"
ScanBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBaseBtn.Font = Enum.Font.GothamBold
ScanBaseBtn.TextSize = 14
ScanBaseBtn.Parent = MainFrame
Instance.new("UICorner", ScanBaseBtn).CornerRadius = UDim.new(0, 8)

-- TP Back To Base Button
local TPBaseBtn = Instance.new("TextButton")
TPBaseBtn.Size = UDim2.new(0.9, 0, 0, 38)
TPBaseBtn.Position = UDim2.new(0.05, 0, 0, 110)
TPBaseBtn.BackgroundColor3 = Color3.fromRGB(50, 168, 82)
TPBaseBtn.Text = "🏠 TP Back To My Base"
TPBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBaseBtn.Font = Enum.Font.GothamBold
TPBaseBtn.TextSize = 14
TPBaseBtn.Parent = MainFrame
Instance.new("UICorner", TPBaseBtn).CornerRadius = UDim.new(0, 8)

-- Custom Distance Text Box (Editable)
local DistanceBox = Instance.new("TextBox")
DistanceBox.Size = UDim2.new(0.9, 0, 0, 35)
DistanceBox.Position = UDim2.new(0.05, 0, 0, 155)
DistanceBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
DistanceBox.TextEditable = true
DistanceBox.ClearTextOnFocus = false
DistanceBox.PlaceholderText = "Enter Height (Studs)"
DistanceBox.Text = tostring(skyTpDistance)
DistanceBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceBox.Font = Enum.Font.GothamBold
DistanceBox.TextSize = 13
DistanceBox.Parent = MainFrame
Instance.new("UICorner", DistanceBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", DistanceBox).Color = Color3.fromRGB(88, 101, 242)

-- Label inside DistanceBox for context
local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0.4, 0, 1, 0)
DistLabel.Position = UDim2.new(0, 10, 0, 0)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "TP Height:"
DistLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DistLabel.Font = Enum.Font.GothamMedium
DistLabel.TextSize = 13
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = DistanceBox

-- Push the actual input text to the right
DistanceBox.TextXAlignment = Enum.TextXAlignment.Right
local Padding = Instance.new("UIPadding", DistanceBox)
Padding.PaddingRight = UDim.new(0, 15)

-- Info Box
local InfoBox = Instance.new("TextBox")
InfoBox.Size = UDim2.new(0.9, 0, 0, 35)
InfoBox.Position = UDim2.new(0.05, 0, 0, 197)
InfoBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
InfoBox.TextEditable = false
InfoBox.ClearTextOnFocus = false
InfoBox.Text = "Status: Base Not Scanned"
InfoBox.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoBox.Font = Enum.Font.GothamMedium
InfoBox.TextSize = 13
InfoBox.Parent = MainFrame
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", InfoBox).Color = Color3.fromRGB(50, 50, 65)

-- Toggle Sky-TP Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 250)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleBtn.Text = "START SKY-TP (" .. skyTpDistance .. " STUDS)"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 15
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- UI Dragging Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Premium Button Animations (Hover & Click)
local function applyPremiumAnimations(btn, baseColor, hoverColor)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = baseColor}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 4, btn.Size.Y.Scale, btn.Size.Y.Offset - 2)}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 4, btn.Size.Y.Scale, btn.Size.Y.Offset + 2)}):Play()
	end)
end

applyPremiumAnimations(ScanBaseBtn, Color3.fromRGB(88, 101, 242), Color3.fromRGB(105, 118, 255))
applyPremiumAnimations(TPBaseBtn, Color3.fromRGB(50, 168, 82), Color3.fromRGB(65, 190, 100))
applyPremiumAnimations(ToggleBtn, Color3.fromRGB(40, 40, 50), Color3.fromRGB(60, 60, 75))
applyPremiumAnimations(CloseBtn, Color3.fromRGB(220, 50, 50), Color3.fromRGB(255, 70, 70))

-- ==========================================
-- 3. LOGIC & TELEPORTATION
-- ==========================================

-- Handle Distance Updates safely
DistanceBox.FocusLost:Connect(function()
	local newDist = tonumber(DistanceBox.Text)
	if newDist then
		skyTpDistance = newDist
		if not isToggled then
			ToggleBtn.Text = "START SKY-TP (" .. skyTpDistance .. " STUDS)"
		end
	else
		-- If they typed letters by mistake, revert to the last valid number
		DistanceBox.Text = tostring(skyTpDistance)
	end
end)

-- Function: Get Plot Center
local function getPlotPosition(plot)
	if plot:IsA("Model") and plot.PrimaryPart then
		return plot.PrimaryPart.Position
	elseif plot:IsA("Model") then
		return plot:GetPivot().Position
	else
		local part = plot:FindFirstChildWhichIsA("BasePart", true)
		if part then return part.Position end
	end
	return nil
end

-- Function: Quick scan active Fruits folders
local function fastRescanFruits()
	local knownItems = {}
	for _, data in ipairs(fruitsData) do
		if data.Item and data.Item.Parent then knownItems[data.Item] = true end
	end

	for folder, _ in pairs(knownFruitsFolders) do
		if folder and folder.Parent then
			for _, item in pairs(folder:GetDescendants()) do
				if not knownItems[item] then
					if item:IsA("Model") then
						table.insert(fruitsData, { Item = item, Type = "Model", OriginalCFrame = item:GetPivot() })
						knownItems[item] = true
					elseif item:IsA("Tool") and item:FindFirstChild("Handle") then
						table.insert(fruitsData, { Item = item, Type = "Tool", OriginalCFrame = item.Handle.CFrame })
						knownItems[item] = true
					elseif item:IsA("BasePart") and not item:FindFirstAncestorOfClass("Model") and not item:FindFirstAncestorOfClass("Tool") then
						table.insert(fruitsData, { Item = item, Type = "BasePart", OriginalCFrame = item.CFrame })
						knownItems[item] = true
					end
				end
			end
		else
			knownFruitsFolders[folder] = nil
		end
	end
end

-- Function: Move Fruits
local function moveFruits(isActive)
	for _, data in ipairs(fruitsData) do
		if data.Item and data.Item:IsDescendantOf(workspace) then
			-- IGNORE FRUITS IN SCANNED PLOT
			if ignoredPlot and data.Item:IsDescendantOf(ignoredPlot) then continue end

			-- Teleport UP based on custom text box distance
			local dest = data.OriginalCFrame
			if isActive then dest = dest + Vector3.new(0, skyTpDistance, 0) end

			if dest then
				if data.Type == "Model" then
					data.Item:PivotTo(dest)
				elseif data.Type == "Tool" and data.Item:FindFirstChild("Handle") then
					data.Item.Handle.CFrame = dest
				elseif data.Type == "BasePart" then
					data.Item.CFrame = dest
				end
			end
		end
	end
end

-- Button: Scan Base
ScanBaseBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local myPos = char.HumanoidRootPart.Position
	local gardens = workspace:FindFirstChild("Gardens")
	
	if not gardens then InfoBox.Text = "Error: Gardens folder not found!"; return end
	
	local closestPlot, closestDistance = nil, math.huge
	for _, plot in pairs(gardens:GetChildren()) do
		if string.match(plot.Name, "Plot") then
			local plotPos = getPlotPosition(plot)
			if plotPos then
				local dist = (myPos - plotPos).Magnitude
				if dist < closestDistance then closestDistance = dist; closestPlot = plot end
			end
		end
	end
	
	if closestPlot then
		ignoredPlot = closestPlot
		InfoBox.Text = "Saved Base: " .. closestPlot.Name
	else
		InfoBox.Text = "No plot found near you"
	end
end)

-- Button: TP Back to Base
TPBaseBtn.MouseButton1Click:Connect(function()
	if not ignoredPlot then
		InfoBox.Text = "PLEASE SCAN BASE FIRST!"
		task.wait(1.5)
		InfoBox.Text = "Status: Base Not Scanned"
		return
	end

	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		local plotPos = getPlotPosition(ignoredPlot)
		if plotPos then
			-- Teleport player slightly above the base center
			char:PivotTo(CFrame.new(plotPos + Vector3.new(0, 8, 0)))
		end
	end
end)

-- Button: Toggle ON/OFF
ToggleBtn.MouseButton1Click:Connect(function()
	if not ignoredPlot then
		InfoBox.Text = "PLEASE SCAN BASE FIRST!"
		task.wait(1.5)
		InfoBox.Text = "Status: Base Not Scanned"
		return
	end

	isToggled = not isToggled

	if isToggled then
		StatusLight.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
		ToggleBtn.Text = "STOP SKY-TP"
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
	else
		StatusLight.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		ToggleBtn.Text = "START SKY-TP (" .. skyTpDistance .. " STUDS)"
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
		moveFruits(false) 
	end
end)

-- Button: Close GUI (X Button)
CloseBtn.MouseButton1Click:Connect(function()
	isToggled = false
	moveFruits(false)
	ScreenGui:Destroy()
end)

-- Background Loop
task.spawn(function()
	while true do
		if not ScreenGui.Parent then break end 
		if isToggled and ignoredPlot then
			fastRescanFruits()
			moveFruits(true)
		end
		task.wait(1)
	end
end)
