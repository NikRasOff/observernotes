extends HBoxContainer

class_name BoolSettingEdit

@export var setting_name:String
@export var display_name:String

@export var checked_texture:Texture2D
@export var unchecked_texture:Texture2D

@export var label:Label
@export var check_button:Button

var checked:bool = false : set = set_checked

func _ready() -> void:
	check_button.pressed.connect(toggle_checked)
	setup()

func setup() -> void:
	await GameSettings.await_loaded()
	label.text = display_name
	checked = GameSettings.get_setting(setting_name, false)

func set_checked(value:bool) -> void:
	checked = value
	if GameSettings.settings_ready:
		GameSettings.set_setting(setting_name, value)
	if check_button != null:
		check_button.icon = checked_texture if value else unchecked_texture

func toggle_checked() -> void:
	checked = !checked
