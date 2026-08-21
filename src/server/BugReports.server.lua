local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local BugConfig = require(ReplicatedStorage.Shared.BugConfig)

local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")

local submitFunction = remotes:FindFirstChild("SubmitBugReport") or Instance.new("RemoteFunction")
submitFunction.Name = "SubmitBugReport"
submitFunction.Parent = remotes

local adminFetchFunction = remotes:FindFirstChild("FetchBugReports") or Instance.new("RemoteFunction")
adminFetchFunction.Name = "FetchBugReports"
adminFetchFunction.Parent = remotes

local adminActionFunction = remotes:FindFirstChild("BugReportAction") or Instance.new("RemoteFunction")
adminActionFunction.Name = "BugReportAction"
adminActionFunction.Parent = remotes

local reportStore = nil
if game.GameId ~= 0 then
    local ok, result = pcall(function()
        return DataStoreService:GetDataStore(BugConfig.DataStoreName)
    end)
    if ok then
        reportStore = result
    else
        warn("ContainmentHeist bug report DataStore unavailable:", result)
    end
end

local sessionReports = {}
local lastSubmitAt = {}
local VALID_CATEGORIES = {
    Gameplay = true,
    UI = true,
    Purchase = true,
    Exploit = true,
    Other = true,
}

local function isAdmin(player)
    if BugConfig.AllowAllStudioPlayersAsAdmin and RunService:IsStudio() then
        return true
    end

    for _, userId in ipairs(BugConfig.AdminUserIds or {}) do
        if player.UserId == userId then
            return true
        end
    end

    for _, username in ipairs(BugConfig.AdminUsernames or {}) do
        if string.lower(player.Name) == string.lower(username) then
            return true
        end
    end

    return false
end

local function markAdmin(player)
    player:SetAttribute("BugReportAdmin", isAdmin(player))
end

Players.PlayerAdded:Connect(markAdmin)
for _, player in ipairs(Players:GetPlayers()) do
    markAdmin(player)
end

Players.PlayerRemoving:Connect(function(player)
    lastSubmitAt[player.UserId] = nil
end)

local function trim(text)
    text = tostring(text or "")
    return text:match("^%s*(.-)%s*$") or ""
end

local function filterReportText(player, raw)
    local ok, result = pcall(function()
        local filtered = TextService:FilterStringAsync(raw, player.UserId)
        return filtered:GetNonChatStringForBroadcastAsync()
    end)

    if ok and type(result) == "string" then
        return result
    end

    if RunService:IsStudio() then
        return raw
    end

    return "[Report text could not be filtered]"
end

local function pushSession(report)
    table.insert(sessionReports, 1, report)
    while #sessionReports > BugConfig.RecentReportLimit do
        table.remove(sessionReports)
    end
end

local function persistReport(report)
    if not reportStore then
        return
    end

    local ok, err = pcall(function()
        reportStore:UpdateAsync("Recent", function(existing)
            existing = type(existing) == "table" and existing or {}
            table.insert(existing, 1, report)
            while #existing > BugConfig.RecentReportLimit do
                table.remove(existing)
            end
            return existing
        end)
    end)

    if not ok then
        warn("ContainmentHeist failed to persist bug report:", err)
    end
end

local function sendWebhook(report)
    if BugConfig.WebhookEndpoint == "" or BugConfig.WebhookSecretName == "" then
        return
    end
    if not HttpService.HttpEnabled then
        return
    end

    task.spawn(function()
        local ok, err = pcall(function()
            local secret = HttpService:GetSecret(BugConfig.WebhookSecretName)
            local response = HttpService:RequestAsync({
                Url = BugConfig.WebhookEndpoint,
                Method = "POST",
                Headers = {
                    ["content-type"] = "application/json",
                    ["x-api-key"] = secret,
                },
                Body = HttpService:JSONEncode(report),
            })
            if not response.Success then
                error(string.format("HTTP %s: %s", tostring(response.StatusCode), tostring(response.StatusMessage)))
            end
        end)
        if not ok then
            warn("ContainmentHeist bug webhook failed:", err)
        end
    end)
end

submitFunction.OnServerInvoke = function(player, payload)
    if type(payload) ~= "table" then
        return false, "Invalid report."
    end

    local nowClock = os.clock()
    local previous = lastSubmitAt[player.UserId] or 0
    local remaining = BugConfig.SubmitCooldownSeconds - (nowClock - previous)
    if remaining > 0 then
        return false, string.format("Please wait %d seconds before sending another report.", math.ceil(remaining))
    end

    local rawMessage = trim(payload.Message)
    if #rawMessage < 8 then
        return false, "Please describe the bug with a little more detail."
    end
    if #rawMessage > BugConfig.MaxReportCharacters then
        rawMessage = string.sub(rawMessage, 1, BugConfig.MaxReportCharacters)
    end

    local category = tostring(payload.Category or "Other")
    if not VALID_CATEGORIES[category] then
        category = "Other"
    end

    local filteredMessage = filterReportText(player, rawMessage)
    local report = {
        Id = HttpService:GenerateGUID(false),
        Status = "NEW",
        Category = category,
        Message = filteredMessage,
        UserName = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        CreatedAt = os.time(),
        Client = {
            Touch = payload.Touch == true,
            Keyboard = payload.Keyboard == true,
            Gamepad = payload.Gamepad == true,
            Viewport = string.sub(tostring(payload.Viewport or "unknown"), 1, 40),
        },
    }

    lastSubmitAt[player.UserId] = nowClock
    pushSession(report)
    task.spawn(persistReport, report)
    sendWebhook(report)

    print(string.format("[BUG REPORT] %s (%s): %s", player.Name, category, filteredMessage))
    return true, "Report sent. Thank you — it was added to the developer bug inbox."
end

local function mergeReports(persistent)
    local byId = {}
    local output = {}

    local function add(report)
        if type(report) ~= "table" or not report.Id or byId[report.Id] then
            return
        end
        byId[report.Id] = true
        table.insert(output, report)
    end

    for _, report in ipairs(sessionReports) do
        add(report)
    end
    for _, report in ipairs(persistent or {}) do
        add(report)
    end

    table.sort(output, function(a, b)
        return (tonumber(a.CreatedAt) or 0) > (tonumber(b.CreatedAt) or 0)
    end)

    while #output > BugConfig.RecentReportLimit do
        table.remove(output)
    end

    return output
end

adminFetchFunction.OnServerInvoke = function(player)
    if not isAdmin(player) then
        return false, "Not authorized."
    end

    local persistent = {}
    if reportStore then
        local ok, result = pcall(function()
            return reportStore:GetAsync("Recent")
        end)
        if ok and type(result) == "table" then
            persistent = result
        end
    end

    return true, mergeReports(persistent)
end

local function updateStatusInList(list, reportId, status)
    local changed = false
    for _, report in ipairs(list) do
        if report.Id == reportId then
            report.Status = status
            report.UpdatedAt = os.time()
            changed = true
            break
        end
    end
    return changed
end

adminActionFunction.OnServerInvoke = function(player, reportId, action)
    if not isAdmin(player) then
        return false, "Not authorized."
    end
    if type(reportId) ~= "string" then
        return false, "Invalid report."
    end

    local status = action == "FIXED" and "FIXED" or action == "REVIEWED" and "REVIEWED" or nil
    if not status then
        return false, "Invalid action."
    end

    updateStatusInList(sessionReports, reportId, status)

    if reportStore then
        pcall(function()
            reportStore:UpdateAsync("Recent", function(existing)
                existing = type(existing) == "table" and existing or {}
                updateStatusInList(existing, reportId, status)
                return existing
            end)
        end)
    end

    return true, status
end
