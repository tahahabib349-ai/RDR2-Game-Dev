# AI_HANDOFF

> Every AI updates this file at the end of every task. Newest information at the top of each
> section. Keep it short and factual.

## Current build

No game build yet. The repository holds only project documents and reference skills.

## Phase

**Phase 0 — Blueprint** (in progress). See `ROADMAP.md`.

## Completed work

- 2026-10-06 · 🟣 Claude · Wrote `docs/MOBILE_CONTROLS.md` (draft v1): screen layout, gesture
  map, tap-target rules, orders and feedback, control groups, camera, building placement,
  production queues, accidental-input protection, desktop test controls, per-phase rollout, test
  plan. Awaiting Game Director approval and answers to its §16 questions.
- 2026-10-06 · 🔵 Joint (Claude) · Set up the repository: `MASTER_PROJECT_BRIEF.md` (the Game
  Director's brief, word for word), `AGENTS.md`, `AI_HANDOFF.md`, `ROADMAP.md`, `README.md`,
  empty `docs/` folder, and 75 game-dev reference skills in `.agents/skills/`.

## Current tasks

| Task | Owner | Status |
|---|---|---|
| Phase 0 blueprint docs: `docs/GAME_DESIGN.md`, `docs/MISSION_ZERO.md`, `docs/TECHNICAL_ARCHITECTURE.md`, `docs/UNIT_SYSTEM.md`, `docs/BUILDING_SYSTEM.md`, `docs/ECONOMY.md` | 🟢 ChatGPT | Not started |
| `docs/MOBILE_CONTROLS.md`: touch selection, move/attack, camera, pinch zoom, building placement, group control | 🟣 Claude | Draft v1 done; awaiting Game Director approval |
| `docs/ART_DIRECTION.md` | Unassigned (proposed: 🟢 ChatGPT, with 🟣 Claude for UI visuals) | Not started |

## Next recommended task

After both Phase 0 tasks are approved by the Game Director: 🔨 Codex starts Phase 1 (create the
Godot 4 project in `game/`, battlefield, camera, selection, movement, pathfinding). The prompt is
written once the architecture doc exists.

## Architectural decisions

- Controls (proposed in `docs/MOBILE_CONTROLS.md`, pending approval): landscape only; 1280×720
  design resolution; one-finger drag pans, long-press-drag box selects; orders fire on finger
  up; gesture thresholds live in a data file. Recommendation to the architect: one input layer
  turns touches/mouse into intents (Tap, DoubleTap, LongPressDrag, Pan, Pinch).

- Engine: Godot 4.x with GDScript (Game Director's choice).
- Targets: Android and iOS; desktop builds for development and testing.
- 2D vs 3D, map representation and pathfinding approach are **not decided yet**. They belong to
  `docs/TECHNICAL_ARCHITECTURE.md` (🟢 ChatGPT).

## Proposed changes awaiting the Game Director

- Answer `docs/MOBILE_CONTROLS.md` §16 (landscape only, smallest phone, pan vs box-select
  gesture, ✓/✕ placement confirm).
- Assign an owner for `docs/ART_DIRECTION.md`.
- Complete the fog-of-war section of the brief (it is cut off mid-sentence).
- Pin an exact Godot 4.x version (belongs in `TECHNICAL_ARCHITECTURE.md`).

## Known issues

None (no code yet).

## Recently modified files

- 2026-10-06: `docs/MOBILE_CONTROLS.md` (new), `AI_HANDOFF.md`.
- 2026-10-06: all files (initial setup).

## Important warnings

- Godot is not preinstalled in cloud AI environments. Whoever writes the first code must install
  a pinned Godot 4.x headless build (or set up a setup script) so tests can run.
- `docs/TECHNICAL_ARCHITECTURE.md` (🟢) should read `docs/MOBILE_CONTROLS.md` §12, which lists
  what the 2D-vs-3D decision changes for controls.
- Don't start Phase 1 code before the architecture doc settles 2D vs 3D and the pathfinding
  approach.
