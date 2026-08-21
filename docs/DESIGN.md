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
6. Spend Research on speed, capacity, passive-income amplification, shield tech, or temporary abilities.
7. Raid another player's lab for a specimen that is better than yours.
8. React to rare server-wide specimen events.
9. Complete daily missions and advance the current season track.
10. Leave and return later to collect capped offline production.

## Why six players

Small servers keep ownership legible. A player should quickly learn which neighboring lab owns the desirable specimen and remember the player who stole from them. The goal is rivalry, not anonymous crowd noise.

## First-session targets

- Player understands the objective without a tutorial dialog.
- First central specimen can be taken within 30 seconds.
- First deposit happens within 90 seconds.
- First meaningful upgrade is affordable within a few minutes.
- First rival-lab interaction can happen during the initial session.
- Rare-event messaging gives players a reason to stay for the next server moment.
- The Lab Shop and Season buttons expose clear medium-term goals before the first session ends.

## Retention systems

### Daily missions

Current daily mission set:

- Play for 10 minutes.
- Earn 2,500 Research.
- Contain 3 anomalies.
- Activate the emergency shield once.

Missions award Season XP. The daily set resets on the UTC day boundary.

### Season 1 — Containment Protocol

- 20 tiers.
- 100 XP per tier.
- Free rewards at every tier.
- Premium rewards at every tier for players who unlock the current season.
- Rewards currently include Research and stored ability charges.
- Changing the configured Season ID creates a fresh season progression track while retaining permanent player upgrades.

Future season reward expansion should favor cosmetics, lab themes, titles, trails, containment-pod skins, emotes, and anomaly-display flex rather than raw combat power.

### Social abilities

Abilities are deliberately short and cooldown-limited:

- **Static Burst** — brief rival-screen interference.
- **Breach Scare** — brief server-wide anomaly scare for rivals.
- **Phase Cloak** — 15 seconds of partial invisibility; cannot be activated while carrying loot and automatically cancels when loot is picked up.

Abilities can be paid for with Research or consumed from stored charges earned through the season track / developer products. They are designed as social chaos and positioning tools rather than guaranteed-win purchases.

### Defensive choices

- Emergency shield: 60 seconds of raid protection, roughly 5-minute base cooldown, reducible with Research upgrades.
- Lab lockdown: up to 3 minutes of protection; unlocking/expiration starts a 1-hour cooldown.
- New-player raid grace remains separate from these player-controlled defenses.

## KPIs after publishing

Priority order:

1. New-user first-session retention at 5 and 10 minutes.
2. Average session time, targeting 15+ minutes before scaling acquisition.
3. D1 retention.
4. D7 play days per user.
5. Intentional co-play / friend joins.
6. Season mission completion and tier progression.
7. Research-shop purchase mix and Research inflation.
8. Only after the loop retains players: payer conversion, revenue per user, and product attach rate.

## Content expansion without rebuilding the game

- New specimen definitions and mutations.
- New security hazards in Central Containment.
- Rotating facility wings.
- Limited-time anomalies.
- Base cosmetics and containment pod skins.
- Gadgets for escape/defense.
- Weekly missions and seven-day login streak rewards.
- Prestige / reset progression for long-term Research sinks.
- Trading only after the economy proves stable.

## Monetization plan

Current planned launch prices are starting hypotheses, not promises. Live prices should be adjusted after observing conversion and Roblox pricing analytics.

| Product | Type | Planned price |
| --- | --- | ---: |
| 2× Research | Permanent pass | 399 R$ |
| VIP (+10% speed + future cosmetic perks) | Permanent pass | 199 R$ |
| Premium current-season track | Developer product | 299 R$ |
| 5,000 Research | Developer product | 29 R$ |
| 25,000 Research | Developer product | 99 R$ |
| Instant shield recharge | Developer product | 19 R$ |
| Static Burst charge | Developer product | 15 R$ |
| Breach Scare charge | Developer product | 25 R$ |
| Phase Cloak charge | Developer product | 29 R$ |

Product IDs stay at zero in source until the published experience has matching Creator Dashboard products. The client shows planned prices during Studio testing and loads the actual Roblox price once IDs are configured.

## Monetization guardrails

Do not block the core heist loop behind Robux. Every gameplay-relevant temporary ability has a Research path, and Phase Cloak cannot carry stolen loot. Premium progression should increasingly emphasize cosmetic/status rewards as art content becomes available.

Avoid purchase spam, forced popups, fake urgency, or products that make a non-paying player unable to compete. Retention and genuine fun come first; monetization should amplify a game people already want to keep playing.
