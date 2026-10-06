# MASTER PROJECT BRIEF

> Source of truth for the project's vision, scope and working rules. Written by the Game
> Director. AI agents must not edit this file except to fix formatting, unless the Game Director
> asks for a change. The main brief below is recorded word for word; the appendix keeps extra
> detail from an earlier draft of the brief.

---

I am developing an original mobile real-time strategy game inspired by the gameplay philosophy and feel of classic PC RTS games, particularly Command & Conquer: Red Alert 2.

This is NOT intended to be a direct Red Alert 2 clone. The finished game must use original intellectual property, including its own factions, characters, story, names, unit/building designs, artwork, music, dialogue, maps and visual identity.

## THE VISION

I want to recreate the classic RTS experience on iOS and Android:

Build a base → establish power → harvest resources → construct production facilities → produce infantry and vehicles → defend the base → build an army → attack enemy positions → destroy the enemy → complete campaign objectives.

The game should retain meaningful RTS control rather than becoming an automated mobile strategy game.

Long term, after the single-player RTS is successful, I want to explore multiplayer and eventually persistent systems somewhat analogous to Clash of Clans — persistent bases, progression, clans/alliances, territory, events and competitive play.

Those systems are NOT the current priority.

## CURRENT PRIORITY — MISSION ZERO

We are deliberately starting small.

Mission Zero is intended to prove that the fundamental RTS gameplay is fun before building a campaign or multiplayer.

The intended gameplay loop is:

Player enters with an MCV-equivalent.

→ Deploy Construction HQ
→ Build Power Plant
→ Build Refinery
→ Harvester collects resources
→ Resources become credits
→ Build Barracks
→ Produce infantry
→ Build Vehicle Factory
→ Produce tanks
→ Build defenses
→ Enemy AI attacks
→ Player builds an army
→ Player attacks enemy base
→ Destroy enemy command structure
→ VICTORY

If Mission Zero isn't genuinely enjoyable, we improve the core game rather than adding more content.

## INITIAL SCOPE

Approximately:

Buildings:

* Construction HQ
* Power Plant
* Refinery
* Barracks
* Vehicle Factory
* Defensive Turret

Units:

* Rifle Infantry
* Anti-Armor Infantry
* Scout/Light Vehicle
* Main Battle Tank
* Heavy/Specialized Tank
* Harvester
* MCV equivalent

Systems:

* Unit selection
* Group selection
* Unit movement
* Pathfinding
* Combat
* Projectiles
* Health
* Armor
* Unit death
* Building construction
* Production queues
* Resource harvesting
* Credits
* Power
* Fog of war
* Enemy AI
* Mission objectives
* Victory/defeat

The game is MOBILE FIRST.

Controls must eventually support intuitive touch selection, movement, attacking, camera movement, pinch zoom, building placement and army control.

## ENGINE

Current preferred engine:

Godot 4.x

The game should target:

Android
iOS

Desktop builds may be used during development and testing.

## CAMPAIGN

Once Mission Zero works and is fun, we will develop the campaign framework.

We do not have the resources for Red Alert-style live-action FMV cinematics.

Instead, storytelling can use:

Animated strategic maps
Commander portraits
Radio communications
Voice-over
Mission intelligence
Animated briefings
Mission objectives
In-engine sequences

The initial campaign should be deliberately manageable, potentially around five missions per faction.

## DEVELOPMENT PHILOSOPHY

This project has limited financial resources and will rely heavily on AI-assisted development.

Therefore:

Do not over-engineer.

Do not prematurely implement multiplayer.

Do not build massive amounts of content before gameplay is proven.

Do not create fake functionality.

Do not casually rewrite working systems.

Do not add unnecessary dependencies.

Build incrementally.

Test every meaningful feature.

The repository and project documentation are the source of truth, NOT an AI conversation's memory.

## AI DEVELOPMENT TEAM

I am the Game Director / Product Owner.

I understand the game I want to create, but I do not have a programming or computer-science background.

Do not expect me to manually debug large amounts of code.

Explain technical decisions to me in understandable language while performing as much implementation/testing as your environment allows.

The AI responsibilities are divided as follows:

### CHATGPT

Role:

Game Designer
Technical Architect
Systems Designer
Project Coordinator
Campaign Designer
Balancing Analyst
QA / Reviewer

ChatGPT primarily determines WHAT should be built, WHY it should work that way, how systems should interact, and whether implementations meet the game's objectives.

### CODEX

Role:

Lead Implementation Engineer

Codex primarily handles:

Repository-level implementation
Godot/GDScript development
Core game systems
Refactoring
Testing
Bug fixing
Performance optimization
Integration

Codex generally implements specifications created through the design/architecture process.

### CLAUDE

Role:

UI/UX Specialist
Secondary Engineering Reviewer

Claude primarily handles:

UI design
Mobile UX
Visual hierarchy
Interface polish
Frontend implementation where appropriate
Second opinions on difficult engineering problems

Claude should not independently redesign fundamental architecture without documenting and coordinating the change.

## TASK OWNERSHIP RULE

Before every substantial task, identify its owner:

🟢 CHATGPT
🟣 CLAUDE
🔨 CODEX
🔵 JOINT

Do not have multiple AI systems independently implement the same feature unless intentionally conducting a review.

If a task belongs to another AI, provide me with a complete copy-paste prompt for that AI rather than unnecessarily duplicating its work.

Also recommend the appropriate model/reasoning level when relevant so I do not waste tokens on an unnecessarily expensive model.

## PROJECT DOCUMENTATION

The repository should eventually maintain:

MASTER_PROJECT_BRIEF.md
GAME_DESIGN.md
TECHNICAL_ARCHITECTURE.md
MISSION_ZERO.md
UNIT_SYSTEM.md
BUILDING_SYSTEM.md
ECONOMY.md
MOBILE_CONTROLS.md
ART_DIRECTION.md
ROADMAP.md
AI_HANDOFF.md
AGENTS.md

AI_HANDOFF.md should track:

* Current build
* Completed work
* Current task
* Known issues
* Architectural decisions
* Recently modified files
* Next recommended task
* Important warnings

This allows us to switch between ChatGPT, Claude and Codex without depending on enormous conversation histories.

## DEVELOPMENT ORDER

Phase 0 — Blueprint

Phase 1 — Battlefield, camera, unit selection, movement and pathfinding

Phase 2 — Combat

Phase 3 — Base construction

Phase 4 — Resource economy

Phase 5 — Enemy AI

Phase 6 — Assemble and balance Mission Zero

Phase 7 — Mobile UI/UX polish

Phase 8 — Campaign framework

Phase 9 — Initial campaign

Phase 10 — Skirmish

Multiplayer and persistent progression come substantially later.

## MOST IMPORTANT RULE

Do not confuse progress with the amount of code generated.

Our first major objective is:

MISSION ZERO MUST BE FUN.

Everything else is secondary until that has been achieved.

When continuing this project, first determine the current project state from the repository and AI_HANDOFF.md rather than assuming where development stopped.

---

## Appendix — extra detail from the earlier draft of the brief

The Game Director's first draft of the brief stopped part-way through its "Fog of War" section.
These parts add detail that the main brief above doesn't repeat.

### Product vision

The player should be able to: establish a base; construct buildings; generate power; harvest
resources; manage an economy; produce infantry; produce vehicles; eventually produce aircraft and
naval units; research/unlock technology; defend the base; control individual units; control groups
of units; attack enemy positions; destroy enemy bases; complete mission objectives; play a
story-driven campaign; play skirmish matches against AI.

The game should NOT become a simplified mobile "auto-battler." Player control and tactical
decision-making are fundamental.

### Long-term stages

- Stage I — Core RTS
- Stage II — Single-Player Campaign
- Stage III — Skirmish
- Stage IV — Competitive Multiplayer
- Stage V — Persistent Strategy Layer (persistent bases, progression, alliances/clans, territory,
  seasonal wars, events, technology progression, rankings). These later systems must NOT
  compromise the classic RTS gameplay.

### Mission Zero detail

Do NOT build a large campaign, multiplayer infrastructure, monetization systems, accounts, clans or
elaborate progression before Mission Zero works. The player discovers a resource field; the
harvester returns to the refinery; enemy AI develops its own economy and produces military units;
enemy attack waves threaten the player's base; destroying the enemy command structure completes
the mission and a victory screen appears.

Engineer or equivalent utility infantry may be added later if justified. Additional units should
only be introduced when the underlying systems are stable.

### Later buildings (do NOT implement prematurely)

Advanced Power, Technology Center, Radar, Airfield, Repair Facility, Advanced Defenses,
Superweapons, Naval Yard.

### Core game systems the architecture should eventually support

- **Unit system:** health, armor, speed, damage, weapon range, fire rate, target selection,
  movement, pathfinding, formation behavior; veterancy and status effects later.
- **Combat:** projectiles; hitscan weapons where appropriate; armor interactions; area damage; unit
  death; building destruction; target acquisition; attack commands; defensive targeting. Combat
  should be readable and satisfying on a phone screen.
- **Economy:** resource field → harvester → refinery → credits. The economy should create strategic
  pressure. Resources must matter.
- **Construction:** buildings require credits, construction time, valid placement, technology
  prerequisites, and power where applicable.
- **Production:** barracks produce infantry; vehicle factories produce vehicles; production should
  support queues.
- **Power:** buildings consume power; power plants generate power; insufficient power should create
  meaningful consequences.
- **Fog of war:** the player should not automatically know… *(the draft ended here)*
