extends Node
class_name ExperienceComponent

@onready var level := 0
@onready var experience := 0

signal level_up

func add_xp(amount:int):
	var temp_experience = experience + amount
	if temp_experience >= Experience.experience_per_level[level]:
		temp_experience = temp_experience - Experience.experience_per_level[level]
		level += 1
		level_up.emit()
	experience = temp_experience
	


