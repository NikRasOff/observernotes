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
	creator_label.text = "Created by: " + obs.creator
	note_label.text = "Observer's note:\n" + obs.note
