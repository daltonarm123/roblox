local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.UITheme)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local stateEvent = remotes:WaitForChild("State")
local toastEvent = remotes:WaitForChild("Toast")

local function formatNumber(value)
    value = tonumber(value) or 0
    local suffixes = {
        {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"},
    }
    for _, entry in ipairs(suffixes) do
        if math.abs(value) >= entry[1] then
            local text = string.format("%.1f%s", value / entry[1], entry[2])
            return text:gsub("%.0([KMBT])", "%1")
        end
    end
    return tostring(math.floor(value))
end

local gui = Instance.new("ScreenGui")
gui.Name = "ContainmentHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 2
gui.Parent = player:WaitForChild("PlayerGui")

local stats = Instance.new("Frame")
stats.Size = UDim2.fromOffset(306, 154)
stats.Position = UDim2.fromOffset(18, 18)
stats.BackgroundColor3 = Color3.fromRGB(20, 27, 39)
stats.BackgroundTransparency = 0.06
stats.BorderSizePixel = 0
stats.Parent = gui
Theme.corner(stats, 18)
Theme.stroke(stats, Theme.Colors.Green, 2, 0.35)
Theme.gradient(stats, Color3.fromRGB(25, 36, 50), Color3.fromRGB(12, 17, 27), 90)

local padding = Theme.padding(stats, 14)
padding.PaddingTop = UDim.new(0, 11)
padding.PaddingBottom = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "CONTAINMENT HEIST"
title.TextColor3 = Color3.fromRGB(101, 255, 179)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.Parent = stats

local research = Instance.new("TextLabel")
research.Size = UDim2.new(1, 0, 0, 30)
research.Position = UDim2.fromOffset(0, 34)
research.BackgroundTransparency = 1
research.TextXAlignment = Enum.TextXAlignment.Left
research.Text = "Research: 0   (+0/s)"
research.TextColor3 = Color3.new(1, 1, 1)
research.Font = Enum.Font.GothamBold
research.TextSize = 18
research.Parent = stats

local collection = Instance.new("TextLabel")
collection.Size = UDim2.new(1, 0, 0, 24)
collection.Position = UDim2.fromOffset(0, 68)
collection.BackgroundTransparency = 1
collection.TextXAlignment = Enum.TextXAlignment.Left
collection.Text = "Contained: 0 / 3"
collection.TextColor3 = Color3.fromRGB(205, 216, 230)
collection.Font = Enum.Font.GothamMedium
collection.TextSize = 16
collection.Parent = stats

local upgrade = Instance.new("TextLabel")
upgrade.Size = UDim2.new(1, 0, 0, 42)
upgrade.Position = UDim2.fromOffset(0, 96)
upgrade.BackgroundTransparency = 1
upgrade.TextXAlignment = Enum.TextXAlignment.Left
upgrade.TextYAlignment = Enum.TextYAlignment.Top
upgrade.TextWrapped = true
upgrade.Text = "Speed: 250 R  •  Capacity: 1.8K R"
upgrade.TextColor3 = Color3.fromRGB(143, 191, 255)
upgrade.Font = Enum.Font.Gotham
upgrade.TextSize = 14
upgrade.Parent = stats

local carry = Instance.new("TextLabel")
carry.AnchorPoint = Vector2.new(0.5, 0)
carry.Position = UDim2.new(0.5, 0, 0, 24)
carry.Size = UDim2.fromOffset(460, 54)
carry.BackgroundColor3 = Color3.fromRGB(213, 54, 70)
carry.BackgroundTransparency = 0.04
carry.TextColor3 = Color3.new(1, 1, 1)
carry.Text = ""
carry.TextScaled = true
carry.Font = Enum.Font.GothamBlack
carry.Visible = false
carry.Parent = gui
Theme.corner(carry, 16)
Theme.stroke(carry, Color3.fromRGB(105, 24, 33), 2, 0.25)
local carryPadding = Theme.padding(carry, 8)

local objective = Instance.new("TextLabel")
objective.AnchorPoint = Vector2.new(0.5, 1)
objective.Position = UDim2.new(0.5, 0, 1, -20)
objective.Size = UDim2.fromOffset(630, 46)
objective.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
objective.BackgroundTransparency = 0.08
objective.TextColor3 = Color3.fromRGB(242, 247, 255)
objective.Text = ""
objective.TextWrapped = true
objective.TextSize = 15
objective.Font = Enum.Font.GothamBold
objective.Visible = false
objective.Parent = gui
Theme.corner(objective, 14)
Theme.stroke(objective, Theme.Colors.Blue, 2, 0.5)
local objectivePadding = Theme.padding(objective, 10)
objectivePadding.PaddingLeft = UDim.new(0, 16)
objectivePadding.PaddingRight = UDim.new(0, 16)

local help = Instance.new("TextButton")
help.AnchorPoint = Vector2.new(0, 1)
help.Position = UDim2.new(0, 18, 1, -18)
help.Size = UDim2.fromOffset(92, 38)
help.Text = "?  HELP"
help.TextColor3 = Theme.Colors.White
help.TextSize = 14
help.Font = Enum.Font.GothamBlack
help.Parent = gui
Theme.styleButton(help, Theme.Colors.Blue, Color3.fromRGB(91, 179, 255), 12)

local tips = {
    "STEAL: Grab anomalies from Central Containment.",
    "CONTAIN: Bring loot back to the green pad in your lab.",
    "RAID: Rival labs can hold better anomalies — watch their shields.",
    "RARE BREACHES: Gold beacon = high-value anomaly in Central.",
}
local tipIndex = 1
local objectiveToken = 0

local function fadeObjectiveOut(token)
    if token ~= objectiveToken or not objective.Visible then return end
    local tween = TweenService:Create(objective, TweenInfo.new(0.3), {
        BackgroundTransparency = 1,
        TextTransparency = 1,
    })
    tween:Play()
    tween.Completed:Once(function()
        if token == objectiveToken then
            objective.Visible = false
            objective.BackgroundTransparency = 0.08
            objective.TextTransparency = 0
        end
    end)
end

local function showObjective(text, duration)
    objectiveToken += 1
    local token = objectiveToken
    objective.Text = text
    objective.Visible = true
    objective.BackgroundTransparency = 1
    objective.TextTransparency = 1
    TweenService:Create(objective, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.08,
        TextTransparency = 0,
    }):Play()
    if duration then
        task.delay(duration, function()
            fadeObjectiveOut(token)
        end)
    end
end

local function showTipSequence()
    objectiveToken += 1
    local token = objectiveToken
    task.spawn(function()
        for i = 1, #tips do
            if token ~= objectiveToken then return end
            tipIndex = i
            objective.Text = tips[i]
            objective.Visible = true
            objective.BackgroundTransparency = 0.08
            objective.TextTransparency = 0
            task.wait(2.35)
        end
        if token == objectiveToken then
            fadeObjectiveOut(token)
        end
    end)
end

help.Activated:Connect(function()
    tipIndex = tipIndex % #tips + 1
    showObjective(tips[tipIndex], 4.5)
end)

local toastHolder = Instance.new("Frame")
toastHolder.AnchorPoint = Vector2.new(1, 0)
toastHolder.Position = UDim2.new(1, -18, 0, 18)
toastHolder.Size = UDim2.fromOffset(390, 250)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = gui
local layout = Instance.new("UIListLayout", toastHolder)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function showToast(message)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 58)
    label.BackgroundColor3 = Color3.fromRGB(18, 25, 36)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextTransparency = 1
    label.TextWrapped = true
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(message)
    label.Parent = toastHolder
    Theme.corner(label, 13)
    Theme.stroke(label, Theme.Colors.Blue, 1.5, 0.7)
    local p = Theme.padding(label, 9)
    p.PaddingLeft = UDim.new(0, 12)
    p.PaddingRight = UDim.new(0, 12)

    TweenService:Create(label, TweenInfo.new(0.2), {BackgroundTransparency = 0.08, TextTransparency = 0}):Play()
    task.delay(4.5, function()
        if label.Parent then
            local tween = TweenService:Create(label, TweenInfo.new(0.25), {BackgroundTransparency = 1, TextTransparency = 1})
            tween:Play()
            tween.Completed:Once(function()
                if label.Parent then label:Destroy() end
            end)
        end
    end)
end

local wasCarrying = false
stateEvent.OnClientEvent:Connect(function(state)
    research.Text = string.format("Research: %s   (+%s/s)", formatNumber(state.Research), formatNumber(state.Income))
    collection.Text = string.format("Contained: %d / %d   •   Lab #%d", state.SpecimenCount or 0, state.Capacity or 0, state.BaseIndex or 0)

    local speedCost = state.SpeedCost == -1 and "MAX" or (formatNumber(state.SpeedCost) .. " R")
    local capacityCost = state.CapacityCost == -1 and "MAX" or (formatNumber(state.CapacityCost) .. " R")
    upgrade.Text = string.format("Speed %s   •   Capacity %s", speedCost, capacityCost)

    local carryingNow = state.Carrying ~= nil
    if carryingNow then
        carry.Text = "CARRYING: " .. string.upper(state.Carrying) .. " — GET BACK TO YOUR LAB!"
        carry.Visible = true
        if not wasCarrying then
            showObjective("ESCAPE SECURITY → REACH YOUR GREEN CONTAINMENT PAD", 5.5)
        end
    else
        carry.Visible = false
        if wasCarrying then
            showObjective("Specimen secured. Upgrade your lab or hunt for something rarer!", 4)
        end
    end
    wasCarrying = carryingNow
end)

toastEvent.OnClientEvent:Connect(showToast)

task.delay(1.2, showTipSequence)

local camera = workspace.CurrentCamera
local function resize()
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    if viewport.X < 760 then
        stats.Size = UDim2.fromOffset(260, 146)
        carry.Size = UDim2.new(0.9, 0, 0, 50)
        objective.Size = UDim2.new(0.82, 0, 0, 48)
        toastHolder.Size = UDim2.new(0.86, 0, 0, 230)
        help.Size = UDim2.fromOffset(76, 36)
    else
        stats.Size = UDim2.fromOffset(306, 154)
        carry.Size = UDim2.fromOffset(460, 54)
        objective.Size = UDim2.fromOffset(630, 46)
        toastHolder.Size = UDim2.fromOffset(390, 250)
        help.Size = UDim2.fromOffset(92, 38)
    end
end

resize()
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end
