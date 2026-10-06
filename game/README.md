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

A signed **debug Android APK** is included in `../builds/android/`, with download/install
instructions and SHA-256. It supports ARM64 Android 7+ and uses the stock Godot 4.6.3 template;
it is not an iPhone or store-release build. The signature, 16 KB alignment, manifest, launcher,
landscape orientation and embedded resources were checked. Physical-phone installation,
gesture feel, safe-area behaviour and performance are still untested. iOS exports require macOS
and signing and remain outside this task.

To reproduce the APK from the repository root on Linux x86_64 (Java 17+ and Python 3.11+):

```bash
game/tools/setup.sh
game/tools/export_android.sh
```

The Android helper reuses/prepares command-line tools 19.0, build-tools 36.0.0, platform 36,
platform-tools and the exact Godot templates. Google bootstrap artifacts and Godot templates
are checksum-verified; SDK packages are downloaded by Google's SDK manager using its normal
verification. The Godot 4.6.3 template targets API 36, so build-tools 36 are used even though the
older 4.6 documentation lists 35. No Gradle, NDK or third-party plugins are needed. Local
Android/Java editor paths and the debug keystore stay outside the repository. The supplied
cloud Java 21 runtime was used successfully. The export-only preset has `runnable=false` to
avoid starting ADB/device polling in cloud tasks; this does not prevent installing/running the APK.

The resulting APK is in `game/export/`. The intentionally committed review APK under
`builds/android/` is copied separately; exports do not overwrite it. `tools/test.sh` now uses
standard `grep -E`, without a ripgrep dependency.

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
9. Rotate between both landscape directions on a notched phone. Portrait should stay disabled;
   buttons must stay clear of the notch/home strip. Try one-handed and two-handed use.

The first priority is whether the 0.2-second pause reliably distinguishes box selection from
pinching. Do not declare Phase 1's phone acceptance complete until this has been checked.
