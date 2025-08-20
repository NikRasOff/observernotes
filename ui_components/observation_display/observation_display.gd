extends ScrollContainer
class_name ObservationDisplay

signal video_fullscreen_requested(vid:InteractiveVideoPlayer)
signal image_fullscreen_requested(im:String)
signal edit_requested(path:String)

@export var control_gallery:ControlGallery
@export var title_label:RichTextLabel
@export var creator_label:RichTextLabel
@export var note_label:RichTextLabel
@export var edit_button:Button

var obs_path:String
var cur_obs:Observation

func _ready() -> void:
	control_gallery.video_fullscreen_requested.connect(video_fullscreen_requested.emit)
	control_gallery.image_fullscreen_requested.connect(image_fullscreen_requested.emit)
	edit_button.pressed.connect(func(): edit_requested.emit(obs_path))
	GameSettings.profile_settings_changed.connect(resolve_creator_text)

func open_observation(path:String) -> void:
	#cur_obs.free()
	obs_path = path
	control_gallery.reset()
	var obs := ResourceLoader.load(path) as Observation
	cur_obs = obs
	match obs.type:
		Observation.TYPE_PHOTO:
			control_gallery.show()
			control_gallery.add_images(obs.files)
		Observation.TYPE_VIDEO:
			control_gallery.show()
			control_gallery.add_videos(obs.files)
		Observation.TYPE_TEXT:
			control_gallery.hide()
	while control_gallery.custom_minimum_size.y < 100:
		await control_gallery.setup_size()
	title_label.text = obs.title
	
	if obs.creator_reference == null:
		obs.creator_reference = ProfileReference.new()
		obs.creator_reference.ignore_savename = true
		obs.creator_reference.fallback_name = obs.creator
		ResourceSaver.save(obs)
	creator_label.text = "Created by: " + obs.creator_reference.get_profile_name()
	note_label.text = "Observer's note:\n" + obs.note

func resolve_creator_text() -> void:
	if obs_path.is_empty():
		return
	cur_obs.creator_reference.update_profile_name()
	creator_label.text = "Created by: " + cur_obs.creator_reference.get_profile_name()
