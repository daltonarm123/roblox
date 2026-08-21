local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.Main.Services.DataService)

local world = Workspace:WaitForChild("ContainmentHeistWorld")
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local toastEvent = remotes:WaitForChild("Toast")

local function toast(player, message)
    if player and player.Parent then
        toastEvent:FireClient(player, message)
    end
end

local function formatTime(seconds)
    seconds = math.max(0, math.ceil(seconds))
    if seconds >= 60 then
        return string.format("%dm %02ds", math.floor(seconds / 60), seconds % 60)
    end
    return tostring(seconds) .. "s"
end

local function makeBillboard(part, text, color)
    local gui = Instance.new("BillboardGui")
    gui.Name = "TerminalLabel"
    gui.Size = UDim2.fromOffset(175, 58)
    gui.StudsOffset = Vector3.new(0, 3.2, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 55
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
    label.BackgroundTransparency = 0.12
    label.TextColor3 = color
    label.TextWrapped = true
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label

    return label
end

local function makeTerminal(lab, floor, name, offsetX, color, actionText, objectText)
    local terminal = Instance.new("Part")
    terminal.Name = name
    terminal.Size = Vector3.new(5.5, 1, 5.5)
    terminal.CFrame = floor.CFrame * CFrame.new(offsetX, 0.55, -18)
    terminal.Anchored = true
    terminal.CanCollide = true
    terminal.Material = Enum.Material.Metal
    terminal.Color = Color3.fromRGB(35, 43, 54)
    terminal.Parent = lab

    local top = Instance.new("Part")
    top.Name = "Glow"
    top.Size = Vector3.new(4.8, 0.15, 4.8)
    top.CFrame = terminal.CFrame * CFrame.new(0, 0.58, 0)
    top.Anchored = true
    top.CanCollide = false
    top.Material = Enum.Material.Neon
    top.Color = color
    top.Parent = lab

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.HoldDuration = 0.45
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = terminal

    local label = makeBillboard(terminal, objectText, color)
    return terminal, prompt, label
end

local function makeDefenseVisuals(lab, floor)
    local folder = Instance.new("Folder")
    folder.Name = "DefenseVisuals"
    folder.Parent = lab

    local pieces = {}
    local specs = {
        {Vector3.new(38, 8, 0.35), CFrame.new(0, 4, -16)},
        {Vector3.new(38, 8, 0.35), CFrame.new(0, 4, 16)},
        {Vector3.new(0.35, 8, 32), CFrame.new(-19, 4, 0)},
        {Vector3.new(0.35, 8, 32), CFrame.new(19, 4, 0)},
    }

    for i, spec in ipairs(specs) do
        local wall = Instance.new("Part")
        wall.Name = "ShieldWall_" .. i
        wall.Size = spec[1]
        wall.CFrame = floor.CFrame * spec[2]
        wall.Anchored = true
        wall.CanCollide = false
        wall.CanTouch = false
        wall.Material = Enum.Material.ForceField
        wall.Color = Color3.fromRGB(75, 215, 255)
        wall.Transparency = 1
        wall.Parent = folder
        pieces[i] = wall
    end

    local gate = Instance.new("Part")
    gate.Name = "LockdownGate"
    gate.Size = Vector3.new(18, 9, 0.8)
    gate.CFrame = floor.CFrame * CFrame.new(0, 4.5, -15.7)
    gate.Anchored = true
    gate.CanCollide = false
    gate.Material = Enum.Material.ForceField
    gate.Color = Color3.fromRGB(255, 74, 92)
    gate.Transparency = 1
    gate.Parent = folder

    return pieces, gate
end

local labs = {}

for _, lab in ipairs(world:GetChildren()) do
    if lab:IsA("Model") and lab.Name:match("^Lab_%d+$") then
        local floor = lab:FindFirstChild("Floor")
        if floor then
            local shieldTerminal, shieldPrompt, shieldLabel = makeTerminal(
                lab, floor, "EmergencyShieldTerminal", -14,
                Color3.fromRGB(70, 220, 255), "ACTIVATE", "EMERGENCY SHIELD\n60s protection"
            )
            local lockTerminal, lockPrompt, lockLabel = makeTerminal(
                lab, floor, "LockdownTerminal", -5,
                Color3.fromRGB(255, 78, 98), "LOCK", "LAB LOCKDOWN\n3 min max"
            )
            local incomeTerminal, incomePrompt, incomeLabel = makeTerminal(
                lab, floor, "IncomeShopTerminal", 5,
                Color3.fromRGB(80, 255, 165), "BUY", "RESEARCH AMP\n+10% income/level"
            )
            local shieldTechTerminal, shieldTechPrompt, shieldTechLabel = makeTerminal(
                lab, floor, "ShieldTechTerminal", 14,
                Color3.fromRGB(190, 120, 255), "BUY", "SHIELD TECH\nshorter cooldown"
            )

            local shieldPieces, lockdownGate = makeDefenseVisuals(lab, floor)

            local record = {
                Model = lab,
                ShieldPrompt = shieldPrompt,
                ShieldLabel = shieldLabel,
                LockPrompt = lockPrompt,
                LockLabel = lockLabel,
                IncomePrompt = incomePrompt,
                IncomeLabel = incomeLabel,
                ShieldTechPrompt = shieldTechPrompt,
                ShieldTechLabel = shieldTechLabel,
                ShieldPieces = shieldPieces,
                LockdownGate = lockdownGate,
                LockdownUntil = 0,
            }
            labs[lab] = record

            shieldPrompt.Triggered:Connect(function(player)
                if lab:GetAttribute("OwnerUserId") ~= player.UserId then
                    toast(player, "Only the lab owner can activate this shield.")
                    return
                end
                local profile = DataService.Get(player)
                if not profile then return end

                local now = os.time()
                if now < (profile.ShieldReadyAt or 0) then
                    toast(player, "Emergency shield recharging: " .. formatTime(profile.ShieldReadyAt - now))
                    return
                end

                local cooldown = DataService.GetShieldCooldown(player)
                lab:SetAttribute("EmergencyShieldUntil", now + Config.EmergencyShieldDuration)
                profile.ShieldReadyAt = now + cooldown
                toast(player, "EMERGENCY SHIELD ACTIVE — your specimens cannot be raided for 60 seconds.")
            end)

            lockPrompt.Triggered:Connect(function(player)
                if lab:GetAttribute("OwnerUserId") ~= player.UserId then
                    toast(player, "Only the lab owner can control lockdown.")
                    return
                end
                local profile = DataService.Get(player)
                if not profile then return end
                local now = os.time()

                if lab:GetAttribute("LockdownActive") then
                    lab:SetAttribute("LockdownActive", false)
                    record.LockdownUntil = 0
                    profile.LockdownReadyAt = now + Config.LockdownCooldownSeconds
                    toast(player, "Lockdown released. Lockdown will be available again in 1 hour.")
                    return
                end

                if now < (profile.LockdownReadyAt or 0) then
                    toast(player, "Lockdown cooling down: " .. formatTime(profile.LockdownReadyAt - now))
                    return
                end

                lab:SetAttribute("LockdownActive", true)
                record.LockdownUntil = now + Config.LockdownMaxSeconds
                toast(player, "LAB LOCKDOWN ACTIVE — raids blocked for up to 3 minutes. Use the terminal again to unlock early.")
            end)

            incomePrompt.Triggered:Connect(function(player)
                if lab:GetAttribute("OwnerUserId") ~= player.UserId then
                    toast(player, "Use the Research Shop at your own lab.")
                    return
                end
                local profile = DataService.Get(player)
                if not profile then return end
                local ok, reason = DataService.BuyIncomeBoost(player)
                if ok then
                    local bonus = math.floor(profile.IncomeLevel * Config.IncomeUpgrade.BonusPerLevel * 100)
                    toast(player, string.format("Research Amplifier upgraded to Lv.%d — +%d%% passive income!", profile.IncomeLevel, bonus))
                elseif reason == "NOT_ENOUGH" then
                    toast(player, "Not enough Research for the Income Amplifier.")
                else
                    toast(player, "Research Amplifier is already maxed.")
                end
            end)

            shieldTechPrompt.Triggered:Connect(function(player)
                if lab:GetAttribute("OwnerUserId") ~= player.UserId then
                    toast(player, "Use the Research Shop at your own lab.")
                    return
                end
                local profile = DataService.Get(player)
                if not profile then return end
                local ok, reason = DataService.BuyShieldTech(player)
                if ok then
                    toast(player, string.format("Shield Tech upgraded to Lv.%d — shield cooldown is now %s.", profile.ShieldLevel, formatTime(DataService.GetShieldCooldown(player))))
                elseif reason == "NOT_ENOUGH" then
                    toast(player, "Not enough Research for Shield Tech.")
                else
                    toast(player, "Shield Tech is already maxed.")
                end
            end)
        end
    end
end

local function updateRaidPrompts(lab, protected)
    for _, descendant in ipairs(lab:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name:match("^Pod_%d+$") then
            local prompt = descendant:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                prompt.Enabled = (not protected) and descendant:GetAttribute("Occupied") == true
            end
        end
    end
end

local function setShieldVisual(record, shieldActive, lockdownActive)
    for _, wall in ipairs(record.ShieldPieces) do
        wall.Transparency = shieldActive and 0.72 or (lockdownActive and 0.82 or 1)
        wall.Color = lockdownActive and Color3.fromRGB(255, 74, 92) or Color3.fromRGB(75, 215, 255)
    end
    record.LockdownGate.Transparency = lockdownActive and 0.38 or 1
    record.LockdownGate.CanCollide = lockdownActive
end

-- Keep displays, raid prompts and timed defenses synchronized.
task.spawn(function()
    while true do
        local now = os.time()
        for lab, record in pairs(labs) do
            local ownerId = lab:GetAttribute("OwnerUserId") or 0
            local owner = ownerId ~= 0 and Players:GetPlayerByUserId(ownerId) or nil
            local profile = owner and DataService.Get(owner) or nil

            local shieldUntil = lab:GetAttribute("EmergencyShieldUntil") or 0
            local shieldActive = now < shieldUntil
            local lockdownActive = lab:GetAttribute("LockdownActive") == true

            if lockdownActive and record.LockdownUntil > 0 and now >= record.LockdownUntil then
                lab:SetAttribute("LockdownActive", false)
                lockdownActive = false
                record.LockdownUntil = 0
                if profile then
                    profile.LockdownReadyAt = now + Config.LockdownCooldownSeconds
                    toast(owner, "Maximum lockdown time reached. Lockdown is cooling down for 1 hour.")
                end
            end

            local protected = shieldActive or lockdownActive
            lab:SetAttribute("DefenseProtected", protected)
            updateRaidPrompts(lab, protected)
            setShieldVisual(record, shieldActive, lockdownActive)

            if owner and profile then
                if shieldActive then
                    record.ShieldPrompt.ActionText = "ACTIVE"
                    record.ShieldLabel.Text = "EMERGENCY SHIELD\n" .. formatTime(shieldUntil - now) .. " remaining"
                elseif now < (profile.ShieldReadyAt or 0) then
                    record.ShieldPrompt.ActionText = "RECHARGING"
                    record.ShieldLabel.Text = "EMERGENCY SHIELD\nready in " .. formatTime(profile.ShieldReadyAt - now)
                else
                    record.ShieldPrompt.ActionText = "ACTIVATE"
                    record.ShieldLabel.Text = "EMERGENCY SHIELD\n60s protection • READY"
                end

                if lockdownActive then
                    record.LockPrompt.ActionText = "UNLOCK"
                    record.LockLabel.Text = "LAB LOCKDOWN\n" .. formatTime(record.LockdownUntil - now) .. " max remaining"
                elseif now < (profile.LockdownReadyAt or 0) then
                    record.LockPrompt.ActionText = "COOLDOWN"
                    record.LockLabel.Text = "LAB LOCKDOWN\nready in " .. formatTime(profile.LockdownReadyAt - now)
                else
                    record.LockPrompt.ActionText = "LOCK"
                    record.LockLabel.Text = "LAB LOCKDOWN\n3 min max • READY"
                end

                if profile.IncomeLevel >= Config.IncomeUpgrade.MaxLevel then
                    record.IncomeLabel.Text = "RESEARCH AMP\nMAX LEVEL"
                else
                    record.IncomeLabel.Text = string.format("RESEARCH AMP Lv.%d\n+10%% next • %d R", profile.IncomeLevel, Config.GetIncomeUpgradeCost(profile.IncomeLevel))
                end

                if profile.ShieldLevel >= Config.ShieldTechUpgrade.MaxLevel then
                    record.ShieldTechLabel.Text = "SHIELD TECH\nMAX LEVEL"
                else
                    record.ShieldTechLabel.Text = string.format("SHIELD TECH Lv.%d\n%d R", profile.ShieldLevel, Config.GetShieldTechCost(profile.ShieldLevel))
                end
            else
                record.ShieldLabel.Text = "EMERGENCY SHIELD\n60s protection"
                record.LockLabel.Text = "LAB LOCKDOWN\n3 min max"
                record.IncomeLabel.Text = "RESEARCH AMP\n+10% income/level"
                record.ShieldTechLabel.Text = "SHIELD TECH\nshorter cooldown"
            end
        end
        task.wait(1)
    end
end)
