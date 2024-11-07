extends Control

var statistics =  {
	"longest_combo_count": 0,
	"ingredients_cut": 0,
	"sinigang_drops": 0,
	"fallen_items": 0,
	"punched_ingredients": 0,
	"punched_bad_items": 0,
	"strikes": 0
}

var defeat_sfx = [
	"res://audio/sfx/defeat_1.ogg",
	"res://audio/sfx/defeat_2.ogg"
]

@onready var anim_player = $AnimationPlayer

# Results screen does not use animation, so....
@onready var results_screen_canvas = $ResultsScreen
@onready var man_face_results = $ResultsScreen/ManFace

@onready var drum_roll_sfx = "res://audio/sfx/drum_roll.wav"
@onready var mistake_done_sfx = "res://audio/sfx/end_screen_fucked_up.mp3"

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	statistics = Events.get_statistics()
	results_screen_canvas.visible = false
	
	if statistics["strikes"] == 3:
		anim_player.play("defeat")
	else:
		_results_screen_time()
	
	# Only occurs if the game ends abruptly.
	if TransitionLayer.in_transition:
		TransitionLayer.remove_transition()
		await TransitionLayer.transition_finished
	else:
		pass
	
	# TODO: REMEMBER, THIS IS DEBUG ONLY
	# anim_player.play("defeat")

#===============================================================================
# Custom functions
#===============================================================================

func _play_defeat_sfx() -> void:
	AudioManager.sfx_play(defeat_sfx.pick_random())

func _play_spotlight_sfx() -> void:
	AudioManager.sfx_play("res://audio/sfx/spotlight.mp3")

func _play_dead_gfx() -> void:
	$BadEnd/AnimatedSprite2D.play("default")

func _on_retry_again_pressed() -> void:
	_retry_again()

func _on_quit_to_menu_pressed() -> void:
	_quit_to_menu()


func _retry_again() -> void:
	TransitionLayer.execute_transition()
	await TransitionLayer.transition_finished
	
	get_tree().change_scene_to_file.call_deferred("res://scenes/game_main.tscn")
	
func _quit_to_menu() -> void:
	TransitionLayer.execute_transition()
	await TransitionLayer.transition_finished
	
	get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu.tscn")

func _results_screen_time() -> void:
	# Wait for transition to end first.
	await get_tree().create_timer(0.5).timeout
	
	results_screen_canvas.visible = true
	
	# Setting up man face
	man_face_results.frame = 3
