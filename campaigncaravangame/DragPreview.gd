extends TextureRect

class_name DragPreview

var card: Card

#func _init(card: Card):
	#self.card = card

func _init():
	self.tree_exiting.connect(self._on_tree_exiting)

func _ready():
	#self.rotation = 150
	#self.offset_right += 1000
	if card:
		self.texture = card.card_texture

func _can_drop_data(_pos, data):
	if data is Card:
		# Example logic to check if the card can be dropped
		return card.card_type == data.card_type
	return false

func _drop_data(_pos, data):
	if self._can_drop_data(_pos, data):  # Probably not needed
		$TextureRect.texture = data.card_texture
	else:
		return_to_original_position()

## Source: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
func _on_tree_exiting()->void:
	print("AAAAAa")

func return_to_original_position():
	# Logic to return the card to its original position
	pass
