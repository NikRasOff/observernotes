extends Resource

class_name GlobalSettings

const save_location:String = "user://global_settings.tres"
const persistent_profile_name:String = "guest"

@export var current_profile:String = persistent_profile_name

static func load_settings() -> GlobalSettings:
	var gs:GlobalSettings
	if ResourceLoader.exists(save_location):
		gs = ResourceLoader.load(save_location)
	else:
		gs = GlobalSettings.new()
	return gs

func save_settings() -> void:
	ResourceSaver.save(self, save_location)
