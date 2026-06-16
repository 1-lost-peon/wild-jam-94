class_name ScreenState
extends Control

signal screen_change_requested(next_scene_path: String)

@export_range(0.0, 60.0, 0.1) var duration := 2.0
@export var image: Texture2D
#@export var next_screen_scene: PackedScene
@export_file("*.tscn") var next_screen_path: String
@export var auto_advance := true

@onready var texture_rect: TextureRect = get_node_or_null("TextureRect") as TextureRect
@onready var timer: Timer = get_node_or_null("Timer") as Timer

var _has_entered := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	if texture_rect != null and image != null:
		texture_rect.texture = image

	if timer != null:
		timer.stop()
		timer.one_shot = true
		timer.wait_time = max(duration, 0.01)

		var timeout_callable := Callable(self, "_on_timer_timeout")
		if not timer.timeout.is_connected(timeout_callable):
			timer.timeout.connect(timeout_callable)


func enter() -> void:
	_has_entered = true

	if timer != null and auto_advance and next_screen_path != null:
		timer.wait_time = max(duration, 0.01)
		timer.start()


func exit() -> void:
	_has_entered = false

	if timer != null:
		timer.stop()


func go_to(next_scene: String = next_screen_path) -> void:
	if next_scene == null:
		push_warning("ScreenState.go_to() called, but no next scene was assigned.")
		return

	screen_change_requested.emit(next_scene)


func _on_timer_timeout() -> void:
	#go_to()
	call_deferred("go_to")
