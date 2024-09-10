extends Node

class_name Player

@onready var hand: Hand = $Hand
@export var game_manager: GameManager = null
@export var game_rules: GameRules = GameRules.new()
@export var caravans: Array[Caravan] = []
@export var is_enemy_player: bool = true

# Putting this property here could cause "invalid" state with multiple current players.
#	but at the same time it also reduces coupling to the GameManager node.
var is_current_player: bool = false

var has_lost: bool = false

signal turn_ended(player: Player)
signal lost(player: Player)

func _ready() -> void:
	
	$Hand.player = self
	$Hand.deck = $Deck

	assert(self.game_manager != null)


func init() -> void:
	$Deck.fill_deck(Deck.new(self.game_rules.deck_min_size, self.game_rules.deck_max_size, self.game_rules.deck_seed))
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


func lose() -> void:
	if self.has_lost:
		return

	if self.hand.get_cards().size() == 0:
		print("Player %s has run out of cards" % self.name)

	print("Player %s loses" % self.name)
	self.has_lost = true
	self.lost.emit(self)
