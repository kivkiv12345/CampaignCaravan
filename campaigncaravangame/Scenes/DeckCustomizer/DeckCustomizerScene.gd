extends HBoxContainer


class_name DeckCustomizer


#signal deck_customizer_save()
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
	
	for custom_deck in SQLDB.connection.query_custom_decks():
		self.insert_custom_deck_alph(custom_deck)


func _on_customizer_back_button_pressed() -> void:
	self.deck_customizer_back.emit()


#func _on_customizer_save_button_pressed() -> void:
	#self.deck_customizer_save.emit()



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
	
	var delta: int = 1
	if Input.is_action_pressed("MultiplierModifier"):
		delta *= 5
		
	if Input.is_action_pressed("NegatorModifier"):
		delta *= -1

	# See if the card is already in our chosen deck
	for deck_card in %CardsInDeckVBoxContainer.get_children():
		assert(deck_card is DeckCardWithCounter)

		if deck_card.card.compare(button.card):
			
			deck_card.set_card_count(deck_card.get_card_count()+delta)
			# TODO Kevin: Scroll to modified card
			return

	# Card was not in out chosen deck, add it.

	#	Actually, we just do this in code now
	# Copy from an existing node, to make it easier to copy signals
	#var new_deck_card: DeckCardWithCounter = %BaseDeckCardTextureButton.duplicate()
	#new_deck_card.visible = true  # We have likely hid the base

	var new_deck_card: DeckCardWithCounter = preload("res://Scenes/DeckCustomizer/DeckCardWithCounter.tscn").instantiate()  #%BaseDeckCardTextureButton.duplicate()

	new_deck_card.card = button.card
	
	new_deck_card.set_card_count(delta)

	self.insert_deck_card_ordered(new_deck_card)


var uniquecards_violators: Array[DeckCardWithCounter] = []
func _on_deck_card_card_count_changed(deck_card_with_counter: DeckCardWithCounter) -> void:
	
	if deck_card_with_counter.get_card_count() > 2:
		if deck_card_with_counter not in self.uniquecards_violators:
			self.uniquecards_violators.append(deck_card_with_counter)
	else:
		for violator in self.uniquecards_violators:
			# Nasty bug here, sometimes (with enough fervent clicking on cards)
			#	the card can be removed from the scene tree while staying in our violator array.
			#	In any case, let's clean those up, while we're at it.
			if violator.get_card_count() <= 2 or not violator.is_inside_tree():
				self.uniquecards_violators.erase(violator)

	var num_cards_total: int = 0
	for deck_cards in %CardsInDeckVBoxContainer.get_children():
		assert(deck_cards is DeckCardWithCounter)
		
		num_cards_total += deck_cards.get_card_count()
		
	%NumberOfCardsValueLabel.text = String.num_int64(num_cards_total)


	if self.uniquecards_violators.size() > 0:
		%UniqueCardsButton.button_pressed = false
		%UniqueCardsButton._update_checkbox_icon()
		#%UniqueCardsButton.tooltip = "This deck has more than 2 of some card"
	else:
		%UniqueCardsButton.button_pressed = true
		%UniqueCardsButton._update_checkbox_icon()
		#%UniqueCardsButton.tooltip = "This deck doesn't have more than 2 of any card"
	
	self.update_save_button_enabled_state()


func update_save_button_enabled_state() -> void:
	
	var entered_deck_name: String = CustomDeckScene.sanitize_deck_name(%DeckNameLineEdit.text)
	
	# Check that the name is valid enough to be saved.
	if entered_deck_name.length() == 0:
		%SaveDeckButton.disabled = true
		return
	
	if %CardsInDeckVBoxContainer.get_child_count() == 0:
		%SaveDeckButton.disabled = true
		return
		
	# Use empty name, because then it will always be different if no selected deck is found.
	var selected_deck_name: String = ""
	for custom_deck in %CustomDecksVBoxContainer.get_children():
		assert(custom_deck is CustomDeckScene)
		
		if custom_deck.is_selected():
			selected_deck_name = custom_deck.get_deck_name()
			break
	
	#var card_count_changed: bool = true
	if entered_deck_name == selected_deck_name:
		if self.compare_saved_cache(self._build_saved_cache()):
			#card_count_changed = false
			%SaveDeckButton.disabled = true
			return

	%SaveDeckButton.disabled = false


var saved_deck_cache: Dictionary = {}
func compare_saved_cache(compare_dict) -> bool:
	
	if self.saved_deck_cache.size() != compare_dict.size():
		return false

	for card_vector in self.saved_deck_cache:
		var card_count: int = self.saved_deck_cache[card_vector]

		if card_vector not in compare_dict:
			return false

		if compare_dict[card_vector] != card_count:
			return false
	
	return true


func _build_saved_cache() -> Dictionary:
	var deck_cache: Dictionary = {}
	for deck_cards in %CardsInDeckVBoxContainer.get_children():
		assert(deck_cards is DeckCardWithCounter)
		
		deck_cache[Vector2i(deck_cards.card.suit, deck_cards.card.rank)] = deck_cards.get_card_count()
		
	return deck_cache


const SaveCustomDeckResult = SQLDB.connection.SaveCustomDeckResult


func _on_deckcard_save_completed(save_result: SaveCustomDeckResult, deck_name: String) -> void:
	
	if save_result == SaveCustomDeckResult.SAVED_NEW:
		var new_custom_deck: CustomDeckScene = preload("res://Scenes/DeckCustomizer/CustomDeckScene.tscn").instantiate()
		new_custom_deck.set_deck_name(deck_name)
		
		self.insert_custom_deck_alph(new_custom_deck)
	
	
	for custom_deck in %CustomDecksVBoxContainer.get_children():
		assert(custom_deck is CustomDeckScene)
		
		if custom_deck.get_deck_name() == deck_name:
			custom_deck.set_selected(true)
		else:
			custom_deck.set_selected(false)
	
	# Update the cache of saved cards, so we can compare for changes.
	self.saved_deck_cache = self._build_saved_cache()
	self.update_save_button_enabled_state()


func _on_save_deck_button_pressed() -> void:

	var deck_name: String = CustomDeckScene.sanitize_deck_name(%DeckNameLineEdit.text)
	
	var deck_cards_arr: Array[DeckCardWithCounter] = []
	for deck_cards in %CardsInDeckVBoxContainer.get_children():
		assert(deck_cards is DeckCardWithCounter)
		deck_cards_arr.append(deck_cards)

	var save_result: SaveCustomDeckResult = SQLDB.connection.save_custom_deck(deck_name, deck_cards_arr, self._on_deckcard_save_completed.bind(deck_name).call)
	assert(save_result != SaveCustomDeckResult.FAILED)


func _on_deck_card_with_counter_entered_tree(node: Node) -> void:
	assert(node is DeckCardWithCounter)
	node.card_count_changed.connect(self._on_deck_card_card_count_changed)
	node.desire_texture_preview.connect(self._on_desire_texture_preview)
	#node.revoke_texture_preview.connect(self._on_revoke_texture_preview)


func insert_custom_deck_alph(deck_to_insert: CustomDeckScene) -> void:
	var insert_index: int = -1
	for custom_deck in %CustomDecksVBoxContainer.get_children():
		assert(custom_deck is CustomDeckScene)
		insert_index += 1
	
		# TODO Kevin: This doesn't seem very alphabetical
		if custom_deck.get_deck_name() > deck_to_insert.get_deck_name():
			break
	
	%CustomDecksVBoxContainer.add_child(deck_to_insert)
	%CustomDecksVBoxContainer.move_child(deck_to_insert, insert_index)


func _on_custom_deck_select_request_completed(deck_cards_arr: Array[DeckCardWithCounter]) -> void:
	
	for deck_cards in deck_cards_arr:
		self.insert_deck_card_ordered(deck_cards)
		
	# Update the cache of saved cards, so we can compare for changes.
	self.saved_deck_cache = self._build_saved_cache()
	self.update_save_button_enabled_state()

func _on_custom_deck_selected(selected_deck: CustomDeckScene) -> void:
	
	%DeckNameLineEdit.text = selected_deck.get_deck_name()
	%DeckNameLineEdit.text_changed.emit(selected_deck.get_deck_name())

	for custom_deck in %CustomDecksVBoxContainer.get_children():
		assert(custom_deck is CustomDeckScene)
		
		if custom_deck == selected_deck:
			custom_deck.set_selected(true)
		else:
			custom_deck.set_selected(false)

	for deck_cards in %CardsInDeckVBoxContainer.get_children():
		%CardsInDeckVBoxContainer.remove_child(deck_cards)
	
	# Async
	SQLDB.connection.query_deck_cards(selected_deck.get_deck_name(), self._on_custom_deck_select_request_completed.call)


func _on_custom_deck_deleted(deleted_deck: CustomDeckScene) -> void:
	
	if deleted_deck.get_deck_name() == CustomDeckScene.sanitize_deck_name(%DeckNameLineEdit.text):
		self.saved_deck_cache = {}
		self.update_save_button_enabled_state()


func _on_custom_deck_entered_tree(node: Node) -> void:
	assert(node is CustomDeckScene)
	node.custom_deck_selected.connect(self._on_custom_deck_selected)
	node.custom_deck_deleted.connect(self._on_custom_deck_deleted)


func _on_deck_name_changed(_new_text: String) -> void:
	self.update_save_button_enabled_state()


## Returns the decks that are shown in the customizer,
## with querying the database. They should already be synced anyway.
func get_custom_decks() -> Array[CustomDeckScene]:
	var custom_decks: Array[CustomDeckScene] = []
	for custom_deck in %CustomDecksVBoxContainer.get_children():
		assert(custom_deck is CustomDeckScene)
		custom_decks.append(custom_deck)
	return custom_decks
