extends CanvasLayer
class_name FullscreenLayer

@export var image_display:ImageDisplay
@export var video_player:InteractiveVideoPlayer
@export var background:ColorRect

func _ready() -> void:
	hide()
	background.color = ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color")
	image_display.hide()
	video_player.hide()
	image_display.fullscreen = true
	video_player.fullscreen = true
	image_display.fullscreen_requested.connect(unfullscreen)
	video_player.fullscreen_requested.connect(unfullscreen)

func display_image(im:String) -> void:
	image_display.set_image(im)
	show()
	image_display.show()
	video_player.hide()
	video_player.stop()

func display_video(vid:String) -> void:
	video_player.stop()
	video_player.assign_video(vid)
	show()
	image_display.hide()
	video_player.show()

func unfullscreen(_arg) -> void:
	video_player.stop()
	hide()
