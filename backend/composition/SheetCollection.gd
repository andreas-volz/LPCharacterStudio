class_name SheetCollection
extends RefCounted

# -------------------------
# Internal properties
# -------------------------
var _entries: Dictionary = {}  ## Internal storage: key=SheetReference.type_name, value=SheetReference

# -------------------------
# Public API
# -------------------------

## factory method to create a SheetCollection in-place
static func make(refs: Array[SheetReference]) -> SheetCollection:
	var c = SheetCollection.new()
	for r in refs:
		c.register_sheet(r)
	return c

## Adds or updates a SheetReference for the given type_name.
## If the reference is invalid, it will be ignored with a warning.
func register_sheet(ref: SheetReference, match_body_color: bool = false) -> void:
	if not ref.is_valid():
		push_warning("Ignoring invalid SheetReference for key '%s'" % ref.type_name)
		return
		
	if match_body_color:
		var body_palette_selection: LPCPaletteSelection
		for palette_selection: LPCPaletteSelection in ref.get_palette_selections():
			if palette_selection.material_domain == "body":
				body_palette_selection = palette_selection
				
		# if there is a selected body color in the new SheetReference then assign this to all (if activated)
		if body_palette_selection:
			for sheet: SheetReference in _entries.values():
				for palette_selection: LPCPaletteSelection in sheet.get_palette_selections():
					if palette_selection.material_domain == "body":
						palette_selection.copy_from(body_palette_selection)
				
				
	_entries[ref.type_name] = ref

## Returns the SheetReference for the given type_name.
## The returned object is a direct reference to the internal state.
## If not found return the fallback (which is null by default)
func get_sheet(type_name: String, fallback: SheetReference = null) -> SheetReference:
	if _entries.has(type_name):
		return _entries[type_name]
	return fallback

## Removes the SheetReference for the given type_name.
## Returns true if the entry existed and was removed.
func remove_sheet(type_name: String) -> bool:
	return _entries.erase(type_name)

## Returns an Array of all keys currently stored.
func get_sheets_type_names() -> Array[String]:
	return SATFUtils.array_to_array_string(_entries.keys())

func get_sheets() -> Array[SheetReference]:
	var array: Array[SheetReference] = []
	for elem: SheetReference in _entries.values():
		array.append(elem)
	return array

## Returns a deep copy of this SheetCollection.
## All SheetReference objects are duplicated, so modifying the copy
## does not affect the original.
func clone() -> SheetCollection:
	var new_collection = SheetCollection.new()
	for key in _entries.keys():
		var ref: SheetReference = _entries[key]
		# Create a new SheetReference for deep copy
		new_collection._entries[key] = ref.clone()
	return new_collection

## Loads SheetReferences from a Dictionary.
## Returns false immediately if a critical error occurs.
## Invalid references are skipped with a warning.
func from_dict(data: Dictionary) -> bool:
	for key in data.keys():
		var entry = data[key]
		
		if not entry is Dictionary:
			push_error("Entry for key '%s' is not a Dictionary" % key)
			return false
		
		if not entry.has("path") or not entry.has("variant"):
			push_error("Entry for key '%s' must have 'path' and 'variant'" % key)
			return false
		
		var ref = SheetReference.new(key, entry["path"], entry["variant"])
		if not ref.is_valid():
			push_warning("Ignoring invalid SheetReference for key '%s'" % key)
			continue  # skip invalid entry without breaking completely
		
		_entries[key] = ref
	
	return true

## Serializes the SheetCollection to a Dictionary.
## The returned Dictionary can be used for saving or exporting
# TODO: this needs rework!
func to_dict() -> Dictionary:
	var dict = {}
	for k in _entries.keys():
		var ref = _entries[k]
		dict[k] = {"path": ref.path, "variant": ref.variant}
	return dict
