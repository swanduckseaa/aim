-- Practice-only aim trainer overlay for Arceus X
-- This does not target real players or interact with gameplay.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimTrainerOverlay"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 320)
main.Position = UDim2.new(0.02, 0, 0.02, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
main.BorderSizePixel = 0
main.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 10)
title.Text = "Aim Trainer"
title.TextColor3 = Color3.fromRGB(245, 247, 250)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 18)
subtitle.Position = UDim2.new(0, 10, 0, 38)
subtitle.Text = "Practice-only overlay • no player targeting"
subtitle.TextColor3 = Color3.fromRGB(140, 160, 190)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
title.BackgroundTransparency = 1
subtitle.Parent = main

local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -16, 0, 42)
buttonFrame.Position = UDim2.new(0, 8, 0, 64)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = main

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.5, -6, 1, 0)
startButton.Position = UDim2.new(0, 0, 0, 0)
startButton.Text = "Start"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextSize = 14
startButton.Font = Enum.Font.GothamBold
startButton.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
startButton.BorderSizePixel = 0
startButton.Parent = buttonFrame

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0.5, -6, 1, 0)
resetButton.Position = UDim2.new(0.5, 6, 0, 0)
resetButton.Text = "Reset"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 14
resetButton.Font = Enum.Font.GothamBold
resetButton.BackgroundColor3 = Color3.fromRGB(86, 102, 132)
resetButton.BorderSizePixel = 0
resetButton.Parent = buttonFrame

local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, -16, 0, 44)
modeFrame.Position = UDim2.new(0, 8, 0, 116)
modeFrame.BackgroundTransparency = 1
modeFrame.Parent = main

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(0.32, 0, 1, 0)
modeLabel.Position = UDim2.new(0, 0, 0, 0)
modeLabel.Text = "Aim at"
modeLabel.TextColor3 = Color3.fromRGB(185, 198, 214)
modeLabel.TextSize = 12
modeLabel.Font = Enum.Font.Gotham
modeLabel.BackgroundTransparency = 1
modeLabel.Parent = modeFrame

local modeButtons = {}
local targetMode = "head"
local modeNames = {"head", "torso", "legs"}
for i, name in ipairs(modeNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.22, 0, 1, 0)
    b.Position = UDim2.new(0.32 + (i - 1) * 0.22, 0, 0, 0)
    b.Text = string.upper(string.sub(name, 1, 1)) .. string.sub(name, 2)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = Color3.fromRGB(79, 96, 128)
    b.BorderSizePixel = 0
    b.Parent = modeFrame

    b.MouseButton1Click:Connect(function()
        targetMode = name
        for _, btn in ipairs(modeButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(79, 96, 128)
        end
        b.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
    end)

    table.insert(modeButtons, b)
end
modeButtons[1].BackgroundColor3 = Color3.fromRGB(52, 168, 83)

local fovFrame = Instance.new("Frame")
fovFrame.Size = UDim2.new(1, -16, 0, 60)
fovFrame.Position = UDim2.new(0, 8, 0, 170)
fovFrame.BackgroundTransparency = 1
fovFrame.Parent = main

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 16)
fovLabel.Position = UDim2.new(0, 0, 0, 0)
fovLabel.Text = "FOV: 70"
fovLabel.TextColor3 = Color3.fromRGB(185, 198, 214)
fovLabel.TextSize = 12
fovLabel.Font = Enum.Font.Gotham
fovLabel.BackgroundTransparency = 1
fovLabel.Parent = fovFrame

local fovBar = Instance.new("Frame")
fovBar.Size = UDim2.new(1, -4, 0, 8)
fovBar.Position = UDim2.new(0, 2, 0, 24)
fovBar.BackgroundColor3 = Color3.fromRGB(60, 72, 94)
fovBar.BorderSizePixel = 0
fovBar.Parent = fovFrame

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(0.58, 0, 1, 0)
fovFill.Position = UDim2.new(0, 0, 0, 0)
fovFill.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
fovFill.BorderSizePixel = 0
fovFill.Parent = fovBar

local fovKnob = Instance.new("TextButton")
fovKnob.Size = UDim2.new(0, 16, 0, 16)
fovKnob.Position = UDim2.new(0.58, -8, 0.5, -8)
fovKnob.Text = ""
fovKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovKnob.BorderSizePixel = 0
fovKnob.Parent = fovBar

local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -16, 0, 44)
statsFrame.Position = UDim2.new(0, 8, 0, 244)
statsFrame.BackgroundTransparency = 1
statsFrame.Parent = main

local scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(0.33, 0, 1, 0)
scoreLabel.Position = UDim2.new(0, 0, 0, 0)
scoreLabel.Text = "Score: 0"
scoreLabel.TextColor3 = Color3.fromRGB(245, 247, 250)
scoreLabel.TextSize = 13
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.BackgroundTransparency = 1
scoreLabel.Parent = statsFrame

local hitLabel = Instance.new("TextLabel")
hitLabel.Size = UDim2.new(0.33, 0, 1, 0)
hitLabel.Position = UDim2.new(0.33, 0, 0, 0)
hitLabel.Text = "Hits: 0"
hitLabel.TextColor3 = Color3.fromRGB(245, 247, 250)
hitLabel.TextSize = 13
hitLabel.Font = Enum.Font.GothamBold
hitLabel.BackgroundTransparency = 1
hitLabel.Parent = statsFrame

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0.34, 0, 1, 0)
timeLabel.Position = UDim2.new(0.66, 0, 0, 0)
timeLabel.Text = "Time: 0s"
timeLabel.TextColor3 = Color3.fromRGB(245, 247, 250)
timeLabel.TextSize = 13
timeLabel.Font = Enum.Font.GothamBold
timeLabel.BackgroundTransparency = 1
timeLabel.Parent = statsFrame

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 24, 0, 24)
crosshair.BackgroundTransparency = 1
crosshair.ZIndex = 99
crosshair.Parent = screenGui

local crossX = Instance.new("Frame")
crossX.Size = UDim2.new(0, 2, 0, 10)
crossX.Position = UDim2.new(0.5, -1, 0.5, -5)
crossX.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crossX.BorderSizePixel = 0
crossX.Parent = crosshair

local crossY = Instance.new("Frame")
crossY.Size = UDim2.new(0, 10, 0, 2)
crossY.Position = UDim2.new(0.5, -5, 0.5, -1)
crossY.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crossY.BorderSizePixel = 0
crossY.Parent = crosshair

local target = nil
local running = false
local score = 0
local hits = 0
local seconds = 0
local timer = nil
local fovValue = 70
local draggingSlider = false

local targetSizes = {
    head = 22,
    torso = 32,
    legs = 42,
}

local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

local function updateFovVisual()
    local ratio = (fovValue - 20) / 100
    fovFill.Size = UDim2.new(ratio, 0, 1, 0)
    fovKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
    fovLabel.Text = "FOV: " .. tostring(fovValue)
end

local function setFov(value)
    fovValue = clamp(math.floor(value), 20, 120)
    updateFovVisual()
end

local function updateStats()
    scoreLabel.Text = "Score: " .. tostring(score)
    hitLabel.Text = "Hits: " .. tostring(hits)
    timeLabel.Text = "Time: " .. tostring(seconds) .. "s"
end

local function moveTarget()
    if target then
        target:Destroy()
    end

    local size = targetSizes[targetMode]
    local x = math.random(40, math.max(40, screenGui.AbsoluteSize.X - size - 40))
    local y = math.random(80, math.max(80, screenGui.AbsoluteSize.Y - size - 40))

    target = Instance.new("TextButton")
    target.Size = UDim2.new(0, size, 0, size)
    target.Position = UDim2.new(0, x, 0, y)
    target.Text = ""
    target.BackgroundColor3 = Color3.fromRGB(255, 95, 95)
    target.BorderSizePixel = 0
    target.AutoButtonColor = false
    target.ZIndex = 50
    target.Parent = screenGui

    target.MouseButton1Click:Connect(function()
        if not running then return end
        local tx = target.AbsolutePosition.X + size / 2
        local ty = target.AbsolutePosition.Y + size / 2
        local cx = crosshair.AbsolutePosition.X + 12
        local cy = crosshair.AbsolutePosition.Y + 12
        local distance = math.sqrt((tx - cx) ^ 2 + (ty - cy) ^ 2)

        if distance <= fovValue then
            score += 1
            hits += 1
            updateStats()
            target.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            task.wait(0.08)
            moveTarget()
        else
            target.BackgroundColor3 = Color3.fromRGB(255, 95, 95)
        end
    end)
end

local function startTraining()
    running = true
    score = 0
    hits = 0
    seconds = 0
    updateStats()
    startButton.Text = "Stop"
    if timer then
        timer:Disconnect()
    end
    timer = RunService.Heartbeat:Connect(function(dt)
        seconds += dt
        timeLabel.Text = "Time: " .. tostring(math.floor(seconds)) .. "s"
    end)
    moveTarget()
end

local function stopTraining()
    running = false
    startButton.Text = "Start"
    if timer then
        timer:Disconnect()
        timer = nil
    end
    if target then
        target:Destroy()
        target = nil
    end
    updateStats()
end

startButton.MouseButton1Click:Connect(function()
    if running then
        stopTraining()
    else
        startTraining()
    end
end)

resetButton.MouseButton1Click:Connect(function()
    stopTraining()
    score = 0
    hits = 0
    seconds = 0
    updateStats()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.X >= fovBar.AbsolutePosition.X and input.Position.X <= fovBar.AbsolutePosition.X + fovBar.AbsoluteSize.X and input.Position.Y >= fovBar.AbsolutePosition.Y and input.Position.Y <= fovBar.AbsolutePosition.Y + fovBar.AbsoluteSize.Y then
            draggingSlider = true
            local ratio = clamp((input.Position.X - fovBar.AbsolutePosition.X) / fovBar.AbsoluteSize.X, 0, 1)
            setFov(20 + ratio * 100)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        crosshair.Position = UDim2.new(0, input.Position.X - 12, 0, input.Position.Y - 12)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local ratio = clamp((input.Position.X - fovBar.AbsolutePosition.X) / fovBar.AbsoluteSize.X, 0, 1)
            setFov(20 + ratio * 100)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

updateFovVisual()
updateStats()
stopTraining()
