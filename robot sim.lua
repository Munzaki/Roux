-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- References
local AttackFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("Attack")
local RebirthFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("Rebirth")
local CrystalsFolder = workspace:WaitForChild("Crystals")

-- Toggle flags
local loopAttack = false
local loopRebirth = false
local loopCrystals = false

-- Heartbeat connections
RunService.Heartbeat:Connect(function()
    if loopAttack then
        pcall(function()
            AttackFunction:InvokeServer(1)
        end)
    end
    if loopRebirth then
        pcall(function()
            RebirthFunction:InvokeServer()
        end)
    end
    if loopCrystals then
        for _, crystal in pairs(CrystalsFolder:GetChildren()) do
            if crystal:IsA("BasePart") then
                hrp.CFrame = crystal.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local function createButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = position
    button.Text = name .. ": OFF"
    button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    button.Parent = ScreenGui

    button.MouseButton1Click:Connect(function()
        local state = callback()
        button.Text = name .. ": " .. (state and "ON" or "OFF")
        button.BackgroundColor3 = state and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    end)
end

-- Buttons
createButton("Auto Attack", UDim2.new(0, 50, 0, 50), function()
    loopAttack = not loopAttack
    return loopAttack
end)

createButton("Auto Rebirth", UDim2.new(0, 50, 0, 120), function()
    loopRebirth = not loopRebirth
    return loopRebirth
end)

createButton("TP Crystals", UDim2.new(0, 50, 0, 190), function()
    loopCrystals = not loopCrystals
    return loopCrystals
end)
