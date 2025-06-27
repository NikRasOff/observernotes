extends Control
class_name InteractiveVideoPlayer

signal fullscreen_requested(vid:InteractiveVideoPlayer)

@export var volume_popup_size:Vector2i = Vector2i(50, 200)

@export_group("Tooltips")
@export var fullscreen_tooltip:String
@export var unfullscreen_tooltip:String
@export var play_tooltip:String
@export var pause_tooltip:String
@export var mute_tooltip:String
@export var unmute_tooltip:String

@export_group("Button Textures")
@export var fullscreen_texture:Texture2D
@export var unfullscreen_texture:Texture2D
@export var pause_texture:Texture2D
@export var play_texture:Texture2D
@export var unmuted_texture:Texture2D
@export var muted_texture:Texture2D

@export_group("Components")
@export var loading_screen:Control
@export var overlay:Control
@export var play_button:Button
@export var fullscreen_button:Button
@export var volume_button:Button
@export var volume_popup:PopupPanel
@export var volume_slider:Slider
@export var debug_label:Label
@export var video_playback:VideoPlayback
@export var speed_button:OptionButton
@export var timeline:Slider
@export var timestamp:Label

var overlay_lifetime:float = -1
var volume_lifetime:float = -1

var mouse_under_control:bool = false
var mouse_on_volume:bool = false
var fullscreen:bool = false : set = set_fullscreen
var is_dragging:bool = false
var is_dragging_volume:bool = false
var was_playing:bool = false
var was_playing_console:bool = false
var max_time:float

var still_setup:bool = false

const OVERLAY_MAX_LIFETIME:float = 3
const VOLUME_POPUP_MAX_LIFETIME:float = 1
const MIN_MOUSE_MOVEMENT:float = 5

func _process(delta: float) -> void:
	if overlay_lifetime > 0 and !is_dragging and !is_dragging_volume and !mouse_on_volume:
		overlay_lifetime -= delta
		if overlay_lifetime < 0:
			hide_overlay()
	if volume_lifetime > 0 and !is_dragging_volume and !mouse_on_volume:
		volume_lifetime -= delta
		if volume_lifetime < 0:
			hide_popup()
	if debug_label != null and GameSettings.debug:
		debug_label.text = str(overlay_lifetime)

func _ready() -> void:
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	mouse_entered.connect(func(): mouse_under_control = true)
	mouse_exited.connect(func(): 
		mouse_under_control = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
	LimboConsole.toggled.connect(fix_post_console_confusion)
	
	play_button.pressed.connect(toggle_pause)
	play_button.tooltip_text = play_tooltip
	
	video_playback.video_loaded.connect(after_video_loaded)
	video_playback.frame_changed.connect(_frame_changed)
	
	timeline.drag_started.connect(_on_timeline_drag_started)
	timeline.drag_ended.connect(_on_timeline_drag_ended)
	timeline.value_changed.connect(_on_timeline_fucked_with)
	video_playback.video_ended.connect(_on_video_ended)
	
	volume_button.pressed.connect(toggle_mute)
	volume_button.mouse_entered.connect(show_popup)
	volume_button.mouse_exited.connect(start_volume_countdown)
	
	speed_button.item_selected.connect(_on_speed_button_selected)
	
	volume_popup.mouse_exited.connect(func(): 
		start_volume_countdown()
		mouse_on_volume = false)
	volume_popup.mouse_entered.connect(func(): mouse_on_volume = true)
	
	volume_slider.drag_started.connect(_on_volume_slider_start)
	volume_slider.drag_ended.connect(_on_volume_slider_stop)
	volume_slider.value_changed.connect(change_volume)
	
	GameSettings.playback_settings_changed.connect(update_playback_settings)
	
	video_playback.audio_player.bus = "VideoPlayback"
	overlay_lifetime = INF
	show_overlay()
	fullscreen = fullscreen
	
	await GameSettings.await_loaded()
	if debug_label != null:
		debug_label.visible = GameSettings.debug
		GameSettings.debug_toggled.connect(func(value:bool): debug_label.visible = value)
		update_playback_settings()

func update_playback_settings() -> void:
	set_muted(GameSettings.get_video_muted())
	set_volume(GameSettings.get_video_volume())
	video_playback.set_playback_speed(GameSettings.get_video_speed())
	still_setup = true
	speed_button.select(int(GameSettings.get_video_speed() / 0.25 - 1))
	still_setup = false

func _on_speed_button_selected(idx:int) -> void:
	if still_setup:
		return
	GameSettings.set_video_speed(0.25 * (idx + 1))

func start_volume_countdown() -> void:
	volume_lifetime = VOLUME_POPUP_MAX_LIFETIME

func hide_popup() -> void:
	mouse_on_volume = false
	volume_lifetime = -1
	volume_popup.hide()

func show_popup() -> void:
	var rect_bottom:int = volume_button.global_position.y
	var rect_top:int = rect_bottom - volume_popup_size.y
	var rect_horiz_center:int = volume_button.global_position.x + volume_button.size.x / 2
	var rect_left:int = rect_horiz_center - volume_popup_size.x / 2
	volume_popup.popup(Rect2i(rect_left, rect_top, volume_popup_size.x, volume_popup_size.y))

func toggle_mute() -> void:
	GameSettings.set_video_muted(!GameSettings.get_video_muted())

func set_muted(value:bool) -> void:
	if volume_button == null:
		return
	if value:
		volume_button.icon = muted_texture
		volume_button.tooltip_text = unmute_tooltip
	else:
		volume_button.icon = unmuted_texture
		volume_button.tooltip_text = mute_tooltip

func _on_volume_slider_start() -> void:
	is_dragging_volume = true

func _on_volume_slider_stop(_val) -> void:
	is_dragging_volume = false
	video_playback.audio_player.volume_linear = 1.0
	GameSettings.set_video_volume(volume_slider.value)

func change_volume(value:float) -> void:
	video_playback.audio_player.volume_linear = value

func set_volume(value:float) -> void:
	volume_slider.value = value

func set_fullscreen(value:bool) -> void:
	fullscreen = value
	if fullscreen_button == null:
		return
	fullscreen_button.icon = unfullscreen_texture if value else fullscreen_texture
	fullscreen_button.tooltip_text = unfullscreen_tooltip if value else fullscreen_tooltip

func assign_video(video_path:String) -> void:
	if !FileAccess.file_exists(video_path):
		LimboConsole.error(video_path + " does not exist!")
		return
	video_playback.set_video_path(video_path)
	timeline.value = 0
	loading_screen.show()

func after_video_loaded() -> void:
	if video_playback.is_open():
		loading_screen.hide()
		timeline.max_value = video_playback.get_video_frame_count() - 1
		timestamp.text = GoodStuff.get_double_timestamp(timeline.max_value / video_playback.get_video_framerate(), 0)

func show_overlay() -> void:
	overlay.show()
	if overlay_lifetime < OVERLAY_MAX_LIFETIME:
		overlay_lifetime = OVERLAY_MAX_LIFETIME
	if mouse_under_control:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_overlay() -> void:
	hide_popup()
	overlay.hide()
	if mouse_under_control:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func fix_post_console_confusion(v:bool) -> void:
	if v:
		was_playing_console = video_playback.is_playing
	if !was_playing_console:
		video_playback.pause()

func force_pause() -> void:
	video_playback.pause()
	play_button.icon = play_texture
	play_button.tooltip_text = play_tooltip

func force_play() -> void:
	if video_playback.current_frame >= video_playback.get_video_frame_count() - 1:
		video_playback.seek_frame(0)
	video_playback.play()
	play_button.icon = pause_texture
	play_button.tooltip_text = pause_tooltip

func toggle_pause() -> void:
	ProgramStatus.set_focused_video_player(self)
	overlay_lifetime = OVERLAY_MAX_LIFETIME
	show_overlay()
	if !video_playback.is_open():
		return
	if video_playback.is_playing:
		force_pause()
	else:
		force_play()
	
	play_button.release_focus()

func _gui_input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		overlay_lifetime = OVERLAY_MAX_LIFETIME
		if event.relative.length() >= MIN_MOUSE_MOVEMENT:
			show_overlay()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_pause()

func _unhandled_input(event: InputEvent) -> void:
	if ProgramStatus.focused_video_player != self:
		return
	if !is_visible_in_tree():
		ProgramStatus.set_focused_video_player(null)
		return
	if event.is_action_released("pause_video"):
		toggle_pause()
	elif event.is_action_released("toggle_fullscreen"):
		get_viewport().set_input_as_handled()
		_on_fullscreen_pressed()
	elif event.is_action_released("forward5"):
		forward_seconds(5)
	elif event.is_action_released("back5"):
		back_seconds(5)
	elif event.is_action_released("forward10"):
		forward_seconds(10)
	elif event.is_action_released("back10"):
		back_seconds(10)
	elif event.is_action_released("forward_frame"):
		video_playback.seek_frame(min(video_playback.get_video_frame_count(), video_playback.current_frame + 1))
	elif event.is_action_released("back_frame"):
		video_playback.seek_frame(max(0, video_playback.current_frame - 1))
	elif event.is_action_pressed("mute"):
		toggle_mute()
	elif event.is_action_released("volume_up"):
		GameSettings.set_video_volume(min(1.0, volume_slider.value + 0.1))
	elif event.is_action_released("volume_down"):
		GameSettings.set_video_volume(max(0.0, volume_slider.value - 0.1))

func forward_seconds(sec:float) -> void:
	show_overlay()
	video_playback.seek_frame(min(video_playback.get_video_frame_count(), video_playback.current_frame + int(sec * video_playback.get_video_framerate())))

func back_seconds(sec:float) -> void:
	show_overlay()
	video_playback.seek_frame(max(0, video_playback.current_frame - int(sec * video_playback.get_video_framerate())))

func _on_video_ended() -> void:
	Beeper.beep(0.9)
	LimboConsole.info("Video has ended")
	play_button.icon = play_texture
	play_button.tooltip_text = play_tooltip
	overlay_lifetime = INF
	show_overlay()

func _frame_changed(value:int) -> void:
	timeline.value = value
	timestamp.text = GoodStuff.get_double_timestamp(timeline.max_value / video_playback.get_video_framerate(), timeline.value / video_playback.get_video_framerate())

func _on_timeline_fucked_with(_value:float) -> void:
	if is_dragging:
		video_playback.seek_frame(timeline.value as int)

func _on_timeline_drag_started() -> void:
	is_dragging = true
	was_playing = video_playback.is_playing
	video_playback.pause()

func _on_timeline_drag_ended(_value: bool) -> void:
	is_dragging = false
	if was_playing:
		video_playback.play()

func _on_fullscreen_pressed() -> void:
	was_playing = video_playback.is_playing
	force_pause()
	overlay_lifetime = INF
	show_overlay()
	fullscreen_requested.emit(self)
	fullscreen_button.release_focus()
