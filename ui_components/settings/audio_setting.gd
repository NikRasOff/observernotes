extends SliderSettingEdit

class_name AudioSettingEdit

@export var audio_bus:int
@export var db_modify:float = 0
@export var test_sound:AudioStream

var audio_stream_player:AudioStreamPlayer

func build_node() -> void:
	min_value = 0
	max_value = 100
	step = 0.5
	suffix = "%"
	ratio = 100
	super()
	
	if test_sound != null:
		audio_stream_player = AudioStreamPlayer.new()
		audio_stream_player.bus = AudioServer.get_bus_name(audio_bus)
		audio_stream_player.stream = test_sound
		audio_stream_player.volume_db = db_modify
		add_child(audio_stream_player)

func setup() -> void:
	super()
	slider.value_changed_while_dragging.connect(soft_read_slider)

func soft_read_slider(value:float) -> void:
	AudioServer.set_bus_volume_linear(audio_bus, value / ratio)

func read_slider(value:float) -> void:
	super(value)
	AudioServer.set_bus_volume_linear(audio_bus, value / ratio)
	if audio_stream_player != null:
		audio_stream_player.play()
