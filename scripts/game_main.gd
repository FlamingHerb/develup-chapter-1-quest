extends Node2D

enum ComboEvent {SCORE, FALLEN, SINIDROP, PUNCHED_INGREDIENT, PUNCHED_BAD_ITEM}

enum ItemType {ITEM, ENEMY}

@onready var projectile_group = $ProjectileGrouping
@onready var current_time_label = $UIStuff/TimePanel/CurrentTime
@onready var screen_tint = $ScreenTint
@onready var animation_player = $AnimationPlayer
@onready var god_ray = $GodRay

@onready var ingredient_cut_hit = $SinigangPhysicsBody/IngredientCutHit
@onready var ingredient_not_cut_hit = $SinigangPhysicsBody/IngredientNotCut
@onready var sinigang_death = $SinigangPhysicsBody/SinigangDeath

@onready var flavor_text = $UIStuff/ComboPanel/FlavorText
@onready var combo_count_text = $UIStuff/ComboPanel/ComboLabel
@onready var combo_panel = $UIStuff/ComboPanel

@onready var spawn_timer = $Timer
@onready var start_of_game_timer = $StartOfGameTimer
@onready var rush_time_timer = $RushTimeCounter
@onready var rush_time_duration_timer = $RushTimeDuration

@export_range(6, 24) var game_time: float = 6
@export_range(1, 200) var game_speed: int = 20
@export var time_passes_allowed: bool = true

const min_per_hour = 60
const game_to_irl_min = (2 * PI) / 1440

# Changing stuff in the game
var current_combo_count: int = 0
var longest_combo_count: int = 0
var ingredients_cut: int = 0
var sinigang_drops: int = 0
var fallen_items: int = 0
var punched_ingredients: int = 0
var punched_bad_items: int = 0
var strikes: int = 0
var rush_time: bool = false
var end_day: bool = false

const up_maroon_color = 	Color8(123, 17, 19, 255)
const up_green_color = 		Color8(1, 68, 33, 255)
const up_yellow_color = 	Color8(243, 170, 44, 255)
const default_panel_color = Color8(53, 53, 53, 255)
const default_combo_color = Color8(168, 168, 168, 255)

const god_ray_color = Color8(207, 162, 0, 106)
const god_ray_color_final = Color8(207, 162, 0, 0)

var item_throw_sfx = [
	"res://audio/sfx/item_throw_1.mp3",
	"res://audio/sfx/item_throw_2.mp3",
	"res://audio/sfx/item_throw_3.mp3"
]

var sinigang_dive_sfx = [
	"res://audio/sfx/sinigang_dive_1.ogg",
	"res://audio/sfx/sinigang_dive_2.ogg",
	"res://audio/sfx/sinigang_dive_3.ogg"
]

var ingredient_cut_sfx = [
	"res://audio/sfx/ingredient_cut_1.ogg",
	"res://audio/sfx/ingredient_cut_2.ogg",
	"res://audio/sfx/ingredient_cut_3.ogg"
]

var item_warning_sfx = [
	"res://audio/sfx/item_warning_1.mp3",
	"res://audio/sfx/item_warning_2.mp3"
]

var sinigang_death_sfx = [
	"res://audio/sfx/sinigang_death_1.ogg",
	"res://audio/sfx/sinigang_death_2.ogg",
	"res://audio/sfx/sinigang_death_3.ogg"
]

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# We assume that we come from a transition.
	TransitionLayer.remove_transition()
	
	screen_tint.change_color(game_time)
	_change_time_label(game_time)
	
	await TransitionLayer.transition_finished
	AudioManager.sfx_play("res://audio/sfx/time_to_start.mp3")
	
	animation_player.play("begin_animation")
	
	start_of_game_timer.start()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_passes_allowed:
		if game_time > 24.0:
			game_time = 0
		if game_time < 17.0:
			game_time += delta * game_to_irl_min * game_speed
		
		if game_time >= 16.5 and end_day == false:
			end_day = true
			_end_the_day()
				
		
		# God Ray manipulation
		if game_time < 11.0:
			god_ray.material.set("shader_parameter/color", god_ray_color.lerp(god_ray_color_final, (game_time-7.00)/4.00))
		
		# Rush Hour Check
		if game_time > 11.0 and rush_time == false:
			print("Rush Time Imminent")
			AudioManager.bgm_fade(7)
			rush_time = true
			spawn_timer.stop()
			
			rush_time_timer.start()
		
		_change_time_label(game_time)
		screen_tint.change_color(game_time)

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("pause_game"):
		#AudioManager.sfx_play("res://audio/sfx/pause_game.wav")
		pass

## If an ingredient falls.
func _on_ingredient_death_zone_body_entered(body: Node2D) -> void:
	## TODO: Deduct points
	if body.item_type == ItemType.ITEM:
		fallen_items += 1
		_change_combo_count(ComboEvent.FALLEN)
	
	#print("And it all fell wth.")
	
	body.call_deferred("item_fell")

## If an ingredient falls into the sinigang.
## body is item_base.gd
func _on_sinigang_physics_body_body_entered(body: Node2D) -> void:
	print(body.item_type)
	match body.item_type:
		ItemType.ITEM:
			if body.is_ingredient_cut:
				AudioManager.sfx_play(ingredient_cut_sfx.pick_random())
				
				ingredients_cut += 1
				_change_combo_count(ComboEvent.SCORE)
				ingredient_cut_hit.stop()
				ingredient_cut_hit.play("default")
			else:
				AudioManager.sfx_play(sinigang_dive_sfx.pick_random())
				
				sinigang_drops += 1
				_change_combo_count(ComboEvent.SINIDROP)
				ingredient_not_cut_hit.stop()
				ingredient_not_cut_hit.play("default")
		
		ItemType.ENEMY:
			AudioManager.sfx_play(sinigang_death_sfx.pick_random())
			AudioManager.sfx_play(sinigang_dive_sfx.pick_random())
			
			ingredient_not_cut_hit.stop()
			sinigang_death.stop()
			
			sinigang_drops += 1
			strikes += 1
			ingredient_not_cut_hit.play("default")
			sinigang_death.play("default")
			_change_combo_count(ComboEvent.SINIDROP)
	
	body.queue_free()

func _on_timer_timeout() -> void:
	_new_item_spawn()
	
	# If not rush time
	if rush_time_duration_timer.is_stopped():
		spawn_timer.wait_time = randf_range(0.75, 1.25)
	
	# Guns blazing
	else:
		spawn_timer.wait_time = randf_range(0.5, 0.75)

func _on_start_of_game_timer_timeout() -> void:
	# Game can now start, time resumes.
	time_passes_allowed = true
	
	# Wait before spawning items.
	await get_tree().create_timer(2).timeout
	
	# Play BGM woooh.
	
	AudioManager.bgm_play("res://audio/csd2_diner_murder_mystery.ogg")
	
	spawn_timer.start()

## Rush time begins
func _on_rush_time_counter_timeout() -> void:
	AudioManager.bgm_play("res://audio/csd2_hot_butter_biscuits_lunch_time.ogg")
	animation_player.play("lunch_time")
	await animation_player.animation_finished
	rush_time_duration_timer.start()
	spawn_timer.start()

func _on_rush_time_duration_timeout() -> void:
	AudioManager.bgm_stop()
	AudioManager.sfx_play("res://audio/csd2_rush_time_fanfare.ogg")
	animation_player.play("lunch_time_end")
	
	await get_tree().create_timer(5.5).timeout

	AudioManager.bgm_play("res://audio/csd2_cheese_block.ogg")

#===============================================================================
# Custom functions
#===============================================================================

func _new_item_spawn():
	var new_item = preload("res://scenes/game_main/item_base.tscn")
	var adding_item = new_item.instantiate()
	
	# 80% item, 20% death
	if randf_range(0, 1) < 0.75:
		AudioManager.sfx_play(item_throw_sfx.pick_random())
		adding_item.item_type = ItemType.ITEM
	else:
		AudioManager.sfx_play(item_warning_sfx.pick_random())
		adding_item.item_type = ItemType.ENEMY
	
	if randi_range(0, 1):
		adding_item.position.x = randi_range(-600, -400)
	else:
		adding_item.position.x =  randi_range(1500, 1700)
	
	adding_item.position.y = randi_range(-100, 700)
	
	adding_item.item_punch.connect(_item_got_punched)
	
	projectile_group.add_child(adding_item)
	
	# Play SFX
	
func _item_got_punched(item_type: ItemType):
	print("Item punched is... ", item_type)
	
	# Stop everything for this moment.
	PhysicsServer2D.set_active(false)
	time_passes_allowed = false
	modulate = Color(1.4, 1.4, 1.4)
	AudioManager.bgm_pause(true)
	
	
	match item_type:
		ItemType.ITEM:
			_change_combo_count(ComboEvent.PUNCHED_INGREDIENT)
			punched_ingredients += 1
		
		ItemType.ENEMY:
			_change_combo_count(ComboEvent.PUNCHED_BAD_ITEM)
			punched_bad_items += 1
	
	await get_tree().create_timer(0.4).timeout
	
	PhysicsServer2D.set_active(true)
	time_passes_allowed = true
	modulate = Color(1, 1, 1)
	AudioManager.bgm_pause(false)
	

func _change_time_label(current_time: float):
	var text_hour: String = ""
	var text_min: String = ""
	var hour: float = floor(current_time)
	var minutes: float = floor((current_time - hour) * 60)
	
	if hour < 10:
		text_hour = "0" + str(hour)
	else:
		text_hour = str(hour)
	
	if minutes < 10:
		text_min = "0" + str(minutes)
	else:
		text_min = str(minutes)
	
	current_time_label.text = text_hour + ":" + text_min

func _change_combo_count(combo_type: ComboEvent):
	match combo_type:
		ComboEvent.SCORE:
			if current_combo_count == 0:
				animation_player.play("show_combo")
			current_combo_count += 1
			
		ComboEvent.FALLEN:
			if current_combo_count > 0:
				animation_player.play("hide_combo")
			current_combo_count = 0
			
		ComboEvent.SINIDROP:
			if current_combo_count > 0:
				animation_player.play("hide_combo")
			current_combo_count = 0
			
		ComboEvent.PUNCHED_INGREDIENT:
			if current_combo_count > 0:
				animation_player.play("hide_combo")
			current_combo_count = 0
		
		ComboEvent.PUNCHED_BAD_ITEM:
			if current_combo_count == 0:
				animation_player.play("show_combo")
			current_combo_count += 1
	
	# Set longest combo.
	_set_longest_combo()
	
	# Change flavor text		
	if current_combo_count == 1 or current_combo_count == 0:
		flavor_text.text = "COMBO"
	else:
		flavor_text.text = "COMBOS"
	
	# Set style of color box again.
	var style_box = preload("res://scenes/themes/combo_panel.tres")
	
		
	# Change combo panel and text layout
	if current_combo_count == 0:
		combo_count_text.add_theme_color_override("font_color", default_combo_color)
		style_box.set("bg_color", default_panel_color)
		
	elif current_combo_count > 0 and current_combo_count <= 50:
		combo_count_text.add_theme_color_override("font_color", default_combo_color.lerp(up_yellow_color, float(current_combo_count)/30))
		style_box.set("bg_color", default_panel_color.lerp(up_green_color, float(current_combo_count)/30))
	
	elif current_combo_count > 50 and current_combo_count <= 100:
		#combo_count_text.add_theme_color_override("font_color", up_yellow_color.lerp(up_green_color, float(current_combo_count - 50)/50))
		style_box.set("bg_color", up_green_color.lerp(up_maroon_color, float(current_combo_count - 50)/50))
	
	#print(combo_count_text.get_theme_color("font_color"))
		
	combo_panel.add_theme_stylebox_override("panel", style_box)
	
	# Finally, change count.
	combo_count_text.text = str(current_combo_count)

func _set_longest_combo() -> void:
	if current_combo_count > longest_combo_count:
		longest_combo_count = current_combo_count

func _end_the_day() -> void:
	AudioManager.bgm_fade(7)
	
	await get_tree().create_timer(3).timeout
	spawn_timer.stop()
	await get_tree().create_timer(4).timeout
	
	animation_player.play("day_end")
	AudioManager.sfx_play("res://audio/day_has_ended.ogg")
	
	_send_statistics()
	
	await animation_player.animation_finished
	
	TransitionLayer.execute_transition()
	
	
	await TransitionLayer.transition_finished
	get_tree().change_scene_to_packed(preload("res://scenes/end_screen.tscn"))
	
	
func _send_statistics():
	var new_dictionary: Dictionary = {
		"longest_combo_count": longest_combo_count,
		"ingredients_cut": ingredients_cut,
		"sinigang_drops": sinigang_drops,
		"fallen_items": fallen_items,
		"punched_ingredients": punched_ingredients,
		"punched_bad_items": punched_bad_items,
		"strikes": strikes
	}
	
	Events.set_statistics(new_dictionary)
	
	
