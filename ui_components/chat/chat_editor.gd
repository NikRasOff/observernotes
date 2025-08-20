class_name ChatEditor
extends VBoxContainer
## Chat editor

# signals

signal saved_changes()

# consts

# exports

@export var chat_name_edit:LineEdit
@export var chat_events_container:VBoxContainer
@export var select_type_popup:PopupPanel

# vars

var cur_chat:Chat

# built-in virtual function overrides

func _ready() -> void:
	chat_name_edit.text_changed.connect(_on_chat_name_changed)

# base class function overrides

# functions

func open_chat(path:String) -> void:
	if !FileAccess.file_exists(path):
		LimboConsole.error("File does not exist: " + path)
		return
	cur_chat = load(path) as Chat
	
	chat_name_edit.text = cur_chat.chat_name
	
	reload_event_display()

func reload_event_display() -> void:
	for n in chat_events_container.get_children():
		n.queue_free()
	
	for event in cur_chat.events:
		add_event(event)

func delete_event(event_edit:ChatEventItem) -> void:
	cur_chat.events.erase(event_edit.event)
	event_edit.queue_free()
	Beeper.beep(0.5)

func add_event(event:ChatEvent) -> void:
	var new_event_edit := ChatEventItem.new(event, cur_chat)
	chat_events_container.add_child(new_event_edit)
	new_event_edit.delete_requested.connect(delete_event.bind(new_event_edit))
	new_event_edit.reordering_requested.connect(reorder_event.bind(new_event_edit))

func reorder_event(shift:int, event_edit:ChatEventItem) -> void:
	var cur_idx := cur_chat.events.find(event_edit.event)
	var new_idx := cur_idx + shift
	if new_idx < 0 or new_idx >= cur_chat.events.size():
		return
	var temp := cur_chat.events[new_idx]
	cur_chat.events[new_idx] = cur_chat.events[cur_idx]
	cur_chat.events[cur_idx] = temp
	reload_event_display()

func request_event_creation() -> void:
	select_type_popup.size = $SelectTypePopup/VBoxContainer.get_minimum_size()
	select_type_popup.popup_centered()
	Beeper.beep(1.2)

func create_new_event(event:ChatEvent) -> void:
	select_type_popup.hide()
	cur_chat.events.append(event)
	add_event(event)
	Beeper.beep(1.1)

func create_debug_event() -> void:
	create_new_event(ChatEventMessage.new())

func create_system_message_event() -> void:
	create_new_event(ChatEventMessage.new())

func create_user_message_event() -> void:
	create_new_event(ChatEventUserMessage.new())

func create_typing_message_event() -> void:
	create_new_event(ChatEventTyping.new())

func save_changes() -> void:
	ResourceSaver.save(cur_chat)
	saved_changes.emit()
	Beeper.beep()

# setters

# getters

# virtual functions

func _on_chat_name_changed(to:String) -> void:
	cur_chat.chat_name = to

# subclasses
