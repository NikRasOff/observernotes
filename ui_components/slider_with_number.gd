extends HBoxContainer

class_name SliderWithNumber

signal value_changed(value:float)
signal value_changed_while_dragging(value:float)

@export var max_value:float = 100
@export var min_value:float = 0
@export var step:float = 1
@export var prefix:String
@export var suffix:String

var slider:Slider
var spinbox:SpinBox

func build_node() -> void:
	slider = HSlider.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(slider)
	
	spinbox = SpinBox.new()
	spinbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(spinbox)

func _ready() -> void:
	build_node()
	setup()

func setup() -> void:
	slider.share(spinbox)
	slider.max_value = max_value
	slider.min_value = min_value
	slider.set_value_no_signal(min_value)
	slider.step = step
	spinbox.prefix = prefix
	spinbox.suffix = suffix
	slider.drag_ended.connect(check_for_value)
	slider.value_changed.connect(value_changed_while_dragging.emit)

func check_for_value(check:bool) -> void:
	if check:
		value_changed.emit(slider.value)

func set_value(value:float) -> void:
	slider.set_value_no_signal(value)
