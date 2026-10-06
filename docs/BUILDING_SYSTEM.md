# Building System

> **All values below are tunable starting values for Mission Zero.** The purpose is to establish one coherent baseline for implementation and playtesting.

## Building stats

| Building | Cost | Build time | HP | Armor | Footprint | Power output | Power use | Weapon |
|---|---:|---:|---:|---|---|---:|---:|---|
| **Field Command** | Deployment | 3 s deploy | 2,000 | Structure | 4 x 4 | +10 | 0 | None |
| **Grid Plant** | 800 | 8 s | 900 | Structure | 3 x 3 | +100 | 0 | None |
| **Ore Works** | 2,000 | 15 s | 1,500 | Structure | 4 x 4 | 0 | 30 | None |
| **Infantry Depot** | 700 | 8 s | 900 | Structure | 3 x 3 | 0 | 15 | None |
| **Vehicle Foundry** | 2,000 | 16 s | 1,600 | Structure | 5 x 4 | 0 | 35 | None |
| **Guardian Turret** | 900 | 10 s | 800 | Structure | 2 x 2 | 0 | 20 | 30 Cannon, range 6.5, 0.90 shots/s |

With Field Command + one Grid Plant + Ore Works + Infantry Depot + Vehicle Foundry, supply is **110** and demand is **80**. Adding two Guardian Turrets raises demand to **120**, intentionally teaching the need for a second Grid Plant or a different defensive choice.

## Roles

### Field Command

- Created by deploying the Pioneer Rig.
- Provides the base-construction queue.
- Establishes the initial construction radius.
- Is the Mission Zero command structure: losing it causes defeat; destroying the enemy one causes victory.
- Cannot pack up in Mission Zero.

### Grid Plant

- Main power generator.
- Cheap and quick enough to be the recovery choice when low power occurs.
- Grid Plant construction always advances at full construction speed even during low power.

### Ore Works

- Accepts Gatherers and converts delivered Flux Ore into credits.
- Spawns **one free Gatherer** when the first Ore Works finishes.
- Additional Ore Works do not grant free Gatherers unless later playtesting proves expansion is too slow.
- Multiple Gatherers may use the same Ore Works, but only one unloads at a time per unload bay in the first implementation.

### Infantry Depot

Produces:

- Ranger
- Lancer

### Vehicle Foundry

Produces:

- Jackal
- Vanguard Tank
- Breaker Tank
- Replacement Gatherer

The Pioneer Rig is locked from production in Mission Zero.

### Guardian Turret

- Ground-only static defense.
- Uses the Cannon damage profile.
- Automatically targets visible hostile ground units in range.
- Target preference: immediate attackers → vehicles/heavy armor → closest target.
- Low power increases its weapon cooldown to 1.5× normal.
- It should delay or weaken an attack, not replace a mobile army.

## Construction pipeline

1. Player chooses an unlocked building.
2. Credits are deducted.
3. The Field Command construction queue counts down.
4. When construction finishes, the building becomes **ready to place**.
5. The player positions a footprint preview on valid cells inside construction radius.
6. Confirming placement creates the completed building.
7. The building becomes active and updates power/pathfinding/production state.

Only one unplaced completed building may wait in the construction queue. The player may cancel it for the normal construction refund.

## Placement rules

A footprint is valid when all required cells are:

- inside the map,
- marked buildable,
- inside connected friendly construction radius,
- not occupied by a building,
- not part of a Flux Ore deposit,
- not blocked terrain,
- not reserved by another pending placement.

Mobile touch gestures, confirmation/cancel controls and preview visuals are defined in `MOBILE_CONTROLS.md`.

### Construction radius

- Field Command: extends buildability **6 cells** from its footprint.
- Every completed friendly building also extends buildability **6 cells**.
- Radius propagation requires connection back to the Field Command through the chain of owned structures.
- Destroying an intermediate structure may remove future placement access beyond it, but already placed structures continue operating.

## Build prerequisites

Keep the tech tree minimal:

| Building | Prerequisite |
|---|---|
| Field Command | Pioneer Rig deployment |
| Grid Plant | Field Command |
| Ore Works | Grid Plant |
| Infantry Depot | Grid Plant |
| Vehicle Foundry | Ore Works + Infantry Depot |
| Guardian Turret | Infantry Depot |

Low power does not change unlock prerequisites.

## Production queues

- Each Infantry Depot / Vehicle Foundry has a separate queue of up to **5**.
- Production begins from the front of the queue.
- Finished units attempt to spawn at a designated exit edge.
- If all valid spawn cells are blocked, production completion waits without losing the unit.
- Buildings may have rally points; produced units automatically receive a move order to that point.

## Damage and destruction

- Buildings use Structure armor.
- At 0 HP, the building immediately stops contributing power, production, economy, construction radius and vision.
- Its occupied cells become available only after the gameplay destruction event clears the footprint.
- A destroyed Grid Plant may instantly put the owner into low power.
- A destroyed production building loses its queued items; **50% of the remaining queued credit value** is refunded as a forgiving Mission Zero starting rule.
- Destroying the Field Command triggers mission victory/defeat before any refund logic matters.

## No repair in Mission Zero

Building repair is deliberately excluded from the first playable mission. It adds economy/UI decisions that are not needed to validate the core loop. Revisit only after the base loop is fun.
