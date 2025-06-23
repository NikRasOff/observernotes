extends Control
class_name VideoEditThing

signal remove_video(idx:int)

@export var video_player:InteractiveVideoPlayer

var index:int = -1

const VIDEO_ASPECT_RATIO:float = 1080.0 / 1920.0

func _ready() -> void:
	while custom_minimum_size.y < 0.1:
		await setup_size()

func setup_size() -> void:
	await get_tree().process_frame # Waiting for a single frame for the size to update
	custom_minimum_size.x = size.x
	custom_minimum_size.y = size.x * VIDEO_ASPECT_RATIO

func set_video(vid:String) -> void:
	await ready
	video_player.assign_video(vid)

func _on_remove_button_pressed() -> void:
	remove_video.emit(index)
