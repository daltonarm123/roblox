local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("ContainmentHeistWorld")

local configuredLabels = setmetatable({}, { __mode = "k" })

local function configureBillboard(gui)
    if configuredLabels[gui] or not gui:IsA("BillboardGui") then
        return
    end

    -- Rare breach markers intentionally render from far away; do not shrink them.
    if gui.Name == "RareBreachLabel" then
        return
    end

    configuredLabels[gui] = true

    gui.MaxDistance = 58
    gui.AlwaysOnTop = false

    if gui.Name == "SpecimenLabel" then
        gui.Size = UDim2.fromOffset(145, 44)
        gui.StudsOffset = Vector3.new(0, 2.8, 0)
    elseif gui.Size.X.Offset >= 180 or gui.Size.Y.Offset >= 55 then
        gui.Size = UDim2.fromOffset(140, 42)
        gui.StudsOffset = Vector3.new(0, 2.8, 0)
    end

    local label = gui:FindFirstChildOfClass("TextLabel")
    if not label then
        return
    end

    local function updateVisibility()
        gui.Enabled = label.Text ~= "EMPTY" and label.Text ~= ""
    end

    updateVisibility()
    label:GetPropertyChangedSignal("Text"):Connect(updateVisibility)
end

local function addOwnerFace(sign, face, text)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "OwnerDisplay"
    gui.Face = face
    gui.AlwaysOnTop = true
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 32
    gui.Parent = sign

    local label = Instance.new("TextLabel")
    label.Name = "OwnerText"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.3
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

local function updateLabSign(lab)
    if not lab:IsA("Model") or not string.match(lab.Name, "^Lab_%d+$") then
        return
    end

    local sign = lab:FindFirstChild("OwnerSign")
    if not sign or not sign:IsA("BasePart") then
        return
    end

    local ownerUserId = lab:GetAttribute("OwnerUserId") or 0
    local text = "UNCLAIMED LAB"

    if ownerUserId ~= 0 then
        local owner = Players:GetPlayerByUserId(ownerUserId)
        if owner then
            text = string.upper(owner.DisplayName) .. "'S LAB"
        else
            text = "CLAIMED LAB"
        end
        sign.Color = Color3.fromRGB(35, 120, 85)
    else
        sign.Color = Color3.fromRGB(15, 20, 26)
    end

    for _, child in ipairs(sign:GetChildren()) do
        if child:IsA("SurfaceGui") then
            child:Destroy()
        end
    end

    -- Mirror the owner text on both sides so it is readable from either approach.
    addOwnerFace(sign, Enum.NormalId.Front, text)
    addOwnerFace(sign, Enum.NormalId.Back, text)
end

for _, descendant in ipairs(world:GetDescendants()) do
    if descendant:IsA("BillboardGui") then
        configureBillboard(descendant)
    end
end

world.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BillboardGui") then
        task.defer(configureBillboard, descendant)
    end
end)

for _, child in ipairs(world:GetChildren()) do
    if child:IsA("Model") and string.match(child.Name, "^Lab_%d+$") then
        updateLabSign(child)
        child:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
            updateLabSign(child)
        end)
    end
end
