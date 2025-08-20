extends CustomItemSelectItem

class_name ProfileItem

@export var deletable:bool = false

const delete_icon:Texture2D = preload("res://icons/button_icons/delete.png")
const profile_icon:Texture2D = preload("res://icons/button_icons/profile.png")

func _init(t_name:String, t_savename:String, t_deletable:bool = true) -> void:
	selectable = true
	item_name = t_name
	has_icon = true
	has_button_deck = true
	select_name = t_savename
	item_icon = profile_icon
	deletable = t_deletable

func build_node() -> void:
	super()
	if deletable:
		add_button_to_deck(delete_icon, "Delete profile", delete_requested.emit.bind(select_name))
