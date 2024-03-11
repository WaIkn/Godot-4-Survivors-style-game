extends Sprite2D

@export var hitmarker_time := .1

func _ready():
	$Timer.start(hitmarker_time)



func _on_timer_timeout():
	queue_free()
