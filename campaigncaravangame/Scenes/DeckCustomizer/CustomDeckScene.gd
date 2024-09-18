extends HBoxContainer


class_name CustomDeckScene


signal custom_deck_deleted(custom_deck: CustomDeckScene)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_delete_deck_button_pressed() -> void:
	
	# TODO Kevin: Drop from table
	
	self.custom_deck_deleted.emit(self)

	self.queue_free()
