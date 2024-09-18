extends HBoxContainer


signal deck_customizer_save()
signal deck_customizer_back()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	%BaseDeckCardTextureButton.visible = false  # Base for cards in the selected deck
	%BaseCardPickerTextureButton.visible = false  # Base for cards to pick for the deck
	
	for card in Deck.base_deck:
		var card_texturebutton: DeckCustomizerCardButton = %BaseCardPickerTextureButton.duplicate()
		card_texturebutton.texture_normal = TextureManager.get_card_texture(card.suit, card.rank)
		card_texturebutton.visible = true
		#%CardScrollContainer.add_child(card_texturerect)
		%CardScrollHBoxContainer.add_child(card_texturebutton)


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


func _on_card_picker_picker_clicked(button: DeckCustomizerCardPickerButton) -> void:

	# See if the card is already in our chosen deck
	for deck_card in %CardsInDeckVBoxContainer.get_children():
		assert(deck_card is DeckCardWithCounter)

		if deck_card.card == button.card:
			deck_card.set_card_count(deck_card.get_card_count()+1)
			# TODO Kevin: Scroll to modified card
			return

	# Card was not in out chosen deck, add it.

	# Copy from an existing node, to make it easier to copy signals
	var new_deck_card: DeckCardWithCounter = %BaseDeckCardTextureButton.duplicate()
	new_deck_card.visible = true  # We have likely hid the base
	#var new_deck_card: DeckCardWithCounter = preload("res://Scenes/DeckCustomizer/deck_card_with_counter.tscn").instantiate()  #%BaseDeckCardTextureButton.duplicate()

	new_deck_card.card = button.card
	%CardsInDeckVBoxContainer.add_child(new_deck_card)


	# Move the newly added card to the correct index
	var new_card_index: int = new_deck_card.card.get_index()
	
	var card_move_index: int = -1
	for deck_card in %CardsInDeckVBoxContainer.get_children():
		assert(deck_card is DeckCardWithCounter)
		card_move_index += 1
		
		var deck_card_index: int = deck_card.card.get_index()
		
		if deck_card_index > new_card_index:
			break
	
	%CardsInDeckVBoxContainer.move_child(new_deck_card, card_move_index)
	
	# TODO Kevin: Scroll to added card.


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
