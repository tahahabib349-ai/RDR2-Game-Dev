# AI_HANDOFF

> Every AI updates this file at the end of every task. Newest information at the top of each
> section. Keep it short and factual.

## Current build

No game build yet. The repository now contains the Phase 0 game-design and technical-architecture
blueprint plus project documents/reference skills. Mobile controls remain pending.

## Phase

**Phase 0 — Blueprint** (in progress). See `ROADMAP.md`.

## Completed work

- 2026-10-06 · 🟢 ChatGPT + Game Director · Confirmed Mission Zero direction: Pioneer Rig remains
  permanently deployed after becoming Field Command; no repair/engineer system in the first
  Mission Zero build; target hardware is iPhone 11/A13-class or better with roughly Snapdragon
  855-class-or-better Android as the performance floor; 2D isometric architecture retained but
  visual direction clarified as modern 2.5D-style presentation rather than retro presentation.
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

- 2026-10-06 · Controls (Game Director decisions): **landscape only**; building placement uses
  small, calm ✓/✕ confirm buttons; smallest checked screen ~5.5", tablets show more battlefield
  rather than bigger buttons.
- Controls (proposed in `docs/MOBILE_CONTROLS.md`, pending approval): 1280×720 design
  resolution; one-finger drag pans, long-press-drag box-selects; orders fire on finger up;
  gesture thresholds live in a data file; one input layer turns touch/mouse into intents (Tap,
  DoubleTap, LongPressDrag, Pan, Pinch) that feed Selection/Commands.
- Engine: Godot 4.x with GDScript; pin one exact stable Godot 4.x release when Phase 1 starts.
- Targets: Android and iOS; desktop builds for development/testing.
- Presentation: modern 2D isometric / 2.5D visual treatment on a 2D simulation; gameplay uses logical orthogonal square-grid coordinates.
- Mission Zero map baseline: 72 x 72 cells.
- Pathfinding: shared `AStarGrid2D` for strategic paths plus lightweight local spacing; do not
  use NavigationServer initially unless profiling/playtests justify a change.
- Stats/balance: custom Godot Resource classes and text `.tres` files; gameplay numbers are not
  hard-coded into entity scripts.
- Simulation: fixed 20 Hz gameplay tick separated from rendering; fog may update at 5 Hz.
- Testing: first-party GDScript headless runner with real non-zero failure exit codes; no test plugin.
- Dependencies: no plugins/add-ons unless the Game Director approves them.
- Minimum performance class: iPhone 11 / A13 Bionic or better; Android roughly Snapdragon 855 /
  Adreno 640 class or better. 30 fps is the hard 100-unit stress minimum; 60 fps is preferred.

## Proposed changes awaiting the Game Director

- Answer `docs/MOBILE_CONTROLS.md` §16 question 3 (one-finger drag pans, long-press-drag
  box-selects). Landscape, screen size and ✓/✕ placement are settled.
- Assign an owner for `docs/ART_DIRECTION.md`.

## Known issues

- Blueprint numbers are explicitly tunable starting values and have not been validated in a playable
  build yet.
- Mobile control details are not yet specified, so selection/command gesture assumptions must not be
  hard-coded during Phase 1 before `docs/MOBILE_CONTROLS.md` is approved.

## Recently modified files

- 2026-10-06: `docs/TECHNICAL_ARCHITECTURE.md` (modern isometric direction + hardware baseline)
- 2026-10-06: `AI_HANDOFF.md` (Game Director decisions recorded)
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
