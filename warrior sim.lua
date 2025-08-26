--// Warrior Simulator Script (Full Patched Version)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Variables
local killauraEnabled = false
local tpEnabled = false
local autoSellEnabled = false
local autoSellGoldEnabled = false
local selectedZone = "Moon"
local teleportDelay = 5
local weaponName = ""

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 400)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Active = true
mainFrame.Draggable = true

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 10)

-- Buttons
local function createButton(name, text, posY)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 25, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    return btn
end

local killauraBtn = createButton("KillAuraBtn", "Toggle Kill Aura", 10)
local tpBtn = createButton("TPBtn", "Toggle TP", 50)
local autoSellBtn = createButton("AutoSellBtn", "Toggle Auto Sell (Moon)", 90)
local autoSellGoldBtn = createButton("AutoSellGoldBtn", "Toggle Auto Sell (Gold)", 130)

-- Teleport Delay
local delayBox = Instance.new("TextBox", mainFrame)
delayBox.Size = UDim2.new(0,200,0,30)
delayBox.Position = UDim2.new(0,25,0,170)
delayBox.PlaceholderText = "Teleport Delay (secs)"
delayBox.Text = tostring(teleportDelay)
delayBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
delayBox.TextColor3 = Color3.fromRGB(255,255,255)

delayBox.FocusLost:Connect(function()
    local val = tonumber(delayBox.Text)
    if val and val > 0 then
        teleportDelay = val
    else
        delayBox.Text = tostring(teleportDelay)
    end
end)

-- Weapon Name
local weaponBox = Instance.new("TextBox", mainFrame)
weaponBox.Size = UDim2.new(0,200,0,30)
weaponBox.Position = UDim2.new(0,25,0,210)
weaponBox.PlaceholderText = "Weapon Name"
weaponBox.Text = weaponName
weaponBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
weaponBox.TextColor3 = Color3.fromRGB(255,255,255)

weaponBox.FocusLost:Connect(function()
    weaponName = weaponBox.Text
end)

-- Zone Dropdown (Scrollable)
local zones = {"Grassland","Desert","Iceland","Lavaland","Overseer","Egypt","Moon","Mars","Future","Pluto","Neptune","Uranus","Saturn","Jupiter","Venus","Mercury"}

local dropdown = Instance.new("TextButton", mainFrame)
dropdown.Size = UDim2.new(0,200,0,30)
dropdown.Position = UDim2.new(0,25,0,250)
dropdown.Text = "Zone: "..selectedZone
dropdown.BackgroundColor3 = Color3.fromRGB(70,70,70)
dropdown.TextColor3 = Color3.fromRGB(255,255,255)

local dropdownFrame = Instance.new("ScrollingFrame", mainFrame)
dropdownFrame.Size = UDim2.new(0,200,0,120)
dropdownFrame.Position = UDim2.new(0,25,0,290)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
dropdownFrame.ScrollBarThickness = 6
dropdownFrame.Visible = false
dropdownFrame.CanvasSize = UDim2.new(0,0,0,#zones * 25)

for i,zone in ipairs(zones) do
    local opt = Instance.new("TextButton", dropdownFrame)
    opt.Size = UDim2.new(1,0,0,25)
    opt.Position = UDim2.new(0,0,0,(i-1)*25)
    opt.Text = zone
    opt.BackgroundColor3 = Color3.fromRGB(80,80,80)
    opt.TextColor3 = Color3.fromRGB(255,255,255)
    opt.MouseButton1Click:Connect(function()
        selectedZone = zone
        dropdown.Text = "Zone: "..zone
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Functions
local function getWeapon()
    if weaponName ~= "" then
        return LocalPlayer.Backpack:FindFirstChild(weaponName) or LocalPlayer.Character:FindFirstChild(weaponName)
    end
    return nil
end

local function attackEnemy(enemy)
    local weapon = getWeapon()
    if weapon and enemy:FindFirstChild("HumanoidRootPart") then
        ReplicatedStorage.Packages._Index["sleitnick_knit@1.5.1"].knit.Services.WeaponService.RE.SwordAttack:FireServer(weapon)
    end
end

-- Kill Aura
task.spawn(function()
    while task.wait(0.2) do
        if killauraEnabled then
            local zoneFolder = workspace.newMap.Zones:FindFirstChild(selectedZone)
            if zoneFolder and zoneFolder:FindFirstChild("Enemies") then
                for _,enemy in ipairs(zoneFolder.Enemies:GetChildren()) do
                    attackEnemy(enemy)
                end
            end
        end
    end
end)

-- Teleport Loop
task.spawn(function()
    while task.wait(1) do
        if tpEnabled then
            local zoneFolder = workspace.newMap.Zones:FindFirstChild(selectedZone)
            if zoneFolder and zoneFolder:FindFirstChild("Enemies") then
                for _,enemy in ipairs(zoneFolder.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                        task.wait(teleportDelay)
                    end
                end
            end
        end
    end
end)

-- Auto Sell Moon
task.spawn(function()
    while task.wait(1) do
        if autoSellEnabled then
            local args = {1}
            ReplicatedStorage.RemoteEvents.Client.touchedDetector:FireServer(unpack(args))
        end
    end
end)

-- Auto Sell Gold
task.spawn(function()
    while task.wait(1) do
        if autoSellGoldEnabled then
            local args = {0}
            ReplicatedStorage.RemoteEvents.Client.touchedDetector:FireServer(unpack(args))
        end
    end
end)

-- Button Connections
killauraBtn.MouseButton1Click:Connect(function() killauraEnabled = not killauraEnabled end)
tpBtn.MouseButton1Click:Connect(function() tpEnabled = not tpEnabled end)
autoSellBtn.MouseButton1Click:Connect(function() autoSellEnabled = not autoSellEnabled end)
autoSellGoldBtn.MouseButton1Click:Connect(function() autoSellGoldEnabled = not autoSellGoldEnabled end)
