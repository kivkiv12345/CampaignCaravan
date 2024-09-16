extends Player

class_name BotPlayer

var rng = RandomNumberGenerator.new()

func _seeded_shuffle(array: Array[Variant]) -> Array[Variant]:

	# Shuffle the cards using the seeded RNG
	for i in range(array.size()):
		var j = self.rng.randi_range(0, array.size() - 1)

		# Swap self.cards[i] and self.cards[j]
		var arrayi: Variant = array[i]
		array[i] = array[j]
		array[j] = arrayi
		
	return array


func start_turn() -> void:
	var cards: Array[CardHandSlot] = self._seeded_shuffle(self.hand.get_cards())
	assert(cards.size())
	
	for hand_card in cards:
		
		# TODO Kevin: Play queens as a last resort,
		#	as they are then more likely to open up avenues of play.
		#	We should also prefer to play them on our own caravans,
		#	as playing them on enemy caravans might help them more than we harm them.
		
		var legal_slots: Array[CaravanCardSlot] = self.get_legal_slots(hand_card)
		self._seeded_shuffle(legal_slots)
		
		if legal_slots.size() == 0:
			continue  # Nowhere to play this card
			
		for legal_slot in legal_slots:
			
			# Make sure we don't ruin our own caravan
			if legal_slot.caravan.player == self:
				
				# TODO Kevin: Check that we don't win the game for the enemy by playing this card.
				#	This could happen if the enemy has their caravan 1 and 2, and we finish our 3.
				
				if hand_card.card.rank == Card.Rank.KING:
					# Do not overburden ourselves with kings
					if legal_slot.caravan.get_value() + (legal_slot.number_card.get_value()*2) > self.game_rules.caravan_max_value:
						print("AAA")
						continue  # Playing this king would overburden our caravan
				# Make sure we don't accidentally 'fix' an enemy caravan
				elif hand_card.card.rank == Card.Rank.JACK:
					if legal_slot.caravan.get_value() <= self.game_rules.caravan_max_value:
						print("BBB")
						continue  # This caravan is not overburdened, so don't play a jack on it.
				elif hand_card.card.is_numeric_card():
					if (legal_slot.caravan.get_value() + hand_card.card.rank) > self.game_rules.caravan_max_value:
						print("CCC")
						continue  # Don't play number cards that would overburden our caravan
			else:  # We are looking at an enemy caravan
				# Make sure playing kings on the enemy actually hurts them
				if hand_card.card.rank == Card.Rank.KING:
					if (legal_slot.caravan.get_value() + (legal_slot.number_card.get_value()*2)) <= self.game_rules.caravan_max_value:
						# TODO Kevin: There is a bug here, for some reason kings are played anyway.
						print("DDD")
						continue  # Playing this king would not overburden the enemy caravan
				# Make sure we don't accidentally 'fix' an enemy caravan
				elif hand_card.card.rank == Card.Rank.JACK:
					# TODO Kevin: If playing a jack on the enemy,
					#	make sure to prioritize the most valuable cards in sold caravans.
					if legal_slot.caravan.get_value() > self.game_rules.caravan_max_value:
						print("EEE")
						continue  # Don't play jacks on overburdended enemy caravans
					#if (legal_slot.caravan.get_value() - legal_slot.number_card.get_value()) in range(CARAVAN_MIN_VALUE, CARAVAN_MAX_VALUE+1):
						#continue

			if legal_slot.try_play_card(hand_card):
				# We played a card!
				# We don't know where, nor what we played, but it ended our turn.
				return
	
	# We didn't have any cards to play, so we must discard something.
	if self.hand.try_discard_card(self.hand.get_lowest_value_card()):
		print("FFF")
		return  # We ended our turn by discarding a card
		
	# Maybe the reason we weren't able to perform any actions, is because we have lost.
	if self.has_lost:
		# How about that.
		# You could argue we should check this first,
		# but doing it down here allows us to check if all of our guards are working correctly.
		return
	
	# Somehow we started our turn without being able to perform any actions.
	# This should not be possible, and we should've lost before this/our turn started.
	assert(false)
