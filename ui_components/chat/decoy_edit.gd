extends LineEdit

func _ready() -> void:
	GameSettings.profile_settings_changed.connect(update_theme)

func update_theme() -> void:
	add_theme_stylebox_override("read_only", get_theme_stylebox("normal"))
	add_theme_color_override("font_uneditable_color", get_theme_color("font_color"))
