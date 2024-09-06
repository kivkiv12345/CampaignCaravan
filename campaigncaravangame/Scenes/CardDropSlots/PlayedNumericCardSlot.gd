extends CaravanCardSlot

class_name PlayedNumericCardSlot


func _play_face_card(hand_card: CardHandSlot) -> void:
	
	var played_card: Node = preload("res://Scenes/CardDropSlots/PlayedCardSlot.tscn").instantiate()
	played_card.set_card(hand_card.card)
	
	# TODO Kevin: This is pretty nasty,
	#	but we currently don't have need for a proper FaceCardSlot.tscn scene,
	#	so we just apply the script. 
	played_card.script = FaceCardSlot
	
	played_card.position = $OpenFaceCardSlot.position

	$PlayedFaceCards.add_child(played_card)
	#self.get_parent().move_child(self, -1)  # Make sure we are rendered on top

	$OpenFaceCardSlot.position = $PlayedFaceCards.get_child(-1).position + Vector2(30, 0)
	
	hand_card._on_card_played(played_card)
	#self.emit_signal("on_card_played", played_card, hand_card)


func can_play_face_card(hand_card: CardHandSlot) -> bool:
	return hand_card.card.is_face_card()

func try_play_face_card(hand_card: CardHandSlot) -> bool:
	if not self.can_play_face_card(hand_card):
		return false
		
	self._play_face_card(hand_card)
	return true


func _register_facecard_to_numbercard(node: Node) -> void:
	assert(node is FaceCardSlot)
	
	node.number_card = self
