local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("ContainmentHeistWorld")

-- Remove the default Studio baseplate so its grid texture cannot bleed through the map.
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and not baseplate:IsDescendantOf(world) then
    baseplate:Destroy()
end

local ground = world:FindFirstChild("Ground")
if ground and ground:IsA("BasePart") then
    ground.Material = Enum.Material.Concrete
    ground.Color = Color3.fromRGB(30, 34, 39)
end

local floorFolder = Instance.new("Folder")
floorFolder.Name = "IndustrialFlooring"
floorFolder.Parent = world

local function makePart(name, size, cframe, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.CanCollide = true
    p.Material = material or Enum.Material.Concrete
    p.Color = color
    p.Transparency = transparency or 0
    p.Parent = floorFolder
    return p
end

-- Six broad walkways connect each lab edge cleanly to Central Containment.
for _, lab in ipairs(world:GetChildren()) do
    if lab:IsA("Model") and lab.Name:match("^Lab_%d+$") then
        local floor = lab:FindFirstChild("Floor")
        if floor then
            floor.Material = Enum.Material.DiamondPlate
            floor.Color = Color3.fromRGB(42, 48, 55)

            local start = Vector3.new(floor.Position.X, 0.18, floor.Position.Z)
            local destination = Vector3.new(0, 0.18, 0)
            local delta = destination - start
            local innerLabOffset = 16
            local centralRadius = 43
            local length = math.max(1, delta.Magnitude - innerLabOffset - centralRadius)
            local midpoint = start + delta.Unit * (innerLabOffset + length / 2)
            local path = makePart(
                lab.Name .. "_MainWalkway",
                Vector3.new(15, 0.35, length),
                CFrame.lookAt(midpoint, midpoint + delta.Unit),
                Color3.fromRGB(48, 53, 58),
                Enum.Material.Concrete
            )

            -- Cyan edge strips make routes legible at night without feeling like a default obby.
            for _, x in ipairs({-6.9, 6.9}) do
                local edge = makePart(
                    lab.Name .. "_PathEdge",
                    Vector3.new(0.35, 0.12, length),
                    path.CFrame * CFrame.new(x, 0.23, 0),
                    Color3.fromRGB(58, 180, 215),
                    Enum.Material.Neon
                )
                edge.CanCollide = false
            end
        end
    end
end

local central = world:FindFirstChild("CentralFacility")
if central then
    local centralFloor = central:FindFirstChild("FacilityFloor")
    if centralFloor then
        centralFloor.Material = Enum.Material.DiamondPlate
        centralFloor.Color = Color3.fromRGB(55, 60, 66)
    end

    -- Hazard bands around the central room sell the containment-facility theme.
    local hazardColor = Color3.fromRGB(245, 190, 55)
    local hazardSpecs = {
        {Vector3.new(82, 0.15, 1.2), CFrame.new(0, 0.65, -39)},
        {Vector3.new(82, 0.15, 1.2), CFrame.new(0, 0.65, 39)},
        {Vector3.new(1.2, 0.15, 82), CFrame.new(-39, 0.65, 0)},
        {Vector3.new(1.2, 0.15, 82), CFrame.new(39, 0.65, 0)},
    }
    for i, spec in ipairs(hazardSpecs) do
        local strip = Instance.new("Part")
        strip.Name = "ContainmentHazardBand_" .. i
        strip.Size = spec[1]
        strip.CFrame = spec[2]
        strip.Anchored = true
        strip.CanCollide = false
        strip.Material = Enum.Material.Neon
        strip.Color = hazardColor
        strip.Parent = central
    end
end

-- Add subtle large concrete panels so the open ground reads as intentional flooring.
local panelSize = 55
local half = 3
for x = -half, half do
    for z = -half, half do
        local panel = makePart(
            string.format("GroundPanel_%d_%d", x, z),
            Vector3.new(panelSize - 0.7, 0.12, panelSize - 0.7),
            CFrame.new(x * panelSize, 0.07, z * panelSize),
            ((x + z) % 2 == 0) and Color3.fromRGB(34, 38, 43) or Color3.fromRGB(30, 34, 39),
            Enum.Material.Concrete
        )
        panel.CanCollide = false
    end
end
