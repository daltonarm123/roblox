local RunService = game:GetService("RunService")

return {
    DataStoreName = "ContainmentHeist_BugReports_v1",
    MaxReportCharacters = 700,
    SubmitCooldownSeconds = 60,
    RecentReportLimit = 100,

    -- Add your numeric Roblox user ID here before release for stronger admin security.
    -- Username fallback is included so the current Studio account can test the inbox now.
    AdminUserIds = {},
    AdminUsernames = { "EnvyTheDev0" },
    AllowAllStudioPlayersAsAdmin = RunService:IsStudio(),

    -- Optional future bridge. Keep blank until we deploy a secure HTTPS endpoint.
    -- That endpoint can email reports or open GitHub issues without putting secrets in the game.
    WebhookEndpoint = "",
    WebhookSecretName = "",
}
