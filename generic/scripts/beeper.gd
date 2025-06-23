extends Node

@export var beep_player:AudioStreamPlayer

var beep_count:int = 0

func _ready() -> void:
	beep_player.finished.connect(cont_beep)

func beep(pitch:float=1.0, count:int=1) -> void:
	beep_count = count
	beep_player.pitch_scale = pitch
	play_beep()

func cont_beep() -> void:
	if beep_count > 0:
		play_beep()

func play_beep() -> void:
	beep_count -= 1
	beep_player.play()
