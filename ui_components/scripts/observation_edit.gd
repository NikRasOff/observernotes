extends ScrollContainer
class_name ObservationEditTab

signal image_fullscreen_requested(im:String)
signal video_fullscreen_requested(vid:String)
signal display_requested(path:String)

@export var image_edit_scene:PackedScene
@export var video_edit_scene:PackedScene

@export_group("Text")
@export var select_image_text:String = "Select image(s)"
@export var select_video_text:String = "Select video(s)"

@export_group("Components")
@export var images_container:BoxContainer
@export var videos_container:BoxContainer
@export var file_dialog:FileDialog
@export var video_file_dialog:FileDialog
@export var text_button:Button
@export var photo_button:Button
@export var video_button:Button
@export var title_edit:LineEdit
@export var note_edit:TextEdit
@export var select_button:Button
@export var display_button:Button
@export var hide_on_text:Array[Control]

var edited_observation:Observation

var type_selected:int : set = set_type
var save_timer:float = -1
var loaded:bool = false

func _ready() -> void:
	file_dialog.file_selected.connect(load_file)
	file_dialog.files_selected.connect(load_files)
	video_file_dialog.file_selected.connect(load_file)
	video_file_dialog.files_selected.connect(load_files)
	text_button.pressed.connect(func():set_type(Observation.TYPE_TEXT))
	photo_button.pressed.connect(func():set_type(Observation.TYPE_PHOTO))
	video_button.pressed.connect(func():set_type(Observation.TYPE_VIDEO))
	title_edit.text_changed.connect(func(_t): save_timer = 1)
	note_edit.text_changed.connect(func(): save_timer = 1)
	select_button.pressed.connect(select_file)
	display_button.pressed.connect(func(): display_requested.emit(edited_observation.resource_path))

func _process(delta: float) -> void:
	if save_timer > 0:
		save_timer -= delta
		if save_timer <= 0:
			save_observation()

func close_obsevation() -> void:
	save_timer = -1

func save_observation() -> void:
	if !loaded:
		return
	save_timer = -1
	edited_observation.title = title_edit.text
	edited_observation.note = note_edit.text
	ResourceSaver.save(edited_observation)

func edit_observation(obs:String) -> void:
	LimboConsole.info("----")
	LimboConsole.info("Loading an observation!")
	save_timer = -1
	loaded = false
	for i in images_container.get_children():
		i.queue_free()
	for i in videos_container.get_children():
		i.queue_free()
	edited_observation = ResourceLoader.load(obs)
	title_edit.text = edited_observation.title
	note_edit.text = edited_observation.note
	match edited_observation.type:
		Observation.TYPE_TEXT:
			text_button.button_pressed = true
		Observation.TYPE_PHOTO:
			photo_button.button_pressed = true
		Observation.TYPE_VIDEO:
			video_button.button_pressed = true
	type_selected = edited_observation.type
	load_files(edited_observation.files)
	loaded = true

func set_type(value:int) -> void:
	match value:
		Observation.TYPE_TEXT:
			LimboConsole.info("Observation type: TEXT")
			images_container.hide()
			videos_container.hide()
			for i in images_container.get_children():
				i.queue_free()
			for i in videos_container.get_children():
				i.queue_free()
			if loaded:
				edited_observation.files.clear()
			select_button.hide()
			for i in hide_on_text:
				i.hide()
		Observation.TYPE_PHOTO:
			LimboConsole.info("Observation type: PHOTO")
			images_container.show()
			videos_container.hide()
			if type_selected == Observation.TYPE_VIDEO:
				for i in videos_container.get_children():
					i.queue_free()
				if loaded:
					edited_observation.files.clear()
			select_button.text = select_image_text
			select_button.show()
			for i in hide_on_text:
				i.show()
		Observation.TYPE_VIDEO:
			LimboConsole.info("Observation type: VIDEO")
			images_container.hide()
			videos_container.show()
			if type_selected == Observation.TYPE_PHOTO:
				for i in images_container.get_children():
					i.queue_free()
				if loaded:
					edited_observation.files.clear()
			select_button.text = select_video_text
			select_button.show()
			for i in hide_on_text:
				i.show()
	type_selected = value
	edited_observation.type = value
	
	save_observation()

func select_file() -> void:
	match type_selected:
		Observation.TYPE_PHOTO:
			file_dialog.popup_centered(Vector2i(640, 360))
		Observation.TYPE_VIDEO:
			video_file_dialog.popup_centered(Vector2i(640, 360))
		Observation.TYPE_TEXT:
			LimboConsole.error("How the fuck...")
		_:
			LimboConsole.error("Invalid observation type")

func add_image(path:String) -> void:
	var new_im_edit = image_edit_scene.instantiate() as ImageEditThing
	new_im_edit.set_image(path)
	new_im_edit.index = images_container.get_children().size()
	new_im_edit.remove_image.connect(delete_image)
	images_container.add_child(new_im_edit)
	new_im_edit.fullscreen_requested.connect(image_fullscreen_requested.emit)
	LimboConsole.info("Added image with index: " + str(new_im_edit.index))

func delete_image(idx:int) -> void:
	LimboConsole.info("Deleting image with index: " + str(idx))
	var images = images_container.get_children() as Array[ImageEditThing]
	for i in images:
		if i.index < idx:
			continue
		if i.index == idx:
			i.queue_free()
		i.index -= 1
	edited_observation.files.remove_at(idx)
	save_observation()

func delete_video(idx:int) -> void:
	LimboConsole.info("Deleting video with index: " + str(idx))
	var images = videos_container.get_children() as Array[VideoEditThing]
	for i in images:
		if i.index < idx:
			continue
		if i.index == idx:
			i.queue_free()
		i.index -= 1
	edited_observation.files.remove_at(idx)
	save_observation()

func add_video(path:String) -> void:
	var new_vid_edit = video_edit_scene.instantiate() as VideoEditThing
	new_vid_edit.set_video(path)
	new_vid_edit.index = videos_container.get_children().size()
	new_vid_edit.remove_video.connect(delete_video)
	videos_container.add_child(new_vid_edit)
	new_vid_edit.video_player.fullscreen_requested.connect(video_fullscreen_requested.emit)
	LimboConsole.info("Added video with index: " + str(new_vid_edit.index))

func load_file(path: String) -> void:
	LimboConsole.info("Loading file: " + path)
	match type_selected:
		Observation.TYPE_PHOTO:
			add_image(path)
			if loaded:
				edited_observation.files.append(path)
		Observation.TYPE_VIDEO:
			add_video(path)
			if loaded:
				edited_observation.files.append(path)
		Observation.TYPE_TEXT:
			LimboConsole.error("What the fuck how did you manage to access file selection in text mode")
		_:
			LimboConsole.error("Invalid observation type")
	save_observation()

func load_files(f:PackedStringArray) -> void:
	LimboConsole.info("Loading files: " + str(f))
	for i in f:
		load_file(i)
