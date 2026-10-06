# Phase 1 — Breakpoint Valley greybox

Owner: 🔨 Codex. Engine: **Godot 4.6.3 stable**, official build `7d41c59c4`.
The full version is pinned in `GODOT_VERSION`; setup/tests reject a different version.
No plugins, addons, combat, construction, economy, enemy AI or fog are included.

This is a movement/control playground, not the complete Mission Zero opening. It deliberately
spawns a Pioneer Rig, three Rangers, a Jackal, a Vanguard Tank and a Gatherer so different unit
sizes/speeds and army selection can be tested before production exists. Everything is labelled
placeholder art. The enemy-base location is terrain only, with no enemy structures or units.

## Setup, tests and running

Each cloud task already has an isolated checkout. Use it; do not create a worktree unless asked.
From the repository root on Linux x86_64:

```bash
game/tools/setup.sh
source game/tools/env.sh
"$GODOT_BIN" --path game
```

`setup.sh` uses a matching existing engine or downloads the exact official release and verifies
its pinned SHA-512 checksum. Tools and writable Godot cache/data/config directories are outside
the checkout, under its parent directory's `.tools/` and `.runtime/`. On another desktop OS,
install the official **4.6.3 standard (GDScript)** engine and open `game/project.godot`; the setup
script also accepts an exact matching engine via `GODOT_BIN`.

Headless checks, after setup/import:

```bash
game/tools/test.sh
```

Or use the engine directly:

```bash
source game/tools/env.sh
"$GODOT_BIN" --headless --path game --import
"$GODOT_BIN" --headless --path game --script res://tests/test_runner.gd
```

The first-party runner counts failures, has a watchdog, and exits nonzero on failure. The shell
wrapper adds a timeout and rejects script errors or missing result summaries even if Godot exits
zero. `game/tools/test.sh --force-failure` intentionally returns 1 to verify this failure path;
it is a runner diagnostic, not a normal suite failure.

Validated: **116 checks passed, 0 failed** in headless Godot and the rendered desktop runner.
Checks cover gesture timing/cancellation, native viewport touch dispatch, UI-origin protection,
selection, TileMap/projection alignment, AStar paths and blocked/unreachable destinations,
dynamic route invalidation, mixed-unit group arrivals, no per-tick path rebuilding, 20 Hz
simulation, zoom anchoring, camera limits, wide aspect ratio, safe-area conversion and HUD sizes.
The startup scene also ran and screenshots were inspected with software OpenGL. This is not a
phone performance or physical gesture-feel measurement.

## Controls

| Action | Touch | Desktop |
|---|---|---|
| Select one unit | Tap, with a minimum 40 design-pixel picking radius | Left click |
| Select visible units of that type | Double tap within 0.30 s / 40 px | Double click |
| Pan | One-finger drag past 20 px; brief inertia | Left drag |
| Box select | Hold one finger still for 0.4 s, then drag (20 px hold slop) | Shift + left drag, or hold left button 0.4 s then drag |
| Zoom / two-finger scroll | Pinch or drag two fingers; never selects | Mouse wheel / left drag |
| Deselect | X (font-safe replacement for ✕) | X or Esc |
| Select all combat units | All Army (excludes Rig/Gatherer) | All Army |
| Move selected units | Tap ground; green pulse and temporary order lines | Left click ground |

+ / − buttons also adjust zoom, with a **1.0 minimum zoom**. A ring fills beneath the held
finger; once complete, dragging stretches a box from the hold point. Lift to select; an empty
box or a hold lifted without dragging leaves selection unchanged. Moving more than 20 px before
completion pans instead. A second finger cancels the pending tap/box and becomes camera-only
pinch/scroll; after either finger lifts, the remaining finger cannot issue an order or select.
Third fingers, OS cancellation and focus loss cancel the sequence. UI-origin touches cannot
pan or issue orders, even if dragged onto the map. HUD touch taps use the same input adapter;
mouse/touch emulation is disabled to avoid duplicate commands.

S / A combat commands belong to Phase 2. Control groups 1–4 belong to Phase 6. Their keyboard
shortcuts are intentionally inactive until the corresponding touch features exist.

## Data and system boundaries

- `data/gestures.tres`: gesture thresholds, tap radius, inertia, camera zoom limits, marker time,
  button sizes, spacing and camera border margin. Sizes use viewport/design pixels at a 720 px design height.
- `data/missions/mission_zero.tres`: 108×108 map, 64×32 visual cells, ridge/passes, ore landmarks,
  test spawns and movement tuning. Ore is a visual landmark only. Central Pass is a 7-cell
  opening; East Cut is a 6-cell opening. The ridge follows the revised MISSION_ZERO coordinates, half-width 2.0, from the west edge
  to the south edge. Central Pass (51,54), East Cut (84.5,79); closing both eliminates all base-to-base routes.
- `data/units/*.tres`: unit IDs, movement speed, on-screen footprint radius, army membership and placeholder colors.
- `scripts/core`: logical map, sole isometric conversion service, terrain view and mission wiring.
- `scripts/input`: timestamp-driven recognizer, raw touch/mouse adapter, camera.
- `scripts/selection`: screen-space picking/selection; no movement decisions.
- `scripts/commands`: validated move requests and distinct reachable group destinations.
- `scripts/movement`: shared AStarGrid2D, no corner cutting, continuous waypoint following,
  swept unit spacing, idle yielding/settling and stuck/invalid-path recovery.

Simulation runs at a fixed 20 Hz and visuals interpolate previous/current logical positions,
then trail them by `visual_smoothing_seconds` (0.08 s) so small direction changes read as
curves. Unit speeds match the revised UNIT_SYSTEM table (about ×0.7): Ranger 2.3, Jackal 4.2,
Vanguard 2.6, Gatherer 2.2 and Rig 1.6 cells/s.

**Spacing is measured on screen** (`footprint_radius`, design px at zoom 1): Ranger 12,
Jackal 18, Vanguard/Gatherer 20, Rig 22, about 1.2–1.3× the drawn body. (The isometric view
squashes the vertical axis, so the earlier circular spacing on the logical grid had to be ~3×
too wide sideways to avoid overlap vertically.) Swept checks cover movement and render
interpolation, so units cannot tunnel through each other.

**Smooth local movement** (Claude, after the second iPhone playtest reported vibrating units):
units aim at the farthest route point in a clear straight line (so groups spread across a
pass instead of funnelling onto one line of cell centres); a blocked unit keeps sidestepping to
the same side for `avoid_side_hold` seconds instead of flipping left/right; turns blend over
ticks; behind slower traffic a unit slows or overtakes. Idle friends step aside, wait until no
mover is within `settle_clear_px`, then walk back politely (a walk-back never pushes others and
gives up if blocked) — only if they were pushed more than `settle_min_px`. A unit blocked near
its goal while another unit stands on that spot stops there instead of shoving. Group slots
avoid units already standing nearby and are assigned closest-first. All tunables live in
`mission_zero.tres`.

Measured (headless probes, 21 mixed units): vibration flips (alternating >20° turns on
consecutive ticks) 926 → ~80 for a crowd converging on one point, 1,040 → ~40 for two groups
swapping sides, 1,841 → ~60 for a 19-unit army crossing the map; every unit finishes moving in
every scenario (previously up to 19 of 21 stayed jammed). Army of 19 through Central Pass:
Jackals 23–29 s, Vanguards 35–44 s, Rangers 37–46 s (unobstructed ideal 22–25 / 35–39 /
39–48 s); the pass takes 2–4 s to cross. The suite locks this in (crowd vibration, no overlap,
no jam, Jackal-before-Rangers, gathered groups not scattered).
Terrain and units share the projection; terrain art does not determine walkability. Blocked
orders resolve to a passable destination; unreachable orders use the reachable partial path.
Paths are requested on orders or invalid/stuck routes, rather than every tick. The camera clamps
against the projected map bounds with a tunable **48 design-pixel dark border**. This allows
all walkable cells, including every edge/corner, to come on screen. Both 1280×720 and 1600×720
coverage tests view **all 11,018 passable cells at the default 1.5 zoom**, with zero missed cells.
Overscroll remains bounded; the camera does not keep the whole viewport inside the diamond.

Landscape in both directions, 1280×720 design resolution, `canvas_items` / `expand` and safe-area
HUD insets are configured. UI sizes are at least 80×80 design pixels. Tablet physical sizing,
polished audio/haptics and richer control accessibility remain later-phase work.

## iPhone retest after the first playtest fixes

Play in iPhone Safari: **https://tahahabib349-ai.github.io/RDR2-Game-Dev/**
Rotate to landscape. For more screen space, use Safari's Share → Add to Home Screen, then
launch the saved icon. Safari's browser bars may still occupy space when played in a normal tab;
the canvas fills the available viewport. Portrait shows a rotation prompt. The HTML shell uses
safe-area insets for the notch/home strip and disables browser pinch/double-tap zoom without
stopping touch events reaching the game. This is a single-threaded WebGL 2 build, with no
SharedArrayBuffer, cross-origin isolation headers, plugins or service-worker workaround.

**Publishing is automatic.** Every push to `main` that touches `game/` runs
`.github/workflows/publish-web.yml`: it installs pinned Godot, runs the full test suite, exports
the single-threaded Web build and deploys it to the same Pages URL (a failing test stops the
deploy). Watch **Publish Phase 1 Web** under GitHub Actions and reload Safari once it is green.
You can also re-run it by hand from the Actions tab (`workflow_dispatch`). Generated builds are
**never committed**; the `gh-pages` branch is no longer used for publishing (it only holds a
README), so GitHub's branch-based Pages build can no longer bring back an old version.

To build locally on Linux x86_64 (Python 3.11+):

```bash
game/tools/setup.sh
game/tools/export_web.sh
```

The export helper verifies the exact engine and installs the official 4.6.3 single-threaded
Web templates, checking the pinned SHA-512 when downloading the archive. Local output is
`game/export/web/` (ignored by git).
For local preview, serve `game/export/web/` with
`python3 -m http.server 8000 --directory game/export/web` and visit localhost:8000.

Validated in Chromium with an 844×390 mobile viewport: actual Web startup with cross-origin
isolation disabled, full viewport canvas, portrait prompt and page-gesture cancellation.
The Game Director tested the previous Web build on iPhone Safari; these revised controls and
movement still need an iPhone retest. Notch handling and sustained performance remain unmeasured; native
iOS performance testing will need a Mac/signing later. No Android APK is included in this PR.
The test wrapper uses standard `grep -E`, without a ripgrep dependency.

On the phone, try:

1. Tap a Ranger from slightly beside its artwork, then double tap it. Only visible Rangers
   should join the selection.
2. Hold one finger for 0.4 s, watch the ring fill, drag a box and lift. Then hold and lift
   without dragging: selection must stay unchanged. A quick drag must pan instead.
3. Rest two fingers, then pinch and drag together. Only the camera may change; no box or order.
   Add a second finger during a one-finger box to confirm the box cancels.
4. Give 20 quick ground taps to a selected army. Look for one green marker per order and units
   spreading into distinct destinations.
5. Pan and zoom while units are selected. No move order should fire. Drag to each map edge and all four corners; every cell should be visible with a thin dark border.
6. Try All Army and X: the Rig/Gatherer stay out of the army selection; X clears selection.
7. Drive a Jackal through idle Rangers: they should step aside, then settle without overlap.
   Send All Army through Central Pass and East Cut; check that bodies never stack or pass through.
8. Drag from a HUD button onto the map and back. It must not move units or activate the button.
9. Rotate between both landscape directions on a notched phone. Portrait should show the rotation prompt;
   buttons must stay clear of the notch/home strip. Try one-handed and two-handed use.

The first priorities are whether hold-to-box feels clear and whether units pass idle traffic
smoothly without overlap. Do not declare Phase 1's phone acceptance complete until this has been checked.
