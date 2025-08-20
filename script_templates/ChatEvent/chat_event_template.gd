# class_name _CLASS_
extends _BASE_

#region Event Describers

func get_event_name() -> String:
	return "_CLASS_"

func get_event_vars() -> Array[ChatEvent.ChatEventProperty]:
	var ar:Array[ChatEvent.ChatEventProperty] = super()
	return ar

#endregion

#region Utility Functions

#endregion

#region Abstract Functions

func start(chat_display:ChatDisplay) -> void:
	super(chat_display)

func process(delta:float, chat_display:ChatDisplay) -> void:
	super(delta, chat_display)

func wait_process(delta:float, chat_display:ChatDisplay) -> void:
	super(delta, chat_display)

#endregion
