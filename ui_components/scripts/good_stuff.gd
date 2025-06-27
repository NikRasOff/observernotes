extends Object
## is good
##
## Just a bunch of stuff that I might need
class_name GoodStuff

static func get_dir_contents(dir_path:String) -> Dictionary:
	var file_array:PackedStringArray
	var dir_array:PackedStringArray
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				dir_array.append(dir_path + "/" + file_name)
			else:
				file_array.append(dir_path + "/" + file_name)
			file_name = dir.get_next()
	else:
		LimboConsole.error("An error occurred when trying to access the path.")
	return {"files":file_array,"dirs":dir_array}

## Returns extention with a dot
static func get_extention(file_path:String) -> String:
	var ext = file_path.get_extension()
	if ext.is_empty():
		return ""
	return "." + ext

## Returns the number on the end of the string
static func get_ending_int(st_string:String) -> String:
	var result := ""
	for i in len(st_string):
		var cur_int = st_string.right(i + 1)
		if cur_int.is_valid_int():
			result = cur_int
		else:
			return result
	return result

## Increments the number at the end of a string
static func increment_string(st_string:String) -> String:
	var string_num = get_ending_int(st_string)
	var st_num:int
	if string_num.is_empty():
		st_num = 1
	else:
		st_num = int(string_num) + 1
	return st_string.trim_suffix(string_num) + str(st_num)

## Renames a directory while avoiding conflicts
static func safe_dir_rename(from:String, to:String) -> Dictionary:
	var cur_path := get_safe_path_dir(to)
	var rename_result = DirAccess.rename_absolute(from, cur_path)
	return {"rename_path": cur_path, "result": rename_result}

## Renames a file while avoiding conflicts
static func safe_file_rename(from:String, to:String) -> Dictionary:
	var cur_path := get_safe_path_file(to)
	var rename_result = DirAccess.rename_absolute(from, cur_path)
	return {"rename_path": cur_path, "result": rename_result}

## Creates a directory while avoiding conflicts
static func safe_dir_create(path:String) -> Error:
	var cur_path := get_safe_path_dir(path)
	return DirAccess.make_dir_absolute(cur_path)

## Saves a res while avoiding conflicts
static func safe_resource_save(s_res:Resource, path:String) -> Dictionary:
	var cur_path := get_safe_path_res(path)
	return {"save_path": cur_path, "result": ResourceSaver.save(s_res, cur_path)}

## Gets a confict-free path for a resource
static func get_safe_path_res(from:String) -> String:
	var cur_path := from
	while ResourceLoader.exists(cur_path):
		cur_path = increment_string(cur_path.get_basename()) + get_extention(cur_path) 
	return cur_path

## Gets a confict-free path for a directory
static func get_safe_path_dir(from:String) -> String:
	var cur_path := from
	while DirAccess.dir_exists_absolute(cur_path):
		cur_path = increment_string(cur_path.get_basename()) + get_extention(cur_path) 
	return cur_path

## Gets a confict-free path for a file
static func get_safe_path_file(from:String) -> String:
	var cur_path := from
	while FileAccess.file_exists(cur_path):
		cur_path = increment_string(cur_path.get_basename()) + get_extention(cur_path) 
	return cur_path

## Copies a file or directory while avoiding conflicts
static func safe_copy(from:String, to:String):
	if from.is_empty():
		return
	if from.get_extension().is_empty():
		if !DirAccess.dir_exists_absolute(from):
			return
		var base_dir = get_safe_path_dir(to + "/" + from.get_file())
		DirAccess.make_dir_absolute(base_dir)
		var file_track = get_dir_contents(from)
		while !file_track["dirs"].is_empty():
			LimboConsole.info("Creating dir: " + str(DirAccess.make_dir_absolute(to + "/" + base_dir.get_file() + "/" + file_track["dirs"][0].trim_prefix(from))))
			var f_in_dir = GoodStuff.get_dir_contents(file_track["dirs"][0])
			file_track["dirs"].remove_at(0)
			file_track["dirs"].append_array(f_in_dir["dirs"])
			file_track["files"].append_array(f_in_dir["files"])
		for i in file_track["files"]:
			LimboConsole.info("Copying file: " + str(DirAccess.copy_absolute(i, to + "/" + base_dir.get_file() + "/" + i.trim_prefix(from))))
	else:
		if !FileAccess.file_exists(from):
			return
		LimboConsole.info(str(DirAccess.copy_absolute(from, get_safe_path_res(to + "/" + from.get_file()))))

static func safe_move(path:String, to:String, is_dir:bool) -> void:
	if path.is_empty():
		return
	if is_dir:
		var new_path = get_safe_path_dir(to + "/" + path.get_file())
		DirAccess.rename_absolute(path, new_path)
	else:
		var new_path = get_safe_path_file(to + "/" + path.get_file())
		DirAccess.rename_absolute(path, new_path)

## Creates a directory and all preceding directories
static func make_dir_good(path:String):
	while !DirAccess.dir_exists_absolute(path):
		var cur_path := path
		while !DirAccess.dir_exists_absolute(cur_path.get_base_dir()):
			cur_path = cur_path.get_base_dir()
		LimboConsole.info("Creating dir: " + str(DirAccess.make_dir_absolute(cur_path)))

## Saves a res to a path and creates all necessary directories
static func save_res_to(res:Resource, path:String="") -> Error:
	if path.is_empty():
		make_dir_good(res.resource_path.get_base_dir())
	else:
		make_dir_good(path.get_base_dir())
	return ResourceSaver.save(res, path)

static func get_double_timestamp(max:float, cur:float) -> String:
	var max_sec := int(floor(max))
	var result = get_timestamp(cur, max >= 3600) + "/" + get_timestamp(max)
	return result

## Turns a number of seconds into a timestamp
static func get_timestamp(sec:float, hours:bool=false) -> String:
	var sec_int := int(floor(sec))
	var sec_number := sec_int % 60
	var min_number := (sec_int / 60) % 60
	var hour_number := sec_int / 3600
	
	var result:String
	
	if hour_number != 0 or hours:
		result += str(hour_number) + ":"
	if min_number < 10:
		result += "0"
	result += str(min_number) + ":"
	if sec_number < 10:
		result += "0"
	result += str(sec_number)
	
	return result
