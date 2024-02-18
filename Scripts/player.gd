extends CharacterBody2D
class_name Player

@export_group("Movement")
@export var speed := 600.0

@export_group("Weapon")
@export var base_attack_speed := 4.0

var can_attack := true

var PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")
@onready var health_component := $Health as Health

func  _physics_process(_delta):
	var direction = get_direction()
	velocity = direction * speed
	move_and_slide()

	rotate_projectile_spawn_point()
	if Input.is_action_pressed("basic attack") and can_attack:
		basic_attack()
		%AttackResetTimer.start(1.0/base_attack_speed)
		can_attack = false

func get_direction():
	return  Input.get_vector("left","right","up","down")

func rotate_projectile_spawn_point():
	$Pivot.look_at(get_global_mouse_position())
	

func  basic_attack():
	var projectile = PROJECTILE_SCENE.instantiate() as Projectile
	projectile.global_position = %ProjectileSpawnPoint.global_position
	projectile.global_rotation = %ProjectileSpawnPoint.global_rotation
	projectile.set_friendly(true)
	get_tree().root.add_child(projectile, true)
	%AttackResetTimer.start(base_attack_speed)

func _on_attack_reset_timer_timeout():
	can_attack = true
