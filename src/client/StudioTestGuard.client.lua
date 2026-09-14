local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- This guard only runs in an unpublished local Studio place. It does not run in
-- published/live servers, so production avatar animations and sounds are untouched.
if not RunService:IsStudio() or game.GameId ~= 0 then
    return
end

local player = Players.LocalPlayer

local CHARACTER_SOUND_NAMES = {
    Climbing = true,
    Died = true,
    FreeFalling = true,
    GettingUp = true,
    Jumping = true,
    Landing = true,
    Running = true,
    Splash = true,
    Swimming = true,
}

local function destroyTrack(track)
    pcall(function()
        track:Stop(0)
    end)
    pcall(function()
        track:Destroy()
    end)
end

local function quietCharacter(character)
    -- If Roblox asset delivery is unavailable (for example, a moderated Studio
    -- session), the stock Animate script can repeatedly create failed tracks until
    -- the Animator reaches its 64-track limit. Disable it only for this local test.
    local animate = character:FindFirstChild("Animate") or character:WaitForChild("Animate", 3)
    if animate and animate:IsA("LocalScript") then
        animate.Disabled = true
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 3)
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            destroyTrack(track)
        end
    end

    -- Default character sounds are also Roblox-hosted assets. Remove only the stock
    -- character sounds in this local unpublished test so a blocked asset endpoint
    -- does not flood Output. Game audio in SoundService is left alone.
    local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 3)
    if root then
        local function removeStockSound(instance)
            if instance:IsA("Sound") and CHARACTER_SOUND_NAMES[instance.Name] then
                instance:Destroy()
            end
        end

        for _, descendant in ipairs(root:GetDescendants()) do
            removeStockSound(descendant)
        end
        root.DescendantAdded:Connect(removeStockSound)
    end
end

local function onCharacter(character)
    task.defer(quietCharacter, character)
end

player.CharacterAdded:Connect(onCharacter)
if player.Character then
    onCharacter(player.Character)
end

warn("ContainmentHeist: unpublished Studio test guard enabled; stock avatar animations/sounds are disabled for this session.")
