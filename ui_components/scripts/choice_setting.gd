extends HBoxContainer

class_name ThemeSettingEdit

@export var display_name:String

@export var label:Label
@export var option_button:OptionButton

func _ready() -> void:
	option_button.item_selected.connect(select_theme)
	setup()

func setup() -> void:
	await GameSettings.await_loaded()
	label.text = display_name
	for i in GameSettings.theme_list:
		option_button.add_item(i.theme_name)
	option_button.select(GameSettings.get_current_theme_idx())

func select_theme(idx:int) -> void:
	GameSettings.set_current_theme(idx)
