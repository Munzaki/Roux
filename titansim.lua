--// Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// Toggles
local autoActive = false
local skyLockActive = false
local autoRebirthActive = false
local fixedSkyPosition = Vector3.new(0, 5000, 0)
local updateInterval = 0.05

--// Noclip variables
local NoclipConnection = nil
local Clip = nil
local floatName = ""

--// Functions
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hrp
end

local function getPunchTool()
    local char, _ = getCharacter()
    local backpack = player:WaitForChild("Backpack")
    local tool = char:FindFirstChild("Punch") or backpack:FindFirstChild("Punch")
    if tool and tool.Parent ~= char then
        char:WaitForChild("Humanoid"):EquipTool(tool)
    end
    return tool
end

--// Loops
-- Auto-Punch
spawn(function()
    while true do
        if autoActive then
            local tool = getPunchTool()
            if tool then
                tool:Activate()
            end
        end
        task.wait(0.05)
    end
end)

-- Auto Drop Teleport
spawn(function()
    while true do
        if autoActive then
            local _, hrp = getCharacter()
            if hrp then
                for _, drop in pairs(Workspace:GetChildren()) do
                    if drop.Name == "Drop" and drop:IsA("BasePart") then
                        drop.CFrame = hrp.CFrame
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Sky Lock
spawn(function()
    while true do
        if skyLockActive then
            local _, hrp = getCharacter()
            if hrp then
                hrp.CFrame = CFrame.new(fixedSkyPosition)
            end
        end
        task.wait(updateInterval)
    end
end)

-- Auto Rebirth
local RebirthEvent = ReplicatedStorage:WaitForChild("RemoteEventContainer"):WaitForChild("Rebirth")
spawn(function()
    while true do
        if autoRebirthActive then
            pcall(function()
                RebirthEvent:FireServer()
            end)
        end
        task.wait(0.05) -- adjust speed if needed
    end
end)

--// GUI
local function createGUI()
    local existing = player:FindFirstChild("PlayerGui"):FindFirstChild("AutoPunchDropsGUI")
    if existing then
        existing:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoPunchDropsGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 220, 0, 220)
    Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Frame.Active = true
    Frame.Draggable = true

    local function createButton(name, posY, callback)
        local button = Instance.new("TextButton")
        button.Parent = Frame
        button.Size = UDim2.new(1, -10, 0, 40)
        button.Position = UDim2.new(0, 5, 0, posY)
        button.BackgroundColor3 = Color3.fromRGB(60,60,60)
        button.TextColor3 = Color3.fromRGB(255,255,255)
        button.TextSize = 18
        button.Font = Enum.Font.SourceSansBold
        button.Text = name
        button.MouseButton1Click:Connect(callback)
        return button
    end

    createButton("Start Auto", 10, function()
        autoActive = true
        autoRebirthActive = true
        print("Automation started")
    end)

    createButton("Stop Auto", 60, function()
        autoActive = false
        autoRebirthActive = false
        print("Automation stopped")
    end)

    createButton("Toggle Sky Lock", 110, function()
        skyLockActive = not skyLockActive
        print("Sky Lock: " .. (skyLockActive and "ON" or "OFF"))
    end)

    return ScreenGui
end

-- Initial GUI
createGUI()

-- Recreate GUI on respawn
player.CharacterAdded:Connect(function()
    createGUI()
end)

--// Noclip functions
local function noclip()
    Clip = false
    local function Nocl()
        if Clip == false and player.Character ~= nil then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide and v.Name ~= floatName then
                    v.CanCollide = false
                end
            end
        end
    end
    NoclipConnection = RunService.Stepped:Connect(Nocl)
end

local function clip()
    if NoclipConnection then NoclipConnection:Disconnect() end
    Clip = true
end

-- Activate noclip
noclip()
