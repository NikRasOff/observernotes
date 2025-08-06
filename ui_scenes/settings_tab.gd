extends Control

@export var setting_container:VBoxContainer

const beep_test_sound:AudioStream = preload("res://sounds/beep1.mp3")

func _ready() -> void:
	var theme_setting := ThemeSettingEdit.new("selected_theme", "Theme")
	setting_container.add_child(theme_setting)
	
	var audio_label := SettingSeparationLabel.new("Audio Settings")
	setting_container.add_child(audio_label)
	
	var master_volume_setting := AudioSettingEdit.new("master_volume", "Master Volume")
	master_volume_setting.audio_bus = AudioServer.get_bus_index("Master")
	master_volume_setting.test_sound = beep_test_sound
	master_volume_setting.db_modify = -6
	setting_container.add_child(master_volume_setting)
	
	var hum_setting := BoolSettingEdit.new("ambient_hum", "Ambient Computer Hum")
	setting_container.add_child(hum_setting)
	
	var hum_video_setting := BoolSettingEdit.new("no_hum_on_video", "Pause Hum During Videos")
	hum_video_setting.add_dependency(hum_setting)
	setting_container.add_child(hum_video_setting)
	
	var hum_audio_setting := AudioSettingEdit.new("hum_volume", "Computer Hum Volume")
	hum_audio_setting.add_dependency(hum_setting)
	hum_audio_setting.audio_bus = AudioServer.get_bus_index("Hum")
	setting_container.add_child(hum_audio_setting)

func save_settings() -> void:
	GameSettings.save_profile_settings()
	Beeper.beep(1.1)
