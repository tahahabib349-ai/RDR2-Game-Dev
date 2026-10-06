# AI_HANDOFF

> Every AI updates this file at the end of every task. Newest information at the top of each
> section. Keep it short and factual.

## Current build

Playable **Phase 1 greybox** in `game/`, pinned to **Godot 4.6.3 stable, official 7d41c59c4**.
Breakpoint Valley: 72×72 logical cells, 64×32 isometric TileMapLayer, blocked rocky ridge,
Central Pass/East Cut and visual-only ore/base landmarks. Seven labelled placeholder units
exercise selection, group movement and differing speeds. This test roster is deliberately more
than Mission Zero's eventual single-Rig opening; no combat, construction, economy, fog or AI.

Run/setup/test instructions and phone checklist: `game/README.md`. Headless and rendered desktop
runs: **88 passed, 0 failed**; intentional failure diagnostic returned exit code **1**.
Physical-phone gesture feel, safe-area behaviour and performance have **not** been validated.
No Android/iOS export artifact was produced.

## Phase

**Phase 1 — Battlefield and movement** implemented; awaiting physical-phone acceptance.
The Game Director explicitly requested Phase 1 implementation on 2026-10-06. See `ROADMAP.md`.

## Completed work

- 2026-10-06 · 🟣 Claude · Reviewed Phase 1 against `MOBILE_CONTROLS.md` §14/§15 and the
  blueprint. Re-ran setup + suite: 88 passed, 0 failed, exit 0. Every Phase 1 control is present;
  no later-phase scope. Findings logged under Known issues (camera edge visibility, a third route
  along the west edge, undocumented ridge extension, `rg` dependency in `tools/test.sh`).
- 2026-10-06 · 🔨 Codex · Implemented Phase 1 only: Godot project/scenes, Resource-based
  gesture/map/unit data, logical-to-isometric conversion, greybox terrain, shared AStarGrid2D,
  distinct group slots, local spacing/re-path recovery, fixed 20 Hz movement and visual interpolation.
  One raw input adapter produces selection/camera/command intents for touch and desktop.
  Includes tap/double-tap, two-finger held box vs immediate pinch, UI-origin/cancel protection,
  ✕, All Army, move markers, camera limits/inertia/anchored zoom, landscape-only canvas_items/expand
  and safe-area HUD. Godot GUI touch buttons are explicitly routed without mouse emulation.
- 2026-10-06 · 🔨 Codex · Verified 88 checks in both headless and software-OpenGL desktop runners;
  inspected rendered greybox screenshots. Tested exact-version setup's download branch against
  official pinned SHA-512, repeat setup, and nonzero runner failure exit. Godot installed under
  `/workspace/.tools/godot-4.6.3`; writable cache/data/config live under `/workspace/.runtime/godot`.

- 2026-10-06 · 🟣 Claude · `docs/MOBILE_CONTROLS.md` draft v2: aligned with ChatGPT's blueprint
  (2D isometric, Pioneer Rig/Field Command/Gatherer names, one construction queue, 5-item
  production queues, refund rules, Gatherer unload orders); recorded the Game Director's
  landscape-only and ✓/✕ placement decisions. (v1 was written earlier the same day: layout,
  gestures, tap targets, orders/feedback, control groups, camera, placement, production,
  accidental-input protection, desktop test controls, per-phase rollout, test plan.)
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
| Phase 1 battlefield/movement/controls | 🔨 Codex | ✅ Implemented; 88 checks pass; phone acceptance pending |
| Phase 1 phone playtest | Game Director, with 🔨 Codex preparing deployment/fixes | Not performed; no mobile export yet |
| Phase 0 blueprint docs: `docs/GAME_DESIGN.md`, `docs/MISSION_ZERO.md`, `docs/TECHNICAL_ARCHITECTURE.md`, `docs/UNIT_SYSTEM.md`, `docs/BUILDING_SYSTEM.md`, `docs/ECONOMY.md` | 🟢 ChatGPT | ✅ Complete; awaiting Game Director review |
| `docs/MOBILE_CONTROLS.md`: touch selection, move/attack, camera, pinch zoom, building placement, group control | 🟣 Claude | ✅ Draft v3 complete; Phase 1 subset implemented per Game Director request |
| `docs/ART_DIRECTION.md` | Unassigned (proposed: 🟢 ChatGPT, with 🟣 Claude for UI visuals) | Not started |

## Next recommended task

🔨 Codex: prepare an Android test export when a target device is chosen, then address Phase 1
phone-playtest findings before combat. The Game Director should especially check held two-finger
box selection vs immediate pinch, quick move orders, pan-with-selection, unit crowding and notches.

Suggested next Codex prompt: "Read AGENTS.md, AI_HANDOFF.md and game/README.md. Prepare a debug
Android test APK for the existing Phase 1 project using the pinned Godot 4.6.3 release. Keep gameplay
scope unchanged, validate the export honestly, and record deployment/toolchain requirements."
Phase 2 is not started or authorized by this task.

## Architectural decisions

- 2026-10-06 · Controls (Game Director decisions): **one finger scrolls the map, two fingers held
  still draw the selection box** (two fingers moving at once = pinch zoom); **landscape only**; building placement uses
  small, calm ✓/✕ confirm buttons; smallest checked screen ~5.5", tablets show more battlefield
  rather than bigger buttons.
- Phase 1 controls (implemented per the Game Director's request): 1280×720 design
  resolution; orders fire on finger up;
  gesture thresholds live in a data file; one input layer turns touch/mouse into intents (Tap,
  DoubleTap, Pan, TwoFingerBox, Pinch) that feed Selection/Commands.
- Engine: **Godot 4.6.3 stable official 7d41c59c4**, GDScript; full pin in `game/GODOT_VERSION`.
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

- Assign an owner for `docs/ART_DIRECTION.md`.

## Known issues

- 🟣 Review 2026-10-06 · **Camera can't show the map's edges.** The camera keeps the whole screen
  inside the map diamond, so strips along every edge can never be on screen: about 12% of
  walkable cells at the default zoom (1.5) and 5% even fully zoomed in (2.5), measured at
  1280×720. Units can walk there and vanish. Conflicts with MISSION_ZERO ("clamped to the full
  playable map with a small presentation margin") and MOBILE_CONTROLS §8. Owner: 🔨 Codex.
- 🟣 Review 2026-10-06 · **Third route along the west edge.** The ridge starts at (8,40) as the
  blueprint says, which leaves cells x<7 open. With Central Pass and East Cut both closed, a path
  of 75 cells still links the bases (Central route 58, East Cut route 68). MISSION_ZERO describes
  two routes. Design decision: 🟢 ChatGPT.
- 🟣 Review 2026-10-06 · `mission_zero.tres` extends the ridge beyond the blueprint's (48,18)
  end, through (56,32), (50,42) and (58,56), to force the East Cut. It's a reasonable reading but
  undocumented; 🟢 ChatGPT should confirm it or update MISSION_ZERO.md.
- 🟣 Review 2026-10-06 · `game/tools/test.sh` needs ripgrep (`rg`); use `grep` so it runs anywhere.
- Blueprint balance numbers remain tunable starting values; only movement is implemented/tested.
- The 0.2 s box-vs-pinch rule is covered by automated tests, but physical-phone feel is untested.
  A dedicated box button remains a fallback if playtests show the gesture is unreliable.
- Headless tests exercise viewport touch events and safe-area math; they do not prove real-device
  rotation/notch handling, sustained FPS, thermals or 100-unit performance.
- Android/iOS export templates/toolchains and signing are not prepared. iOS needs macOS.
- Placeholder unit labels/art and simple local spacing need playtesting; no polished audio,
  haptics, tablet physical sizing or later-phase control groups/combat shortcuts are included.

## Recently modified files

- 2026-10-06: `AI_HANDOFF.md` (🟣 Claude Phase 1 review findings)
- 2026-10-06 · 🔨 Codex: `game/` project, scenes, scripts, `.tres` data, headless runner, pinned
  setup/test scripts and README; `AI_HANDOFF.md`, `ROADMAP.md`.

- 2026-10-06: `docs/MOBILE_CONTROLS.md` (v3, two-finger box select), `AI_HANDOFF.md` (🟣 Claude)
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

- 2026-10-06: **The Game Director's test phone is an iPhone (no Android).** An APK can't be
  playtested. Plan proposed by 🟣 Claude: a single-threaded Godot **Web export** hosted on GitHub
  Pages and played in iPhone Safari for control-feel testing now. A native iOS build (Mac or cloud
  Mac, Apple Developer account, TestFlight) comes later for performance testing.
- Source `game/tools/env.sh` before direct Godot invocations in cloud tasks; use
  `game/tools/setup.sh` for exact-version installation/import/tests. Do not silently float versions.
- Use the existing isolated checkout, without a worktree unless explicitly requested.
- The Game Director's Phase 1 implementation request supplies authorization for that scope;
  it does not authorize combat, construction or economy.
- `TECHNICAL_ARCHITECTURE.md` does not set a UI design resolution; `MOBILE_CONTROLS.md` §2 uses
  1280×720 landscape (stretch mode `canvas_items`, aspect `expand`).
- Keep the first implementation simple: no multiplayer, progression, monetization, ECS framework,
  general-purpose behaviour tree or third-party addon.
