## GameManager.gd
## Central autoload for game state management

extends Node

signal difficulty_changed(new_difficulty: int)
signal game_paused(paused: bool)
signal game_over(dead: bool)

enum Difficulty {
    NORMAL = 0,
    NIGHTMARE = 1,
    HELL = 2
}

enum GameState {
    TITLE,
    PLAYING,
    PAUSED,
    GAME_OVER,
    INVENTORY,
    STATS,
    SKILLS,
    OPTIONS
}

var current_state: GameState = GameState.TITLE
var current_difficulty: Difficulty = Difficulty.NORMAL
var is_multiplayer: bool = false
var players_in_game: int = 1
var game_time: float = 0.0
var gold_dropped_on_death: int = 0

# World settings
const TILE_SIZE: int = 64
const ISO_ANGLE: float = 0.707  # cos(45°)

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _process(delta: float) -> void:
    if current_state == GameState.PLAYING:
        game_time += delta

func change_difficulty(new_diff: Difficulty) -> void:
    current_difficulty = new_diff
    difficulty_changed.emit(new_diff)
    _apply_difficulty_modifiers()

func _apply_difficulty_modifiers() -> void:
    # Higher difficulties reduce player resistances
    match current_difficulty:
        Difficulty.NORMAL:
            pass  # No modifiers
        Difficulty.NIGHTMARE:
            # -30% to all resistances
            pass
        Difficulty.HELL:
            # -50% to all resistances
            pass

func set_game_state(new_state: GameState) -> void:
    current_state = new_state
    
    match new_state:
        GameState.PAUSED:
            game_paused.emit(true)
            get_tree().paused = true
        GameState.PLAYING:
            game_paused.emit(false)
            get_tree().paused = false
        GameState.GAME_OVER:
            game_over.emit(true)

func get_difficulty_modifier() -> float:
    match current_difficulty:
        Difficulty.NORMAL: return 1.0
        Difficulty.NIGHTMARE: return 2.0
        Difficulty.HELL: return 4.0
    return 1.0

func get_resistance_penalty() -> float:
    match current_difficulty:
        Difficulty.NORMAL: return 0.0
        Difficulty.NIGHTMARE: return 0.30
        Difficulty.HELL: return 0.50
    return 0.0
