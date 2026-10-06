# Technical Architecture

> Phase 0 architecture for a small-team, placeholder-art mobile RTS in **Godot 4.x + GDScript**, targeting Android and iOS. The goal is the simplest structure that lets Codex implement, test and tune Mission Zero without painting the project into a corner.

## Decision summary

| Question | Decision |
|---|---|
| Presentation | **2D isometric** |
| Gameplay map | **Logical orthogonal square grid**, rendered isometrically |
| Pathfinding | **AStarGrid2D** for strategic paths + lightweight local spacing; not NavigationServer initially |
| Unit count target | Approximately **100 active units** on a mid-range phone |
| Game data | Custom Godot **Resource** classes with `.tres` assets |
| Simulation | **Fixed 20 Hz gameplay tick**, rendering/interpolation separate |
| Networking | None in current architecture |
| Automated testing | Plain GDScript headless runner using `godot --headless`; no testing plugin |
| Dependencies | Godot only; no plugins/add-ons unless later approved |

Codex should pin one exact stable Godot 4.x release when Phase 1 creates `game/project.godot` and the setup script. Do not silently float engine versions between machines.

## Why 2D isometric

### Chosen: 2D isometric

This gives the battlefield the classic RTS spatial feel while keeping the project practical for a small team:

- units/buildings can start as simple sprites, shapes and labels,
- maps can be authored from 2D tiles,
- selection and placement remain 2D math,
- there is no 3D camera, lighting, rigging, animation or mesh pipeline to solve before the game is fun,
- mobile rendering cost is easier to control.

### Rejected for now: pure 2D top-down

Top-down would be the cheapest implementation, but it sacrifices too much of the intended base-building battlefield feel. We can still use top-down **logical coordinates internally** while projecting them into an isometric view.

### Rejected for now: 3D

3D adds camera perspective, meshes, materials, lighting, animation, depth/occlusion and substantially larger art/performance scope. None of that helps prove Mission Zero's core strategy loop. Do not use 3D just to imitate an isometric camera.

## Coordinate model: logical grid, isometric rendering

The game should not make isometric screen coordinates the source of truth.

### Logical world

- Mission Zero map: **72 x 72 logical square cells**.
- Core gameplay coordinates are `Vector2` / `Vector2i` in logical map space.
- Terrain cells store flags/data such as:
  - passable,
  - buildable,
  - resource amount,
  - reserved/occupied building footprint.
- Unit positions are continuous logical coordinates, not locked to cell centers.
- Buildings occupy integer cell footprints.

### Rendering

Use one or more Godot `TileMapLayer` nodes for terrain/background/decorative layers. The TileSet may be configured for an isometric visual projection.

Gameplay systems query the logical map model, not decorative TileMap art. This prevents a visual tile change from accidentally changing rules.

A small conversion service owns:

- logical world → rendered isometric position,
- rendered pointer position → logical world/cell,
- logical bounds → camera/render bounds.

Only that service should know the projection formula.

## Pathfinding decision

### Use AStarGrid2D initially

For Mission Zero, `AStarGrid2D` is the better fit than Godot's navigation server.

Reasons:

- the battlefield is already a finite grid,
- building footprints can mark cells blocked/unblocked directly,
- path results are deterministic and easy to test headlessly,
- there are no arbitrary 3D navigation meshes,
- we do not need sophisticated dynamic obstacle avoidance to prove the game,
- debugging a wrong path is easier when every cell can be inspected.

### Why not NavigationServer initially

`NavigationServer2D` / navigation regions are useful for free-form polygon navigation and built-in avoidance, but they add more runtime state and tuning than Mission Zero needs. For a 72 x 72 grid with about 100 units, predictable grid pathfinding plus simple group/spacing behaviour is easier to control.

This is not a permanent ban. Revisit only if profiling/playtests show the grid approach cannot produce acceptable movement.

### Pathfinding rules

- Maintain one shared `AStarGrid2D` for the current mission.
- Static terrain initializes walkability once.
- Placed/destroyed buildings update affected blocked cells.
- A unit requests a path when receiving a new movement destination, when its path becomes invalid, or when it has been stuck beyond a short threshold.
- **Do not recompute every unit's path every simulation tick.**
- Queue/spread expensive re-path requests across ticks if many units are ordered at once.
- Group commands generate nearby destination slots so 20 units do not all demand the exact same final point.
- Local unit-to-unit crowding is handled by lightweight separation/priority rules, not by marking every moving unit as a hard A* obstacle.

### Local movement

Units follow path waypoints in continuous logical space. A small steering layer:

- separates overlapping units,
- slows when the next waypoint is congested,
- gives larger units slightly higher right-of-way priority,
- detects "stuck" units and requests a re-path.

Avoid full rigid-body physics for army movement. RTS units are gameplay agents, not physically simulated vehicles.

## Data-driven stats with Godot Resources

Balance values must not be hard-coded in unit/building scripts.

Create custom `Resource` classes such as:

- `UnitStats`
- `WeaponStats`
- `BuildingStats`
- `ProductionEntry`
- `MissionConfig`

Store individual definitions as text `.tres` files, for example:

```text
game/data/units/ranger.tres
game/data/units/lancer.tres
game/data/units/vanguard_tank.tres
game/data/buildings/grid_plant.tres
game/data/weapons/small_arms_rifle.tres
game/data/missions/mission_zero.tres
```

Scripts receive a Resource reference and read values such as HP, cost, speed, range and build time. Runtime health/cooldowns/cargo stay on the gameplay entity; **do not mutate the shared Resource**.

This means balancing can change a `.tres` number without editing code.

## Scene and folder structure

Keep the project understandable rather than highly abstract.

```text
game/
  project.godot

  scenes/
    main.tscn
    missions/
      mission_zero.tscn
    units/
      unit.tscn
      projectile.tscn
    buildings/
      building.tscn
    ui/
      hud.tscn

  scripts/
    core/
      simulation_clock.gd
      game_session.gd
      map_model.gd
      iso_projection.gd

    selection/
      selection_controller.gd

    commands/
      command_controller.gd
      order.gd

    movement/
      path_service.gd
      unit_movement.gd
      group_slots.gd

    combat/
      health_component.gd
      weapon_controller.gd
      projectile.gd
      combat_system.gd

    construction/
      construction_system.gd
      placement_rules.gd

    production/
      production_system.gd

    economy/
      economy_system.gd
      gatherer_controller.gd

    power/
      power_system.gd

    fog/
      fog_system.gd

    ai/
      mission_zero_ai.gd

    mission/
      objective_system.gd

    data/
      unit_stats.gd
      weapon_stats.gd
      building_stats.gd
      mission_config.gd

  data/
    units/
    weapons/
    buildings/
    missions/

  tests/
    test_runner.gd
    unit/
    integration/
```

Do not create every file on day one. This is the target separation as systems arrive through the roadmap.

## System boundaries

The important rule is that each system owns one kind of decision.

### Selection

Owns:

- what friendly units/buildings are selected,
- selection-set changes,
- drag/tap selection queries supplied by the controls layer.

Does **not** move or attack units.

### Commands

Owns:

- translating player/AI intent into explicit gameplay orders,
- move, attack, attack-move, stop, deploy and later rally/harvest commands,
- validating that the selected entity can receive an order.

Player controls and AI should both go through the same command interface whenever practical. The AI should not directly teleport or damage entities.

### Movement

Owns:

- path requests,
- waypoint following,
- destination slots,
- local separation,
- stuck detection,
- logical unit position.

Does **not** decide what enemy to attack.

### Combat

Owns:

- target validity,
- range/cooldown,
- armor multiplier,
- projectile creation/resolution,
- damage,
- death event.

Movement may be asked to approach a combat target, but combat decides whether a shot is legal.

### Construction

Owns:

- base construction queue,
- build timers,
- placement readiness,
- footprint validity,
- construction-radius rules,
- committing/removing a building footprint.

### Production

Owns:

- per-building unit queues,
- cost reservation/refunds through Economy,
- build progress,
- spawn-exit resolution,
- rally order after spawn.

### Economy

Owns:

- player/AI credit balances,
- Flux Ore remaining values,
- Gatherer cargo transfer,
- credit change events,
- affordability transactions.

No other system should directly set credits.

### Power

Owns:

- total supply/demand,
- normal/low-power state,
- power-state change events,
- applying the documented production/construction/turret modifiers.

Other systems ask Power for the current modifier rather than recalculating the rule.

### Fog of war

Owns:

- explored/visible cells per side,
- vision-source registration,
- visibility queries for selection/targeting/rendering.

Combat asks Fog whether a target is currently visible.

### AI

Owns:

- Mission Zero build script,
- unit composition and wave scheduling,
- choosing strategic destinations/targets.

It issues normal construction/production/command requests and receives the same economic/power limitations as the player.

### Mission/objectives

Owns:

- mission start,
- objective text/state,
- win/lose checks,
- victory/defeat flow.

It observes destruction and other system events; it should not contain combat or economy logic.

## Communication between systems

Prefer explicit method calls for direct requests and Godot signals for events.

Examples:

- Command → Movement: `issue_move(entity_ids, destination)`
- Combat emits: `entity_destroyed(entity_id, owner_id)`
- Economy emits: `credits_changed(owner_id, new_amount)`
- Power emits: `power_state_changed(owner_id, is_low_power)`
- Mission listens to Field Command destruction.
- UI listens to state changes but does not own game rules.

Avoid a giant global singleton that contains every system.

A small `GameSession` may hold references to mission-level services, and a `SimulationClock` may own ticking. Everything else should be mission-scoped nodes/services.

## Fixed-timestep simulation

Mission Zero has no networking, but simulation should still be independent from render frame rate.

### Starting tick rate

- Gameplay simulation: **20 ticks per second** (50 ms per tick).
- Rendering: device frame rate, normally 60 fps when performance allows.
- Visual nodes interpolate between previous/current simulation positions.

Systems updated on the fixed gameplay tick include:

- movement,
- weapon cooldowns/combat decisions,
- projectiles,
- construction/production timers,
- harvesting/unloading,
- power updates when dirty,
- AI scheduling.

Fog can update at **5 Hz** unless a playtest proves that feels delayed.

### Why

A fixed simulation makes:

- balance timings stable across 30/60/120 Hz displays,
- headless tests repeatable,
- pause/speed/debug stepping easier,
- future replay/network research less painful without building networking now.

Do **not** implement lockstep networking, rollback, determinism infrastructure or multiplayer prediction.

## IDs and runtime entities

Give each gameplay entity a simple unique integer ID for the current match. Commands and system events may reference IDs rather than keeping fragile cross-tree node pointers.

The scene node is the presentation/controller for that entity; the authoritative runtime state remains mission-local and is removed on death.

Keep this lightweight: no general ECS framework is needed.

## Mobile performance guardrails

Target roughly **100 active units** in the Mission Zero stress test.

Rules:

- profile before optimizing,
- no per-frame global searches like "find every unit" from each unit,
- spatial queries should use a simple grid/bucket index when combat target scans become expensive,
- do not rebuild A* paths every tick,
- pool projectiles/effects only if profiling shows spawn/free churn matters,
- keep placeholder visuals cheap and shared,
- test release builds on actual mid-range Android hardware before declaring performance solved.

Initial performance acceptance target: stable **30 fps minimum** on the chosen mid-range test phone during a 100-unit battle, with 60 fps as the preferred experience where hardware allows.

## Headless Godot testing

No third-party testing plugin is required.

Codex should provide a minimal GDScript `SceneTree` test runner under `game/tests/test_runner.gd` that:

- counts passes/failures itself,
- exits with `quit(1)` if any test fails,
- never relies on bare `assert()` to set the process exit code,
- can run pure logic tests without opening the editor.

Fresh checkout flow:

```bash
godot --headless --path game --import
godot --headless --path game --script res://tests/test_runner.gd
```

The first command builds the import cache so custom `class_name` Resources and assets resolve correctly.

### Test layers

**Unit tests**

- damage multiplier calculations,
- affordability/refunds,
- power-state modifiers,
- construction prerequisite/placement rules,
- path cell blocking,
- production timing,
- harvest/unload arithmetic,
- objective win/lose conditions.

**Integration tests**

- deploy Pioneer Rig → Field Command,
- build Grid Plant/Ore Works,
- Gatherer completes one income cycle,
- queue and spawn a unit,
- issue move order around blocked cells,
- kill a target and verify cleanup,
- destroy Field Command and verify victory/defeat signal.

**Mission smoke test**

Run Mission Zero headlessly for a bounded simulated duration with scripted commands and verify there are no fatal errors, invalid paths or stuck queues. It does not prove fun; the Game Director still performs the real feel playtest.

## What is deliberately not designed now

- multiplayer/netcode,
- accounts/backend,
- monetization,
- progression/veterancy trees,
- persistence,
- campaign framework,
- mod support,
- general-purpose behaviour trees,
- dependency injection frameworks,
- ECS frameworks,
- third-party Godot addons.

Add complexity only when a measured problem or approved roadmap phase requires it.
