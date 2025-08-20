class_name ChatDisplay
extends VBoxContainer
## The thing that actually displays the chat

# signals

# consts

# exports

@export var start_chat_message:String = "Press the send button to start chat replay"

@export_group("Components")
@export var decoy_edit:LineEdit
@export var typing_label:RichTextLabel
@export var chatbox:RichTextLabel
@export var name_label:Label
@export var handy_dandy_timer:Timer

# onready vars

# vars

var cur_chat:Chat

var cur_event:int
var playing_chat:bool = false
var waiting_for_next_event:bool = false

var currently_typing:PackedInt32Array
var chat_memory:String

# built-in virtual function overrides

func _ready() -> void:
	handy_dandy_timer.timeout.connect(advance_event)

func _process(delta: float) -> void:
	if !playing_chat:
		return
	if waiting_for_next_event:
		cur_chat.events[cur_event].wait_process(delta, self)
	else:
		cur_chat.events[cur_event].process(delta, self)

# base class function overrides

# functions

func open_chat(path:String) -> void:
	if !FileAccess.file_exists(path):
		LimboConsole.error("File \"" + path + "\" doen not exist. Could not open chat.")
		return
	cur_chat = load(path) as Chat
	
	reset()

func reset() -> void:
	handy_dandy_timer.stop()
	name_label.text = cur_chat.chat_name
	typing_label.text = start_chat_message
	cur_event = 0
	currently_typing.clear()
	chat_memory = ""
	display_memory()

func start_chat() -> void:
	reset()
	typing_label.hide()
	playing_chat = true
	start_new_event()

func stop_chat() -> void:
	playing_chat = false

func start_new_event() -> void:
	waiting_for_next_event = false
	cur_chat.events[cur_event].has_ended.connect(end_event)
	cur_chat.events[cur_event].start(self)

func end_event() -> void:
	waiting_for_next_event = true
	cur_chat.events[cur_event].has_ended.disconnect(end_event)
	handy_dandy_timer.start(cur_chat.events[cur_event].end_duration)

func advance_event() -> void:
	if cur_event == cur_chat.events.size() - 1:
		stop_chat()
		return
	cur_event += 1
	start_new_event()

func get_profile_name(id:int) -> String:
	return cur_chat.participants[id].get_profile_name()

func format_typing_label() -> void:
	if currently_typing.is_empty():
		typing_label.text = " "
		return
	var type_string:String = ""
	for t in currently_typing:
		if !type_string.is_empty():
			type_string += ", "
		type_string += get_profile_name(t)
	if currently_typing.size() == 1:
		type_string += " is typing..."
	elif currently_typing.size() > 1 and currently_typing.size() <= 4:
		type_string += " are typing..."
	else:
		type_string = "Many people are typing..."
	
	typing_label.text = type_string
	end_event()

func format_text(text:String) -> String:
	return text.replace("~censor~", GameSettings.get_current_theme().main_color.to_html())\
	.replace("~delimiter~", "")

func append_to_memory(new_text:String) -> void:
	chat_memory += new_text
	chatbox.append_text(format_text(new_text))

func display_memory() -> void:
	chatbox.text = format_text(chat_memory)

# setters

# getters

# virtual functions

# subclasses
