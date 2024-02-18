extends CharacterBody2D
class_name Enemy

@onready var player = get_node("../Player") as Player
@onready var health_component := $Health as Health
@onready var HITMARKER_SCENE = preload("res://hitmarker.tscn")

@export var attack_damage := 1.0
@export var attack_speed := 1.0
@export var swing_time := .5
@export var attack_range := 150.0
@export var base_speed := 300

@export var can_get_stagger := true
@export var stagger_time := .25
@export var stagger_immunity_time := 1.0

var can_attack := true
var is_staggered := false


func _physics_process(delta):
	if not is_staggered:
		velocity = (player.position - position).normalized() * base_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	if player_in_attack_range() and can_attack and not is_staggered:
		attack()

func attack():
	%AttackResetTimer.start(1.0/attack_speed)
	can_attack = false
	player.health_component.damage(attack_damage)
		

func dead():
	queue_free()

func player_in_attack_range():
	return player.global_position.distance_to(global_position) <= attack_range and attack_range > 0

func on_death():
	pass

func staggered():
	is_staggered = true
	can_get_stagger = false
	%StaggerTimer.start(stagger_time)
	%StaggerImmunityTimer.start(stagger_immunity_time)

func _on_hit_box_area_entered(area):
	if can_get_stagger:
		staggered()
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
	is_staggered = false

func _on_stagger_immunity_timer_timeout():
	can_get_stagger = true
