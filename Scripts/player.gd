extends CharacterBody2D
class_name Player

@export_group("Movement")
@export var speed := 150.0

@export_group("Weapon")
@export var base_attack_speed := 10.0
@export var number_of_projectile := 1
@export var projectile_spawn_distance := 20.0

var can_attack := true

var PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")
@onready var health_component := $Health as Health

func  _physics_process(_delta):
	var direction = get_direction()

	rotate_projectile_spawn_point()
	if Input.is_action_pressed("basic attack") and can_attack:
		basic_attack()
		%AttackResetTimer.start(1.0/base_attack_speed)
		can_attack = false
		
	velocity = direction * speed
	move_and_slide()

func get_direction():
	return  Input.get_vector("left","right","up","down")

func rotate_projectile_spawn_point():
	$Pivot.look_at(get_global_mouse_position())
	

func  basic_attack():
	var angle = clamp(180.0/number_of_projectile, .5, 12.0)
	var position_offsets = Projectile.get_position_offsets($Pivot, projectile_spawn_distance, number_of_projectile, angle)
	var rotation_offsets = Projectile.get_rotation_offsets($Pivot.global_rotation_degrees, number_of_projectile, angle)
	var i = 0
	while i < number_of_projectile:
		var projectile = PROJECTILE_SCENE.instantiate() as Projectile
		projectile.global_position = position_offsets[i] + $Pivot.global_position
		projectile.global_rotation_degrees = rotation_offsets[i] 
		projectile.shooter = self
		projectile.set_friendly(true)
		get_tree().root.add_child(projectile, true)
		i += 1
	%AttackResetTimer.start(base_attack_speed)

func _on_attack_reset_timer_timeout():
	can_attack = true


func _on_health_health_damaged():
	var tween := create_tween()
	tween.tween_property($PlayerSprite,"self_modulate",Color.CRIMSON,.1)
	tween.tween_property($PlayerSprite,"self_modulate",Color.WHITE,.05)
