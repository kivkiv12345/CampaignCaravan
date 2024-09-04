extends Control

class_name CardDropSlot


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DragPreview:
		return false  # Under no circumstances can we drop something which is not a card.
	
	var drag_item: DragPreview = data as DragPreview
	
	# Actually, this class/method is abstract.
	# It has no way of knowing if a card may be dropped here.
	return false


func _drop_data(_pos: Vector2, data: Variant):
	
	assert(data is DragPreview)
	
	data.destination = self
	
	self.texture = data.card.card_texture  # TODO Kevin: Rework this, probably
