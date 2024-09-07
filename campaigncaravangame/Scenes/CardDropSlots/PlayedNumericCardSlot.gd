extends CaravanCardSlot

class_name PlayedNumericCardSlot


func _play_face_card(hand_card: CardHandSlot) -> void:
	
	var played_card: Node = preload("res://Scenes/CardDropSlots/PlayedCardSlot.tscn").instantiate()
	
	# TODO Kevin: This is pretty nasty,
	#	but we currently don't have need for a proper FaceCardSlot.tscn scene,
	#	so we just apply the script.
	played_card.script = FaceCardSlot
	assert(played_card is FaceCardSlot)
	
	# Apparently changing the script resets the card field, so it must be done first.
	played_card.set_card(hand_card.card)
	
	# Also it seems that the _register_cardslot_to_caravan()
	#	signal (on Caravan) isn't called recursivly.
	#	So our face cards will not automatially be registered.
	#	Which is why we do it here.
	played_card.caravan = self.caravan

	played_card.position = $OpenFaceCardSlot.position

	$PlayedFaceCards.add_child(played_card)
	#self.get_parent().move_child(self, -1)  # Make sure we are rendered on top

	$OpenFaceCardSlot.position = $PlayedFaceCards.get_child(-1).position + Vector2(30, 0)
	
	hand_card._on_card_played(played_card)
	
	# You might think it doesn't make sense to create the played_card
	#	when it's gonnna be remove by a jack anyway.
	#	But it probably, eventually, makes animation easier, probably.
	if played_card.card.rank == Card.Rank.JACK:
		self.caravan.remove_card(self)
	#self.emit_signal("on_card_played", played_card, hand_card)


func can_play_face_card(hand_card: CardHandSlot) -> bool:
	return hand_card.card.is_face_card()

func try_play_face_card(hand_card: CardHandSlot) -> bool:
	if not self.can_play_face_card(hand_card):
		return false
		
	self._play_face_card(hand_card)
	return true


func can_play_card(hand_card: CardHandSlot) -> bool:
	return self.can_play_face_card(hand_card)


func get_value() -> int:
	assert(self.card.is_numeric_card())
	var value: int = self.card.rank
	for facecard in $PlayedFaceCards.get_children():
		assert(facecard is FaceCardSlot)
		if facecard.card.rank == Card.Rank.KING:
			value *= 2
	return value


func _register_facecard_to_numbercard(node: Node) -> void:
	assert(node is FaceCardSlot)
	
	node.number_card = self
