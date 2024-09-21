extends TextureRect

class_name Caravan

#signal on_card_played(dropslot: CardSlot, played_from: CardHandSlot)  # TODO Kevin: Pass player here when it exists, probably
signal on_value_changed(caravan: Caravan, old_value: int, new_value: int)
signal new_sold_status(caravan: Caravan, new_status: SoldStatus)

@export var player: Player = null

var num_turns_overburdened: int = 0

var ongoing_tween: Tween = null

enum SoldStatus {SOLD, UNDERBURDENED, OVERBURDENED, TIED, OUTBID}


func _on_player_turn_ended(player: Player) -> void:
	
	if self.get_value() > player.game_rules.caravan_max_value:
		self.num_turns_overburdened += 1
	else:
		self.num_turns_overburdened = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(self.player)
	self.player.turn_ended.connect(self._on_player_turn_ended)
	for card_slot in self.get_children():
		if not card_slot is OpenNumericCardSlot:
			continue
		card_slot.caravan = self


func _register_cardslot_to_caravan(node: Node) -> void:
	if not node is CaravanCardSlot:
		return
	node.caravan = self


const _number_card_spacing: int = 30

## Source: https://chatgpt.com
func _fix_card_spacing() -> void:
	# Go through each remaining card in PlayedCards and adjust their position
	for i in range($PlayedCards.get_child_count()):
		var card = $PlayedCards.get_child(i)
		var target_position: Vector2 = Vector2(0, i * self._number_card_spacing)
		
		# Tween each card to its new position
		var tween: Tween = self.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "position", target_position, 0.5)
	
	# Adjust OpenNumericCardSlot position (if applicable)
	$OpenNumericCardSlot.position = Vector2(0, self._number_card_spacing * $PlayedCards.get_child_count())
	

## Called by Jacks and Jokers
## Help from: https://chatgpt.com
func remove_card(number_card: PlayedNumericCardSlot, animation_delay: float = 0.0) -> void:
	assert(number_card in $PlayedCards.get_children())  # TODO Kevin: This can fail

	# Move affected card to CardsToRemove node, so we can recalculate caravan value immediately
	assert($CardsToRemove != null)

	var before_value: int = self.get_value()
	
	# Store the original z-index before moving the card,
	#	so we can correctly render cards in the middle of caravans when animating their removal.
	var original_z_index = number_card.get_z_index()
	
	$PlayedCards.remove_child(number_card)
	$CardsToRemove.add_child(number_card)
	
	# Restore its z-index to maintain its drawing order,
	#	which will have been borked when we moved number_card to $CardsToRemove
	number_card.set_z_index(original_z_index)

	## Source: https://chatgpt.com
	## Function to create and animate the card off-screen
	var _animate_card_removal = func ():
		# Get the viewport size to determine how far off-screen the card should move
		var viewport_rect: Rect2 = get_viewport().get_visible_rect()
		var offscreen_distance: float = viewport_rect.size.y  # Move down by the height of the viewport
		
		var tween: Tween = self.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		var target_position: Vector2 = number_card.position + Vector2(0, offscreen_distance)
		
		# Animate the card
		tween.tween_property(number_card, "position", target_position, 1)
		
		# Use a callback to remove the card after the animation completes
		tween.tween_callback(func():

			# Fix card spacing immediately so that the gameplay is not slowed down
			self._fix_card_spacing()

			number_card.queue_free()
		)

	# Check if there's an ongoing tween (e.g., when bot plays a jack)
	#if ongoing_tween and not ongoing_tween.is_running():
	if ongoing_tween:
		ongoing_tween.stop()
		ongoing_tween.tween_callback(_animate_card_removal)  # Wait for the face card animation to finish
		ongoing_tween.play()
	else:
		CaravanUtils.delay(_animate_card_removal.call, animation_delay, self)  # Animate immediately if no ongoing face card animation

	# Update the caravan's value immediately
	self.on_value_changed.emit(self, before_value, self.get_value())


## It seems that our child nodes can't emit our signal.
## So we expose this function, so we can do it for them.
## This is especially used when playing kings,
## Which otherwise don't require our intervention.
func emit_value_changed(old_value: int) -> void:
	self.on_value_changed.emit(self, old_value, self.get_value())

func update_sold_status(status: SoldStatus) -> void:
	self.new_sold_status.emit(self, status)

func get_value() -> int:
	var value: int = 0
	for card in $PlayedCards.get_children():
		assert(card is PlayedNumericCardSlot)
		value += card.get_value()
	return value


func _play_number_card(hand_card: CardHandSlot, animate: bool = true) -> void:
	
	var played_card: PlayedNumericCardSlot = preload("res://Scenes/CardDropSlots/PlayedNumericCardSlot.tscn").instantiate()
	played_card.set_card(hand_card.card)
	played_card.set_caravan(self)
	
	var before_value: int = self.get_value()
	
	$PlayedCards.add_child(played_card)
	
	# First add the new card where the current slot is
	if animate:
		var tween: Tween = self.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		played_card.global_position = hand_card.global_position
		tween.tween_property(played_card, "position", $OpenNumericCardSlot.position, 1)
	else:
		played_card.position = $OpenNumericCardSlot.position

	# Then move the slot to where the next card should be placed.
	$OpenNumericCardSlot.position += Vector2(0, self._number_card_spacing)

	hand_card._on_card_played(played_card)

	self.on_value_changed.emit(self, before_value, self.get_value())
	hand_card.hand.player.end_turn()
	#self.emit_signal("on_card_played", played_card, hand_card)

#enum _CaravanDirection { ASCENDING, DECENDING, NONE }

func can_play_number_card(hand_card: CardHandSlot) -> bool:
	
	if not hand_card.card.is_numeric_card():
		return false
		
	if self.player.has_lost:
		return false  # There is no point in playing cards on the caravan of a player that has lost.
		
	if hand_card.hand.player.has_lost:
		return false  # Players that have lost can only spectate
		
	if hand_card.hand.player != self.player:
		# Number cards can not be played on other player's caravans.
		return false
		
	var played_cards: Array[Node] = $PlayedCards.get_children()
	
	# TODO Kevin: In case of differnt rulesets,
	#	should we follow the rules of: hand_card.hand.player or self.caravan.player ?
	if played_cards.size() >= self.player.game_rules.caravan_max_cards:
		return false  # This caravan is at, or over, its maximum permissable size.
	
	if played_cards.size() == 0:
		# If the caravan is empty, it will not have a direction yet,
		#	and so any numeric card is free to be played.
		return true
		
	if (played_cards[-1] as PlayedNumericCardSlot).card.rank == hand_card.card.rank:
		# Under no circumstances can 2 cards of the same numeric rank be played on top of eachother.
		return false

	if (played_cards.size() >= 2):
		#var direction: _CaravanDirection = _CaravanDirection.NONE
		if (played_cards[-1] as PlayedNumericCardSlot).get_effective_suit() == hand_card.card.suit:
			return true

		# Normal rank compare order
		var last_card: PlayedNumericCardSlot = played_cards[-1]
		var second_last_card: PlayedNumericCardSlot = played_cards[-2]

		# TODO Kevin: Should multiple queens reverse direction multiple times?
		#	Maybe make this a gamerule too.
		var has_queen: bool = played_cards[-1].num_queens() % 2

		# TODO Kevin: Same question about which ruleset to follow here
		if has_queen and self.player.game_rules.queen_changes_direction:  # Reverse rank compare order
			# But hand_card.card.rank should still be compared
			#	with the rank of the actual [-1] last card.
			var temp_reverse: PlayedNumericCardSlot = last_card
			last_card = second_last_card
			second_last_card = temp_reverse

		if last_card.card.rank > second_last_card.card.rank:
			#direction = _CaravanDirection.ASCENDING
			return hand_card.card.rank > played_cards[-1].card.rank
		elif last_card.card.rank < second_last_card.card.rank:
			#direction = _CaravanDirection.DECENDING
			return hand_card.card.rank < played_cards[-1].card.rank
		# Jacks and Jokers can cause the 2 last cards in a caravan to have the same rank,
		#	in which case we allow this hand_card.card to set the new direction.

	return true

func try_play_number_card(hand_card: CardHandSlot, animate: bool = true) -> bool:
	if not self.can_play_number_card(hand_card):
		return false
		
	self._play_number_card(hand_card, animate)
	return true


func _discard_caravan() -> void:
	
	# Discarding a large caravan deserves a little "reward"
	if $PlayedCards.get_child_count() > 4:
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/casino/cardtable/sfx_cards_os_04.ogg"), 0, 0, randf_range(0.98, 1.05))
	
	var animation_delay: float = 0
	for card in $PlayedCards.get_children():
		assert(card is CaravanCardSlot)
		
		self.remove_card(card, animation_delay)
		animation_delay += 0.05
		
	self.player.end_turn()


func can_discard_caravan() -> bool:
	if not self.player.is_current_player:
		return false
	
	# It's not like it's illegal to discard an empty caravan.
	# But if we return true here, the player will think they should end their turn.
	# And that's a little harsh.
	if $PlayedCards.get_child_count() == 0:
		return false

	return true


func try_discard_caravan() -> bool:
	if not self.can_discard_caravan():
		return false
		
	self._discard_caravan()
	return true
