return {
    MasterVolume = 0.72,

    -- Roblox-owned Creator Store effects. Playback speed gives each cue its own feel
    -- while keeping the first audio pass lightweight and safe to use.
    Cues = {
        UIClick = { Id = 12221990, Volume = 0.22, PlaybackSpeed = 1.35 }, -- electronic ping
        Pickup = { Id = 12222140, Volume = 0.55, PlaybackSpeed = 1.18 }, -- snap
        Deposit = { Id = 12221990, Volume = 0.62, PlaybackSpeed = 0.88 },
        RareBreach = { Id = 12221944, Volume = 0.95, PlaybackSpeed = 0.68 }, -- bass hit
        Security = { Id = 12221944, Volume = 0.78, PlaybackSpeed = 1.08 },
        Shield = { Id = 12221990, Volume = 0.58, PlaybackSpeed = 0.74 },
        Lockdown = { Id = 12221944, Volume = 0.82, PlaybackSpeed = 0.82 },
        Upgrade = { Id = 12221990, Volume = 0.58, PlaybackSpeed = 1.55 },
        Ability = { Id = 12222140, Volume = 0.64, PlaybackSpeed = 0.86 },
        Error = { Id = 12221944, Volume = 0.48, PlaybackSpeed = 1.42 },
    },
}
