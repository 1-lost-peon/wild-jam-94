extends TextureRect

@export var upgrade_name: String

@onready var name_label: Label = $MarginContainer/HBoxContainer/NameLabel

func _ready() -> void:
	name_label.text = upgrade_name
