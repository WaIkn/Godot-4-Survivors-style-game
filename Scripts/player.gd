extends CharacterBody2D
class_name Player

@export_group("Movement")
@export var speed := 150.0
@export var max_dash_range := 300.0
@export var min_dash_range := 50.0
@export var dash_cooldown := 5.0

@export_group("Weapon")
@export var base_attack_speed := 10.0
@export var number_of_projectile := 1
@export var projectile_spawn_distance := 20.0

@onready var experience_component = $ExperienceComponent as ExperienceComponent

var can_attack := true
var can_dash := true
var is_dead := false

var PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")
@onready var health_component := $Health as Health

func  _physics_process(_delta):
	if is_dead:
		return
	if Input.is_action_pressed("dash") and can_dash:
		dash()
	var direction = get_direction()
	
	sprite_update()
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


func _on_health_zero_health():
	velocity = Vector2.ZERO
	is_dead = true
	health_component.visible = false
	create_tween().tween_property(self, "modulate:a", 0, 1.5)

func sprite_update():
	if get_local_mouse_position().x >= 0:
		$PlayerSprite.flip_h = false
	else:
		$PlayerSprite.flip_h = true


func dash():
	var end_position := get_local_mouse_position()
	can_dash = false
	%DashResetTimer.start(dash_cooldown)
	%DashResetEffectTimer.start(dash_cooldown*.9)
	if end_position.length() > max_dash_range or end_position.length() < min_dash_range:
		end_position = end_position.normalized()* clampf(end_position.length(),min_dash_range,max_dash_range)
	create_tween().tween_property(self,"position",position + end_position,.2)


func _on_dash_reset_timer_timeout():
	
	can_dash = true





func _on_dash_reset_effect_timer_timeout():
	%DashResetEffect.emitting = true


func _on_hit_box_area_entered(area):
	if area.get_parent() is ExperienceDrop:
		area.get_parent().pick_up()
		experience_component.add_xp(1)


func _on_experience_component_level_up():
	health_component.heal_full()
	number_of_projectile += 2
	speed += 10
	%SuckInArea.get_child(0).shape.radius += 20
