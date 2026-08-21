local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Theme = require(script.Parent.UITheme)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local seasonState = remotes:WaitForChild("SeasonState")

local gui = Instance.new("ScreenGui")
gui.Name = "SeasonPassUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 12
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Theme.makeOpenButton(gui, "SEASON 1", "S1", Theme.Colors.Gold, UDim2.new(1, -18, 0.38, 0))
local overlay, panel, panelScale = Theme.makeOverlay(gui, UDim2.fromOffset(860, 610))

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 102)
header.BackgroundColor3 = Theme.Colors.Gold
header.ZIndex = 22
header.Parent = panel
Theme.corner(header, 22)
Theme.gradient(header, Color3.fromRGB(255, 202, 74), Color3.fromRGB(244, 123, 52), 90)

local headerMask = Instance.new("Frame")
headerMask.Position = UDim2.new(0, 0, 1, -22)
headerMask.Size = UDim2.new(1, 0, 0, 22)
headerMask.BorderSizePixel = 0
headerMask.BackgroundColor3 = Color3.fromRGB(244, 123, 52)
headerMask.ZIndex = 22
headerMask.Parent = header

local seasonTag = Theme.makeBadge(header, "SEASON 1", Color3.fromRGB(112, 65, 28), UDim2.fromOffset(92, 26), UDim2.fromOffset(22, 14))
seasonTag.ZIndex = 24

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(22, 43)
title.Size = UDim2.new(0.62, 0, 0, 36)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = Config.Season.Name
title.TextColor3 = Theme.Colors.White
title.TextSize = 27
title.Font = Enum.Font.GothamBlack
title.ZIndex = 24
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(24, 77)
subtitle.Size = UDim2.new(0.62, 0, 0, 18)
subtitle.BackgroundTransparency = 1
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Complete missions • climb tiers • collect free + premium rewards"
subtitle.TextColor3 = Color3.fromRGB(255, 238, 214)
subtitle.TextSize = 12
subtitle.Font = Enum.Font.GothamBold
subtitle.ZIndex = 24
subtitle.Parent = header

local close = Theme.makeCloseButton(header)

local tierBadge = Instance.new("Frame")
tierBadge.Position = UDim2.fromOffset(22, 116)
tierBadge.Size = UDim2.fromOffset(112, 96)
tierBadge.BackgroundColor3 = Color3.fromRGB(255, 244, 218)
tierBadge.ZIndex = 22
tierBadge.Parent = panel
Theme.corner(tierBadge, 18)
Theme.stroke(tierBadge, Theme.Colors.Gold, 3, 0.15)

local tierWord = Instance.new("TextLabel")
tierWord.Position = UDim2.fromOffset(0, 8)
tierWord.Size = UDim2.new(1, 0, 0, 22)
tierWord.BackgroundTransparency = 1
tierWord.Text = "TIER"
tierWord.TextColor3 = Color3.fromRGB(143, 83, 35)
tierWord.TextSize = 13
tierWord.Font = Enum.Font.GothamBlack
tierWord.ZIndex = 23
tierWord.Parent = tierBadge

local tierNumber = Instance.new("TextLabel")
tierNumber.Position = UDim2.fromOffset(0, 26)
tierNumber.Size = UDim2.new(1, 0, 0, 54)
tierNumber.BackgroundTransparency = 1
tierNumber.Text = "0"
tierNumber.TextColor3 = Theme.Colors.Orange
tierNumber.TextSize = 44
tierNumber.Font = Enum.Font.GothamBlack
tierNumber.ZIndex = 23
tierNumber.Parent = tierBadge

local progressCard = Instance.new("Frame")
progressCard.Position = UDim2.fromOffset(148, 116)
progressCard.Size = UDim2.new(1, -446, 0, 96)
progressCard.BackgroundColor3 = Color3.fromRGB(245, 248, 253)
progressCard.ZIndex = 22
progressCard.Parent = panel
Theme.corner(progressCard, 18)
Theme.stroke(progressCard, Color3.fromRGB(214, 221, 235), 2, 0.2)

local progressTitle = Instance.new("TextLabel")
progressTitle.Position = UDim2.fromOffset(14, 11)
progressTitle.Size = UDim2.new(1, -28, 0, 24)
progressTitle.BackgroundTransparency = 1
progressTitle.TextXAlignment = Enum.TextXAlignment.Left
progressTitle.Text = "NEXT TIER"
progressTitle.TextColor3 = Theme.Colors.Ink
progressTitle.TextSize = 15
progressTitle.Font = Enum.Font.GothamBlack
progressTitle.ZIndex = 23
progressTitle.Parent = progressCard

local barBack = Instance.new("Frame")
barBack.Position = UDim2.fromOffset(14, 42)
barBack.Size = UDim2.new(1, -28, 0, 20)
barBack.BackgroundColor3 = Color3.fromRGB(215, 222, 234)
barBack.ZIndex = 23
barBack.Parent = progressCard
Theme.corner(barBack, 999)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Theme.Colors.Gold
barFill.ZIndex = 24
barFill.Parent = barBack
Theme.corner(barFill, 999)
Theme.gradient(barFill, Theme.Colors.Gold, Theme.Colors.Orange, 0)

local xpLabel = Instance.new("TextLabel")
xpLabel.Position = UDim2.fromOffset(14, 66)
xpLabel.Size = UDim2.new(1, -28, 0, 20)
xpLabel.BackgroundTransparency = 1
xpLabel.TextXAlignment = Enum.TextXAlignment.Left
xpLabel.Text = "0 / 100 XP"
xpLabel.TextColor3 = Theme.Colors.Muted
xpLabel.TextSize = 12
xpLabel.Font = Enum.Font.GothamBold
xpLabel.ZIndex = 23
xpLabel.Parent = progressCard

local premiumButton = Instance.new("TextButton")
premiumButton.Position = UDim2.new(1, -286, 0, 116)
premiumButton.Size = UDim2.fromOffset(264, 96)
premiumButton.TextColor3 = Theme.Colors.White
premiumButton.TextWrapped = true
premiumButton.TextSize = 14
premiumButton.Font = Enum.Font.GothamBlack
premiumButton.ZIndex = 22
premiumButton.Parent = panel
Theme.styleButton(premiumButton, Theme.Colors.Purple, Color3.fromRGB(182, 119, 255), 18)

local premiumBadge = Theme.makeBadge(premiumButton, "PREMIUM", Theme.Colors.Gold, UDim2.fromOffset(84, 24), UDim2.fromOffset(12, 10))
premiumBadge.ZIndex = 24

local productId = Config.Monetization.DeveloperProducts.SeasonPremium
local productConfigured = type(productId) == "number" and productId > 0
local displayPrice = Config.Season.SuggestedPremiumPrice

if productConfigured then
    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
        end)
        if ok and info and info.PriceInRobux then
            displayPrice = info.PriceInRobux
        end
    end)
end

local rewardsHeader = Instance.new("TextLabel")
rewardsHeader.Position = UDim2.fromOffset(22, 226)
rewardsHeader.Size = UDim2.new(1, -44, 0, 26)
rewardsHeader.BackgroundTransparency = 1
rewardsHeader.TextXAlignment = Enum.TextXAlignment.Left
rewardsHeader.Text = "REWARD TRACK"
rewardsHeader.TextColor3 = Theme.Colors.Ink
rewardsHeader.TextSize = 16
rewardsHeader.Font = Enum.Font.GothamBlack
rewardsHeader.ZIndex = 22
rewardsHeader.Parent = panel

local rewardScroll = Instance.new("ScrollingFrame")
rewardScroll.Position = UDim2.fromOffset(22, 256)
rewardScroll.Size = UDim2.new(1, -44, 0, 190)
rewardScroll.BackgroundColor3 = Color3.fromRGB(237, 242, 250)
rewardScroll.BorderSizePixel = 0
rewardScroll.ScrollBarThickness = 6
rewardScroll.ScrollBarImageColor3 = Theme.Colors.Gold
rewardScroll.ScrollingDirection = Enum.ScrollingDirection.X
rewardScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
rewardScroll.CanvasSize = UDim2.new()
rewardScroll.ZIndex = 22
rewardScroll.Parent = panel
Theme.corner(rewardScroll, 16)
local rewardPadding = Theme.padding(rewardScroll, 10)
local rewardLayout = Instance.new("UIListLayout")
rewardLayout.FillDirection = Enum.FillDirection.Horizontal
rewardLayout.Padding = UDim.new(0, 10)
rewardLayout.SortOrder = Enum.SortOrder.LayoutOrder
rewardLayout.Parent = rewardScroll

local rewardCards = {}
local function rewardSummary(reward)
    local research = reward.Research or 0
    if reward.Ability and (reward.AbilityCount or 0) > 0 then
        local ability = Config.Abilities[reward.Ability]
        return string.format("%s R\n+%dx %s", tostring(research), reward.AbilityCount, ability and ability.Name or reward.Ability)
    end
    return tostring(research) .. " R"
end

for tier = 1, Config.Season.MaxTier do
    local card = Instance.new("Frame")
    card.Name = "Tier" .. tier
    card.Size = UDim2.fromOffset(128, 166)
    card.BackgroundColor3 = Theme.Colors.White
    card.ZIndex = 23
    card.Parent = rewardScroll
    Theme.corner(card, 15)
    local cardStroke = Theme.stroke(card, Color3.fromRGB(197, 204, 218), 2, 0.25)

    local number = Instance.new("TextLabel")
    number.Position = UDim2.fromOffset(8, 6)
    number.Size = UDim2.new(1, -16, 0, 24)
    number.BackgroundTransparency = 1
    number.Text = "TIER " .. tier
    number.TextColor3 = Theme.Colors.Ink
    number.TextSize = 13
    number.Font = Enum.Font.GothamBlack
    number.ZIndex = 24
    number.Parent = card

    local freeBox = Instance.new("TextLabel")
    freeBox.Position = UDim2.fromOffset(8, 34)
    freeBox.Size = UDim2.new(1, -16, 0, 54)
    freeBox.BackgroundColor3 = Color3.fromRGB(222, 243, 231)
    freeBox.TextColor3 = Theme.Colors.GreenDark
    freeBox.TextWrapped = true
    freeBox.Text = "FREE\n" .. rewardSummary(Config.GetSeasonReward(tier, false))
    freeBox.TextSize = 11
    freeBox.Font = Enum.Font.GothamBlack
    freeBox.ZIndex = 24
    freeBox.Parent = card
    Theme.corner(freeBox, 10)

    local premiumBox = Instance.new("TextLabel")
    premiumBox.Position = UDim2.fromOffset(8, 96)
    premiumBox.Size = UDim2.new(1, -16, 0, 62)
    premiumBox.BackgroundColor3 = Color3.fromRGB(242, 228, 255)
    premiumBox.TextColor3 = Color3.fromRGB(105, 55, 166)
    premiumBox.TextWrapped = true
    premiumBox.Text = "PREMIUM\n" .. rewardSummary(Config.GetSeasonReward(tier, true))
    premiumBox.TextSize = 10
    premiumBox.Font = Enum.Font.GothamBlack
    premiumBox.ZIndex = 24
    premiumBox.Parent = card
    Theme.corner(premiumBox, 10)

    rewardCards[tier] = {
        Frame = card,
        Stroke = cardStroke,
        Free = freeBox,
        Premium = premiumBox,
    }
end

local missionsHeader = Instance.new("TextLabel")
missionsHeader.Position = UDim2.fromOffset(22, 458)
missionsHeader.Size = UDim2.new(1, -44, 0, 24)
missionsHeader.BackgroundTransparency = 1
missionsHeader.TextXAlignment = Enum.TextXAlignment.Left
missionsHeader.Text = "DAILY MISSIONS"
missionsHeader.TextColor3 = Theme.Colors.Ink
missionsHeader.TextSize = 16
missionsHeader.Font = Enum.Font.GothamBlack
missionsHeader.ZIndex = 22
missionsHeader.Parent = panel

local missionHolder = Instance.new("Frame")
missionHolder.Position = UDim2.fromOffset(22, 488)
missionHolder.Size = UDim2.new(1, -44, 0, 98)
missionHolder.BackgroundTransparency = 1
missionHolder.ZIndex = 22
missionHolder.Parent = panel
local missionLayout = Instance.new("UIGridLayout")
missionLayout.CellSize = UDim2.new(0.25, -8, 1, 0)
missionLayout.CellPadding = UDim2.fromOffset(10, 0)
missionLayout.Parent = missionHolder

local missionCards = {}
for i = 1, 4 do
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.Colors.White
    card.ZIndex = 23
    card.Parent = missionHolder
    Theme.corner(card, 14)
    Theme.stroke(card, Color3.fromRGB(202, 210, 224), 2, 0.35)

    local name = Instance.new("TextLabel")
    name.Position = UDim2.fromOffset(10, 8)
    name.Size = UDim2.new(1, -20, 0, 39)
    name.BackgroundTransparency = 1
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextYAlignment = Enum.TextYAlignment.Top
    name.TextWrapped = true
    name.Text = "Loading mission..."
    name.TextColor3 = Theme.Colors.Ink
    name.TextSize = 11
    name.Font = Enum.Font.GothamBlack
    name.ZIndex = 24
    name.Parent = card

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(10, 53)
    bar.Size = UDim2.new(1, -20, 0, 12)
    bar.BackgroundColor3 = Color3.fromRGB(222, 228, 238)
    bar.ZIndex = 24
    bar.Parent = card
    Theme.corner(bar, 999)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = Theme.Colors.Blue
    fill.ZIndex = 25
    fill.Parent = bar
    Theme.corner(fill, 999)

    local progress = Instance.new("TextLabel")
    progress.Position = UDim2.fromOffset(10, 69)
    progress.Size = UDim2.new(1, -20, 0, 20)
    progress.BackgroundTransparency = 1
    progress.TextXAlignment = Enum.TextXAlignment.Left
    progress.Text = "0/0 • +0 XP"
    progress.TextColor3 = Theme.Colors.Muted
    progress.TextSize = 10
    progress.Font = Enum.Font.GothamBold
    progress.ZIndex = 24
    progress.Parent = card

    missionCards[i] = {Frame = card, Name = name, Fill = fill, Progress = progress}
end

premiumButton.Activated:Connect(function()
    if premiumButton:GetAttribute("Owned") then return end
    if not productConfigured then
        premiumButton.Text = string.format("PREMIUM TRACK\n%d R$ PLANNED • ENABLES AFTER PUBLISH", displayPrice)
        return
    end
    MarketplaceService:PromptProductPurchase(player, productId)
end)

seasonState.OnClientEvent:Connect(function(state)
    local tier = state.Tier or 0
    local maxTier = state.MaxTier or Config.Season.MaxTier
    tierNumber.Text = tostring(tier)
    progressTitle.Text = tier >= maxTier and "SEASON COMPLETE!" or string.format("TIER %d → %d", tier, math.min(maxTier, tier + 1))
    local ratio = math.clamp((state.XPIntoTier or 0) / math.max(1, state.XPPerTier or 100), 0, 1)
    barFill.Size = UDim2.fromScale(ratio, 1)
    xpLabel.Text = string.format("%d / %d XP  •  %d total Season XP", state.XPIntoTier or 0, state.XPPerTier or 100, state.XP or 0)

    premiumButton:SetAttribute("Owned", state.Premium == true)
    if state.Premium then
        premiumButton.BackgroundColor3 = Theme.Colors.Green
        premiumButton.Text = "PREMIUM UNLOCKED\nExtra rewards auto-claim as you level"
        premiumBadge.Text = "OWNED"
        premiumBadge.BackgroundColor3 = Theme.Colors.GreenDark
    elseif productConfigured then
        premiumButton.BackgroundColor3 = Theme.Colors.Purple
        premiumButton.Text = string.format("UNLOCK PREMIUM TRACK\n%d R$ • EXTRA REWARDS", displayPrice)
        premiumBadge.Text = "PREMIUM"
        premiumBadge.BackgroundColor3 = Theme.Colors.Gold
    else
        premiumButton.BackgroundColor3 = Color3.fromRGB(123, 94, 156)
        premiumButton.Text = string.format("UNLOCK PREMIUM TRACK\n%d R$ PLANNED", displayPrice)
    end

    for rewardTier, card in ipairs(rewardCards) do
        local earned = rewardTier <= tier
        local nextTier = rewardTier == math.min(maxTier, tier + 1) and tier < maxTier
        card.Frame.BackgroundColor3 = earned and Color3.fromRGB(250, 255, 246) or Theme.Colors.White
        card.Stroke.Color = nextTier and Theme.Colors.Gold or (earned and Theme.Colors.Green or Color3.fromRGB(197, 204, 218))
        card.Stroke.Thickness = nextTier and 4 or 2
        card.Free.TextTransparency = earned and 0 or 0.08
        if earned then
            card.Free.Text = "CLAIMED ✓\n" .. rewardSummary(Config.GetSeasonReward(rewardTier, false))
        else
            card.Free.Text = "FREE\n" .. rewardSummary(Config.GetSeasonReward(rewardTier, false))
        end

        if state.Premium and earned then
            card.Premium.Text = "CLAIMED ✓\n" .. rewardSummary(Config.GetSeasonReward(rewardTier, true))
            card.Premium.BackgroundColor3 = Color3.fromRGB(226, 251, 233)
            card.Premium.TextColor3 = Theme.Colors.GreenDark
        elseif state.Premium then
            card.Premium.Text = "PREMIUM\n" .. rewardSummary(Config.GetSeasonReward(rewardTier, true))
            card.Premium.BackgroundColor3 = Color3.fromRGB(242, 228, 255)
            card.Premium.TextColor3 = Color3.fromRGB(105, 55, 166)
        else
            card.Premium.Text = "LOCKED 🔒\n" .. rewardSummary(Config.GetSeasonReward(rewardTier, true))
            card.Premium.BackgroundColor3 = Color3.fromRGB(232, 232, 239)
            card.Premium.TextColor3 = Theme.Colors.Muted
        end
    end

    rewardScroll.CanvasPosition = Vector2.new(math.max(0, (math.max(1, tier) - 1) * 138 - 80), 0)

    for i, card in ipairs(missionCards) do
        local mission = state.Missions and state.Missions[i]
        if mission then
            local missionRatio = math.clamp((mission.Progress or 0) / math.max(1, mission.Target or 1), 0, 1)
            card.Name.Text = mission.Completed and ("✓ " .. mission.Name) or mission.Name
            card.Name.TextColor3 = mission.Completed and Theme.Colors.GreenDark or Theme.Colors.Ink
            card.Fill.Size = UDim2.fromScale(missionRatio, 1)
            card.Fill.BackgroundColor3 = mission.Completed and Theme.Colors.Green or Theme.Colors.Blue
            card.Progress.Text = string.format("%d/%d  •  +%d XP", mission.Progress or 0, mission.Target or 0, mission.XP or 0)
        end
    end
end)

openButton.Activated:Connect(function()
    openButton.Visible = false
    Theme.openOverlay(overlay, panelScale)
end)

close.Activated:Connect(function()
    Theme.closeOverlay(overlay, panelScale)
    task.delay(0.14, function() openButton.Visible = true end)
end)

local camera = workspace.CurrentCamera
local responsiveScale = Instance.new("UIScale")
responsiveScale.Parent = panel
local function resize()
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    responsiveScale.Scale = math.clamp(math.min(viewport.X / 1000, viewport.Y / 740), 0.64, 1)
end
resize()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
