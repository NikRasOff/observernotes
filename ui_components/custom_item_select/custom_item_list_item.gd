extends PanelContainer

class_name CustomItemListItem

@export var item_name:String = "Item" : set = set_item_name
@export var has_icon:bool = false
@export var item_icon:Texture2D
@export var has_button_deck:bool = false

var main_container:HBoxContainer
var name_label:Label
var icon_texture_rect:TextureRect
var icon_separator:VSeparator
var button_deck_separator:VSeparator
var button_deck:BoxContainer

var mouse_inside:bool = false : set = set_mouse_inside

func _ready() -> void:
	build_node()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	GameSettings.profile_settings_changed.connect(update_theme)

func _init(t_name:String, t_icon:Texture2D = null, t_has_button_deck:bool = false) -> void:
	item_name = t_name
	has_icon = (t_icon != null)
	item_icon = t_icon
	has_button_deck = t_has_button_deck

func update_theme() -> void:
	var new_theme := GameSettings.get_current_theme()
	update_panel_state()
	if has_icon:
		icon_texture_rect.self_modulate = new_theme.main_color

func set_item_name(value:String) -> void:
	item_name = value
	if name_label == null:
		return
	name_label.text = value

func create_button(icon:Texture2D, tooltip:String) -> Button:
	var new_button = Button.new()
	new_button.icon = icon
	new_button.tooltip_text = tooltip
	new_button.theme_type_variation = "ToolButton"
	return new_button

func add_button_to_deck(icon:Texture2D, tooltip:String, callback:Callable) -> void:
	var button := create_button(icon, tooltip)
	button.pressed.connect(callback)
	button_deck.add_child(button)

func clear_button_deck() -> void:
	for button in button_deck.get_children():
		button.queue_free()

func build_node() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	focus_mode = Control.FOCUS_CLICK
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme_type_variation = "file_display_panel" # I'm too lazy to change the name
	
	main_container = HBoxContainer.new()
	add_child(main_container)
	
	if has_icon:
		icon_texture_rect = TextureRect.new()
		icon_texture_rect.self_modulate = GameSettings.get_current_theme().main_color
		icon_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_texture_rect.texture = item_icon
		icon_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		main_container.add_child(icon_texture_rect)
		
		icon_separator = VSeparator.new()
		main_container.add_child(icon_separator)
	
	name_label = Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_FILL
	name_label.text = item_name
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	main_container.add_child(name_label)
	
	if has_button_deck:
		button_deck_separator = VSeparator.new()
		main_container.add_child(button_deck_separator)
		
		button_deck = HBoxContainer.new()
		main_container.add_child(button_deck)

func update_panel_state() -> void:
	if mouse_inside:
		add_theme_stylebox_override("panel", get_theme_stylebox("hover_panel"))
	else:
		remove_theme_stylebox_override("panel")

func set_mouse_inside(value:bool) -> void:
	mouse_inside = value
	update_panel_state()

func _on_mouse_entered() -> void:
	mouse_inside = true

func _on_mouse_exited() -> void:
	mouse_inside = false
