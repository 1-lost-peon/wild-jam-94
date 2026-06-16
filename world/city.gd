extends Node2D

@export var health: float
@export var attack_damage: float
@export var health_regeneration: float

var max_health: int = 100

@onready var city: Sprite2D = $City


func set_city_destruction_progress(progress: float) -> void:
	if city.material == null:
		return
	city.material.set_shader_parameter("progress", clamp(progress, 0.0, 1.0))
