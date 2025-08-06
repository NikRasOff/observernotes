extends HBoxContainer

## Allows for display and edit of a setting
class_name BaseSettingEdit

@export var bool_setting_dependency:BoolSettingEdit

@export var setting_name:String
@export var display_name:String

var name_label:Label
var center_sep:VSeparator

func _init(t_setting_name:String, t_display_name:String) -> void:
	setting_name = t_setting_name
	display_name = t_display_name

func add_dependency(to:BoolSettingEdit) -> void:
	bool_setting_dependency = to

## Creates the node
func build_node() -> void:
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(name_label)
	
	center_sep = VSeparator.new()
	add_child(center_sep)

func _ready() -> void:
	build_node()
	GameSettings.profile_settings_changed.connect(update_setting)
	if bool_setting_dependency != null:
		bool_setting_dependency.changed_state.connect(update_dependency)
	setup()

## After-ready setup
func setup() -> void:
	name_label.text = display_name

## Gray out setting if bool is off
func update_dependency(value:bool) -> void:
	if !value:
		modulate = Color.DARK_GRAY
	else:
		modulate = Color.WHITE

## Updates this display of the setting
func update_setting() -> void:
	pass

## Sets the relevant profile setting
func set_setting() -> void:
	pass
