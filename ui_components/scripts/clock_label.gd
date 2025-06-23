extends Label

func _process(_delta: float) -> void:
	var t_arr := Time.get_time_string_from_system().split(":")
	text = t_arr[0] + ":" + t_arr[1]
