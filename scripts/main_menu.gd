extends Node

@onready var anim_player = $AnimationPlayer
@onready var current_scene: String = ""

@export var game_scene: PackedScene

var transition_sfx = [
	"res://audio/sfx/transition_swing_001.mp3",
	"res://audio/sfx/transition_swing_002.mp3",
	"res://audio/sfx/transition_swing_003.mp3",
	"res://audio/sfx/transition_swing_004.mp3"
]



#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

func _ready() -> void:
	AudioManager.bgm_play("res://audio/csd2_mainmenu_c.ogg")
	
	# Only occurs if the game ends abruptly.
	if TransitionLayer.in_transition:
		TransitionLayer.remove_transition()
		await TransitionLayer.transition_finished
	else:
		pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	AudioManager.bgm_stop(0.5)
	
	TransitionLayer.execute_transition()
	
	await TransitionLayer.transition_finished
	
	get_tree().change_scene_to_packed(game_scene)
	
	
func _on_how_to_play_pressed() -> void:
	AudioManager.sfx_play(transition_sfx.pick_random())
	if current_scene == "how_to_play":
		current_scene = ""
		anim_player.play("hide_how_to_play")
	else:
		current_scene = "how_to_play"
		anim_player.play("show_how_to_play")

func _on_credits_pressed() -> void:
	AudioManager.sfx_play(transition_sfx.pick_random())
	if current_scene == "credits":
		current_scene = ""
		anim_player.play("hide_credits")
	else:
		current_scene = "credits"
		anim_player.play("show_credits")

func _on_quit_game_pressed() -> void:
	get_tree().quit()

#===============================================================================
# Custom functions
#===============================================================================
