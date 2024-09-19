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
	var existing_decks: Array = SqlManager.db.select_rows("Decks", "name = '" + self.get_deck_name() + "'", ["id"])
	assert(existing_decks.size() == 1)
	
	# First delete all the cards, to avoid any constraints.
	var card_delete_result: bool = SqlManager.db.delete_rows("DeckCards", "deck = '" + String.num_int64(existing_decks[0]["id"]) + "'")
	assert(card_delete_result == true)
	
	# And now we can delete the deck itself
	var deck_delete_result: bool = SqlManager.db.delete_rows("Decks", "id = '" + String.num_int64(existing_decks[0]["id"]) + "'")
	assert(deck_delete_result == true)
	
	self.custom_deck_deleted.emit(self)

	self.queue_free()


func _on_deck_select_button_button_down() -> void:
	self.custom_deck_selected.emit(self)



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
	
	# Get the ID of the deck
	var existing_decks: Array = SqlManager.db.select_rows("Decks", "name = '" + for_deck_name + "'", ["id"])
	assert(existing_decks.size() == 1)
	
	var query_string : String = "SELECT count, suit, rank FROM DeckCards JOIN Cards ON Cards.id = DeckCards.card WHERE deck = ?;"
	var param_bindings : Array = [existing_decks[0]["id"]]
	
	var success: bool = SqlManager.db.query_with_bindings(query_string, param_bindings)
	assert(success)
	
	var deck_cards: Array[DeckCardWithCounter]
	for query_deck_card in SqlManager.db.query_result:
		var deck_card: DeckCardWithCounter = preload("res://Scenes/DeckCustomizer/deck_card_with_counter.tscn").instantiate()
		deck_card.card = Card.new(query_deck_card["suit"], query_deck_card["rank"])
		deck_card.set_card_count(query_deck_card["count"])
		deck_cards.append(deck_card)
	
	return deck_cards
