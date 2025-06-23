extends Label

@export var mock_os_name:String = "ObserverOS"

func _ready() -> void:
	text = mock_os_name + " v" + ProjectSettings.get("application/config/version")
