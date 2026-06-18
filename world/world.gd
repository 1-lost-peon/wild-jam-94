extends ScreenState

@export var upgrades: Upgrade
@export var upgrade_price: int
@export var mutation_price: int
@export var list_of_upgrades: Dictionary[Upgrade, TextureRect]
@export var list_of_mutations: Dictionary[Mutation, TextureRect]
@export var destruction_points: int = 0

enum Upgrade {
	BIGGER_MUSCLES,
	TOUGHER_SKIN,
	FASTER_RECOVERY,
	SHARPER_INSTINCTS,
}

enum Mutation {
	HUMANOID,
	WINGS,
	SPIKES,
	EXTRA_ARMS,
	MOUTH
}

const PRICE_INCREASE: float = 1.5
const BIGGER_MUSCLES_MODIFIER: float = 1.25
const TOUGHER_SKIN_MODIFIER: float = 0.75
const FASTER_RECOVERY_MODIFIER: float = 3
const SHARPER_INSTINCTS_MODIFIER: float = 0.75

@onready var city: Control = $City
@onready var player: Node2D = $Player
@onready var turn_timer: Timer = %TurnTimer
@onready var attack_rest_button: Button = %AttackRestButton
@onready var bigger_muscles: TextureRect = %BiggerMuscles
@onready var tougher_skin: TextureRect = %TougherSkin
@onready var faster_recovery: TextureRect = %FasterRecovery
@onready var sharper_instincts: TextureRect = %SharperInstincts
@onready var destruction_points_amount: Label = %DestructionPointsAmount
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var button_player: AudioStreamPlayer = $ButtonPlayer
@onready var toggle_player: AudioStreamPlayer = $TogglePlayer

# TODO: I should create functions for updating the different parts of UI (i.e. update_destruction_points(1))
var health_bar: ProgressBar
var city_destroyed_amount: Label
var is_game_over: bool = false
var player_lost: bool = true
var lose_scene_path: String = "res://gui/screens/lose_screen.tscn"
var win_scene_path: String = "res://gui/screens/win_screen.tscn"
var turn_counter: int = 3
var is_humanoid: bool = false


func _ready() -> void:
	update_destruction_points(0)
	update_player_health(player.max_health)
	
	for upgrade_type in list_of_upgrades:
		list_of_upgrades[upgrade_type].purchase_button.pressed.connect(_on_upgrade_purchased.bind(upgrade_type))
		list_of_upgrades[upgrade_type].update_price(str(upgrade_price))
	
	for mutation_type in list_of_mutations:
		list_of_mutations[mutation_type].purchase_button.pressed.connect(_on_mutation_purchased.bind(mutation_type))
		list_of_mutations[mutation_type].update_price(str(mutation_price))


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


func update_city_health(new_amount: float) -> void:
	city.health = new_amount
	if city.health <= 0:
		city.health = 0
	if city.health >= city.max_health:
		city.health = city.max_health
	
	city.value = ((100 - city.health))


func _on_upgrade_purchased(upgrade: int) -> void:
	button_player.play()
	update_destruction_points(destruction_points - upgrade_price)
	
	upgrade_price = upgrade_price * PRICE_INCREASE
	
	for upgrade_type in list_of_upgrades:
		list_of_upgrades[upgrade_type].update_price(str(int(upgrade_price)))
		 
	
	match upgrade:
		Upgrade.BIGGER_MUSCLES:
			player.attack_damage = player.attack_damage * BIGGER_MUSCLES_MODIFIER
			list_of_upgrades[Upgrade.BIGGER_MUSCLES].increase_upgrade_level()
		Upgrade.TOUGHER_SKIN:
			city.attack_damage = city.attack_damage * TOUGHER_SKIN_MODIFIER
			list_of_upgrades[Upgrade.TOUGHER_SKIN].increase_upgrade_level()
		Upgrade.FASTER_RECOVERY:
			player.health_regeneration = player.health_regeneration * FASTER_RECOVERY_MODIFIER
			list_of_upgrades[Upgrade.FASTER_RECOVERY].increase_upgrade_level()
		Upgrade.SHARPER_INSTINCTS:
			city.health_regeneration = city.health_regeneration * SHARPER_INSTINCTS_MODIFIER
			list_of_upgrades[Upgrade.SHARPER_INSTINCTS].increase_upgrade_level()


func _on_mutation_purchased(mutation: int) -> void:
	button_player.play()
	update_destruction_points(destruction_points - mutation_price)
	
	mutation_price = mutation_price * PRICE_INCREASE
	
	for mutation_type in list_of_mutations:
		list_of_mutations[mutation_type].update_price(str(int(mutation_price)))
	
	match mutation:
		Mutation.EXTRA_ARMS: # Double Player Damage
			player.attack_damage = player.attack_damage * 2
			player.mutate_arms()
			list_of_mutations[Mutation.EXTRA_ARMS].visible = false
		Mutation.HUMANOID: # Blend in with Humans, delay damage for 3 seconds
			is_humanoid = true
			player.mutate_humanoid()
			list_of_mutations[Mutation.HUMANOID].visible = false
		Mutation.MOUTH: # Double Damage
			player.attack_damage = player.attack_damage * 2
			player.mutate_mouth()
			list_of_mutations[Mutation.MOUTH].visible = false
		Mutation.WINGS: # Increase damage speeds
			player.attack_damage = player.attack_damage * 1.15
			player.mutate_wings()
			list_of_mutations[Mutation.WINGS].visible = false
		Mutation.SPIKES: # Reduce damage by half
			city.health_regeneration = city.attack_damage / 2
			player.mutate_spikes()
			list_of_mutations[Mutation.SPIKES].visible = false

func _on_lose_timer_timeout() -> void:
	go_to()


func _on_turn_timer_timeout() -> void:
	if player.health == 0:
		is_game_over = true
	
	if city.health == 0:
		is_game_over = true
		player_lost = false
	
	if is_game_over:
		if player_lost:
			next_screen_path = lose_scene_path
		else:
			next_screen_path = win_scene_path
		go_to()
	
	if destruction_points < upgrade_price:
		for upgrade_type in list_of_upgrades:
			list_of_upgrades[upgrade_type].toggle_disable(true)
	else:
		for upgrade_type in list_of_upgrades:
			list_of_upgrades[upgrade_type].toggle_disable(false)



	# TODO: Randomize the amounts
	if player.is_attacking:
		update_city_health(city.health - player.attack_damage)
		update_destruction_points(destruction_points + 1)
		
		if turn_counter == 3:
			update_player_health(player.health - city.attack_damage)
		else:
			turn_counter += 1
	else:
		update_player_health(player.health + player.health_regeneration)
		update_city_health(city.health + city.health_regeneration)
		print(turn_counter)
		if is_humanoid and turn_counter == 3:
			turn_counter = 0


func _on_attack_rest_button_toggled(toggled_on: bool) -> void:
	if is_game_over:
		return
	
	toggle_player.play()
	
	player.is_attacking = toggled_on
	
	if player.is_attacking:
		attack_rest_button.text = "Attacking - Click to Rest"
		attack_rest_button.tooltip_text = "Attacking damages the city, earns points based on destruction %, and drains health."
	else:
		attack_rest_button.text = "Resting - Click to Attack"
		attack_rest_button.tooltip_text = "Resting restores health, but the city slowly recovers."
