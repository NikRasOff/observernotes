extends Control

@export var current_user_text:String = "Current user: "

@export var current_user_label:Label
@export var tab_bar:TabBar
@export var observations_tab:ObservationsTab
@export var profile_tab:ProfileTab
@export var exit_button:Button

func _ready() -> void:
	setup_ui()
	tab_bar.tab_changed.connect(change_tab)
	profile_tab.changed_profile.connect(update_profile)
	
	exit_button.pressed.connect(quit_btn)

func setup_ui() -> void:
	await GameSettings.await_loaded()
	update_profile()

func update_profile() -> void:
	current_user_label.text = current_user_text + GameSettings.get_profile_name()

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
		2:
			observations_tab.hide()
			profile_tab.show()
		_:
			LimboConsole.error("Not implemented yet")
