extends RigidBody2D

const target_pos = Vector2(602, 570)
enum ItemType {ITEM, ENEMY}


@onready var time_in_air: float 
@export var item_type: ItemType

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_calculate_linear_velocity()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#===============================================================================
# Custom functions
#===============================================================================

## We know position (x,y) but not linear velocity.
func _calculate_linear_velocity() -> void:
	# First, classify what kind of throw that is valid for this specific item
	if (position.y >= -100 && position.y <= 400):
		time_in_air = randi_range(1, 1.2)
	if (position.y > 400 && position.y <= 600):
		time_in_air = randi_range(1.5, 2)
	if (position.y > 600 && position.y <= 700):
		time_in_air = randi_range(1.7, 2.4)
	
	linear_velocity.x = (target_pos.x - position.x) / time_in_air
	linear_velocity.y = ((target_pos.y - position.y) - ((960 * (time_in_air ** 2)) / 2)) / time_in_air
	print(linear_velocity)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		queue_free()
