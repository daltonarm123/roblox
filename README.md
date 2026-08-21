# Junkyard Empire

A Roblox tycoon/simulator designed around a simple repeatable loop:

**Grab scrap → sell → upgrade → automate → rebirth.**

The project is source-controlled with a Rojo layout so we can build and maintain the experience from GitHub while syncing scripts into Roblox Studio.

## MVP status

The first playable foundation currently includes:

- Server-authoritative cash and scrap economy
- DataStore player saving and autosave
- Scrap storage capacity
- Pickup Power, Scrap Value, Storage, and Auto Crusher upgrades
- Passive Auto Crusher income every 2 seconds
- Rebirth system with a permanent cash multiplier
- Leaderstats for Cash and Rebirths
- Server-generated junkyard map, fences, scrap piles, crusher, pads, and signs
- ProximityPrompt interactions throughout the yard
- Mobile/desktop HUD with live prices and player stats
- Basic remote-event rate limiting
- Double Cash / VIP game-pass hooks
- 5,000 / 50,000 cash developer-product hooks

## Project layout

```text
src/
  shared/             Shared configuration and number formatting
  server/
    Main.server.lua   Runtime bootstrap, remotes, autosave, passive loop
    Services/         Data, economy, monetization, and world generation
  client/
    Hud.client.lua    Player HUD and action controls
```

## Run it in Roblox Studio

1. Install Rojo (CLI) and the Rojo Roblox Studio plugin.
2. Clone this repository.
3. From the repository folder, run:

```bash
rojo serve
```

4. Open a new Baseplate experience in Roblox Studio.
5. Open the Rojo plugin, connect to the local server, and sync the project.
6. Press **Play**. The junkyard map builds itself when the server starts.

You can also build a place file with:

```bash
rojo build default.project.json -o JunkyardEmpire.rbxlx
```

For persistent DataStore testing in Studio, publish the experience and enable **Studio Access to API Services** in Game Settings > Security.

## Monetization setup

The monetization code is already wired but product IDs are intentionally `0` until products are created for the published Roblox experience.

Edit `src/shared/Config.lua` after creating:

- Double Cash game pass
- VIP game pass
- 5,000 Cash developer product
- 50,000 Cash developer product

Replace the corresponding `0` values with the IDs from Creator Dashboard.

## Next milestone

The next build should add the visual conveyor/crushing cycle, unlockable yard zones, first-session quests, daily rewards, purchase UI, analytics events, and stronger production DataStore session handling.
