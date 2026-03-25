# Hoard Mode

A game mode modifier for Brotato that floods the screen with enemies.

## What It Does

Hoard Mode adds a toggle on the **difficulty selection page** that can be combined with any difficulty level (Danger 0-5). When enabled:

### Enemy Changes
- **5x Enemy Count** - Five times the number of enemies per wave
- **-40% Enemy HP** - Enemies have less health individually
- **-20% Enemy Damage** - Each hit from an enemy deals less damage

### Player Changes
- **-40% Materials** - Reduced material drops to offset the higher enemy count
- **-40% XP** - Reduced experience gain

### Scaling with Difficulty
The HP reduction stacks with difficulty danger modifiers, creating a natural difficulty curve:

| Difficulty | Enemy HP | Enemy Dmg | Net Total HP | Net Incoming Dmg |
|---|---|---|---|---|
| D0 | 60% | 80% | 3x normal | 4x |
| D3 | 72% | 92% | 3.6x normal | 4.6x |
| D5 | 100% | 100%+ | 5x normal | 5x+ |

At Danger 5, enemies recover to nearly full stats while still appearing at 5x count.

## Features

### Toggle
- Located below the difficulty selectors on the difficulty selection page
- Always defaults to off on game start
- Persists through restarts (hitting Restart keeps hoard mode on)
- Saves/resumes correctly mid-run

### Hoard Mode Indicator
Shown on:
- Pause menu (Escape) - in the difficulty info line
- Shop screen (between waves) - in the title
- End-of-run screen - in the run summary

### Challenges
4 challenges to earn:

| Challenge | Requirement |
|---|---|
| **Hoard Survivor** | Win a run in Hoard Mode (any difficulty) |
| **Hoard Slayer** | Win a run in Hoard Mode on Danger 5 |
| **Hoard Master** | Win Hoard Mode with 5 different characters |
| **Hoard Endurance** | Reach wave 30 in Hoard + Endless Mode |

All challenges are badge-only (no item/character unlocks).

### Configuration
All multipliers are configurable via ModLoader config:

| Setting | Default | Range |
|---|---|---|
| Enemy Count Bonus (%) | 400 | 50-900 |
| Enemy HP Modifier (%) | -40 | -80 to 0 |
| Enemy Damage Modifier (%) | -20 | -50 to 0 |
| Materials Drop Modifier (%) | -40 | -80 to 0 |
| XP Gain Modifier (%) | -40 | -80 to 0 |
| Max Enemies Cap Multiplier | 5.0 | 1.5-10.0 |

The description text on the toggle updates to reflect configured values.

### Localization
Fully translated in 13 languages: English, French, Spanish, German, Russian, Portuguese, Polish, Italian, Turkish, Chinese (Simplified), Chinese (Traditional), Japanese, Korean.

## Technical Details

### No Core File Modifications
This mod uses ModLoader script extensions exclusively. Zero vanilla files are edited.

### Script Extensions
- `run_data.gd` - Adds hoard mode flag, save/resume, restart persistence, challenge triggers
- `entity_spawner.gd` - Raises max concurrent enemies cap (100 to 500)
- `difficulty_selection.gd` - Adds toggle UI, applies effects from config
- `main.gd` - Challenge checks at wave end
- `base_end_run.gd` - Hoard mode label on end screen
- `ingame_main_menu.gd` - Hoard mode label on pause menu
- `shop.gd` - Hoard mode label on shop screen

### Dependencies
None. Works standalone with ModLoader 6.2.0+.

### Compatibility
- Brotato 1.1.13.1
- ModLoader 6.2.0
- Compatible with Endless Mode, Ban Mode, Co-op
