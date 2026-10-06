# Game Design

> **Status:** Phase 0 blueprint. Names and numbers are original placeholders. Numerical values are tunable starting points.

## Design goal

Build a mobile-first real-time strategy game that preserves direct player control and the classic base-building loop:

**deploy → establish power → harvest → build production → create a mixed army → defend → expand → attack → destroy the enemy command structure**

Mission Zero must make this loop enjoyable before the project grows into campaign, skirmish or later systems.

## Core loop

### 1. Establish

The player starts with a **Pioneer Rig**, deploys it into a **Field Command**, and gains a construction radius.

### 2. Power

Build a **Grid Plant**. Power is a shared base-wide capacity. New structures consume power, so expansion creates a reason to add generation.

### 3. Economy

Build an **Ore Works** beside a practical route to a **Flux Ore** field. Its Gatherer travels to the field, harvests, returns and converts the cargo into credits.

### 4. Production

Build an **Infantry Depot** and **Vehicle Foundry**. Spend credits on units through production queues.

### 5. Defense and information

Use units, terrain chokepoints and **Guardian Turrets** to survive pressure. Explore to reveal the map and locate threats through fog of war.

### 6. Army composition

Mix fast scouting, anti-armor infantry and different armored units. A single unit type should be exploitable by a counter.

### 7. Attack

Choose a route, push toward the enemy base and destroy its **Field Command**.

## Buildings: Mission Zero roster

| Building | Role | Key relationship |
|---|---|---|
| **Field Command** | Base anchor and building construction source | Mission-critical; created by deploying the Pioneer Rig |
| **Grid Plant** | Generates power | Enables the rest of the base to run efficiently |
| **Ore Works** | Economy building; receives Gatherers | Includes one Gatherer on completion |
| **Infantry Depot** | Produces Rangers and Lancers | Cheap early military production |
| **Vehicle Foundry** | Produces Jackals, Vanguard Tanks, Breaker Tanks and replacement Gatherers | Expensive but unlocks mobile armor |
| **Guardian Turret** | Static ground defense | Stronger with army support; weakened by low power |

Detailed first-pass values are in `BUILDING_SYSTEM.md`.

## Units: Mission Zero roster

| Unit | Role | Strong against | Vulnerable to |
|---|---|---|---|
| **Ranger** | Cheap general-purpose infantry | Enemy infantry, light pressure | Tanks, concentrated fire |
| **Lancer** | Anti-armor infantry with slow heavy shot | Jackals, Vanguard/Breaker Tanks | Rangers, fast focus fire |
| **Jackal** | Fast light scout/raider | Rangers, exposed Gatherers, map control | Lancers, tanks, turrets |
| **Vanguard Tank** | Mainline armored unit | Light vehicles, general combat, structures | Lancers, Breaker Tanks in straight fights |
| **Breaker Tank** | Slow heavy assault unit | Heavy armor, structures | Cost, speed, being surrounded without support |
| **Gatherer** | Economic vehicle | Resource collection | Raids; it is unarmed |
| **Pioneer Rig** | Starting deployment vehicle | Establishing the base | Losing it before deployment; unarmed |

Detailed values are in `UNIT_SYSTEM.md`.

## Counter model

Mission Zero uses a small damage/armor matrix rather than many hidden exceptions.

Armor types:

- **Infantry**
- **Light**
- **Vehicle**
- **Heavy**
- **Structure**

Weapon profiles:

- **Small Arms:** best versus Infantry; poor versus armored targets.
- **Piercing:** anti-vehicle profile; good versus Light/Vehicle/Heavy.
- **Cannon:** dependable general armored damage.
- **Heavy Cannon:** best versus Heavy and Structure; inefficient versus Infantry.

The exact multipliers are defined in `UNIT_SYSTEM.md`.

The goal is not perfect rock-paper-scissors. A bigger force can still win a poor matchup, but composition should materially affect cost efficiency.

## Construction rules

- The Field Command maintains one base-construction queue.
- The player pays the full credit cost when construction begins.
- Cancelling an unfinished building refunds **75%** of its cost.
- Completed buildings must be placed on valid buildable cells inside the player's construction radius.
- Construction radius extends **6 logical cells** from the Field Command and each completed owned building, creating a connected base footprint.
- Buildings may not overlap blocked terrain, resources, another structure, or reserved placement cells.
- Units standing in a footprint temporarily make placement invalid; the player must move them.
- Buildings become functional only after placement is completed.
- Grid Plants are always allowed to construct at full construction speed even during low power so the player cannot enter a hard lock.

The mobile gesture/preview flow for placement belongs to `MOBILE_CONTROLS.md`.

## Production rules

- Infantry Depot and Vehicle Foundry each have their own production queue.
- Queue length: **up to 5 items** per production building.
- Credits are deducted when an item is queued.
- Cancelling a queued but not completed unit refunds **100%** if production has not started and **75%** once production has started.
- One item is produced at a time per building; multiple production buildings can operate in parallel.
- Finished units spawn at the nearest valid exit cell and move toward the building rally point if one is set.
- If the exit is blocked, the completed unit waits safely in the production building until a valid cell opens.

## Power rules

Power is intentionally simple and base-wide.

### Supply and demand

- Grid Plants add power supply.
- Most other structures add power demand.
- Units do not consume power.
- `available_power = total_supply - total_demand`.

### Normal power

When supply is at least demand:

- Construction operates at 100% speed.
- Unit production operates at 100% speed.
- Guardian Turrets use their normal fire rate.

### Low power

When demand exceeds supply:

- A clear **LOW POWER** state is shown in the HUD.
- Non-Grid-Plant building construction progresses at **50% speed**.
- Infantry and vehicle production progresses at **50% speed**.
- Guardian Turret weapon cooldowns become **1.5× longer**.
- Ore Works and Gatherer unloading remain at full rate so the player can recover.
- Existing mobile units keep normal movement, vision and weapons.
- Grid Plant construction remains at 100% speed.

There is no second "blackout" threshold in Mission Zero. One readable rule is enough.

## Fog of war

Mission Zero uses three map-information states:

### Unexplored

- Covered by opaque shroud.
- Terrain details, resources and enemy entities are hidden.
- Own units can be ordered into unexplored space if the player taps a valid map position.

### Explored but not currently visible

- Terrain and known resource fields remain visible but dimmed.
- Enemy units and enemy buildings are not shown.
- No "last known enemy" ghost markers in Mission Zero.
- The player may issue movement/attack-move commands into the area, but cannot directly target an unseen enemy.

### Visible

- Terrain is fully lit.
- Enemy units/buildings inside current vision can be seen and targeted.
- Projectiles already fired may complete their current travel after a target leaves vision, but no new attack begins against an unseen target.

### Vision sources

Suggested starting sight radii are measured in logical cells:

| Source | Sight radius |
|---|---:|
| Ranger | 7 |
| Lancer | 6 |
| Jackal | 9 |
| Vanguard Tank | 7 |
| Breaker Tank | 6 |
| Gatherer | 6 |
| Pioneer Rig | 7 |
| Field Command | 9 |
| Grid Plant / Ore Works / Infantry Depot / Vehicle Foundry | 5 |
| Guardian Turret | 7 |

Fog may update at a lower frequency than rendering, initially **5 times per second**, if profiling shows that is sufficient. Mission Zero does not require terrain height or cliff line-of-sight occlusion; vision is radial and blocked only by map bounds.

## Combat behaviour

- A direct attack order causes the selected combat units to pursue until the target is in weapon range, then fire.
- An attack-move order moves toward a location while acquiring hostile targets within normal acquisition range.
- Units stop chasing an incidental target if it exceeds a limited leash from the commanded route.
- Units should not automatically cross the map because they briefly saw an enemy.
- Friendly fire is off for Mission Zero.
- No veterancy, suppression, morale, cover, repair, stealth, aircraft or naval combat.

## Design principles for the prototype

- **Readable before realistic:** clear ranges, silhouettes and damage relationships matter more than simulation detail.
- **Economy creates pressure:** the player should regularly choose between production, power, defense and expansion.
- **Counters are visible:** players should learn by watching outcomes, not by reading hidden formulas.
- **Mobile control remains direct:** do not solve touch constraints by automating the strategy away.
- **Failure should teach:** losing a Gatherer, power or a chokepoint should have an understandable cause.
- **No content inflation:** do not add a seventh building or eighth unit until Mission Zero demonstrates a specific design need.
