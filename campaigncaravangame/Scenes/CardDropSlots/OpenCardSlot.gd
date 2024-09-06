## Abstract Base Class for card drop slots. Is not inherited by HandCardSlot

# TODO Kevin: OpenCardSlots probably shouldn't have a .card field,
#	so we should reconsider this inheritance.
extends CardSlot

class_name OpenCardSlot



# TODO Kevin: Would it be better if this node was found in the tree?
#	It would certainly incur less state.
@export var caravan: Caravan = null


## Abstract method, overridden by both OpenNumericCardSlot and OpenFaceCardSlot
##	(but we don't know that of course, being a base class and all)
#func play_card(card: Card) -> void:
	#assert(false)  # Abstract method


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DraggedCard:
		return false  # Under no circumstances can we drop something which is not a card.
	
	var drag_item: DraggedCard = data as DraggedCard
		
	# Actually, this class/method is abstract.
	# It has no way of knowing if a card may be dropped here.
	return false


func _drop_data(_pos: Vector2, data: Variant):
	
	assert(data is DraggedCard)
	
	data.destination = self

	# TODO Kevin: We probably wanna emit a signal here,
	#	at least such that a player's hand can shift/shrink during the inital round,
	#	or draw from deck during normal rounds.
	
	self.caravan.try_play_card(data.source)
	
	#self.play_card(data.card)
	
	#self.texture = data.card.card_texture  # TODO Kevin: Rework this, probably
	#self.card = data.card
