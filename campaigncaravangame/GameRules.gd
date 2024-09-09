extends Resource

class_name GameRules


@export var caravan_max_value: int = 26
@export var caravan_min_value: int = 21

@export var queen_changes_suit: bool = true  # Whether playing a queen changes the direction of the caravan it's played on.
@export var queen_changes_direction: bool = true  # Whether playing a queen changes the suit of its number card.

@export var hand_size: int = 5  # Number of cards that may be kept in the hand during play

const caravan_count: int = 3  # TODO Kevin: Maybe make this variable in the future?

# TODO Kevin: Can we represent rules about decks here?
@export var deck_min_size: int = 30
@export var deck_max_size: int = 108
@export var deck_require_unique_cards: bool = true  # Can a deck be filled of only: 10's, 6's and  kings?

# TODO Kevin: This setting may not continue to live here.
#	It's not used to determine of 2 GameRules are equal.
@export var deck_seed: int = 12345

func same_rules(game_rules: GameRules) -> bool:
	if game_rules == self:
		return true

	return game_rules.caravan_max_value == self.caravan_max_value and game_rules.caravan_mix_value == self.caravan_mix_value and game_rules.queen_changes_suit == self.queen_changes_suit and game_rules.queen_changes_direction == self.queen_changes_direction and game_rules.hand_size == self.hand_size and game_rules.caravan_count == self.caravan_count and game_rules.deck_min_size == self.deck_min_size and game_rules.deck_max_size == self.deck_max_size and game_rules.deck_require_unique_cards == self.deck_require_unique_cards
