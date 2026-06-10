extends HFlowContainer

#signal variant_selected(sheet_reference: SheetReference)

const VARIANT_CONTAINER = preload("uid://dsmikhx2smbl8")

@onready var variant_scale_control: VariantScaleControl = %VariantScaleControl
@onready var variant_preview_scale_slider: HSlider = %VariantPreviewScaleSlider

func clear():
	for child in get_children():
		child.queue_free()

func add_preview(asset_variant_view_model: AssetVariantViewModel):
	var variant_container: VariantContainer = VARIANT_CONTAINER.instantiate()
	add_child(variant_container)
	
	variant_container.set_view_model(asset_variant_view_model)
	
	# connect the signal from the scale slider...and intiialize the control with the current slider value
	variant_scale_control.variant_scaled.connect(variant_container._on_set_variant_scale)
	variant_container._on_set_variant_scale(variant_preview_scale_slider.value)
	
	var variant_tooltip_text: String
	#if sheet_reference.asset_reference.variant.has_value():
		#variant_tooltip_text = sheet_reference.asset_reference.variant.get_or()
	#elif not sheet_reference.palette_selections.is_empty():
		#var palette: LPCPaletteSelection = sheet_reference.palette_selections.front()
		#variant_tooltip_text = palette.collection.material_domain.get_or() + "." + palette.collection.value + "." + palette.variant
	#else:
		#pass
		
	#satf_sprite_control.tooltip_text = variant_tooltip_text
	
