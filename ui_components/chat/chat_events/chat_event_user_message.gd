class_name ChatEventUserMessage
extends ChatEventMessage
## User Messages

@export var sender:int

#region Event Describers

func get_event_name() -> String:
	return "User Message"

func get_event_vars() -> Array[ChatEvent.ChatEventProperty]:
	var ar:Array[ChatEvent.ChatEventProperty] = super()
	ar.append(ChatEvent.ChatEventProperty.new(PROPERTY_TYPE_PROFILE, \
	"sender", "Message Sender", "Profile that sends this message"))
	return ar

#endregion

#region Utility Functions

#endregion

#region Abstract Functions

func start(chat_display:ChatDisplay) -> void:
	LimboConsole.info("Started Chat Event: " + get_event_name())
	var cur := chat_display.currently_typing.find(sender)
	if cur >= 0:
		chat_display.currently_typing.remove_at(cur)
		chat_display.format_typing_label()
	chat_display.append_to_memory(delimiter + chat_display.cur_chat.participants[sender].get_profile_name_raw() + ": " +\
	"[color=" + chat_display.cur_chat.participants[sender].get_profile_color().to_html() +\
	"]" + text + "[/color]")
	end_event()

func process(delta:float, chat_display:ChatDisplay) -> void:
	pass

func wait_process(delta:float, chat_display:ChatDisplay) -> void:
	super(delta, chat_display)

#endregion
