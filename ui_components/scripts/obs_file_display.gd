extends FileDisplay

class_name ObsFileDisplay

@export var texture_rect:TextureRect

const folder_texture = preload("res://icons/file_icons/folder.png")
const obs_text_texture = preload("res://icons/file_icons/obs_text.png")
const obs_photo_texture = preload("res://icons/file_icons/obs_photo.png")
const obs_video_texture = preload("res://icons/file_icons/obs_video.png")

const supported_file_types:Array[String] = [".res", ".tres"]

func display_file_icon():
	if is_dir:
		texture_rect.texture = folder_texture
		return
	if GoodStuff.get_extention(file_path) not in supported_file_types:
		texture_rect.texture = obs_text_texture
		return
	var res = ResourceLoader.load(file_path)
	if res == null:
		texture_rect.texture = obs_text_texture
	match res.type:
		Observation.TYPE_TEXT:
			texture_rect.texture = obs_text_texture
		Observation.TYPE_PHOTO:
			texture_rect.texture = obs_photo_texture
		Observation.TYPE_VIDEO:
			texture_rect.texture = obs_video_texture
