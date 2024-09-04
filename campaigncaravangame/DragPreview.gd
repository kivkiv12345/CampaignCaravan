## Much of the drag-and-drop functionality has been inspired by: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
## Especially in regards to handling invalid drop locations.

extends TextureRect

class_name DragPreview

var source: CardHandSlot = null
var destination: CardDropSlot = null  # Will be set by the CardDropSlot._drop_data()

var card: Card = null  # Determines the preview

#func _init(card: Card):
	#self.card = card

func _init(source: CardHandSlot, card: Card, render_offset: Vector2 = Vector2.ZERO):
	self.source = source
	self.card = card
	self.texture = card.card_texture
	self.tree_exiting.connect(self._on_tree_exiting)
	
	self.expand_mode = source.expand_mode
	self.size = source.size
		
	if render_offset:
		self.position = render_offset

#func _ready():
	##self.rotation = 150
	##self.offset_right += 1000
	#if card:
		#self.texture = card.card_texture

## Source: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
func _on_tree_exiting()->void:
	# As per the source linked above, this is a good location to emit a signal.
	# But for now it's probably better to message the destination directly.
	if self.destination == null:
		self.return_to_original_position()

func return_to_original_position():
	# Logic to return the card to its original position
	# TODO Kevin: We probably want this to be more robust.
	#	AKA, a more strongly defined interface
	self.source.texture = self.card.card_texture
