extends Node2D

@onready var projectile_group = $ProjectileGrouping

enum StartingPosition {LEFT, RIGHT}
enum ItemType {ITEM, ENEMY}

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_new_item_spawn()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_key_pressed(KEY_SPACE):
		_new_item_spawn()

#===============================================================================
# Custom functions
#===============================================================================

func _new_item_spawn():
	var new_item = preload("res://scenes/game_main/item_base.tscn")
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
