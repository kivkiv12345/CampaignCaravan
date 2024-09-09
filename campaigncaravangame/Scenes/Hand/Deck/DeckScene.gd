extends Control

class_name DeckScene

var deck: Deck = null
@export var texture_seed: int = 12345  # Simply detemines the back textures of cards in the deck, the cards drawn or therein
var rng = RandomNumberGenerator.new()

const ROT_LIMIT = 0.2
const OFFSET_LIMIT = 10


func _ready() -> void:
	self.rng.seed = self.texture_seed

func fill_deck(_deck: Deck) -> void:
	self.deck = _deck
	
	for card in _deck.cards:
		
		# Use $Base_TextureRect as an 'abstract' (invisible) TextureRect that we can inherit attributes from.
		var deckcard_back = $Base_TextureRect.duplicate()
		assert(deckcard_back is TextureRect)
		
		deckcard_back.pivot_offset = Vector2i(deckcard_back.size.x, deckcard_back.size.x) / 2  # Pivot around center
		deckcard_back.rotation = self.rng.randf_range(-self.ROT_LIMIT, self.ROT_LIMIT)  # Apply a bit of random rotation
		deckcard_back.position += Vector2(self.rng.randf_range(-self.OFFSET_LIMIT, self.OFFSET_LIMIT), self.rng.randf_range(-self.OFFSET_LIMIT, self.OFFSET_LIMIT))  # And a bit of random offset
		
		deckcard_back.texture = TextureManager.back_textures[self.rng.randi_range(0, TextureManager.back_textures.size()-1)]
		card.back_texture = deckcard_back.texture
		
		$Cards.add_child(deckcard_back)


func get_card() -> Card:
	var cards: Array[Node] = $Cards.get_children()
	$Cards.remove_child(cards.back())
	return self.deck.cards.pop_back()
