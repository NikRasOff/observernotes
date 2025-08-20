extends Resource

## The thing to use when you need to reference a profile
class_name ProfileReference

@export var ignore_savename:bool
@export var savename:String
@export var fallback_name:String

var profile_name:String

func update_profile_name() -> void:
	if ignore_savename or !ProfileSettings.profile_exists(savename):
		if !ignore_savename:
			LimboConsole.warn("Profile " + savename + " not found, using fallback")
		profile_name = fallback_name
		return
	var profile_settings := ProfileSettings.get_from_profile(savename)
	profile_name = profile_settings.get_profile_name_with_effects()

func get_profile_name() -> String:
	if profile_name.is_empty():
		update_profile_name()
	return profile_name.replace("~censor~", GameSettings.get_current_theme().main_color.to_html())

func get_profile_name_raw() -> String:
	if profile_name.is_empty():
		update_profile_name()
	return profile_name

func get_profile() -> ProfileSettings:
	return ProfileSettings.get_from_profile(savename)

func get_profile_color() -> Color:
	return get_profile().chat_text_color

func is_current() -> bool:
	if ignore_savename:
		return false
	return savename == GameSettings.profile_settings.get_savename()
