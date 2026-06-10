class_name LPCPaletteCompatibility
extends RefCounted

## Defines palette compatibility rules for a specific material domain.
##
## Compatibility data describes which palette collections can be used by
## an asset and how palette selections should be interpreted. This allows
## assets to expose valid palette options without embedding palette data
## directly into the asset definition.
##
## The compatibility model acts as the bridge between asset definitions
## and the palette catalog.

## Material domain this compatibility definition belongs to (e.g. body, eye, cloth).
## Defines the asset/material scope for which palette rules are evaluated.
var material_domain: String

## TODO: document this, the usage it to remember palette changes while the asset is changed
## TODO: deprecated as this is done without - remove!
var type_name := OptionalString.new()

## Default palette collection used when no explicit selection is provided.
var base_collection := OptionalString.new()

## Default palette variant used as fallback when no variant is selected.
var base_variant := OptionalString.new()

## Human-readable label for editor/UI representation of this compatibility entry.
var label := OptionalString.new()

## List of allowed target collections that can be used for this material domain.
## Each entry defines a valid palette source within the palette catalog.
var collections: Array[LPCPaletteCollectionTarget]

## Optional list of palette source identifiers used for legacy or external mapping.
## Some assets source palettes are specified direct in the asset and not referenced
## to the palette catalog
var palette_source: Array [String] = []
