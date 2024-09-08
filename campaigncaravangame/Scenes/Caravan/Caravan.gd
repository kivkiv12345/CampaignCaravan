extends TextureRect

class_name Caravan

#signal on_card_played(dropslot: CardSlot, played_from: CardHandSlot)  # TODO Kevin: Pass player here when it exists, probably
signal on_value_changed(caravan: Caravan, old_value: int, new_value: int)

@export var player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card_slot in self.get_children():
		if not card_slot is OpenNumericCardSlot:
			continue
		card_slot.caravan = self


func _register_cardslot_to_caravan(node: Node) -> void:
	if not node is CaravanCardSlot:
		return
	node.caravan = self


const _number_card_spacing: int = 30

## Called by Jacks and Jokers
func remove_card(number_card: PlayedNumericCardSlot) -> void:
	assert(number_card in $PlayedCards.get_children())
	
	var before_value: int = self.get_value()

	for i in range(number_card.get_index(), $PlayedCards.get_child_count()):
		$PlayedCards.get_child(i).position -= Vector2(0, self._number_card_spacing)
	
	$PlayedCards.remove_child(number_card)

	$OpenNumericCardSlot.position = Vector2(0, self._number_card_spacing*$PlayedCards.get_child_count())
	
	self.on_value_changed.emit(self, before_value, self.get_value())


## It seems that our child nodes can't emit our signal.
## So we expose this function, so we can do it for them.
## This is especially used when playing kings,
## Which otherwise don't require our intervention.
func emit_value_changed(old_value: int) -> void:
	self.on_value_changed.emit(self, old_value, self.get_value())


func get_value() -> int:
	var value: int = 0
	for card in $PlayedCards.get_children():
		assert(card is PlayedNumericCardSlot)
		value += card.get_value()
	return value


func _play_number_card(hand_card: CardHandSlot) -> void:
	
	var played_card: Node = preload("res://Scenes/CardDropSlots/PlayedNumericCardSlot.tscn").instantiate()
	played_card.set_card(hand_card.card)
	played_card.set_caravan(self)
	
	var before_value: int = self.get_value()
	
	# First add the new card where the current slot is
	played_card.position = $OpenNumericCardSlot.position
	$PlayedCards.add_child(played_card)

	# Then move the slot to where the next card should be placed.
	$OpenNumericCardSlot.position = $PlayedCards.get_child(-1).position + Vector2(0, self._number_card_spacing)

	hand_card._on_card_played(played_card)

	self.on_value_changed.emit(self, before_value, self.get_value())
	hand_card.hand.player.end_turn()
	#self.emit_signal("on_card_played", played_card, hand_card)

#enum _CaravanDirection { ASCENDING, DECENDING, NONE }

func can_play_number_card(hand_card: CardHandSlot) -> bool:
	
	if not hand_card.card.is_numeric_card():
		return false
		
	if hand_card.hand.player != self.player:
		# Number cards can not be played on other player's caravans.
		return false
		
	var played_cards: Array[Node] = $PlayedCards.get_children()
	
	if played_cards.size() == 0:
		# If the caravan is empty, it will not have a direction yet,
		#	and so any numeric card is free to be played.
		return true
		
	if (played_cards[-1] as PlayedNumericCardSlot).card.rank == hand_card.card.rank:
		# Under no circumstances can 2 cards of the same numeric rank be played on top of eachother.
		return false

	if (played_cards.size() >= 2):
		#var direction: _CaravanDirection = _CaravanDirection.NONE
		if (played_cards[-1] as PlayedNumericCardSlot).get_effective_suit() == hand_card.card.suit:
			return true

		# Normal rank compare order
		var last_card: PlayedNumericCardSlot = played_cards[-1]
		var second_last_card: PlayedNumericCardSlot = played_cards[-2]

		# TODO Kevin: Should multiple queens reverse direction multiple times?
		#	Maybe make this a gamerule too.
		var has_queen: bool = played_cards[-1].num_queens() % 2

		# TODO Kevin: Gamerule to control whether queens reverse direction of caravan
		if has_queen:  # Reverse rank compare order
			# But hand_card.card.rank should still be compared
			#	with the rank of the actual [-1] last card.
			var temp_reverse: PlayedNumericCardSlot = last_card
			last_card = second_last_card
			second_last_card = temp_reverse

		if last_card.card.rank > second_last_card.card.rank:
			#direction = _CaravanDirection.ASCENDING
			return hand_card.card.rank > played_cards[-1].card.rank
		elif last_card.card.rank < second_last_card.card.rank:
			#direction = _CaravanDirection.DECENDING
			return hand_card.card.rank < played_cards[-1].card.rank
		# Jacks and Jokers can cause the 2 last cards in a caravan to have the same rank,
		#	in which case we allow this hand_card.card to set the new direction.

	return true

func try_play_number_card(hand_card: CardHandSlot) -> bool:
	if not self.can_play_number_card(hand_card):
		return false
		
	self._play_number_card(hand_card)
	return true
