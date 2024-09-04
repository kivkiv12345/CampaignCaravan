extends Node2D

## This is the amount of cards that will be kept on hand during the game
const HAND_SIZE: int = 5

## The hand size will contain an extra card for each caravan during the initial round
const CARAVAN_COUNT: int = 3

## Draws a card from the player's deck, and adds it to their hand.
func draw_card_from_deck() -> void:
	var card: Card = $Deck.get_card()
	
	if card == null:
		print("No more cards to draw")
		return
	
	var hand_card_slot: Node = preload("res://Scenes/Hand/HandCardSlot.tscn").instantiate()
	hand_card_slot.set_card(card)
	
	const base_shift: int = -30  # Shift card left from the deck.
	const shift_per_card: int = 149-127  # And shift it a bit more for each card in the hand
	
	hand_card_slot.position += Vector2(base_shift+(shift_per_card*$Cards.get_child_count()), 0)
	
	$Cards.add_child(hand_card_slot)


func fill_initial_hand() -> void:
	while $Cards.get_child_count() < self.HAND_SIZE+self.CARAVAN_COUNT:
		self.draw_card_from_deck()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.fill_initial_hand()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
