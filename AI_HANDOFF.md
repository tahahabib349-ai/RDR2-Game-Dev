# AI_HANDOFF

> Every AI updates this file at the end of every task. Newest information at the top of each
> section. Keep it short and factual.

## Current build

No game build yet. The repository holds only project documents and reference skills.

## Phase

**Phase 0 — Blueprint** (in progress). See `ROADMAP.md`.

## Completed work

- 2026-10-06 · 🔵 Joint (Claude) · Set up the repository: `MASTER_PROJECT_BRIEF.md` (the Game
  Director's brief, word for word), `AGENTS.md`, `AI_HANDOFF.md`, `ROADMAP.md`, `README.md`,
  empty `docs/` folder, and 75 game-dev reference skills in `.agents/skills/`.

## Current tasks

| Task | Owner | Status |
|---|---|---|
| Phase 0 blueprint docs: `docs/GAME_DESIGN.md`, `docs/MISSION_ZERO.md`, `docs/TECHNICAL_ARCHITECTURE.md`, `docs/UNIT_SYSTEM.md`, `docs/BUILDING_SYSTEM.md`, `docs/ECONOMY.md` | 🟢 ChatGPT | Not started |
| `docs/MOBILE_CONTROLS.md`: touch selection, move/attack, camera, pinch zoom, building placement, group control | 🟣 Claude | Not started |

## Next recommended task

After both Phase 0 tasks are approved by the Game Director: 🔨 Codex starts Phase 1 (create the
Godot 4 project in `game/`, battlefield, camera, selection, movement, pathfinding). The prompt is
written once the architecture doc exists.

## Architectural decisions

- Engine: Godot 4.x with GDScript (Game Director's choice).
- Targets: Android and iOS; desktop builds for development and testing.
- 2D vs 3D, map representation and pathfinding approach are **not decided yet**. They belong to
  `docs/TECHNICAL_ARCHITECTURE.md` (🟢 ChatGPT).

## Proposed changes awaiting the Game Director

None.

## Known issues

None (no code yet).

## Recently modified files

- 2026-10-06: all files (initial setup).

## Important warnings

- Godot is not preinstalled in cloud AI environments. Whoever writes the first code must install
  a pinned Godot 4.x headless build (or set up a setup script) so tests can run.
- Don't start Phase 1 code before the architecture doc settles 2D vs 3D and the pathfinding
  approach.
