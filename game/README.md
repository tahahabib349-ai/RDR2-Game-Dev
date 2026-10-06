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

Validated: **98 checks passed, 0 failed** in headless Godot and the rendered desktop runner.
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
| Box select | Two fingers still for 0.2 s, then resize with both fingers | Shift + left drag |
| Zoom | Move two fingers immediately; zoom about their midpoint | Mouse wheel |
| Deselect | ✕ | ✕ or Esc |
| Select all combat units | All Army (excludes Rig/Gatherer) | All Army |
| Move selected units | Tap ground; green pulse and temporary order lines | Left click ground |

+ / − buttons also adjust zoom. The box previews in screen space, freezes when the first finger
lifts, and commits after both lift. An empty box preserves the current selection. Mode stays
locked through the entire gesture; remaining fingers cannot accidentally move units. Third
fingers, OS cancellation and focus loss cancel the gesture. UI-origin touches cannot pan or issue
orders, even if dragged onto the map. HUD touch taps are routed explicitly by the same input
adapter; mouse/touch emulation is disabled to avoid duplicate commands.

S / A combat commands belong to Phase 2. Control groups 1–4 belong to Phase 6. Their keyboard
shortcuts are intentionally inactive until the corresponding touch features exist.

## Data and system boundaries

- `data/gestures.tres`: gesture thresholds, tap radius, inertia, camera zoom limits, marker time,
  button sizes, spacing and camera border margin. Sizes use viewport/design pixels at a 720 px design height.
- `data/missions/mission_zero.tres`: 72×72 map, 64×32 visual cells, ridge/passes, ore landmarks,
  test spawns and movement tuning. Ore is a visual landmark only. Central Pass is a 7-cell
  opening; East Cut is a 6-cell opening. Coordinates are tunable greybox choices.
- `data/units/*.tres`: unit IDs, movement speed/spacing, army membership and placeholder colors.
- `scripts/core`: logical map, sole isometric conversion service, terrain view and mission wiring.
- `scripts/input`: timestamp-driven recognizer, raw touch/mouse adapter, camera.
- `scripts/selection`: screen-space picking/selection; no movement decisions.
- `scripts/commands`: validated move requests and distinct reachable group destinations.
- `scripts/movement`: shared AStarGrid2D, no corner cutting, continuous waypoint following,
  lightweight local spacing and stuck/invalid-path recovery.

Simulation runs at a fixed 20 Hz and visuals interpolate previous/current logical positions.
Terrain and units share the projection; terrain art does not determine walkability. Blocked
orders resolve to a passable destination; unreachable orders use the reachable partial path.
Paths are requested on orders or invalid/stuck routes, rather than every tick. The camera clamps
against the projected map bounds with a tunable **48 design-pixel dark border**. This allows
all walkable cells, including every edge/corner, to come on screen. Both 1280×720 and 1600×720
coverage tests view **all 4,945 passable cells at the default 1.5 zoom**, with zero missed cells.
Overscroll remains bounded; the camera does not keep the whole viewport inside the diamond.

Landscape in both directions, 1280×720 design resolution, `canvas_items` / `expand` and safe-area
HUD insets are configured. UI sizes are at least 80×80 design pixels. Tablet physical sizing,
polished audio/haptics and richer control accessibility remain later-phase work.

## Phone playtest (not yet performed)

Play in iPhone Safari: **https://tahahabib349-ai.github.io/RDR2-Game-Dev/**
Rotate to landscape. For more screen space, use Safari's Share → Add to Home Screen, then
launch the saved icon. Safari's browser bars may still occupy space when played in a normal tab;
the canvas fills the available viewport. Portrait shows a rotation prompt. The HTML shell uses
safe-area insets for the notch/home strip and disables browser pinch/double-tap zoom without
stopping touch events reaching the game. This is a single-threaded WebGL 2 build, with no
SharedArrayBuffer, cross-origin isolation headers, plugins or service-worker workaround.

To rebuild and republish from the repository root on Linux x86_64 (Python 3.11+, Git and GitHub
push access; run `setup.sh` first on a fresh machine):

```bash
game/tools/setup.sh
game/tools/export_web.sh
game/tools/test.sh
game/tools/publish_web.sh
```

The export helper verifies the exact engine and installs the official 4.6.3 single-threaded
Web templates, checking the pinned SHA-512 when downloading the archive. Local output is
`game/export/web/` (ignored). The publish helper replaces the generated site on the dedicated
`gh-pages` branch using a temporary deployment directory, then pushes it. It never merges source
into main. Commit source changes before publishing so `source-commit.txt` identifies the build.
GitHub repository Settings → Pages must use **Deploy from a branch**, **gh-pages**, **/(root)**
(already configured for this repository). Wait for the Pages deployment to finish, then reload
Safari; a source PR alone does not republish. For local preview, serve `game/export/web/` with
`python3 -m http.server 8000 --directory game/export/web` and visit localhost:8000.

Validated in Chromium with an 844×390 mobile viewport: actual Web startup with cross-origin
isolation disabled, full viewport canvas, portrait prompt and page-gesture cancellation.
Physical iPhone Safari touch feel, notch handling and performance remain **untested**; native
iOS performance testing will need a Mac/signing later. No Android APK is included in this PR.
The test wrapper uses standard `grep -E`, without a ripgrep dependency.

On the phone, try:

1. Tap a Ranger from slightly beside its artwork, then double tap it. Only visible Rangers
   should join the selection.
2. Rest two fingers for a beat, stretch the box, then lift them one after the other. Check
   that the preview is clear and the final selection matches it.
3. Spread two fingers immediately to zoom, then pause. It must stay zoom, with no box or order.
4. Give 20 quick ground taps to a selected army. Look for one green marker per order and units
   spreading into distinct destinations.
5. Pan and zoom while units are selected. No move order should fire. Drag to each map edge and all four corners; every cell should be visible with a thin dark border.
6. Try All Army and ✕: the Rig/Gatherer stay out of the army selection; ✕ clears selection.
7. Send a mixed group through Central Pass and East Cut. Check for obvious jams or clipping.
8. Drag from a HUD button onto the map and back. It must not move units or activate the button.
9. Rotate between both landscape directions on a notched phone. Portrait should show the rotation prompt;
   buttons must stay clear of the notch/home strip. Try one-handed and two-handed use.

The first priority is whether the 0.2-second pause reliably distinguishes box selection from
pinching. Do not declare Phase 1's phone acceptance complete until this has been checked.
