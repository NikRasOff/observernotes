extends VBoxContainer

class_name ObsFileInspect

signal observation_opened(path:String)
signal observation_edited(path:String)
signal file_renamed(from:String, to:String)
signal file_deleted(path:String)

@export var file_inspect:FileInspect

func _ready() -> void:
	file_inspect.file_renamed.connect(file_renamed.emit)
	file_inspect.file_deleted.connect(file_deleted.emit)
	file_inspect.file_opened.connect(observation_opened.emit)

func create_observation() -> void:
	var new_obs:Observation = Observation.new()
	new_obs.creator = GameSettings.get_profile_name()
	var result = GoodStuff.safe_resource_save(new_obs, file_inspect.current_path + "/new_observation.tres")
	LimboConsole.info("Created observation, result: " + str(result["result"]))
	file_inspect.reload_files()
	observation_edited.emit(result["save_path"])
