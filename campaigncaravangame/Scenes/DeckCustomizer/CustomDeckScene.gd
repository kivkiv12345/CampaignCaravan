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
	
	SqlManager.ensure_database()

	var success: bool = true
	success = SqlManager.db.query_with_bindings("SELECT id FROM Decks WHERE name = ?", [self.get_deck_name(),])
	assert(success)

	var existing_decks: Array[Dictionary] = SqlManager.db.query_result
	assert(existing_decks.size() == 1)

	# First delete all the cards, to avoid any constraints.
	success = SqlManager.db.query_with_bindings("DELETE FROM DeckCards WHERE deck = ?", [existing_decks[0]["id"],])
	assert(success)

	# And now we can delete the deck itself
	success = SqlManager.db.query_with_bindings("DELETE FROM Decks WHERE id = ?", [existing_decks[0]["id"],])
	assert(success)
	
	self.get_parent().remove_child(self)
	self.queue_free()
	
	self.custom_deck_deleted.emit(self)


func _on_deck_select_button_pressed() -> void:
	self.custom_deck_selected.emit(self)


func set_selected(selected: bool) -> void:
	%DeckSelectButton.button_pressed = selected

func is_selected() -> bool:
	return %DeckSelectButton.is_pressed()


static func query_custom_decks() -> Array[CustomDeckScene]:
	SqlManager.ensure_database()
	
	var decks_query_result: Array = SqlManager.db.select_rows("Decks", "", ["*"])
	
	var custom_decks: Array[CustomDeckScene] = []
	for query_deck in decks_query_result:
		var custom_deck: CustomDeckScene = preload("res://Scenes/DeckCustomizer/CustomDeckScene.tscn").instantiate()
		custom_deck.set_deck_name(query_deck["name"])
		custom_decks.append(custom_deck)
	
	return custom_decks


static func query_deck_cards(for_deck_name: String) -> Array[DeckCardWithCounter]:
	SqlManager.ensure_database()
	
	var success: bool = true

	# Get the ID of the deck
	success = SqlManager.db.query_with_bindings("SELECT id FROM Decks WHERE name = ?", [for_deck_name,])
	assert(success)

	var existing_decks: Array[Dictionary] = SqlManager.db.query_result
	assert(existing_decks.size() == 1)
	
	var query_string : String = "SELECT count, suit, rank FROM DeckCards JOIN Cards ON Cards.id = DeckCards.card WHERE deck = ?;"
	var param_bindings : Array = [existing_decks[0]["id"]]
	
	success = SqlManager.db.query_with_bindings(query_string, param_bindings)
	assert(success)
	
	var deck_cards: Array[DeckCardWithCounter]
	for query_deck_card in SqlManager.db.query_result:
		var deck_card: DeckCardWithCounter = preload("res://Scenes/DeckCustomizer/DeckCardWithCounter.tscn").instantiate()
		deck_card.card = Card.new(query_deck_card["suit"], query_deck_card["rank"])
		deck_card.set_card_count(query_deck_card["count"])
		deck_cards.append(deck_card)
	
	return deck_cards
