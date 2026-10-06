# AI_HANDOFF

> Every AI updates this file at the end of every task. Newest information at the top of each
> section. Keep it short and factual.

## Current build

Playable **Phase 1 greybox** in `game/`, pinned to **Godot 4.6.3 stable, official 7d41c59c4**.
Breakpoint Valley: 108×108 logical cells, 64×32 isometric TileMapLayer, blocked rocky ridge,
Central Pass/East Cut and visual-only ore/base landmarks. Seven labelled placeholder units
exercise selection, group movement and differing speeds. This test roster is deliberately more
than Mission Zero's eventual single-Rig opening; no combat, construction, economy, fog or AI.

Run/setup/test instructions and phone checklist: `game/README.md`. Headless and rendered desktop
runs: **116 passed, 0 failed**; intentional failure diagnostic returned exit code **1**.
The Game Director played the previous build on iPhone Safari. The revised controls/movement
need a fresh phone retest; notch handling and sustained performance remain unmeasured.
Single-threaded Godot 4.6.3 Web export published at
**https://tahahabib349-ai.github.io/RDR2-Game-Dev/** via an artifact-based GitHub Actions deployment triggered from `gh-pages` (no build files
committed by the updated publish helper).
Browser startup/layout/page-gesture blocking and real tap/pinch/held-box touch dispatch checked
in mobile-sized Chromium without special headers; page scale stayed 1. Revised physical iPhone Safari verification remains pending. No Android APK is included in the
final PR; native iOS export/performance validation still requires Mac/signing.

## Phase

**Phase 1 — Battlefield and movement** implemented; awaiting physical-phone acceptance.
The Game Director explicitly requested Phase 1 implementation on 2026-10-06. See `ROADMAP.md`.

## Completed work

- 2026-10-06 · 🔨 Codex · Applied the first iPhone playtest fixes only: one-finger 0.4 s
  hold-to-box with 20 px slop and a filling ring; hold without drag cancels; a second finger
  cancels selection and becomes pinch/scroll only. Desktop supports Shift+drag and hold+drag.
  Minimum zoom is 1.0; deselect uses the font-supported ASCII X glyph.
- 2026-10-06 · 🔨 Codex · Replaced soft separation with swept movement/interpolation checks,
  conservative body/shadow radii, local sidesteps, idle yielding and return-to-rest settling.
  Group slots enforce combined radii. Idle-lane minimum spacing ratio 1.00179; mixed-group
  minimum 1.00008; all arrive. Actual mission groups keep full spacing through the passes.
- 2026-10-06 · 🔨 Codex · Applied the approved 108×108 map, exact landmark/ridge/pass coordinates,
  ridge half-width 2.0, relocated spawns around (18,87), and revised unit speeds. Both passes
  closed means no base-to-base route. Updated old coordinate tests; 11,018 walkable cells
  remain viewable at default zoom on standard/wide viewports. Full headless/rendered suites:
  116 passed, 0 failed. Single-threaded Web export republished via an artifact upload; no build files committed.
  Publish helper/workflow updated to preserve the same URL without committing generated files.

- 2026-10-06 · 🔨 Codex · Fixed Claude's camera review finding: clamp against projected map
  bounds plus a tunable 48 design-pixel dark border. Exhaustive default-zoom tests bring all
  4,945 walkable cells on screen on standard/wide viewports, including four corners; no missed
  cells. Updated the obsolete viewport-inside-diamond tests to enforce bounded overscroll instead.
  Headless and rendered desktop full suites: 98 passed, 0 failed. Corner screenshots inspected.
- 2026-10-06 · 🔨 Codex · Replaced ripgrep with standard grep -E; intentional failure exits 1.
  Built the exact 4.6.3 single-threaded Web export and published it to GitHub Pages. Added
  repeatable template setup/export/publish helpers and an engine-generated Web preset. The
  stock-derived HTML shell blocks page zoom gestures, fills the landscape viewport, reserves
  CSS safe-area insets and shows a portrait rotation prompt. Chromium startup/layout checks pass
  without cross-origin isolation. iPhone Safari must still be checked by the Game Director.
  No gameplay/map-layout scope changes; design-owned ridge/third-route findings remain open.

- 2026-10-06 · 🟣 Claude · Reviewed Phase 1 against `MOBILE_CONTROLS.md` §14/§15 and the
  blueprint. Re-ran setup + suite: 88 passed, 0 failed, exit 0. Every Phase 1 control is present;
  no later-phase scope. Findings logged under Known issues (camera edge visibility, a third route
  along the west edge, undocumented ridge extension, `rg` dependency in `tools/test.sh`).
- 2026-10-06 · 🔨 Codex · Implemented Phase 1 only: Godot project/scenes, Resource-based
  gesture/map/unit data, logical-to-isometric conversion, greybox terrain, shared AStarGrid2D,
  distinct group slots, local spacing/re-path recovery, fixed 20 Hz movement and visual interpolation.
  One raw input adapter produces selection/camera/command intents for touch and desktop.
  Includes tap/double-tap, two-finger one-finger held box vs quick pan, two-finger pinch/scroll, UI-origin/cancel protection,
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
| Phase 1 battlefield/movement/controls | 🔨 Codex | ✅ Implemented; 116 checks pass; phone acceptance pending |
| Phase 1 phone playtest | Game Director, with 🔨 Codex preparing deployment/fixes | Web build live on GitHub Pages; First iPhone playtest done; revised build retest pending |
| Phase 0 blueprint docs: `docs/GAME_DESIGN.md`, `docs/MISSION_ZERO.md`, `docs/TECHNICAL_ARCHITECTURE.md`, `docs/UNIT_SYSTEM.md`, `docs/BUILDING_SYSTEM.md`, `docs/ECONOMY.md` | 🟢 ChatGPT | ✅ Complete; awaiting Game Director review |
| `docs/MOBILE_CONTROLS.md`: touch selection, move/attack, camera, pinch zoom, building placement, group control | 🟣 Claude | ✅ Draft v4 complete; Phase 1 subset implemented per Game Director request |
| `docs/ART_DIRECTION.md` | Unassigned (proposed: 🟢 ChatGPT, with 🟣 Claude for UI visuals) | Not started |

## Next recommended task

The Game Director uses an **iPhone**. Open the Pages link above in Safari, rotate to landscape,
and optionally Add to Home Screen. Use the checklist in `game/README.md`: every edge/corner,
one-finger held box vs quick pan, two-finger pinch/scroll, quick moves, pan-with-selection, crowding and notches. Confirm the
Safari page stays still during two-finger gestures. Fix findings before combat. Native
 iOS/performance testing requires a Mac/signing later.

The ridge/route/map-speed decisions below are implemented as approved. 🟢 ChatGPT can review
Claude's covering design decision when available; do not revert it pending that review.

Phase 2 is not started or authorized by this task.

## Architectural decisions

- 2026-10-06 · Controls: **one finger held 0.4 s then dragged selects a box**, with 20 px
  slop and a filling ring; lift without drag changes nothing. Quick one-finger drag scrolls;
  **two fingers only pinch/scroll** and never select. Landscape only; minimum zoom 1.0.
- 1280×720 design resolution; orders fire on finger up; gesture thresholds in `gestures.tres`.
  One input adapter produces tap/double-tap/pan/box/pinch intents for touch and mouse.
- Engine: **Godot 4.6.3 stable official 7d41c59c4**, GDScript; full pin in `game/GODOT_VERSION`.
- Targets: Android and iOS; desktop builds for development/testing.
- Presentation: modern 2D isometric / 2.5D visual treatment on a 2D simulation; gameplay uses logical orthogonal square-grid coordinates.
- Mission Zero map baseline: **108 x 108 cells** (raised from 72 on 2026-10-06, see below).
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

- Camera edge visibility remains resolved on the enlarged map: all 11,018 passable cells
  viewable at default zoom, including edges/corners, with bounded dark overscroll.
- Claude's west-edge third-route and undocumented ridge-extension findings are **resolved**
  by the approved MISSION_ZERO revision. Exact ridge/pass coordinates applied; sealed-pass test passes.
- First iPhone playtest findings (old box gesture, unit overlap, minimum zoom and missing ✕)
  are fixed and automatically/browser checked. The Game Director must retest the revised build.
- Claude's ripgrep dependency finding is **resolved**: test.sh uses standard grep -E.
- Blueprint balance numbers remain tunable starting values; only movement is implemented/tested.
- New hold-to-box gesture and idle yielding/settling need physical-phone feel testing.
- Headless tests exercise viewport touch events and safe-area math; they do not prove real-device
  rotation/notch handling, sustained FPS, thermals or 100-unit performance.
- Web build runs in mobile-sized Chromium; physical iPhone Safari, notch handling and sustained
  performance are untested. Browser bars depend on Safari; Add to Home Screen gives more space.
  Native iOS remains unprepared and requires macOS/signing.
- Placeholder unit labels/art and revised local spacing need playtesting; no polished audio,
  haptics, tablet physical sizing or later-phase control groups/combat shortcuts are included.

## Recently modified files

- 2026-10-06 · 🔨 Codex: gesture recognizer/config/HUD/session; movement and group destination
  allocation; mission/unit Resources; headless regression runner; artifact-based publish helper and `.github/workflows/publish-web.yml`;
  `game/README.md`, `AI_HANDOFF.md`.

- 2026-10-06 · 🔨 Codex: camera/projection/gesture data and coverage tests; portable test wrapper;
  Web export preset/setup/export/publish helpers, original icon and `game/web/shell.html`; `game/README.md`, `AI_HANDOFF.md` and the
  camera-margin wording in `docs/MOBILE_CONTROLS.md` §8.

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

## First iPhone playtest: findings and decisions (2026-10-06)

Game Director played the Phase 1 web build (PR #2) on iPhone Safari. 🟣 Claude measured each point
in the same build with headless Godot. **Historical findings: the fixes below are now implemented;
retest the republished build.**

1. **Decision: box select becomes one-finger press-and-hold (0.4 s), then drag.** Two fingers now
   only zoom and scroll. Replaces the two-finger box. `docs/MOBILE_CONTROLS.md` v4 §4. Owner to
   build: 🔨 Codex.
2. **Decision: units must never overlap or pass through each other** (MOBILE_CONTROLS v4 §6).
   Measured: a Jackal ordered past three idle Rangers drove straight through them (0.05 cells
   clearance, needs 0.57), and the Rangers never moved, because idle units skip separation
   (`unit_movement.gd` `tick` returns early when the route is empty). In group moves, units
   overlapped by up to 98% of their spacing. Spacing radii are also smaller than the drawn
   art (Ranger 0.44 vs 0.50 cells), so units look stacked even when "separated". Owner: 🔨 Codex.
3. **Map feels small.** Measured: units cross base to base (71.5 cells) in 12 s (Jackal) to
   22 s (Rangers), 31 s (Pioneer Rig). Fully zoomed out (0.75), one screen shows 31% of the map.
   - Zoom-out cap → 1.0 (17% of the map per screen): MOBILE_CONTROLS v4 §8; owner 🔨 Codex
     (data change in `gestures.tres`).
   - Map size and unit speeds: 🟢 ChatGPT to decide. 🟣 Claude recommends a base-to-base trip of
     roughly 45–60 s for mainline units, via a larger map (~96–112 cells), slower speeds, or both.
4. Smaller UI items for 🔨 Codex: the ✕ deselect button renders as an empty box in the web build
   (the font lacks "✕"; use a drawn icon or a glyph the font has); HUD text is about 10 pt on an
   iPhone (Phase 7 polish, not blocking).
5. Observation, not a bug: group members travel at their own speed, so a Jackal reaches a far
   target ~10 s before the Rangers. Classic-RTS normal; revisit only if playtests want formations.

### Map size, speeds and routes: decided 2026-10-06 (🟣 Claude, covering 🟢 ChatGPT at the Game Director's request)

ChatGPT was unavailable, so the Game Director asked Claude to make this design call. 🟢 ChatGPT should
review it when back. It was prototyped in the engine before being written down; numbers are measured.
- **Map 72 → 108 cells.** All coordinates ×1.5, except that each near ore field stays ~10 cells
  from its base so the opening economy keeps its pace. Exact coordinates: `MISSION_ZERO.md`.
- **All unit speeds ×0.7** (`UNIT_SYSTEM.md`, `ECONOMY.md`). Base to base via Central Pass
  (~106 cells): Jackal ~25 s, Vanguard ~41 s, Ranger ~46 s, Lancer ~53 s, Breaker ~56 s.
  Estimated Gatherer income unchanged at ~1,900 credits/min.
- **Third route closed:** the ridge now runs from the west edge to the south edge. With both
  passes blocked, no route exists (verified).
- **Ridge extension confirmed** and written into MISSION_ZERO. **East Cut moved** to (84.5, 79):
  a 21% detour (~128 cells) instead of 9%.
- The first enemy wave now reaches the player ~5:15–5:25 instead of ~4:50; recheck in Phase 5/6.
- 🔨 Codex: apply via `mission_zero.tres` and the unit `.tres` files. The current suite then fails
  5 tests that hard-code 72 or old coordinates; **applied and updated by Codex in this task**.
