extends Resource

class_name ProfileObservationList

const filename:String = "authored_observations.tres"

@export var list:PackedStringArray

func update_fallback_names(with:String) -> void:
	for f in list:
		if !FileAccess.file_exists(f):
			continue
		var obs := (ResourceLoader.load(f) as Observation)
		obs.creator_reference.fallback_name = with
		ResourceSaver.save(obs)

func purge() -> void:
	for f in list:
		if !FileAccess.file_exists(f):
			continue
		var obs := (ResourceLoader.load(f) as Observation)
		obs.creator_reference.ignore_savename = true
		ResourceSaver.save(obs)
