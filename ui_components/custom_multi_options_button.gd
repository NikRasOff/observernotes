@tool
class_name CustomMultiOptionButton
extends PanelContainer
## Select multiple options!

# signals
signal selection_updated(items:PackedInt32Array)

# consts

const down_arrow_texture:Texture2D = preload("res://icons/button_icons/down_small.png")
const checked_texture:Texture2D = preload("res://icons/button_icons/checked.png")
const unchecked_texture:Texture2D = preload("res://icons/button_icons/unchecked.png")

# exports

@export var debug_items:PackedStringArray
@export var placeholder_text:String = "Click to Select"
@export var character_limit:int = 30

# onready vars

# vars

var hcont:HBoxContainer
var main_label:RichTextLabel
var down_arrow:TextureRect
var option_popup:PopupPanel
var option_cont:VBoxContainer

var mouse_hovered:bool = false : set = set_mouse_hovered
var pressed:bool = false : set = set_pressed

var items:Array[CustomItemListItem]
var selected_items:PackedInt32Array

# built-in virtual function overrides

func _ready() -> void:
	build_node()
	setup()

func setup() -> void:
	if Engine.is_editor_hint():
		return
	for i in items:
		option_cont.add_child(i)
		i.rich_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		i.gui_input.connect(_option_gui_event.bind(items.find(i)))
	for i in debug_items:
		add_option(i)
	update_selection()
	option_popup.popup_hide.connect(_on_hide_popup)
	GameSettings.profile_settings_changed.connect(update_theme)
	await GameSettings.await_loaded()
	update_theme()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				pressed = true
				var pos := global_position
				pos.y += size.y
				option_popup.position = pos
				option_popup.size = option_cont.get_minimum_size()
				option_popup.popup()
			else:
				pressed = false

# base class function overrides

# functions

func build_node() -> void:
	theme_type_variation = "CustomOptionButton"
	hcont = HBoxContainer.new()
	add_child(hcont)
	
	main_label = RichTextLabel.new()
	main_label.bbcode_enabled = true
	main_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	main_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hcont.add_child(main_label)
	
	down_arrow = TextureRect.new()
	down_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	down_arrow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	down_arrow.texture = down_arrow_texture
	down_arrow.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	hcont.add_child(down_arrow)
	
	option_popup = PopupPanel.new()
	add_child(option_popup)
	
	option_cont = VBoxContainer.new()
	option_popup.add_child(option_cont)

func update_panel() -> void:
	if pressed:
		add_theme_stylebox_override("panel", get_theme_stylebox("pressed"))
	elif mouse_hovered:
		add_theme_stylebox_override("panel", get_theme_stylebox("hovered"))
	else:
		remove_theme_stylebox_override("panel")

func add_option(option_name:String) -> void:
	var new_option := CustomItemListItem.new(option_name, unchecked_texture, false)
	new_option.rich_label = true
	items.append(new_option)
	if is_node_ready():
		option_cont.add_child(new_option)
		new_option.rich_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		new_option.gui_input.connect(_option_gui_event.bind(items.size() - 1))
		update_selection()

func erase_options() -> void:
	for i in items:
		i.queue_free()
	main_label.text = ""
	items.clear()

func toggle_selection(id:int) -> void:
	var i := selected_items.find(id)
	if i != -1:
		selected_items.remove_at(i)
	else:
		selected_items.append(id)
	if is_node_ready():
		update_selection()
		selection_updated.emit(selected_items)

func handle_text_limit(s:String) -> String:
	#LimboConsole.info("---new---")
	var wip := s
	
	var regex = RegEx.new()
	regex.compile("\\[(?<tag>.*?)\\]")
	var results := regex.search_all(s)
	var open_tags:Array[String]
	var tags_to_close:Array[String]
	var start_cutoff_at:int = character_limit
	for res in results:
		#LimboConsole.info("Cutoff = " + str(start_cutoff_at))
		var start := res.get_start()
		var end := res.get_end()
		var closing:bool = (s[start + 1] == "/")
		var tag := res.get_string("tag").get_slice(" ", 0).get_slice("=", 0)
		if closing:
			tag = tag.substr(1)
		if start < start_cutoff_at:
			start_cutoff_at += end - start + 1
			if closing:
				if tag in open_tags:
					open_tags.remove_at(open_tags.rfind(tag))
					tags_to_close.append(tag)
			else:
				#LimboConsole.info("Start = " + str(start) + ", end = " + str(end))
				open_tags.append(tag)
		else:
			if closing:
				if tag in open_tags:
					open_tags.remove_at(open_tags.rfind(tag))
					tags_to_close.append(tag)
	wip = wip.left(start_cutoff_at)
	for ct in tags_to_close:
		wip += "[/" + ct + "]"
	return wip + " ..."
	#return GoodStuff.escape_bbcode(wip) + "..."

func count_chars(s:String) -> int:
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(s, "", true)
	return text_without_tags.length()

func update_selection() -> void:
	var new_text:String = ""
	var over_the_limit:bool = false
	for i in range(items.size()):
		if i in selected_items:
			if !over_the_limit:
				if !new_text.is_empty():
					new_text += ", "
				new_text += items[i].item_name
				if count_chars(new_text) >= character_limit:
					new_text = handle_text_limit(new_text)
					over_the_limit = true
			items[i].icon_texture_rect.texture = checked_texture
		else:
			items[i].icon_texture_rect.texture = unchecked_texture
	main_label.text = new_text
	if new_text.is_empty():
		main_label.text = placeholder_text
	main_label.custom_minimum_size.y = main_label.get_content_height() + 6
	main_label.custom_minimum_size.x = main_label.get_content_width() + 10

func update_theme() -> void:
	down_arrow.self_modulate = GameSettings.get_current_theme().main_color

# setters

func set_mouse_hovered(value:bool) -> void:
	mouse_hovered = value
	update_panel()

func set_pressed(value:bool) -> void:
	pressed = value
	update_panel()

func set_selected_items(value:PackedInt32Array) -> void:
	selected_items = value
	if is_node_ready():
		update_selection()

# getters

# virtual functions

func _on_mouse_entered() -> void:
	mouse_hovered = true

func _on_mouse_exited() -> void:
	mouse_hovered = false

func _option_gui_event(event:InputEvent, option_id:int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				toggle_selection(option_id)
			else:
				option_popup.hide()

func _on_hide_popup() -> void:
	pressed = false

# subclasses
