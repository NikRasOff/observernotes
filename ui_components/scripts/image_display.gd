extends TextureRect
class_name ImageDisplay

signal fullscreen_requested(im:String)

@export var fullscreen_tooltip:String
@export var unfullscreen_tooltip:String
@export var fullscreen_texture:Texture2D
@export var unfullscreen_texture:Texture2D
@export var fullscreen_button:Button

var fullscreen:bool = false : set = set_fullscreen
var im_path:String

func _ready() -> void:
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	fullscreen = fullscreen

func set_fullscreen(value:bool) -> void:
	fullscreen = value
	if fullscreen_button == null:
		return
	fullscreen_button.icon = unfullscreen_texture if value else fullscreen_texture
	fullscreen_button.tooltip_text = unfullscreen_tooltip if value else fullscreen_tooltip

func set_image(path:String) -> void:
	if !FileAccess.file_exists(path):
		LimboConsole.error(path + " does not exist")
		return
	var image := Image.load_from_file(path)
	if image == null:
		LimboConsole.error(path + " could not be loaded as an image")
		return
	im_path = path
	texture = ImageTexture.create_from_image(image)

func _on_fullscreen_pressed() -> void:
	fullscreen_requested.emit(im_path)
