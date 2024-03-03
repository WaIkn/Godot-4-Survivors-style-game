extends CharacterBody2D
class_name Enemy

@onready var player = get_node("../../Player") as Player
@onready var health_component := $Health as Health
@onready var HITMARKER_SCENE = preload("res://hitmarker.tscn")
@onready var BEAM_SCENE = preload("res://Beam.tscn")

@export var attack_damage := 10.0
@export var attack_speed := .5
@export var swing_time := .65
@export var attack_range := 150.0
@export var base_speed := 75


@export var can_get_stagger := true
@export var stagger_time := .25
@export var stagger_immunity_time := 1.0


var attacking := false
var can_attack := true
var staggered := false

var _beam : Beam

func _ready():
	pass

func _physics_process(delta):
	if not staggered and not attacking and not player_in_attack_range():
		velocity = (player.position - position).normalized() * base_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	if player_in_attack_range() and can_attack and not staggered:
		attack()

func attack():
	%AttackResetTimer.start(1.0/attack_speed)
	$Timers/AttackSwingTimer.start(swing_time)
	attacking = true
	can_attack = false
	_beam = create_beam()
	
		

func dead():
	queue_free()

func player_in_attack_range():
	return player.global_position.distance_to(global_position) <= attack_range and attack_range > 0

func on_death():
	pass

func stagger():
	staggered = true
	can_get_stagger = false
	%StaggerTimer.start(stagger_time)
	%StaggerImmunityTimer.start(stagger_immunity_time)

func _on_hit_box_area_entered(area):
	if can_get_stagger:
		stagger()
	if area is Projectile:
		health_component.damage(area.damage)
	var hitmarker := HITMARKER_SCENE.instantiate()
	hitmarker.position = area.position
	add_child(hitmarker)

func _on_health_zero_health():
	dead()
	on_death()

func _on_attack_reset_timer_timeout():
	can_attack = true

func _on_stagger_timer_timeout():
	staggered = false

func _on_stagger_immunity_timer_timeout():
	can_get_stagger = true

func _on_attack_swing_timer_timeout():
	$Timers/BeamTimer.start(Beam.get_beam_time())
	_beam.fire()
	if _beam.is_colliding():
		player.health_component.damage(attack_damage)
	

func create_beam() -> Beam:
	var beam := BEAM_SCENE.instantiate() as Beam
	beam.target_position.x = attack_range
	add_child(beam,true)
	beam.look_at(player.global_position)
	beam.force_target_update()
	return beam


func _on_beam_timer_timeout():
	attacking = false
	_beam.dead()

