extends Node2D

func _ready() -> void:
	# TODO Kevin: This script could be avoided by adding drop slots as
	#	a child node to a node with a child_entered_tree() signal connected.
	for caravan in self.get_tree().get_nodes_in_group("Caravans"):
		assert(caravan.has_signal("on_card_played"))
		caravan.on_card_played.connect($Hand._on_card_played)
