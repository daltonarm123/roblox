local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.Main.Services.DataService)

local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local toastEvent = remotes:WaitForChild("Toast")

local seasonState = remotes:FindFirstChild("SeasonState") or Instance.new("RemoteEvent")
seasonState.Name = "SeasonState"
seasonState.Parent = remotes

local sessions = {}

local function toast(player, message)
    if player and player.Parent then
        toastEvent:FireClient(player, message)
    end
end

local function rewardText(reward)
    local text = string.format("%d Research", reward.Research or 0)
    if reward.Ability and (reward.AbilityCount or 0) > 0 then
        local ability = Config.Abilities[reward.Ability]
        text ..= string.format(" + %dx %s", reward.AbilityCount, ability and ability.Name or reward.Ability)
    end
    return text
end

local function grantReward(player, tier, premium)
    local reward = Config.GetSeasonReward(tier, premium)
    if reward.Research and reward.Research > 0 then
        DataService.AddResearch(player, reward.Research)
    end
    if reward.Ability and (reward.AbilityCount or 0) > 0 then
        DataService.AddAbilityCharge(player, reward.Ability, reward.AbilityCount)
    end
    toast(player, string.format("SEASON TIER %d %s REWARD: %s", tier, premium and "PREMIUM" or "FREE", rewardText(reward)))
end

local function grantEarnedTiers(player, profile)
    local achievedTier = math.clamp(math.floor(profile.SeasonXP / Config.Season.XPPerTier), 0, Config.Season.MaxTier)

    while profile.SeasonFreeClaimed < achievedTier do
        profile.SeasonFreeClaimed += 1
        grantReward(player, profile.SeasonFreeClaimed, false)
    end

    if DataService.HasSeasonPremium(player) then
        while profile.SeasonPremiumClaimed < achievedTier do
            profile.SeasonPremiumClaimed += 1
            grantReward(player, profile.SeasonPremiumClaimed, true)
        end
    end
end

local function checkMissions(player, profile)
    for _, mission in ipairs(Config.Season.Missions) do
        local progress = profile.DailyProgress[mission.Id] or 0
        if not profile.DailyCompleted[mission.Id] and progress >= mission.Target then
            DataService.SetMissionCompleted(player, mission.Id)
            DataService.AddSeasonXP(player, mission.XP)
            toast(player, string.format("DAILY COMPLETE: %s  +%d Season XP", mission.Name, mission.XP))
        end
    end
end

local function sendState(player, profile)
    local missions = {}
    for _, mission in ipairs(Config.Season.Missions) do
        table.insert(missions, {
            Id = mission.Id,
            Name = mission.Name,
            Target = mission.Target,
            XP = mission.XP,
            Progress = math.min(mission.Target, profile.DailyProgress[mission.Id] or 0),
            Completed = profile.DailyCompleted[mission.Id] == true,
        })
    end

    local achievedTier = math.clamp(math.floor(profile.SeasonXP / Config.Season.XPPerTier), 0, Config.Season.MaxTier)
    local xpIntoTier = profile.SeasonXP % Config.Season.XPPerTier
    if achievedTier >= Config.Season.MaxTier then
        xpIntoTier = Config.Season.XPPerTier
    end

    local nextTier = math.min(Config.Season.MaxTier, achievedTier + 1)
    seasonState:FireClient(player, {
        SeasonId = Config.Season.Id,
        SeasonName = Config.Season.Name,
        Tier = achievedTier,
        MaxTier = Config.Season.MaxTier,
        XP = profile.SeasonXP,
        XPIntoTier = xpIntoTier,
        XPPerTier = Config.Season.XPPerTier,
        Premium = DataService.HasSeasonPremium(player),
        SuggestedPremiumPrice = Config.Season.SuggestedPremiumPrice,
        Missions = missions,
        NextFreeReward = rewardText(Config.GetSeasonReward(nextTier, false)),
        NextPremiumReward = rewardText(Config.GetSeasonReward(nextTier, true)),
    })
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

local function setupPlayer(player)
    task.spawn(function()
        local profile = waitForProfile(player)
        if not profile then return end
        DataService.EnsureDaily(player)
        sessions[player] = {
            LastResearch = profile.Research,
            LastContained = #profile.Specimens,
            LastShieldUses = player:GetAttribute("ShieldUses") or 0,
        }
        grantEarnedTiers(player, profile)
        sendState(player, profile)
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    sessions[player] = nil
end)
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

task.spawn(function()
    while true do
        task.wait(1)
        for player, session in pairs(sessions) do
            if not player.Parent then
                sessions[player] = nil
                continue
            end

            local profile = DataService.EnsureDaily(player)
            if not profile then continue end

            DataService.RecordMissionProgress(player, "PlaySeconds", 1)

            local researchNow = profile.Research
            local researchGain = researchNow - session.LastResearch
            if researchGain > 0 then
                DataService.RecordMissionProgress(player, "ResearchEarned", researchGain)
            end

            local containedNow = #profile.Specimens
            local containedGain = containedNow - session.LastContained
            if containedGain > 0 then
                DataService.RecordMissionProgress(player, "Contained", containedGain)
            end

            local shieldUses = player:GetAttribute("ShieldUses") or 0
            local shieldGain = shieldUses - session.LastShieldUses
            if shieldGain > 0 then
                DataService.RecordMissionProgress(player, "Shields", shieldGain)
            end

            checkMissions(player, profile)
            grantEarnedTiers(player, profile)

            -- Reset baselines after mission/tier rewards so reward Research does not
            -- recursively count toward the daily earn-Research mission.
            session.LastResearch = profile.Research
            session.LastContained = #profile.Specimens
            session.LastShieldUses = player:GetAttribute("ShieldUses") or 0

            sendState(player, profile)
        end
    end
end)
