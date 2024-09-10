extends Control

class_name Hand


## This is the amount of cards that will be kept on hand during the game
const HAND_SIZE: int = 5

## The hand size will contain an extra card for each caravan during the initial round
const CARAVAN_COUNT: int = 3


@export var deck: DeckScene = null
@export var player: Player = null


## Signal handler for both child_entered_tree() and child_exiting_tree(),
##	which is therefore automatiaclly called when cards are either added or removed from the hand.
func fix_card_spacing(_node: Node) -> void:

	var cards = $Cards.get_children()
	cards.reverse()
	var num_cards_in_hand = cards.size()

	# If there are no cards, then there's no need for spacing ¯\_(ツ)_/¯
	if num_cards_in_hand == 0:
		return

	# Constants for card spacing
	const min_spacing: int = 22  # Ensure enough space to see both suit and rank of the card
	const max_spacing: int = min_spacing * 3  # We also need a maximum constraint, but this is not as importatnt as the minimum
	
	# Calculate dynamic spacing. Spacing decreases as more cards are in hand.
	var current_card_spacing = max_spacing - (max_spacing - min_spacing) * (num_cards_in_hand / 10.0)
	if current_card_spacing < min_spacing:
		current_card_spacing = min_spacing

	# Adjust each card’s position based on index and spacing
	var i: int = -1
	for card in cards:
		i += 1;
		
		if card is not CardHandSlot:
			continue

		# TODO Kevin: I can't really get the spacing right, but this is fine for now... probably
		#	135.6 is offset of Cards in Hand.tscn (towards deck)
		card.position = Vector2(135.6-((i-1)*current_card_spacing), 0)


func get_cards() -> Array[CardHandSlot]:
	var cards: Array[CardHandSlot] = []
	for card in $Cards.get_children():
		assert(card is CardHandSlot)
		cards.append(card)
	return cards

enum _TryDrawCard {SUCCESS, NO_MORE_CARDS, HAND_FULL}

func _draw_card_from_deck() -> _TryDrawCard:
	
	var card: Card = self.deck.get_card()
	
	if card == null:
		#print("No more cards to draw")
		return _TryDrawCard.NO_MORE_CARDS
	
	var hand_card_slot: Node = preload("res://Scenes/Hand/HandCardSlot.tscn").instantiate()
	hand_card_slot.hand = self
	hand_card_slot.set_card(card)
	
	#hand_card_slot.position += Vector2(base_shift+(shift_per_card*$Cards.get_child_count()), 0)
	
	$Cards.add_child(hand_card_slot)  # Automatically fixes spacing through signal
	
	return _TryDrawCard.SUCCESS

## Draws a card from the player's deck, and adds it to their hand.
func try_draw_card_from_deck() -> _TryDrawCard:
	
	if self.get_cards().size() >= self.player.game_rules.hand_size:
		return _TryDrawCard.HAND_FULL
	
	return _draw_card_from_deck()

func try_fill_hand() -> bool:
	
	while true:
		match self.try_draw_card_from_deck():
			_TryDrawCard.NO_MORE_CARDS:
				return false
			_TryDrawCard.HAND_FULL:
				break
			_:
				continue  # We have not filled our hand yet.
	
	return true

func get_lowest_value_card() -> CardHandSlot:
	var hand_cards: Array[CardHandSlot] = self.get_cards()
	assert(hand_cards.size() > 0)
	var lowest_hand_card: CardHandSlot = hand_cards[0]
	
	for hand_card in hand_cards:
		if hand_card.card.rank < lowest_hand_card.card.rank:
			lowest_hand_card = hand_card
			
	return lowest_hand_card

func can_discard_card(hand_card: CardHandSlot) -> bool:
	
	if not self.player.is_current_player:
		return false  # It is not our turn, so we cannot discard cards
		
	if self.player.has_lost:
		return false  # We have lost, and can therfore not discard cards
	
	if hand_card not in $Cards.get_children():
		return false  # We don't have that card, this is almost an assert().
		
	return true

func _discard_card(hand_card: CardHandSlot) -> void:
	assert(hand_card in $Cards.get_children())
	assert(self == hand_card.hand)
	
	$Cards.remove_child(hand_card)
	self.try_fill_hand()
	
	if self.get_cards().size() == 0:
		self.player.lose()
	else:
		hand_card.hand.player.end_turn()

func try_discard_card(hand_card: CardHandSlot) -> bool:
	
	if not self.can_discard_card(hand_card):
		return false
		
	self._discard_card(hand_card)
	return true

func _on_card_played(_dropslot: CardSlot, played_from: CardHandSlot) -> void:

	assert(played_from in $Cards.get_children())
	$Cards.remove_child(played_from)

	if $Cards.get_child_count() < self.player.game_rules.hand_size:
		self.try_fill_hand()
		
	if self.get_cards().size() == 0:
		self.player.lose()


func fill_initial_hand() -> void:
	for __ in range(self.player.game_rules.hand_size+self.player.game_rules.caravan_count):
		if $Cards.get_child_count() >= self.player.game_rules.hand_size+self.player.game_rules.caravan_count:
			break
		self._draw_card_from_deck()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.deck != null:
		self.fill_initial_hand()
