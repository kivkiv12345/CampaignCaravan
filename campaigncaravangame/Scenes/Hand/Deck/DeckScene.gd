extends Control

class_name DeckScene


signal card_drawn(deck: DeckScene, card: Card)
signal deck_size_changed(deck: DeckScene)

var deck: Deck = null
@export var texture_seed: int = 12345  # Simply detemines the back textures of cards in the deck, the cards drawn or therein
var rng = RandomNumberGenerator.new()

const ROT_LIMIT = 0.2
const OFFSET_LIMIT = 10


func _ready() -> void:
	self.rng.seed = self.texture_seed

func fill_deck(_deck: Deck) -> void:
	self.deck = _deck

	for card in $Cards.get_children():
		$Cards.remove_child(card)

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
		
	self.deck_size_changed.emit(self)


func get_deck_size() -> int:
	return $Cards.get_child_count()

static func _random_cardfold_sound():

	const card_sounds = [
		preload("res://FalloutNVUISounds/casino/cardtable/sfx_cards_os_01.ogg"),
		preload("res://FalloutNVUISounds/casino/cardtable/sfx_cards_os_02.ogg"),
		preload("res://FalloutNVUISounds/casino/cardtable/sfx_cards_os_03.ogg"),
		preload("res://FalloutNVUISounds/casino/cardtable/sfx_cards_os_04.ogg"),
		preload("res://FalloutNVUISounds/casino/cardtable/sfx_cards_os_05.ogg"),
	]
	var rand_index:int = randi() % card_sounds.size()
	SoundManager.playback.play_stream(card_sounds[rand_index], 0, 0, randf_range(0.98, 1.05))

func unseeded_shuffle() -> void:

	DeckScene._random_cardfold_sound()

	self.deck.shuffle()

	# Shuffle the cards using the seeded RNG
	for i in range($Cards.get_child_count()):
		var j = randi_range(0, $Cards.get_child_count() - 1)
		$Cards.move_child($Cards.get_child(i), j)


func get_card() -> Card:
	var cards: Array[Node] = $Cards.get_children()
	
	if cards.is_empty():
		return null
	
	$Cards.remove_child(cards.back())
	var card: Card = self.deck.cards.pop_back()
	self.deck_size_changed.emit(self)
	self.card_drawn.emit(self, card)
	return card
