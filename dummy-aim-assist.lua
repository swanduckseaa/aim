-- Dummy-targeting aim assist for Arceus X
-- Targets dummy-style Roblox characters only, not real players.
-- Mobile-friendly UI with FOV and target point selection.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local config = {
    enabled = true,
    fov = 90,
    smooth = 0.24,
    aimPart = "Head",
    maxDistance = 260,
    autoSpawnDummies = true,
    cameraAssist = true,
    snapStrength = 0.30,
}

local state = {
    currentTarget = nil,
    dummyCount = 0,
}

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function round(value, digits)
    local mult = 10 ^ (digits or 0)
    return math.floor(value * mult + 0.5) / mult
end

local function getAimPart(model)
    local aimPartName = string.lower(config.aimPart)
    local candidates = {
        head = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"},
        torso = {"Torso", "UpperTorso", "HumanoidRootPart", "Head"},
        legs = {"LeftLeg", "RightLeg", "HumanoidRootPart", "Torso"},
    }

    local list = candidates[aimPartName] or candidates.head
    for _, name in ipairs(list) do
        local part = model:FindFirstChild(name)
        if part then
            return part
        end
    end

    return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
end

local function getCharacterModels()
    local list = {}
    local seen = {}

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local name = string.lower(obj.Name)
            if name:find("dummy") or name:find("bot") or name:find("npc") or name:find("test") then
                if not seen[obj] then
                    seen[obj] = true
                    table.insert(list, obj)
                end
            end
        end
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local name = string.lower(otherPlayer.Name)
            if name:find("dummy") or name:find("bot") or name:find("npc") or name:find("test") then
                if not seen[otherPlayer.Character] then
                    seen[otherPlayer.Character] = true
                    table.insert(list, otherPlayer.Character)
                end
            end
        end
    end

    return list
end

local function createDummy(position)
    local dummy = Instance.new("Model")
dummy.Name = "AimDummy"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 2, 1)
    root.Position = position
    root.Anchored = true
    root.Color = Color3.fromRGB(255, 112, 112)
    root.Material = Enum.Material.SmoothPlastic
    root.Parent = dummy

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 2, 2)
    head.Position = position + Vector3.new(0, 3.2, 0)
    head.Anchored = true
    head.Color = Color3.fromRGB(255, 255, 255)
    head.Material = Enum.Material.SmoothPlastic
    head.Parent = dummy

    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Position = position + Vector3.new(0, 1.3, 0)
    torso.Anchored = true
    torso.Color = Color3.fromRGB(120, 180, 255)
    torso.Material = Enum.Material.SmoothPlastic
    torso.Parent = dummy

    local leftArm = Instance.new("Part")
    leftArm.Name = "LeftArm"
    leftArm.Size = Vector3.new(1, 2, 1)
    leftArm.Position = position + Vector3.new(-1.4, 1.3, 0)
    leftArm.Anchored = true
    leftArm.Color = Color3.fromRGB(255, 255, 255)
    leftArm.Parent = dummy

    local rightArm = Instance.new("Part")
    rightArm.Name = "RightArm"
    rightArm.Size = Vector3.new(1, 2, 1)
    rightArm.Position = position + Vector3.new(1.4, 1.3, 0)
    rightArm.Anchored = true
    rightArm.Color = Color3.fromRGB(255, 255, 255)
    rightArm.Parent = dummy

    local leftLeg = Instance.new("Part")
    leftLeg.Name = "LeftLeg"
    leftLeg.Size = Vector3.new(1, 2, 1)
    leftLeg.Position = position + Vector3.new(-0.5, -0.8, 0)
    leftLeg.Anchored = true
    leftLeg.Color = Color3.fromRGB(120, 180, 255)
    leftLeg.Parent = dummy

    local rightLeg = Instance.new("Part")
    rightLeg.Name = "RightLeg"
    rightLeg.Size = Vector3.new(1, 2, 1)
    rightLeg.Position = position + Vector3.new(0.5, -0.8, 0)
    rightLeg.Anchored = true
    rightLeg.Color = Color3.fromRGB(120, 180, 255)
    rightLeg.Parent = dummy

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "Humanoid"
    humanoid.Parent = dummy

    dummy.Parent = Workspace
    return dummy
end

local function ensureDummies()
    local existing = getCharacterModels()
    if #existing > 0 then
        state.dummyCount = #existing
        return existing
    end

    if not config.autoSpawnDummies then
        return {}
    end

    local basePos = Vector3.new(0, 0, 0)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        basePos = player.Character.HumanoidRootPart.Position
    end

    local created = {}
    for i = 1, 3 do
        local offset = Vector3.new((i - 2) * 8, 0, -14)
        local dummy = createDummy(basePos + offset)
        table.insert(created, dummy)
    end

    state.dummyCount = #created
    return created
end

local function getBestTarget()
    local center = Vector2.new(screenGui.AbsoluteSize.X / 2, screenGui.AbsoluteSize.Y / 2)
    local best = nil
    local bestScore = math.huge

    for _, model in ipairs(ensureDummies()) do
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local part = getAimPart(model)

            if part then
                local ok, screen = pcall(function()
                    return camera:WorldToViewportPoint(part.Position)
                end)

                if ok and screen.Z > 0 then
                    local pos = Vector2.new(screen.X, screen.Y)
                    local dist = (pos - center).Magnitude
                    local worldDist = (part.Position - camera.CFrame.Position).Magnitude

                    if dist <= config.fov and worldDist <= config.maxDistance then
                        local score = dist + worldDist * 0.02
                        if score < bestScore then
                            bestScore = score
                            best = {model = model, part = part, pos = pos, dist = dist}
                        end
                    end
                end
            end
        end
    end

    return best
end

local function clearHighlight(model)
    if model then
        local old = model:FindFirstChild("AimAssistHighlight")
        if old then
            old:Destroy()
        end
    end
end

local function showHighlight(model)
    clearHighlight(model)
    if not model then
        return
    end

    local hl = Instance.new("Highlight")
    hl.Name = "AimAssistHighlight"
    hl.FillColor = Color3.fromRGB(0, 255, 153)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.35
    hl.OutlineTransparency = 0.2
    hl.Parent = model
end

local function updateStatus(text)
    if statusLabel then
        statusLabel.Text = text
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DummyAimAssistGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 300, 0, 230)
main.Position = UDim2.new(0.02, 0, 0.02, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
main.BorderSizePixel = 0
main.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.new(0, 10, 0, 8)
title.Text = "Dummy Aim Assist"
title.TextColor3 = Color3.fromRGB(245, 247, 250)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = main

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 0, 34)
statusLabel.Text = "Searching for dummies"
statusLabel.TextColor3 = Color3.fromRGB(145, 170, 200)
statusLabel.TextSize = 11
title.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = main

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.4, -8, 0, 34)
toggleButton.Position = UDim2.new(0, 10, 0, 60)
toggleButton.Text = "On"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 13
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BackgroundColor3 = Color3.fromRGB(66, 199, 111)
toggleButton.BorderSizePixel = 0
toggleButton.Parent = main

toggleButton.MouseButton1Click:Connect(function()
    config.enabled = not config.enabled
    toggleButton.Text = config.enabled and "On" or "Off"
    toggleButton.BackgroundColor3 = config.enabled and Color3.fromRGB(66, 199, 111) or Color3.fromRGB(120, 128, 145)
    updateStatus(config.enabled and "Tracking dummies" or "Paused")
end)

local modeButtons = {}
local aimPartButtons = {"Head", "Torso", "Legs"}
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, -20, 0, 38)
modeFrame.Position = UDim2.new(0, 10, 0, 102)
modeFrame.BackgroundTransparency = 1
modeFrame.Parent = main

for index, partName in ipairs(aimPartButtons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 1, 0)
    btn.Position = UDim2.new(0.02 + (index - 1) * 0.32, 0, 0, 0)
    btn.Text = partName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(80, 95, 125)
    btn.BorderSizePixel = 0
    btn.Parent = modeFrame

    btn.MouseButton1Click:Connect(function()
        config.aimPart = partName
        for _, other in ipairs(modeButtons) do
            other.BackgroundColor3 = Color3.fromRGB(80, 95, 125)
        end
        btn.BackgroundColor3 = Color3.fromRGB(66, 199, 111)
        updateStatus("Aim point: " .. partName)
    end)

    table.insert(modeButtons, btn)
end
modeButtons[1].BackgroundColor3 = Color3.fromRGB(66, 199, 111)

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, -20, 0, 16)
fovLabel.Position = UDim2.new(0, 10, 0, 150)
fovLabel.Text = "FOV: 70"
fovLabel.TextColor3 = Color3.fromRGB(175, 190, 210)
fovLabel.TextSize = 11
fovLabel.Font = Enum.Font.Gotham
fovLabel.BackgroundTransparency = 1
fovLabel.Parent = main

local fovBar = Instance.new("Frame")
fovBar.Size = UDim2.new(1, -20, 0, 10)
fovBar.Position = UDim2.new(0, 10, 0, 170)
fovBar.BackgroundColor3 = Color3.fromRGB(70, 85, 110)
fovBar.BorderSizePixel = 0
fovBar.Parent = main

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(0.7, 0, 1, 0)
fovFill.BackgroundColor3 = Color3.fromRGB(66, 199, 111)
fovFill.BorderSizePixel = 0
fovFill.Parent = fovBar

local knob = Instance.new("TextButton")
knob.Size = UDim2.new(0, 16, 0, 16)
knob.Position = UDim2.new(0.7, -8, 0.5, -8)
knob.Text = ""
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.Parent = fovBar

local draggingFOV = false
local function updateFOVVisual()
    local ratio = (config.fov - 20) / 100
    fovFill.Size = UDim2.new(ratio, 0, 1, 0)
    knob.Position = UDim2.new(ratio, -8, 0.5, -8)
    fovLabel.Text = "FOV: " .. tostring(math.floor(config.fov))
end

local function setFOVFromInput(x)
    local ratio = clamp((x - fovBar.AbsolutePosition.X) / fovBar.AbsoluteSize.X, 0, 1)
    config.fov = 20 + ratio * 100
    updateFOVVisual()
end

fovBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFOV = true
        setFOVFromInput(input.Position.X)
    end
end)

UIS.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if draggingFOV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setFOVFromInput(input.Position.X)
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFOV = false
    end
end)

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 24, 0, 24)
crosshair.Position = UDim2.new(0.5, -12, 0.5, -12)
crosshair.BackgroundTransparency = 1
crosshair.ZIndex = 50
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

local connection
local function stopAssist()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

local function startAssist()
    stopAssist()
    connection = RunService.RenderStepped:Connect(function()
        if not config.enabled or not camera then
            return
        end

        local target = getBestTarget()
        if target then
            state.currentTarget = target
            showHighlight(target.model)
            updateStatus("Target: " .. target.model.Name)

            crosshair.Visible = true
            local screenPos = target.pos
            crosshair.Position = UDim2.new(0, screenPos.X - 12, 0, screenPos.Y - 12)

            if config.cameraAssist then
                local cameraLook = CFrame.new(camera.CFrame.Position, target.part.Position)
                local lerpAlpha = clamp(config.smooth + (target.dist / 500), 0.18, 0.42)
                camera.CFrame = camera.CFrame:Lerp(cameraLook, lerpAlpha)
            end
        else
            state.currentTarget = nil
            clearHighlight(nil)
            updateStatus("No dummy in range")
            crosshair.Visible = false
        end
    end)
end

updateFOVVisual()
startAssist()
