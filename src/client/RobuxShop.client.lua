local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Theme = require(script.Parent.UITheme)
local player = Players.LocalPlayer
local monetization = Config.Monetization
local passes = monetization.GamePasses
local products = monetization.DeveloperProducts
local suggested = monetization.SuggestedPrices

local gui = Instance.new("ScreenGui")
gui.Name = "RobuxShopUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 11
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Theme.makeOpenButton(gui, "R$ SHOP", "R$", Theme.Colors.Green, UDim2.new(1, -18, 0.52, 0))
local overlay, panel, panelScale = Theme.makeOverlay(gui, UDim2.fromOffset(820, 570))

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 92)
header.BackgroundColor3 = Theme.Colors.Green
header.ZIndex = 22
header.Parent = panel
Theme.corner(header, 22)
Theme.gradient(header, Color3.fromRGB(85, 231, 140), Color3.fromRGB(37, 159, 91), 90)

local headerMask = Instance.new("Frame")
headerMask.Position = UDim2.new(0, 0, 1, -22)
headerMask.Size = UDim2.new(1, 0, 0, 22)
headerMask.BorderSizePixel = 0
headerMask.BackgroundColor3 = Color3.fromRGB(37, 159, 91)
headerMask.ZIndex = 22
headerMask.Parent = header

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(22, 12)
title.Size = UDim2.new(0.6, 0, 0, 36)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "CONTAINMENT STORE"
title.TextColor3 = Theme.Colors.White
title.TextSize = 27
title.Font = Enum.Font.GothamBlack
title.ZIndex = 24
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(24, 50)
subtitle.Size = UDim2.new(0.7, 0, 0, 22)
subtitle.BackgroundTransparency = 1
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Permanent perks, boosts, and harmless chaos toys"
subtitle.TextColor3 = Color3.fromRGB(224, 255, 235)
subtitle.TextSize = 13
subtitle.Font = Enum.Font.GothamBold
subtitle.ZIndex = 24
subtitle.Parent = header

local robuxBadge = Instance.new("TextLabel")
robuxBadge.AnchorPoint = Vector2.new(1, 0.5)
robuxBadge.Position = UDim2.new(1, -74, 0.5, 0)
robuxBadge.Size = UDim2.fromOffset(160, 44)
robuxBadge.BackgroundColor3 = Theme.Colors.White
robuxBadge.Text = "R$  STORE"
robuxBadge.TextColor3 = Theme.Colors.GreenDark
robuxBadge.TextSize = 17
robuxBadge.Font = Enum.Font.GothamBlack
robuxBadge.ZIndex = 24
robuxBadge.Parent = header
Theme.corner(robuxBadge, 999)
Theme.stroke(robuxBadge, Theme.Colors.GreenDark, 2, 0.5)

local close = Theme.makeCloseButton(header)

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(22, 102)
status.Size = UDim2.new(1, -44, 0, 32)
status.BackgroundColor3 = Color3.fromRGB(236, 244, 250)
status.TextColor3 = Theme.Colors.Muted
status.Text = "Studio preview: planned prices shown until Roblox product IDs are created."
status.TextWrapped = true
status.TextSize = 12
status.Font = Enum.Font.GothamBold
status.ZIndex = 22
status.Parent = panel
Theme.corner(status, 10)

local tabBar = Instance.new("Frame")
tabBar.Position = UDim2.fromOffset(22, 144)
tabBar.Size = UDim2.new(1, -44, 0, 44)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 22
tabBar.Parent = panel
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 8)
tabLayout.Parent = tabBar

local pageHolder = Instance.new("Frame")
pageHolder.Position = UDim2.fromOffset(22, 198)
pageHolder.Size = UDim2.new(1, -44, 1, -218)
pageHolder.BackgroundTransparency = 1
pageHolder.ZIndex = 22
pageHolder.Parent = panel

local pages = {}
local tabs = {}

local function makePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 5
    page.ScrollBarImageColor3 = Theme.Colors.Green
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.ZIndex = 23
    page.Parent = pageHolder

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.fromOffset(244, 166)
    grid.CellPadding = UDim2.fromOffset(12, 12)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = page
    pages[name] = page
    return page
end

for _, name in ipairs({"FEATURED", "BOOSTS", "CHAOS", "PREMIUM"}) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.fromOffset(150, 40)
    tab.Text = name
    tab.TextSize = 13
    tab.Font = Enum.Font.GothamBlack
    tab.ZIndex = 23
    tab.Parent = tabBar
    Theme.styleButton(tab, Color3.fromRGB(220, 232, 239), Color3.fromRGB(234, 242, 247), 12)
    tabs[name] = tab
end

local featured = makePage("FEATURED")
local boosts = makePage("BOOSTS")
local chaos = makePage("CHAOS")
local premium = makePage("PREMIUM")

local function configured(id)
    return type(id) == "number" and id > 0
end

local defs = {
    DoubleResearch = {
        Name = "2× RESEARCH", Icon = "2X", Description = "Permanent passive Research multiplier.", Badge = "POPULAR",
        Id = passes.DoubleResearch, InfoType = Enum.InfoType.GamePass, Price = suggested.DoubleResearch,
    },
    VIP = {
        Name = "VIP ACCESS", Icon = "VIP", Description = "+10% movement speed and future VIP perks.", Badge = "PERMANENT",
        Id = passes.VIP, InfoType = Enum.InfoType.GamePass, Price = suggested.VIP,
    },
    Research5000 = {
        Name = "+5K RESEARCH", Icon = "R+", Description = "Quick Research top-up for upgrades.",
        Id = products.Research5000, InfoType = Enum.InfoType.Product, Price = suggested.Research5000,
    },
    Research25000 = {
        Name = "+25K RESEARCH", Icon = "R++", Description = "Bigger Research bundle with better value.", Badge = "BEST VALUE",
        Id = products.Research25000, InfoType = Enum.InfoType.Product, Price = suggested.Research25000,
    },
    Shield = {
        Name = "SHIELD RECHARGE", Icon = "S", Description = "Reset the emergency shield cooldown now.",
        Id = products.InstantShieldRecharge, InfoType = Enum.InfoType.Product, Price = suggested.InstantShieldRecharge,
    },
    Static = {
        Name = "+1 STATIC BURST", Icon = "ZAP", Description = "Store one free rival-screen scramble.",
        Id = products.StaticBurstCharge, InfoType = Enum.InfoType.Product, Price = suggested.StaticBurstCharge,
    },
    Scare = {
        Name = "+1 BREACH SCARE", Icon = "!", Description = "Store one harmless server-wide scare.",
        Id = products.JumpScareCharge, InfoType = Enum.InfoType.Product, Price = suggested.JumpScareCharge,
    },
    Cloak = {
        Name = "+1 PHASE CLOAK", Icon = "Ø", Description = "Store one 15-second cloak charge.",
        Id = products.CloakCharge, InfoType = Enum.InfoType.Product, Price = suggested.CloakCharge,
    },
}

local livePrices = {}
local cardsByKey = {}

local function displayPrice(def)
    return livePrices[def] or def.Price
end

local function purchase(def)
    if not configured(def.Id) then
        status.Text = string.format("%s is planned at %d R$. It becomes purchasable after we create its Roblox product.", def.Name, def.Price)
        return
    end
    if def.InfoType == Enum.InfoType.GamePass then
        MarketplaceService:PromptGamePassPurchase(player, def.Id)
    else
        MarketplaceService:PromptProductPurchase(player, def.Id)
    end
end

local function makeProductCard(page, key, accent)
    local def = defs[key]
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Colors.White
    card.ZIndex = 23
    card.Parent = page
    Theme.corner(card, 18)
    Theme.stroke(card, accent, 2, 0.4)

    local icon = Instance.new("TextLabel")
    icon.Position = UDim2.fromOffset(12, 12)
    icon.Size = UDim2.fromOffset(54, 54)
    icon.BackgroundColor3 = accent
    icon.Text = def.Icon
    icon.TextColor3 = Theme.Colors.White
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBlack
    icon.ZIndex = 24
    icon.Parent = card
    Theme.corner(icon, 15)
    Theme.padding(icon, 10)

    local name = Instance.new("TextLabel")
    name.Position = UDim2.fromOffset(76, 11)
    name.Size = UDim2.new(1, -86, 0, 28)
    name.BackgroundTransparency = 1
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Text = def.Name
    name.TextColor3 = Theme.Colors.Ink
    name.TextSize = 15
    name.Font = Enum.Font.GothamBlack
    name.ZIndex = 24
    name.Parent = card

    if def.Badge then
        local badge = Theme.makeBadge(card, def.Badge, def.Badge == "BEST VALUE" and Theme.Colors.Gold or accent, UDim2.fromOffset(92, 23), UDim2.new(1, -102, 0, 44))
        badge.TextSize = 10
        badge.ZIndex = 25
    end

    local desc = Instance.new("TextLabel")
    desc.Position = UDim2.fromOffset(12, 72)
    desc.Size = UDim2.new(1, -24, 0, 38)
    desc.BackgroundTransparency = 1
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Text = def.Description
    desc.TextColor3 = Theme.Colors.Muted
    desc.TextSize = 11
    desc.Font = Enum.Font.GothamBold
    desc.ZIndex = 24
    desc.Parent = card

    local buy = Instance.new("TextButton")
    buy.AnchorPoint = Vector2.new(0, 1)
    buy.Position = UDim2.new(0, 12, 1, -10)
    buy.Size = UDim2.new(1, -24, 0, 42)
    buy.TextColor3 = Theme.Colors.White
    buy.TextSize = 13
    buy.Font = Enum.Font.GothamBlack
    buy.ZIndex = 24
    buy.Parent = card
    Theme.styleButton(buy, accent, accent:Lerp(Theme.Colors.White, 0.12), 11)

    local function redraw()
        local price = displayPrice(def)
        if configured(def.Id) then
            buy.Text = string.format("BUY  •  %d R$", price)
        else
            buy.Text = string.format("%d R$  •  PREVIEW", price)
        end
    end
    redraw()
    buy.Activated:Connect(function() purchase(def) end)

    cardsByKey[key] = cardsByKey[key] or {}
    table.insert(cardsByKey[key], redraw)
end

makeProductCard(featured, "DoubleResearch", Theme.Colors.Green)
makeProductCard(featured, "VIP", Theme.Colors.Purple)
makeProductCard(featured, "Research25000", Theme.Colors.Gold)
makeProductCard(featured, "Shield", Theme.Colors.Cyan)

makeProductCard(boosts, "Research5000", Theme.Colors.Green)
makeProductCard(boosts, "Research25000", Theme.Colors.Gold)
makeProductCard(boosts, "Shield", Theme.Colors.Cyan)

makeProductCard(chaos, "Static", Theme.Colors.Cyan)
makeProductCard(chaos, "Scare", Theme.Colors.Orange)
makeProductCard(chaos, "Cloak", Theme.Colors.Purple)

makeProductCard(premium, "DoubleResearch", Theme.Colors.Green)
makeProductCard(premium, "VIP", Theme.Colors.Purple)

local seasonCard = Instance.new("Frame")
seasonCard.BackgroundColor3 = Color3.fromRGB(255, 246, 222)
seasonCard.ZIndex = 23
seasonCard.Parent = premium
Theme.corner(seasonCard, 18)
Theme.stroke(seasonCard, Theme.Colors.Gold, 2, 0.25)
local seasonIcon = Instance.new("TextLabel")
seasonIcon.Position = UDim2.fromOffset(12, 12)
seasonIcon.Size = UDim2.fromOffset(54, 54)
seasonIcon.BackgroundColor3 = Theme.Colors.Gold
seasonIcon.Text = "S1"
seasonIcon.TextColor3 = Theme.Colors.White
seasonIcon.TextScaled = true
seasonIcon.Font = Enum.Font.GothamBlack
seasonIcon.ZIndex = 24
seasonIcon.Parent = seasonCard
Theme.corner(seasonIcon, 15)
Theme.padding(seasonIcon, 10)
local seasonTitle = Instance.new("TextLabel")
seasonTitle.Position = UDim2.fromOffset(76, 12)
seasonTitle.Size = UDim2.new(1, -88, 0, 30)
seasonTitle.BackgroundTransparency = 1
seasonTitle.TextXAlignment = Enum.TextXAlignment.Left
seasonTitle.Text = "SEASON PREMIUM"
seasonTitle.TextColor3 = Theme.Colors.Ink
seasonTitle.TextSize = 15
seasonTitle.Font = Enum.Font.GothamBlack
seasonTitle.ZIndex = 24
seasonTitle.Parent = seasonCard
local seasonDesc = Instance.new("TextLabel")
seasonDesc.Position = UDim2.fromOffset(12, 72)
seasonDesc.Size = UDim2.new(1, -24, 0, 38)
seasonDesc.BackgroundTransparency = 1
seasonDesc.TextWrapped = true
seasonDesc.Text = "Premium rewards live in the Season 1 menu so you cannot accidentally buy the track twice."
seasonDesc.TextColor3 = Theme.Colors.Muted
seasonDesc.TextSize = 11
seasonDesc.Font = Enum.Font.GothamBold
seasonDesc.ZIndex = 24
seasonDesc.Parent = seasonCard
local seasonButton = Instance.new("TextButton")
seasonButton.AnchorPoint = Vector2.new(0, 1)
seasonButton.Position = UDim2.new(0, 12, 1, -10)
seasonButton.Size = UDim2.new(1, -24, 0, 42)
seasonButton.Text = string.format("OPEN SEASON 1  •  %d R$ PLANNED", Config.Season.SuggestedPremiumPrice)
seasonButton.TextColor3 = Theme.Colors.White
seasonButton.TextSize = 12
seasonButton.Font = Enum.Font.GothamBlack
seasonButton.ZIndex = 24
seasonButton.Parent = seasonCard
Theme.styleButton(seasonButton, Theme.Colors.Gold, Color3.fromRGB(255, 205, 91), 11)
seasonButton.Activated:Connect(function()
    status.Text = "Close the store and tap SEASON 1 to view the premium reward track."
end)

local function setTab(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(tabs) do
        local active = tabName == name
        button.BackgroundColor3 = active and Theme.Colors.Green or Color3.fromRGB(220, 232, 239)
        button.TextColor3 = active and Theme.Colors.White or Theme.Colors.Ink
    end
end

for name, button in pairs(tabs) do
    button.Activated:Connect(function() setTab(name) end)
end

for key, def in pairs(defs) do
    if configured(def.Id) then
        task.spawn(function()
            local ok, info = pcall(function()
                return MarketplaceService:GetProductInfoAsync(def.Id, def.InfoType)
            end)
            if ok and info and info.PriceInRobux then
                livePrices[def] = info.PriceInRobux
                for _, redraw in ipairs(cardsByKey[key] or {}) do redraw() end
            end
        end)
    end
end

openButton.Activated:Connect(function()
    openButton.Visible = false
    Theme.openOverlay(overlay, panelScale)
end)

close.Activated:Connect(function()
    Theme.closeOverlay(overlay, panelScale)
    task.delay(0.14, function() openButton.Visible = true end)
end)

setTab("FEATURED")

local camera = workspace.CurrentCamera
local responsiveScale = Instance.new("UIScale")
responsiveScale.Parent = panel
local function resize()
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    responsiveScale.Scale = math.clamp(math.min(viewport.X / 960, viewport.Y / 700), 0.68, 1)
end
resize()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
