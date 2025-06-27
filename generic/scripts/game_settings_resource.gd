extends Resource
class_name GameSettingsResource

@export_range(0.5, 5) var mouse_sensitivity:float = 1
@export var language:String = "en" : set = set_language
@export var debug:bool = false
@export var profile_name:String = "N-1606"
@export var focused_folder_obs:String = "user://observations"
@export var ambient_hum:bool = false
@export var selected_theme:int = 1

@export_group("Video Playback Settings")
@export var video_muted:bool = false : set = set_video_muted
@export var video_volume:float = 1 : set = set_video_volume
@export var video_speed:float = 1

static func load_settings() -> GameSettingsResource:
	var gs:GameSettingsResource
	if ResourceLoader.exists("user://game_settings.tres"):
		gs = ResourceLoader.load("user://game_settings.tres")
	else:
		gs = GameSettingsResource.new()
	return gs

func save_settings() -> void:
	ResourceSaver.save(self, "user://game_settings.tres")

func set_language(value:String) -> void:
	TranslationServer.set_locale(value)
	language = value

func set_video_muted(value:bool) -> void:
	video_muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("VideoPlayback"), value)

func set_video_volume(value:float) -> void:
	video_volume = value
	var amplify_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index("VideoPlayback"), 0) as AudioEffectAmplify
	amplify_effect.volume_linear = value
