-- Roblox aimbot script for mobile with FOV slider, toggleable GUI, and target options
-- Note: This script is for educational purposes only. Using aimbots is against Roblox TOS.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AimbotGui"
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "Aimbot: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.AutoButtonColor = true

local FOVSliderLabel = Instance.new("TextLabel", ScreenGui)
FOVSliderLabel.Size = UDim2.new(0, 200, 0, 20)
FOVSliderLabel.Position = UDim2.new(0, 10, 0, 60)
FOVSliderLabel.Text = "FOV: 100"
FOVSliderLabel.BackgroundTransparency = 1
FOVSliderLabel.TextColor3 = Color3.new(1,1,1)
FOVSliderLabel.Font = Enum.Font.SourceSans
FOVSliderLabel.TextSize = 18

local FOVSlider = Instance.new("Frame", ScreenGui)
FOVSlider.Size = UDim2.new(0, 200, 0, 20)
FOVSlider.Position = UDim2.new(0, 10, 0, 80)
FOVSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
FOVSlider.BorderSizePixel = 0

local FOVFill = Instance.new("Frame", FOVSlider)
FOVFill.Size = UDim2.new(0.5, 0, 1, 0)
FOVFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FOVFill.BorderSizePixel = 0

local FOVSliderButton = Instance.new("TextButton", FOVSlider)
FOVSliderButton.Size = UDim2.new(0, 20, 1, 0)
FOVSliderButton.Position = UDim2.new(0.5, -10, 0, 0)
FOVSliderButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FOVSliderButton.Text = ""
FOVSliderButton.AutoButtonColor = false

local TargetDropdown = Instance.new("TextButton", ScreenGui)
TargetDropdown.Size = UDim2.new(0, 120, 0, 40)
TargetDropdown.Position = UDim2.new(0, 10, 0, 110)
TargetDropdown.Text = "Target: Head"
TargetDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TargetDropdown.TextColor3 = Color3.new(1,1,1)
TargetDropdown.Font = Enum.Font.SourceSansBold
TargetDropdown.TextSize = 20
TargetDropdown.AutoButtonColor = true

local DropdownFrame = Instance.new("Frame", ScreenGui)
DropdownFrame.Size = UDim2.new(0, 120, 0, 90)
DropdownFrame.Position = UDim2.new(0, 10, 0, 150)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DropdownFrame.Visible = false
DropdownFrame.BorderSizePixel = 0

local targets = {"Head", "Torso", "Legs"}
local targetButtons = {}

for i, v in ipairs(targets) do
    local btn = Instance.new("TextButton", DropdownFrame)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
    btn.Text = v
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.AutoButtonColor = true
    targetButtons[v] = btn
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- Variables
local aimbotEnabled = false
local fov = 100
local targetPartName = "Head"

-- Functions
local function isTeammate(player)
    local lpTeam = LocalPlayer.Team
    if lpTeam and player.Team and lpTeam == player.Team then
        return true
    end
    return false
end

local function isDead(character)
    if not character then return true end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return true
    end
    return false
end

local function isVisible(targetCharacter)
    if not targetCharacter then return false end
    local targetPart = targetCharacter:FindFirstChild(targetPartName)
    if not targetPart then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult and raycastResult.Instance and targetCharacter:IsAncestorOf(raycastResult.Instance) then
        return true
    end
    return false
end

local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not isDead(player.Character) and not isTeammate(player) and isVisible(player.Character) then
            local targetPart = player.Character:FindFirstChild(targetPartName)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if dist < fov and dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function aimAt(targetCharacter)
    if not targetCharacter then return end
    local targetPart = targetCharacter:FindFirstChild(targetPartName)
    if not targetPart then return end
    local cameraCFrame = Camera.CFrame
    local direction = (targetPart.Position - cameraCFrame.Position).Unit
    local newCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + direction)
    Camera.CFrame = newCFrame
end

-- UI Events
ToggleButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    ToggleButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    FOVCircle.Visible = aimbotEnabled
end)

local dragging = false
FOVSliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
FOVSliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouseX = UserInputService:GetMouseLocation().X
        local sliderPos = FOVSlider.AbsolutePosition.X
        local sliderSize = FOVSlider.AbsoluteSize.X
        local relativeX = math.clamp(mouseX - sliderPos, 0, sliderSize)
        local percent = relativeX / sliderSize
        fov = math.floor(percent * 300)
        FOVFill.Size = UDim2.new(percent, 0, 1, 0)
        FOVSliderButton.Position = UDim2.new(percent, -10, 0, 0)
        FOVSliderLabel.Text = "FOV: " .. tostring(fov)
        FOVCircle.Radius = fov
    end
end)

TargetDropdown.MouseButton1Click:Connect(function()
    DropdownFrame.Visible = not DropdownFrame.Visible
end)

for name, btn in pairs(targetButtons) do
    btn.MouseButton1Click:Connect(function()
        targetPartName = name
        TargetDropdown.Text = "Target: " .. name
        DropdownFrame.Visible = false
    end)
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local targetPlayer = getClosestTarget()
        if targetPlayer and targetPlayer.Character then
            aimAt(targetPlayer.Character)
        end
    end
    if FOVCircle.Visible then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)
