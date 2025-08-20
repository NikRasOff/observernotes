class_name ChatEvent
extends Resource

## Emitted when the event is over (but before the wait)
signal has_ended

## How long to wait after the end of the event before starting the next one,
## in seconds
@export var end_duration:float = 1

enum {
	PROPERTY_TYPE_FLOAT,
	PROPERTY_TYPE_INT,
	PROPERTY_TYPE_STRING,
	PROPERTY_TYPE_PROFILE,
	PROPERTY_TYPE_PROFILE_ARRAY
}

#region Event Describers

func get_event_name() -> String:
	return "Default Event (DEBUG ONLY)"

func get_event_vars() -> Array[ChatEventProperty]:
	return [ChatEventProperty.new(PROPERTY_TYPE_FLOAT, "end_duration", \
	"End Duration", "For how long to wait after the event is finished, in seconds" \
	, {"min": 0, "max": INF, "step":0})]

#endregion

#region Utility Functions

func end_event() -> void:
	has_ended.emit()

#endregion

#region Abstract Functions

func start(chat_display:ChatDisplay) -> void:
	LimboConsole.info("Started Chat Event: " + get_event_name())

func process(_delta:float, chat_display:ChatDisplay) -> void:
	end_event()

func wait_process(_delta:float, chat_display:ChatDisplay) -> void:
	pass

#endregion

class ChatEventProperty:
	var type:int
	var property:String
	var name:String
	var tooltip:String
	var extra:Dictionary
	
	func _init(t_type:int, t_property:String, t_name:String, t_tooltip:String="", t_extra:Dictionary={}) -> void:
		type = t_type
		property = t_property
		name = t_name
		tooltip = t_tooltip
		extra = t_extra
