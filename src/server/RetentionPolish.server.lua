local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("ContainmentHeistWorld")
local lastShieldUntil = {}

local function polishTerminalLabel(gui)
    if not gui:IsA("BillboardGui") or gui.Name ~= "TerminalLabel" then return end
    gui.Size = UDim2.fromOffset(128, 42)
    gui.StudsOffset = Vector3.new(0, 2.2, 0)
    gui.MaxDistance = 28
    gui.AlwaysOnTop = false

    local label = gui:FindFirstChildOfClass("TextLabel")
    if label then
        label.TextScaled = true
        label.TextWrapped = true
    end
end

for _, descendant in ipairs(world:GetDescendants()) do
    polishTerminalLabel(descendant)
end
world.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BillboardGui") then
        task.defer(polishTerminalLabel, descendant)
    end
end)

local function watchLab(lab)
    if not lab:IsA("Model") or not lab.Name:match("^Lab_%d+$") then return end
    lastShieldUntil[lab] = lab:GetAttribute("EmergencyShieldUntil") or 0

    lab:GetAttributeChangedSignal("EmergencyShieldUntil"):Connect(function()
        local previous = lastShieldUntil[lab] or 0
        local current = lab:GetAttribute("EmergencyShieldUntil") or 0
        lastShieldUntil[lab] = current
        if current <= previous or current <= os.time() then return end

        local ownerId = lab:GetAttribute("OwnerUserId") or 0
        local owner = ownerId ~= 0 and Players:GetPlayerByUserId(ownerId) or nil
        if owner then
            owner:SetAttribute("ShieldUses", (owner:GetAttribute("ShieldUses") or 0) + 1)
        end
    end)
end

for _, child in ipairs(world:GetChildren()) do
    watchLab(child)
end
world.ChildAdded:Connect(watchLab)
