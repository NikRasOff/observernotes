extends Control
class_name ControlGallery

signal video_fullscreen_requested(vid:InteractiveVideoPlayer)
signal image_fullscreen_requested(im:String)

@export_group("Scenes")
@export var video_player_scene:PackedScene
@export var image_display_scene:PackedScene

@export_group("Components")
@export var left_button:Button
@export var right_button:Button
@export var button_control:Control
@export var content_control:Control

var index:int = 0 : set = set_index

const ASPECT_RATIO:float = 1080.0 / 1920.0

func _ready() -> void:
	left_button.pressed.connect(go_left)
	right_button.pressed.connect(go_right)

func setup_size() -> void:
	await get_tree().process_frame # Waiting for a single frame for the size to update
	custom_minimum_size.x = size.x
	custom_minimum_size.y = size.x * ASPECT_RATIO

func add_image(path:String) -> void:
	var inst = image_display_scene.instantiate() as ImageDisplay
	inst.set_image(path)
	inst.fullscreen_requested.connect(image_fullscreen_requested.emit)
	add_control(inst)

func add_video(path:String) -> void:
	var inst = video_player_scene.instantiate() as InteractiveVideoPlayer
	inst.assign_video(path)
	inst.fullscreen_requested.connect(video_fullscreen_requested.emit)
	if content_control.get_child_count() == 0:
		ProgramStatus.set_focused_video_player(inst)
	add_control(inst)

func add_control(c:Control) -> void:
	content_control.add_child(c)
	if content_control.get_child_count() > 1:
		c.hide()
	update_buttons()

func add_images(paths:PackedStringArray) -> void:
	for i in paths:
		add_image(i)
	update_buttons()

func add_videos(paths:PackedStringArray) -> void:
	for i in paths:
		add_video(i)
	update_buttons()

func reset() -> void:
	index = 0
	for i in content_control.get_children():
		i.free()
	update_buttons()

func set_index(value:int) -> void:
	if content_control.get_child_count() <= 0:
		return
	var prev := content_control.get_child(index) as Control
	if prev != null:
		prev.hide()
		if prev is InteractiveVideoPlayer:
			ProgramStatus.set_focused_video_player(null)
	index = clampi(value, 0, max(content_control.get_child_count() - 1, 0))
	var now := content_control.get_child(index) as Control
	if now != null:
		now.show()
		if now is InteractiveVideoPlayer:
			ProgramStatus.set_focused_video_player(now)

func update_buttons() -> void:
	if content_control.get_child_count() <= 1:
		button_control.hide()
		return
	else:
		button_control.show()
	
	left_button.disabled = (index == 0)
	right_button.disabled = (index == content_control.get_child_count() - 1)

func go_left() -> void:
	index -= 1
	update_buttons()

func go_right() -> void:
	index += 1
	update_buttons()
