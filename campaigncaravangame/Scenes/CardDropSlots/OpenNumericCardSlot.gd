extends CaravanCardSlot

class_name OpenNumericCardSlot


#func play_card(card: Card) -> void:
	#var played_card: Node = preload("res://Scenes/CardDropSlots/PlayedCardSlot.tscn").instantiate()
	#played_card.set_card(card)
	#self.add_sibling(played_card)
	#self.get_parent().move_child(self, -1)  # Make sure we are rendered on top
	#
	#print(self.get_parent().get_children())
	#
	#self.position += Vector2(0, 30)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DraggedCard:
		return false  # Under no circumstances can we drop something which is not a card.
	
	var drag_item: DraggedCard = data as DraggedCard
	
	return self.caravan.can_play_number_card(drag_item.source)


func _drop_data(_pos: Vector2, data: Variant):
	
	assert(data is DraggedCard)
	
	data.destination = self
	
	self.caravan.try_play_number_card(data.source, false)


func can_play_card(hand_card: CardHandSlot) -> bool:
	return self.caravan.can_play_number_card(hand_card)

func try_play_card(hand_card: CardHandSlot, animate: bool = true) -> bool:
	return self.caravan.try_play_number_card(hand_card)
