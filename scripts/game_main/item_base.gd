extends RigidBody2D

const target_pos = Vector2(602, 570)
enum ItemType {ITEM, ENEMY}

var ingredient = [
	"daikon", "kangkong", "meat", "onion", "tamarind", "tomato"
]

var ingredient_graphics = {
	"daikon": preload("res://graphics/game_main/ingredients/daikon.png"),
	"kangkong": preload("res://graphics/game_main/ingredients/kangkong.png"),
	"meat": preload("res://graphics/game_main/ingredients/meat.png"),
	"onion": preload("res://graphics/game_main/ingredients/onion.png"),
	"tamarind": preload("res://graphics/game_main/ingredients/tamarind.png"),
	"tomato": preload("res://graphics/game_main/ingredients/tomato.png")
}

@onready var time_in_air: float 
@onready var item_sprite = $ItemSprite
@onready var ingredient_picked: String

@export var item_type: ItemType

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_graphics()
	_calculate_linear_velocity()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		queue_free()

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
	angular_velocity = randi_range(0, 20)
	print(linear_velocity)

func _set_graphics() -> void:
	ingredient_picked = ingredient.pick_random()
	item_sprite.texture = ingredient_graphics[ingredient_picked]
