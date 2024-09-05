## Abstract Base Class for card drop slots. Is not inherited by HandCardSlot

extends Control

class_name CardDropSlot

signal on_card_played(dropslot: CardDropSlot, card_drag: DragPreview)  # TODO Kevin: Pass player here when it exists, probably

var card: Card = null

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

	# TODO Kevin: We probably wanna emit a signal here,
	#	at least such that a player's hand can shift/shrink during the inital round,
	#	or draw from deck during normal rounds.
	
	self.texture = data.card.card_texture  # TODO Kevin: Rework this, probably
	self.card = data.card
	
	self.emit_signal("on_card_played", self, data)
