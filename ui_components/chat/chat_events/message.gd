class_name ChatEventMessage
extends ChatEvent
## System Messages

@export var delimiter:String = "\n~delimiter~\n"
@export var text:String

#region Event Describers

func get_event_name() -> String:
	return "System Message"

func get_event_vars() -> Array[ChatEvent.ChatEventProperty]:
	var ar:Array[ChatEvent.ChatEventProperty] = super()
	ar.append(ChatEvent.ChatEventProperty.new(PROPERTY_TYPE_STRING, \
	"text", "Message Text", "Main text of the message"))
	return ar

#endregion

#region Utility Functions

#endregion

#region Abstract Functions

func start(chat_display:ChatDisplay) -> void:
	super(chat_display)
	chat_display.append_to_memory(delimiter + text)
	end_event()

func process(delta:float, chat_display:ChatDisplay) -> void:
	pass

func wait_process(delta:float, chat_display:ChatDisplay) -> void:
	super(delta, chat_display)

#endregion
