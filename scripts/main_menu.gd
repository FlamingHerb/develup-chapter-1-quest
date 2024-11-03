extends Node

@export var game_scene: PackedScene

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

func _ready() -> void:
	AudioManager.bgm_play("res://audio/csd2_mainmenu_c.ogg")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_how_to_play_pressed() -> void:
	pass # Replace with function body.

func _on_quit_game_pressed() -> void:
	pass # Replace with function body.

#===============================================================================
# Custom functions
#===============================================================================
