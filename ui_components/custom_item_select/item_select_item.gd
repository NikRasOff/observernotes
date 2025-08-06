extends CustomItemListItem

class_name CustomItemSelectItem

signal item_selected

@export var selectable:bool = false
@export var select_name:String = "item"

var is_selected:bool = false : set = set_is_selected

func _init(t_name:String, t_selectable:bool = false, t_has_button_deck:bool = false, t_icon:Texture2D = null) -> void:
	selectable = t_selectable
	item_name = t_name
	has_icon = (t_icon != null)
	has_button_deck = t_has_button_deck
	item_icon = t_icon

func set_is_selected(value:bool) -> void:
	is_selected = value
	update_panel_state()
	if is_selected:
		item_selected.emit()

func update_panel_state() -> void:
	if mouse_inside:
		if is_selected:
			add_theme_stylebox_override("panel", get_theme_stylebox("hover_selected"))
		else:
			add_theme_stylebox_override("panel", get_theme_stylebox("hover_panel"))
	else:
		if is_selected:
			add_theme_stylebox_override("panel", get_theme_stylebox("selected"))
		else:
			remove_theme_stylebox_override("panel")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			is_selected = true
