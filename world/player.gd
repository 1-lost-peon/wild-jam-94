extends Node2D

const BASE_MAX_HEALTH: float = 100.0
const BASE_HEALTH_REGENERATION: float = 12.0

var max_health: float = BASE_MAX_HEALTH
var health: float = BASE_MAX_HEALTH
var health_regeneration: float = BASE_HEALTH_REGENERATION
var is_attacking: bool = false

func _ready() -> void:
	health = BASE_MAX_HEALTH
