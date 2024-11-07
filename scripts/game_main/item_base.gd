extends RigidBody2D

enum ItemType {ITEM, ENEMY}

signal item_punch(item_type: ItemType, body_reference: Node2D)

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


var death_graphics = [
	preload("res://graphics/game_main/death/bug_kokuzoumushi_kome.png"),
	preload("res://graphics/game_main/death/cooking_syouyu.png"),
	preload("res://graphics/game_main/death/fashion_loose_socks.png"),
	preload("res://graphics/game_main/death/medical_syoudoku_alcohol.png")
]

var item_fall_sfx = [
	"res://audio/sfx/explode-4.wav",
	"res://audio/sfx/explode-5.wav",
	"res://audio/sfx/explode-6.wav",
	"res://audio/sfx/explode-7.wav"
]

var item_cut_sfx = [
	#"res://audio/sfx/ingredient_point_1.wav"
	#"res://audio/sfx/ingredient_point_2.wav",
	#"res://audio/sfx/ingredient_point_3.wav",
	#"res://audio/sfx/ingredient_point_4.wav",
	"res://audio/sfx/ingredient_point_5.ogg",
	"res://audio/sfx/ingredient_point_6.ogg",
	"res://audio/sfx/ingredient_point_7.ogg"
]

var item_bad_sfx = [
	"res://audio/sfx/bad_ingredient_1.ogg",
	"res://audio/sfx/bad_ingredient_2.ogg"
]

var explosion_sfx = [
	"res://audio/sfx/explosion_1.ogg",
	"res://audio/sfx/explosion_2.ogg",
	"res://audio/sfx/explosion_3.ogg",
	"res://audio/sfx/explosion_4.ogg"
]

var parry_sfx = "res://audio/sfx/parry.ogg"

@onready var time_in_air: float 
@onready var ingredient_picked: String
@onready var is_ingredient_cut: bool = false

@onready var item_got_hit_anim = $ItemGotHit
@onready var item_fell_anim = $ItemFell
@onready var item_explode_anim = $ItemExplodes
@onready var anim_player = $AnimationPlayer

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
	if event is InputEventMouseButton and event.pressed:
		
		# Remove mask, no more scanning.
		# If Left-clicked, levitate to pot.
		if event.button_index == MOUSE_BUTTON_LEFT:
			if item_type == ItemType.ITEM:
				AudioManager.sfx_play(item_cut_sfx.pick_random())
			else:
				AudioManager.sfx_play(item_bad_sfx.pick_random())
			is_ingredient_cut = true
			actual_hitbox.shape.radius = 50
			_change_ingredient()
		
		# If right-clicked, punch it away.
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_item_got_punched()

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
	
	if item_type == ItemType.ITEM:
		item_sprite.texture = ingredient_cut_graphics[ingredient_picked]
	
	item_got_hit_anim.play("transform_end")
	
	await get_tree().create_timer(0.2).timeout
	
	freeze = false
	
	angular_velocity = randi_range(0, 20)

func _set_graphics() -> void:
	match item_type:
		ItemType.ITEM:
			ingredient_picked = ingredient.pick_random()
			item_sprite.texture = ingredient_graphics[ingredient_picked]
		ItemType.ENEMY:
			item_sprite.texture = death_graphics.pick_random()
		

func item_fell() -> void:
	
	freeze = true
	rotation = 0
	item_sprite.texture = null
	
	if randi_range(0, 1):
		item_fell_anim.play("anim_1")
	else:
		item_fell_anim.play("anim_2")
		
	AudioManager.sfx_play(item_fall_sfx.pick_random())
	await item_fell_anim.animation_finished
	queue_free()

func _item_got_punched() -> void:
	freeze = true
	item_punch.emit(item_type, self)
	AudioManager.sfx_play(parry_sfx)
	mouse_collision.disabled = true
	
	linear_velocity = Vector2(0,0)
	gravity_scale = 0
	
	await get_tree().create_timer(Events.hit_stop_duration).timeout
	
	anim_player.play("item_explodes")
	await anim_player.animation_finished
	
	item_sprite.visible = false
	AudioManager.sfx_play(explosion_sfx.pick_random())
	item_explode_anim.play("default")
	await item_explode_anim.animation_finished
	
	
	queue_free()
	
