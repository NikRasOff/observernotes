extends Resource

class_name ProfileSettings

const profile_save_dir:String = "user://profiles/"
const base_profile_name:String = "profile"
const save_name:String = "profile_settings.tres"

@export var language:String = "en" : set = set_language
@export var ambient_hum:bool = false
@export var no_hum_on_video:bool = true
@export var selected_theme:int = 1

@export var master_volume:float = 1
@export var hum_volume:float = 1

@export_group("Profile attributes")
@export var profile_name:String = "Profile"
## Censors the name wherever it's brought up.
## [br]Mainly used for signifying "mysterious higherups"
@export var name_censored:bool = false
## Allows you to edit any observation, even if it's not your own
@export var admin_profile:bool = false
@export var undeletable:bool = false
@export var hidden:bool = false

@export_group("Video Playback Settings")
@export var video_muted:bool = false : set = set_video_muted
@export var video_volume:float = 1 : set = set_video_volume
@export var video_speed:float = 1

static func convert_game_settings(old:GameSettingsResource) -> ProfileSettings:
	var new = ProfileSettings.new()
	new.ambient_hum = old.ambient_hum
	new.selected_theme = old.selected_theme
	new.profile_name = old.profile_name
	new.video_muted = old.video_muted
	new.video_volume = old.video_volume
	new.video_speed = old.video_speed
	return new

static func get_safe_profile_savename() -> String:
	var res:String = base_profile_name + "0"
	while profile_exists(res):
		res = GoodStuff.increment_string(res)
	return res

static func get_save_path_from_name(n:String) -> String:
	return profile_save_dir + n + "/" + save_name

static func get_profile_folder_from_name(n:String) -> String:
	return profile_save_dir + n

static func profile_exists(profile:String) -> bool:
	return DirAccess.dir_exists_absolute(get_profile_folder_from_name(profile)) or (profile == GlobalSettings.persistent_profile_name)

static func get_from_profile(profile:String) -> ProfileSettings:
	var f = get_save_path_from_name(profile)
	if FileAccess.file_exists(f):
		return ResourceLoader.load(f)
	else:
		return null

static func load_settings(profile:String) -> ProfileSettings:
	var location := get_save_path_from_name(profile)
	var gs:ProfileSettings
	if profile == GlobalSettings.persistent_profile_name or !ResourceLoader.exists(location):
		# Even if the guest has a profile saved, it's not loaded
		# That's on purpose
		# This is not a profile
		# This is a placeholder
		gs = ProfileSettings.new()
		gs.profile_name = "Guest"
		gs.undeletable = true
		gs.hidden = true
	else:
		gs = ResourceLoader.load(location)
	return gs

func save_settings(profile:String) -> void:
	if profile == GlobalSettings.persistent_profile_name:
		return
	if !DirAccess.dir_exists_absolute(get_profile_folder_from_name(profile)):
		DirAccess.make_dir_absolute(get_profile_folder_from_name(profile))
	ResourceSaver.save(self, get_save_path_from_name(profile))

func update_some_settings() -> void:
	AudioServer.set_bus_volume_linear(0, master_volume)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Hum"), hum_volume)

func set_language(value:String) -> void:
	TranslationServer.set_locale(value)
	language = value

func set_video_muted(value:bool) -> void:
	video_muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("VideoPlayback"), value)

func set_video_volume(value:float) -> void:
	video_volume = value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("VideoPlayback"), value)
