@tool
extends Node

#@export var is_number_editable: bool:
	#set(value):
		#is_number_editable = value
		#notify_property_list_changed()
@export var number: int

func _validate_property(property: Dictionary):
	if property.name == "number":
		property.type = TYPE_INT
		property.usage |= PROPERTY_USAGE_CHECKABLE | PROPERTY_USAGE_EDITOR
		if number != null:
			property.usage |= PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_CHECKED
