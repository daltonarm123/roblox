local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Services.DataService)
local WorldService = require(script.Services.WorldService)

local world = WorldService.Build()

local remotes = Instance.new("Folder")
remotes.Name = "ContainmentRemotes"
remotes.Parent = ReplicatedStorage

local stateEvent = Instance.new("RemoteEvent")
stateEvent.Name = "State"
stateEvent.Parent = remotes

local toastEvent = Instance.new("RemoteEvent")
toastEvent.Name = "Toast"
toastEvent.Parent = remotes

local carrying = {}
local centralActive = {}
local raidProtectedUntil = {}
local touchDebounce = {}

local function weightedPick(list)
    local total = 0
    for _, item in ipairs(list) do
        total += item.Weight
    end
    local roll = math.random() * total
    local cursor = 0
    for _, item in ipairs(list) do
        cursor += item.Weight
        if roll <= cursor then
            return item
        end
    end
    return list[#list]
end

local function getPlayerByBaseIndex(baseIndex)
    local base = world.Bases[baseIndex]
    if not base or base.OwnerUserId == 0 then return nil end
    return Players:GetPlayerByUserId(base.OwnerUserId)
end

local function toast(player, message)
    if player and player.Parent then
        toastEvent:FireClient(player, message)
    end
end

local function toastAll(message)
    toastEvent:FireAllClients(message)
end

local function updateLeaderstats(player)
    local profile = DataService.Get(player)
    local stats = player:FindFirstChild("leaderstats")
    if not profile or not stats then return end
    local research = stats:FindFirstChild("Research")
    local anomalies = stats:FindFirstChild("Anomalies")
    if research then research.Value = math.floor(profile.Research) end
    if anomalies then anomalies.Value = #profile.Specimens end
end

local function sendState(player)
    local profile = DataService.Get(player)
    if not profile then return end
    local carry = carrying[player.UserId]
    stateEvent:FireClient(player, {
        Research = math.floor(profile.Research),
        Income = DataService.GetIncome(player),
        SpecimenCount = #profile.Specimens,
        Capacity = Config.GetCapacity(profile.CapacityLevel),
        SpeedLevel = profile.SpeedLevel,
        CapacityLevel = profile.CapacityLevel,
        SpeedCost = profile.SpeedLevel < Config.SpeedUpgrade.MaxLevel and Config.GetSpeedCost(profile.SpeedLevel) or -1,
        CapacityCost = profile.CapacityLevel < Config.CapacityUpgrade.MaxLevel and Config.GetCapacityCost(profile.CapacityLevel) or -1,
        Carrying = carry and carry.DisplayName or nil,
        BaseIndex = (WorldService.FindPlayerBase(player) and WorldService.FindPlayerBase(player).Index) or 0,
    })
    updateLeaderstats(player)
end

local function refreshBase(player)
    local base = WorldService.FindPlayerBase(player)
    local profile = DataService.Get(player)
    if not base or not profile then return end
    for slot = 1, Config.MaxCapacity do
        WorldService.SetPod(base.Index, slot, profile.Specimens[slot])
    end
end

local function applyMovement(player, character)
    local profile = DataService.Get(player)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if profile and humanoid then
        humanoid.WalkSpeed = Config.GetWalkSpeed(profile.SpeedLevel)
    end
end

local function destroyCarryVisual(player)
    local character = player.Character
    if character then
        local visual = character:FindFirstChild("CarriedSpecimen")
        if visual then visual:Destroy() end
    end
end

local function makeCarryVisual(player, specimen, variant)
    destroyCarryVisual(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local visual = Instance.new("Part")
    visual.Name = "CarriedSpecimen"
    visual.Size = specimen.Shape == "Block" and Vector3.new(2.5, 2.5, 2.5) or Vector3.new(2.6, 2.6, 2.6)
    visual.Shape = specimen.Shape == "Ball" and Enum.PartType.Ball or Enum.PartType.Block
    visual.Material = variant.Id == "Normal" and Enum.Material.SmoothPlastic or Enum.Material.Neon
    visual.Color = specimen.Color
    visual.CanCollide = false
    visual.Massless = true
    visual.CFrame = root.CFrame * CFrame.new(0, 1.2, 2.4)
    visual.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = visual
    weld.Parent = visual

    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(170, 52)
    gui.StudsOffset = Vector3.new(0, 2.2, 0)
    gui.AlwaysOnTop = true
    gui.Parent = visual
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.2
    label.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.Text = variant.Name .. " " .. specimen.Name
    label.Parent = gui
end

local function beginCarry(player, specimenId, variantId, originPlayer)
    if carrying[player.UserId] then return false end
    local specimen = Config.GetSpecimenById(specimenId)
    local variant = Config.GetVariantById(variantId)
    if not specimen or not variant then return false end

    carrying[player.UserId] = {
        SpecimenId = specimenId,
        VariantId = variantId,
        DisplayName = variant.Name .. " " .. specimen.Name,
        OriginUserId = originPlayer and originPlayer.UserId or 0,
    }
    makeCarryVisual(player, specimen, variant)
    sendState(player)
    return true
end

local function clearCarry(player, returnToOwner)
    local data = carrying[player.UserId]
    if not data then return end
    carrying[player.UserId] = nil
    destroyCarryVisual(player)

    if returnToOwner and data.OriginUserId and data.OriginUserId ~= 0 then
        local owner = Players:GetPlayerByUserId(data.OriginUserId)
        if owner and DataService.AddSpecimen(owner, data.SpecimenId, data.VariantId) then
            refreshBase(owner)
            sendState(owner)
            toast(owner, "Security recovered one of your stolen specimens.")
        end
    end
    sendState(player)
end

local function centralLabel(target, text)
    local gui = Instance.new("BillboardGui")
    gui.Name = "SpecimenLabel"
    gui.Size = UDim2.fromOffset(190, 62)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = target
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.2
    label.BackgroundColor3 = Color3.fromRGB(8, 11, 15)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.Parent = gui
end

local spawnCentral

local function removeCentral(index)
    local current = centralActive[index]
    if current and current.Part then
        current.Part:Destroy()
    end
    centralActive[index] = nil
end

spawnCentral = function(index, forceLegendary)
    removeCentral(index)
    local pedestal = world.Pedestals[index]
    if not pedestal then return end

    local specimen = forceLegendary and Config.GetSpecimenById("StarParasite") or weightedPick(Config.Specimens)
    local variant = forceLegendary and Config.GetVariantById("Glowing") or weightedPick(Config.Variants)

    local item = Instance.new("Part")
    item.Name = "CentralSpecimen_" .. index
    item.Size = specimen.Shape == "Block" and Vector3.new(3, 3, 3) or Vector3.new(3.2, 3.2, 3.2)
    item.Shape = specimen.Shape == "Ball" and Enum.PartType.Ball or Enum.PartType.Block
    item.Anchored = true
    item.CanCollide = false
    item.Material = variant.Id == "Normal" and Enum.Material.SmoothPlastic or Enum.Material.Neon
    item.Color = specimen.Color
    item.CFrame = pedestal.CFrame * CFrame.new(0, 2.3, 0)
    item.Parent = world.Central

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "TAKE"
    prompt.ObjectText = variant.Name .. " " .. specimen.Name
    prompt.HoldDuration = specimen.Rarity == "Legendary" and 1.5 or 0.55
    prompt.MaxActivationDistance = 9
    prompt.RequiresLineOfSight = false
    prompt.Parent = item

    local income = math.floor(specimen.Income * variant.Multiplier)
    centralLabel(item, string.format("%s\n%s • %d R/s", specimen.Name, variant.Name, income))
    centralActive[index] = { Part = item, SpecimenId = specimen.Id, VariantId = variant.Id }

    prompt.Triggered:Connect(function(player)
        if centralActive[index] == nil or carrying[player.UserId] then return end
        local profile = DataService.Get(player)
        if not profile then return end
        if #profile.Specimens >= Config.GetCapacity(profile.CapacityLevel) then
            toast(player, "Your lab is full. Upgrade CAPACITY first.")
            return
        end

        local active = centralActive[index]
        centralActive[index] = nil
        item:Destroy()
        beginCarry(player, active.SpecimenId, active.VariantId, nil)
        toast(player, "ALARM! Get the specimen back to your green containment pad.")

        task.delay(Config.SpecimenRespawnSeconds, function()
            if world and world.Pedestals[index] and centralActive[index] == nil then
                spawnCentral(index, false)
            end
        end)
    end)
end

local function bindDeposit(base)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "CONTAIN"
    prompt.ObjectText = "Your Lab"
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = base.Deposit

    prompt.Triggered:Connect(function(player)
        if base.OwnerUserId ~= player.UserId then
            toast(player, "That is not your lab.")
            return
        end
        local carry = carrying[player.UserId]
        if not carry then
            toast(player, "You are not carrying a specimen.")
            return
        end
        if DataService.AddSpecimen(player, carry.SpecimenId, carry.VariantId) then
            carrying[player.UserId] = nil
            destroyCarryVisual(player)
            refreshBase(player)
            sendState(player)
            local specimen = Config.GetSpecimenById(carry.SpecimenId)
            local variant = Config.GetVariantById(carry.VariantId)
            toast(player, string.format("Contained %s %s! It now earns Research every second.", variant.Name, specimen.Name))
        else
            toast(player, "Your lab is full.")
        end
    end)
end

local function bindUpgrade(base, pad, kind)
    local prompt = pad:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return end
    prompt.Triggered:Connect(function(player)
        if base.OwnerUserId ~= player.UserId then
            toast(player, "Only the lab owner can use this upgrade.")
            return
        end
        local ok, reason
        if kind == "Speed" then
            ok, reason = DataService.BuySpeed(player)
            if ok and player.Character then applyMovement(player, player.Character) end
        else
            ok, reason = DataService.BuyCapacity(player)
        end
        if ok then
            toast(player, kind .. " upgraded!")
            refreshBase(player)
            sendState(player)
        elseif reason == "NOT_ENOUGH" then
            toast(player, "Not enough Research yet.")
        else
            toast(player, kind .. " is already maxed.")
        end
    end)
end

local function bindRaid(base, slotIndex, pod)
    pod.Prompt.Triggered:Connect(function(raider)
        if base.OwnerUserId == 0 or base.OwnerUserId == raider.UserId then return end
        if carrying[raider.UserId] then
            toast(raider, "You can only carry one specimen at a time.")
            return
        end

        local owner = getPlayerByBaseIndex(base.Index)
        if not owner then return end
        if (raidProtectedUntil[owner.UserId] or 0) > os.clock() then
            toast(raider, "That lab still has new-player security shielding.")
            return
        end

        local stolen = DataService.RemoveSpecimenAt(owner, slotIndex)
        if not stolen then return end
        refreshBase(owner)
        sendState(owner)
        beginCarry(raider, stolen.SpecimenId, stolen.VariantId, owner)

        local specimen = Config.GetSpecimenById(stolen.SpecimenId)
        toast(owner, raider.DisplayName .. " stole your " .. specimen.Name .. "!")
        toast(raider, "HEIST! Escape to your lab before you lose the specimen.")
    end)
end

for _, base in ipairs(world.Bases) do
    bindDeposit(base)
    bindUpgrade(base, base.SpeedPad, "Speed")
    bindUpgrade(base, base.CapacityPad, "Capacity")
    for slotIndex, pod in ipairs(base.Pods) do
        bindRaid(base, slotIndex, pod)
    end
end

for _, descendant in ipairs(world.Central:GetDescendants()) do
    if descendant:IsA("BasePart") and descendant:GetAttribute("SecurityLaser") then
        descendant.Touched:Connect(function(hit)
            local character = hit:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)
            if not player or not carrying[player.UserId] then return end
            local now = os.clock()
            if (touchDebounce[player.UserId] or 0) > now then return end
            touchDebounce[player.UserId] = now + 2
            clearCarry(player, true)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:TakeDamage(20) end
            toast(player, "SECURITY SCAN! You dropped the specimen.")
        end)
    end
end

local function setupPlayer(player)
    local profile = DataService.Load(player)

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    local research = Instance.new("IntValue")
    research.Name = "Research"
    research.Parent = leaderstats
    local anomalies = Instance.new("IntValue")
    anomalies.Name = "Anomalies"
    anomalies.Parent = leaderstats

    local base = WorldService.ClaimBase(player)
    if not base then
        toast(player, "Server is full: no lab was available.")
    end
    raidProtectedUntil[player.UserId] = os.clock() + Config.RaidGraceSeconds

    if base then refreshBase(player) end
    sendState(player)

    player.CharacterAdded:Connect(function(character)
        task.wait(0.25)
        applyMovement(player, character)
        if base then
            local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
            if root then root.CFrame = base.Facing * CFrame.new(0, 4, -12) end
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                clearCarry(player, true)
            end)
        end
    end)

    if player.Character then
        task.defer(applyMovement, player, player.Character)
    end

    task.delay(1.5, function()
        if player.Parent and profile.OfflineAward and profile.OfflineAward > 0 then
            toast(player, string.format("Your contained anomalies produced %d Research while you were away!", profile.OfflineAward))
            profile.OfflineAward = 0
        end
        if player.Parent then
            toast(player, "Raid the central facility, grab an anomaly, and bring it back to your green pad.")
        end
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    clearCarry(player, true)
    WorldService.ReleaseBase(player)
    raidProtectedUntil[player.UserId] = nil
    touchDebounce[player.UserId] = nil
    DataService.Release(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end

for index = 1, Config.CentralSpawnCount do
    spawnCentral(index, false)
end

task.spawn(function()
    while true do
        task.wait(1)
        for _, player in ipairs(Players:GetPlayers()) do
            local income = DataService.GetIncome(player)
            if income > 0 then
                DataService.AddResearch(player, income)
            end
            sendState(player)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(Config.RareEventSeconds)
        local index = math.random(1, Config.CentralSpawnCount)
        spawnCentral(index, true)
        toastAll("⚠ RARE BREACH: A GLOWING STAR PARASITE just appeared in Central Containment!")
    end
end)

task.spawn(function()
    while true do
        task.wait(Config.AutosaveSeconds)
        for _, player in ipairs(Players:GetPlayers()) do
            DataService.Save(player)
        end
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        DataService.Save(player)
    end
    if not RunService:IsStudio() then
        task.wait(2)
    end
end)
