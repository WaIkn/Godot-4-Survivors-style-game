extends ProgressBar
class_name Health

@export var max_health := 100.0
@onready var health : float

signal zero_health
signal health_change
signal health_damaged
signal health_healed

func _ready():
	health = max_health
	max_value = max_health
	value = health

func damage(amount):
	health -= amount
	health_change.emit()
	health_damaged.emit()
	if health <= 0:
		zero_health.emit()

func heal(amount):
	health += amount
	health_change.emit()
	if health > max_health:
		health = max_health

func set_health_bar_visible(_visible : bool):
	visible = _visible

func _on_health_change():
	value = health
