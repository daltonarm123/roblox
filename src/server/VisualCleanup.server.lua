local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("ContainmentHeistWorld")

local configuredLabels = setmetatable({}, { __mode = "k" })

local function configureBillboard(gui)
    if configuredLabels[gui] or not gui:IsA("BillboardGui") then
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
