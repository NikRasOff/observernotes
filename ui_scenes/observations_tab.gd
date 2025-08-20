extends Control
class_name ObservationsTab

@export var file_inspect:ObsFileInspect
@export var placeholder:Control
@export var obs_edit:ObservationEditTab
@export var obs_display:ObservationDisplay
@export var fullscreen_layer:FullscreenLayer

var current_obs:String

func _ready() -> void:
	file_inspect.observation_edited.connect(edit_obs)
	file_inspect.observation_opened.connect(open_obs)
	file_inspect.file_deleted.connect(_on_obs_deleted)
	file_inspect.file_renamed.connect(_on_obs_renamed)
	obs_edit.image_fullscreen_requested.connect(fullscreen_layer.display_image)
	obs_edit.video_fullscreen_requested.connect(fullscreen_layer.display_video)
	obs_edit.display_requested.connect(open_obs)
	obs_display.image_fullscreen_requested.connect(fullscreen_layer.display_image)
	obs_display.video_fullscreen_requested.connect(fullscreen_layer.display_video)
	obs_display.edit_requested.connect(edit_obs)

func open_obs(path:String) -> void:
	Beeper.beep(1.1)
	current_obs = path
	placeholder.hide()
	obs_edit.hide()
	obs_display.show()
	obs_display.open_observation(path)

func edit_obs(path:String) -> void:
	Beeper.beep(1.2)
	current_obs = path
	obs_edit.edit_observation(path)
	placeholder.hide()
	obs_display.hide()
	obs_edit.show()

func _on_obs_renamed(from:String, to:String) -> void:
	Beeper.beep()
	var obs := (ResourceLoader.load(to) as Observation)
	if !obs.creator_reference.ignore_savename:
		var profile_settings := ProfileSettings.get_from_profile(obs.creator_reference.savename)
		profile_settings.rename_obs_in_list(from, to)
	if from != current_obs:
		return
	current_obs = to
	if obs_edit.visible:
		obs_edit.edit_observation(to)
	if obs_display.visible:
		obs_display.open_observation(to)

func _on_obs_deleted(path:String) -> void:
	if DirAccess.dir_exists_absolute(path):
		return
	var obs := (ResourceLoader.load(path) as Observation)
	if !obs.creator_reference.ignore_savename:
		var profile_settings := ProfileSettings.get_from_profile(obs.creator_reference.savename)
		profile_settings.remove_obs_from_list(path)
	if path != current_obs:
		return
	placeholder.show()
	obs_edit.close_obsevation()
	obs_edit.hide()
	obs_display.hide()
