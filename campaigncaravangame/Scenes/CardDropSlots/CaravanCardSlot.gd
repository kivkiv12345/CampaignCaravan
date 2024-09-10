extends CardSlot

class_name CaravanCardSlot


# TODO Kevin: Would it be better if this node was found in the tree?
#	It would certainly incur less state.
@export var caravan: Caravan = null


func set_caravan(_caravan: Caravan) -> void:
	self.caravan = _caravan


## Abstarct method
func _play_card(_hand_card: CardHandSlot) -> void:
	assert(false, "Abstarct method")

## Abstarct method
func can_play_card(_hand_card: CardHandSlot) -> bool:
	assert(false, "Abstarct method")
	return false

func try_play_card(hand_card: CardHandSlot) -> bool:
	
	if not self.can_play_card(hand_card):
		return false
		
	self._play_card(hand_card)
	return true
