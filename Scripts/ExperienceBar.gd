extends ProgressBar
class_name ExperienceBar

@onready var experience_component = get_parent().get_node("ExperienceComponent") as ExperienceComponent


func _process(_delta):
	value = experience_component.experience / (Experience.experience_per_level[experience_component.level] * 1.0) * 100
