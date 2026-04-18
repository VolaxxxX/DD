# Aether Drift

2.5D procedural co-op RPG MVP for Android & iOS. Built with Godot 4.3.

- Run-based (5–25 min), permadeath, world memory across runs.
- Solo + 2-player online co-op.
- Procedural ecosystems, hidden fate engine, emergent apex (dragon) events.
- No scripted progression.

## Start here

Read [SETUP.md](./SETUP.md) — step-by-step guide to run the project.

## Architecture overview

```
core/    - seeds, RNG, event bus, run orchestrator, world memory
world/   - zone generator (biome, chaos, corruption)
entity/  - archetype factory, creatures, AI FSM, ecosystem
apex/    - dragon system (ecosystem modifiers)
fate/    - hidden d20 resolver, event resolver
net/     - ENet host/client, event-based packets
coop/    - shared-decision voting
render/  - 2.5D zone & entity views
ui/      - minimal HUD (no numbers shown to player)
player/  - local player controller
```

Branch: `claude/mobile-game-mvp-9riFM`
