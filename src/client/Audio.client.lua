local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AudioConfig = require(ReplicatedStorage.Shared.AudioConfig)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local toastEvent = remotes:WaitForChild("Toast")
local stateEvent = remotes:WaitForChild("State")

local soundFolder = SoundService:FindFirstChild("ContainmentAudio") or Instance.new("Folder")
soundFolder.Name = "ContainmentAudio"
soundFolder.Parent = SoundService

local function playCue(name)
    local cue = AudioConfig.Cues[name]
    if not cue or type(cue.Id) ~= "number" or cue.Id <= 0 then
        return
    end

    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = "rbxassetid://" .. tostring(cue.Id)
    sound.Volume = math.clamp((cue.Volume or 1) * (AudioConfig.MasterVolume or 1), 0, 10)
    sound.PlaybackSpeed = cue.PlaybackSpeed or 1
    sound.RollOffMaxDistance = 80
    sound.Parent = soundFolder
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    sound:Play()

    task.delay(8, function()
        if sound.Parent then
            sound:Destroy()
        end
    end)
end

local function classifyToast(message)
    local text = string.upper(tostring(message or ""))
    if string.find(text, "RARE BREACH", 1, true) then
        return "RareBreach"
    elseif string.find(text, "SECURITY", 1, true) or string.find(text, "ALARM", 1, true) or string.find(text, "HEIST", 1, true) then
        return "Security"
    elseif string.find(text, "CONTAINED", 1, true) or string.find(text, "SECURED", 1, true) then
        return "Deposit"
    elseif string.find(text, "SHIELD", 1, true) then
        return "Shield"
    elseif string.find(text, "LOCKDOWN", 1, true) then
        return "Lockdown"
    elseif string.find(text, "UPGRADED", 1, true) or string.find(text, "UNLOCKED", 1, true) or string.find(text, "PURCHASE COMPLETE", 1, true) or string.find(text, "DAILY COMPLETE", 1, true) then
        return "Upgrade"
    elseif string.find(text, "CLOAK", 1, true) or string.find(text, "STATIC BURST", 1, true) or string.find(text, "BREACH SCARE", 1, true) then
        return "Ability"
    elseif string.find(text, "NOT ENOUGH", 1, true) or string.find(text, "COOLING DOWN", 1, true) or string.find(text, "CANNOT", 1, true) then
        return "Error"
    end
end

toastEvent.OnClientEvent:Connect(function(message)
    local cue = classifyToast(message)
    if cue then
        playCue(cue)
    end
end)

local wasCarrying = false
stateEvent.OnClientEvent:Connect(function(state)
    local carryingNow = state.Carrying ~= nil
    if carryingNow and not wasCarrying then
        playCue("Pickup")
    end
    wasCarrying = carryingNow
end)

local connectedButtons = setmetatable({}, { __mode = "k" })
local function connectButton(instance)
    if connectedButtons[instance] or not instance:IsA("GuiButton") then
        return
    end
    connectedButtons[instance] = true
    instance.Activated:Connect(function()
        playCue("UIClick")
    end)
end

local playerGui = player:WaitForChild("PlayerGui")
for _, descendant in ipairs(playerGui:GetDescendants()) do
    connectButton(descendant)
end
playerGui.DescendantAdded:Connect(connectButton)

local function connectAbilityRemote(remote)
    if not remote:IsA("RemoteEvent") or remote.Name ~= "AbilityEffect" then return end
    remote.OnClientEvent:Connect(function()
        playCue("Ability")
    end)
end
local abilityEffect = remotes:FindFirstChild("AbilityEffect")
if abilityEffect then
    connectAbilityRemote(abilityEffect)
end
remotes.ChildAdded:Connect(connectAbilityRemote)

-- Future systems can fire AudioCue to request a named cue without knowing how
-- sounds are implemented on the client.
local function connectAudioRemote(remote)
    if remote:IsA("RemoteEvent") and remote.Name == "AudioCue" then
        remote.OnClientEvent:Connect(function(name)
            playCue(tostring(name))
        end)
    end
end

local existing = remotes:FindFirstChild("AudioCue")
if existing then
    connectAudioRemote(existing)
end
remotes.ChildAdded:Connect(connectAudioRemote)
