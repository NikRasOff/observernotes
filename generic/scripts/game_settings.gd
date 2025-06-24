extends Node

signal settings_loaded
signal settings_changed
signal debug_toggled(value:bool)

@export var fit_resolution:bool = true
@export var ignore_base_width:bool = false
@export var theme_list:Array[CustomTheme]

var game_settings:GameSettingsResource
var settings_ready:bool = false
var screen_resolution:Vector2
var debug:bool = false : set = set_debug, get = get_debug

func _ready() -> void:
	call_deferred("load_settings")
	if !fit_resolution:
		#LimboConsole.info("Current resolution: " + str(get_tree().root.size))
		return
	fix_window_size(true)
	LimboConsole.register_command(toggle_debug, "debug", "Toggles debug functionality")
	LimboConsole.register_command(set_ambient_hum, "hum")

func await_loaded() -> void:
	if settings_ready:
		return
	await settings_loaded

func toggle_debug() -> void:
	debug = !debug
	LimboConsole.info("Debug mode set to " + ("ON" if debug else "OFF"))
	debug_toggled.emit(debug)

func fix_window_size(set_to_display:bool = false) -> void:
	var screen_size:Vector2i = get_tree().root.size
	if set_to_display:
		screen_size = DisplayServer.screen_get_size()
	var base_width:int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var base_height:int = ProjectSettings.get_setting("display/window/size/viewport_height")
	if screen_size.x < base_width or ignore_base_width:
		get_tree().root.content_scale_size.x = screen_size.x
	else:
		get_tree().root.content_scale_size.x = base_width
	if screen_size.y < base_height or ignore_base_width:
		get_tree().root.content_scale_size.y = screen_size.y
	else:
		get_tree().root.content_scale_size.y = base_height
	get_tree().root.size = screen_size
	#ProjectSettings.set_setting("display/window/size/window_width_override", screen_size.x)
	#ProjectSettings.set_setting("display/window/size/window_height_override", screen_size.y)
	screen_resolution = get_tree().root.size
	LimboConsole.info("Current resolution: " + str(get_tree().root.size))

func load_settings() -> void:
	game_settings = GameSettingsResource.load_settings()
	settings_ready = true
	settings_loaded.emit()

func get_setting(setting_name:String, default):
	if game_settings == null:
		return default
	var result = game_settings.get(setting_name)
	if result == null:
		return default
	return result

func set_setting(setting_name:String, value) -> void:
	if game_settings == null:
		return
	game_settings.set(setting_name, value)
	game_settings.save_settings()
	settings_changed.emit()

func setting_exists(setting_name:String) -> bool:
	return game_settings.get(setting_name) != null

func get_language() -> String:
	return get_setting("language", "en")

func set_language(to:String) -> void:
	set_setting("language", to)

func get_debug() -> bool:
	return get_setting("debug", false)

func set_debug(to:bool) -> void:
	set_setting("debug", to)

func set_profile_name(to:String) -> void:
	set_setting("profile_name", to)

func get_profile_name() -> String:
	return get_setting("profile_name", "N-1606")

func get_current_resolution() -> Vector2i:
	return screen_resolution

func get_mouse_sensitivity() -> float:
	return get_setting("mouse_sensitivity", 1)

func get_focused_folder_obs() -> String:
	return get_setting("focused_folder_obs", "user://observations")

func set_focused_folder_obs(value:String) -> void:
	set_setting("focused_folder_obs", value)

func set_ambient_hum(value:bool) -> void:
	set_setting("ambient_hum", value)

func get_ambient_hum() -> bool:
	return get_setting("ambient_hum", false)

func get_current_theme_idx() -> int:
	return get_setting("selected_theme", 0)

func get_current_theme() -> CustomTheme:
	return theme_list[get_current_theme_idx()]

func set_current_theme(idx:int) -> void:
	set_setting("selected_theme", idx)
