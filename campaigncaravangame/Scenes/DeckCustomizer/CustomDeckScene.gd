extends MarginContainer


class_name CustomDeckScene


signal custom_deck_deleted(custom_deck: CustomDeckScene)
signal custom_deck_selected(custom_deck: CustomDeckScene)


# TODO Kevin: We may be interested in storing the database ID here, somewhere


static func sanitize_deck_name(deck_name_in: String) -> String:
	const strip_charts: String = " "
	return deck_name_in.strip_edges().strip_escapes().lstrip(strip_charts).rstrip(strip_charts)


func set_deck_name(deck_name: String) -> void:
	%DeckSelectButton.text = deck_name


func get_deck_name() -> String:
	return sanitize_deck_name(%DeckSelectButton.text)


func _on_delete_deck_button_pressed() -> void:
	
	var success = SQLDB.connection.delete_custom_deck(self.get_deck_name())
	assert(success)
	
	self.get_parent().remove_child(self)
	self.queue_free()
	
	# TODO Kevin: Now that we've moved the SQL implimentation,
	#	we may also want to move the signal
	self.custom_deck_deleted.emit(self)


func _on_deck_select_button_pressed() -> void:
	self.custom_deck_selected.emit(self)


func set_selected(selected: bool) -> void:
	%DeckSelectButton.button_pressed = selected

func is_selected() -> bool:
	return %DeckSelectButton.is_pressed()
