extends Control

@export var current_user_text:String = "Current user: "

@export var current_user_label:RichTextLabel
@export var tab_bar:TabBar
@export var observations_tab:ObservationsTab
@export var settings_tab:Control
@export var profile_tab:ProfileTab
@export var exit_button:Button
@export var ambient_hum:AudioStreamPlayer

func _ready() -> void:
	tab_bar.tab_changed.connect(change_tab)
	
	exit_button.pressed.connect(quit_btn)
	GameSettings.profile_settings_changed.connect(update_settings)
	ProgramStatus.update_hum.connect(update_hum_extra)

func update_settings() -> void:
	update_profile()
	update_hum()
	update_current_theme()

func update_profile() -> void:
	current_user_label.text = current_user_text + GameSettings.get_profile_name_with_effects()

func update_hum() -> void:
	if GameSettings.profile_settings.ambient_hum:
		ambient_hum.stream_paused = false
		ambient_hum.play()
	else:
		ambient_hum.stop()

## pauses/unpauses hum
func update_hum_extra(value:bool) -> void:
	if value:
		ambient_hum.stream_paused = false
	else:
		ambient_hum.stream_paused = true

func update_current_theme() -> void:
	var th := GameSettings.get_current_theme()
	theme = ResourceLoader.load(th.theme_file)
	RenderingServer.set_default_clear_color(th.clear_color)
	Input.set_custom_mouse_cursor(ResourceLoader.load(th.cursor_image))

func quit_btn() -> void:
	Beeper.beep(0.5)
	await Beeper.beep_player.finished
	get_tree().quit()

func change_tab(idx:int) -> void:
	Beeper.beep()
	match idx:
		0:
			observations_tab.show()
			profile_tab.hide()
			settings_tab.hide()
		1:
			observations_tab.hide()
			profile_tab.show()
			settings_tab.hide()
		2:
			observations_tab.hide()
			profile_tab.hide()
			settings_tab.show()
		_:
			LimboConsole.error("Not implemented yet")
