extends FileDisplay

class_name ObsFileDisplay

const folder_texture = preload("res://icons/file_icons/folder.png")
const obs_text_texture = preload("res://icons/file_icons/obs_text.png")
const obs_photo_texture = preload("res://icons/file_icons/obs_photo.png")
const obs_video_texture = preload("res://icons/file_icons/obs_video.png")

const supported_file_types:Array[String] = [".res", ".tres"]

func choose_file_icon() -> Texture2D:
	if is_dir:
		return folder_texture
	if GoodStuff.get_extention(file_path) not in supported_file_types:
		return obs_text_texture
	var res = ResourceLoader.load(file_path)
	if res == null:
		return obs_text_texture
	match res.type:
		Observation.TYPE_TEXT:
			return obs_text_texture
		Observation.TYPE_PHOTO:
			return obs_photo_texture
		Observation.TYPE_VIDEO:
			return obs_video_texture
	return obs_text_texture
