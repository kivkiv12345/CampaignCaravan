extends Player

class_name BotPlayer

var rng = RandomNumberGenerator.new()
@export var min_delay: float = 0.0
@export var max_delay: float = 0.0

func _seeded_shuffle(array: Array[Variant]) -> Array[Variant]:

	# Shuffle the cards using the seeded RNG
	for i in range(array.size()):
		var j = self.rng.randi_range(0, array.size() - 1)

		# Swap self.cards[i] and self.cards[j]
		var arrayi: Variant = array[i]
		array[i] = array[j]
		array[j] = arrayi
		
	return array


## Does not account for Jokers
func playing_card_loses_game(card_slot: CaravanCardSlot, hand_card: CardHandSlot) -> bool:

	# Check if we would win the game for the opponent by playing this card
	var equal_num_caravans: Dictionary = {}
	for player in self.game_manager.players:
		equal_num_caravans[player.caravans.size()] = null
	assert(equal_num_caravans.size() == 1)

	assert(self.game_manager.players.size() <= 2, "Logic to check for losing plays needs to be rewritten to support more than 2 players")
	var opponent_player: Player = null
	for player in self.game_manager.players:
		if player != self:
			opponent_player = player
			break
	assert(opponent_player != null)

	const SoldStatus = Caravan.SoldStatus
	var opponent_sold_indexes: Array[int] = []
	# Now we now it's relativly safe to use index to compare caravans.
	var idx: int = -1
	for caravan in opponent_player.caravans:
		idx += 1
		var sold_status: SoldStatus = self.game_manager.get_caravan_sold_status(caravan)
		if sold_status == SoldStatus.SOLD:
			opponent_sold_indexes.append(idx)


	# The opponent needs to sell more than 1 caravan to win.
	#	So we assume playing this 1 card can't lose us the game.
	# TODO Kevin: Joker may need some logic here.
	if opponent_sold_indexes.size() < self.caravans.size()-1:
		return false

	# Find out which caravn needs to be sold before they win.
	var unsold_idx: int = -1
	for i in range(self.caravans.size()):
		if not i in opponent_sold_indexes:
			unsold_idx = i
			break
	
	
	# Apparently the opponent has sold all of their caravans.
	# 	This should be an assert(),
	#	but we can probably let the rest of the game handle the consequences.
	#	There's no good right/wrong answer here,
	#	but maybe we can assume that we can outbid one the of sold opponent caravans.
	#assert(unsold_idx != -1)
	if unsold_idx == -1:
		return false
	

	
	# This is our unsold caravan, which may lose us the game if we sell it.
	var danger_caravan: Caravan = self.caravans[unsold_idx]


	# If our caravan, corresponding to the unsold opponent one, is sold, then we should have lost now.
	if self.game_manager.get_caravan_sold_status(danger_caravan) == SoldStatus.SOLD:
		# Unless the opponent is required to sell all their caravans.
		#	In which case we just assume it's okay to play this card.
		#	This custom rule is a bit of an edge case anyway, so it's probably fine... probably.
		assert(opponent_player.game_rules.require_all_caravans)
		return false


	# TODO Kevin: It would be nice to have a method telling us what the value of a caravan will be, after playing a card.

	var caravan_sold_range = range(self.game_rules.caravan_min_value, self.game_rules.caravan_max_value+1)
	if hand_card.card.is_face_card():
		assert(card_slot is OpenFaceCardSlot)
		if hand_card.card.rank == Card.Rank.JACK:
			if (danger_caravan.get_value() - card_slot.number_card.get_value()) in caravan_sold_range:
				return true
		if hand_card.card.rank == Card.Rank.KING:
			if (danger_caravan.get_value() + card_slot.number_card.get_value()) in caravan_sold_range:
				return true

		# TODO Kevin: Joker may need some logic here.
		return false
				
	if hand_card.card.is_numeric_card():
		assert(card_slot is OpenNumericCardSlot)
		if danger_caravan.get_value() + hand_card.card.rank in caravan_sold_range:
			return true

	return false  # No you're good, go ahead and play that card


func perform_turn() -> void:
	var cards: Array[CardHandSlot] = self._seeded_shuffle(self.hand.get_cards())
	assert(cards.size())
	
	# In cases very short randomized delay (especially 0.02 <-> 0.04 seconds)
	#	is employed to start turns between 2 bots,
	#	it can occur that a bot starts its turn when it is not actually its turn.
	#	I assume this is because its turn is somehow delayed into that of the next player.
	#	Although I don't know how the next player manages to start its turn,
	#	before this one has taken place.
	#	Nevertheless, returning here (without taking any action) seems entirely valid,
	#	despite my initial suspicion that this might cause deadlocks.
	if not self.is_current_player:
		return

	assert(self.is_current_player)
	
	for hand_card in cards:
		
		# Skip queens in this loop, so we prioritize cards that give a numeric benefit.
		if hand_card.card.rank == Card.Rank.QUEEN:
			continue
		
		var legal_slots: Array[CaravanCardSlot] = self.get_legal_caravan_slots(hand_card)
		
		if legal_slots.size() == 0:
			continue  # Nowhere to play this card

		self._seeded_shuffle(legal_slots)

		for legal_slot in legal_slots:
			
			# Make sure we don't ruin our own caravan
			if legal_slot.caravan.player == self:
				
				# TODO Kevin: Check that we don't win the game for the enemy by playing this card.
				#	This could happen if the enemy has their caravan 1 and 2, and we finish our 3.
				
				if hand_card.card.rank == Card.Rank.KING:
					# Do not overburden ourselves with kings
					if legal_slot.caravan.get_value() + (legal_slot.number_card.get_value()) > self.game_rules.caravan_max_value:
						continue  # Playing this king would overburden our caravan
				# Make sure we don't accidentally 'fix' an enemy caravan
				elif hand_card.card.rank == Card.Rank.JACK:
					if legal_slot.caravan.get_value() <= self.game_rules.caravan_max_value:
						continue  # This caravan is not overburdened, so don't play a jack on it.
				elif hand_card.card.is_numeric_card():
					if (legal_slot.caravan.get_value() + hand_card.card.rank) > self.game_rules.caravan_max_value:
						continue  # Don't play number cards that would overburden our caravan
			else:  # We are looking at an enemy caravan
				# Make sure playing kings on the enemy actually hurts them
				if hand_card.card.rank == Card.Rank.KING:
					if (legal_slot.caravan.get_value() + (legal_slot.number_card.get_value())) <= self.game_rules.caravan_max_value:
						# TODO Kevin: There is a bug here, for some reason kings are played anyway.
						continue  # Playing this king would not overburden the enemy caravan
				# Make sure we don't accidentally 'fix' an enemy caravan
				elif hand_card.card.rank == Card.Rank.JACK:
					# TODO Kevin: If playing a jack on the enemy,
					#	make sure to prioritize the most valuable cards in sold caravans.
					if legal_slot.caravan.get_value() > self.game_rules.caravan_max_value:
						continue  # Don't play jacks on overburdended enemy caravans


			if self.playing_card_loses_game(legal_slot, hand_card):
				#print("Oh baby")
				continue


			if legal_slot.try_play_card(hand_card):
				# We played a card!
				# We don't know where, nor what we played, but it ended our turn.
				return
				
	# We couldn't play any cards, excluding queens.
	#	So now would be a good time to play those queens.
	#	as that might allow us to play some of our other cards.
	for hand_card in cards:

		if hand_card.card.rank != Card.Rank.QUEEN:
			continue  # Don't play cards with didn't want to play in the for loop above.

		var legal_slots: Array[CaravanCardSlot] = self.get_legal_caravan_slots(hand_card)
		
		if legal_slots.size() == 0:
			continue  # Nowhere to play this queen

		self._seeded_shuffle(legal_slots)

		# Try playing the queen on our own caravans.
		#	By now why can't play any other cards.
		for legal_slot in legal_slots:

			assert(legal_slot is OpenFaceCardSlot)

			if legal_slot.caravan.player != self:
				continue  # This loop is only for our own caravans
				
			if legal_slot.caravan.get_value() > legal_slot.caravan.player.game_rules.caravan_max_value:
				continue  # Queens don't help an overburdened caravan.

			#print("IIIIII %d %d" % [legal_slot.number_card.get_index(), legal_slot.caravan.find_child("PlayedCards", false).get_child_count()])
			assert(legal_slot.number_card in legal_slot.caravan.find_child("PlayedCards", false).get_children())
			if legal_slot.number_card.get_index() < legal_slot.caravan.find_child("PlayedCards", false).get_child_count() - 1:
				continue  # Only play queens at the bottom of caravans

			if legal_slot.try_play_card(hand_card):
				# We played a queen!
				#	Hopefully we can now play a number card next round.
				#print("GGG")
				return
		
		# That didn't work, let's just "discard" it, by playing it on the enemy.
		#	We don't know what effect this will have on them however, so that's why it's our last resort.
		for legal_slot in legal_slots:
			
			assert(legal_slot is OpenFaceCardSlot)
			
			if legal_slot.caravan.get_value() > legal_slot.caravan.player.game_rules.caravan_max_value:
				continue  # Queens don't help an overburdened caravan.
			
			if legal_slot.caravan.player == self:
				continue  # This loop is only for enemy caravans
				
			assert(legal_slot.number_card in legal_slot.caravan.find_child("PlayedCards", false).get_children())
			if legal_slot.number_card.get_index() < legal_slot.caravan.find_child("PlayedCards", false).get_child_count() - 1:
				continue  # Only play queens at the bottom of caravans
				
			if legal_slot.try_play_card(hand_card):
				# We played a queen, on an enemy caravan.
				#	Hopefully that harms them, more than it helps them.
				print("HHH")
				return
	
	# Before we just keep discarding cards forever,
	#	let's see if we have some caravans to give up on.
	for caravan in self.get_tree().get_nodes_in_group("Caravans"):
		assert(caravan is Caravan)
		
		if caravan.num_turns_overburdened > 3:
			if caravan.try_discard_caravan():
				# Well, hopefully it was truly broken beyond repair.
				#	And that we can quickly rebuild it.
				print("FFF")
				return
	
	# We didn't have any cards to play, so we must discard something.
	if self.hand.try_discard_card(self.hand.get_lowest_value_card(), true):
		return  # We ended our turn by discarding a card
		
	# Maybe the reason we weren't able to perform any actions, is because we have lost.
	if self.has_lost:
		# How about that.
		# You could argue we should check this first,
		# but doing it down here allows us to check if all of our guards are working correctly.
		return
	
	# Somehow we started our turn without being able to perform any actions.
	# This should not be possible, and we should've lost before this/our turn started.
	print("Bot started turn without being able to perform any actions")
	assert(false)


func start_turn() -> void:
	super()
	if self.min_delay or self.max_delay:
		CaravanUtils.delay(self.perform_turn, self.rng.randf_range(self.min_delay, self.max_delay), self)
	else:
		self.perform_turn()
