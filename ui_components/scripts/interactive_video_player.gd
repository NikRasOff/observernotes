extends VideoStreamPlayer
class_name InteractiveVideoPlayer

signal fullscreen_requested(vid:String)

@export_group("Tooltips")
@export var fullscreen_tooltip:String
@export var unfullscreen_tooltip:String
@export var play_tooltip:String
@export var pause_tooltip:String

@export_group("Button Textures")
@export var fullscreen_texture:Texture2D
@export var unfullscreen_texture:Texture2D
@export var pause_texture:Texture2D
@export var play_texture:Texture2D

@export_group("Components")
@export var overlay:Control
@export var play_button:Button
@export var fullscreen_button:Button
@export var debug_label:Label

var overlay_lifetime:float = -1

var mouse_under_control:bool = false
var video_paused:bool = true : set = set_video_paused
var fullscreen:bool = false : set = set_fullscreen

const OVERLAY_MAX_LIFETIME:float = 3
const MIN_MOUSE_MOVEMENT:float = 5

func _process(delta: float) -> void:
	if overlay_lifetime > 0:
		overlay_lifetime -= delta
		if overlay_lifetime < 0:
			hide_overlay()
	if debug_label != null and GameSettings.debug:
		debug_label.text = str(overlay_lifetime)

func _ready() -> void:
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	mouse_entered.connect(func(): mouse_under_control = true)
	mouse_exited.connect(func(): 
		mouse_under_control = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
	gui_input.connect(_on_gui_input)
	play_button.pressed.connect(toggle_pause)
	finished.connect(_on_video_ended)
	overlay_lifetime = INF
	show_overlay()
	if !GameSettings.settings_ready:
		await GameSettings.settings_loaded
	if debug_label != null:
		debug_label.visible = GameSettings.debug
		GameSettings.debug_toggled.connect(func(value:bool): debug_label.visible = value)
	fullscreen = fullscreen
	video_paused = video_paused

func set_video_paused(value:bool) -> void:
	video_paused = value
	paused = value
	if !value and !is_playing():
		overlay_lifetime = OVERLAY_MAX_LIFETIME
		play()
	if play_button == null:
		return
	play_button.icon = play_texture if value else pause_texture
	play_button.tooltip_text = play_tooltip if value else pause_tooltip

func set_fullscreen(value:bool) -> void:
	fullscreen = value
	if fullscreen_button == null:
		return
	fullscreen_button.icon = unfullscreen_texture if value else fullscreen_texture
	fullscreen_button.tooltip_text = unfullscreen_tooltip if value else fullscreen_tooltip

func assign_video(path:String) -> void:
	if !FileAccess.file_exists(path):
		LimboConsole.error(path + " does not exist!")
		return
	var video_stream := VideoStreamTheora.new()
	video_stream.file = path
	stream = video_stream

func show_overlay() -> void:
	overlay.show()
	if overlay_lifetime < OVERLAY_MAX_LIFETIME:
		overlay_lifetime = OVERLAY_MAX_LIFETIME
	if mouse_under_control:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_overlay() -> void:
	overlay.hide()
	if mouse_under_control:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func toggle_pause() -> void:
	video_paused = !video_paused
	show_overlay()

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.relative.length() >= MIN_MOUSE_MOVEMENT:
			show_overlay()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_pause()
	elif event.is_action_pressed("pause_video"):
		toggle_pause()

func _on_video_ended() -> void:
	Beeper.beep(0.9)
	video_paused = true
	overlay_lifetime = INF
	show_overlay()

func _on_fullscreen_pressed() -> void:
	stop()
	overlay_lifetime = INF
	video_paused = true
	fullscreen_requested.emit(stream.file)
