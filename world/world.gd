extends ScreenState

@export var upgrades: Upgrade
@export var upgrade_price: int
@export var list_of_upgrades: Dictionary[Upgrade, TextureRect]
@export var destruction_points: int = 0

enum Upgrade {
	BIGGER_MUSCLES,
	TOUGHER_SKIN,
	FASTER_RECOVERY,
	SHARPER_INSTINCTS,
}

const PRICE_INCREASE: float = 1.5

@onready var city: Node2D = $City
@onready var player: Node2D = $Player
@onready var turn_timer: Timer = %TurnTimer
@onready var attack_rest_button: Button = %AttackRestButton
@onready var bigger_muscles: TextureRect = %BiggerMuscles
@onready var tougher_skin: TextureRect = %TougherSkin
@onready var faster_recovery: TextureRect = %FasterRecovery
@onready var sharper_instincts: TextureRect = %SharperInstincts
@onready var destruction_points_amount: Label = %DestructionPointsAmount
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
# TODO: I should create functions for updating the different parts of UI (i.e. update_destruction_points(1))
var health_bar: ProgressBar
var city_destroyed_amount: Label


func _ready() -> void:
	update_destruction_points(0)
	
	for upgrade_type in list_of_upgrades:
		list_of_upgrades[upgrade_type].purchase_button.pressed.connect(_on_upgrade_purchased.bind(upgrade_type))
		list_of_upgrades[upgrade_type].update_price(str(upgrade_price))


func update_destruction_points(new_amount: int) -> void:
	destruction_points = new_amount
	destruction_points_amount.text = str(destruction_points)


func update_player_health(new_amount: int) -> void:
	player.health = new_amount
	
	if player.health <= 0:
		player.health = 0
	if player.health >= player.max_health:
		player.health = player.max_health
	
	player_health_bar.value = player.health


func update_city_health(new_amount: int) -> void:
	city.health = new_amount
	
	if city.health <= 0:
		city.health = 0
	if city.health >= city.max_health:
		city.health = city.max_health
	
	city.set_city_destruction_progress((100 - city.health) / 100)


func _on_upgrade_purchased(upgrade: int) -> void:
	update_destruction_points(destruction_points - upgrade_price)
	
	upgrade_price = upgrade_price * PRICE_INCREASE
	
	for upgrade_type in list_of_upgrades:
		list_of_upgrades[upgrade_type].update_price(str(int(upgrade_price)))
	
	match upgrade:
		Upgrade.BIGGER_MUSCLES:
			player.attack_damage = player.attack_damage * 1.05


func _on_lose_timer_timeout() -> void:
	go_to()


func _on_turn_timer_timeout() -> void:
	if destruction_points < upgrade_price:
		for upgrade_type in list_of_upgrades:
			list_of_upgrades[upgrade_type].toggle_disable(true)
	else:
		for upgrade_type in list_of_upgrades:
			list_of_upgrades[upgrade_type].toggle_disable(false)

	# TODO: Randomize the amounts
	if player.is_attacking:
		update_player_health(player.health - city.attack_damage)
		update_destruction_points(destruction_points + 1)
		print(city.health)
		update_city_health(city.health - player.attack_damage)
		
	else:
		update_player_health(player.health + player.health_regeneration)
		update_city_health(city.health + city.health_regeneration)


func _on_attack_rest_button_toggled(toggled_on: bool) -> void:
	player.is_attacking = toggled_on
	
	if player.is_attacking:
		attack_rest_button.text = "Attacking - Click to Rest"
		attack_rest_button.tooltip_text = "Attacking damages the city, earns points based on destruction %, and drains health."
	else:
		attack_rest_button.text = "Resting - Click to Attack"
		attack_rest_button.tooltip_text = "Resting restores health, but the city slowly recovers."
