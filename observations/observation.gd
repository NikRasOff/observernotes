extends Resource
## The thing this whole program was made for
class_name Observation

enum {
	TYPE_VIDEO,
	TYPE_PHOTO,
	TYPE_TEXT
}

@export_enum("Footage", "Photograph", "Text") var type:int = TYPE_VIDEO
@export var title:String
@export var creator:String
@export var note:String
@export var files:PackedStringArray
@export var text:String
