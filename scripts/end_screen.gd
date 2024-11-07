extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Only occurs if the game ends abruptly.
	if TransitionLayer.in_transition:
		TransitionLayer.remove_transition()
		await TransitionLayer.transition_finished
	else:
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
