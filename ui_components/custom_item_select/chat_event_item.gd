class_name ChatEventItem
extends CustomItemListItem
## Displays chat event editors

signal delete_requested
signal reordering_requested(shift:int)

const delete_icon:Texture2D = preload("res://icons/button_icons/delete.png")
const down_arrow_texture:Texture2D = preload("res://icons/button_icons/down_small.png")
const up_arrow_texture:Texture2D = preload("res://icons/button_icons/up_small.png")

var vertical_container:VBoxContainer
var top_box_sep:HSeparator

var chat:Chat
var event:ChatEvent

func _init(t_event:ChatEvent, t_chat:Chat) -> void:
	chat = t_chat
	event = t_event
	item_name = event.get_event_name()
	has_icon = false
	has_button_deck = true

func _ready() -> void:
	super()
	update_panel_state()

func update_panel_state() -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("hover_panel"))

func build_node() -> void:
	super()
	vertical_container = VBoxContainer.new()
	add_child(vertical_container)
	
	main_container.reparent(vertical_container)
	
	top_box_sep = HSeparator.new()
	top_box_sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vertical_container.add_child(top_box_sep)
	
	for p in event.get_event_vars():
		var new_editor := build_event_editor(p)
		vertical_container.add_child(new_editor)
	
	add_button_to_deck(up_arrow_texture, "Shift Event Up", reordering_requested.emit.bind(-1))
	add_button_to_deck(down_arrow_texture, "Shift Event Down", reordering_requested.emit.bind(1))
	add_button_to_deck(delete_icon, "Delete Event", delete_requested.emit)

func build_event_editor(property:ChatEvent.ChatEventProperty) -> HBoxContainer:
	var new_editor := HBoxContainer.new()
	
	new_editor.tooltip_text = property.tooltip
	
	var new_label := Label.new()
	new_label.text = property.name
	new_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_editor.add_child(new_label)
	
	var sep := VSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	new_editor.add_child(sep)
	
	var property_value = event.get(property.property)
	
	match property.type:
		ChatEvent.PROPERTY_TYPE_FLOAT, ChatEvent.PROPERTY_TYPE_INT:
			var spinbox := SpinBox.new()
			spinbox.min_value = property.extra["min"]
			spinbox.max_value = property.extra["max"]
			spinbox.step = property.extra["step"]
			if spinbox.step <= 0.001:
				spinbox.custom_arrow_step = 0.1
			spinbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
			spinbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
			spinbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			spinbox.value = property_value
			new_editor.add_child(spinbox)
			
			spinbox.value_changed.connect(set_event_property.bind(property.property))
		ChatEvent.PROPERTY_TYPE_STRING:
			var line_edit := LineEdit.new()
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line_edit.text = property_value
			#var line_edit_menu := line_edit.get_menu()
			#var custom_item_id := line_edit_menu.item_count
			#line_edit_menu.add_item("Add Profile Mention", custom_item_id)
			#line_edit_menu.set_item_tooltip(custom_item_id, "Add a profile mention from the list of chat participants")
			
			new_editor.add_child(line_edit)
			
			line_edit.text_changed.connect(set_event_property.bind(property.property))
		ChatEvent.PROPERTY_TYPE_PROFILE:
			var option_button := CustomOptionButton.new()
			option_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
			option_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			new_editor.add_child(option_button)
			for p in chat.participants:
				option_button.add_option(p.get_profile_name())
			option_button.selected_item = property_value
			
			GameSettings.profile_settings_changed.connect(func():
				option_button.erase_options()
				for p in chat.participants:
					p.update_profile_name()
					option_button.add_option(p.get_profile_name())
				)
			option_button.item_selected.connect(set_event_property.bind(property.property))
		ChatEvent.PROPERTY_TYPE_PROFILE_ARRAY:
			var option_button := CustomMultiOptionButton.new()
			option_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
			option_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			new_editor.add_child(option_button)
			for p in chat.participants:
				option_button.add_option(p.get_profile_name())
			option_button.selected_items = property_value
			
			GameSettings.profile_settings_changed.connect(func():
				option_button.erase_options()
				for p in chat.participants:
					p.update_profile_name()
					option_button.add_option(p.get_profile_name())
				)
			option_button.selection_updated.connect(set_event_property.bind(property.property))
		_:
			var error_label := Label.new()
			error_label.text = "Unknown property type"
			error_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			error_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			new_editor.add_child(error_label)
			LimboConsole.error("Unknown property type: " + str(property.type))
	
	return new_editor

func set_event_property(to, property_name:String) -> void:
	event.set(property_name, to)
