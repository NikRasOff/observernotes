extends BaseSettingEdit

class_name SliderSettingEdit

@export_group("Slider Parameters")
@export var max_value:float = 100
@export var min_value:float = 0
@export var step:float = 1
@export var prefix:String
@export var suffix:String
## Ratio: slider value/setting value
@export var ratio:float = 1

var slider:SliderWithNumber

func build_node() -> void:
	super()
	slider = SliderWithNumber.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.max_value = max_value
	slider.min_value = min_value
	slider.step = step
	slider.prefix = prefix
	slider.suffix = suffix
	add_child(slider)

func setup() -> void:
	super()
	slider.value_changed.connect(read_slider)

func read_slider(_value:float) -> void:
	set_setting()

## Updates this display of the setting
func update_setting() -> void:
	slider.set_value(GameSettings.get_profile_setting(setting_name, min_value) * ratio)

## Sets the relevant profile setting
func set_setting() -> void:
	GameSettings.profile_settings.set(setting_name, slider.slider.value / ratio)
