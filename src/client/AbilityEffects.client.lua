local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local abilityEffect = remotes:WaitForChild("AbilityEffect")

local gui = Instance.new("ScreenGui")
gui.Name = "AbilityEffectsUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.Parent = player:WaitForChild("PlayerGui")

local function staticBurst(payload)
    local duration = tonumber(payload.Duration) or 2
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(5, 18, 25)
    overlay.BackgroundTransparency = 0.18
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.fromScale(0.5, 0.5)
    label.Size = UDim2.fromScale(0.7, 0.18)
    label.BackgroundTransparency = 1
    label.Text = "SIGNAL HIJACKED\nSTATIC BURST"
    label.TextColor3 = Color3.fromRGB(100, 235, 255)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.Code
    label.Parent = overlay

    local bars = {}
    for i = 1, 18 do
        local bar = Instance.new("Frame")
        bar.BorderSizePixel = 0
        bar.BackgroundColor3 = i % 3 == 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(55, 220, 255)
        bar.BackgroundTransparency = 0.25
        bar.Size = UDim2.new(math.random(15, 80) / 100, 0, 0, math.random(2, 12))
        bar.Position = UDim2.new(math.random(0, 70) / 100, 0, math.random(0, 100) / 100, 0)
        bar.Parent = overlay
        bars[i] = bar
    end

    local finishAt = os.clock() + duration
    while os.clock() < finishAt and overlay.Parent do
        for _, bar in ipairs(bars) do
            bar.Position = UDim2.new(math.random(0, 75) / 100, 0, math.random(0, 100) / 100, 0)
            bar.BackgroundTransparency = math.random(10, 70) / 100
        end
        overlay.BackgroundTransparency = math.random(10, 35) / 100
        task.wait(0.08)
    end
    overlay:Destroy()
end

local function jumpScare(payload)
    local duration = tonumber(payload.Duration) or 1.4
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(8, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    local eye = Instance.new("TextLabel")
    eye.AnchorPoint = Vector2.new(0.5, 0.5)
    eye.Position = UDim2.fromScale(0.5, 0.45)
    eye.Size = UDim2.fromScale(0.65, 0.42)
    eye.BackgroundTransparency = 1
    eye.Text = "◉"
    eye.TextColor3 = Color3.fromRGB(255, 45, 45)
    eye.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    eye.TextStrokeTransparency = 0.2
    eye.TextScaled = true
    eye.Font = Enum.Font.GothamBlack
    eye.Parent = overlay

    local warning = Instance.new("TextLabel")
    warning.AnchorPoint = Vector2.new(0.5, 0.5)
    warning.Position = UDim2.fromScale(0.5, 0.72)
    warning.Size = UDim2.fromScale(0.8, 0.15)
    warning.BackgroundTransparency = 1
    warning.Text = "CONTAINMENT BREACH\nIT SAW YOU"
    warning.TextColor3 = Color3.new(1, 1, 1)
    warning.TextStrokeTransparency = 0
    warning.TextScaled = true
    warning.Font = Enum.Font.GothamBlack
    warning.Parent = overlay

    TweenService:Create(overlay, TweenInfo.new(0.08), {BackgroundTransparency = 0.03}):Play()
    eye.Size = UDim2.fromScale(0.1, 0.1)
    TweenService:Create(eye, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0.65, 0.42)}):Play()
    task.wait(math.max(0.2, duration - 0.18))
    local fade = TweenService:Create(overlay, TweenInfo.new(0.18), {BackgroundTransparency = 1})
    fade:Play()
    fade.Completed:Wait()
    overlay:Destroy()
end

abilityEffect.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then return end
    if payload.Type == "StaticBurst" then
        task.spawn(staticBurst, payload)
    elseif payload.Type == "JumpScare" then
        task.spawn(jumpScare, payload)
    end
end)
