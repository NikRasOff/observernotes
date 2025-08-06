extends CustomItemListItem

class_name FileDisplay

signal opened(file_d:FileDisplay)
signal selected(file_d:FileDisplay)
signal copy_requested(file_d:FileDisplay)
signal delete_requested(file_d:FileDisplay)
signal rename_requested(by:FileDisplay, to:String)
signal started_dragging(file_d: FileDisplay, point:Vector2)
signal stopped_dragging(file_d:FileDisplay)

enum {
	MODE_EDIT,
	MODE_PROTECTED,
	MODE_SELECT,
	MODE_RENAMEABLE,
	MODE_LOCKED
}

@export var file_path:String
@export var is_dir:bool = false
@export_enum("Edit", "Protected", "Select", "Renameable", "Locked") var display_mode:int = 0

var file_line_edit:LineEdit

const file_open_icon:Texture2D = preload("res://icons/button_icons/open.png")
const file_select_icon:Texture2D = preload("res://icons/button_icons/select.png")
const file_rename_icon:Texture2D = preload("res://icons/button_icons/rename.png")
const file_copy_icon:Texture2D = preload("res://icons/button_icons/copy.png")
const file_delete_icon:Texture2D = preload("res://icons/button_icons/delete.png")

func _ready() -> void:
	super()
	gui_input.connect(_on_gui_input)
	file_line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	file_line_edit.focus_exited.connect(_on_line_edit_focus_exited)

func build_node() -> void:
	super()
	file_line_edit = LineEdit.new()
	file_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_line_edit.hide()
	main_container.add_child(file_line_edit)
	main_container.move_child(file_line_edit, name_label.get_index() + 1)
	
	match display_mode:
		MODE_EDIT:
			make_open_button()
			make_rename_button()
			add_button_to_deck(file_copy_icon, "Copy", _on_copy_button_pressed)
			add_button_to_deck(file_delete_icon, "Delete", _on_delete_button_pressed)
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

func choose_file_icon() -> Texture2D:
	return null

func make_open_button() -> void:
	add_button_to_deck(file_open_icon, "Open", _on_open_button_pressed)

func make_select_button() -> void:
	add_button_to_deck(file_select_icon, "Select", _on_select_button_pressed)

func make_rename_button() -> void:
	add_button_to_deck(file_rename_icon, "Rename", _on_rename_button_pressed)

func _init(t_file_path:String, mode:int, t_is_dir:bool, t_custom_name:="") -> void:
	display_mode = mode
	file_path = t_file_path
	is_dir = t_is_dir
	has_button_deck = true
	item_icon = choose_file_icon()
	has_icon = (item_icon != null)
	if t_custom_name.is_empty() and !file_path.is_empty():
		if is_dir:
			item_name = file_path.get_file()
		else:
			item_name = file_path.get_file().get_basename()
	else:
		item_name = t_custom_name

func enter_edit_mode():
	file_line_edit.text = name_label.text
	name_label.hide()
	file_line_edit.show()
	file_line_edit.grab_focus()

func exit_edit_mode():
	if !file_line_edit.visible:
		return
	if file_line_edit.text == name_label.text:
		file_line_edit.hide()
		name_label.show()
		return
	var new_file_path = file_path.get_base_dir() + "/" + file_line_edit.text
	if (!is_dir):
		new_file_path += GoodStuff.get_extention(file_path)
	file_line_edit.hide()
	name_label.show()
	rename_requested.emit(self, new_file_path)

func _on_open_button_pressed() -> void:
	opened.emit(self)

func _on_delete_button_pressed() -> void:
	delete_requested.emit(self)

func _on_rename_button_pressed() -> void:
	enter_edit_mode()

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				started_dragging.emit(self)
			else:
				stopped_dragging.emit(self, event.global_position)
		if event.double_click:
			if display_mode == MODE_SELECT and !is_dir:
				selected.emit(self)
			else:
				opened.emit(self)

func _on_line_edit_focus_exited() -> void:
	exit_edit_mode()

func _on_line_edit_text_submitted(_new_text) -> void:
	exit_edit_mode()

func _on_select_button_pressed() -> void:
	selected.emit(self)

func _on_copy_button_pressed() -> void:
	copy_requested.emit(self)
