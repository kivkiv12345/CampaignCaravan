extends CardSlot

class_name DiscardCardSlot


func _animate_card_removal(hand_card: CardHandSlot) -> void:
	
	# Store the original z-index before moving the card,
	#	so we can correctly render cards in the middle of caravans when animating their removal.
	var original_z_index = hand_card.get_z_index()
	var original_global_position = hand_card.global_position
	
	hand_card.hand.find_child("CardsToRemove", false).add_child(hand_card)
	
	# Restore its z-index to maintain its drawing order,
	#	which will have been borked when we moved number_card to $CardsToRemove
	hand_card.set_z_index(original_z_index)
	hand_card.global_position = self.global_position

	# Get the viewport size to determine how far off-screen the card should move
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var offscreen_distance: float = viewport_rect.size.x*2  # Move down by the height of the viewport
	
	var tween: Tween = self.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var target_position: Vector2 = Vector2(offscreen_distance, self.global_position.y)
	
	# Animate the card
	tween.tween_property(hand_card, "global_position", target_position, 1)
	
	# Use a callback to remove the card after the animation completes
	tween.tween_callback(func():

		hand_card.queue_free()
	)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DraggedCard:
		return false  # Under no circumstances can we drop something which is not a card.
		
	var card_data: CardHandSlot = data.source
	
	return card_data.hand.can_discard_card(data.source)


func _drop_data(_pos: Vector2, data: Variant) -> void:
	
	assert(data is DraggedCard)

	if (self.try_play_card(data.source, true)):
		# This is a bit hacky.
		#	because we don't set the destination,
		#	the DraggedCard, will return to the hand slot, which we move here.
		#	Fortunatly it's not possible to play this card again,
		#	because it's still removed from Hand.$Cards
		data.destination = null


func can_play_card(hand_card: CardHandSlot) -> bool:
	return hand_card.hand.can_discard_card(hand_card)
	
func try_play_card(hand_card: CardHandSlot, _animate: bool = true) -> bool:
	
	# Don't animate the removal from the hand, we will handle it from here.
	var success: bool = hand_card.hand.try_discard_card(hand_card, false)
	
	if success and _animate:
		self._animate_card_removal(hand_card)
	
	return success
