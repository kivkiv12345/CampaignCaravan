extends Resource

class_name Card

#var owner: Node = null  # TODO Kevin: Should we have an owner variable, to make sure the card can only be located at one place?

# Enums for card suits and ranks
# Start from 1, as to reserve Vector2i.ZERO for errors
enum Suit { NONE = 0, CLOVER = 1, DIAMOND, HEARTS, SPADES, JOKER0, JOKER1 }  # Jokers don't have a suit, and we use this fact to uniquely idenfity either of them (for texturing purposes).
enum Rank { NONE = 0, ACE = 1, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, JOKER }

var suit: Suit = Suit.NONE
var rank: Rank = Rank.NONE
var card_texture: Texture2D
var back_texture: Texture2D

func _init(_suit: Suit, _rank: Rank):
	self.suit = _suit
	self.rank = _rank
	self.card_texture = TextureManager.get_card_texture(_suit, _rank)


func get_index() -> int:
	
	var card_index: int = -1
	for card_vector in TextureManager.texture_paths:
		card_index += 1
		
		if card_vector == Vector2i(self.suit, self.rank):
			return card_index

	assert(false)
	return card_index


func is_face_card() -> bool:
	return self.rank in [Rank.JACK, Rank.QUEEN, Rank.KING, Rank.JOKER]
	
func is_numeric_card() -> bool:
	return self.rank in [Rank.ACE, Rank.TWO, Rank.THREE, Rank.FOUR, Rank.FIVE, Rank.SIX, Rank.SEVEN, Rank.EIGHT, Rank.NINE, Rank.TEN]
