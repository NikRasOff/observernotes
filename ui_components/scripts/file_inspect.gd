extends Control

class_name FileInspect

# The beautiful mess responcible for displaying
# file selection

signal file_opened(file_path:String)
signal file_renamed(from:String, to:String)
signal dir_renamed(from:String, to:String)
signal file_deleted(path:String)
signal selected(path:String)
signal dir_opened(dir_path:String)

@export var file_display_scene:PackedScene

enum {
	MODE_EDIT,
	MODE_FILE_SELECT,
	MODE_DIR_SELECT,
	MODE_BOTH_SELECT,
	MODE_LOCKED
}

## The root path of the file inspect
@export var root_path:String = "observations"
@export var root_flavor_text:String = "root://"
var prefix:String
## How the file inspect operates
@export_enum("Edit", "Select file", "Select dir", "Select file or dir", "Locked") var work_mode:int = 0
@export var file_inspect:BoxContainer
@export var delete_confirm:FileConfirmDialog
@export var rename_confirm:FileConfirmDialog
@export var dir_path_display:Label
@export var accept_dialog:AcceptDialog
@export var up_layer_button:Button

var current_path:String

var clipboard:String

func _ready():
	delete_confirm.file_confirmed.connect(_on_delete_dialog_confirmed)
	rename_confirm.file_confirmed.connect(_on_rename_confirm_confirmed)
	rename_confirm.file_custom_action.connect(_on_rename_confirm_custom_action)
	up_layer_button.pressed.connect(go_up)
	GameSettings.settings_changed.connect(reload_files)
	start_at_root()

func notify_player(what:String) -> void:
	accept_dialog.dialog_text = what
	accept_dialog.popup_centered(Vector2i(100, 100))

## Just opens the root directory
func start_at_root():
	prefix = "user://" + root_path
	if !DirAccess.dir_exists_absolute(prefix):
		GoodStuff.make_dir_good(prefix)
	open_dir(prefix)

## Opens a directiory
func open_dir(dir_path:String) -> void:
	current_path = dir_path
	dir_path_display.text = root_flavor_text + current_path.trim_prefix(prefix).trim_prefix("/")
	reload_files()
	dir_opened.emit(dir_path)

## Goes up a directory layer
func go_up() -> void:
	Beeper.beep(0.9, 2)
	open_dir(current_path.get_base_dir())

## Creates a new file display
func create_file_display(file_path:String, mode:int, is_dir:bool, custom_name:String="") -> FileDisplay:
	var new_file_display = file_display_scene.instantiate() as FileDisplay
	new_file_display.opened.connect(_on_file_opened)
	new_file_display.delete_requested.connect(_on_file_delete_requested)
	new_file_display.rename_requested.connect(_on_rename_requested)
	new_file_display.selected.connect(_on_selected)
	new_file_display.copy_requested.connect(_on_copy_requested)
	new_file_display.call_deferred("create", file_path, mode, is_dir, custom_name)
	return new_file_display

## Reloads the file displays
func reload_files() -> void:
	for i in file_inspect.get_children():
		i.queue_free()
	var files := GoodStuff.get_dir_contents(current_path)
	if current_path != prefix:
		up_layer_button.disabled = false
		var up_text = current_path.get_base_dir()
		if up_text == prefix:
			up_text = root_flavor_text
		else:
			up_text = up_text.get_file()
		up_layer_button.tooltip_text = "Go up to \"" + up_text + "\""
	else:
		up_layer_button.disabled = true
		up_layer_button.tooltip_text = ""
	match work_mode:
		MODE_EDIT:
			for t_f in files["dirs"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_EDIT, true))
			for t_f in files["files"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_EDIT, false))
		MODE_FILE_SELECT:
			for t_f in files["dirs"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_RENAMEABLE, true))
			for t_f in files["files"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_SELECT, false))
		MODE_DIR_SELECT:
			for t_f in files["dirs"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_SELECT, true))
			for t_f in files["files"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_RENAMEABLE, false))
		MODE_BOTH_SELECT:
			for t_f in files["dirs"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_SELECT, true))
			for t_f in files["files"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_SELECT, false))
		MODE_LOCKED:
			for t_f in files["dirs"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_LOCKED, true))
			for t_f in files["files"]:
				file_inspect.add_child(create_file_display(t_f, FileDisplay.MODE_LOCKED, false))

## Creates a new folder at the current path
func create_new_folder() -> void:
	GoodStuff.safe_dir_create(current_path + "/new_folder")
	reload_files()

## Pastes the previously copied file at the current path
func copy_file() -> void:
	GoodStuff.safe_copy(clipboard, current_path)
	reload_files()

func _on_file_opened(file_display:FileDisplay) -> void:
	if file_display.is_dir:
		Beeper.beep(0.9)
		open_dir(file_display.file_path)
	else:
		file_opened.emit(file_display.file_path)

func _on_selected(file_display:FileDisplay) -> void:
	selected.emit(file_display.file_path)

func _on_file_delete_requested(file_display:FileDisplay) -> void:
	delete_confirm.popup_for_file(file_display.file_path)

func _on_copy_requested(file_display:FileDisplay) -> void:
	clipboard = file_display.file_path

func _on_rename_requested(by:FileDisplay, to:String) -> void:
	if !to.trim_prefix(by.file_path.get_base_dir() + "/").is_valid_filename():
		notify_player("File/folder name invalid.\nMake sure the name isn't empty and\ndoesn't contain any of these characters:\n: / \\ ? * \" | % < > .")
		return
	if (by.is_dir and !DirAccess.dir_exists_absolute(to)) or (!by.is_dir and !FileAccess.file_exists(to)):
		DirAccess.rename_absolute(by.file_path, to)
		if !by.is_dir:
			file_renamed.emit(by.file_path, to)
		else:
			dir_renamed.emit(by.file_path, to)
		reload_files()
		return
	if by.is_dir:
		rename_confirm.dialog_text = "Folder \"" + to.get_file().get_basename() + "\" already exists."
	else:
		rename_confirm.dialog_text = "File \"" + to.get_file().get_basename() + "\" already exists."
	rename_confirm.popup_for_file(by.file_path, {"name": to, "is_dir": by.is_dir})

func _on_delete_dialog_confirmed(f:String, _args) -> void:
	file_deleted.emit(f)
	OS.move_to_trash(ProjectSettings.globalize_path(f))
	reload_files()

func _on_rename_confirm_confirmed(f:String, extra_args:Dictionary) -> void:
	OS.move_to_trash(ProjectSettings.globalize_path(f))
	DirAccess.rename_absolute(f, extra_args["name"])
	if !extra_args["is_dir"]:
		file_renamed.emit(f, extra_args["name"])
	else:
		dir_renamed.emit(f, extra_args["name"])
	reload_files()

func _on_rename_confirm_custom_action(action:StringName, f:String, extra_args:Dictionary) -> void:
	match action:
		"ch_name":
			if extra_args["is_dir"]:
				var result := GoodStuff.safe_dir_rename(f, extra_args["name"])
				dir_renamed.emit(result["rename_path"], result["result"])
				reload_files()
			else:
				var result := GoodStuff.safe_file_rename(f, extra_args["name"])
				file_renamed.emit(result["rename_path"], result["result"])
				reload_files()
	rename_confirm.hide()
