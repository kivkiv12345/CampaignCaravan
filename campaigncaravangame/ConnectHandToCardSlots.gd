extends Node2D

func _ready() -> void:
	# TODO Kevin: This script could be avoided by adding on drop slots as
	#	a child node to a node with a child_entered_tree() signal connected.
	for card_drop_slot in self.get_tree().get_nodes_in_group("CardSlots"):
		assert(card_drop_slot.has_signal("on_card_played"))
		card_drop_slot.on_card_played.connect($Hand._on_card_played)
