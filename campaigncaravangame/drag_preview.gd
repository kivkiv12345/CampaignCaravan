extends TextureRect

var card: Card

func _init(card: Card):
	self.card = card

func _ready():
	if card:
		$TextureRect.texture = card.card_texture

func _can_drop_data(_pos, data):
	if data is Card:
		# Example logic to check if the card can be dropped
		return card.card_type == data.card_type
	return false

func _drop_data(_pos, data):
	if _can_drop_data(_pos, data):
		$TextureRect.texture = data.card_texture
	else:
		return_to_original_position()

func return_to_original_position():
	# Logic to return the card to its original position
	pass
