extends Node


@export var generating: bool
@export var enemies_spawn_rate := 5.0
@export var max_spawn_distance := 500.0
@export var min_spawn_distance := 300.0
@onready var ENEMY_SCENE := preload("res://Scenes/enemy.tscn")
@onready var enemies := get_node("Enemies")

var enemies_can_spawn
var enemies_limit := 1

func _ready():
	randomize()
	enemies_can_spawn = true

func _physics_process(delta):
	if enemies_can_spawn and enemies.get_children().size() < enemies_limit:
		spawn_enemy(get_spawn_position())

func spawn_enemy(position: Vector2):
	var enemy = ENEMY_SCENE.instantiate()
	enemy.position = position
	enemies.add_child(enemy)
	%EnemySpawnTimer.start(1.0/enemies_spawn_rate)

func get_spawn_position():
	var angle = randf_range(-PI ,PI)
	var distance = randf_range(min_spawn_distance, max_spawn_distance)
	return $Player.global_position + Vector2(cos(angle) * distance, sin(angle) * distance)


func _on_enemy_spawn_timer_timeout():
	enemies_can_spawn = true
