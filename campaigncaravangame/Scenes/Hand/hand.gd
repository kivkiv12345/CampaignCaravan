extends Node2D

## This is the amount of cards that will be kept on hand during the game
const HAND_SIZE: int = 5

## The hand size will contain an extra card for each caravan during the initial round
const CARAVAN_COUNT: int = 3

## Signal handler for both child_entered_tree() and child_exiting_tree(),
##	which is therefore automatiaclly called when cards are either added or removed from the hand.
func fix_card_spacing(_node: Node) -> void:

	var cards = $Cards.get_children()
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

	# Calculate the total width occupied by all cards
	var total_width = current_card_spacing * (num_cards_in_hand - 1)
	
	# Center the cards relative to the deck's starting position
	var base_shift = -80

	# Adjust each card’s position based on index and spacing
	var i: int = -1
	for card in cards:
		i += 1;
		
		if card is not CardHandSlot:
			continue
		
		print("AA %d" % i)
		print("BB %f" % (base_shift + (current_card_spacing * i)))
		
		card.position = Vector2(base_shift + (current_card_spacing * i), 0)
	
	print("END")
	print("\n")


## Draws a card from the player's deck, and adds it to their hand.
func draw_card_from_deck() -> void:
	var card: Card = $Deck.get_card()
	
	if card == null:
		print("No more cards to draw")
		return
	
	var hand_card_slot: Node = preload("res://Scenes/Hand/HandCardSlot.tscn").instantiate()
	hand_card_slot.set_card(card)
	
	
	#hand_card_slot.position += Vector2(base_shift+(shift_per_card*$Cards.get_child_count()), 0)
	
	$Cards.add_child(hand_card_slot)  # Automatically fixes spacing through signal


func _on_card_played(dropslot: CardDropSlot, card_drag: DragPreview) -> void:
	
	$Cards.remove_child(card_drag.source)
	
	var round_number = 0  # TODO Kevin: Implement round number
	
	if round_number == 0:
		return

	self.draw_card_from_deck()


func fill_initial_hand() -> void:
	while $Cards.get_child_count() < self.HAND_SIZE+self.CARAVAN_COUNT:
		self.draw_card_from_deck()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.fill_initial_hand()
