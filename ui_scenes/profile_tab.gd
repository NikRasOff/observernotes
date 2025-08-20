extends Control
class_name ProfileTab

const delete_icon:Texture2D = preload("res://icons/button_icons/delete.png")

@export var profile_select:CustomItemSelect

@export var profile_name_edit:LineEdit
@export var confirm_button:Button
@export var profile_attributes:VBoxContainer

func _ready() -> void:
	var name_censored_setting := BoolSettingEdit.new("name_censored", "Censor Name")
	profile_attributes.add_child(name_censored_setting)
	var admin_setting := BoolSettingEdit.new("admin_profile", "Administrator")
	admin_setting.tooltip_text = "If yes, can edit all profiles, not just their own"
	profile_attributes.add_child(admin_setting)
	admin_setting.hide()
	var color_setting := ColorSettingEdit.new("chat_text_color", "Chat Text Color")
	color_setting.tooltip_text = "Color used when displaying this profile's texts in the Chats tab"
	profile_attributes.add_child(color_setting)
	
	profile_select.item_selected.connect(select_profile)
	profile_select.item_deleted.connect(delete_profile)
	GameSettings.profile_settings_changed.connect(update_profile_info)
	confirm_button.pressed.connect(confirm_profile_changes)
	setup_tab()

func setup_tab() -> void:
	await GameSettings.await_loaded()
	for profile_name in DirAccess.get_directories_at(ProfileSettings.profile_save_dir):
		var profile_settings := ProfileSettings.get_from_profile(profile_name)
		if profile_settings == null or profile_settings.hidden:
			continue
		var profile_item := ProfileItem.new(profile_settings.profile_name, profile_name, !profile_settings.undeletable)
		profile_select.add_item(profile_item)
	profile_select.select_item(GameSettings.global_settings.current_profile)
	
	update_profile_info()

func update_profile_info() -> void:
	profile_name_edit.text = GameSettings.profile_settings.profile_name

func select_profile(profile_item:CustomItemSelectItem) -> void:
	if profile_item == null:
		GameSettings.change_profile(GlobalSettings.persistent_profile_name)
		return
	if profile_item.select_name == GameSettings.global_settings.current_profile:
		return
	GameSettings.change_profile(profile_item.select_name)
	Beeper.beep()

func delete_profile(profile_item:CustomItemSelectItem) -> void:
	GameSettings.delete_profile(profile_item.select_name)
	Beeper.beep(0.5)

func create_new_profile() -> void:
	var new_savename := GameSettings.create_profile()
	var new_settings := ProfileSettings.get_from_profile(new_savename)
	var new_item := ProfileItem.new(new_settings.profile_name, new_savename, true)
	profile_select.add_item(new_item)
	Beeper.beep(1.1, 2)

func confirm_profile_changes() -> void:
	GameSettings.profile_settings.profile_name = profile_name_edit.text
	profile_select.get_item(GameSettings.global_settings.current_profile).item_name = GameSettings.profile_settings.profile_name
	GameSettings.profile_settings.get_obs_list().update_fallback_names(GameSettings.profile_settings.get_profile_name_with_effects())
	GameSettings.save_profile_settings()
	Beeper.beep(1.1)
