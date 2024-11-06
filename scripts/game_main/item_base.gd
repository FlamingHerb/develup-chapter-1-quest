extends RigidBody2D


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

var ingredient_cut_graphics = {
	"daikon": preload("res://graphics/game_main/ingredients/daikon_cut.png"),
	"kangkong": preload("res://graphics/game_main/ingredients/kangkong_cut.png"),
	"meat": preload("res://graphics/game_main/ingredients/meat_cut.png"),
	"onion": preload("res://graphics/game_main/ingredients/onion_cut.png"),
	"tamarind": preload("res://graphics/game_main/ingredients/tamarind_cut.png"),
	"tomato": preload("res://graphics/game_main/ingredients/tomato_cut.png")
}

@onready var time_in_air: float 
@onready var ingredient_picked: String
@onready var is_ingredient_cut: bool = false

@onready var item_got_hit_anim = $ItemGotHit
@onready var item_fell_anim = $ItemFell

@onready var item_sprite = $ItemSprite
@onready var mouse_collision = $Area2D/CollisionShape2D
@onready var actual_hitbox = $ActualHitbox

@onready var target_pos = Vector2(602, 570)

@export var item_type: ItemType

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set target pos randomly
	target_pos.x = target_pos.x + randi_range(-200,200)
	target_pos.y = target_pos.y + randi_range(-400,-200)
	
	_set_graphics()
	_calculate_linear_velocity()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Ingredient is indeed cut.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_ingredient_cut = true
		actual_hitbox.shape.radius = 50
		_change_ingredient()

#===============================================================================
# Custom functions
#===============================================================================

## We know position (x,y) but not linear velocity.
func _calculate_linear_velocity() -> void:
	# First, classify what kind of throw that is valid for this specific item
	if (position.y >= -100 && position.y <= 400):
		time_in_air = randf_range(1, 1.2)
	if (position.y > 400 && position.y <= 600):
		time_in_air = randf_range(1.5, 2)
	if (position.y > 600 && position.y <= 700):
		time_in_air = randf_range(1.7, 2.4)
	
	linear_velocity.x = (target_pos.x - position.x) / time_in_air
	linear_velocity.y = ((target_pos.y - position.y) - ((960 * (time_in_air ** 2)) / 2)) / time_in_air
	angular_velocity = randi_range(0, 20)
	#print(linear_velocity)

## Recalculates velocity if the ingredient is actually cut.
func _change_ingredient() -> void:
	# Freeze to let it change.
	freeze = true
	
	# Change graphics to being cut.
	item_got_hit_anim.play("transform_start")
	
	
	# Disable mouse collision/detection.
	mouse_collision.disabled = true
	
	# Recalculate to be thrown towards the pot.
	linear_velocity.x = (602 - position.x) / 0.1
	linear_velocity.y = (570 - position.y) / 0.1
	
	gravity_scale = 0
	
	# Wait for animation to finish before negg diffing again.
	await item_got_hit_anim.animation_finished
	item_sprite.texture = ingredient_cut_graphics[ingredient_picked]
	item_got_hit_anim.play("transform_end")
	
	await get_tree().create_timer(0.2).timeout
	
	freeze = false
	
	angular_velocity = randi_range(0, 20)

func _set_graphics() -> void:
	ingredient_picked = ingredient.pick_random()
	item_sprite.texture = ingredient_graphics[ingredient_picked]

func item_fell() -> void:
	
	freeze = true
	rotation = 0
	item_sprite.texture = null
	
	if randi_range(0, 1):
		item_fell_anim.play("anim_1")
	else:
		item_fell_anim.play("anim_2")
		
	
	await item_fell_anim.animation_finished
	queue_free()
