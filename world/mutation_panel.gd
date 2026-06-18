extends TextureRect

@export var upgrade_name: String

@onready var name_label: Label = $MarginContainer/HBoxContainer/NameLabel
@onready var purchase_button: Button = $MarginContainer/HBoxContainer/PurchaseButton

func _ready() -> void:
	name_label.text = upgrade_name

func update_price(new_price: String) -> void:
	purchase_button.text = new_price + "  "
