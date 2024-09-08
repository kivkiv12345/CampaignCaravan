extends CaravanCardSlot

class_name PlayedNumericCardSlot


func set_caravan(caravan: Caravan) -> void:
	super(caravan)

	$OpenFaceCardSlot.set_caravan(caravan)

	for facecard in $PlayedFaceCards.get_children():
		facecard.set_caravan(caravan)


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
	
	var before_value: int = self.caravan.get_value()

	$PlayedFaceCards.add_child(played_card)
	#self.get_parent().move_child(self, -1)  # Make sure we are rendered on top

	$OpenFaceCardSlot.position = $PlayedFaceCards.get_child(-1).position + Vector2(30, 0)
	
	hand_card._on_card_played(played_card)
	
	# You might think it doesn't make sense to create the played_card
	#	when it's gonnna be remove by a jack anyway.
	#	But it probably, eventually, makes animation easier, probably.
	if played_card.card.rank == Card.Rank.JACK:
		self.caravan.remove_card(self)
	elif played_card.card.rank == Card.Rank.JOKER:
		for number_card in self.get_tree().get_nodes_in_group("NumericCardSlots"):
			assert(number_card is CaravanCardSlot)
			
			if not number_card is PlayedNumericCardSlot:
				# This is probably an open card slot, we which dont' want to remove.
				# I haven't quite decided if I want these in the group.
				continue
			
			if number_card == self:
				continue
			
			# Playing a joker on an ace removes all other cards of the same suit
			if self.card.rank == Card.Rank.ACE:
				if number_card.get_effective_suit() == self.card.suit:
					number_card.caravan.remove_card(number_card)
			else:  # Otherwise it removes all other cards of the same rank
				if number_card.card.rank == self.card.rank:
					number_card.caravan.remove_card(number_card)
	elif played_card.card.rank == Card.Rank.KING:
		self.caravan.emit_value_changed(before_value)
		#self.number_card.caravan.on_value_changed.emit(self, before_value, self.get_value())
		#self.caravan.on_value_changed.emit(self, before_value, self.get_value())

	#self.emit_signal("on_card_played", played_card, hand_card)
	hand_card.hand.player.end_turn()


func can_play_face_card(hand_card: CardHandSlot) -> bool:
	return hand_card.card.is_face_card()

func try_play_face_card(hand_card: CardHandSlot) -> bool:
	if not self.can_play_face_card(hand_card):
		return false
		
	self._play_face_card(hand_card)
	return true


func can_play_card(hand_card: CardHandSlot) -> bool:
	return self.can_play_face_card(hand_card)

func try_play_card(hand_card: CardHandSlot) -> bool:
	return self.try_play_face_card(hand_card)

func get_value() -> int:
	assert(self.card.is_numeric_card())
	var value: int = self.card.rank
	for facecard in $PlayedFaceCards.get_children():
		assert(facecard is FaceCardSlot)
		if facecard.card.rank == Card.Rank.KING:
			value *= 2
	return value


func num_queens() -> int:
	assert(self.card.is_numeric_card())
	var num_queens: int = 0
	for facecard in $PlayedFaceCards.get_children():
		assert(facecard is FaceCardSlot)
		if facecard.card.rank == Card.Rank.QUEEN:
			num_queens += 1
	return num_queens


## Returns the suit of the card, accounting for any queens played on it
func get_effective_suit() -> Card.Suit:
	# TODO Kevin: Gamerule to control whether queen changes suit
	var facecards = $PlayedFaceCards.get_children()
	facecards.reverse()  # Reverse so we find the last queen first
	for facecard in facecards:
		if facecard.card.rank == Card.Rank.QUEEN:
			# Return the suit of the last played queen.
			return facecard.card.suit
	return self.card.suit


func _register_facecard_to_numbercard(node: Node) -> void:
	assert(node is FaceCardSlot)
	
	node.number_card = self
