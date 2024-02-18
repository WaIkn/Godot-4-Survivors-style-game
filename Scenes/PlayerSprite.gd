extends Sprite2D

func _physics_process(delta):
	if get_local_mouse_position().x >= 0:
		flip_h = false
	else:
		flip_h = true
