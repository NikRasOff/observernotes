extends Control
class_name ProfileTab

signal changed_profile

@export var profile_name_edit:LineEdit
@export var confirm_button:Button

func _ready() -> void:
	confirm_button.pressed.connect(change_profile)
	setup_tab()

func setup_tab() -> void:
	await GameSettings.await_loaded()
	profile_name_edit.text = GameSettings.get_profile_name()

func change_profile() -> void:
	GameSettings.set_profile_name(profile_name_edit.text)
	changed_profile.emit()
