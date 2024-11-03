
extends Button

@onready var button_size = size.x
@onready var hover_left = $HoverLeft
@onready var hover_right = $HoverRight

#===============================================================================
# Engine Signature/Signals functions
#===============================================================================
func _ready() -> void:
	_correct_hover_position()

func _process(delta: float) -> void:
	hover_left.rotation += PI * delta
	hover_right.rotation += PI * delta

func _on_mouse_entered() -> void:
	_change_prompt_visibility(true)

func _on_mouse_exited() -> void:
	_change_prompt_visibility(false)

#===============================================================================
# Custom functions
#===============================================================================
func _correct_hover_position() -> void:
	hover_right.position.x = button_size + 18

func _change_prompt_visibility(value: bool) -> void:
	hover_left.visible = value
	hover_right.visible = value
