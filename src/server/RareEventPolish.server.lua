local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("ContainmentHeistWorld")
local central = world:WaitForChild("CentralFacility")

local marked = setmetatable({}, { __mode = "k" })

local function nearestPedestal(part)
    local bestIndex = 0
    local bestDistance = math.huge
    for _, child in ipairs(central:GetChildren()) do
        local index = tonumber(child.Name:match("^Pedestal_(%d+)$"))
        if index and child:IsA("BasePart") then
            local distance = (child.Position - part.Position).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                bestIndex = index
            end
        end
    end
    return bestIndex
end

local function markRare(part)
    if marked[part] or not part:IsA("BasePart") then return end

    task.defer(function()
        if not part.Parent then return end
        local prompt = part:FindFirstChildOfClass("ProximityPrompt") or part:WaitForChild("ProximityPrompt", 2)
        if not prompt or not string.find(string.lower(prompt.ObjectText), "glowing star parasite", 1, true) then
            return
        end

        marked[part] = true
        part:SetAttribute("RareBreachVisual", true)
        part.Size = Vector3.new(4.6, 4.6, 4.6)

        local pedestalIndex = nearestPedestal(part)

        local highlight = Instance.new("Highlight")
        highlight.Name = "RareBreachHighlight"
        highlight.FillColor = Color3.fromRGB(255, 205, 55)
        highlight.OutlineColor = Color3.fromRGB(255, 80, 65)
        highlight.FillTransparency = 0.35
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = part
        highlight.Parent = part

        local light = Instance.new("PointLight")
        light.Name = "RareBreachLight"
        light.Color = Color3.fromRGB(255, 207, 70)
        light.Brightness = 6
        light.Range = 42
        light.Shadows = false
        light.Parent = part

        local sparkles = Instance.new("Sparkles")
        sparkles.SparkleColor = Color3.fromRGB(255, 230, 120)
        sparkles.Parent = part

        local marker = Instance.new("Part")
        marker.Name = "RareBreachBeacon"
        marker.Size = Vector3.new(2.2, 52, 2.2)
        marker.CFrame = CFrame.new(part.Position + Vector3.new(0, 28, 0))
        marker.Anchored = true
        marker.CanCollide = false
        marker.CanTouch = false
        marker.CanQuery = false
        marker.Material = Enum.Material.Neon
        marker.Color = Color3.fromRGB(255, 198, 45)
        marker.Transparency = 0.38
        marker.Parent = central

        local gui = Instance.new("BillboardGui")
        gui.Name = "RareBreachLabel"
        gui.Size = UDim2.fromOffset(250, 90)
        gui.StudsOffset = Vector3.new(0, 3.8, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 260
        gui.Parent = marker

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundColor3 = Color3.fromRGB(30, 12, 6)
        label.BackgroundTransparency = 0.08
        label.TextColor3 = Color3.fromRGB(255, 220, 85)
        label.TextStrokeTransparency = 0.3
        label.TextWrapped = true
        label.TextScaled = true
        label.Font = Enum.Font.GothamBlack
        label.Text = string.format("⚠ RARE BREACH ⚠\nGLOWING STAR PARASITE\nPEDESTAL #%d", pedestalIndex)
        label.Parent = gui
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)

        part.AncestryChanged:Connect(function(_, parent)
            if parent == nil and marker.Parent then
                marker:Destroy()
            end
        end)
    end)
end

for _, child in ipairs(central:GetChildren()) do
    if child:IsA("BasePart") and child.Name:match("^CentralSpecimen_") then
        markRare(child)
    end
end

central.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") and child.Name:match("^CentralSpecimen_") then
        markRare(child)
    end
end)
