# Unit System

> **All values below are tunable starting values for Mission Zero.** They exist to give implementation and playtesting a coherent baseline, not to lock final balance.

## Shared conventions

- Distance is expressed in **logical map cells**.
- Speed is **cells per second**.
- Fire rate is **shots per second**.
- Damage is raw damage before armor-profile multipliers.
- Units occupy continuous positions even though pathfinding uses the logical grid.
- Mission Zero has no veterancy, status effects, repair, transport, stealth or ammunition.

## Unit stats

> **2026-10-06 (🟣 Claude, covering 🟢 ChatGPT at the Game Director's request):** all speeds ×0.7 alongside the 108-cell map (`MISSION_ZERO.md`). Units used to cross the map in 12–22 s, which made it feel small; the Vanguard Tank now takes ~41 s base to base. Speed ratios between units are unchanged.

| Unit | Cost | Build time | HP | Armor | Damage / profile | Range | Fire rate | Speed | Power | Capacity / economy |
|---|---:|---:|---:|---|---|---:|---:|---:|---:|---|
| **Ranger** | 150 | 5 s | 100 | Infantry | 12 Small Arms | 4.5 | 1.20 | 2.3 | 0 | — |
| **Lancer** | 300 | 8 s | 90 | Infantry | 38 Piercing | 5.0 | 0.55 | 2.0 | 0 | — |
| **Jackal** | 500 | 12 s | 260 | Light | 18 Small Arms | 4.0 | 1.50 | 4.2 | 0 | — |
| **Vanguard Tank** | 900 | 18 s | 650 | Vehicle | 55 Cannon | 5.0 | 0.80 | 2.6 | 0 | — |
| **Breaker Tank** | 1,400 | 28 s | 1,000 | Heavy | 95 Heavy Cannon | 5.5 | 0.45 | 1.9 | 0 | — |
| **Gatherer** | 1,200 | 18 s | 750 | Vehicle | Unarmed | — | — | 2.2 | 0 | 1,000-credit-equivalent cargo |
| **Pioneer Rig** | 3,000* | 40 s* | 1,200 | Heavy | Unarmed | — | — | 1.6 | 0 | Deploys to Field Command in 3 s |

* The Pioneer Rig is **not producible in Mission Zero**. Cost/build time are reference values for later balancing; the player and AI each start with one.

## Damage versus armor multipliers

| Weapon profile | Infantry | Light | Vehicle | Heavy | Structure |
|---|---:|---:|---:|---:|---:|
| **Small Arms** | 1.00× | 0.80× | 0.35× | 0.20× | 0.25× |
| **Piercing** | 0.70× | 1.25× | 1.50× | 1.25× | 0.80× |
| **Cannon** | 0.60× | 1.00× | 1.00× | 1.00× | 1.20× |
| **Heavy Cannon** | 0.50× | 0.90× | 1.15× | 1.35× | 1.40× |

Final damage per hit:

`final_damage = raw_damage × armor_multiplier`

Mission Zero uses no random damage spread, critical hits or accuracy roll. A valid shot that connects deals deterministic damage.

## Roles and counter intent

### Ranger

The baseline infantry unit. Rangers are cheap enough to mass early and efficient against other Infantry. They should lose cost-efficiently to armored units if unsupported.

**Design test:** several Rangers can still finish a damaged tank, but equal-credit pure Rangers should not be the best answer to armor.

### Lancer

Slow-firing anti-armor infantry. Lancers punish vehicles but have lower health, movement speed and anti-infantry efficiency than Rangers.

**Design test:** two or three Lancers behind Rangers should noticeably change a tank fight; unsupported Lancers should be vulnerable to Rangers and Jackals.

### Jackal

Fast light vehicle for scouting, flanking and economic harassment. Its weapon mainly threatens infantry and Gatherers. It is not a miniature tank.

**Design test:** speed should create value even when its raw combat efficiency is lower than a Vanguard Tank.

### Vanguard Tank

The dependable main battle unit. Balanced mobility, HP and cannon damage make it the default armored core, but Piercing weapons punish it.

**Design test:** a player can understand "build these when unsure," while still improving results by mixing support units.

### Breaker Tank

Heavy assault armor. Expensive, slow and durable, with a weapon tuned for heavy targets and structures.

**Design test:** one Breaker should feel threatening, but replacing an entire mixed army with Breakers should create mobility and anti-infantry weaknesses.

### Gatherer

Economic unit. It travels to Flux Ore, harvests until full (or ordered home), returns to an Ore Works and unloads.

**Design test:** losing one hurts enough to matter but does not automatically end the match.

### Pioneer Rig

Deployment unit. It exists to make the match begin with a meaningful choice of where the permanent base anchor goes.

Mission Zero supports only **deploy**, not pack-up/redeploy.

## Movement and footprint starting values

| Unit class | Approx. collision/spacing radius |
|---|---:|
| Infantry | 0.22 cell |
| Jackal | 0.35 cell |
| Vanguard Tank | 0.45 cell |
| Breaker Tank | 0.55 cell |
| Gatherer | 0.50 cell |
| Pioneer Rig | 0.60 cell |

These are local-spacing values, not pathfinding-cell sizes. Multiple small units may occupy the same broad navigation corridor but should separate visually.

## Target acquisition starting values

- Default auto-acquisition radius: **weapon range + 1.5 cells**.
- Attack-move acquisition: same as auto-acquisition.
- Chase leash for incidental targets: **8 cells** from the unit/group's commanded route or destination.
- Direct attack command ignores the incidental leash until the target becomes invalid/unseen.
- Target preference may bias toward favorable armor matchups, but distance and immediate threats should keep behaviour predictable.

## Death

At 0 HP:

1. The unit becomes non-targetable immediately.
2. Its navigation/spacing reservation is released.
3. A short visual death effect plays.
4. The gameplay entity is removed from simulation.
5. Mission/economy/AI listeners receive a death event.

Visual effects must not delay gameplay-state cleanup.
