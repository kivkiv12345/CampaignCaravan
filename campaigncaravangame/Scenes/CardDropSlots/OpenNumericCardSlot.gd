extends CaravanCardSlot

class_name OpenNumericCardSlot


func _ready() -> void:
	super()
	self.mouse_entered.disconnect(self._on_mouse_entered)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	
	if data is not DraggedCard:
		return false  # Under no circumstances can we drop something which is not a card.
	
	var drag_item: DraggedCard = data as DraggedCard
	
	return self.caravan.can_play_number_card(drag_item.source)


func _drop_data(_pos: Vector2, data: Variant):
	
	assert(data is DraggedCard)
	
	data.destination = self
	
	self.caravan.try_play_number_card(data.source, false)


func can_play_card(hand_card: CardHandSlot) -> bool:
	return self.caravan.can_play_number_card(hand_card)

func try_play_card(hand_card: CardHandSlot, _animate: bool = true) -> bool:
	return self.caravan.try_play_number_card(hand_card)


func _on_numericcard_mouse_entered() -> void:
	
	# We have self._on_mouse_entered return a bool, indicating whether a card has snapped to us.
	if !self._on_mouse_entered():
		return
		
	# TODO Kevin: How should we color the preview on enemy carvans?
	if self.caravan.player.is_enemy_player:
		return
	
	assert(self.card && self.card.is_numeric_card())
	print(self.caravan.get_value() + self.card.rank)
	print(self.caravan.player.game_rules.caravan_max_value)
	if (self.caravan.get_value() + self.card.rank) > self.caravan.player.game_rules.caravan_max_value:
		self.set_modulate(Color.ORANGE_RED)
