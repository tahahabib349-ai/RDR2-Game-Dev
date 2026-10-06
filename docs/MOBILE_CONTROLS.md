# MOBILE_CONTROLS

> Owner: 🟣 Claude (UI/UX). Status: **Draft v1, awaiting Game Director approval.**
> Covers how the player commands the game by touch: selection, move/attack, camera, zoom,
> building placement, production, and army control. It describes *what the player does and
> sees*, not how the code is structured (that is 🟢 ChatGPT's `TECHNICAL_ARCHITECTURE.md` and
> 🔨 Codex's implementation).

---

## 1. Goals and principles

1. **Real RTS control, no autopilot.** The player picks units and gives orders. Nothing in this
   doc automates decisions the player should make.
2. **One finger commands, two fingers move the camera.** That is the rule players learn first,
   and nothing breaks it. (One-finger drag also pans; see §4 for why.)
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
| Orientation | Layout | **Landscape only** (both landscape directions allowed) |
| Smallest supported screen | Button and tap sizes | ~5.5" phone, 16:9 up to 20:9 aspect |
| Design resolution | All pixel sizes in this doc | **1280 × 720** (scaled to the real screen, extra width revealed, never cropped) |
| 2D or 3D, camera angle | How taps find units, how zoom works | **Undecided** (🟢 architecture doc). This doc works for both; see §12. |

All sizes below are in **design pixels at 720 px screen height** and scale with the screen.

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
  them is selected): Attack-Move, Stop, and context buttons such as Deploy for the MCV.
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
| **Tap own building** | Select building | Select building (drops units) | Select that building |
| **Tap empty ground** | Nothing | **Move** there | Production building: **set rally point**; others: nothing |
| **Tap enemy unit/building** | Show its info (name, health) | **Attack** it | Nothing |
| **Tap resource field** | Show info | Harvesters: **harvest there**; others: move there | Refinery/factory: rally there |
| **One-finger drag** | Pan camera | Pan camera | Pan camera |
| **Long-press (0.35 s) then drag** | **Box select** | Box select (replaces) | Box select |
| **Long-press, no drag** | Nothing (cancels) | Nothing | Nothing |
| **Two-finger drag** | Pan camera | Pan camera | Pan camera |
| **Pinch** | Zoom | Zoom | Zoom |

**Why one-finger drag pans (and box select needs a long press):** players scroll a map
constantly and box-select far less often. Making the common action the easiest gesture, and
the rarer one a deliberate press-and-hold, is what most successful mobile strategy games
converge on. During the long press a ring fills under the finger, so the player sees box mode
coming. *Alternative to playtest:* a "box" toggle button that turns the next drag into a box
select. We can add it if long-press feels awkward.

**Adding to a selection** (for example, "these 3 tanks plus those 2"): tapping a unit while
holding a second finger anywhere on the battlefield adds or removes it instead of replacing the
selection. This is optional, and control groups (§7) cover most of the need. It ships in
Phase 7, not Phase 1.

**Deselecting:** the ✕ button in the selection panel. Tapping empty ground can't deselect,
because with units selected that tap means "move".

### Gesture timings and thresholds (tunable data, not code)

| Value | Default | Meaning |
|---|---|---|
| Tap slop | 20 px | A finger moving less than this still counts as a tap, not a drag |
| Long-press time | 0.35 s | Hold time before box select starts |
| Double-tap window | 0.30 s and ≤ 40 px apart | Two taps closer than this make a double-tap |
| Pan inertia | on, decays in ~0.3 s | The map glides briefly after a flick |
| Two-finger cancel | always | If a second finger lands mid-gesture, the pending one-finger order is cancelled |

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
  finger. The player can double-tap to grab the whole type, or box select.

## 6. Orders and feedback

| Order | How | Feedback |
|---|---|---|
| Move | Tap ground | Green marker pulses at the spot; units briefly show a line to it; acknowledgement sound |
| Attack | Tap enemy | Red ring flashes on the target; attackers face it |
| **Attack-Move** | Press ⚔ then tap ground | Red marker; units fight anything they meet on the way |
| Stop | Press ■ | Units halt; small "stop" icon over them |
| Deploy MCV | Select MCV → **Deploy** button (or double-tap the selected MCV) | Building footprint preview; deploy refused (red flash plus message) if the spot is blocked |
| Harvest | Select harvester → tap resource field | Field outline flashes |
| Rally point | Select factory/barracks → tap ground | Flag icon plus a dashed line from the building |

**Group moves:** when a group moves, units spread around the tapped point instead of all
fighting for the same spot. Formation rules are 🔨 Codex/🟢 ChatGPT territory; from the
controls side the requirement is only that units arrive *around* the marker, quickly, without
jamming.

**Always visible on the battlefield:**
- A selection ring under every selected unit or building.
- Health bars on selected units, damaged units, and anything currently in combat. They are
  hidden otherwise to cut clutter.
- An order marker for about 1 second after each order.

**Sound and haptics:** a short acknowledgement sound per order. An optional light vibration on
selection and on order confirm (with a setting to turn it off) comes in Phase 7.

## 7. Army control

- **Select All Army** button: selects every combat unit (never harvesters or the MCV).
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
| One- or two-finger drag | Pan; the map moves with the finger exactly (1:1), then glides briefly |
| Pinch | Zoom around the point between the fingers |
| Zoom range | Closest: a tank fills about 1/10 of the screen height. Furthest: about one base and its surroundings fit on screen. Exact values in data. |
| Minimap tap/drag | Jump/scrub the camera |
| Map edges | Camera stops at the map border with a soft bounce, never showing beyond it |
| Base button (in menu or double-tap minimap) | Centre on the Construction HQ |
| Alert tap (Phase 5+) | Tapping "Base under attack!" jumps the camera to the fight |

No edge-scrolling (scrolling when the finger nears the screen edge) during normal play,
because on touch it triggers by accident. The one exception is building placement (§9).

## 9. Building placement

The flow is "build first, place when ready", the classic base-building rhythm:

1. **Tap a building icon** in the sidebar → construction starts. The icon shows a progress
   sweep, and credits are spent over time.
   - Tap it again while building → nothing. To pause or cancel, **long-press** the icon, which
     opens Pause/Cancel buttons (refund rules belong to `ECONOMY.md`).
   - Only one building constructs at a time per sidebar (classic rule; 🟢 to confirm in
     `BUILDING_SYSTEM.md`).
2. Finished → the icon shows **READY** and glows.
3. **Tap the READY icon** → placement mode:
   - A ghost of the building appears **in the middle of the screen**, snapped to the grid.
   - The footprint is **green** where the building is allowed and **red** where it isn't
     (blocked, out of build range, on resources). The build-range area is shaded.
   - **Drag the ghost** with one finger to move it. It sits about 80 px *above* the finger so
     the finger never hides it. Dragging near the screen edge scrolls the map.
   - **Dragging anywhere else** pans the camera as usual; pinch still zooms.
   - **Large ✓ and ✕ buttons** float next to the ghost. ✓ places it (greyed out while red),
     ✕ cancels and leaves the building READY in the sidebar.
4. Placed → the building appears with a short build-up animation, and the sidebar icon returns
   to normal.

**Why ✓/✕ instead of "tap to place":** a single stray tap that drops a power plant in the wrong
spot is the most frustrating mistake on mobile, and it can't be undone. Confirming costs one
extra tap and prevents it.

## 10. Production (infantry and vehicles)

- **Tap a unit icon** → adds one to that factory's queue. A small number badge shows how many
  are queued.
- **Tap again** → queues another (cap set in data; 5 per type to start).
- **Long-press a queued icon** → removes one from the queue (refund per `ECONOMY.md`).
- Units go to the factory's **rally point** if one is set, or just outside the door otherwise.
- When a sidebar tab has something ready or idle, its tab shows a small dot, so the player
  notices without opening it.

## 11. Accidental-input protection (summary)

- A touch that **starts on any UI element** never reaches the battlefield, even if it is
  dragged onto the map.
- Orders fire on **finger up**, and only if the touch stayed within the tap slop.
- A **second finger landing cancels** the first finger's pending order (that touch is now a
  pinch or pan).
- Building placement needs ✓ to confirm, and queue cancel needs a long-press.
- The pause menu pauses the game in single-player, so the player can think and read.

## 12. What changes depending on 2D vs 3D (for 🟢 ChatGPT / 🔨 Codex)

The player-facing rules above stay the same either way. The differences are internal:
- **Finding what was tapped:** 2D checks the point under the finger; 3D casts a ray from the
  camera. Both must apply the minimum 40 px *screen-space* tap radius from §5.
- **Zoom:** 2D changes the camera zoom; 3D moves the camera lower or higher (fixed angle, no
  rotation in Mission Zero). Camera rotation is **not** recommended. It adds a control the
  player must manage and makes the minimap harder to read.
- **Box select:** in 3D, a unit is inside the box if its on-screen position is inside it.

**Recommendation to the architect (not a decision):** turn raw touches into a small set of
"intents" (Tap, DoubleTap, LongPressDrag, Pan, Pinch) in one input layer. Then gameplay code
never reads raw touch events, and desktop mouse controls (§13) can produce the same intents.

## 13. Desktop controls (development and testing only)

Developers and the Game Director will test a lot on desktop, so desktop must produce the same
intents:

| Mouse/keyboard | Equivalent touch |
|---|---|
| Left click | Tap |
| Left double-click | Double-tap |
| Left drag | One-finger drag (pan) |
| Shift + left drag *or* left hold 0.35 s then drag | Long-press drag (box select) |
| Mouse wheel | Pinch zoom |
| Esc | Deselect / cancel placement |
| S / A then click | Stop / Attack-move |
| 1–4, Ctrl+1–4 | Select / assign control group |

Desktop controls are a testing convenience. They are not a separate design and must never get
features that touch lacks.

## 14. Rollout by roadmap phase

| Phase | Controls delivered |
|---|---|
| **1** Battlefield & movement | Tap select, double-tap select-type, long-press box select, ✕ deselect, Select All Army, tap-to-move with marker, one/two-finger pan, pinch zoom, map-edge limits, forgiving tap radius, desktop mapping, thresholds in a data file |
| **2** Combat | Tap enemy to attack, Attack-Move, Stop, health bar visibility rules, attack feedback |
| **3** Base construction | MCV Deploy, sidebar with build/READY/place flow, ✓/✕ placement, production queues, rally points |
| **4** Economy | Harvester tap-to-harvest, credits/power in the top bar |
| **5** Enemy AI | Alerts and tap-alert-to-jump |
| **6** Mission Zero | Minimap, control groups 1–4, base button |
| **7** Polish | Add-to-selection gesture, haptics, settings (haptics, left-handed mirrored layout, UI scale), tuning from playtests |

## 15. How we'll test it

**Automated (headless Godot, 🔨 Codex):** feed fake touch sequences to the input layer and check
the result. Examples: a 10 px wiggle is a tap and a 30 px move is a pan; holding 0.35 s then
dragging produces a box select; a second finger cancels a pending tap; a tap 35 px from a tiny
unit still selects it; a touch starting on a button never moves units.

**By hand on a real phone (Game Director), each phase:**
1. Select one unit, then a group, without looking at instructions. Was it obvious?
2. Give 20 quick move orders. Did any tap get ignored or do the wrong thing?
3. Pan and zoom while units are selected. Did any unit move by accident?
4. Pick out one tank from a crowd. How many tries did it take?
5. (Phase 3) Place 5 buildings fast. Any misplacements or frustration?
6. Play one-handed for a minute and two-handed for a minute. Which felt natural?

## 16. Open questions for the Game Director

1. **Landscape only?** (Recommended: yes.)
2. **Oldest/smallest phone** we must support? (Default: a ~5.5" screen.)
3. **One-finger drag pans, long-press boxes** — OK as the starting point, with a "box" toggle
   as the fallback if playtests disagree?
4. **Placement with ✓/✕ confirm** — OK, or would you rather have faster tap-to-place and
   accept occasional mistakes?
