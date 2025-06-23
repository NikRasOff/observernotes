extends Control

class_name FileDisplay

signal opened(file_d:FileDisplay)
signal selected(file_d:FileDisplay)
signal copy_requested(file_d:FileDisplay)
signal delete_requested(file_d:FileDisplay)
signal rename_requested(by:FileDisplay, to:String)

enum {
	MODE_EDIT,
	MODE_PROTECTED,
	MODE_SELECT,
	MODE_RENAMEABLE,
	MODE_LOCKED
}

@export var file_path:String
@export var is_dir:bool = false
@export var custom_name:String = ""
@export_enum("Edit", "Protected", "Select", "Renameable", "Locked") var display_mode:int = 0
@export var file_label:Label
@export var file_line_edit:LineEdit
@export var file_display:BoxContainer

const file_open_icon:Texture2D = preload("res://icons/button_icons/open.png")
const file_select_icon:Texture2D = preload("res://icons/button_icons/select.png")
const file_rename_icon:Texture2D = preload("res://icons/button_icons/rename.png")
const file_copy_icon:Texture2D = preload("res://icons/button_icons/copy.png")
const file_delete_icon:Texture2D = preload("res://icons/button_icons/delete.png")

func display_file_icon():
	pass

func create_button(icon:Texture2D, tooltip:String) -> Button:
	var new_button = Button.new()
	new_button.icon = icon
	new_button.tooltip_text = tooltip
	new_button.theme_type_variation = "ToolButton"
	return new_button

func make_open_button() -> void:
	var open_button = create_button(file_open_icon, "Open")
	open_button.pressed.connect(_on_open_button_pressed)
	file_display.add_child(open_button)

func make_select_button() -> void:
	var select_button = create_button(file_select_icon, "Select")
	select_button.pressed.connect(_on_select_button_pressed)
	file_display.add_child(select_button)

func make_rename_button() -> void:
	var rename_button = create_button(file_rename_icon, "Rename")
	rename_button.pressed.connect(_on_rename_button_pressed)
	file_display.add_child(rename_button)

func create(t_file_path:String, mode:int, t_is_dir:bool, t_custom_name:=""):
	display_mode = mode
	file_path = t_file_path
	is_dir = t_is_dir
	custom_name = t_custom_name
	display_file_icon()
	if custom_name.is_empty() and !file_path.is_empty():
		if is_dir:
			file_label.text = file_path.get_file()
		else:
			file_label.text = file_path.get_file().get_basename()
	else:
		file_label.text = custom_name
	match display_mode:
		MODE_EDIT:
			make_open_button()
			make_rename_button()
			var copy_button = create_button(file_copy_icon, "Copy")
			copy_button.pressed.connect(_on_copy_button_pressed)
			file_display.add_child(copy_button)
			var delete_button = create_button(file_delete_icon, "Delete")
			delete_button.pressed.connect(_on_delete_button_pressed)
			file_display.add_child(delete_button)
		MODE_PROTECTED:
			make_open_button()
		MODE_SELECT:
			make_select_button()
			if is_dir:
				make_open_button()
			make_rename_button()
		MODE_RENAMEABLE:
			if is_dir:
				make_open_button()
			make_rename_button()
		MODE_LOCKED:
			if is_dir:
				make_open_button()

func enter_edit_mode():
	file_line_edit.text = file_label.text
	file_label.hide()
	file_line_edit.show()
	file_line_edit.grab_focus()

func exit_edit_mode():
	if !file_line_edit.visible:
		return
	if file_line_edit.text == file_label.text:
		file_line_edit.hide()
		file_label.show()
		return
	var new_file_path = file_path.get_base_dir() + "/" + file_line_edit.text
	if (!is_dir):
		new_file_path += GoodStuff.get_extention(file_path)
	file_line_edit.hide()
	file_label.show()
	rename_requested.emit(self, new_file_path)

func _on_open_button_pressed() -> void:
	opened.emit(self)

func _on_delete_button_pressed() -> void:
	delete_requested.emit(self)

func _on_rename_button_pressed() -> void:
	enter_edit_mode()

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			if display_mode == MODE_SELECT and !is_dir:
				selected.emit(self)
			else:
				opened.emit(self)

func _on_mouse_entered() -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("hover_panel"))

func _on_mouse_exited() -> void:
	remove_theme_stylebox_override("panel")

func _on_line_edit_focus_exited() -> void:
	exit_edit_mode()

func _on_line_edit_text_submitted(_new_text) -> void:
	exit_edit_mode()

func _on_select_button_pressed() -> void:
	selected.emit(self)

func _on_copy_button_pressed() -> void:
	copy_requested.emit(self)
