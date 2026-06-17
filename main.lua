local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create a table to remember the original locations of all items
local fruitsData = {}

print("Scanning for Fruits folders...")

-- Step 1: Scan for all items and save their ORIGINAL positions
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("Folder") and obj.Name == "Fruits" then
		
		for _, item in pairs(obj:GetDescendants()) do
			if item:IsA("Model") then
				table.insert(fruitsData, {
					Item = item,
					Type = "Model",
					OriginalCFrame = item:GetPivot() -- Gets the original position of the whole model
				})
				
			elseif item:IsA("Tool") and item:FindFirstChild("Handle") then
				table.insert(fruitsData, {
					Item = item,
					Type = "Tool",
					OriginalCFrame = item.Handle.CFrame
				})
				
			elseif item:IsA("BasePart") then
				if not item:FindFirstAncestorOfClass("Model") and not item:FindFirstAncestorOfClass("Tool") then
					table.insert(fruitsData, {
						Item = item,
						Type = "BasePart",
						OriginalCFrame = item.CFrame
					})
				end
			end
		end
	end
end

if #fruitsData == 0 then
	warn("Could not find any fruits to teleport!")
	return
end

print("Found " .. #fruitsData .. " fruit items! Starting the 5-second teleport loop...")

-- Step 2: Create a function to teleport all saved items
local function teleportFruits(targetCFrame, useOriginal)
	for _, data in ipairs(fruitsData) do
		-- Make sure the item hasn't been destroyed or picked up by someone else
		if data.Item and data.Item:IsDescendantOf(workspace) then
			
			-- Determine where it's going (Original spot OR the Player's spot)
			local destination = useOriginal and data.OriginalCFrame or targetCFrame
			
			if data.Type == "Model" then
				data.Item:PivotTo(destination)
			elseif data.Type == "Tool" and data.Item:FindFirstChild("Handle") then
				data.Item.Handle.CFrame = destination
			elseif data.Type == "BasePart" then
				data.Item.CFrame = destination
			end
		end
	end
end

-- Step 3: Start the infinite teleporting loop in the background
task.spawn(function()
	while true do
		-- Get the player's CURRENT location (updated in case you moved)
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local myLocation = character.HumanoidRootPart.CFrame
			
			-- Bring to player
			teleportFruits(myLocation, false)
		end
		
		-- Wait 5 seconds
		task.wait(5)
		
		-- Send back to original positions
		teleportFruits(nil, true)
		
		-- Wait 1 second
		task.wait(1)
		
		-- Loop restarts, immediately bringing them back to the player
	end
end)
