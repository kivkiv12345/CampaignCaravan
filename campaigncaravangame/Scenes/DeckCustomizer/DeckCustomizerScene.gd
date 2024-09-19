extends HBoxContainer


signal deck_customizer_save()
signal deck_customizer_back()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#%BaseDeckCardTextureButton.visible = false  # Base for cards in the selected deck
	%BaseCardPickerTextureButton.visible = false  # Base for cards to pick for the deck
	
	for card in Deck.base_deck:
		var card_texturebutton: DeckCustomizerCardButton = %BaseCardPickerTextureButton.duplicate()
		card_texturebutton.texture_normal = TextureManager.get_card_texture(card.suit, card.rank)
		card_texturebutton.visible = true
		#%CardScrollContainer.add_child(card_texturerect)
		%CardScrollHBoxContainer.add_child(card_texturebutton)
	

	# Bit of a hack to make sure save button state is correct.
	self._on_deck_name_changed(%DeckNameLineEdit.text)
	
	for custom_deck in CustomDeckScene.query_custom_decks():
		self.insert_custom_deck_alph(custom_deck)


func _on_customizer_back_button_pressed() -> void:
	self.deck_customizer_back.emit()


func _on_customizer_save_button_pressed() -> void:
	self.deck_customizer_save.emit()



func _on_desire_texture_preview(texture: Texture2D) -> void:
	%CardViewerTextureRect.texture = texture


func _on_revoke_texture_preview(texture: Texture2D) -> void:
	if %CardViewerTextureRect.texture != texture:
		return  # Somebody has already replaced the texture we are trying to revoke.
	%CardViewerTextureRect.texture = null


func insert_deck_card_ordered(insert_deck_card: DeckCardWithCounter) -> void:
	
	%CardsInDeckVBoxContainer.add_child(insert_deck_card)
	
	# Move the newly added card to the correct index
	var new_card_index: int = insert_deck_card.card.get_index()
	
	var card_move_index: int = -1
	for deck_card in %CardsInDeckVBoxContainer.get_children():
		assert(deck_card is DeckCardWithCounter)
		card_move_index += 1
		
		var deck_card_index: int = deck_card.card.get_index()
		
		if deck_card_index > new_card_index:
			break
	
	%CardsInDeckVBoxContainer.move_child(insert_deck_card, card_move_index)
	
	# TODO Kevin: Scroll to added card.


func _on_card_picker_picker_clicked(button: DeckCustomizerCardPickerButton) -> void:

	# See if the card is already in our chosen deck
	for deck_card in %CardsInDeckVBoxContainer.get_children():
		assert(deck_card is DeckCardWithCounter)

		if deck_card.card.compare(button.card):
			deck_card.set_card_count(deck_card.get_card_count()+1)
			# TODO Kevin: Scroll to modified card
			return

	# Card was not in out chosen deck, add it.

	#	Actually, we just do this in code now
	# Copy from an existing node, to make it easier to copy signals
	#var new_deck_card: DeckCardWithCounter = %BaseDeckCardTextureButton.duplicate()
	#new_deck_card.visible = true  # We have likely hid the base

	var new_deck_card: DeckCardWithCounter = preload("res://Scenes/DeckCustomizer/deck_card_with_counter.tscn").instantiate()  #%BaseDeckCardTextureButton.duplicate()

	new_deck_card.card = button.card

	self.insert_deck_card_ordered(new_deck_card)


var uniquecards_violators: Array[DeckCardWithCounter] = []
func _on_deck_card_card_count_changed(deck_card_with_counter: DeckCardWithCounter) -> void:
	
	if deck_card_with_counter.get_card_count() > 2:
		if deck_card_with_counter not in self.uniquecards_violators:
			self.uniquecards_violators.append(deck_card_with_counter)
	else:
		if deck_card_with_counter in self.uniquecards_violators:
			self.uniquecards_violators.erase(deck_card_with_counter)

	if self.uniquecards_violators.size() > 0:
		#%UniqueCardsButton.set_pressed(false)
		#%UniqueCardsButton.disabled = false
		%UniqueCardsButton.button_pressed = false
		%UniqueCardsButton._update_checkbox_icon()
		#%UniqueCardsButton.tooltip = "This deck has more than 2 of some card"
	else:
		#%UniqueCardsButton.disabled = false
		#%UniqueCardsButton.set_pressed(true)
		%UniqueCardsButton.button_pressed = true
		%UniqueCardsButton._update_checkbox_icon()
		#%UniqueCardsButton.tooltip = "This deck doesn't have more than 2 of any card"


func _on_save_deck_button_pressed() -> void:

	
	var deck_name: String = CustomDeckScene.sanitize_deck_name(%DeckNameLineEdit.text)
	
	SqlManager.ensure_database()
	var existing_decks: Array = SqlManager.db.select_rows("Decks", "name = '" + deck_name + "'", ["id"])
	
	# Reuse variable, to avoid warning
	var insert_result: bool = true
	
	assert(existing_decks.size() <= 1)  # It shouldn't be possible to have multiple decks with the same name
	var saved_new: bool = false
	if existing_decks.size() == 0:  # A deck with this name doesn't exist.
		insert_result = SqlManager.db.insert_row("Decks", {"name": deck_name})
		assert(insert_result == true, "I'm not gonna bother with what happens if we can't insert decks, for now")
		
		# Now we need to get the primary key
		existing_decks = SqlManager.db.select_rows("Decks", "name = '" + deck_name + "'", ["id"])
		assert(existing_decks.size() == 1)
		saved_new = true
	
	
	var deckcard_data: Array[Dictionary] = []
	for deck_cards in %CardsInDeckVBoxContainer.get_children():
		assert(deck_cards is DeckCardWithCounter)
		
		var card_vector: Vector2i = TextureManager.get_card_from_texture(deck_cards.texture_normal)
		var card: Card = Card.new(card_vector.x, card_vector.y)
		
		# ensure_database creates the database, such that Cards.pk == Card.get_index()+1 
		deckcard_data.append({"deck": existing_decks[0]["id"], "card": card.get_index()+1, "count": deck_cards.get_card_count()})

	# Just delete all the existing cards, and insert new ones, because we're lazy.
	SqlManager.db.delete_rows("DeckCards", "deck = '" + String.num_int64(existing_decks[0]["id"]) + "'")

	insert_result = SqlManager.db.insert_rows("DeckCards", deckcard_data)
	assert(insert_result == true, "I'm not gonna bother with what happens if we can't insert decks, for now")
	
	if saved_new:
		var new_custom_deck: CustomDeckScene = preload("res://Scenes/DeckCustomizer/CustomDeckScene.tscn").instantiate()
		new_custom_deck.set_deck_name(deck_name)
		
		self.insert_custom_deck_alph(new_custom_deck)


func _on_deck_card_with_counter_entered_tree(node: Node) -> void:
	assert(node is DeckCardWithCounter)
	node.card_count_changed.connect(self._on_deck_card_card_count_changed)
	node.desire_texture_preview.connect(self._on_desire_texture_preview)
	node.revoke_texture_preview.connect(self._on_revoke_texture_preview)


func insert_custom_deck_alph(deck_to_insert: CustomDeckScene) -> void:
	var insert_index: int = -1
	for custom_deck in %CustomDecksVBoxContainer.get_children():
		assert(custom_deck is CustomDeckScene)
		insert_index += 1
	
		if custom_deck.get_deck_name() > deck_to_insert.get_deck_name():
			break
	
	%CustomDecksVBoxContainer.add_child(deck_to_insert)
	%CustomDecksVBoxContainer.move_child(deck_to_insert, insert_index)



func _on_custom_deck_selected(custom_deck: CustomDeckScene):
	
	%DeckNameLineEdit.text = custom_deck.get_deck_name()
	%DeckNameLineEdit.text_changed.emit(custom_deck.get_deck_name())
	
	for deck_cards in %CardsInDeckVBoxContainer.get_children():
		%CardsInDeckVBoxContainer.remove_child(deck_cards)
		
	for deck_cards in CustomDeckScene.query_deck_cards(custom_deck.get_deck_name()):
		self.insert_deck_card_ordered(deck_cards)


func _on_custom_deck_entered_tree(node: Node) -> void:
	assert(node is CustomDeckScene)
	node.custom_deck_selected.connect(self._on_custom_deck_selected)


func _on_deck_name_changed(new_text: String) -> void:
	if CustomDeckScene.sanitize_deck_name(new_text).length() == 0:
		%SaveDeckButton.disabled = true
	else:
		%SaveDeckButton.disabled = false
