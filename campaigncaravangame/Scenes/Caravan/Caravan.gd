extends TextureRect

class_name Caravan

#signal on_card_play(dropslot: OpenCardSlot, card_drag: DraggedCard)  # TODO Kevin: Pass player here when it exists, probably
signal on_card_played(dropslot: CardSlot, played_from: CardHandSlot)  # TODO Kevin: Pass player here when it exists, probably

var player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card_slot in self.get_children():
		if not card_slot is OpenNumericCardSlot:
			continue
		card_slot.caravan = self


func _register_cardslot_to_caravan(node: Node) -> void:
	if not node is OpenNumericCardSlot:
		return
	node.caravan = self


## This should be called by Jacks and Jokers
func _remove_card() -> void:
	assert(false)


func _play_number_card(hand_card: CardHandSlot) -> void:
	
	var played_card: Node = preload("res://Scenes/CardDropSlots/PlayedNumericCardSlot.tscn").instantiate()
	played_card.set_card(hand_card.card)
	played_card.position = $OpenNumericCardSlot.position

	$PlayedCards.add_child(played_card)
	#self.get_parent().move_child(self, -1)  # Make sure we are rendered on top

	$OpenNumericCardSlot.position = $PlayedCards.get_child(-1).position + Vector2(0, 30)
	
	hand_card._on_card_played(played_card)
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
		if (played_cards[-1] as PlayedNumericCardSlot).card.suit == hand_card.card.suit:
			return true
		
		if (played_cards[-1] as PlayedNumericCardSlot).card.rank > (played_cards[-2] as PlayedNumericCardSlot).card.rank:
			#direction = _CaravanDirection.ASCENDING
			return hand_card.card.rank > (played_cards[-1] as PlayedNumericCardSlot).card.rank
		elif (played_cards[-1] as PlayedNumericCardSlot).card.rank < (played_cards[-2] as PlayedNumericCardSlot).card.rank:
			#direction = _CaravanDirection.DECENDING
			return hand_card.card.rank < (played_cards[-1] as PlayedNumericCardSlot).card.rank
		# Jacks and Jokers can cause the 2 last cards in a caravan to have the same rank,
		#	in which case we allow this hand_card.card to set the new direction.
			
	
	return true

func try_play_number_card(hand_card: CardHandSlot) -> bool:
	if not self.can_play_number_card(hand_card):
		return false
		
	self._play_number_card(hand_card)
	return true
