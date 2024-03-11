extends RayCast2D
class_name Beam

@onready var line := $Line2D as Line2D

const wind_up_time := 0.1
const wind_down_time := 0.05


func _ready():
	line.points[0] = Vector2.ZERO
	set_physics_process(true)
	

func fire():
	set_physics_process(true)
	force_target_update()
	beam()
		

func beam():
	var tween = create_tween()
	if is_colliding():
		$TargetParticles.position = line.points[1]
		$TargetParticles.rotation = get_collision_normal().angle()
		$TargetParticles.emitting = true
		$BeamParticles.emitting = true
		
	tween.tween_property($Line2D,"width", 3.0, wind_up_time).as_relative().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Line2D,"width", 0, wind_down_time)
	tween.tween_property($TargetParticles,"emitting",false,0.0)
	

func dead():
	queue_free()
	
static func get_beam_time():
	return wind_down_time + wind_up_time

func force_target_update():
	var cast_point := target_position
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
	
	line.points[1] = cast_point
	$BeamParticles.position = cast_point *.5
	$BeamParticles.process_material.emission_box_extents.x = cast_point.length() * .5
