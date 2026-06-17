extends ScreenState

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("scroll")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	go_to()
