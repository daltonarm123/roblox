local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Theme = require(script.Parent.UITheme)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local shopRequest = remotes:WaitForChild("ShopRequest")
local shopState = remotes:WaitForChild("ShopState")
local abilityRequest = remotes:WaitForChild("AbilityRequest")
local abilityState = remotes:WaitForChild("AbilityState")

local gui = Instance.new("ScreenGui")
gui.Name = "LabShopUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Theme.makeOpenButton(gui, "LAB SHOP", "⚙", Theme.Colors.Blue, UDim2.new(1, -18, 0.66, 0))
local overlay, panel, panelScale = Theme.makeOverlay(gui, UDim2.fromOffset(760, 560))

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 86)
header.BackgroundColor3 = Theme.Colors.Blue
header.ZIndex = 22
header.Parent = panel
Theme.corner(header, 22)
Theme.gradient(header, Color3.fromRGB(88, 184, 255), Color3.fromRGB(49, 119, 230), 90)

local headerMask = Instance.new("Frame")
headerMask.Position = UDim2.new(0, 0, 1, -22)
headerMask.Size = UDim2.new(1, 0, 0, 22)
headerMask.BorderSizePixel = 0
headerMask.BackgroundColor3 = Color3.fromRGB(49, 119, 230)
headerMask.ZIndex = 22
headerMask.Parent = header

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(22, 12)
title.Size = UDim2.new(0.55, 0, 0, 34)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "LAB UPGRADE STATION"
title.TextColor3 = Theme.Colors.White
title.TextSize = 24
title.Font = Enum.Font.GothamBlack
title.ZIndex = 24
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(23, 47)
subtitle.Size = UDim2.new(0.6, 0, 0, 22)
subtitle.BackgroundTransparency = 1
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Spend Research • defend your lab • unleash chaos"
subtitle.TextColor3 = Color3.fromRGB(222, 240, 255)
subtitle.TextSize = 13
subtitle.Font = Enum.Font.GothamBold
subtitle.ZIndex = 24
subtitle.Parent = header

local researchPill = Instance.new("TextLabel")
researchPill.AnchorPoint = Vector2.new(1, 0.5)
researchPill.Position = UDim2.new(1, -74, 0.5, 0)
researchPill.Size = UDim2.fromOffset(188, 44)
researchPill.BackgroundColor3 = Theme.Colors.White
researchPill.TextColor3 = Theme.Colors.BlueDark
researchPill.Text = "R  0"
researchPill.TextSize = 18
researchPill.Font = Enum.Font.GothamBlack
researchPill.ZIndex = 24
researchPill.Parent = header
Theme.corner(researchPill, 999)
Theme.stroke(researchPill, Theme.Colors.BlueDark, 2, 0.45)

local close = Theme.makeCloseButton(header)

local tabBar = Instance.new("Frame")
tabBar.Position = UDim2.fromOffset(20, 100)
tabBar.Size = UDim2.new(1, -40, 0, 48)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 22
tabBar.Parent = panel
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 10)
tabLayout.Parent = tabBar

local contentHolder = Instance.new("Frame")
contentHolder.Position = UDim2.fromOffset(20, 160)
contentHolder.Size = UDim2.new(1, -40, 1, -180)
contentHolder.BackgroundTransparency = 1
contentHolder.ZIndex = 22
contentHolder.Parent = panel

local pages = {}
local tabs = {}
local activeTab = "UPGRADES"

local function makePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 5
    page.ScrollBarImageColor3 = Theme.Colors.Blue
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.ZIndex = 23
    page.Parent = contentHolder

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.5, -8, 0, 158)
    grid.CellPadding = UDim2.fromOffset(14, 14)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = page

    pages[name] = page
    return page
end

local function setTab(name)
    activeTab = name
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(tabs) do
        local active = tabName == name
        button.BackgroundColor3 = active and Theme.Colors.Blue or Color3.fromRGB(220, 229, 242)
        button.TextColor3 = active and Theme.Colors.White or Theme.Colors.Ink
    end
end

for _, name in ipairs({"UPGRADES", "DEFENSE", "ABILITIES"}) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.fromOffset(160, 42)
    tab.Text = name
    tab.TextSize = 14
    tab.Font = Enum.Font.GothamBlack
    tab.ZIndex = 23
    tab.Parent = tabBar
    Theme.styleButton(tab, Color3.fromRGB(220, 229, 242), Color3.fromRGB(232, 239, 249), 13)
    tabs[name] = tab
    tab.Activated:Connect(function()
        setTab(name)
    end)
end

local upgradesPage = makePage("UPGRADES")
local defensePage = makePage("DEFENSE")
local abilitiesPage = makePage("ABILITIES")

local function formatResearch(value)
    value = math.floor(tonumber(value) or 0)
    if value >= 1000000 then return string.format("%.1fM", value / 1000000):gsub("%.0M", "M") end
    if value >= 1000 then return string.format("%.1fK", value / 1000):gsub("%.0K", "K") end
    return tostring(value)
end

local function costText(cost)
    if cost == -1 then return "MAXED" end
    return formatResearch(cost) .. " R"
end

local function makeCard(parent, icon, titleText, accent)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Colors.White
    card.ZIndex = 23
    card.Parent = parent
    Theme.corner(card, 18)
    Theme.stroke(card, accent, 2, 0.38)

    local iconBubble = Instance.new("TextLabel")
    iconBubble.Position = UDim2.fromOffset(14, 14)
    iconBubble.Size = UDim2.fromOffset(54, 54)
    iconBubble.BackgroundColor3 = accent
    iconBubble.Text = icon
    iconBubble.TextColor3 = Theme.Colors.White
    iconBubble.TextScaled = true
    iconBubble.Font = Enum.Font.GothamBlack
    iconBubble.ZIndex = 24
    iconBubble.Parent = card
    Theme.corner(iconBubble, 15)
    Theme.stroke(iconBubble, Theme.Colors.Ink, 2, 0.7)
    Theme.padding(iconBubble, 9)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Position = UDim2.fromOffset(80, 13)
    titleLabel.Size = UDim2.new(1, -94, 0, 28)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Theme.Colors.Ink
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.ZIndex = 24
    titleLabel.Parent = card

    local info = Instance.new("TextLabel")
    info.Position = UDim2.fromOffset(80, 42)
    info.Size = UDim2.new(1, -94, 0, 44)
    info.BackgroundTransparency = 1
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.TextWrapped = true
    info.Text = "Loading..."
    info.TextColor3 = Theme.Colors.Muted
    info.TextSize = 12
    info.Font = Enum.Font.GothamBold
    info.ZIndex = 24
    info.Parent = card

    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(0, 1)
    button.Position = UDim2.new(0, 14, 1, -12)
    button.Size = UDim2.new(1, -28, 0, 44)
    button.Text = "LOADING"
    button.TextColor3 = Theme.Colors.White
    button.TextSize = 14
    button.Font = Enum.Font.GothamBlack
    button.ZIndex = 24
    button.Parent = card
    Theme.styleButton(button, accent, accent:Lerp(Theme.Colors.White, 0.12), 12)

    return {Frame = card, Info = info, Button = button, Accent = accent}
end

local cards = {
    Speed = makeCard(upgradesPage, ">>", "SPEED", Theme.Colors.Blue),
    Capacity = makeCard(upgradesPage, "+1", "CAPACITY", Theme.Colors.Purple),
    Income = makeCard(upgradesPage, "R+", "RESEARCH AMP", Theme.Colors.Green),
    ShieldTech = makeCard(defensePage, "S", "SHIELD TECH", Theme.Colors.Cyan),
    Emergency = makeCard(defensePage, "60", "EMERGENCY SHIELD", Theme.Colors.Cyan),
    Lockdown = makeCard(defensePage, "L", "LAB LOCKDOWN", Theme.Colors.Red),
    StaticBurst = makeCard(abilitiesPage, "ZAP", "STATIC BURST", Theme.Colors.Cyan),
    JumpScare = makeCard(abilitiesPage, "!", "BREACH SCARE", Theme.Colors.Orange),
    Cloak = makeCard(abilitiesPage, "Ø", "PHASE CLOAK", Theme.Colors.Purple),
}

cards.Speed.Button.Activated:Connect(function() shopRequest:FireServer("Speed") end)
cards.Capacity.Button.Activated:Connect(function() shopRequest:FireServer("Capacity") end)
cards.Income.Button.Activated:Connect(function() shopRequest:FireServer("Income") end)
cards.ShieldTech.Button.Activated:Connect(function() shopRequest:FireServer("ShieldTech") end)

cards.Emergency.Button.Text = "USE CYAN TERMINAL IN YOUR LAB"
cards.Emergency.Button.Active = false
cards.Emergency.Button.AutoButtonColor = false
cards.Emergency.Info.Text = "Blocks rival raids for 60 seconds. Base cooldown: 5 minutes. Shield Tech reduces it."

cards.Lockdown.Button.Text = "USE RED TERMINAL IN YOUR LAB"
cards.Lockdown.Button.Active = false
cards.Lockdown.Button.AutoButtonColor = false
cards.Lockdown.Info.Text = "Hard-lock your lab for up to 3 minutes. Releasing it starts a 1-hour cooldown."

for _, id in ipairs({"StaticBurst", "JumpScare", "Cloak"}) do
    cards[id].Button.Activated:Connect(function()
        abilityRequest:FireServer(id)
    end)
end

local latestResearch = 0
local latestShop = nil
local latestAbilities = nil

local function renderUpgrade(card, level, maxLevel, description, cost)
    card.Info.Text = string.format("Lv.%d / %d\n%s", level, maxLevel, description)
    card.Button.Text = cost == -1 and "MAX LEVEL" or ("UPGRADE  •  " .. costText(cost))
    card.Button.Active = cost ~= -1
end

local function render()
    researchPill.Text = "R  " .. formatResearch(latestResearch)

    if latestShop then
        local speed = latestShop.Speed
        renderUpgrade(cards.Speed, speed.Level, speed.MaxLevel, "+1.15 movement speed each level", speed.Cost)

        local capacity = latestShop.Capacity
        renderUpgrade(cards.Capacity, capacity.Level, capacity.MaxLevel, string.format("%d containment slots • next adds +1", capacity.Slots), capacity.Cost)

        local income = latestShop.Income
        renderUpgrade(cards.Income, income.Level, income.MaxLevel, string.format("+%d%% passive Research income", income.BonusPercent), income.Cost)

        local shield = latestShop.ShieldTech
        renderUpgrade(cards.ShieldTech, shield.Level, shield.MaxLevel, string.format("Emergency shield cooldown: %ds", shield.Cooldown), shield.Cost)
    end

    if latestAbilities then
        for _, id in ipairs({"StaticBurst", "JumpScare", "Cloak"}) do
            local state = latestAbilities[id]
            local config = Config.Abilities[id]
            local card = cards[id]
            if state and config then
                card.Info.Text = config.Description
                if (state.CooldownRemaining or 0) > 0 then
                    card.Button.Text = string.format("COOLDOWN  •  %ds", state.CooldownRemaining)
                    card.Button.Active = false
                elseif (state.Charges or 0) > 0 then
                    card.Button.Text = string.format("USE FREE CHARGE  •  %d STORED", state.Charges)
                    card.Button.Active = true
                else
                    card.Button.Text = string.format("USE  •  %s R", formatResearch(config.ResearchCost))
                    card.Button.Active = true
                end
            end
        end
    end
end

shopState.OnClientEvent:Connect(function(state)
    latestShop = state
    latestResearch = state.Research or latestResearch
    render()
end)

abilityState.OnClientEvent:Connect(function(state)
    latestAbilities = state.Abilities
    latestResearch = state.Research or latestResearch
    render()
end)

openButton.Activated:Connect(function()
    openButton.Visible = false
    Theme.openOverlay(overlay, panelScale)
end)

close.Activated:Connect(function()
    Theme.closeOverlay(overlay, panelScale)
    task.delay(0.14, function()
        openButton.Visible = true
    end)
end)

setTab(activeTab)

local camera = workspace.CurrentCamera
local responsiveScale = Instance.new("UIScale")
responsiveScale.Parent = panel
local function resize()
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    responsiveScale.Scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 680), 0.72, 1)
end
resize()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
