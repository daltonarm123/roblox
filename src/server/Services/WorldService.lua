local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.Config)

local WorldService = {}
local world

local function part(parent, name, size, cframe, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.CanCollide = true
    p.Color = color or Color3.fromRGB(80, 80, 80)
    p.Material = material or Enum.Material.Metal
    p.Parent = parent
    return p
end

local function surfaceText(target, text, face)
    local gui = Instance.new("SurfaceGui")
    gui.Face = face or Enum.NormalId.Top
    gui.AlwaysOnTop = true
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 30
    gui.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.45
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
    return label
end

local function billboard(target, text)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(190, 58)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
    gui.AlwaysOnTop = true
    gui.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.25
    label.BackgroundColor3 = Color3.fromRGB(8, 11, 16)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.Parent = gui
    return label
end

local function prompt(target, action, object, hold)
    local p = Instance.new("ProximityPrompt")
    p.ActionText = action
    p.ObjectText = object
    p.HoldDuration = hold or 0.35
    p.MaxActivationDistance = 10
    p.RequiresLineOfSight = false
    p.Parent = target
    return p
end

local function buildBase(parent, index, angle)
    local radius = 122
    local center = Vector3.new(math.cos(angle) * radius, 1, math.sin(angle) * radius)
    local facing = CFrame.lookAt(center, Vector3.new(0, 1, 0))

    local model = Instance.new("Model")
    model.Name = "Lab_" .. index
    model:SetAttribute("BaseIndex", index)
    model:SetAttribute("OwnerUserId", 0)
    model.Parent = parent

    local floor = part(model, "Floor", Vector3.new(38, 1, 32), facing, Color3.fromRGB(30, 39, 49), Enum.Material.Metal)
    floor.CFrame += Vector3.new(0, -0.5, 0)

    local back = part(model, "BackWall", Vector3.new(38, 10, 1), facing * CFrame.new(0, 5, 15.5), Color3.fromRGB(18, 25, 33))
    local left = part(model, "LeftWall", Vector3.new(1, 10, 32), facing * CFrame.new(-18.5, 5, 0), Color3.fromRGB(18, 25, 33))
    local right = part(model, "RightWall", Vector3.new(1, 10, 32), facing * CFrame.new(18.5, 5, 0), Color3.fromRGB(18, 25, 33))
    back.Material, left.Material, right.Material = Enum.Material.Metal, Enum.Material.Metal, Enum.Material.Metal

    local sign = part(model, "OwnerSign", Vector3.new(12, 4, 0.8), facing * CFrame.new(0, 7.2, 15), Color3.fromRGB(15, 20, 26), Enum.Material.Neon)
    local signLabel = surfaceText(sign, "UNCLAIMED LAB", Enum.NormalId.Front)

    local deposit = part(model, "Deposit", Vector3.new(12, 0.6, 7), facing * CFrame.new(0, 0.3, -10), Color3.fromRGB(50, 225, 145), Enum.Material.Neon)
    deposit:SetAttribute("ActionType", "Deposit")
    deposit:SetAttribute("BaseIndex", index)
    surfaceText(deposit, "CONTAIN SPECIMEN")

    local speedPad = part(model, "SpeedUpgrade", Vector3.new(8, 0.6, 6), facing * CFrame.new(-12, 0.3, -8), Color3.fromRGB(70, 170, 255), Enum.Material.Neon)
    speedPad:SetAttribute("ActionType", "Upgrade")
    speedPad:SetAttribute("UpgradeType", "Speed")
    speedPad:SetAttribute("BaseIndex", index)
    prompt(speedPad, "Upgrade", "Movement Speed")
    surfaceText(speedPad, "SPEED")

    local capacityPad = part(model, "CapacityUpgrade", Vector3.new(8, 0.6, 6), facing * CFrame.new(12, 0.3, -8), Color3.fromRGB(195, 105, 255), Enum.Material.Neon)
    capacityPad:SetAttribute("ActionType", "Upgrade")
    capacityPad:SetAttribute("UpgradeType", "Capacity")
    capacityPad:SetAttribute("BaseIndex", index)
    prompt(capacityPad, "Upgrade", "Containment Slots")
    surfaceText(capacityPad, "CAPACITY")

    local pods = {}
    for slot = 1, Config.MaxCapacity do
        local row = math.floor((slot - 1) / 3)
        local col = (slot - 1) % 3
        local x = -10 + col * 10
        local z = 3 + row * 8
        local stand = part(model, "PodStand_" .. slot, Vector3.new(7, 0.8, 6), facing * CFrame.new(x, 0.4, z), Color3.fromRGB(60, 69, 78), Enum.Material.Metal)
        local glass = part(model, "Pod_" .. slot, Vector3.new(5, 5.5, 4), facing * CFrame.new(x, 3.2, z), Color3.fromRGB(35, 65, 78), Enum.Material.Glass)
        glass.Transparency = 0.45
        glass.CanCollide = false
        glass:SetAttribute("ActionType", "Raid")
        glass:SetAttribute("BaseIndex", index)
        glass:SetAttribute("PodIndex", slot)
        local raidPrompt = prompt(glass, "RAID", "Empty Containment Pod", 1.1)
        raidPrompt.Enabled = false
        local label = billboard(glass, "EMPTY")
        pods[slot] = { Stand = stand, Glass = glass, Prompt = raidPrompt, Label = label, Visual = nil }
    end

    return {
        Index = index,
        Model = model,
        Center = center,
        Facing = facing,
        OwnerUserId = 0,
        SignLabel = signLabel,
        Deposit = deposit,
        SpeedPad = speedPad,
        CapacityPad = capacityPad,
        Pods = pods,
    }
end

function WorldService.Build()
    if workspace:FindFirstChild("ContainmentHeistWorld") then
        workspace.ContainmentHeistWorld:Destroy()
    end

    Lighting.ClockTime = 1.2
    Lighting.Brightness = 1.6
    Lighting.Ambient = Color3.fromRGB(28, 35, 48)
    Lighting.OutdoorAmbient = Color3.fromRGB(18, 25, 34)
    Lighting.FogColor = Color3.fromRGB(15, 23, 32)
    Lighting.FogEnd = 420

    local root = Instance.new("Folder")
    root.Name = "ContainmentHeistWorld"
    root.Parent = workspace

    part(root, "Ground", Vector3.new(330, 2, 330), CFrame.new(0, -1, 0), Color3.fromRGB(18, 27, 31), Enum.Material.Asphalt)

    local central = Instance.new("Model")
    central.Name = "CentralFacility"
    central.Parent = root
    part(central, "FacilityFloor", Vector3.new(86, 1, 86), CFrame.new(0, 0, 0), Color3.fromRGB(45, 52, 58), Enum.Material.Metal)

    local wallColor = Color3.fromRGB(20, 30, 38)
    part(central, "NorthWallA", Vector3.new(32, 12, 2), CFrame.new(-27, 6, -43), wallColor)
    part(central, "NorthWallB", Vector3.new(32, 12, 2), CFrame.new(27, 6, -43), wallColor)
    part(central, "SouthWallA", Vector3.new(32, 12, 2), CFrame.new(-27, 6, 43), wallColor)
    part(central, "SouthWallB", Vector3.new(32, 12, 2), CFrame.new(27, 6, 43), wallColor)
    part(central, "WestWallA", Vector3.new(2, 12, 32), CFrame.new(-43, 6, -27), wallColor)
    part(central, "WestWallB", Vector3.new(2, 12, 32), CFrame.new(-43, 6, 27), wallColor)
    part(central, "EastWallA", Vector3.new(2, 12, 32), CFrame.new(43, 6, -27), wallColor)
    part(central, "EastWallB", Vector3.new(2, 12, 32), CFrame.new(43, 6, 27), wallColor)

    local beacon = part(central, "RareEventBeacon", Vector3.new(7, 12, 7), CFrame.new(0, 6, 0), Color3.fromRGB(255, 187, 55), Enum.Material.Neon)
    beacon.Transparency = 0.35
    billboard(beacon, "CENTRAL CONTAINMENT\nRARE EVENT EVERY 5 MIN")

    local pedestals = {}
    for i = 1, Config.CentralSpawnCount do
        local a = ((i - 1) / Config.CentralSpawnCount) * math.pi * 2
        local pos = Vector3.new(math.cos(a) * 24, 0.6, math.sin(a) * 24)
        local pedestal = part(central, "Pedestal_" .. i, Vector3.new(8, 1.2, 8), CFrame.new(pos), Color3.fromRGB(90, 98, 108), Enum.Material.Metal)
        pedestal:SetAttribute("SpawnIndex", i)
        pedestals[i] = pedestal
    end

    -- Bright hazard strips force carriers to choose a route instead of walking a straight line.
    for i = -1, 1 do
        local laser = part(central, "SecurityLaserX_" .. i, Vector3.new(2, 4, 54), CFrame.new(i * 14, 2.2, 0), Color3.fromRGB(255, 45, 70), Enum.Material.Neon)
        laser.CanCollide = false
        laser.Transparency = 0.2
        laser:SetAttribute("SecurityLaser", true)
    end

    local bases = {}
    for i = 1, Config.BaseCount do
        bases[i] = buildBase(root, i, ((i - 1) / Config.BaseCount) * math.pi * 2)
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "LobbySpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.CFrame = CFrame.new(0, 1, 63)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Material = Enum.Material.Neon
    spawn.Color = Color3.fromRGB(85, 170, 255)
    spawn.Parent = root

    world = { Root = root, Central = central, Pedestals = pedestals, Bases = bases, Beacon = beacon }
    return world
end

function WorldService.GetWorld()
    return world
end

function WorldService.ClaimBase(player)
    if not world then return nil end
    for _, base in ipairs(world.Bases) do
        if base.OwnerUserId == 0 then
            base.OwnerUserId = player.UserId
            base.Model:SetAttribute("OwnerUserId", player.UserId)
            base.SignLabel.Text = string.upper(player.DisplayName) .. "'S LAB"
            return base
        end
    end
end

function WorldService.ReleaseBase(player)
    if not world then return end
    for _, base in ipairs(world.Bases) do
        if base.OwnerUserId == player.UserId then
            base.OwnerUserId = 0
            base.Model:SetAttribute("OwnerUserId", 0)
            base.SignLabel.Text = "UNCLAIMED LAB"
            for i = 1, Config.MaxCapacity do
                WorldService.SetPod(base.Index, i, nil)
            end
            return
        end
    end
end

function WorldService.FindPlayerBase(player)
    if not world then return nil end
    for _, base in ipairs(world.Bases) do
        if base.OwnerUserId == player.UserId then
            return base
        end
    end
end

function WorldService.SetPod(baseIndex, slotIndex, owned)
    local base = world and world.Bases[baseIndex]
    local pod = base and base.Pods[slotIndex]
    if not pod then return end

    if pod.Visual then
        pod.Visual:Destroy()
        pod.Visual = nil
    end

    if not owned then
        pod.Prompt.Enabled = false
        pod.Prompt.ObjectText = "Empty Containment Pod"
        pod.Label.Text = "EMPTY"
        pod.Glass:SetAttribute("Occupied", false)
        return
    end

    local specimen = Config.GetSpecimenById(owned.SpecimenId)
    local variant = Config.GetVariantById(owned.VariantId)
    if not specimen or not variant then return end

    local visual = Instance.new("Part")
    visual.Name = "ContainedSpecimen"
    visual.Size = specimen.Shape == "Block" and Vector3.new(2.7, 2.7, 2.7) or Vector3.new(2.8, 2.8, 2.8)
    visual.Shape = specimen.Shape == "Ball" and Enum.PartType.Ball or Enum.PartType.Block
    visual.Anchored = true
    visual.CanCollide = false
    visual.Material = variant.Id == "Normal" and Enum.Material.SmoothPlastic or Enum.Material.Neon
    visual.Color = specimen.Color:Lerp(Color3.new(1, 1, 1), variant.Id == "Glowing" and 0.25 or 0)
    visual.CFrame = pod.Glass.CFrame
    visual.Parent = pod.Glass.Parent
    pod.Visual = visual

    local income = math.floor(specimen.Income * variant.Multiplier)
    pod.Label.Text = string.format("%s\n%s • %d R/s", specimen.Name, variant.Name, income)
    pod.Prompt.ObjectText = variant.Name .. " " .. specimen.Name
    pod.Prompt.Enabled = true
    pod.Glass:SetAttribute("Occupied", true)
end

return WorldService
