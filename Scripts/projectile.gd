extends Area2D
class_name Projectile


@export var projectile_speed := 1000.0
@export var projectile_duration := 1.5
@export var damage := 10.0
@export var max_pierce : int = 1
@export var number_of_projectile := 1
var pierce_left : int

var friendly : bool

func _ready():
	pierce_left = max_pierce
	$ProjectileDuration.start(projectile_duration)

func _physics_process(delta):
	update_position(delta)

func update_position(delta):
	position += projectile_speed * Vector2.RIGHT.rotated(rotation) * delta


func set_friendly(is_friendly : bool):
	friendly = is_friendly
	if is_friendly:
		set_collision_layer_value(4,  true)
		set_collision_mask_value(3,  true)
	else:
		set_collision_layer_value(5,  true)
		set_collision_mask_value(1,  true)

func _on_projectile_duration_timeout():
	queue_free()

func _on_area_entered(area):
	if pierce_left >= 1:
		if friendly and area.get_parent() is Enemy:
			pierce_left -= 1
		elif area.get_parent() is Player:
			pierce_left -= 1
	else:
		queue_free()

func get_position_offsets():
	pass
	
func get_rotation_offsets():
	pass
