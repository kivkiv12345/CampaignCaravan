extends Resource

class_name GameRules


@export var caravan_max_value: int = 26  # Maximum value to sell a caravan (inclusive)
@export var caravan_min_value: int = 21  # Minimum value to sell a caravan (inclusive)
@export var caravan_max_cards: int = 20  # Maximum number of numeric cards that can be played in a caravan

@export var queen_changes_suit: bool = true  # Whether playing a queen changes the direction of the caravan it's played on.
@export var queen_changes_direction: bool = true  # Whether playing a queen changes the suit of its number card.

@export var number_card_allow_faces_first_round: bool = true  # TODO Kevin: Implement
@export var number_card_require_face_match_suit: bool = false  # TODO Kevin: Implement
@export var number_card_max_faces: int = 6  # Maximum number of face cards applied to a number card.

@export var hand_size: int = 5  # Number of cards that may be kept in the hand during play

const caravan_count: int = 3  # TODO Kevin: Maybe make this variable in the future?

# TODO Kevin: Can we represent rules about decks here?
@export var deck_min_size: int = 30  # Minimum starting number of cards allowed in the deck
@export var deck_max_size: int = 108  # Maximum starting number of cards allowed in the deck
@export var deck_shuffle: bool = true  # Shuffle deck before starting game
@export var deck_require_unique_cards: bool = true  # TODO Kevin: Implement, Prevent filling a deck of only: 10's, 6's and  kings?

# TODO Kevin: This setting may not continue to live here.
#	It's not used to determine of 2 GameRules are equal.
@export var deck_seed: int = 0
@export var custom_deck: Deck = null



## Useful to disallow playing with different rules between players, not that this is a requirement
func same_rules(game_rules: GameRules) -> bool:
	if game_rules == self:
		return true

	return game_rules.caravan_max_value == self.caravan_max_value and \
	game_rules.caravan_min_value == self.caravan_min_value and \
	game_rules.caravan_max_cards == self.caravan_max_cards and \
	game_rules.queen_changes_suit == self.queen_changes_suit and \
	game_rules.queen_changes_direction == self.queen_changes_direction and \
	game_rules.number_card_allow_faces_first_round == self.number_card_allow_faces_first_round and \
	game_rules.number_card_require_face_match_suit == self.number_card_require_face_match_suit and \
	game_rules.number_card_max_faces == self.number_card_max_faces and \
	game_rules.hand_size == self.hand_size and \
	game_rules.caravan_count == self.caravan_count and \
	game_rules.deck_min_size == self.deck_min_size and \
	game_rules.deck_max_size == self.deck_max_size and \
	game_rules.deck_shuffle == self.deck_shuffle and \
	game_rules.deck_require_unique_cards == self.deck_require_unique_cards
