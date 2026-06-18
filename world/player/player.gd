extends Node2D

const BASE_MAX_HEALTH: float = 100.0
const BASE_HEALTH_REGENERATION: float = 12.0

@export var attack_damage: float
@export var health_regeneration: float = BASE_HEALTH_REGENERATION

var max_health: float = BASE_MAX_HEALTH
var health: float = BASE_MAX_HEALTH
var is_attacking: bool = false
var size: int = 516 / 2

@onready var wings: Sprite2D = $Wings
@onready var humanoid: Sprite2D = $Humanoid
@onready var extra_arms: Sprite2D = $ExtraArms
@onready var mouth: Sprite2D = $Mouth
@onready var spikes: Sprite2D = $Spikes


func _ready() -> void:
	health = BASE_MAX_HEALTH


func mutate_humanoid():
	if extra_arms.visible != true:
		position.y = position.y - (size * .3)
	else:
		position.y = position.y - (size * .3) + (size * .09)
	humanoid.visible = true


func mutate_spikes():
	spikes.visible = true


func mutate_mouth():
	mouth.visible = true


func mutate_arms():
	extra_arms.visible = true
	if humanoid.visible != true:
		position.y = position.y - (size * .09)


func mutate_wings():
	wings.visible = true
