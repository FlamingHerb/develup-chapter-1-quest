extends Node2D

enum ComboEvent {SCORE, FALLEN, SINIDROP}

@onready var projectile_group = $ProjectileGrouping
@onready var current_time_label = $UIStuff/TimePanel/CurrentTime
@onready var screen_tint = $ScreenTint
@onready var animation_player = $AnimationPlayer

@onready var flavor_text = $UIStuff/ComboPanel/FlavorText
@onready var combo_count_text = $UIStuff/ComboPanel/ComboLabel
@onready var combo_panel = $UIStuff/ComboPanel

enum StartingPosition {LEFT, RIGHT}
enum ItemType {ITEM, ENEMY}

@export_range(6, 24) var game_time: float = 6
@export_range(1, 200) var game_speed: int = 20
@export var time_passes_allowed: bool = true

const min_per_hour = 60
const game_to_irl_min = (2 * PI) / 1440

# Changing stuff in the game
var current_combo_count: int = 0
var longest_combo_count: int = 0
var sinigang_drops: int = 0
var fallen_items: int = 0


const up_maroon_color = 	Color8(123, 17, 19, 255)
const up_green_color = 		Color8(1, 68, 33, 255)
const up_yellow_color = 	Color8(243, 170, 44, 255)
const default_panel_color = Color8(53, 53, 53, 255)
const default_combo_color = Color8(168, 168, 168, 255)

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_new_item_spawn()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_passes_allowed:
		if game_time > 24.0:
			game_time = 0
		if game_time < 16.0:
			game_time += delta * game_to_irl_min * game_speed
		
		_change_time_label(game_time)
		screen_tint.change_color(game_time)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_key_pressed(KEY_SPACE):
		_new_item_spawn()

#===============================================================================
# Custom functions
#===============================================================================

func _new_item_spawn():
	var new_item = load("res://scenes/game_main/item_base.tscn")
	var adding_item = new_item.instantiate()
	
	if randi_range(0, 1):
		adding_item.position.x = randi_range(-600, -400)
	else:
		adding_item.position.x =  randi_range(1500, 1700)
	
	adding_item.position.y = randi_range(-100, 700)
	
	projectile_group.add_child(adding_item)

## If an ingredient falls.
func _on_ingredient_death_zone_body_entered(body: Node2D) -> void:
	## TODO: Deduct points
	fallen_items += 1
	_change_combo_count(ComboEvent.FALLEN)
	
	print("And it all fell wth.")
	body.queue_free()

## If an ingredient falls into the sinigang.
## body is item_base.gd
func _on_sinigang_physics_body_body_entered(body: Node2D) -> void:
	if body.is_ingredient_cut:
		_change_combo_count(ComboEvent.SCORE)
		
	else:
		sinigang_drops += 1
		_change_combo_count(ComboEvent.SINIDROP)
		
		print("Did not cut it.")
	
	body.queue_free()

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
	
	# Change flavor text		
	if current_combo_count == 1 or current_combo_count == 0:
		flavor_text.text = "COMBO"
	else:
		flavor_text.text = "COMBOS"
	
	# Set style of color box again.
	var style_box = load("res://scenes/themes/combo_panel.tres")
	
		
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
	
	print(combo_count_text.get_theme_color("font_color"))
		
	combo_panel.add_theme_stylebox_override("panel", style_box)
	
	# Finally, change count.
	combo_count_text.text = str(current_combo_count)
	
func _on_timer_timeout() -> void:
	_new_item_spawn()
