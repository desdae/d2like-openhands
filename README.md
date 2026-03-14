# D2-like OpenHands

A dark, isometric action role-playing game set in a gothic fantasy world.

## Overview

The player controls a single hero from an overhead isometric perspective, battling through randomized dungeons, wilderness areas, and hellish landscapes. The core loop revolves around real-time combat, character progression through skill trees, and the pursuit of increasingly powerful randomized loot.

## Features

- **5 Playable Classes**: Marauder, Sorceress, Shadow, Necromancer, Paladin
- **3 Skill Trees per Class**: ~20 skills each (60 skills per class)
- **3 Difficulty Tiers**: Normal, Nightmare, Hell
- **Procedural Generation**: Randomized dungeons and zones
- **Loot System**: 6 rarity tiers, affixes, sockets, runes, charms

## Project Structure

```
src/
├── core/           # Game managers and databases
│   ├── game_manager.gd
│   ├── player_manager.gd
│   ├── item_database.gd
│   └── skill_database.gd
├── character/      # Player character code
├── combat/         # Combat system
├── items/          # Item-related code
├── world/          # Level/world generation
├── ai/             # Monster AI
├── ui/             # User interface
├── multiplayer/    # Multiplayer support
└── scripts/        # Utility scripts

assets/
├── sprites/        # Character/item sprites
├── tiles/          # Environment tiles
├── audio/          # Sound effects and music
├── fonts/          # UI fonts
└── ui/             # UI graphics

data/
├── items/          # Item definitions
├── monsters/       # Monster data
├── skills/         # Skill definitions
├── quests/         # Quest data
└── levels/         # Level templates
```

## Getting Started

### Prerequisites

- Godot Engine 4.2+

### Running the Game

1. Open the project in Godot 4.2+
2. Press F5 to run

### Controls

- **WASD**: Move
- **Left Click**: Primary attack/skill
- **Right Click**: Secondary skill
- **1-4**: Potion hotkeys
- **I**: Inventory
- **S**: Skills
- **ESC**: Pause/Menu

## Documentation

See `docs/` for detailed documentation.

## License

MIT License
