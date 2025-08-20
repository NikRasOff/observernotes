class_name ColorSettingEdit
extends BaseSettingEdit

var color_button:ColorPickerButton

func build_node() -> void:
	super()
	color_button = ColorPickerButton.new()
	color_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	color_button.size_flags_vertical = Control.SIZE_FILL
	color_button.theme_type_variation = "ToolButton"
	add_child(color_button)

func setup() -> void:
	super()
	color_button.color_changed.connect(set_setting.unbind(1))

## Updates this display of the setting
func update_setting() -> void:
	color_button.color = GameSettings.get_profile_setting(setting_name, Color.WHITE)

## Sets the relevant profile setting
func set_setting() -> void:
	GameSettings.profile_settings.set(setting_name, color_button.color)
