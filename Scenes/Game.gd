extends Node


@export var generating: bool
@export var enemies_limit_ramp := 10.0
@export var max_spawn_distance := 800.0
@export var min_spawn_distance := 600.0
@onready var ENEMY_SCENE := preload("res://Scenes/enemy.tscn")
@onready var enemies := get_node("Enemies")
@onready var player = get_node("Player") as Player
@onready var DEAD_UI_SCENE := preload("res://dead_ui.tscn")

var dead_ui : DeadUI

var enemies_can_spawn
var enemies_limit := 10

func _ready():
	randomize()
	enemies_can_spawn = true
	%EnemySpawnTimer.wait_time = enemies_limit_ramp

func _physics_process(_delta):
	if enemies_can_spawn and enemies.get_children().size() < enemies_limit:
		spawn_enemy(get_spawn_position())

func _process(_delta):
	if player.is_dead and Input.is_action_just_pressed("basic attack"):
		get_tree().reload_current_scene()

func spawn_enemy(position: Vector2):
	var enemy = ENEMY_SCENE.instantiate()
	enemy.position = position
	enemies.add_child(enemy)

func get_spawn_position():
	var angle = randf_range(-PI ,PI)
	var distance = randf_range(min_spawn_distance, max_spawn_distance)
	return $Player.global_position + Vector2(cos(angle) * distance, sin(angle) * distance)


func _on_enemy_spawn_timer_timeout():
	enemies_limit = ceili(enemies_limit * 1.1)


func _on_health_zero_health():
	
	if dead_ui == null:
		dead_ui = DEAD_UI_SCENE.instantiate()
		dead_ui.global_position = player.global_position - dead_ui.size/2
		add_child(dead_ui)
		dead_ui.fade_in(3)
		
