extends HBoxContainer

class_name SettingSeparationLabel

@export var text:String

var label:Label
var sep1:HSeparator
var sep2:HSeparator

func _init(t_text:String) -> void:
	text = t_text

func build_node() -> void:
	sep1 = HSeparator.new()
	sep1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(sep1)
	
	label = Label.new()
	label.text = text
	add_child(label)
	
	sep2 = HSeparator.new()
	sep2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(sep2)

func _ready() -> void:
	build_node()
