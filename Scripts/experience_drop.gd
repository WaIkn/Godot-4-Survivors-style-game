extends Node2D
class_name ExperienceDrop

var velocity := Vector2.ZERO
var target = null
var base_acceleration := 10.0
var acceleration_ramp := .01
@onready var acceleration := base_acceleration
var decceleration = 10.0

func _physics_process(delta):
	
	update_velocity(delta)
	global_position += velocity
	
	
func update_velocity(delta):
	var temp_velocity = velocity
	if target is Player:
		temp_velocity += (target.global_position - global_position).normalized() * acceleration * delta
		_ramp_acceleration()
	temp_velocity -= velocity.normalized() * decceleration * delta
		
	velocity = temp_velocity


func _on_hitbox_area_entered(area):
	if area.get_parent() is Player:
		target = area.get_parent()


func _on_hitbox_area_exited(area):
	if area.get_parent() is Player:
		target = null
		acceleration_ramp = 0.0

func _ramp_acceleration():
	acceleration *= (1 + acceleration_ramp)

func pick_up():
	queue_free()
