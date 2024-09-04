extends Resource

class_name Card

# Enums for card suits and ranks
enum Suit { CLOVER, DIAMOND, HEARTS, SPADES }
enum Rank { ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, JOKER }

var suit: Suit
var rank: Rank
var card_texture: Texture2D

func _init(suit: Suit, rank: Rank):
	self.suit = suit
	self.rank = rank
	self.card_texture = TextureManager.get_card_texture(suit, rank)


func is_face_card() -> bool:
	return self.rank in [Rank.JACK, Rank.QUEEN, Rank.KING, Rank.JOKER]
	
func is_numeric_card() -> bool:
	return self.rank in [Rank.ACE, Rank.TWO, Rank.THREE, Rank.FOUR, Rank.FIVE, Rank.SIX, Rank.SEVEN, Rank.EIGHT, Rank.NINE, Rank.TEN]
