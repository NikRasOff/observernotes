extends BaseSettingEdit

class_name ThemeSettingEdit

var option_button:CustomOptionButton

func build_node() -> void:
	super()
	option_button = CustomOptionButton.new()
	option_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	option_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for i in GameSettings.theme_list:
		option_button.add_option(i.theme_name)
	add_child(option_button)

func setup() -> void:
	super()
	option_button.item_selected.connect(select_theme)

func select_theme(idx:int) -> void:
	set_setting()

## Updates this display of the setting
func update_setting() -> void:
	option_button.select_option(GameSettings.profile_settings.selected_theme)

## Sets the relevant profile setting
func set_setting() -> void:
	GameSettings.profile_settings.set(setting_name, option_button.selected_item)
