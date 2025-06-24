extends Resource
class_name GameSettingsResource

@export_range(0.5, 5) var mouse_sensitivity:float = 1
@export var language:String = "en" : set = set_language
@export var debug:bool = false
@export var profile_name:String = "N-1606"
@export var focused_folder_obs:String = "user://observations"
@export var ambient_hum:bool = false
@export var selected_theme:int = 1

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
