extends Node

signal update_hum(value:bool)

var focused_video_player:InteractiveVideoPlayer

func set_focused_video_player(pl:InteractiveVideoPlayer) -> void:
	focused_video_player = pl

func set_hum_playing(value:bool) -> void:
	update_hum.emit(value)
