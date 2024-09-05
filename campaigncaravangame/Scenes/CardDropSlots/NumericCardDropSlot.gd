extends CardDropSlot

class_name NumericCardDropSlot


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DragPreview:
		return false  # Under no circumstances can we drop something which is not a card.
	
	var drag_item: DragPreview = data as DragPreview
	# TODO Kevin: Check if dropping on other player's side
	
	if self.card != null:
		return false
	
	return drag_item.card.is_numeric_card()


## Handled by base class
#func _drop_data(_pos: Vector2, data: DragPreview):
	#
	#assert(data is DragPreview)
	#
	#data.destination = self
	#
	#self.texture = data.card.card_texture  # TODO Kevin: Rework this, probably
