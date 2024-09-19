extends Node

class_name Player

@onready var hand = $Hand
@export var game_manager: GameManager = null
@export var game_rules: GameRules = GameRules.new()
@export var caravans: Array[Caravan] = []
@export var is_enemy_player: bool = true
@export var reverse_caravans: bool = false

# Putting this property here could cause "invalid" state with multiple current players.
#	but at the same time it also reduces coupling to the GameManager node.
var is_current_player: bool = false

var has_lost: bool = false

signal turn_ended(player: Player)
signal lost(player: Player)
signal won(player: Player)

func _ready() -> void:
	
	$Hand.player = self
	$Hand.deck = $Deck


func init() -> void:

	if self.hand == null:
		self.hand = $Hand

	# TODO Kevin: More spaghetti
	if self.hand.deck == null:
		self.hand.deck = $Deck

	if self.game_manager == null:
		self.game_manager = self.find_parent("TableTop")
		assert(self.game_manager)

	if self.caravans == null:
		self.caravans = []

	# TODO Kevin: Spaghetti
	if self.caravans.size() == 0:
		
		var children = self.get_children()

		if self.reverse_caravans:
			children.reverse()

		for child in children:
			if not child is Caravan:
				continue
			self.caravans.append(child)
			child.player = self

	var deck_seed: int = self.game_rules.deck_seed
	if deck_seed == 0:
		deck_seed = randi()

	var deck: Deck = null

	if self.game_rules.custom_deck_name != "":
		deck = Deck.from_custom_deck_name(self.game_rules.custom_deck_name)

	# No custom deck, generate a random one.
	if deck == null:
		deck = Deck.from_bounds_and_seed(self.game_rules.deck_min_size, self.game_rules.deck_max_size, deck_seed)

	$Deck.fill_deck(deck)

	# TODO Kevin: Quick play shows that we may actually do some shuffling,
	#	even when this game rule is false.
	if game_rules.deck_shuffle:
		$Deck.unseeded_shuffle()

	print(self.game_rules.hand_size)
	print(self.is_enemy_player)

	$Hand.fill_initial_hand()


func get_legal_slots(hand_card: CardHandSlot) -> Array[CaravanCardSlot]:
	var legal_slots: Array[CaravanCardSlot] = []
	# It's more likely for our hand to be in the tree than us
	for cardslot in self.hand.get_tree().get_nodes_in_group("OpenCardSlots"):
		assert(cardslot is CaravanCardSlot)
		
		if cardslot.can_play_card(hand_card):
			legal_slots.append(cardslot)

	return legal_slots

## Abstract method. This is where bot players would do their thing.
## Human players would likely just write "pass" here (or start a timeout).
## But it assert(false), just so we don't get stuck if we forget to override it.
func start_turn() -> void:
	assert(false)

## Called by the various objects in the game
func end_turn() -> void:
	self.turn_ended.emit(self)


func win() -> void:
	if self.has_lost:
		return  # Can we win, after losing?
	# TODO Kevin: Actually, I don't know if we want to print here
	self.won.emit(self)


func lose() -> void:
	if self.has_lost:
		return

	if self.hand.get_cards().size() == 0:
		print("Player %s has run out of cards" % self.name)

	print("Player %s loses" % self.name)
	self.has_lost = true
	self.lost.emit(self)
