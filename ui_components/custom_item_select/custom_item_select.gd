extends ScrollContainer

class_name CustomItemSelect

signal item_selected(item:CustomItemSelectItem)
signal item_deleted(item:CustomItemSelectItem)

@export var item_holder:VBoxContainer

var selected_item:CustomItemSelectItem

func add_item(item:CustomItemSelectItem) -> void:
	item_holder.add_child(item)
	item.item_selected.connect(unselect_other_items.bind(item))

func clear_items() -> void:
	for i in item_holder.get_children():
		i.queue_free()

func get_item(item_name:String) -> CustomItemSelectItem:
	for i in item_holder.get_children():
		var t:CustomItemSelectItem = i as CustomItemSelectItem
		if t.select_name == item_name:
			return t
	return null

func select_item(item_name:String) -> void:
	var item = get_item(item_name)
	if item == null:
		return
	item.is_selected = true

func delete_item(item_name:String) -> void:
	var item = get_item(item_name)
	if item == null:
		return
	if item.is_selected:
		if item_holder.get_child_count() > 1:
			var item_id := item.get_index()
			if item_id == 0:
				var new_item = item_holder.get_child(1) as CustomItemSelectItem
				new_item.is_selected = true
			else:
				var new_item = item_holder.get_child(item_id - 1) as CustomItemSelectItem
				new_item.is_selected = true
		else:
			selected_item = null
			item_selected.emit(null)
	item_deleted.emit(item)
	item.queue_free()

func unselect_other_items(item:CustomItemSelectItem) -> void:
	item_selected.emit(item)
	selected_item = item
	for i in item_holder.get_children():
		var item2:CustomItemSelectItem = i as CustomItemSelectItem
		if item2 != item:
			item2.is_selected = false
