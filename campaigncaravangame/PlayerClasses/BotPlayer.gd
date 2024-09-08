extends Player

class_name BotPlayer

var rng = RandomNumberGenerator.new()

func _shuffled_hand() -> Array[CardHandSlot]:
	var cards: Array[CardHandSlot] = self.hand.get_cards()

	# Shuffle the cards using the seeded RNG
	for i in range(cards.size()):
		var j = self.rng.randi_range(0, cards.size() - 1)

		# Swap self.cards[i] and self.cards[j]
		var cardi: CardHandSlot = cards[i]
		cards[i] = cards[j]
		cards[j] = cardi
		
	return cards

func _discard_lowest_value_card() -> bool:
	# TODO Kevin: This may not where we want to function to be implemented.
	var hand_cards: Array[CardHandSlot] = self.hand.get_cards()
	assert(hand_cards.size() > 0)
	var lowest_hand_card: CardHandSlot = hand_cards[0]
	
	for hand_card in hand_cards:
		if hand_card.card.rank < lowest_hand_card.card.rank:
			lowest_hand_card = hand_card
			
	return self.hand.try_discard_card(lowest_hand_card)
	

func start_turn() -> void:
	var cards: Array[CardHandSlot] = self._shuffled_hand()
	assert(cards.size())
	
	for hand_card in cards:
		
		# TODO Kevin: Should we shuffle the legal slots too?
		var legal_slots: Array[CaravanCardSlot] = self.get_legal_slots(hand_card)
		
		if legal_slots.size() == 0:
			continue  # Nowhere to play this card
			
		for legal_slot in legal_slots:
			
			const CARAVAN_MIN_VALUE: int = 21
			const CARAVAN_MAX_VALUE: int = 26
			
			# Make sure we don't ruin our own caravan
			if legal_slot.caravan.player == self:
				if hand_card.card.rank == Card.Rank.KING:
					# Do not overburden ourselves with kings
					if legal_slot.caravan.get_value() + (legal_slot.number_card.get_value()*2) > CARAVAN_MAX_VALUE:
						print("AAA")
						continue  # Playing this king would overburden our caravan
				# Make sure we don't accidentally 'fix' an enemy caravan
				elif hand_card.card.rank == Card.Rank.JACK:
					if legal_slot.caravan.get_value() <= CARAVAN_MAX_VALUE:
						print("BBB")
						continue  # This caravan is not overburdened, so don't play a jack on it.
				elif hand_card.card.is_numeric_card():
					if (legal_slot.caravan.get_value() + hand_card.card.rank) > CARAVAN_MAX_VALUE:
						print("CCC")
						continue  # Don't play number cards that would overburden our caravan
			else:  # We are looking at an enemy caravan
				# Make sure playing kings on the enemy actually hurts them
				if hand_card.card.rank == Card.Rank.KING:
					if (legal_slot.caravan.get_value() + (legal_slot.number_card.get_value()*2)) <= CARAVAN_MAX_VALUE:
						print(legal_slot.number_card.rank)
						print("DDD")
						continue  # Playing this king would not overburden the enemy caravan
				# Make sure we don't accidentally 'fix' an enemy caravan
				elif hand_card.card.rank == Card.Rank.JACK:
					if legal_slot.caravan.get_value() > CARAVAN_MAX_VALUE:
						print("EEE")
						continue  # Don't play jacks on overburdended enemy caravans
					#if (legal_slot.caravan.get_value() - legal_slot.number_card.get_value()) in range(CARAVAN_MIN_VALUE, CARAVAN_MAX_VALUE+1):
						#continue

			if legal_slot.try_play_card(hand_card):
				# We played a card!
				# We don't know where, nor what we played, but it ended our turn.
				return
	
	# We didn't have any cards to play, so we must discard something.
	if self._discard_lowest_value_card():
		return  # We ended our turn by discarding a card
	
	# Somehow we started our turn without being able to perform any actions.
	# This should not be possible, and we should've last when we ended our last round.
	assert(false)
