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


func perform_turn() -> void:
	var cards: Array[CardHandSlot] = self._seeded_shuffle(self.hand.get_cards())
	assert(cards.size())
	
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
					if legal_slot.caravan.get_value() + (legal_slot.number_card.get_value()*2) > self.game_rules.caravan_max_value:
						#print("AAA")
						continue  # Playing this king would overburden our caravan
				# Make sure we don't accidentally 'fix' an enemy caravan
				elif hand_card.card.rank == Card.Rank.JACK:
					if legal_slot.caravan.get_value() <= self.game_rules.caravan_max_value:
						#print("BBB")
						continue  # This caravan is not overburdened, so don't play a jack on it.
				elif hand_card.card.is_numeric_card():
					if (legal_slot.caravan.get_value() + hand_card.card.rank) > self.game_rules.caravan_max_value:
						#print("CCC")
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
						#print("EEE")
						continue  # Don't play jacks on overburdended enemy caravans
					#if (legal_slot.caravan.get_value() - legal_slot.number_card.get_value()) in range(CARAVAN_MIN_VALUE, CARAVAN_MAX_VALUE+1):
						#continue

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

			#print("IIIIII %d %d" % [legal_slot.number_card.get_index(), legal_slot.caravan.find_child("PlayedCards", false).get_child_count()])
			assert(legal_slot.number_card in legal_slot.caravan.find_child("PlayedCards", false).get_children())
			if legal_slot.number_card.get_index() < legal_slot.caravan.find_child("PlayedCards", false).get_child_count() - 1:
				continue  # Only play queens at the bottom of caravans

			if legal_slot.try_play_card(hand_card):
				# We played a queen!
				#	Hopefully we can now play a number card next round.
				print("GGG")
				return
		
		# That didn't work, let's just "discard" it, by playing it on the enemy.
		#	We don't know what effect this will have on them however, so that's why it's our last resort.
		for legal_slot in legal_slots:
			
			assert(legal_slot is OpenFaceCardSlot)
			
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
	
	# We didn't have any cards to play, so we must discard something.
	if self.hand.try_discard_card(self.hand.get_lowest_value_card(), true):
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


func start_turn() -> void:
	super()
	if self.min_delay or self.max_delay:
		CaravanUtils.delay(self.perform_turn, self.rng.randf_range(self.min_delay, self.max_delay), self)
	else:
		self.perform_turn()
