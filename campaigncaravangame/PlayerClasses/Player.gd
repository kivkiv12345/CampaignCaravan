extends Node

class_name Player

@export var _hand_override = null
@onready var hand: Hand = $Hand


func _ready() -> void:
	$Hand.player = self
	$Hand.deck = $Deck
	$Hand.fill_initial_hand()
	if self._hand_override != null:
		self.hand = self._hand_override


func get_legal_slots(hand_card: CardHandSlot) -> Array[CaravanCardSlot]:
	var legal_slots: Array[CaravanCardSlot] = []
	# It's more likely for our hand to be in the tree than us
	for cardslot in self.hand.get_tree().get_nodes_in_group("OpenCardSlots"):
		assert(cardslot is CaravanCardSlot)
		
		if cardslot.can_play_card(hand_card):
			legal_slots.append(cardslot)

	return legal_slots
