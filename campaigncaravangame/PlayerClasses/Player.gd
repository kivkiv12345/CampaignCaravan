extends Node

class_name Player

@onready var hand: Hand = $Hand
@export var game_manager: GameManager = null
@export var has_lost: bool = false
@export var game_rules: GameRules = GameRules.new()
@export var caravans: Array[Caravan] = []

signal turn_ended(player: Player)

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
	print("Player %s loses" % self.name)
	self.has_lost = true
