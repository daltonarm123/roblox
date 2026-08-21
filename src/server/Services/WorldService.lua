local Workspace = game:GetService("Workspace")

local WorldService = {}

local WORLD_NAME = "JunkyardEmpireWorld"

local function createPart(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.Size = size
    part.Position = position
    part.Color = color
    part.Material = material or Enum.Material.Metal
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function addSign(part, text, textColor)
    local gui = Instance.new("BillboardGui")
    gui.Name = "Sign"
    gui.Size = UDim2.fromOffset(220, 70)
    gui.StudsOffset = Vector3.new(0, 4, 0)
    gui.AlwaysOnTop = true
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 0.2
    label.BackgroundColor3 = Color3.fromRGB(20, 24, 28)
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = textColor or Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
end

local function addPrompt(part, actionText, objectText, action, upgradeName)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt:SetAttribute("Action", action)
    if upgradeName then
        prompt:SetAttribute("UpgradeName", upgradeName)
    end
    prompt.Parent = part
    return prompt
end

local function buildFence(parent)
    local fenceColor = Color3.fromRGB(72, 78, 82)
    for x = -90, 90, 12 do
        createPart(parent, "Fence", Vector3.new(10, 8, 0.4), Vector3.new(x, 4, -70), fenceColor, Enum.Material.DiamondPlate)
        createPart(parent, "Fence", Vector3.new(10, 8, 0.4), Vector3.new(x, 4, 70), fenceColor, Enum.Material.DiamondPlate)
    end
    for z = -58, 58, 12 do
        createPart(parent, "Fence", Vector3.new(0.4, 8, 10), Vector3.new(-96, 4, z), fenceColor, Enum.Material.DiamondPlate)
        createPart(parent, "Fence", Vector3.new(0.4, 8, 10), Vector3.new(96, 4, z), fenceColor, Enum.Material.DiamondPlate)
    end
end

local function buildCrusher(parent)
    local crusher = Instance.new("Model")
    crusher.Name = "Crusher"
    crusher.Parent = parent

    local dark = Color3.fromRGB(38, 42, 46)
    local hazard = Color3.fromRGB(230, 164, 35)
    createPart(crusher, "Base", Vector3.new(26, 2, 20), Vector3.new(25, 1.5, 0), dark, Enum.Material.Metal)
    createPart(crusher, "LeftSupport", Vector3.new(3, 15, 3), Vector3.new(16, 9, 0), hazard, Enum.Material.Metal)
    createPart(crusher, "RightSupport", Vector3.new(3, 15, 3), Vector3.new(34, 9, 0), hazard, Enum.Material.Metal)
    createPart(crusher, "Top", Vector3.new(22, 3, 5), Vector3.new(25, 16, 0), dark, Enum.Material.Metal)
    local press = createPart(crusher, "Press", Vector3.new(15, 3, 13), Vector3.new(25, 11, 0), Color3.fromRGB(165, 55, 48), Enum.Material.Metal)
    addSign(press, "AUTO CRUSHER\nEarns cash while you play", Color3.fromRGB(255, 224, 110))
end

local function buildScrapPiles(parent)
    local positions = {
        Vector3.new(-55, 2, -35),
        Vector3.new(-35, 2, -45),
        Vector3.new(-60, 2, 5),
        Vector3.new(-40, 2, 20),
        Vector3.new(-62, 2, 42),
        Vector3.new(-25, 2, 42),
    }

    local colors = {
        Color3.fromRGB(115, 91, 70),
        Color3.fromRGB(93, 105, 111),
        Color3.fromRGB(145, 76, 62),
    }

    for index, position in ipairs(positions) do
        local pile = Instance.new("Model")
        pile.Name = "ScrapPile" .. index
        pile.Parent = parent

        local base = createPart(pile, "Scrap", Vector3.new(9, 3, 8), position, colors[((index - 1) % #colors) + 1], Enum.Material.CorrodedMetal)
        base.Orientation = Vector3.new(0, index * 17, 0)
        for piece = 1, 4 do
            local offset = Vector3.new(((piece % 2) * 3) - 1.5, 2 + (piece * 0.7), ((piece % 3) * 2) - 2)
            local scrap = createPart(pile, "LooseScrap", Vector3.new(4 + piece, 0.7, 1.5), position + offset, colors[((index + piece - 1) % #colors) + 1], Enum.Material.CorrodedMetal)
            scrap.Orientation = Vector3.new(piece * 8, index * 23, piece * 11)
        end
        addPrompt(base, "Grab Scrap", "Scrap Pile", "CollectScrap")
    end
end

local function buildPads(parent)
    local padInfo = {
        { "PickupPower", "PICKUP POWER", Vector3.new(52, 0.6, -42), Color3.fromRGB(72, 139, 212) },
        { "SellBoost", "SCRAP VALUE", Vector3.new(68, 0.6, -42), Color3.fromRGB(83, 177, 118) },
        { "Storage", "STORAGE", Vector3.new(52, 0.6, -24), Color3.fromRGB(171, 111, 201) },
        { "AutoCrusher", "AUTO CRUSHER", Vector3.new(68, 0.6, -24), Color3.fromRGB(227, 157, 57) },
    }

    for _, info in ipairs(padInfo) do
        local upgradeName, displayName, position, color = table.unpack(info)
        local pad = createPart(parent, upgradeName .. "Pad", Vector3.new(12, 1, 12), position, color, Enum.Material.Neon)
        addSign(pad, displayName, Color3.new(1, 1, 1))
        addPrompt(pad, "Buy Upgrade", displayName, "BuyUpgrade", upgradeName)
    end

    local sellPad = createPart(parent, "SellPad", Vector3.new(16, 1, 16), Vector3.new(-5, 0.6, -38), Color3.fromRGB(59, 190, 98), Enum.Material.Neon)
    addSign(sellPad, "SELL SCRAP", Color3.fromRGB(195, 255, 207))
    addPrompt(sellPad, "Sell All", "Scrap Buyer", "SellScrap")

    local rebirthPad = createPart(parent, "RebirthPad", Vector3.new(16, 1, 16), Vector3.new(60, 0.6, 42), Color3.fromRGB(232, 83, 84), Enum.Material.Neon)
    addSign(rebirthPad, "REBIRTH\nReset for permanent multiplier", Color3.fromRGB(255, 220, 220))
    addPrompt(rebirthPad, "Rebirth", "Prestige Yard", "Rebirth")
end

function WorldService.Build()
    local existing = Workspace:FindFirstChild(WORLD_NAME)
    if existing then
        existing:Destroy()
    end

    local world = Instance.new("Model")
    world.Name = WORLD_NAME
    world.Parent = Workspace

    createPart(world, "Ground", Vector3.new(190, 1, 140), Vector3.new(0, -0.5, 0), Color3.fromRGB(67, 69, 66), Enum.Material.Asphalt)
    buildFence(world)
    buildCrusher(world)
    buildScrapPiles(world)
    buildPads(world)

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "JunkyardSpawn"
    spawn.Size = Vector3.new(10, 1, 10)
    spawn.Position = Vector3.new(0, 0.6, 45)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Material = Enum.Material.Neon
    spawn.Color = Color3.fromRGB(88, 170, 255)
    spawn.Parent = world
    addSign(spawn, "JUNKYARD EMPIRE\nGrab scrap → Sell → Upgrade → Automate", Color3.fromRGB(180, 225, 255))

    return world
end

return WorldService
