extends Node

const Suit := Card.Suit
const Rank := Card.Rank

# I had thought that GDscript supported "tuples" (or something similar) as keys.
# But it appears that GDscript doesn't feature tuples at all.
# Perhaps lists can be used as keys,
# but we are probably better served by restricting ourselves to Vector2i keys.
var texture_paths := {

	# Aces
	Vector2i(Suit.CLOVER, Rank.ACE): preload("res://CardTextures/a_clover_lanius.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.ACE): preload("res://CardTextures/a_diamond_nero.jpeg"),
	Vector2i(Suit.HEARTS, Rank.ACE): preload("res://CardTextures/a_hearts_oliver.jpeg"),
	Vector2i(Suit.SPADES, Rank.ACE): preload("res://CardTextures/a_spades_pacer.jpeg"),

	# Twos
	Vector2i(Suit.CLOVER, Rank.TWO): preload("res://CardTextures/2_clover_alexus.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.TWO): preload("res://CardTextures/2_diamond_marilyn.jpeg"),
	Vector2i(Suit.HEARTS, Rank.TWO): preload("res://CardTextures/2_hearts_boone.jpeg"),
	Vector2i(Suit.SPADES, Rank.TWO): preload("res://CardTextures/2_spades_twins.jpeg"),

	# Threes
	Vector2i(Suit.CLOVER, Rank.THREE): preload("res://CardTextures/3_clover_ulysses.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.THREE): preload("res://CardTextures/3_diamond_gunderson.jpeg"),
	Vector2i(Suit.HEARTS, Rank.THREE): preload("res://CardTextures/3_hearts_cass.jpeg"),
	Vector2i(Suit.SPADES, Rank.THREE): preload("res://CardTextures/3_spades_jules.jpeg"),

	# Fours
	Vector2i(Suit.CLOVER, Rank.FOUR): preload("res://CardTextures/4_clover_runner.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.FOUR): preload("res://CardTextures/4_diamond_sarah.jpeg"),
	Vector2i(Suit.HEARTS, Rank.FOUR): preload("res://CardTextures/4_hearts_pappas.jpeg"),
	Vector2i(Suit.SPADES, Rank.FOUR): preload("res://CardTextures/4_spades_motor.jpeg"),

	# Fives
	Vector2i(Suit.CLOVER, Rank.FIVE): preload("res://CardTextures/5_clover_phoenix.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.FIVE): preload("res://CardTextures/5_diamond_angelo.jpeg"),
	Vector2i(Suit.HEARTS, Rank.FIVE): preload("res://CardTextures/5_hearts_crocker.jpeg"),
	Vector2i(Suit.SPADES, Rank.FIVE): preload("res://CardTextures/5_spades_rex.jpeg"),

	# Sixes
	Vector2i(Suit.CLOVER, Rank.SIX): preload("res://CardTextures/6_clover_siri.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.SIX): preload("res://CardTextures/6_diamond_tommy.jpeg"),
	Vector2i(Suit.HEARTS, Rank.SIX): preload("res://CardTextures/6_hearts_alice.jpeg"),
	Vector2i(Suit.SPADES, Rank.SIX): preload("res://CardTextures/6_spades_arcade.jpeg"),

	# Sevens
	Vector2i(Suit.CLOVER, Rank.SEVEN): preload("res://CardTextures/7_clover_cato.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.SEVEN): preload("res://CardTextures/7_diamond_vegas.jpeg"),
	Vector2i(Suit.HEARTS, Rank.SEVEN): preload("res://CardTextures/7_hearts_hsu.jpeg"),
	Vector2i(Suit.SPADES, Rank.SEVEN): preload("res://CardTextures/7_spades_dixon.jpeg"),

	# Eights
	Vector2i(Suit.CLOVER, Rank.EIGHT): preload("res://CardTextures/8_clover_speculatores.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.EIGHT): preload("res://CardTextures/8_diamond_whiteglove.jpeg"),
	Vector2i(Suit.HEARTS, Rank.EIGHT): preload("res://CardTextures/8_hearts_rangers.jpeg"),
	Vector2i(Suit.SPADES, Rank.EIGHT): preload("res://CardTextures/8_spades_graffs.jpeg"),

	# Nines
	Vector2i(Suit.CLOVER, Rank.NINE): preload("res://CardTextures/9_clover_frumentarii.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.NINE): preload("res://CardTextures/9_diamond_omertas.jpeg"),
	Vector2i(Suit.HEARTS, Rank.NINE): preload("res://CardTextures/9_hearts_caravan.jpeg"),
	Vector2i(Suit.SPADES, Rank.NINE): preload("res://CardTextures/9_spades_followers.jpeg"),

	# Tens
	Vector2i(Suit.CLOVER, Rank.TEN): preload("res://CardTextures/10_clover_praetorian.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.TEN): preload("res://CardTextures/10_diamond_chairmen.jpeg"),
	Vector2i(Suit.HEARTS, Rank.TEN): preload("res://CardTextures/10_hearts_gunrunners.jpeg"),
	Vector2i(Suit.SPADES, Rank.TEN): preload("res://CardTextures/10_spades_kings.jpeg"),

	# Jacks
	Vector2i(Suit.CLOVER, Rank.JACK): preload("res://CardTextures/j_clover_vulpes.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.JACK): preload("res://CardTextures/j_diamond_swank.jpeg"),
	Vector2i(Suit.HEARTS, Rank.JACK): preload("res://CardTextures/j_hearts_hanlon.jpeg"),
	Vector2i(Suit.SPADES, Rank.JACK): preload("res://CardTextures/j_spades_baptiste.jpeg"),

	# Queens
	Vector2i(Suit.CLOVER, Rank.QUEEN): preload("res://CardTextures/q_clover_lupa.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.QUEEN): preload("res://CardTextures/q_diamond_marjorie.jpeg"),
	Vector2i(Suit.HEARTS, Rank.QUEEN): preload("res://CardTextures/q_hearts_moore.jpeg"),
	Vector2i(Suit.SPADES, Rank.QUEEN): preload("res://CardTextures/q_spades_julie.jpeg"),

	# Kings
	Vector2i(Suit.CLOVER, Rank.KING): preload("res://CardTextures/k_clover_caesar.jpeg"),
	Vector2i(Suit.DIAMOND, Rank.KING): preload("res://CardTextures/k_diamond_house.jpeg"),
	Vector2i(Suit.HEARTS, Rank.KING): preload("res://CardTextures/k_hearts_kimball.jpeg"),
	Vector2i(Suit.SPADES, Rank.KING): preload("res://CardTextures/k_spades_king.jpeg"),

	# Jokers
	Vector2i(Suit.JOKER0, Rank.JOKER): preload("res://CardTextures/joker_benny.jpeg"),
	Vector2i(Suit.JOKER1, Rank.JOKER): preload("res://CardTextures/joker_courier.jpeg"),
}

var back_textures: Array = [
	preload("res://CardTextures/back_bison.jpeg"),
	preload("res://CardTextures/back_gomorrah.jpeg"),
	preload("res://CardTextures/back_lucky38.jpeg"),
	preload("res://CardTextures/back_silverrush.jpeg"),
	preload("res://CardTextures/back_tops.jpeg"),
	preload("res://CardTextures/back_ultraluxe.jpeg"),
	preload("res://CardTextures/back_wrangler.jpeg"),
]

func get_card_texture(suit: Suit, rank: Rank) -> Texture2D:
	return texture_paths[Vector2i(suit, rank)]

func get_card_from_texture(texture: Texture2D) -> Vector2i:
	for key in texture_paths:
		if texture_paths[key] == texture:
			return key
	return Vector2i.ZERO;
