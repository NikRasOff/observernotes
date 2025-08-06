extends TextureRect
class_name ImageEditThing

signal remove_image(idx:int)
signal fullscreen_requested(im:String)

@export var fullscreen_button:Button

var index:int = -1
var im_path:String

func _ready() -> void:
	fullscreen_button.pressed.connect(fullscreen)

func set_image(im:String) -> void:
	if !FileAccess.file_exists(im):
		LimboConsole.error(im + " does not exist")
		return
	var image := Image.load_from_file(im)
	if image == null:
		LimboConsole.error(im + " could not be loaded as an image")
		return
	im_path = im
	texture = ImageTexture.create_from_image(image)

func fullscreen() -> void:
	fullscreen_requested.emit(im_path)

func _on_remove_button_pressed() -> void:
	remove_image.emit(index)
