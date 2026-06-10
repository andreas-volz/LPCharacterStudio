class_name JsonVFS
extends RefCounted

var _json_tree: TreeNode

## path->{sheet}
var _json_index: Dictionary = {}

class TreeNode:
	var name: String                        # folder or json file name
	var children: Array[TreeNode] = []      # sub folders
	var dicts: Dictionary = {}              # dict_name: String -> dict:Dictionary
	var relative_path: String = ""          # relative path from root
	
	## returns an Array of {name: String, dict: Dictionary} sorted by name
	func get_sorted_dicts() -> Array:
		var result: Array = []
		var sorted_dict_keys := dicts.keys()
		sorted_dict_keys.sort()
		for key in sorted_dict_keys:
			result.append({"name": key, "dict": dicts[key]})
		return result

## contructor to optional load JSON by path
func _init(root_path: String = ""):
	load_all_json(root_path)
	
## public function to fill the VFS by providing a root path
func load_all_json(root_path: String):
	_json_tree = _load_all_json_recusive(root_path)
	
func get_tree() -> TreeNode:
	return _json_tree
	
func get_index() -> Dictionary:
	return _json_index
	
## internal recusive loading of all json files
func _load_all_json_recusive(root_path: String, parent_path: String = "", leave :TreeNode = null) -> TreeNode:
	const FILE_EXT := "json"
	var dir = DirAccess.open(root_path)
	
	# create root node in first recursion
	if leave == null:
		leave = TreeNode.new()
		leave.name = "root" # dummy root name
	
	if DirAccess.get_open_error() == OK:
		var sub_dirs := dir.get_directories()
		var sub_files := dir.get_files()
		
		for sub_dir in sub_dirs:
			var sub_dir_abs := dir.get_current_dir() + "/" + sub_dir
			# build a relative path to root without "/" in the beginning
			var sub_dir_rel: String
			if parent_path.is_empty():
				sub_dir_rel = sub_dir
			else:
				sub_dir_rel = parent_path + "/" + sub_dir
			
			var item := TreeNode.new()
			leave.children.append(item)
			item.name = sub_dir
			item.relative_path = sub_dir_rel
			_load_all_json_recusive(sub_dir_abs, sub_dir_rel, item)
			
		for sub_file in sub_files:
			var sub_file_abs := dir.get_current_dir() + "/" + sub_file
			if FILE_EXT and (sub_file.get_extension() == FILE_EXT):
				var json = json_from_file(sub_file_abs)
				var key_name := sub_file.trim_suffix("." + FILE_EXT)
				leave.dicts[key_name] = json
				
				# put the dict reference in the index with a unique path
				var path_id := parent_path + "/" + key_name
				_json_index[path_id] = json
				
	return leave

static func json_from_file(file: String) -> Variant:
	var json_str = FileAccess.get_file_as_string(file)
	var json = JSON.parse_string(json_str)
	if json == null:
		push_error("JSON parsing failed: ", file)
	return json

static func json_to_file(dict: Dictionary, path: String):
	var pretty = JSON.stringify(dict, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(pretty)
	file.close()
