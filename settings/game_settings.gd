extends Node

signal settings_loaded
signal settings_changed
signal profile_settings_changed

@export var fit_resolution:bool = true
@export var ignore_base_width:bool = false
@export var theme_list:Array[CustomTheme]

var global_settings:GlobalSettings
var profile_settings:ProfileSettings

var settings_ready:bool = false
var screen_resolution:Vector2

func _ready() -> void:
	call_deferred("load_settings")
	if !fit_resolution:
		#LimboConsole.info("Current resolution: " + str(get_tree().root.size))
		return
	fix_window_size(true)

func await_loaded() -> void:
	if settings_ready:
		return
	await settings_loaded

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

## Changes the current profile
func change_profile(to:String) -> void:
	if !ProfileSettings.profile_exists(to):
		LimboConsole.error("Profile doesn't seem to exist")
		return
	profile_settings = ProfileSettings.load_settings(to)
	profile_settings.update_some_settings()
	global_settings.current_profile = to
	global_settings.save_settings()
	settings_changed.emit()
	profile_settings_changed.emit()

## Moves a profile to trash
func delete_profile(profile:String) -> void:
	if !ProfileSettings.profile_exists(profile):
		LimboConsole.error("There's nothing to delete")
		return
	var fodel := ProfileSettings.get_profile_folder_from_name(profile)
	var settings := ProfileSettings.get_from_profile(profile)
	settings.get_obs_list().purge()
	if global_settings.current_profile == profile:
		change_profile(GlobalSettings.persistent_profile_name)
	OS.move_to_trash(ProjectSettings.globalize_path(fodel))

## Creates a new profile and returns you the savename
func create_profile() -> String:
	var savename := ProfileSettings.get_safe_profile_savename()
	DirAccess.make_dir_absolute(ProfileSettings.get_profile_folder_from_name(savename))
	var new_settings := ProfileSettings.new()
	new_settings.save_settings(savename)
	return savename

func is_guest() -> bool:
	return (global_settings.current_profile == GlobalSettings.persistent_profile_name)

func load_settings() -> void:
	if !DirAccess.dir_exists_absolute(ProfileSettings.profile_save_dir):
		DirAccess.make_dir_absolute(ProfileSettings.profile_save_dir)
	
	global_settings = GlobalSettings.load_settings()
	if FileAccess.file_exists("user://game_settings.tres"):
		var temp_settings := GameSettingsResource.load_settings()
		profile_settings = ProfileSettings.convert_game_settings(temp_settings)
		DirAccess.remove_absolute("user://game_settings.tres")
		
		var savename := ProfileSettings.get_safe_profile_savename()
		global_settings.current_profile = savename
		global_settings.save_settings()
		profile_settings.save_settings(savename)
	else:
		#if !ProfileSettings.profile_exists(global_settings.current_profile):
			#global_settings.current_profile = GlobalSettings.persistent_profile_name
		profile_settings = ProfileSettings.load_settings(global_settings.current_profile)
	
	settings_ready = true
	settings_loaded.emit()
	settings_changed.emit()
	profile_settings_changed.emit()

func save_profile_settings() -> void:
	profile_settings.save_settings(global_settings.current_profile)
	profile_settings.update_some_settings()
	settings_changed.emit()
	profile_settings_changed.emit()

func get_profile_setting(setting_name:String, default):
	if profile_settings == null:
		return default
	var result = profile_settings.get(setting_name)
	if result == null:
		return default
	return result

func get_global_setting(setting_name:String, default):
	if global_settings == null:
		return default
	var result = global_settings.get(setting_name)
	if result == null:
		return default
	return result

func set_profile_setting(setting_name:String, value) -> void:
	if profile_settings == null:
		return
	profile_settings.set(setting_name, value)
	profile_settings.save_settings(global_settings.current_profile)
	settings_changed.emit()

func set_global_setting(setting_name:String, value) -> void:
	if global_settings == null:
		return
	global_settings.set(setting_name, value)
	global_settings.save_settings()
	settings_changed.emit()

func profile_setting_exists(setting_name:String) -> bool:
	return profile_settings.get(setting_name) != null

func global_setting_exists(setting_name:String) -> bool:
	return global_settings.get(setting_name) != null

func get_current_resolution() -> Vector2i:
	return screen_resolution

func get_current_theme() -> CustomTheme:
	return theme_list[profile_settings.selected_theme]

func get_profile_name_with_effects() -> String:
	var escaped_name := GoodStuff.escape_bbcode(profile_settings.profile_name)
	if profile_settings.name_censored:
		return "[fgcolor=#" + get_current_theme().main_color.to_html() + "]" + escaped_name + "[/fgcolor]"
	return escaped_name
