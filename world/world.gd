extends ScreenState

@export var upgrades: Upgrade

const BASE_CITY_DAMAGE_PER_TICK := 0.001
const BASE_CITY_RECOVERY_PER_TICK := 0.003
const BASE_POINT_REWARD_POWER := 2

@onready var amount: Label = $Amount
@onready var pay_timer: Timer = $PayTimer
@onready var city: Node2D = $City
@onready var player: Node2D = $Player
@onready var turn_timer: Timer = %TurnTimer
@onready var attack_rest_button: Button = %AttackRestButton


var destruction_points: int = 0
var city_damage_per_tick := BASE_CITY_DAMAGE_PER_TICK
var city_recovery_per_tick := BASE_CITY_RECOVERY_PER_TICK
var point_reward_power := BASE_POINT_REWARD_POWER
var syncing_attack_button := false

var health_bar: ProgressBar
var city_destroyed_amount: Label

var repeatable_upgrades := {
	"BiggerMuscles": {
		"button_path": "Panel/VBoxContainer2/VBoxContainer/BiggerMuscles",
		"display_name": "Bigger Muscles",
		"description": "Builds stronger muscles so each attack damages the city more.",
		"base_cost": 5,
		"cost_multiplier": 1.35,
		"damage_bonus": 0.0008,
		"point_power_bonus": 1,
		"defense_bonus": 0.0,
		"rest_bonus": 0.0,
		"max_health_bonus": 0.0,
		"purchased": 0,
	},
	"GrowthHormones": {
		"button_path": "Panel/VBoxContainer2/VBoxContainer/GrowthHormones",
		"display_name": "Growth Hormones",
		"description": "Makes the mutant bigger, increasing city damage and max health.",
		"base_cost": 12,
		"cost_multiplier": 1.4,
		"damage_bonus": 0.0010,
		"point_power_bonus": 1,
		"defense_bonus": 0.0,
		"rest_bonus": 0.0,
		"max_health_bonus": 5.0,
		"purchased": 0,
	},
	"SharperClaws": {
		"button_path": "Panel/VBoxContainer2/VBoxContainer/SharperClaws",
		"display_name": "Sharper Claws",
		"description": "Cuts through buildings faster, greatly increasing city damage.",
		"base_cost": 20,
		"cost_multiplier": 1.45,
		"damage_bonus": 0.0014,
		"point_power_bonus": 1,
		"defense_bonus": 0.0,
		"rest_bonus": 0.0,
		"max_health_bonus": 0.0,
		"purchased": 0,
	},
	"ToughSkin": {
		"button_path": "Panel/VBoxContainer2/VBoxContainer/ToughSkin",
		"display_name": "Tough Skin",
		"description": "Reduces damage taken while attacking and increases max health.",
		"base_cost": 35,
		"cost_multiplier": 1.5,
		"damage_bonus": 0.0,
		"point_power_bonus": 0,
		"defense_bonus": 1.0,
		"rest_bonus": 0.0,
		"max_health_bonus": 10.0,
		"purchased": 0,
	},
	"FasterReflexes": {
		"button_path": "Panel/VBoxContainer2/VBoxContainer/FasterReflexes",
		"display_name": "Faster Reflexes",
		"description": "Attacks faster, increasing city damage and slightly reducing damage taken.",
		"base_cost": 55,
		"cost_multiplier": 1.55,
		"damage_bonus": 0.0011,
		"point_power_bonus": 2,
		"defense_bonus": 0.5,
		"rest_bonus": 0.0,
		"max_health_bonus": 0.0,
		"purchased": 0,
	},
	"ImprovedInstincts": {
		"button_path": "Panel/VBoxContainer2/VBoxContainer/ImprovedInstincts",
		"display_name": "Improved Instincts",
		"description": "Finds weak city targets and recovers better while resting.",
		"base_cost": 80,
		"cost_multiplier": 1.6,
		"damage_bonus": 0.0009,
		"point_power_bonus": 3,
		"defense_bonus": 0.0,
		"rest_bonus": 1.5,
		"max_health_bonus": 0.0,
		"purchased": 0,
	},
}

var one_time_upgrades := {
	"ExtraArms": {
		"button_path": "Panel/VBoxContainer2/GridContainer/ExtraArms",
		"display_name": "Extra Arms",
		"description": "Grows another pair of arms and permanently increases attack damage.",
		"cost": 5,
		"damage_bonus": 0.0025,
		"point_power_bonus": 3,
		"defense_bonus": 0.0,
		"rest_bonus": 0.0,
		"max_health_bonus": 10.0,
		"purchased": false,
	},
}

var disabled_one_time_buttons := {
	"NightVision": {
		"button_path": "Panel/VBoxContainer2/GridContainer/NightVision",
		"display_name": "Night Vision",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
	"VenomGlands": {
		"button_path": "Panel/VBoxContainer2/GridContainer/VenomGlands",
		"display_name": "Venom Glands",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
	"ExtraEyes": {
		"button_path": "Panel/VBoxContainer2/GridContainer/ExtraEyes",
		"display_name": "Extra Eyes",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
	"BoneSpikes": {
		"button_path": "Panel/VBoxContainer2/GridContainer/BoneSpikes",
		"display_name": "Bone Spikes",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
	"Wings": {
		"button_path": "Panel/VBoxContainer2/GridContainer/Wings",
		"display_name": "Wings",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
	"LaserEyes": {
		"button_path": "Panel/VBoxContainer2/GridContainer/LaserEyes",
		"display_name": "Laser Eyes",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
	"AcidBlood": {
		"button_path": "Panel/VBoxContainer2/GridContainer/AcidBlood",
		"display_name": "Acid Blood",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
	"ShadowClones": {
		"button_path": "Panel/VBoxContainer2/GridContainer/ShadowClones",
		"display_name": "Shadow Clones",
		"description": "One-time upgrade placeholder. Not wired yet.",
	},
}

func _ready() -> void:
	destruction_points = 0
	#_setup_repeatable_upgrade_buttons()
	#_setup_one_time_upgrade_buttons()
	#_setup_disabled_one_time_buttons()
	#_set_attack_mode(false)
	#_update_ui()

#func _on_pay_timer_timeout() -> void:
	#var current_progress := _get_city_destruction_progress()
#
	#if is_attacking:
		#var new_progress = clamp(current_progress + city_damage_per_tick, 0.0, 1.0)
		#_set_city_destruction_progress(new_progress)
		#destruction_points += _calculate_points_awarded(new_progress)
		#health = max(health - health_loss_per_attack_tick, 0.0)
#
		#if health <= 0.0:
			#_set_attack_mode(false)
	#else:
		#_set_city_destruction_progress(clamp(current_progress - city_recovery_per_tick, 0.0, 1.0))
		#health = min(health + health_recovery_per_rest_tick, max_health)
#
	#_update_ui()


#func _on_attack_rest_toggled(button_pressed: bool) -> void:
	#if syncing_attack_button:
		#return
#
	#if button_pressed and health <= 0.0:
		#_set_attack_mode(false)
		#return
#
	#_set_attack_mode(button_pressed)


func _setup_repeatable_upgrade_buttons() -> void:
	for upgrade_id in repeatable_upgrades.keys():
		var upgrade: Dictionary = repeatable_upgrades[upgrade_id]
		var button := get_node_or_null(upgrade["button_path"]) as Button
		if button == null:
			push_warning("Missing repeatable upgrade button: %s" % upgrade_id)
			continue

		_prepare_upgrade_button(button, upgrade["display_name"], upgrade["description"])

		var pressed_callable := Callable(self, "_on_repeatable_upgrade_pressed").bind(upgrade_id)
		if not button.pressed.is_connected(pressed_callable):
			button.pressed.connect(pressed_callable)

func _setup_one_time_upgrade_buttons() -> void:
	for upgrade_id in one_time_upgrades.keys():
		var upgrade: Dictionary = one_time_upgrades[upgrade_id]
		var button := get_node_or_null(upgrade["button_path"]) as Button
		if button == null:
			push_warning("Missing one-time upgrade button: %s" % upgrade_id)
			continue

		_prepare_upgrade_button(button, upgrade["display_name"], upgrade["description"])

		var pressed_callable := Callable(self, "_on_one_time_upgrade_pressed").bind(upgrade_id)
		if not button.pressed.is_connected(pressed_callable):
			button.pressed.connect(pressed_callable)

func _setup_disabled_one_time_buttons() -> void:
	for upgrade_id in disabled_one_time_buttons.keys():
		var upgrade: Dictionary = disabled_one_time_buttons[upgrade_id]
		var button := get_node_or_null(upgrade["button_path"]) as Button
		if button == null:
			continue

		_prepare_upgrade_button(button, upgrade["display_name"], upgrade["description"])
		button.disabled = true
		button.tooltip_text = "%s\n\nThis one-time upgrade is not implemented yet." % upgrade["description"]
		_set_upgrade_labels(button, "", "Locked", false)

func _prepare_upgrade_button(button: Button, display_name: String, description: String) -> void:
	button.text = display_name
	button.tooltip_text = description
	button.custom_minimum_size = Vector2(180, 48)
	_get_or_create_upgrade_label(button, "UpgradeCountLabel", -70.0, -8.0)
	_get_or_create_upgrade_label(button, "UpgradePriceLabel", -70.0, -8.0)

func _get_or_create_upgrade_label(button: Button, label_name: String, left_offset: float, right_offset: float) -> Label:
	var label := button.get_node_or_null(label_name) as Label
	if label == null and label_name == "UpgradeCountLabel":
		label = button.get_node_or_null("Amount") as Label
		if label != null:
			label.name = label_name

	if label == null:
		label = Label.new()
		label.name = label_name
		button.add_child(label)

	label.layout_mode = 1
	label.anchor_left = 1.0
	label.anchor_top = 0.0
	label.anchor_right = 1.0
	label.anchor_bottom = 0.0
	label.offset_left = left_offset
	label.offset_right = right_offset
	label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if label_name == "UpgradeCountLabel":
		label.offset_top = 2.0
		label.offset_bottom = 22.0
	else:
		label.offset_top = 24.0
		label.offset_bottom = 44.0

	return label

func _set_upgrade_labels(button: Button, count_text: String, price_text: String, show_count: bool = true) -> void:
	var count_label := _get_or_create_upgrade_label(button, "UpgradeCountLabel", -70.0, -8.0)
	var price_label := _get_or_create_upgrade_label(button, "UpgradePriceLabel", -70.0, -8.0)
	count_label.visible = show_count
	count_label.text = count_text
	price_label.visible = true
	price_label.text = price_text

func _on_repeatable_upgrade_pressed(upgrade_id: String) -> void:
	var cost := _get_repeatable_upgrade_cost(upgrade_id)
	if destruction_points < cost:
		_update_ui()
		return

	destruction_points -= cost
	var upgrade: Dictionary = repeatable_upgrades[upgrade_id]
	upgrade["purchased"] = int(upgrade["purchased"]) + 1
	repeatable_upgrades[upgrade_id] = upgrade
	_update_ui()

func _on_one_time_upgrade_pressed(upgrade_id: String) -> void:
	var upgrade: Dictionary = one_time_upgrades[upgrade_id]
	if bool(upgrade["purchased"]):
		_update_ui()
		return

	var cost := int(upgrade["cost"])
	if destruction_points < cost:
		_update_ui()
		return

	destruction_points -= cost
	upgrade["purchased"] = true
	one_time_upgrades[upgrade_id] = upgrade

	#if upgrade_id == "ExtraArms":
		#arms_1.visible = true

	_update_ui()

func _get_repeatable_upgrade_cost(upgrade_id: String) -> int:
	var upgrade: Dictionary = repeatable_upgrades[upgrade_id]
	return int(ceil(upgrade["base_cost"] * pow(upgrade["cost_multiplier"], upgrade["purchased"])))


func _calculate_points_awarded(city_progress: float) -> int:
	var destroyed_ratio = clamp(city_progress, 0.0, 1.0)
	var destruction_multiplier := 0.15 + pow(destroyed_ratio, 2.0) * 4.85
	return max(1, int(ceil(point_reward_power * destruction_multiplier)))

func _get_city_destruction_progress() -> float:
	if city.material == null:
		return 0.0
	return float(city.material.get_shader_parameter("progress"))

func _set_city_destruction_progress(progress: float) -> void:
	if city.material == null:
		return
	city.material.set_shader_parameter("progress", clamp(progress, 0.0, 1.0))

func _update_ui() -> void:
	amount.text = str(destruction_points)
	#_update_status_ui()
	_update_repeatable_upgrade_buttons()
	_update_one_time_upgrade_buttons()

#func _update_status_ui() -> void:
	#if health_bar != null:
		#health_bar.max_value = max_health
		#health_bar.value = health
#
	#if city_destroyed_amount != null:
		#city_destroyed_amount.text = "%s%%" % int(round(_get_city_destruction_progress() * 100.0))
#
	#_sync_attack_rest_button()

func _update_repeatable_upgrade_buttons() -> void:
	for upgrade_id in repeatable_upgrades.keys():
		var upgrade: Dictionary = repeatable_upgrades[upgrade_id]
		var button := get_node_or_null(upgrade["button_path"]) as Button
		if button == null:
			continue

		var cost := _get_repeatable_upgrade_cost(upgrade_id)
		var purchased_count := int(upgrade["purchased"])
		button.disabled = destruction_points < cost
		button.tooltip_text = _build_repeatable_tooltip(upgrade, purchased_count, cost)
		_set_upgrade_labels(button, "x%s" % purchased_count, "$%s" % cost, true)

func _update_one_time_upgrade_buttons() -> void:
	for upgrade_id in one_time_upgrades.keys():
		var upgrade: Dictionary = one_time_upgrades[upgrade_id]
		var button := get_node_or_null(upgrade["button_path"]) as Button
		if button == null:
			continue

		var purchased := bool(upgrade["purchased"])
		var cost := int(upgrade["cost"])
		button.visible = not purchased
		button.disabled = destruction_points < cost
		button.tooltip_text = _build_one_time_tooltip(upgrade, cost)
		_set_upgrade_labels(button, "", "$%s" % cost, false)

func _build_repeatable_tooltip(upgrade: Dictionary, purchased_count: int, cost: int) -> String:
	var lines := [
		upgrade["description"],
		"",
		"Owned: %s" % purchased_count,
		"Next Cost: %s destruction points" % cost,
		"Effect per upgrade:",
	]
	_append_upgrade_effect_lines(lines, upgrade)
	return _join_lines(lines)

func _build_one_time_tooltip(upgrade: Dictionary, cost: int) -> String:
	var lines := [
		upgrade["description"],
		"",
		"Cost: %s destruction points" % cost,
		"Effect:",
	]
	_append_upgrade_effect_lines(lines, upgrade)
	return _join_lines(lines)

func _append_upgrade_effect_lines(lines: Array, upgrade: Dictionary) -> void:
	var has_effect := false
	if float(upgrade.get("damage_bonus", 0.0)) != 0.0:
		lines.append("+%.4f city damage/tick" % float(upgrade["damage_bonus"]))
		has_effect = true
	if int(upgrade.get("point_power_bonus", 0)) != 0:
		lines.append("+%s point reward power" % int(upgrade["point_power_bonus"]))
		has_effect = true
	if float(upgrade.get("defense_bonus", 0.0)) != 0.0:
		lines.append("-%s health lost while attacking" % float(upgrade["defense_bonus"]))
		has_effect = true
	if float(upgrade.get("rest_bonus", 0.0)) != 0.0:
		lines.append("+%s health recovered while resting" % float(upgrade["rest_bonus"]))
		has_effect = true
	if float(upgrade.get("max_health_bonus", 0.0)) != 0.0:
		lines.append("+%s max health" % float(upgrade["max_health_bonus"]))
		has_effect = true
	if not has_effect:
		lines.append("No effect yet.")

func _join_lines(lines: Array) -> String:
	var text := ""
	for line_index in range(lines.size()):
		if line_index > 0:
			text += "\n"
		text += str(lines[line_index])
	return text


func _on_lose_timer_timeout() -> void:
	go_to()


func _on_turn_timer_timeout() -> void:
	var current_progress := _get_city_destruction_progress()

	if player.is_attacking:
		var new_progress = clamp(current_progress + city_damage_per_tick, 0.0, 1.0)
		_set_city_destruction_progress(new_progress)
		destruction_points += _calculate_points_awarded(new_progress)
		player.health = max(player.health - city.attack_damage, 0.0)

	else:
		_set_city_destruction_progress(clamp(current_progress - city_recovery_per_tick, 0.0, 1.0))
		player.health = min(player.health + player.health_regeneration, player.max_health)

	_update_ui()


func _on_attack_rest_button_toggled(toggled_on: bool) -> void:
	player.is_attacking = toggled_on
	
	if player.is_attacking:
		attack_rest_button.text = "Attacking - Click to Rest"
		attack_rest_button.tooltip_text = "Attacking damages the city, earns points based on destruction %, and drains health."
	else:
		attack_rest_button.text = "Resting - Click to Attack"
		attack_rest_button.tooltip_text = "Resting restores health, but the city slowly recovers."
