extends FaceCardSlot

class_name OpenFaceCardSlot


#func play_card(card: Card) -> void:
	#assert(false)
	#var played_card: Node = preload("res://Scenes/CardDropSlots/PlayedCardSlot.tscn").instantiate()
	#played_card.set_card(card)
	#self.parent.add_child_below_node(played_card)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DraggedCard:
		return false  # Under no circumstances can we drop something which is not a card.
	
	var drag_item: DraggedCard = data as DraggedCard
	return drag_item.card.is_face_card()


## Handled by base class
func _drop_data(_pos: Vector2, data: Variant) -> void:
	
	assert(data is DraggedCard)
	
	data.destination = self
	
	self.number_card.try_play_face_card(data.source)


func can_play_card(hand_card: CardHandSlot) -> bool:
	return self.number_card.can_play_face_card(hand_card)
