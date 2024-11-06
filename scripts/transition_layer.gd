extends CanvasLayer

signal transition_finished
@onready var anim_player = $AnimationPlayer

var transition_sfx = [
	"res://audio/sfx/transition_swing_001.mp3",
	"res://audio/sfx/transition_swing_002.mp3",
	"res://audio/sfx/transition_swing_003.mp3",
	"res://audio/sfx/transition_swing_004.mp3"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func execute_transition() -> void:
	AudioManager.sfx_play(transition_sfx.pick_random())
	anim_player.play("next_scene")

func remove_transition() -> void:
	AudioManager.sfx_play(transition_sfx.pick_random())
	anim_player.play("next_scene_show")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	transition_finished.emit()
