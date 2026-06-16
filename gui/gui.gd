extends CanvasLayer

@export var first_screen_path: String
@export_range(0.0, 5.0, 0.05) var fade_duration := 0.35

var current_screen_state: ScreenState
var _is_changing := false

@onready var _screen_root: Control = $ScreenRoot
@onready var _fade_rect: ColorRect = $FadeRect


func _ready() -> void:
	# Start fully black so the first screen fades in from black.
	_fade_rect.visible = true
	_fade_rect.modulate.a = 1.0

	if first_screen_path == null:
		push_warning("GUI has no first_screen_scene assigned.")
		return

	await change_screen(first_screen_path)


func change_screen(next_scene_path: String) -> void:
	if _is_changing or next_scene_path == null:
		return

	_is_changing = true

	# Fade out the current screen, if one exists.
	if current_screen_state != null:
		current_screen_state.exit()
		await _fade_to(1.0)
		current_screen_state.queue_free()
		current_screen_state = null

	var next_scene := load(next_scene_path) as PackedScene
	
	if next_scene != null:
		var instance := next_scene.instantiate()
		
		if not instance is ScreenState:
			push_error("Screen scene must have a root node with the ScreenState script attached: %s" % next_scene.resource_path)
			instance.queue_free()
			_is_changing = false
			return

		current_screen_state = instance as ScreenState
		_screen_root.add_child(current_screen_state)
		current_screen_state.screen_change_requested.connect(_on_screen_change_requested)

		# Fade in, then let the state begin its own timer/input logic.
		await _fade_to(0.0)
		current_screen_state.enter()

		_is_changing = false


func _on_screen_change_requested(next_scene_path: String) -> void:
	call_deferred("change_screen", next_scene_path)
	#await change_screen(next_scene_path)


#func _build_runtime_nodes() -> void:
	#_screen_root = Control.new()
	#_screen_root.name = "ScreenRoot"
	#add_child(_screen_root)
	#_screen_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	#_screen_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
#
	#_fade_rect = ColorRect.new()
	#_fade_rect.name = "FadeRect"
	#_fade_rect.color = Color.BLACK
	#_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#add_child(_fade_rect)
	#_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)


func _fade_to(alpha: float) -> void:
	_fade_rect.visible = true

	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", alpha, fade_duration)
	await tween.finished

	if is_zero_approx(alpha):
		_fade_rect.visible = false
