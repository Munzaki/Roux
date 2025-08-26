-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- References
local SwordAttackEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Client"):WaitForChild("SwordAttack")
local touchedDetector = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Client"):WaitForChild("touchedDetector")

-- State variables
local killAuraActive = false
local autoSellActive = false
local autoSellGoldActive = false
local teleportDelay = 5 -- default seconds
local selectedZone = "Moon"
local selectedWeaponName = "Sword of the Epicredness"

-- Reference your sword (updated to use textbox weapon name)
local function getSword()
    local char = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")
    local sword = char:FindFirstChild(selectedWeaponName) or backpack:FindFirstChild(selectedWeaponName)
    if sword and sword.Parent ~= char then
        char:WaitForChild("Humanoid"):EquipTool(sword)
    end
    return sword
end

-- Attack a single mob repeatedly
local function attackMob(mob)
    local sword = getSword()
    local char, hrp = player.Character, player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if sword and char and hrp and mob and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
        spawn(function()
            while killAuraActive and mob.Parent and mob.Humanoid.Health > 0 do
                pcall(function()
                    SwordAttackEvent:FireServer(mob.Humanoid, sword, mob.HumanoidRootPart.Position, 5)
                end)
                wait(0.05)
            end
        end)
    end
end

-- Kill Aura + teleport loop
spawn(function()
    while true do
        if killAuraActive then
            local enemiesFolder = Workspace:FindFirstChild("newMap") 
                                and Workspace.newMap:FindFirstChild("Zones") 
                                and Workspace.newMap.Zones:FindFirstChild(selectedZone) 
                                and Workspace.newMap.Zones[selectedZone]:FindFirstChild("Enemies")
            if enemiesFolder then
                for _, mob in pairs(enemiesFolder:GetChildren()) do
                    if not killAuraActive then break end
                    if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = mob.HumanoidRootPart.CFrame
                            attackMob(mob)
                        end
                        wait(teleportDelay) -- delay before next mob
                    end
                end
            end
        end
        wait(0.5)
    end
end)

-- Auto Sell loop (Moon)
spawn(function()
    while true do
        if autoSellActive then
            pcall(function()
                touchedDetector:FireServer(1)
            end)
            wait(1)
        end
        wait(0.1)
    end
end)

-- Auto Sell loop (Gold)
spawn(function()
    while true do
        if autoSellGoldActive then
            pcall(function()
                local args = {0}
                touchedDetector:FireServer(unpack(args))
            end)
            wait(1)
        end
        wait(0.1)
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoScriptGUI"
ScreenGui.ResetOnSpawn = false -- keep GUI after death
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,220,0,350) -- increased height
mainFrame.Position = UDim2.new(0.5,-110,0.5,-175)
mainFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
mainFrame.Parent = ScreenGui
mainFrame.Active = true

-- ✅ Improved GUI Dragging (patched in)
local dragging = false
local dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Buttons
local function createButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,200,0,30)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("Toggle Kill Aura", 10, function()
    killAuraActive = not killAuraActive
    print("Kill Aura: "..(killAuraActive and "ON" or "OFF"))
end)

createButton("Toggle Auto Sell (Moon)", 50, function()
    autoSellActive = not autoSellActive
    print("Auto Sell (Moon): "..(autoSellActive and "ON" or "OFF"))
end)

createButton("Toggle Auto Sell (Gold)", 90, function()
    autoSellGoldActive = not autoSellGoldActive
    print("Auto Sell (Gold): "..(autoSellGoldActive and "ON" or "OFF"))
end)

-- Teleport Delay TextBox
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0,200,0,20)
delayLabel.Position = UDim2.new(0,10,0,130)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Teleport Delay (seconds):"
delayLabel.TextColor3 = Color3.new(1,1,1)
delayLabel.Parent = mainFrame

local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(0,200,0,25)
delayBox.Position = UDim2.new(0,10,0,150)
delayBox.Text = tostring(teleportDelay)
delayBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
delayBox.TextColor3 = Color3.new(1,1,1)
delayBox.ClearTextOnFocus = false
delayBox.Parent = mainFrame
delayBox.FocusLost:Connect(function()
    local val = tonumber(delayBox.Text)
    if val then teleportDelay = val end
end)

-- Weapon Name TextBox
local weaponLabel = Instance.new("TextLabel")
weaponLabel.Size = UDim2.new(0,200,0,20)
weaponLabel.Position = UDim2.new(0,10,0,180)
weaponLabel.BackgroundTransparency = 1
weaponLabel.Text = "Weapon Name:"
weaponLabel.TextColor3 = Color3.new(1,1,1)
weaponLabel.Parent = mainFrame

local weaponBox = Instance.new("TextBox")
weaponBox.Size = UDim2.new(0,200,0,25)
weaponBox.Position = UDim2.new(0,10,0,200)
weaponBox.Text = selectedWeaponName
weaponBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
weaponBox.TextColor3 = Color3.new(1,1,1)
weaponBox.ClearTextOnFocus = false
weaponBox.Parent = mainFrame
weaponBox.FocusLost:Connect(function()
    if weaponBox.Text ~= "" then
        selectedWeaponName = weaponBox.Text
    end
end)

-- Zone Selector Dropdown (Scrollable)
local zones = {"Grassland","Desert","Iceland","Lavaland","Overseer","Egypt","Moon","Mars","Future"}

local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0,200,0,30)
dropdown.Position = UDim2.new(0,10,0,230)
dropdown.Text = "Zone: "..selectedZone
dropdown.BackgroundColor3 = Color3.fromRGB(70,70,70)
dropdown.TextColor3 = Color3.fromRGB(255,255,255)
dropdown.Parent = mainFrame

-- Use ScrollingFrame for scrollable dropdown
local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Size = UDim2.new(0,200,0,120) -- visible area
dropdownFrame.Position = UDim2.new(0,10,0,260)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
dropdownFrame.ScrollBarThickness = 6
dropdownFrame.Visible = false
dropdownFrame.Parent = mainFrame
dropdownFrame.CanvasSize = UDim2.new(0,0,0,#zones*25)

for i,zone in ipairs(zones) do
    local opt = Instance.new("TextButton")
    opt.Size = UDim2.new(1,0,0,25)
    opt.Position = UDim2.new(0,0,0,(i-1)*25)
    opt.Text = zone
    opt.BackgroundColor3 = Color3.fromRGB(80,80,80)
    opt.TextColor3 = Color3.fromRGB(255,255,255)
    opt.Parent = dropdownFrame
    opt.MouseButton1Click:Connect(function()
        selectedZone = zone
        dropdown.Text = "Zone: "..zone
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)
