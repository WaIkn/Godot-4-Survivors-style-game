extends Label
class_name DeadUI


func _ready():
	pass

func fade_in(seconds : float):
	modulate.a = 0
	create_tween().tween_property(self, "modulate:a", 1, seconds)
