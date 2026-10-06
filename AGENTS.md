# AGENTS.md — rules for every AI working in this repository

This file is for ChatGPT, Codex and Claude. Read it in full at the start of every session.

## 1. Start every session the same way

1. Read `AI_HANDOFF.md`. It says what state the project is in and what to do next.
2. Read `MASTER_PROJECT_BRIEF.md`, which holds the vision, scope and rules. It overrides
   everything else.
3. Read the design doc(s) in `docs/` that cover your task.
4. Check the actual repository (files, recent commits) and confirm it matches `AI_HANDOFF.md`.
   If they disagree, trust the repository and say so.

Never rely on memory of an earlier conversation. The repository is the source of truth.

## 2. Who owns what

| Owner | Role | Owns |
|---|---|---|
| 🟢 CHATGPT | Game Designer, Technical Architect, Project Coordinator, QA/Reviewer | What to build and why: design docs, architecture, balance numbers, campaign, acceptance criteria |
| 🔨 CODEX | Lead Implementation Engineer | Godot/GDScript code, core systems, tests, bug fixes, performance, integration |
| 🟣 CLAUDE | UI/UX Specialist, Secondary Engineering Reviewer | Mobile controls and UX, HUD and menus, visual hierarchy, UI implementation, second-opinion reviews |
| 🔵 JOINT | Shared | Repository housekeeping, `AI_HANDOFF.md`, `ROADMAP.md` |

- Label every substantial task with its owner before starting it.
- If a task belongs to another AI, don't do it. Write the Game Director a complete copy-paste
  prompt for that AI, and recommend a model/reasoning level.
- Don't redesign architecture you don't own. Propose the change in `AI_HANDOFF.md` under
  "Proposed changes" and wait for the Game Director.

## 3. The Game Director

The Game Director is the product owner and is not a programmer.

- Explain decisions in plain language. Avoid jargon or explain it in one line.
- Do the implementation and testing yourself; don't hand them code to debug.
- Ask them only for decisions that are truly theirs (game feel, scope, priorities, art, story).

## 4. How we build

- **Mission Zero must be fun.** Nothing else matters until it is (see `docs/MISSION_ZERO.md`).
- Work in the phase order in `ROADMAP.md`. Don't build ahead of the current phase.
- No multiplayer, accounts, monetization, clans or progression code until the roadmap says so.
- Don't over-engineer. Build the simplest version that works, then improve it.
- Don't fake functionality. Never use stubs that pretend a feature works, or hard-coded results
  that look like real systems. If something is placeholder, label it clearly in code and in the
  handoff.
- Don't rewrite working systems without a documented reason.
- No new plugins, add-ons or dependencies without the Game Director's approval.
- Keep game data (costs, HP, damage, build times) in data files (Godot Resources), not hard-coded,
  so balancing never needs code changes.
- Placeholder art (shapes, colours, labels) is fine until art direction is approved.
- All names, art, audio and text must be original. Don't use Red Alert / Command & Conquer names
  or assets.

## 5. Testing

- Test every meaningful feature. Prefer automated tests that run with headless Godot
  (`godot --headless`) so any AI can verify them.
- Report test results honestly. If something wasn't tested, say so and why.
- For anything about feel (controls, combat readability), also list what the Game Director should
  try by hand.

## 6. Finishing a task — always

1. Update `AI_HANDOFF.md`: current build, completed work, current/next task, known issues,
   decisions, files changed, warnings.
2. Update any design doc whose content changed.
3. Commit with a clear message saying what changed and why.
4. Give the Game Director a short plain-language summary: what now works, what to try, and what's
   next (with the owner and a copy-paste prompt if it's another AI's task).

## 7. Repository layout

```
MASTER_PROJECT_BRIEF.md   vision and rules (Game Director owns)
AGENTS.md                 this file
AI_HANDOFF.md             current state; update at the end of every task
ROADMAP.md                phases and status
docs/                     design docs: GAME_DESIGN, TECHNICAL_ARCHITECTURE, MISSION_ZERO,
                          UNIT_SYSTEM, BUILDING_SYSTEM, ECONOMY, MOBILE_CONTROLS, ART_DIRECTION
game/                     the Godot 4 project (created in Phase 1)
.agents/skills/           game-dev reference skills (Godot, RTS disciplines, etc.)
.claude/skills            symlink to .agents/skills for Claude Code
```

## 8. Reference skills

`.agents/skills/` holds 75 game-dev reference guides from
`gamedev-skills/awesome-gamedev-agent-skills` (Apache-2.0). Start with `router/SKILL.md`, which
says which guide fits a task. The ones most relevant to this project: `godot-*`, `game-ai`,
`camera-systems`, `input-systems`, `game-ui-ux`, `physics-tuning`, `performance-optimization`,
`game-feel`, `level-design`, `godot-gdscript-headless-testing`, `godot-export`.
