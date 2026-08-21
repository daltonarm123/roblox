local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local BugConfig = require(ReplicatedStorage.Shared.BugConfig)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local submitFunction = remotes:WaitForChild("SubmitBugReport")
local adminFetchFunction = remotes:WaitForChild("FetchBugReports")
local adminActionFunction = remotes:WaitForChild("BugReportAction")

local gui = Instance.new("ScreenGui")
gui.Name = "BugReportUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Instance.new("TextButton")
openButton.AnchorPoint = Vector2.new(1, 0.5)
openButton.Position = UDim2.new(1, -18, 0.80, 0)
openButton.Size = UDim2.fromOffset(145, 40)
openButton.BackgroundColor3 = Color3.fromRGB(112, 54, 64)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "REPORT BUG"
openButton.TextSize = 15
openButton.Font = Enum.Font.GothamBlack
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 10)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(500, 430)
panel.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
panel.BackgroundTransparency = 0.02
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(225, 90, 105)
stroke.Transparency = 0.25
stroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(16, 10)
title.Size = UDim2.new(1, -72, 0, 36)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "REPORT A BUG"
title.TextColor3 = Color3.fromRGB(255, 145, 155)
title.TextSize = 22
title.Font = Enum.Font.GothamBlack
title.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 10)
close.Size = UDim2.fromOffset(38, 38)
close.BackgroundColor3 = Color3.fromRGB(42, 48, 58)
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "×"
close.TextSize = 24
close.Font = Enum.Font.GothamBold
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local intro = Instance.new("TextLabel")
intro.Position = UDim2.fromOffset(16, 52)
intro.Size = UDim2.new(1, -32, 0, 46)
intro.BackgroundTransparency = 1
intro.TextXAlignment = Enum.TextXAlignment.Left
intro.TextYAlignment = Enum.TextYAlignment.Top
intro.TextWrapped = true
intro.Text = "Tell us what happened, what you expected, and what you were doing right before it broke."
intro.TextColor3 = Color3.fromRGB(190, 202, 220)
intro.TextSize = 14
intro.Font = Enum.Font.Gotham
intro.Parent = panel

local categories = { "Gameplay", "UI", "Purchase", "Exploit", "Other" }
local categoryIndex = 1
local categoryButton = Instance.new("TextButton")
categoryButton.Position = UDim2.fromOffset(16, 106)
categoryButton.Size = UDim2.fromOffset(180, 40)
categoryButton.BackgroundColor3 = Color3.fromRGB(32, 42, 54)
categoryButton.TextColor3 = Color3.fromRGB(215, 226, 242)
categoryButton.Text = "CATEGORY: GAMEPLAY"
categoryButton.TextSize = 13
categoryButton.Font = Enum.Font.GothamBold
categoryButton.Parent = panel
Instance.new("UICorner", categoryButton).CornerRadius = UDim.new(0, 8)

local inboxButton = Instance.new("TextButton")
inboxButton.AnchorPoint = Vector2.new(1, 0)
inboxButton.Position = UDim2.new(1, -16, 0, 106)
inboxButton.Size = UDim2.fromOffset(160, 40)
inboxButton.BackgroundColor3 = Color3.fromRGB(38, 90, 70)
inboxButton.TextColor3 = Color3.new(1, 1, 1)
inboxButton.Text = "DEV BUG INBOX"
inboxButton.TextSize = 13
inboxButton.Font = Enum.Font.GothamBold
inboxButton.Visible = player:GetAttribute("BugReportAdmin") == true
inboxButton.Parent = panel
Instance.new("UICorner", inboxButton).CornerRadius = UDim.new(0, 8)

player:GetAttributeChangedSignal("BugReportAdmin"):Connect(function()
    inboxButton.Visible = player:GetAttribute("BugReportAdmin") == true
end)

local box = Instance.new("TextBox")
box.Position = UDim2.fromOffset(16, 158)
box.Size = UDim2.new(1, -32, 0, 172)
box.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
box.TextColor3 = Color3.fromRGB(240, 244, 250)
box.PlaceholderColor3 = Color3.fromRGB(125, 138, 158)
box.PlaceholderText = "Example: I stole a rare anomaly, reached my green pad, but it disappeared instead of being contained..."
box.ClearTextOnFocus = false
box.MultiLine = true
box.TextWrapped = true
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextSize = 15
box.Font = Enum.Font.Gotham
box.Text = ""
box.Parent = panel
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 9)
local boxPadding = Instance.new("UIPadding", box)
boxPadding.PaddingLeft = UDim.new(0, 12)
boxPadding.PaddingRight = UDim.new(0, 12)
boxPadding.PaddingTop = UDim.new(0, 10)
boxPadding.PaddingBottom = UDim.new(0, 10)

local count = Instance.new("TextLabel")
count.AnchorPoint = Vector2.new(1, 0)
count.Position = UDim2.new(1, -16, 0, 334)
count.Size = UDim2.fromOffset(150, 24)
count.BackgroundTransparency = 1
count.TextXAlignment = Enum.TextXAlignment.Right
count.TextColor3 = Color3.fromRGB(145, 156, 176)
count.Text = "0 / " .. BugConfig.MaxReportCharacters
count.TextSize = 12
count.Font = Enum.Font.Gotham
count.Parent = panel

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(16, 334)
status.Size = UDim2.new(1, -182, 0, 48)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(175, 188, 205)
status.Text = "Reports include your username, server ID, and device type so bugs are easier to reproduce."
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.Parent = panel

local submit = Instance.new("TextButton")
submit.AnchorPoint = Vector2.new(1, 1)
submit.Position = UDim2.new(1, -16, 1, -14)
submit.Size = UDim2.fromOffset(170, 42)
submit.BackgroundColor3 = Color3.fromRGB(180, 58, 72)
submit.TextColor3 = Color3.new(1, 1, 1)
submit.Text = "SEND REPORT"
submit.TextSize = 14
submit.Font = Enum.Font.GothamBlack
submit.Parent = panel
Instance.new("UICorner", submit).CornerRadius = UDim.new(0, 9)

local function updateCount()
    if #box.Text > BugConfig.MaxReportCharacters then
        box.Text = string.sub(box.Text, 1, BugConfig.MaxReportCharacters)
    end
    count.Text = string.format("%d / %d", #box.Text, BugConfig.MaxReportCharacters)
end
box:GetPropertyChangedSignal("Text"):Connect(updateCount)

categoryButton.Activated:Connect(function()
    categoryIndex = categoryIndex % #categories + 1
    categoryButton.Text = "CATEGORY: " .. string.upper(categories[categoryIndex])
end)

openButton.Activated:Connect(function()
    panel.Visible = true
    openButton.Visible = false
end)
close.Activated:Connect(function()
    panel.Visible = false
    openButton.Visible = true
end)

submit.Activated:Connect(function()
    submit.Active = false
    submit.Text = "SENDING..."
    status.Text = "Sending report..."

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new()
    local payload = {
        Category = categories[categoryIndex],
        Message = box.Text,
        Touch = UserInputService.TouchEnabled,
        Keyboard = UserInputService.KeyboardEnabled,
        Gamepad = UserInputService.GamepadEnabled,
        Viewport = string.format("%dx%d", math.floor(viewport.X), math.floor(viewport.Y)),
    }

    local ok, success, message = pcall(function()
        return submitFunction:InvokeServer(payload)
    end)

    if ok and success then
        status.TextColor3 = Color3.fromRGB(100, 235, 160)
        status.Text = tostring(message)
        box.Text = ""
    else
        status.TextColor3 = Color3.fromRGB(255, 135, 145)
        status.Text = ok and tostring(message) or "Could not send the report. Please try again."
    end

    submit.Active = true
    submit.Text = "SEND REPORT"
end)

-- Developer inbox ------------------------------------------------------------
local inbox = Instance.new("Frame")
inbox.AnchorPoint = Vector2.new(0.5, 0.5)
inbox.Position = UDim2.fromScale(0.5, 0.5)
inbox.Size = UDim2.fromOffset(720, 520)
inbox.BackgroundColor3 = Color3.fromRGB(7, 11, 17)
inbox.Visible = false
inbox.Parent = gui
Instance.new("UICorner", inbox).CornerRadius = UDim.new(0, 14)
local inboxStroke = Instance.new("UIStroke", inbox)
inboxStroke.Color = Color3.fromRGB(70, 200, 135)
inboxStroke.Transparency = 0.2

local inboxTitle = Instance.new("TextLabel")
inboxTitle.Position = UDim2.fromOffset(16, 10)
inboxTitle.Size = UDim2.new(1, -70, 0, 34)
inboxTitle.BackgroundTransparency = 1
inboxTitle.TextXAlignment = Enum.TextXAlignment.Left
inboxTitle.Text = "DEVELOPER BUG INBOX"
inboxTitle.TextColor3 = Color3.fromRGB(100, 245, 170)
inboxTitle.TextSize = 20
inboxTitle.Font = Enum.Font.GothamBlack
inboxTitle.Parent = inbox

local inboxClose = close:Clone()
inboxClose.Parent = inbox

local refresh = Instance.new("TextButton")
refresh.Position = UDim2.fromOffset(16, 52)
refresh.Size = UDim2.fromOffset(120, 34)
refresh.BackgroundColor3 = Color3.fromRGB(35, 82, 64)
refresh.TextColor3 = Color3.new(1, 1, 1)
refresh.Text = "REFRESH"
refresh.TextSize = 13
refresh.Font = Enum.Font.GothamBold
refresh.Parent = inbox
Instance.new("UICorner", refresh).CornerRadius = UDim.new(0, 8)

local inboxStatus = Instance.new("TextLabel")
inboxStatus.Position = UDim2.fromOffset(150, 52)
inboxStatus.Size = UDim2.new(1, -166, 0, 34)
inboxStatus.BackgroundTransparency = 1
inboxStatus.TextXAlignment = Enum.TextXAlignment.Left
inboxStatus.TextColor3 = Color3.fromRGB(160, 175, 195)
inboxStatus.Text = ""
inboxStatus.TextSize = 12
inboxStatus.Font = Enum.Font.Gotham
inboxStatus.Parent = inbox

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(16, 96)
list.Size = UDim2.new(1, -32, 1, -112)
list.BackgroundColor3 = Color3.fromRGB(12, 17, 25)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = inbox
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 9)
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local listPadding = Instance.new("UIPadding", list)
listPadding.PaddingTop = UDim.new(0, 8)
listPadding.PaddingBottom = UDim.new(0, 8)
listPadding.PaddingLeft = UDim.new(0, 8)
listPadding.PaddingRight = UDim.new(0, 8)

local function clearEntries()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function formatDate(timestamp)
    local ok, value = pcall(function()
        return os.date("%m/%d %H:%M", timestamp)
    end)
    return ok and value or tostring(timestamp)
end

local function addReportCard(report)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 128)
    card.BackgroundColor3 = report.Status == "FIXED" and Color3.fromRGB(24, 56, 43) or report.Status == "REVIEWED" and Color3.fromRGB(50, 46, 28) or Color3.fromRGB(30, 35, 45)
    card.Parent = list
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local text = Instance.new("TextLabel")
    text.Position = UDim2.fromOffset(10, 8)
    text.Size = UDim2.new(1, -190, 1, -16)
    text.BackgroundTransparency = 1
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.TextWrapped = true
    text.TextColor3 = Color3.fromRGB(225, 232, 242)
    text.TextSize = 12
    text.Font = Enum.Font.Gotham
    text.Text = string.format("[%s] %s • %s • %s\n%s\nDevice: %s  Server: %s", tostring(report.Status or "NEW"), tostring(report.Category or "Other"), tostring(report.UserName or "Unknown"), formatDate(tonumber(report.CreatedAt) or 0), tostring(report.Message or ""), tostring(report.Client and report.Client.Viewport or "unknown"), string.sub(tostring(report.JobId or "studio"), 1, 12))
    text.Parent = card

    local reviewed = Instance.new("TextButton")
    reviewed.AnchorPoint = Vector2.new(1, 0)
    reviewed.Position = UDim2.new(1, -10, 0, 14)
    reviewed.Size = UDim2.fromOffset(150, 36)
    reviewed.BackgroundColor3 = Color3.fromRGB(115, 92, 35)
    reviewed.TextColor3 = Color3.new(1, 1, 1)
    reviewed.Text = "MARK REVIEWED"
    reviewed.TextSize = 11
    reviewed.Font = Enum.Font.GothamBold
    reviewed.Parent = card
    Instance.new("UICorner", reviewed).CornerRadius = UDim.new(0, 7)

    local fixed = Instance.new("TextButton")
    fixed.AnchorPoint = Vector2.new(1, 0)
    fixed.Position = UDim2.new(1, -10, 0, 62)
    fixed.Size = UDim2.fromOffset(150, 36)
    fixed.BackgroundColor3 = Color3.fromRGB(35, 115, 74)
    fixed.TextColor3 = Color3.new(1, 1, 1)
    fixed.Text = "MARK FIXED"
    fixed.TextSize = 11
    fixed.Font = Enum.Font.GothamBold
    fixed.Parent = card
    Instance.new("UICorner", fixed).CornerRadius = UDim.new(0, 7)

    local function action(newStatus)
        local ok, success = pcall(function()
            return adminActionFunction:InvokeServer(report.Id, newStatus)
        end)
        if ok and success then
            report.Status = newStatus
            card.BackgroundColor3 = newStatus == "FIXED" and Color3.fromRGB(24, 56, 43) or Color3.fromRGB(50, 46, 28)
            local prefix = text.Text:gsub("^%[[^%]]+%]", "[" .. newStatus .. "]")
            text.Text = prefix
        end
    end

    reviewed.Activated:Connect(function() action("REVIEWED") end)
    fixed.Activated:Connect(function() action("FIXED") end)
end

local function loadInbox()
    inboxStatus.Text = "Loading reports..."
    clearEntries()
    local ok, success, reports = pcall(function()
        return adminFetchFunction:InvokeServer()
    end)

    if not ok or not success then
        inboxStatus.Text = "Could not load reports."
        return
    end

    reports = type(reports) == "table" and reports or {}
    inboxStatus.Text = string.format("%d recent report%s", #reports, #reports == 1 and "" or "s")
    for _, report in ipairs(reports) do
        addReportCard(report)
    end
end

inboxButton.Activated:Connect(function()
    if not inboxButton.Visible then return end
    panel.Visible = false
    inbox.Visible = true
    loadInbox()
end)

inboxClose.Activated:Connect(function()
    inbox.Visible = false
    panel.Visible = true
end)
refresh.Activated:Connect(loadInbox)
