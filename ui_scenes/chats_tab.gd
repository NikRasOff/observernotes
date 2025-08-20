class_name ChatsTab
extends Control
## Tab for chats

@export var chat_select:VBoxContainer
@export var placeholder:Control
@export var chat_edit:ChatEditor
@export var chat_display:ChatDisplay

var current_chat:String

func _ready() -> void:
	chat_edit.saved_changes.connect(refresh_chat_select)
	setup()

func setup() -> void:
	await GameSettings.await_loaded()
	refresh_chat_select()

func refresh_chat_select() -> void:
	if !DirAccess.dir_exists_absolute(Chat.base_chat_dir):
		DirAccess.make_dir_absolute(Chat.base_chat_dir)
	for i in chat_select.get_children():
		i.queue_free()
	for chat_path in DirAccess.get_files_at(Chat.base_chat_dir):
		var chat_item := ChatItem.new(Chat.base_chat_dir + "/" + chat_path)
		chat_select.add_child(chat_item)
		chat_item.item_selected.connect(open_chat.bind(Chat.base_chat_dir + "/" + chat_path))
		chat_item.delete_requested.connect(delete_chat)
		chat_item.edit_requested.connect(edit_chat)

func open_chat(path:String) -> void:
	chat_display.open_chat(path)
	placeholder.hide()
	chat_edit.hide()
	chat_display.show()
	current_chat = path
	Beeper.beep(1.1)

func edit_chat(path:String) -> void:
	chat_edit.open_chat(path)
	placeholder.hide()
	chat_edit.show()
	chat_display.hide()
	current_chat = path
	Beeper.beep(1.2)

func delete_chat(path:String) -> void:
	DirAccess.remove_absolute(path)
	refresh_chat_select()
	if path != current_chat:
		return
	chat_edit.hide()
	chat_display.hide()
	placeholder.show()
	current_chat = ""
	Beeper.beep(0.5)

func create_new_chat() -> void:
	var new_chat := Chat.new()
	new_chat.participants = ProfileSettings.get_references_to_all_profiles()
	var new_path := Chat.get_safe_chat_name()
	ResourceSaver.save(new_chat, new_path)
	refresh_chat_select()
	edit_chat(new_path)
