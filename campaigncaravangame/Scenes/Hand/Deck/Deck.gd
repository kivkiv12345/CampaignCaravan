extends Resource

class_name Deck

#const MIN_SIZE = 30
#const MAX_SIZE = 108

const Suit := Card.Suit
const Rank := Card.Rank


static var base_deck: Array[Card] = [

	# Aces
	Card.new(Suit.CLOVER, Rank.ACE),
	Card.new(Suit.DIAMOND, Rank.ACE),
	Card.new(Suit.HEARTS, Rank.ACE),
	Card.new(Suit.SPADES, Rank.ACE),

	# Twos
	Card.new(Suit.CLOVER, Rank.TWO),
	Card.new(Suit.DIAMOND, Rank.TWO),
	Card.new(Suit.HEARTS, Rank.TWO),
	Card.new(Suit.SPADES, Rank.TWO),

	# Threes
	Card.new(Suit.CLOVER, Rank.THREE),
	Card.new(Suit.DIAMOND, Rank.THREE),
	Card.new(Suit.HEARTS, Rank.THREE),
	Card.new(Suit.SPADES, Rank.THREE),

	# Fours
	Card.new(Suit.CLOVER, Rank.FOUR),
	Card.new(Suit.DIAMOND, Rank.FOUR),
	Card.new(Suit.HEARTS, Rank.FOUR),
	Card.new(Suit.SPADES, Rank.FOUR),

	# Fives
	Card.new(Suit.CLOVER, Rank.FIVE),
	Card.new(Suit.DIAMOND, Rank.FIVE),
	Card.new(Suit.HEARTS, Rank.FIVE),
	Card.new(Suit.SPADES, Rank.FIVE),

	# Sixes
	Card.new(Suit.CLOVER, Rank.SIX),
	Card.new(Suit.DIAMOND, Rank.SIX),
	Card.new(Suit.HEARTS, Rank.SIX),
	Card.new(Suit.SPADES, Rank.SIX),

	# Sevens
	Card.new(Suit.CLOVER, Rank.SEVEN),
	Card.new(Suit.DIAMOND, Rank.SEVEN),
	Card.new(Suit.HEARTS, Rank.SEVEN),
	Card.new(Suit.SPADES, Rank.SEVEN),

	# Eights
	Card.new(Suit.CLOVER, Rank.EIGHT),
	Card.new(Suit.DIAMOND, Rank.EIGHT),
	Card.new(Suit.HEARTS, Rank.EIGHT),
	Card.new(Suit.SPADES, Rank.EIGHT),

	# Nines
	Card.new(Suit.CLOVER, Rank.NINE),
	Card.new(Suit.DIAMOND, Rank.NINE),
	Card.new(Suit.HEARTS, Rank.NINE),
	Card.new(Suit.SPADES, Rank.NINE),

	# Tens
	Card.new(Suit.CLOVER, Rank.TEN),
	Card.new(Suit.DIAMOND, Rank.TEN),
	Card.new(Suit.HEARTS, Rank.TEN),
	Card.new(Suit.SPADES, Rank.TEN),

	# Jacks
	Card.new(Suit.CLOVER, Rank.JACK),
	Card.new(Suit.DIAMOND, Rank.JACK),
	Card.new(Suit.HEARTS, Rank.JACK),
	Card.new(Suit.SPADES, Rank.JACK),

	# Queens
	Card.new(Suit.CLOVER, Rank.QUEEN),
	Card.new(Suit.DIAMOND, Rank.QUEEN),
	Card.new(Suit.HEARTS, Rank.QUEEN),
	Card.new(Suit.SPADES, Rank.QUEEN),

	# Kings
	Card.new(Suit.CLOVER, Rank.KING),
	Card.new(Suit.DIAMOND, Rank.KING),
	Card.new(Suit.HEARTS, Rank.KING),
	Card.new(Suit.SPADES, Rank.KING),

	# Jokers
	Card.new(Suit.JOKER0, Rank.JOKER),
	Card.new(Suit.JOKER1, Rank.JOKER),
]


var cards: Array[Card] = []

static func from_custom_deck_name(custom_deck_name: String) -> Deck:
	
	var _self = Deck.new()
		
	for deck_cards in SqlManager.query_deck_cards(custom_deck_name):
		
		for __ in range(deck_cards.get_card_count()):
			_self.cards.append(deck_cards.card)
			
	return _self

static func from_bounds_and_seed(min_size: int, max_size: int, _seed: int = 0) -> Deck:

	var _self = Deck.new()
	
	# Duplicate the base deck to create a potential full deck
	@warning_ignore( "integer_division" )
	var num_decks: int = max_size/Deck.base_deck.size()
	if max_size % Deck.base_deck.size():  # Simulate ceil()
		num_decks += 1

	for __ in range(num_decks):
		_self.cards += Deck.base_deck.duplicate()


	_self.shuffle(_seed)

	var rng = RandomNumberGenerator.new()
	rng.seed = _seed
	
	# Determine a random size within the provided bounds
	var deck_size = rng.randi_range(min_size, max_size)

	_self.cards.resize(deck_size)
	
	return _self


func shuffle(_seed: int = 0) -> void:

	if _seed == 0:
		_seed = randi()

	var rng = RandomNumberGenerator.new()
	rng.seed = _seed

	# Shuffle the cards using the seeded RNG
	for i in range(cards.size()):
		var j = rng.randi_range(0, cards.size() - 1)

		# Swap self.cards[i] and self.cards[j]
		var cardi: Card = self.cards[i]
		self.cards[i] = self.cards[j]
		self.cards[j] = cardi
