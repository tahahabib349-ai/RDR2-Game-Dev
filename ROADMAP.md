# ROADMAP

Status key: ⬜ not started · 🟡 in progress · ✅ done

The current goal is **Mission Zero must be fun**. Phases 8+ don't start until Phase 6 passes a
playtest with the Game Director.

| Phase | Name | Main owner | Status | Done when |
|---|---|---|---|---|
| 0 | Blueprint | 🟢 ChatGPT (+ 🟣 Claude for controls) | 🟡 | Design docs, architecture and mobile controls are in `docs/` and the Game Director has approved them |
| 1 | Battlefield, camera, unit selection, movement, pathfinding | 🔨 Codex | ⬜ | On a phone: pan/zoom the map, select one unit or a group, order a move, units path around obstacles |
| 2 | Combat | 🔨 Codex | ⬜ | Units attack, projectiles hit, armor matters, units and buildings die; readable on a phone |
| 3 | Base construction | 🔨 Codex (+ 🟣 Claude for placement UX) | ⬜ | Deploy MCV into HQ, place buildings, build times, power, production queues |
| 4 | Resource economy | 🔨 Codex | ⬜ | Harvester loop produces credits that limit what you can build |
| 5 | Enemy AI | 🔨 Codex (🟢 ChatGPT designs behaviour) | ⬜ | Enemy builds a base and economy and sends escalating attacks |
| 6 | Assemble and balance Mission Zero | 🔵 Joint | ⬜ | Full loop from MCV to victory screen, and the Game Director says it's fun |
| 7 | Mobile UI/UX polish | 🟣 Claude | ⬜ | HUD, menus and controls feel good on real phones |
| 8 | Campaign framework | 🟢 ChatGPT → 🔨 Codex | ⬜ | Briefings, objectives, radio messages, mission flow |
| 9 | Initial campaign | 🟢 ChatGPT → 🔨 Codex | ⬜ | ~5 missions per faction |
| 10 | Skirmish | 🔨 Codex | ⬜ | Configurable battles against AI |

Later, not scheduled: competitive multiplayer, then the persistent strategy layer. See
`MASTER_PROJECT_BRIEF.md`.
