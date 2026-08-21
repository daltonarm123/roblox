local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local NumberFormat = require(ReplicatedStorage.Shared.NumberFormat)
local remotes = ReplicatedStorage:WaitForChild("JunkyardRemotes")
local stateEvent = remotes:WaitForChild("State")
local actionEvent = remotes:WaitForChild("Action")
local requestState = remotes:WaitForChild("RequestState")

local gui = Instance.new("ScreenGui")
gui.Name = "JunkyardHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function rounded(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = object
end

local function stroke(object, transparency)
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 255, 255)
    uiStroke.Transparency = transparency or 0.8
    uiStroke.Thickness = 1
    uiStroke.Parent = object
end

local stats = Instance.new("Frame")
stats.Name = "Stats"
stats.AnchorPoint = Vector2.new(0.5, 0)
stats.Position = UDim2.new(0.5, 0, 0, 14)
stats.Size = UDim2.new(0.88, 0, 0, 84)
stats.BackgroundColor3 = Color3.fromRGB(20, 24, 28)
stats.BackgroundTransparency = 0.08
stats.Parent = gui
rounded(stats, 16)
stroke(stats, 0.72)

local statsLayout = Instance.new("UIGridLayout")
statsLayout.CellPadding = UDim2.new(0, 6, 0, 6)
statsLayout.CellSize = UDim2.new(0.25, -5, 1, -12)
statsLayout.FillDirectionMaxCells = 4
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statsLayout.Parent = stats

local function makeStat(title)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Parent = stats

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.42, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(170, 178, 186)
    titleLabel.TextScaled = true
    titleLabel.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Position = UDim2.new(0, 0, 0.42, 0)
    valueLabel.Size = UDim2.new(1, 0, 0.58, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = "0"
    valueLabel.TextColor3 = Color3.fromRGB(245, 247, 250)
    valueLabel.TextScaled = true
    valueLabel.Parent = frame
    return valueLabel
end

local cashLabel = makeStat("CASH")
local scrapLabel = makeStat("SCRAP")
local rebirthLabel = makeStat("REBIRTHS")
local passiveLabel = makeStat("AUTO / 2 SEC")

local feedback = Instance.new("TextLabel")
feedback.Name = "Feedback"
feedback.AnchorPoint = Vector2.new(0.5, 0)
feedback.Position = UDim2.new(0.5, 0, 0, 108)
feedback.Size = UDim2.new(0.7, 0, 0, 38)
feedback.BackgroundColor3 = Color3.fromRGB(20, 24, 28)
feedback.BackgroundTransparency = 0.15
feedback.Font = Enum.Font.GothamBold
feedback.Text = "Grab scrap around the yard, sell it, then automate the crusher."
feedback.TextColor3 = Color3.fromRGB(235, 238, 242)
feedback.TextScaled = true
feedback.TextWrapped = true
feedback.Parent = gui
rounded(feedback, 10)

local panel = Instance.new("Frame")
panel.Name = "Actions"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -18)
panel.Size = UDim2.new(0.92, 0, 0, 158)
panel.BackgroundColor3 = Color3.fromRGB(20, 24, 28)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
rounded(panel, 16)
stroke(panel, 0.72)

local grid = Instance.new("UIGridLayout")
grid.CellPadding = UDim2.new(0.012, 0, 0, 8)
grid.CellSize = UDim2.new(0.238, 0, 0, 67)
grid.FillDirectionMaxCells = 4
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Center
grid.Parent = panel

local function makeButton(name, text, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.AutoButtonColor = true
    button.BackgroundColor3 = color
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.TextWrapped = true
    button.Parent = panel
    rounded(button, 12)
    stroke(button, 0.7)
    return button
end

local collectButton = makeButton("Collect", "GRAB SCRAP", Color3.fromRGB(80, 127, 174))
local sellButton = makeButton("Sell", "SELL ALL", Color3.fromRGB(58, 155, 91))
local pickupButton = makeButton("PickupPower", "PICKUP POWER", Color3.fromRGB(75, 133, 205))
local valueButton = makeButton("SellBoost", "SCRAP VALUE", Color3.fromRGB(77, 168, 111))
local storageButton = makeButton("Storage", "STORAGE", Color3.fromRGB(152, 94, 184))
local autoButton = makeButton("AutoCrusher", "AUTO CRUSHER", Color3.fromRGB(201, 132, 40))
local rebirthButton = makeButton("Rebirth", "REBIRTH", Color3.fromRGB(190, 67, 68))
local infoButton = makeButton("Info", "JUNKYARD EMPIRE\nMVP v0.1", Color3.fromRGB(63, 68, 74))
infoButton.AutoButtonColor = false

local currentState

local function formatCost(cost)
    if not cost or cost < 0 then
        return "MAX"
    end
    return "$" .. NumberFormat.Compact(cost)
end

local function render(state)
    if not state then
        return
    end
    currentState = state

    cashLabel.Text = "$" .. NumberFormat.Compact(state.Cash)
    scrapLabel.Text = string.format("%s / %s", NumberFormat.Compact(state.Scrap), NumberFormat.Compact(state.Capacity))
    rebirthLabel.Text = tostring(state.Rebirths)
    passiveLabel.Text = "$" .. NumberFormat.Compact(state.PassivePerTick or 0)

    local upgrades = state.Upgrades or {}
    local costs = state.NextUpgradeCosts or {}
    pickupButton.Text = string.format("PICKUP Lv.%d\n%s", upgrades.PickupPower or 0, formatCost(costs.PickupPower))
    valueButton.Text = string.format("VALUE Lv.%d\n%s", upgrades.SellBoost or 0, formatCost(costs.SellBoost))
    storageButton.Text = string.format("STORAGE Lv.%d\n%s", upgrades.Storage or 0, formatCost(costs.Storage))
    autoButton.Text = string.format("AUTO Lv.%d\n%s", upgrades.AutoCrusher or 0, formatCost(costs.AutoCrusher))
    rebirthButton.Text = string.format("REBIRTH\nNeed $%s", NumberFormat.Compact(state.RebirthRequirement or 0))
end

local function send(action, argument)
    actionEvent:FireServer(action, argument)
end

collectButton.Activated:Connect(function()
    send("CollectScrap")
end)

sellButton.Activated:Connect(function()
    send("SellScrap")
end)

pickupButton.Activated:Connect(function()
    send("BuyUpgrade", "PickupPower")
end)

valueButton.Activated:Connect(function()
    send("BuyUpgrade", "SellBoost")
end)

storageButton.Activated:Connect(function()
    send("BuyUpgrade", "Storage")
end)

autoButton.Activated:Connect(function()
    send("BuyUpgrade", "AutoCrusher")
end)

rebirthButton.Activated:Connect(function()
    send("Rebirth")
end)

stateEvent.OnClientEvent:Connect(function(state, message, success)
    render(state)
    if message then
        feedback.Text = message
        feedback.TextColor3 = success == false and Color3.fromRGB(255, 145, 145) or Color3.fromRGB(167, 255, 184)
        task.delay(2.5, function()
            if feedback.Text == message then
                feedback.Text = "Grab scrap → Sell → Upgrade → Automate → Rebirth"
                feedback.TextColor3 = Color3.fromRGB(235, 238, 242)
            end
        end)
    end
end)

local success, initialState = pcall(function()
    return requestState:InvokeServer()
end)
if success then
    render(initialState)
end
