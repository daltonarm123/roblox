local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.Main.Services.DataService)

local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local toastEvent = remotes:WaitForChild("Toast")

local abilityRequest = remotes:FindFirstChild("AbilityRequest") or Instance.new("RemoteEvent")
abilityRequest.Name = "AbilityRequest"
abilityRequest.Parent = remotes

local abilityState = remotes:FindFirstChild("AbilityState") or Instance.new("RemoteEvent")
abilityState.Name = "AbilityState"
abilityState.Parent = remotes

local abilityEffect = remotes:FindFirstChild("AbilityEffect") or Instance.new("RemoteEvent")
abilityEffect.Name = "AbilityEffect"
abilityEffect.Parent = remotes

local cooldowns = {}
local globalNext = {
    StaticBurst = 0,
    JumpScare = 0,
}
local cloakTokens = {}

local function toast(player, message)
    if player and player.Parent then
        toastEvent:FireClient(player, message)
    end
end

local function waitForProfile(player)
    local deadline = os.clock() + 15
    repeat
        local profile = DataService.Get(player)
        if profile then return profile end
        task.wait(0.1)
    until os.clock() >= deadline or not player.Parent
    return nil
end

local function sendState(player)
    local profile = DataService.Get(player)
    if not profile then return end
    local now = os.time()
    local state = {}
    for abilityId, ability in pairs(Config.Abilities) do
        local playerCooldowns = cooldowns[player.UserId] or {}
        state[abilityId] = {
            Name = ability.Name,
            Description = ability.Description,
            ResearchCost = ability.ResearchCost,
            Charges = DataService.GetAbilityCharges(player, abilityId),
            CooldownRemaining = math.max(0, (playerCooldowns[abilityId] or 0) - now),
        }
    end
    abilityState:FireClient(player, {
        Research = profile.Research,
        Abilities = state,
    })
end

local function setCloak(player, duration)
    local character = player.Character
    if not character then return false end
    if character:FindFirstChild("CarriedSpecimen") then
        toast(player, "Phase Cloak cannot be used while carrying an anomaly.")
        return false
    end

    cloakTokens[player] = (cloakTokens[player] or 0) + 1
    local token = cloakTokens[player]
    local originals = {}

    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            originals[descendant] = descendant.Transparency
            descendant.Transparency = math.max(descendant.Transparency, 0.82)
        elseif descendant:IsA("Decal") then
            originals[descendant] = descendant.Transparency
            descendant.Transparency = 1
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PhaseCloakShimmer"
    highlight.FillTransparency = 0.96
    highlight.OutlineTransparency = 0.45
    highlight.OutlineColor = Color3.fromRGB(80, 220, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    local function restore()
        if cloakTokens[player] ~= token then return end
        cloakTokens[player] = token + 1
        if highlight.Parent then highlight:Destroy() end
        for instance, transparency in pairs(originals) do
            if instance and instance.Parent then
                instance.Transparency = transparency
            end
        end
    end

    task.spawn(function()
        local finishAt = os.clock() + duration
        while player.Parent and os.clock() < finishAt and cloakTokens[player] == token do
            local currentCharacter = player.Character
            if currentCharacter ~= character or character:FindFirstChild("CarriedSpecimen") then
                toast(player, "Phase Cloak cancelled because you started carrying an anomaly.")
                break
            end
            task.wait(0.2)
        end
        restore()
    end)

    return true
end

local function payForUse(player, abilityId)
    if DataService.ConsumeAbilityCharge(player, abilityId) then
        return true, "CHARGE"
    end

    local ability = Config.Abilities[abilityId]
    if not ability then return false, "INVALID" end
    if DataService.SpendResearch(player, ability.ResearchCost) then
        return true, "RESEARCH"
    end
    return false, "NOT_ENOUGH"
end

local function affectRivals(source, payload)
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= source then
            abilityEffect:FireClient(target, payload)
        end
    end
end

abilityRequest.OnServerEvent:Connect(function(player, abilityId)
    if type(abilityId) ~= "string" then return end
    local ability = Config.Abilities[abilityId]
    if not ability then return end
    if not waitForProfile(player) then return end

    local now = os.time()
    cooldowns[player.UserId] = cooldowns[player.UserId] or {}
    local playerCooldowns = cooldowns[player.UserId]
    if now < (playerCooldowns[abilityId] or 0) then
        toast(player, string.format("%s is cooling down for %ds.", ability.Name, (playerCooldowns[abilityId] or 0) - now))
        sendState(player)
        return
    end

    if (abilityId == "StaticBurst" or abilityId == "JumpScare") and now < (globalNext[abilityId] or 0) then
        toast(player, "Someone just used that server-wide ability. Try again in a few seconds.")
        return
    end

    if abilityId == "Cloak" then
        local character = player.Character
        if not character or character:FindFirstChild("CarriedSpecimen") then
            toast(player, "Phase Cloak cannot be activated while carrying an anomaly.")
            return
        end
    end

    local paid, method = payForUse(player, abilityId)
    if not paid then
        toast(player, string.format("You need %d Research or a free %s charge.", ability.ResearchCost, ability.Name))
        sendState(player)
        return
    end

    local successful = true
    if abilityId == "StaticBurst" then
        globalNext.StaticBurst = now + 12
        affectRivals(player, {
            Type = "StaticBurst",
            Source = player.DisplayName,
            Duration = ability.Duration,
        })
        toast(player, "STATIC BURST fired — rival screens scrambled briefly.")
    elseif abilityId == "JumpScare" then
        globalNext.JumpScare = now + 20
        affectRivals(player, {
            Type = "JumpScare",
            Source = player.DisplayName,
            Duration = ability.Duration,
        })
        toast(player, "BREACH SCARE transmitted to every rival.")
    elseif abilityId == "Cloak" then
        successful = setCloak(player, ability.Duration)
        if successful then
            toast(player, "PHASE CLOAK ACTIVE for 15 seconds. Picking up loot cancels it.")
        end
    end

    if not successful then
        -- Refund the currency/charge if the effect could not actually start.
        if method == "CHARGE" then
            DataService.AddAbilityCharge(player, abilityId, 1)
        else
            DataService.AddResearch(player, ability.ResearchCost)
        end
        sendState(player)
        return
    end

    playerCooldowns[abilityId] = now + ability.Cooldown
    sendState(player)
end)

Players.PlayerRemoving:Connect(function(player)
    cooldowns[player.UserId] = nil
    cloakTokens[player] = nil
end)

task.spawn(function()
    while true do
        task.wait(1)
        for _, player in ipairs(Players:GetPlayers()) do
            if DataService.Get(player) then
                sendState(player)
            end
        end
    end
end)
