extends Node2D

@onready var projectile_group = $ProjectileGrouping
@onready var current_time_label = $UIStuff/TimePanel/CurrentTime
@onready var screen_tint = $ScreenTint

enum StartingPosition {LEFT, RIGHT}
enum ItemType {ITEM, ENEMY}

@export_range(6, 24) var game_time: float = 6
@export_range(1, 200) var game_speed: int = 20
@export var time_passes_allowed: bool = true

const min_per_hour = 60
const game_to_irl_min = (2 * PI) / 1440


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
	print("And it all fell wth.")
	body.queue_free()

## If an ingredient falls into the sinigang.
## body is item_base.gd
func _on_sinigang_physics_body_body_entered(body: Node2D) -> void:
	if body.is_ingredient_cut:
		## TODO: Add scoring here.
		pass
	else:
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
