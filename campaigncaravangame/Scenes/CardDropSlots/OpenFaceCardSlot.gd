extends FaceCardSlot

class_name OpenFaceCardSlot


func _ready() -> void:
	super()
	self.mouse_entered.disconnect(self._on_mouse_entered)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DraggedCard:
		return false  # Under no circumstances can we drop something which is not a card.
	
	var drag_item: DraggedCard = data as DraggedCard
	return drag_item.card.is_face_card()


func _drop_data(_pos: Vector2, data: Variant) -> void:
	
	assert(data is DraggedCard)
	
	data.destination = self
	
	self.number_card.try_play_face_card(data.source, false)


func can_play_card(hand_card: CardHandSlot) -> bool:
	return self.number_card.can_play_face_card(hand_card)
	
func try_play_card(hand_card: CardHandSlot, _animate: bool = true) -> bool:
	return self.number_card.try_play_face_card(hand_card)


func _unset_joker_color(number_cards: Array[PlayedNumericCardSlot]):
	for _number_card in number_cards:
		_number_card.set_modulate(Color.WHITE)


func _on_facecard_mouse_entered() -> void:

	# We have self._on_mouse_entered return a bool, indicating whether a card has snapped to us.
	if !self._on_mouse_entered():
		return
		
	assert(self.card && self.card.is_face_card())
	
	if self.card.rank == Card.Rank.JOKER:
		var affected_cards: Array[PlayedNumericCardSlot] = self.caravan.player.game_manager.get_joker_affected_cards(self)
		for _number_card in self.caravan.player.game_manager.get_joker_affected_cards(self):
			_number_card.set_modulate(Color.YELLOW)
			
		self.mouse_exited.connect(self._unset_joker_color.bind(affected_cards), ConnectFlags.CONNECT_ONE_SHOT)


	# TODO Kevin: How should we color the preview of kings on enemy carvans?
	if self.caravan.player.is_enemy_player:
		return

	if self.card.rank != Card.Rank.KING:
		return

	if (self.caravan.get_value() + (self.number_card.get_value())) > self.caravan.player.game_rules.caravan_max_value:
		self.set_modulate(Color.ORANGE_RED)
