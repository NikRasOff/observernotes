extends ConfirmationDialog
class_name FileConfirmDialog

signal file_confirmed(file:String, extra_args:Dictionary)
signal file_custom_action(action:StringName, file:String, extra_args:Dictionary)

@export var text_template:String = "Are you sure in \"{file}\"?"
@export var use_template:bool = true
@export var custom_buttons:Array[CustomConfirmButton]

var w_file_path:String
var additional_arguments:Dictionary

func _ready() -> void:
	for b in custom_buttons:
		add_button(b.button_name, b.right, b.action_name)
	confirmed.connect(_on_confirm)
	custom_action.connect(_on_custom_action)

func popup_for_file(f:String, extra_args := {}) -> void:
	w_file_path = f
	additional_arguments = extra_args
	if use_template:
		dialog_text = text_template.format({"file": f.get_file()})
	popup_centered(Vector2i(100, 100))

func _on_confirm() -> void:
	file_confirmed.emit(w_file_path, additional_arguments)

func _on_custom_action(action:StringName) -> void:
	file_custom_action.emit(action, w_file_path, additional_arguments)
