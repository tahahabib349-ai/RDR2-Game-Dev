# MOBILE_CONTROLS

> Owner: 🟣 Claude (UI/UX). Status: **Draft v4, after the first iPhone playtest.** v4 (Game Director playtest, 2026-10-06): box select is now press-and-hold with one finger, two fingers only zoom/scroll, units must never overlap, and zoom-out is capped. v3: two-finger box select (replaced in v4). v2 aligns names and rules with 🟢 ChatGPT's Phase 0 blueprint (2D isometric, Pioneer Rig, Field Command, etc.).
> Covers how the player commands the game by touch: selection, move/attack, camera, zoom,
> building placement, production, and army control. It describes *what the player does and
> sees*, not how the code is structured (that is 🟢 ChatGPT's `TECHNICAL_ARCHITECTURE.md` and
> 🔨 Codex's implementation).

---

## 1. Goals and principles

1. **Real RTS control, no autopilot.** The player picks units and gives orders. Nothing in this
   doc automates decisions the player should make.
2. **One finger acts, two fingers only move the camera.** A one-finger tap gives orders, a
   one-finger drag scrolls the map, and a one-finger press-and-hold then drag draws a selection
   box. Two fingers only pinch-zoom and scroll, so they can never select or order anything (§4).
3. **Orders happen when the finger lifts, never when it lands.** That way a finger that starts a
   pan or pinch never fires an accidental move order.
4. **Every order gets visible feedback within one frame,** such as a marker, a flash, or a ring.
   If the player can't tell an order was received, they will tap again.
5. **No hidden-only controls.** Every gesture beyond plain tap and drag also has an on-screen
   button, so nothing depends on discovering a gesture.
6. **Forgiving targets.** Units are small on a phone, so tap areas are bigger than the art, and
   the game picks the most likely intended target (§5).
7. **Thumbs and fingers cover the screen.** Important information never sits where a hand
   rests; controls hug the edges and keep the centre of the battlefield clear.

## 2. Assumptions (confirm or change)

| Assumption | Why it matters | Default used here |
|---|---|---|
| Orientation | Layout | **Landscape only** (both landscape directions allowed). ✅ Confirmed by Game Director 2026-10-06 |
| Smallest supported screen | Button and tap sizes | ~5.5" phone, 16:9 up to 20:9 aspect. Layout adapts automatically; this only sets the smallest screen we check for cramping. ✅ Default accepted |
| Design resolution | All pixel sizes in this doc | **1280 × 720** (scaled to the real screen, extra width revealed, never cropped) |
| 2D or 3D, camera angle | How taps find units, how zoom works | ✅ **2D isometric** with a fixed camera angle (`TECHNICAL_ARCHITECTURE.md`); see §12 |

All sizes below are in **design pixels at 720 px screen height** and scale with the screen.

**Tablets and large screens:** buttons keep roughly the same *physical* size (finger-sized), and
the extra screen space shows more battlefield, rather than everything simply getting bigger.
Codex can do this by raising the design resolution on screens larger than about 7".

## 3. Screen layout (landscape)

```
┌──────────────────────────────────────────────────────────────────────┐
│ [≡]  💰 2,450   ⚡ 120/100      (alerts appear here)       [MAP]    │ ← top bar (thin)
│┌────────┐                                              ┌───────────┐│
││minimap │                                              │ BUILD     ││
││(tap/   │                                              │ SIDEBAR   ││
││ drag)  │            BATTLEFIELD                       │ [tabs]    ││
│└────────┘          (kept clear)                        │ ▢ ▢       ││
│                                                        │ ▢ ▢       ││
│                                                        │ ▢ ▢       ││
│┌──────────────────────────────────────┐                │ (scroll)  ││
││ SELECTION PANEL: icons/count  [✕]    │  [⚔ATK-MOVE]   │           ││
││ [1][2][3][4]  control groups [ALL]   │  [■ STOP]      └───────────┘│
│└──────────────────────────────────────┘                             │
└──────────────────────────────────────────────────────────────────────┘
```

- **Top bar** (≤ 48 px tall): menu/pause, credits, power (red and flashing when low), alerts,
  and a button that shows/hides the minimap.
- **Minimap** (top-left, ~200 × 200, can be hidden): tap to jump the camera there, drag to
  scrub. A tap on the minimap is **never** a unit order in Mission Zero (avoids accidents).
- **Build sidebar** (right edge, ~200 px wide, collapsible to a thin tab): production tabs
  (Buildings / Defense / Infantry / Vehicles) and a scrolling grid of large icons.
- **Selection panel** (bottom-left): what's selected (portrait, or icons with counts), the
  Deselect ✕ button, control-group buttons, and Select-All-Army.
- **Command buttons** (just right of the selection panel, only shown when something able to use
  them is selected): Attack-Move, Stop, and context buttons such as Deploy for the Pioneer Rig.
- **Safe area:** everything is inset from notches, rounded corners and the home-indicator
  strip. On wide phones the extra width goes to the battlefield, not to stretched panels.
- UI that blocks the battlefield is minimal: about 20% of the screen with the sidebar open,
  about 8% with it collapsed.

**Sizes:** every button is at least **80 px** in both directions (about 7–9 mm on a 6" phone,
which matches iOS and Android guidance). Primary buttons (sidebar icons, Attack-Move, Stop) are
**96 px**, with at least 12 px between neighbouring buttons.

## 4. Gesture map (battlefield)

| Gesture | Nothing selected | Units selected | A building selected |
|---|---|---|---|
| **Tap own unit** | Select it | Replace selection with it | Select it |
| **Double-tap own unit** | Select all of that type visible on screen | Same | Same |
| **Tap own building** | Select building | Gatherers + Ore Works: **unload there**; otherwise select the building (drops units) | Select that building |
| **Tap empty ground** | Nothing | **Move** there | Production building: **set rally point**; others: nothing |
| **Tap enemy unit/building** | Show its info (name, health) | **Attack** it | Nothing |
| **Tap Flux Ore field** | Show info | Gatherers: **harvest there**; others: move there | Production building: rally there |
| **Tap into unexplored shroud** | Nothing | **Move** there (scouting) | Production building: rally there |
| **One-finger drag** | Pan camera | Pan camera | Pan camera |
| **One finger held still (0.4 s), then drag** | **Box select** from the hold point to the finger | Box select (replaces) | Box select |
| **One finger held still, lifted without dragging** | Nothing (cancels) | Nothing (cancels) | Nothing (cancels) |
| **Two fingers (pinch / drag)** | Zoom and scroll | Zoom and scroll | Zoom and scroll |

**Press-and-hold box select (Game Director playtest decision, 2026-10-06; replaces the v3
two-finger box).** The two-finger box felt messy next to pinch-zoom, so selection moves to one
finger:
1. Put one finger on the battlefield and keep it still. A ring fills under the finger over
   0.4 s, so the player sees box mode coming.
2. When the ring completes, box mode starts: a small pulse confirms it and the map stops
   scrolling for this touch.
3. Drag: the box stretches from where the finger was held to where it is now. Units inside
   light up as a preview.
4. Lift → everything inside is selected. Lift with nothing inside, or without dragging →
   selection unchanged.

**How it is told apart from scrolling:** a finger that *moves* before the ring completes is a
scroll, as always. Only a finger that *stays still* for 0.4 s becomes a box. Two fingers never
select, so zooming can't be mistaken for selecting. The hold time is in the data file, to tune
after playtests.

**Adding to a selection** (for example, "these 3 tanks plus those 2"): a small "+" toggle in
the selection panel. While it is on, taps and boxes add to (or remove from) the selection instead
of replacing it. This is optional, and control groups (§7) cover most of the need. It ships in
Phase 7, not Phase 1.

**Deselecting:** the ✕ button in the selection panel. Tapping empty ground can't deselect,
because with units selected that tap means "move".

### Gesture timings and thresholds (tunable data, not code)

| Value | Default | Meaning |
|---|---|---|
| Tap slop | 20 px | A finger moving less than this still counts as a tap, not a drag |
| Box hold time | 0.4 s | One finger still for this long → box mode; moving sooner → scroll |
| Box hold slop | 20 px | Finger movement allowed during the hold (same as tap slop) |
| Double-tap window | 0.30 s and ≤ 40 px apart | Two taps closer than this make a double-tap |
| Pan inertia | on, decays in ~0.3 s | The map glides briefly after a flick |
| Two-finger cancel | always | If a second finger lands mid-gesture, the pending one-finger tap or box is cancelled and the touch becomes a pinch/scroll |

These must live in a data file so they can be tuned without code changes (see AGENTS.md
"keep game data in data files").

*Note on double-tap:* a single tap selects immediately, and the second tap upgrades it to
"select all of type". We never wait to see whether a second tap is coming, so single taps stay
instant.

## 5. Picking the right target (forgiving taps)

- Every unit and building has a **tap radius of at least 40 px on screen** (80 px wide), no
  matter how small it looks or how far the camera is zoomed out.
- If several things are in range of a tap, choose:
  1. When **selecting**: own units first, then own buildings; closest to the finger wins.
  2. When **commanding** (units selected): enemies first (attack), then own units/buildings
     (move next to them; later, guard/repair), then ground (move).
- Infantry clumps: a tap on a tight group of own infantry selects the one closest to the
  finger. The player can double-tap to grab the whole type, or press-and-hold to draw a box.

## 6. Orders and feedback

| Order | How | Feedback |
|---|---|---|
| Move | Tap ground | Green marker pulses at the spot; units briefly show a line to it; acknowledgement sound |
| Attack | Tap enemy | Red ring flashes on the target; attackers face it |
| **Attack-Move** | Press ⚔ then tap ground | Red marker; units fight anything they meet on the way |
| Stop | Press ■ | Units halt; small "stop" icon over them |
| Deploy Pioneer Rig | Select Pioneer Rig → **Deploy** button | Field Command footprint preview; deploy refused (red flash plus message) if the spot is blocked. Deploying is permanent in Mission Zero, so the Deploy button shows the footprint first and needs one more tap to confirm |
| Harvest | Select Gatherer → tap Flux Ore field (or own Ore Works to unload) | Field / building outline flashes |
| Rally point | Select Infantry Depot / Vehicle Foundry → tap ground | Flag icon plus a dashed line from the building |

**Group moves:** when a group moves, units spread around the tapped point instead of all
fighting for the same spot. Formation rules are 🔨 Codex/🟢 ChatGPT territory; from the
controls side the requirement is only that units arrive *around* the marker, quickly, without
jamming.

**Units never overlap (Game Director playtest, 2026-10-06).** On screen, two units must never
sit on top of or pass through each other:
- Each unit's spacing size matches its drawn size, so a unit's art never covers a neighbour's.
- A moving unit steers around others. A friendly unit standing still in the way **steps aside**
  and then settles, like classic RTS units do, instead of being driven through.
- Groups arrive *around* the marker, each unit on its own spot, as now.
- Brief touching while squeezing past is fine. Visibly stacked or ghosting units is a bug.
How this is done (collision, avoidance, nudging) is 🔨 Codex's choice; this is the rule the
player sees.

**Always visible on the battlefield:**
- A selection ring under every selected unit or building.
- Health bars on selected units, damaged units, and anything currently in combat. They are
  hidden otherwise to cut clutter.
- An order marker for about 1 second after each order.

**Sound and haptics:** a short acknowledgement sound per order. An optional light vibration on
selection and on order confirm (with a setting to turn it off) comes in Phase 7.

## 7. Army control

- **Select All Army** button: selects every combat unit (never Gatherers or the Pioneer Rig).
- **Control groups 1–4** (buttons in the selection panel):
  - **Long-press a group button** → saves the current selection to it (the button flashes and
    shows the count).
  - **Tap** → selects that group.
  - **Double-tap** → selects it and moves the camera to it.
  - Dead units drop out automatically, and an empty group shows as empty.
- **Select-all-of-type** via double-tap (§4).

Four groups is the starting point for Mission Zero (6 combat unit types, one map). We can raise
it after playtesting.

## 8. Camera

| Control | Behaviour |
|---|---|
| One- or two-finger drag | Pan; the map moves with the fingers exactly (1:1), then glides briefly |
| Pinch | Zoom around the point between the fingers |
| Zoom range | Closest: a tank fills about 1/10 of the screen height. Furthest: about one base and its surroundings fit on screen, which is **zoom 1.0** (one screen ≈ 17% of Breakpoint Valley). The Phase 1 build allowed 0.75 (31% of the map on one screen), which made the map feel small; raise the minimum to 1.0. Exact values in data. |
| Minimap tap/drag | Jump/scrub the camera |
| Map edges | Camera stops at the map border with a soft bounce and a small dark presentation margin; every walkable cell, edge and corner can be brought on screen |
| Base button (in menu or double-tap minimap) | Centre on the Field Command |
| Alert tap (Phase 5+) | Tapping "Base under attack!" jumps the camera to the fight |

No edge-scrolling (scrolling when the finger nears the screen edge) during normal play,
because on touch it triggers by accident. The one exception is building placement (§9).

## 9. Building placement

The flow is "build first, place when ready", the classic base-building rhythm:

1. **Tap a building icon** in the sidebar → construction starts. The icon shows a progress
   sweep, and credits are spent over time.
   - Tap it again while building → nothing. To cancel, **long-press** the icon, which opens a
     small Cancel button (75% refund per `ECONOMY.md`). No pause in Mission Zero.
   - The Field Command has **one construction queue**, so only one building is in progress or
     waiting to be placed at a time (`BUILDING_SYSTEM.md`).
2. Finished → the icon shows **READY** and glows.
3. **Tap the READY icon** → placement mode:
   - A ghost of the building appears **in the middle of the screen**, snapped to the grid.
   - The footprint is **green** where the building is allowed and **red** where it isn't
     (blocked, out of build range, on resources). The build-range area is shaded.
   - **Drag the ghost** with one finger to move it. It sits about 80 px *above* the finger so
     the finger never hides it. Dragging near the screen edge scrolls the map.
   - **Dragging anywhere else** pans the camera as usual; pinch still zooms. Press-and-hold box
     select is switched off during placement.
   - **Small ✓ and ✕ buttons** sit just beside the ghost. ✓ places it (greyed out while red),
     ✕ cancels and leaves the building READY in the sidebar.
   - **Keep them quiet** (Game Director: "shouldn't overpower the screen or look annoying"):
     two compact round buttons, 80 px each (the minimum finger size, nothing bigger), solid and
     calm in colour, with no pulsing, bouncing or pop-up text. They follow the ghost to the side
     with the most free space, so they never cover the spot being built on, and they disappear
     the moment the building is placed or cancelled.
4. Placed → the building appears with a short build-up animation, and the sidebar icon returns
   to normal.

**Why ✓/✕ instead of "tap to place":** a single stray tap that drops a Grid Plant in the wrong
spot is the most frustrating mistake on mobile, and it can't be undone. Confirming costs one
extra tap and prevents it.

## 10. Production (infantry and vehicles)

- **Tap a unit icon** → adds one to that building's queue (Infantry Depot or Vehicle Foundry). A small number badge shows how many
  are queued.
- **Tap again** → queues another (cap set in data; 5 items per production building, per `BUILDING_SYSTEM.md`). Credits are taken when queued.
- **Long-press a queued icon** → removes one from the queue (100% refund if not started, 75% if started, per `ECONOMY.md`).
- Units go to the building's **rally point** if one is set, or just outside the door otherwise.
- When a sidebar tab has something ready or idle, its tab shows a small dot, so the player
  notices without opening it.

## 11. Accidental-input protection (summary)

- A touch that **starts on any UI element** never reaches the battlefield, even if it is
  dragged onto the map.
- Orders fire on **finger up**, and only if the touch stayed within the tap slop.
- A **second finger landing cancels** the first finger's pending order (that touch is now a
  pinch or scroll).
- Building placement needs ✓ to confirm, and queue cancel needs a long-press.
- The pause menu pauses the game in single-player, so the player can think and read.

## 12. Notes for 2D isometric (for 🔨 Codex)

The architecture chose a 2D simulation on a square logical grid, drawn isometrically. For controls
that means:
- **Finding what was tapped:** convert the screen point to world space and pick the nearest
  candidate using the rules in §5, with the minimum 40 px *screen-space* tap radius. Tall sprites
  (buildings, tanks) should also be tappable on their drawn body, not only their ground cell.
- **Zoom:** camera zoom only. The camera angle is fixed and there is no rotation. Rotation would
  add a control to manage and make the minimap harder to read.
- **Box select:** the box is drawn in screen space, and a unit is inside it if its on-screen
  position is inside it (not a box on the logical grid).
- **Placement ghost:** snaps to logical grid cells and is drawn as isometric diamonds, so
  green/red cells match what the player sees.
- **Input layer:** turn raw touches into a small set of intents (Tap, DoubleTap, Pan, HoldBox,
  Pinch) in one place. Selection and Commands (`TECHNICAL_ARCHITECTURE.md` "System
  boundaries") consume intents and never read raw touch, so desktop mouse controls (§13) produce
  the same intents.

## 13. Desktop controls (development and testing only)

Developers and the Game Director will test a lot on desktop, so desktop must produce the same
intents:

| Mouse/keyboard | Equivalent touch |
|---|---|
| Left click | Tap |
| Left double-click | Double-tap |
| Left drag | One-finger drag (pan) |
| Shift + left drag, or hold left button 0.4 s then drag | Press-and-hold box select |
| Mouse wheel | Pinch zoom |
| Esc | Deselect / cancel placement |
| S / A then click | Stop / Attack-move |
| 1–4, Ctrl+1–4 | Select / assign control group |

Desktop controls are a testing convenience. They are not a separate design and must never get
features that touch lacks.

## 14. Rollout by roadmap phase

| Phase | Controls delivered |
|---|---|
| **1** Battlefield & movement | Tap select, double-tap select-type, press-and-hold box select, ✕ deselect, Select All Army, tap-to-move with marker, one-finger pan, pinch zoom, map-edge limits, forgiving tap radius, desktop mapping, thresholds in a data file |
| **2** Combat | Tap enemy to attack, Attack-Move, Stop, health bar visibility rules, attack feedback |
| **3** Base construction | Pioneer Rig Deploy, sidebar with build/READY/place flow, ✓/✕ placement, production queues, rally points |
| **4** Economy | Gatherer tap-to-harvest / tap-to-unload, credits/power in the top bar |
| **5** Enemy AI | Alerts and tap-alert-to-jump |
| **6** Mission Zero | Minimap, control groups 1–4, base button |
| **7** Polish | Add-to-selection gesture, haptics, settings (haptics, left-handed mirrored layout, UI scale), tuning from playtests |

## 15. How we'll test it

**Automated (headless Godot, 🔨 Codex):** feed fake touch sequences to the input layer and check
the result. Examples: a 10 px wiggle is a tap and a 30 px move is a pan; one finger held
still for 0.4 s then dragged produces a box select, while moving sooner scrolls; two fingers
never select; a second finger cancels a pending tap; a tap 35 px from a tiny
unit still selects it; a touch starting on a button never moves units.

**By hand on a real phone (Game Director), each phase:**
1. Select one unit, then a group, without looking at instructions. Was it obvious?
2. Give 20 quick move orders. Did any tap get ignored or do the wrong thing?
3. Pan and zoom while units are selected. Did any unit move by accident?
4. Pick out one tank from a crowd. How many tries did it take?
5. (Phase 3) Place 5 buildings fast. Any misplacements or frustration?
6. Play one-handed for a minute and two-handed for a minute. Which felt natural?

## 16. Open questions for the Game Director

1. ~~Landscape only?~~ ✅ Yes, landscape only (Game Director, 2026-10-06).
2. ~~Smallest phone?~~ ✅ Default (~5.5") accepted; layout auto-adjusts.
3. ~~Box select gesture?~~ ✅ One finger scrolls; **press-and-hold one finger, then drag** draws
   the box; two fingers only zoom/scroll (Game Director, after the first iPhone playtest,
   2026-10-06; replaces the earlier two-finger box).
4. ~~Placement confirm?~~ ✅ Yes, ✓/✕ confirm, kept small and unobtrusive (Game Director,
   2026-10-06).
