# AI_HANDOFF

> Every AI updates this file at the end of every task. Newest information at the top of each
> section. Keep it short and factual.

## Current build

No game build yet. The repository now contains the Phase 0 game-design and technical-architecture
blueprint plus project documents/reference skills. Mobile controls remain pending.

## Phase

**Phase 0 — Blueprint** (in progress). See `ROADMAP.md`.

## Completed work

- 2026-10-06 · 🟢 ChatGPT · Completed the Phase 0 blueprint: `docs/MISSION_ZERO.md`,
  `docs/GAME_DESIGN.md`, `docs/UNIT_SYSTEM.md`, `docs/BUILDING_SYSTEM.md`,
  `docs/ECONOMY.md`, and `docs/TECHNICAL_ARCHITECTURE.md`. Defined Mission Zero map/AI,
  original unit/building roster and tunable baseline balance, power/fog/economy rules, and a
  Godot 4.x architecture using 2D isometric presentation, a logical square grid,
  `AStarGrid2D`, Resource-based stats, fixed-step simulation, and headless tests.
- 2026-10-06 · 🔵 Joint (Claude) · Set up the repository: `MASTER_PROJECT_BRIEF.md` (the Game
  Director's brief, word for word), `AGENTS.md`, `AI_HANDOFF.md`, `ROADMAP.md`, `README.md`,
  empty `docs/` folder, and 75 game-dev reference skills in `.agents/skills/`.

## Current tasks

| Task | Owner | Status |
|---|---|---|
| Phase 0 blueprint docs: `docs/GAME_DESIGN.md`, `docs/MISSION_ZERO.md`, `docs/TECHNICAL_ARCHITECTURE.md`, `docs/UNIT_SYSTEM.md`, `docs/BUILDING_SYSTEM.md`, `docs/ECONOMY.md` | 🟢 ChatGPT | ✅ Complete; awaiting Game Director review |
| `docs/MOBILE_CONTROLS.md`: touch selection, move/attack, camera, pinch zoom, building placement, group control | 🟣 Claude | Not started |

## Next recommended task

🟣 Claude should create `docs/MOBILE_CONTROLS.md` and reconcile it with the completed blueprint,
especially tap-vs-drag selection behaviour, camera bounds/zoom, command gestures, placement
confirmation/cancel, group control and minimum touch-target size. After the Game Director approves
both Phase 0 workstreams, 🔨 Codex starts Phase 1.

## Architectural decisions

- Engine: Godot 4.x with GDScript; pin one exact stable Godot 4.x release when Phase 1 starts.
- Targets: Android and iOS; desktop builds for development/testing.
- Presentation: 2D isometric; gameplay uses logical orthogonal square-grid coordinates.
- Mission Zero map baseline: 72 x 72 cells.
- Pathfinding: shared `AStarGrid2D` for strategic paths plus lightweight local spacing; do not
  use NavigationServer initially unless profiling/playtests justify a change.
- Stats/balance: custom Godot Resource classes and text `.tres` files; gameplay numbers are not
  hard-coded into entity scripts.
- Simulation: fixed 20 Hz gameplay tick separated from rendering; fog may update at 5 Hz.
- Testing: first-party GDScript headless runner with real non-zero failure exit codes; no test plugin.
- Dependencies: no plugins/add-ons unless the Game Director approves them.

## Proposed changes awaiting the Game Director

None.

## Known issues

- Blueprint numbers are explicitly tunable starting values and have not been validated in a playable
  build yet.
- Mobile control details are not yet specified, so selection/command gesture assumptions must not be
  hard-coded during Phase 1 before `docs/MOBILE_CONTROLS.md` is approved.
- No target device has yet been selected for the 100-unit mid-range-phone performance benchmark.

## Recently modified files

- 2026-10-06: `docs/MISSION_ZERO.md`
- 2026-10-06: `docs/GAME_DESIGN.md`
- 2026-10-06: `docs/UNIT_SYSTEM.md`
- 2026-10-06: `docs/BUILDING_SYSTEM.md`
- 2026-10-06: `docs/ECONOMY.md`
- 2026-10-06: `docs/TECHNICAL_ARCHITECTURE.md`
- 2026-10-06: `AI_HANDOFF.md`

## Important warnings

- Godot is not preinstalled in cloud AI environments. Codex should install/use a pinned Godot 4.x
  headless-capable binary or setup script before claiming tests pass.
- Do not start Phase 1 implementation until the Game Director approves the architecture and
  `docs/MOBILE_CONTROLS.md` settles touch-selection/command behaviour.
- Keep the first implementation simple: no multiplayer, progression, monetization, ECS framework,
  general-purpose behaviour tree or third-party addon.
