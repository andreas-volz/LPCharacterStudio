# Global class ApplicationController
extends Node

signal apply_sheet_collection_intent

func handle_intent(intent: Intent):
	if intent is ApplySheetCollectionIntent:
		_on_apply_sheet_collection_intent(intent)
	pass

func _on_apply_sheet_collection_intent(intent: ApplySheetCollectionIntent):
	ApplicationContext.sheet_collection_active = intent.sheet_collection
	
	apply_sheet_collection_intent.emit()
