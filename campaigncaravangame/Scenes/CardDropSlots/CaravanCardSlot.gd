extends CardSlot

class_name CaravanCardSlot


# TODO Kevin: Would it be better if this node was found in the tree?
#	It would certainly incur less state.
@export var caravan: Caravan = null


## Abstarct method
func can_play_card(hand_card: CardHandSlot) -> bool:
	assert(false)
	return false
