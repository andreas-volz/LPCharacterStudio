class_name LPCPaletteSelection
extends RefCounted

## Represents a concrete palette choice for a material domain.
##
## A selection specifies which palette variant should be used and from
## which target collection it should be resolved.
##
## The material domain identifies the asset area being recolored, while
## the target collection determines where the selected palette variant
## should be looked up within the palette catalog.
##
## Palette selections are attached to sheet references and are later
## resolved into SATF palette bindings used by the runtime recoloring
## pipeline.

## Material domain of the asset being recolored (e.g. body, eye, cloth).
## Defines which part of the asset the palette selection applies to.
var material_domain: String

## Target palette collection used to resolve the selected palette variant
## within the palette catalog and compatibility rules.
var target_collection: LPCPaletteCollectionTarget

## Name of the PaletteVariant to apply (e.g. "blue", "yellow").
## The variant defines the selected color set used for recoloring.
var variant: String

enum PaletteResolveRule {
	PULL,
	PUSH,
	NEUTRAL
}
var palette_resolve_rule: PaletteResolveRule = PaletteResolveRule.PULL
var _priority_revision: int

func _init(domain_param: String = "", collection_param: LPCPaletteCollectionTarget = LPCPaletteCollectionTarget.new(), variant_param: String = "") -> void:
	material_domain = domain_param
	target_collection = collection_param
	variant = variant_param

func copy_from(other: LPCPaletteSelection):
	material_domain = other.material_domain
	target_collection = other.target_collection
	variant = other.variant
	palette_resolve_rule = other.palette_resolve_rule

func clone() -> LPCPaletteSelection:
	var new_selection := LPCPaletteSelection.new(material_domain, target_collection, variant)
	new_selection.palette_resolve_rule = palette_resolve_rule
	return new_selection

func from_dict(dict: Dictionary) -> bool:
	var result: bool = true
	
	if dict.has("material_domain"):
		material_domain = dict["material_domain"]
	else:
		push_warning("no 'material_domain' in Dictionary")
		result = false
		
	if dict.has("target_collection"):
		var target_collection_dict = dict["target_collection"]
		if target_collection_dict is Dictionary:
			target_collection.from_dict(target_collection_dict)
		
	if dict.has("variant"):
		variant = dict["variant"]
	else:
		push_warning("no 'variant' in Dictionary")
		result = false

	# TODO palette_resolve_rule

	return result

func to_dict() -> Dictionary:
	var dict := {}
	
	dict["material_domain"] = material_domain
	dict["target_collection"] = target_collection.to_dict()
	dict["variant"] = variant
	
	# TODO palette_resolve_rule
	
	return dict
