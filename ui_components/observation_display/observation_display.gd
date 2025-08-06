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

func _ready() -> void:
	control_gallery.video_fullscreen_requested.connect(video_fullscreen_requested.emit)
	control_gallery.image_fullscreen_requested.connect(image_fullscreen_requested.emit)
	edit_button.pressed.connect(func(): edit_requested.emit(obs_path))
	GameSettings.profile_settings_changed.connect(resolve_creator_text)

func open_observation(path:String) -> void:
	obs_path = path
	control_gallery.reset()
	var obs := ResourceLoader.load(path) as Observation
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
	
	var creator_text:String
	if obs.censor_creator:
		creator_text = "[fgcolor=#" + GameSettings.get_current_theme().main_color.to_html() + "]" + obs.creator + "[/fgcolor]"
	else:
		creator_text = obs.creator
	creator_label.text = "Created by: " + creator_text
	note_label.text = "Observer's note:\n" + obs.note

func resolve_creator_text() -> void:
	if obs_path.is_empty():
		return
	var obs:Observation = ResourceLoader.load(obs_path) as Observation
	var creator_text:String
	if obs.censor_creator:
		creator_text = "[fgcolor=#" + GameSettings.get_current_theme().main_color.to_html() + "]" + obs.creator + "[/fgcolor]"
	else:
		creator_text = obs.creator
	creator_label.text = "Created by: " + creator_text
