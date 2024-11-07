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
@onready var results_background = $ResultsScreen/ResultsBackground

var drum_roll_sfx = "res://audio/sfx/drum_roll.wav"
var woosh_sfx = "res://audio/sfx/dsbarexp.wav"
var mistaker_sfx = "res://audio/sfx/dsplpain.wav"
var mistake_done_sfx = "res://audio/sfx/end_screen_fucked_up.mp3"
var good_applause = "res://audio/sfx/good_applause.ogg"
var bad_applause = "res://audio/sfx/bad_applause.ogg"

var end_pathetic = "res://audio/sfx/end_pathethic.mp3"
var end_bad = "res://audio/sfx/end_bad.ogg"
var end_good = "res://audio/sfx/end_good.ogg"
var end_perfect = "res://audio/sfx/end_perfect.ogg"

var transition_each_line = 0.5

# Arranged in order
var background_screens = [
	preload("res://graphics/end_screen/background/screen_0.png"),
	preload("res://graphics/end_screen/background/screen_1.png"),
	preload("res://graphics/end_screen/background/screen_2.png"),
	preload("res://graphics/end_screen/background/screen_3.png"),
	preload("res://graphics/end_screen/background/screen_4.png"),
	preload("res://graphics/end_screen/background/screen_5.png"),
	preload("res://graphics/end_screen/background/screen_6.png"),
	preload("res://graphics/end_screen/background/screen_7.png"),
	preload("res://graphics/end_screen/background/screen_8.png"),
	preload("res://graphics/end_screen/background/screen_9.png")
]

# MADNESS BEGINS
@onready var long_combo 				= $ResultsScreen/ResultsPanel/VC/HC/LongCombo
@onready var long_combo_count 			= $ResultsScreen/ResultsPanel/VC/HC/LongComboCount
@onready var ingredients_cut			= $ResultsScreen/ResultsPanel/VC/HC2/IngreCut
@onready var ingredients_cut_count		= $ResultsScreen/ResultsPanel/VC/HC2/IngreCutCount
@onready var punched_bad				= $ResultsScreen/ResultsPanel/VC/HC3/PunchedBad
@onready var punched_bad_count			= $ResultsScreen/ResultsPanel/VC/HC3/PunchedBadCount
@onready var sinigang_drop				= $ResultsScreen/ResultsPanel/VC/HC4/SinigangDrop
@onready var sinigang_drop_count		= $ResultsScreen/ResultsPanel/VC/HC4/SinigangDropCount
@onready var fallen_items				= $ResultsScreen/ResultsPanel/VC/HC5/FallenItems
@onready var fallen_items_count			= $ResultsScreen/ResultsPanel/VC/HC5/FallenItemsCount
@onready var punched_ingredients		= $ResultsScreen/ResultsPanel/VC/HC6/PunchedIngre
@onready var punched_ingredients_count	= $ResultsScreen/ResultsPanel/VC/HC6/PunchedIngreCount
@onready var strikeds					= $ResultsScreen/ResultsPanel/VC/HC7/Strikes
@onready var strikeds_count				= $ResultsScreen/ResultsPanel/VC/HC7/StrikesCount


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

func _set_debug_stats() -> void:
	statistics =  {
		"longest_combo_count": 75,
		"ingredients_cut": 50,
		"sinigang_drops": 0,
		"fallen_items": 0,
		"punched_ingredients": 0,
		"punched_bad_items": 25,
		"strikes": 0
	}

func _results_screen_time() -> void:
	# TODO: Remember to remove this later!
	#_set_debug_stats()
	
	# Default score is 4
	var score = 4
	
	# Wait for transition to end first.
	await get_tree().create_timer(0.5).timeout
	
	# Show canvas
	results_screen_canvas.visible = true
	
	# Wait for transition to end first.
	AudioManager.sfx_play(drum_roll_sfx)
	await get_tree().create_timer(1).timeout
	
	# Setting up man face
	man_face_results.frame = score

	#========================================
	# Longest Combo
	#========================================
	long_combo.visible = true
	
	long_combo_count.text = str(statistics["longest_combo_count"])
	long_combo_count.visible = true
	if statistics["longest_combo_count"] >= 75:
		AudioManager.sfx_play(woosh_sfx)
		score += 1
	else:
		AudioManager.sfx_play(mistaker_sfx)
		score -= 1
	
	man_face_results.frame = score
	results_background.texture = background_screens[score]
	
	await get_tree().create_timer(transition_each_line).timeout
	
	#========================================
	# Ingredients Cut
	#========================================
	ingredients_cut.visible = true
	
	ingredients_cut_count.text = str(statistics["ingredients_cut"])
	ingredients_cut_count.visible = true
	if statistics["ingredients_cut"] >= 50:
		AudioManager.sfx_play(woosh_sfx)
	else:
		AudioManager.sfx_play(mistaker_sfx)
	
	man_face_results.frame = score
	results_background.texture = background_screens[score]
	
	await get_tree().create_timer(transition_each_line).timeout
	
	#========================================
	# Punched Bad Items
	#========================================
	punched_bad.visible = true
	
	punched_bad_count.text = str(statistics["punched_bad_items"])
	punched_bad_count.visible = true
	if statistics["punched_bad_items"] >= 25:
		AudioManager.sfx_play(woosh_sfx)
	else:
		AudioManager.sfx_play(mistaker_sfx)
	
	man_face_results.frame = score
	results_background.texture = background_screens[score]
	
	await get_tree().create_timer(transition_each_line).timeout
	
	#========================================
	# Sinigang Drops
	#========================================
	sinigang_drop.visible = true
	
	sinigang_drop_count.text = str(statistics["sinigang_drops"])
	sinigang_drop_count.visible = true
	if statistics["sinigang_drops"] == 0:
		AudioManager.sfx_play(woosh_sfx)
		score += 1
	else:
		score -= 1
		AudioManager.sfx_play(mistaker_sfx)
	
	man_face_results.frame = score
	results_background.texture = background_screens[score]
	
	await get_tree().create_timer(transition_each_line).timeout
	
	#========================================
	# Fallen Items
	#========================================
	fallen_items.visible = true
	
	fallen_items_count.text = str(statistics["fallen_items"])
	fallen_items_count.visible = true
	if statistics["fallen_items"] == 0:
		AudioManager.sfx_play(woosh_sfx)
		score += 1
	else:
		score -= 1
		AudioManager.sfx_play(mistaker_sfx)
	
	man_face_results.frame = score
	results_background.texture = background_screens[score]
	
	await get_tree().create_timer(transition_each_line).timeout
	
	#========================================
	# Punched Ingredients
	#========================================
	punched_ingredients.visible = true
	
	punched_ingredients_count.text = str(statistics["punched_ingredients"])
	punched_ingredients_count.visible = true
	if statistics["punched_ingredients"] == 0:
		AudioManager.sfx_play(woosh_sfx)
		score += 1
	else:
		score -= 1
		AudioManager.sfx_play(mistaker_sfx)
	
	man_face_results.frame = score
	results_background.texture = background_screens[score]
	
	await get_tree().create_timer(transition_each_line).timeout
	
	#========================================
	# Strikes
	#========================================
	strikeds.visible = true
	
	strikeds_count.text = str(statistics["strikes"])
	strikeds_count.visible = true
	if statistics["strikes"] == 0:
		AudioManager.sfx_play(woosh_sfx)
		score += 1
	else:
		score -= 1
		AudioManager.sfx_play(mistaker_sfx)
	
	man_face_results.frame = score
	results_background.texture = background_screens[score]
	
	await get_tree().create_timer(transition_each_line).timeout
	
	#========================================
	# FINALE
	#========================================	
	await get_tree().create_timer(1.5).timeout

	if score == 0:
		AudioManager.sfx_play(end_pathetic)
	elif score >= 1 and score <= 3:
		AudioManager.sfx_play(end_bad)
	elif score >= 1 and score <= 3:
		AudioManager.sfx_play(end_good)
	elif score == 9:
		AudioManager.sfx_play(end_perfect)
	print(score)
