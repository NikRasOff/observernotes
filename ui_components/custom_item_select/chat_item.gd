class_name ChatItem
extends CustomItemSelectItem

signal edit_requested(path:String)

const chat_icon:Texture2D = preload("res://icons/button_icons/chat.png")

func _init(chat_path:String) -> void:
	var chat:Chat = load(chat_path) as Chat
	item_name = chat.chat_name
	selectable = false
	select_name = chat_path
	has_icon = true
	item_icon = chat_icon
	has_button_deck = true

func _ready() -> void:
	super()

func build_node() -> void:
	super()
	add_button_to_deck(FileDisplay.file_open_icon, "Open Chat", item_selected.emit)
	add_button_to_deck(FileDisplay.file_rename_icon, "Edit Chat", edit_requested.emit.bind(select_name))
	add_button_to_deck(FileDisplay.file_delete_icon, "Delete Chat", delete_requested.emit.bind(select_name))
