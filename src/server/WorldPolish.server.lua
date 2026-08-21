local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Keep the horror/research-facility mood, but make gameplay readable.
Lighting.ClockTime = 18.2
Lighting.Brightness = 3
Lighting.Ambient = Color3.fromRGB(92, 102, 122)
Lighting.OutdoorAmbient = Color3.fromRGB(62, 72, 92)
Lighting.ExposureCompensation = 0.45
Lighting.FogColor = Color3.fromRGB(28, 38, 50)
Lighting.FogEnd = 720
Lighting.EnvironmentDiffuseScale = 0.45
Lighting.EnvironmentSpecularScale = 0.7

local colorCorrection = Lighting:FindFirstChild("ContainmentColorCorrection")
if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Name = "ContainmentColorCorrection"
    colorCorrection.Parent = Lighting
end
colorCorrection.Brightness = 0.04
colorCorrection.Contrast = 0.06
colorCorrection.Saturation = -0.08
colorCorrection.TintColor = Color3.fromRGB(220, 232, 255)

local world = Workspace:WaitForChild("ContainmentHeistWorld")

local polishFolder = Instance.new("Folder")
polishFolder.Name = "WorldPolish"
polishFolder.Parent = world

local function makeFixture(parent, name, cframe, size, color, brightness, range)
    local fixture = Instance.new("Part")
    fixture.Name = name
    fixture.Size = size
    fixture.CFrame = cframe
    fixture.Anchored = true
    fixture.CanCollide = false
    fixture.CanTouch = false
    fixture.CanQuery = false
    fixture.Material = Enum.Material.Neon
    fixture.Color = color
    fixture.Parent = parent

    local light = Instance.new("PointLight")
    light.Brightness = brightness
    light.Range = range
    light.Color = color
    light.Shadows = false
    light.Parent = fixture

    return fixture
end

local function ensureBackSign(sign, text)
    local gui = sign:FindFirstChild("BackOwnerSign")
    if not gui then
        gui = Instance.new("SurfaceGui")
        gui.Name = "BackOwnerSign"
        gui.Face = Enum.NormalId.Back
        gui.AlwaysOnTop = true
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 30
        gui.Parent = sign

        local label = Instance.new("TextLabel")
        label.Name = "OwnerText"
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.35
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
    end

    local label = gui:FindFirstChildOfClass("TextLabel")
    if label then
        label.Text = text
    end
end

local function updateLabSign(lab)
    local sign = lab:FindFirstChild("OwnerSign")
    if not sign then
        return
    end

    local ownerUserId = lab:GetAttribute("OwnerUserId") or 0
    local text = "UNCLAIMED LAB"

    if ownerUserId ~= 0 then
        local player = Players:GetPlayerByUserId(ownerUserId)
        if player then
            text = string.upper(player.DisplayName) .. "'S LAB"
        else
            text = "CLAIMED LAB"
        end
        sign.Color = Color3.fromRGB(40, 210, 145)
    else
        sign.Color = Color3.fromRGB(40, 48, 60)
    end

    for _, descendant in ipairs(sign:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            descendant.Text = text
        end
    end

    ensureBackSign(sign, text)
end

-- Light every player lab and keep ownership signage synced to the actual model attribute.
for _, child in ipairs(world:GetChildren()) do
    if child:IsA("Model") and child.Name:match("^Lab_%d+$") then
        local floor = child:FindFirstChild("Floor")
        if floor then
            for i, x in ipairs({-11, 0, 11}) do
                makeFixture(
                    child,
                    "CeilingLight_" .. i,
                    floor.CFrame * CFrame.new(x, 7.8, 0),
                    Vector3.new(7, 0.25, 2),
                    Color3.fromRGB(195, 225, 255),
                    2.8,
                    28
                )
            end
        end

        updateLabSign(child)
        child:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
            updateLabSign(child)
        end)
    end
end

-- Central Containment gets bright overhead fixtures so loot and hazards are readable.
local central = world:FindFirstChild("CentralFacility")
if central then
    local positions = {
        Vector3.new(-25, 10.5, -25), Vector3.new(0, 10.5, -25), Vector3.new(25, 10.5, -25),
        Vector3.new(-25, 10.5, 0),   Vector3.new(0, 10.5, 0),   Vector3.new(25, 10.5, 0),
        Vector3.new(-25, 10.5, 25),  Vector3.new(0, 10.5, 25),  Vector3.new(25, 10.5, 25),
    }

    for i, position in ipairs(positions) do
        makeFixture(
            central,
            "FacilityLight_" .. i,
            CFrame.new(position),
            Vector3.new(8, 0.25, 2),
            Color3.fromRGB(205, 230, 255),
            2.5,
            30
        )
    end
end

-- Low path lights make the route between labs and Central readable without turning it into daytime.
for i = 1, 12 do
    local angle = ((i - 1) / 12) * math.pi * 2
    local radius = 78
    local position = Vector3.new(math.cos(angle) * radius, 2.5, math.sin(angle) * radius)
    makeFixture(
        polishFolder,
        "PathLight_" .. i,
        CFrame.new(position),
        Vector3.new(0.8, 4.5, 0.8),
        Color3.fromRGB(95, 205, 255),
        1.8,
        24
    )
end
