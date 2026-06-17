local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ==========================================
-- 1. DATA & ANTI-LAG CACHE
-- ==========================================
local fruitsData = {} 
local knownFruitsFolders = {}
local targetCFrame = nil
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

-- Set Location Button
local SetLocBtn = Instance.new("TextButton")
SetLocBtn.Size = UDim2.new(0.9, 0, 0, 35)
SetLocBtn.Position = UDim2.new(0.05, 0, 0, 55)
SetLocBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
SetLocBtn.Text = "Set TP Location"
SetLocBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetLocBtn.Font = Enum.Font.GothamBold
SetLocBtn.TextSize = 14
SetLocBtn.Parent = MainFrame
Instance.new("UICorner", SetLocBtn).CornerRadius = UDim.new(0, 6)

-- Coordinate Box (Uneditable)
local CoordBox = Instance.new("TextBox")
CoordBox.Size = UDim2.new(0.9, 0, 0, 35)
CoordBox.Position = UDim2.new(0.05, 0, 0, 100)
CoordBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CoordBox.TextEditable = false
CoordBox.ClearTextOnFocus = false
CoordBox.Text = "Location Not Set"
CoordBox.TextColor3 = Color3.fromRGB(180, 180, 180)
CoordBox.Font = Enum.Font.Gotham
CoordBox.TextSize = 13
CoordBox.Parent = MainFrame
Instance.new("UICorner", CoordBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", CoordBox).Color = Color3.fromRGB(40, 40, 50)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 175)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleBtn.Text = "START AUTO-TP"
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
addHoverEffect(SetLocBtn, Color3.fromRGB(88, 101, 242), Color3.fromRGB(100, 115, 255))
addHoverEffect(ToggleBtn, Color3.fromRGB(40, 40, 50), Color3.fromRGB(60, 60, 75))
addHoverEffect(CloseBtn, Color3.fromRGB(220, 50, 50), Color3.fromRGB(255, 75, 75))

-- ==========================================
-- 3. LOGIC & TELEPORTATION
-- ==========================================

-- Function: Quick scan of ONLY the active Fruits folders (No Lag!)
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
local function moveFruits(destinationCFrame, useOriginal)
	for _, data in ipairs(fruitsData) do
		if data.Item and data.Item:IsDescendantOf(workspace) then
			local dest = useOriginal and data.OriginalCFrame or destinationCFrame
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

-- Button: Set Location
SetLocBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		targetCFrame = char.HumanoidRootPart.CFrame
		CoordBox.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", targetCFrame.X, targetCFrame.Y, targetCFrame.Z)
	end
end)

-- Button: Toggle ON/OFF
ToggleBtn.MouseButton1Click:Connect(function()
	if not targetCFrame then
		CoordBox.Text = "PLEASE SET A LOCATION FIRST!"
		task.wait(1.5)
		CoordBox.Text = "Location Not Set"
		return
	end

	isToggled = not isToggled

	if isToggled then
		StatusLight.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- Green
		ToggleBtn.Text = "STOP AUTO-TP"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	else
		StatusLight.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Red
		ToggleBtn.Text = "START AUTO-TP"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		
		-- Return everything to original positions when turned off
		moveFruits(nil, true) 
	end
end)

-- Button: Close GUI (X Button)
CloseBtn.MouseButton1Click:Connect(function()
	isToggled = false
	moveFruits(nil, true) -- Send fruits back so game isn't broken for you
	ScreenGui:Destroy()   -- Completely removes the GUI
end)

-- Background 1-Second Loop
task.spawn(function()
	while true do
		-- If GUI was destroyed, break the loop to save performance
		if not ScreenGui.Parent then break end 
		
		if isToggled and targetCFrame then
			fastRescanFruits()
			moveFruits(targetCFrame, false)
		end
		task.wait(1)
	end
end)
