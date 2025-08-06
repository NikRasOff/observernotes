extends BaseSettingEdit

class_name BoolSettingEdit

signal changed_state(state:bool)

const checked_texture:Texture2D = preload("res://icons/button_icons/checked.png")
const unchecked_texture:Texture2D = preload("res://icons/button_icons/unchecked.png")

var check_button:Button

var checked:bool = false : set = set_checked

func build_node() -> void:
	super()
	check_button = Button.new()
	check_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	check_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	check_button.theme_type_variation = "ToolButton"
	add_child(check_button)

func setup() -> void:
	super()
	check_button.pressed.connect(toggle_checked)

func set_checked(value:bool) -> void:
	checked = value
	changed_state.emit(value)
	set_setting()
	if check_button != null:
		check_button.icon = checked_texture if value else unchecked_texture

func toggle_checked() -> void:
	checked = !checked

## Updates this display of the setting
func update_setting() -> void:
	checked = GameSettings.get_profile_setting(setting_name, false)

## Sets the relevant profile setting
func set_setting() -> void:
	GameSettings.profile_settings.set(setting_name, checked)
