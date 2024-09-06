## Super Abstract Base Class for card slots

extends TextureRect

class_name CardSlot

var card: Card = null

## Update the card displayed in this slot
func set_card(new_card: Card) -> void:
	self.card = new_card
	self.texture = new_card.card_texture

func remove_card() -> void:
	self.card = null
	self.texture = null
