extends Area2D
class_name Projectile

var shooter

@export var projectile_speed := 600.0
@export var projectile_duration := .5
@export var damage := 10.0
@export var max_pierce: int = 0
@export var max_chain: int = 0
@export var max_chain_distance := 500.0
@export var max_chain_angle := 60.0
@export var returning := false

var is_returning := false

var pierce_left: int
var chain_left: int

var friendly : bool

signal invalid_number_of_projectile

func _ready():
	pierce_left = max_pierce
	chain_left = max_chain
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

func chain(area):
	var enemies = get_tree().root.get_node("Level/Enemies").get_children()
	var min_distance = 999999.0
	var next_target
	for enemy in enemies:
		var current_distance = global_position.distance_to(enemy.global_position)
		var current_angle = rad_to_deg(get_angle_to(enemy.global_position))
		if current_distance < min_distance and area.get_parent() != enemy and current_angle < max_chain_angle and current_angle > -max_chain_angle:
			min_distance = current_distance
			next_target = enemy
	if next_target:
		chain_left -= 1
		look_at(next_target.global_position)
	else:
		return

func _on_projectile_duration_timeout():
	if not returning:
		dead()
	elif not is_returning:
		$ProjectileDuration.start(projectile_duration)
		is_returning = true
		rotate_projectile_to_shooter()
	else:
		dead()

func rotate_projectile_to_shooter():
	look_at(shooter.global_position)

func _on_area_entered(area):
	if pierce_left > 0 or is_returning:
		if friendly and area.get_parent() is Enemy:
			pierce_left -= 1
		elif area.get_parent() is Player:
			pierce_left -= 1
	elif chain_left > 0 and area.get_parent():
		chain(area)
	else:
		dead()

func dead():
	queue_free()

static func get_position_offsets(pivot: Node2D, distance: float, number_of_projectile: int, angle: float = 12.0):
	var offsets: Array = [Vector2(cos(pivot.rotation),sin(pivot.rotation)) * distance]

	var current_offset: Vector2
	var i = 1
	
	while number_of_projectile > offsets.size():
		current_offset.x = cos(deg_to_rad(angle)*i + pivot.global_rotation) * distance
		current_offset.y = sin(deg_to_rad(angle)*i + pivot.global_rotation) * distance
		offsets.append(current_offset)
		current_offset.x = cos(deg_to_rad(-angle)*i + pivot.global_rotation) * distance
		current_offset.y = sin(deg_to_rad(-angle)*i + pivot.global_rotation) * distance
		offsets.append(current_offset)
		i+=1
	return offsets

static func get_rotation_offsets(pivot_grotation: float, number_of_projectile: int, angle: float = 12.0):
	var offsets: Array = [pivot_grotation]
	var i = 1
	var flip := true
	while number_of_projectile > offsets.size():
		if flip:
			offsets.append(pivot_grotation + angle * i)
			flip = false
		else:
			offsets.append(pivot_grotation + -angle * i)
			i += 1
			flip = true
				
		
	return offsets
	

