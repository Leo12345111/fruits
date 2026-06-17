local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ==========================================
-- 1. DATA & ANTI-LAG CACHE
-- ==========================================
local fruitsData = {} 
local knownFruitsFolders = {}
local ignoredPlot = nil
local isToggled = false

-- Find existing Fruits folders
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("Folder") and obj.Name == "Fruits" then
		knownFruitsFolders[obj] = true
	end
end

-- Catch new Fruits folders dynamically (Prevents needing to scan workspace every 1s)
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Folder") and obj.Name == "Fruits" then
		knownFruitsFolders[obj] = true
	end
end)

-- ==========================================
-- 2. UI CREATION (100x Good UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowAGardenHack"
ScreenGui.ResetOnSpawn = false

-- Use CoreGui if exploiting, otherwise PlayerGui
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 75)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "🌱 Grow a Garden 2 hack"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Credit Label
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, -40, 0, 15)
Credit.Position = UDim2.new(0, 15, 0, 30)
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
StatusLight.Position = UDim2.new(1, -15, 0.5, 0)
StatusLight.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Red initially
StatusLight.Parent = Title

local LightCorner = Instance.new("UICorner")
LightCorner.CornerRadius = UDim.new(1, 0)
LightCorner.Parent = StatusLight

-- Close (X) Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Scan Base Button
local ScanBaseBtn = Instance.new("TextButton")
ScanBaseBtn.Size = UDim2.new(0.9, 0, 0, 35)
ScanBaseBtn.Position = UDim2.new(0.05, 0, 0, 55)
ScanBaseBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
ScanBaseBtn.Text = "Scan My Base (Stand in it)"
ScanBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBaseBtn.Font = Enum.Font.GothamBold
ScanBaseBtn.TextSize = 14
ScanBaseBtn.Parent = MainFrame
Instance.new("UICorner", ScanBaseBtn).CornerRadius = UDim.new(0, 6)

-- Info Box (Uneditable)
local InfoBox = Instance.new("TextBox")
InfoBox.Size = UDim2.new(0.9, 0, 0, 35)
InfoBox.Position = UDim2.new(0.05, 0, 0, 100)
InfoBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
InfoBox.TextEditable = false
InfoBox.ClearTextOnFocus = false
InfoBox.Text = "Base Not Scanned"
InfoBox.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoBox.Font = Enum.Font.Gotham
InfoBox.TextSize = 13
InfoBox.Parent = MainFrame
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", InfoBox).Color = Color3.fromRGB(40, 40, 50)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 175)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleBtn.Text = "START SKY-TP"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- UI Dragging Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
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
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Button Hover Effects
local function addHoverEffect(btn, originalColor, hoverColor)
	btn.MouseEnter:Connect(function() game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() end)
	btn.MouseLeave:Connect(function() game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play() end)
end
addHoverEffect(ScanBaseBtn, Color3.fromRGB(88, 101, 242), Color3.fromRGB(100, 115, 255))
addHoverEffect(ToggleBtn, Color3.fromRGB(40, 40, 50), Color3.fromRGB(60, 60, 75))
addHoverEffect(CloseBtn, Color3.fromRGB(220, 50, 50), Color3.fromRGB(255, 75, 75))

-- ==========================================
-- 3. LOGIC & TELEPORTATION
-- ==========================================

-- Function: Get the center location of a Plot folder/model
local function getPlotPosition(plot)
	if plot:IsA("Model") and plot.PrimaryPart then
		return plot.PrimaryPart.Position
	elseif plot:IsA("Model") then
		return plot:GetPivot().Position
	else
		-- If it's a folder, find any BasePart inside to get a position
		local part = plot:FindFirstChildWhichIsA("BasePart", true)
		if part then return part.Position end
	end
	return nil
end

-- Function: Quick scan of active Fruits folders (No Lag!)
local function fastRescanFruits()
	local knownItems = {}
	for _, data in ipairs(fruitsData) do
		if data.Item and data.Item.Parent then
			knownItems[data.Item] = true
		end
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
			
			-- COMPLETELY IGNORE FRUITS IN YOUR OWN SCANNED PLOT
			if ignoredPlot and data.Item:IsDescendantOf(ignoredPlot) then
				continue
			end

			-- Teleport 100 studs UP from original location if active, else return to original
			local dest = data.OriginalCFrame
			if isActive then
				dest = dest + Vector3.new(0, 250, 0)
			end

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
	
	if not gardens then
		InfoBox.Text = "Error: Gardens folder not found!"
		return
	end
	
	local closestPlot = nil
	local closestDistance = math.huge
	
	-- Loop through all Plots to find the nearest one
	for _, plot in pairs(gardens:GetChildren()) do
		if string.match(plot.Name, "Plot") then
			local plotPos = getPlotPosition(plot)
			if plotPos then
				local dist = (myPos - plotPos).Magnitude
				if dist < closestDistance then
					closestDistance = dist
					closestPlot = plot
				end
			end
		end
	end
	
	if closestPlot then
		ignoredPlot = closestPlot
		InfoBox.Text = "Ignored: " .. closestPlot.Name
	else
		InfoBox.Text = "No plot found near you"
	end
end)

-- Button: Toggle ON/OFF
ToggleBtn.MouseButton1Click:Connect(function()
	if not ignoredPlot then
		InfoBox.Text = "PLEASE SCAN BASE FIRST!"
		task.wait(1.5)
		InfoBox.Text = "Base Not Scanned"
		return
	end

	isToggled = not isToggled

	if isToggled then
		StatusLight.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- Green
		ToggleBtn.Text = "STOP SKY-TP"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	else
		StatusLight.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Red
		ToggleBtn.Text = "START SKY-TP"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		
		-- Return everything to original positions when turned off
		moveFruits(false) 
	end
end)

-- Button: Close GUI (X Button)
CloseBtn.MouseButton1Click:Connect(function()
	isToggled = false
	moveFruits(false) -- Send fruits back so game isn't broken for others
	ScreenGui:Destroy() -- Removes the GUI
end)

-- Background 1-Second Loop
task.spawn(function()
	while true do
		-- If GUI was destroyed, break the loop to save performance
		if not ScreenGui.Parent then break end 
		
		if isToggled and ignoredPlot then
			fastRescanFruits()
			moveFruits(true)
		end
		task.wait(1)
	end
end)
