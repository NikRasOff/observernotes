class_name ChatEventTyping
extends ChatEvent
## To simulate people typing

@export var typists:PackedInt32Array

#region Event Describers

func get_event_name() -> String:
	return "Typing Message"

func get_event_vars() -> Array[ChatEvent.ChatEventProperty]:
	var ar:Array[ChatEvent.ChatEventProperty] = super()
	ar.append(ChatEvent.ChatEventProperty.new(PROPERTY_TYPE_PROFILE_ARRAY,\
	"typists", "Typing People", "List of people that should show up as typing"))
	return ar

#endregion

#region Utility Functions

#endregion

#region Abstract Functions

func start(chat_display:ChatDisplay) -> void:
	super(chat_display)
	chat_display.currently_typing = typists.duplicate()
	chat_display.format_typing_label()
	end_event()

func process(delta:float, chat_display:ChatDisplay) -> void:
	pass

func wait_process(delta:float, chat_display:ChatDisplay) -> void:
	super(delta, chat_display)

#endregion
