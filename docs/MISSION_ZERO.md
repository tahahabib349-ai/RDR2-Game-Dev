# Mission Zero

> **Status:** Phase 0 blueprint. All timings, coordinates and balance values are **tunable starting values**, not final balance.
>
> **2026-10-06 map revision (🟣 Claude, covering 🟢 ChatGPT's role at the Game Director's request; ChatGPT to review):** after the first iPhone playtest the map felt small (units crossed base to base in 12–22 s). The map grows from 72 to **108** cells (all coordinates ×1.5, near-ore offsets kept), unit speeds drop to ×0.7 (`UNIT_SYSTEM.md`), the ridge now runs edge to edge so there is no third route along the west edge, and East Cut moves south-east so it is a real detour. All numbers below were measured in the engine with a prototype of this layout.

## Purpose

Mission Zero exists to answer one question: **is the core mobile RTS loop fun?** It is a single authored battle that teaches the complete loop without campaign systems, multiplayer, progression or monetization.

Target first-clear time: **12–18 minutes** after the player understands the controls.

## Map: Breakpoint Valley

### Technical size

- Logical map: **108 x 108 square cells**.
- Rendering: 2D isometric projection; gameplay/pathfinding uses the logical square grid.
- Suggested visual cell footprint: approximately **64 x 32 px** at 1.0 zoom.
- Unit movement is continuous across passable cells; cells define terrain, building footprints and pathfinding.
- Minimum main-lane width: **6 cells** so groups do not become single-file.
- Camera is clamped to the full playable map with a small presentation margin; exact touch camera behaviour belongs in `MOBILE_CONTROLS.md`.

### Major locations

Coordinates are logical grid coordinates `(x, y)`, origin at the north-west.

| Area | Approx. center | Purpose |
|---|---:|---|
| Player start | (18, 87) | Safe south-west deployment basin |
| Player near Flux Ore field | (26, 81) | First economy; visible shortly after deploying |
| West expansion Flux Ore field | (27, 46) | Optional safer expansion |
| Central rich Flux Ore field | (54, 54) | Contested economic reward |
| Enemy near Flux Ore field | (83, 27) | Supports enemy economy |
| Enemy base | (90, 21) | Final objective in north-east |

### Terrain and chokepoints

The map should feel like one readable battlefield, not a maze.

- A broken rocky ridge, about 4 cells thick, runs **from the west map edge to the south map edge** and walls the player's south-west basin off from the rest of the map. Its line passes through **(0, 61) → (12, 60) → (36, 58.5) → (51, 54) → (60, 39) → (72, 27) → (84, 48) → (75, 63) → (87, 84) → (101, 108)**. The only crossings are the two passes below; there is **no route along the west edge**.
- **Central Pass**, centered near **(51, 54)**, is the shortest route between bases (**~106 cells**). It is about **7 cells wide** and has the rich central Flux Ore field just off the lane, forcing economic activity into danger.
- **East Cut**, centered near **(84.5, 79)**, is a **6-cell-wide** flanking route, about **21% longer** (~128 cells, roughly 9 s extra for a Vanguard Tank). It lets a player avoid the main pass at the cost of travel time.
- The **west expansion field (27, 46)** lies beyond the ridge. The player reaches it through Central Pass (~70 cells from the start), so its approach is exposed to attacks coming through the pass.
- Travel times base to base through Central Pass: Jackal ~25 s, Vanguard Tank ~41 s, Ranger ~46 s, Lancer ~53 s, Breaker Tank ~56 s.
- Each near Flux Ore field is ~10 cells from its base, unchanged from the 72-cell layout so the opening economy keeps its pace.
- Decorative cliffs, scrub and debris may make the map feel denser, but must not create hidden one-cell traps.
- No bridges, destructible terrain, elevation combat modifiers or amphibious areas in Mission Zero.

### Blockout sketch

```text
NORTH (y = 0)
┌────────────────────────────────────────────────────────┐
│                                       [ENEMY BASE]     │
│                                     E-ORE              │
│                                  #                     │
│        WEST ORE                #   #                   │
│                              #       #                 │
│                       [RICH ORE]       #               │
│ ############## CENTRAL PASS            #               │
│               #####                    #  (ridge bends │
│   P-ORE            ######             #    back west)  │
│ [PLAYER START]           ###            EAST CUT       │
│                             ####           #           │
│                                 ######        #        │
└────────────────────────────────────────────────────────┘
SOUTH (y = 108)   # = ridge, wall from west edge to south edge
```

The final greybox should be adjusted if pathfinding or camera readability is poor; the coordinates above define intent, not pixel-perfect art placement.

## Starting state

### Player

- **1 Pioneer Rig** at approximately **(18, 87)**.
- **4,000 credits**.
- No other units or structures.
- Mission begins with a short objective prompt: deploy the Pioneer Rig.
- The Pioneer Rig deploys into a **Field Command** in **3 seconds** and cannot pack up again in Mission Zero.

### Enemy

The enemy starts with:

- **1 Pioneer Rig** at approximately **(90, 21)**.
- **4,000 credits**.
- The AI deploys automatically at mission start and then follows the build script below.
- The AI uses the same costs, build times, production rules, economy and power rules as the player. It does **not** receive free combat units or hidden income.

## Mission flow

1. Deploy Pioneer Rig into Field Command.
2. Build a Grid Plant.
3. Build an Ore Works; it provides one Gatherer when completed.
4. Establish a stable credit income.
5. Build an Infantry Depot and train infantry.
6. Build a Vehicle Foundry and produce armor.
7. Add a second Grid Plant and/or Guardian Turret as power and defense require.
8. Survive escalating enemy attack waves.
9. Expand to a second Flux Ore field or contest the center if the starting field is insufficient.
10. Build an army, push through a chokepoint and destroy the enemy Field Command.

These are gameplay beats, not forced tutorial locks. Once a system is available, the player may choose a different order.

## Win and lose conditions

### Victory

- **Destroy the enemy Field Command.**
- Victory triggers only after its destruction event resolves.
- Remaining enemy units do not need to be eliminated.
- Show a simple victory screen with mission time and a restart/continue-to-menu choice.

### Defeat

- **The player's Field Command is destroyed.**
- Mission Zero does not support repacking into a Pioneer Rig, replacement command structures or recovery after command loss.
- Show a simple defeat screen with restart/return choice.

## Enemy AI script

The Mission Zero AI is intentionally understandable and testable. It is a scripted macro plan with simple reactions, not a general-purpose strategy AI.

### Principles

- Uses real credits and power.
- Builds on valid cells near its existing base.
- Harvests the enemy-side Flux Ore field first.
- Keeps a small defensive reserve at home once attacks begin.
- Sends discrete waves instead of trickling single units across the map.
- Does not know the player's hidden unit positions through fog.
- May know the player's starting-base region for mission pacing, but attack groups must acquire actual targets through normal visibility once they arrive.
- If a scripted purchase cannot be afforded, the AI waits; it does not cheat.

### Opening build order

Times are targets and may slip if the economy or placement blocks the action.

| Target time | AI action |
|---:|---|
| 0:00 | Deploy Pioneer Rig into Field Command |
| 0:08 | Queue Grid Plant |
| 0:25 | Queue Ore Works |
| 0:50 | Queue Infantry Depot |
| 1:05 | Train 2 Rangers |
| 1:25 | Train 1 Lancer |
| 1:45 | Queue Vehicle Foundry |
| 2:10 | Produce 1 Jackal |
| 2:30 | Produce 1 Vanguard Tank |
| 2:55 | Train 2 Rangers |
| 3:15 | Queue second Grid Plant if projected demand would exceed supply |
| 3:35 | Produce 1 Vanguard Tank |
| 3:55 | Train 1 Lancer |
| 4:15 | Assemble Wave 1 at rally point |
| 4:30 | Launch Wave 1 |

If the starting field is temporarily blocked or the Gatherer is destroyed, the AI first replaces the Gatherer before resuming the military plan.

### Attack timing and growth

- **First attack target:** **4:30** (launch). With the 108-cell map the wave needs ~45–55 s to cross, so it reaches the player around **5:15–5:25**. Check in the Phase 5/6 playtest whether launch should move earlier.
- Earliest allowed first attack in tuning: **4:15**.
- Standard interval after Wave 1: **90 seconds**.
- If a wave is still fighting after 90 seconds, the next wave waits until either the prior wave is mostly destroyed or 45 additional seconds pass.
- The AI keeps roughly **25% of its current combat value** at home once it has enough units to do so.

Wave strength is driven by a simple credit-value budget:

`wave_budget = min(1000 + 500 × (wave_number - 1), 3500)`

The AI fills the budget from currently unlocked units using the composition guidance below and only launches units it has actually produced.

| Wave | Intended character |
|---|---|
| 1 | Mostly Rangers, 1 Lancer, 1 Jackal; teaches basic defense |
| 2 | Rangers + Lancers + 1 Vanguard Tank |
| 3 | 2+ Vanguard Tanks supported by infantry |
| 4 | Introduces 1 Breaker Tank with mixed support |
| 5+ | Mixed armor/infantry; budget continues to rise until the 3,500-credit cap |

### Tactical behaviour

- Attack waves move toward the player's last known base area using the shortest currently passable route.
- While moving, units attack enemies that enter normal acquisition range but do not chase more than **8 cells** away from the wave route.
- Priority when inside the player base: hostile combat units threatening the wave → Guardian Turrets → production structures → Field Command.
- Anti-armor Lancers prefer Vehicle/Heavy targets when available.
- Breaker Tanks prefer Heavy or Structure targets.
- If the AI sees a large player force attacking its base, nearby produced units defend instead of joining the next wave.
- No kiting, focus-fire micro, repair logic, scouting routines, superweapons or difficulty cheats in Mission Zero.

## Playtest fun checklist

A Mission Zero playtest is not a pass merely because it can be completed. The Game Director should check:

- [ ] I understand what to do within the first 30 seconds without reading a manual.
- [ ] Deploying the base and placing the first structures feels fast, not administrative.
- [ ] The first Gatherer trip makes the economy visually obvious.
- [ ] Credits create real choices; I cannot mindlessly queue everything at once.
- [ ] Low power is noticeable and recoverable rather than confusing or fatal.
- [ ] Infantry and vehicles have visibly different jobs.
- [ ] Lancers feel meaningfully better against armor than Rangers.
- [ ] Jackals feel useful for speed/scouting rather than like cheap tanks.
- [ ] Vanguard Tanks are the reliable core armor choice.
- [ ] Breaker Tanks feel powerful but expensive/slow enough to need support.
- [ ] The first enemy attack arrives after I have time to understand my base, but before I feel safe or bored.
- [ ] Later waves create pressure without feeling like unexplained cheating.
- [ ] Central Pass and East Cut create at least one meaningful route choice.
- [ ] The central Flux Ore field is tempting enough to fight over.
- [ ] Units usually reach commanded destinations without obvious traffic jams.
- [ ] A mixed group remains controllable on a phone-sized view.
- [ ] Combat results are readable: I can tell who is firing, what is taking damage and why something died.
- [ ] Guardian Turrets help hold ground but cannot win the mission for me.
- [ ] Fog creates uncertainty without making basic navigation frustrating.
- [ ] Destroying the enemy Field Command feels like a clear climax.
- [ ] A normal successful match lands roughly in the 12–18 minute target.
- [ ] I want to immediately replay with a different build order or attack route.

Any unchecked item is a reason to tune or fix the core game before adding content.
