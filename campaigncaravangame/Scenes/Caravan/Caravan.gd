extends TextureRect

class_name Caravan

#signal on_card_play(dropslot: OpenCardSlot, card_drag: DraggedCard)  # TODO Kevin: Pass player here when it exists, probably
signal on_card_played(dropslot: CardSlot, played_from: CardHandSlot)  # TODO Kevin: Pass player here when it exists, probably

var player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card_slot in self.get_children():
		if not card_slot is OpenCardSlot:
			continue
		card_slot.caravan = self


func _register_cardslot_to_caravan(node: Node) -> void:
	if not node is OpenCardSlot:
		return
	node.caravan = self


## This should be called by Jacks and Jokers
func _remove_card() -> void:
	assert(false)


func _play_card(hand_card: CardHandSlot) -> void:
	
	var played_card: Node = preload("res://Scenes/CardDropSlots/PlayedCardSlot.tscn").instantiate()
	played_card.set_card(hand_card.card)
	played_card.position = $OpenNumericCardSlot.position

	$PlayedCards.add_child(played_card)
	#self.get_parent().move_child(self, -1)  # Make sure we are rendered on top

	$OpenNumericCardSlot.position = $PlayedCards.get_child(-1).position + Vector2(0, 30)
	
	self.emit_signal("on_card_played", played_card, hand_card)


func can_play_card(hand_card: CardHandSlot) -> bool:
	return true

func try_play_card(hand_card: CardHandSlot) -> bool:
	if not self.can_play_card(hand_card):
		return false
		
	self._play_card(hand_card)
	return true
