# CONTAINMENT HEIST

A small-lobby Roblox collection/heist game built around a high-retention loop:

**raid the facility -> escape with an anomaly -> contain it in your lab -> earn passive Research -> upgrade -> raid rival labs -> chase rare events**

This replaces the scrapped Junkyard Empire prototype.

## Why this direction

The game is designed around current Roblox discovery signals rather than a traditional tycoon loop:

- immediate action in the first seconds
- 6-player servers so rivalries stay personal
- collectible rarity + visible flex value
- passive/offline income from captured anomalies
- PvP theft creates stories without requiring a shooter-sized combat system
- scheduled rare spawns create server-wide races
- progression supports repeat sessions without needing a huge map

The concept deliberately avoids being another `Steal a ___` title. The theft mechanic is one layer inside an original containment-lab theme.

## MVP gameplay

1. Claim one of six private labs when you join.
2. Enter the central containment facility.
3. Take a randomly spawned anomaly from a pedestal.
4. Escape back to your lab while carrying it.
5. Deposit it into a containment pod.
6. Contained anomalies generate Research every second, including capped offline earnings.
7. Spend Research on movement speed and extra containment capacity.
8. Raid other players' occupied containment pods and escape with their anomaly.
9. Every five minutes a server-wide rare specimen event creates a race.

## Development

This repository uses a Rojo source layout.

```text
src/
  client/
  server/
  shared/
```

### Studio setup

1. Install Rojo and the Roblox Studio Rojo plugin.
2. Clone this repository.
3. Run `rojo serve` in the repository directory.
4. Open a blank Baseplate in Roblox Studio.
5. Connect the Rojo plugin to the running project.
6. Sync the project.
7. Press Play. The facility and player labs are generated at runtime.

For persistent DataStore testing, publish the experience and enable **Studio Access to API Services** in Game Settings > Security.

## Current milestone

The first branch is `feat/containment-heist-mvp`. It is intended to prove the core retention loop before we invest in polished models, animations, monetization, or LiveOps.
