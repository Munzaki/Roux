-- References to RemoteFunctions
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KnitIndex = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.5.1"):WaitForChild("knit"):WaitForChild("Services")

local ChestService = KnitIndex:WaitForChild("ChestService").RF
local RebirthService = KnitIndex:WaitForChild("RebirthService").RF
local PetService = KnitIndex:WaitForChild("PetService").RE
local ItemCrateService = KnitIndex:WaitForChild("ItemCrateService").RE

local UserInputService = game:GetService("UserInputService")

-- Timer for EnlargeAllPets
local lastEnlargeTime = 0
local enlargeInterval = 3 -- seconds

-- Control flag for crate loop
local loopCrate = false

-- Loop function for UnboxCrate
spawn(function()
    while true do
        if loopCrate then
            local args = {"Crate_1"}
            pcall(function()
                ItemCrateService.UnboxCrate:FireServer(unpack(args))
            end)
        end
        wait(1)
    end
end)

-- Toggle loop with key press (e.g., "R")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R and not gameProcessed then
        loopCrate = not loopCrate
        print("UnboxCrate loop: " .. (loopCrate and "ON" or "OFF"))
    end
end)

-- Main loop
while true do
    -- Claim chests immediately
    ChestService.ClaimDailyChest:InvokeServer()
    ChestService.ClaimGroupChest:InvokeServer()

    -- Perform rebirth
    RebirthService.Rebirth:InvokeServer()

    -- Check if it's time to fire EnlargeAllPets
    if tick() - lastEnlargeTime >= enlargeInterval then
        PetService.EnlargeAllPets:FireServer()
        lastEnlargeTime = tick()
    end

    wait() -- minimal yield to prevent freezing
end
