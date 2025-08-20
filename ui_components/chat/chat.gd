extends Resource

## A way to simulate real-time conversations
class_name Chat

const base_chat_dir:String = "user://chats"
const base_chat_name:String = "chat"

@export var chat_name:String = "New Chat"
@export var participants:Array[ProfileReference]
@export var events:Array[ChatEvent]

static func get_safe_chat_name() -> String:
	var result := base_chat_name + "0"
	while FileAccess.file_exists(base_chat_dir + "/" + result + ".res"):
		result = GoodStuff.increment_string(result)
	return base_chat_dir + "/" + result + ".res"
