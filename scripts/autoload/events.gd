extends Node

var player_statistics = {
	"longest_combo_count": 0,
	"ingredients_cut": 0,
	"sinigang_drops": 0,
	"fallen_items": 0,
	"punched_ingredients": 0,
	"punched_bad_items": 0,
	"strikes": 0
}

var hit_stop_duration: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_statistics() -> Dictionary:
	return player_statistics

func set_statistics(data: Dictionary) -> void:
	player_statistics = data
	print(player_statistics)
