# Containment Heist — MVP Design Targets

## Product thesis

Build a six-player social heist/collection game where every successful raid creates a visible story: who stole what, who escaped, whose lab got robbed, and what rare specimen is currently worth fighting over.

The project is intentionally narrower than a survival sandbox or roleplay city so a small team can ship, test retention, and iterate quickly.

## Core loop

1. Spot a specimen in Central Containment.
2. Enter the facility and take it.
3. Escape security while visibly carrying the loot.
4. Deposit it in your own lab.
5. The specimen generates Research passively.
6. Upgrade movement speed and containment capacity.
7. Raid another player's lab for a specimen that is better than yours.
8. React to rare server-wide specimen events.
9. Leave and return later to collect capped offline production.

## Why six players

Small servers keep ownership legible. A player should quickly learn which neighboring lab owns the desirable specimen and remember the player who stole from them. The goal is rivalry, not anonymous crowd noise.

## First-session targets

- Player understands the objective without a tutorial dialog.
- First central specimen can be taken within 30 seconds.
- First deposit happens within 90 seconds.
- First meaningful upgrade is affordable within a few minutes.
- First rival-lab interaction can happen during the initial session.
- Rare-event messaging gives players a reason to stay for the next server moment.

## KPIs after publishing

Priority order:

1. New-user first-session retention at 5 and 10 minutes.
2. Average session time, targeting 15+ minutes before scaling acquisition.
3. D1 retention.
4. D7 play days per user.
5. Intentional co-play / friend joins.
6. Only after the loop retains players: payer conversion and Robux per user.

## Content expansion without rebuilding the game

- New specimen definitions and mutations.
- New security hazards in Central Containment.
- Rotating facility wings.
- Limited-time anomalies.
- Base cosmetics and containment pod skins.
- Gadgets for escape/defense.
- Contracts and daily missions.
- Trading only after the economy proves stable.

## Monetization guardrails

Do not block the core heist loop behind Robux. Good candidates later are cosmetic lab themes, extra loadout convenience, temporary boosts, optional recovery products, VIP visual flex, and additional non-essential progression convenience. Monetization should be added after retention testing, not used to hide a weak loop.
