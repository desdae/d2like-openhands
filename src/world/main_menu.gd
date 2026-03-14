## MainMenu.gd
## Main menu scene script

extends Control

func _ready() -> void:
    # Play main menu music
    pass

func _on_start_game_pressed() -> void:
    get_tree().change_scene_to_file("res://src/world/character_select.tscn")

func _on_options_pressed() -> void:
    pass  # TODO

func _on_exit_pressed() -> void:
    get_tree().quit()
