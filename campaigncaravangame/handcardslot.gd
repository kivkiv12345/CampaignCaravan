# Modified from: https://pastebin.com/vymW5TJS (https://www.youtube.com/watch?v=8cV-5ByZLOE)
extends TextureRect
 
class_name CardHandSlot

var card: Card = null

## Update the card displayed in this slot
func set_card(new_card: Card) -> void:
	self.card = new_card
	self.texture = card.card_texture

func remove_card() -> void:
	self.card = null
	self.texture = null

## Is likely to spawn a DragPreview Card when the player goes to drag this card from thier hand.
func _get_drag_data(at_position: Vector2):

	if self.card == null:  # Try finding the card from the texture.
		# Using the texture itself feels pretty dirty, but maybe it's okay for now.
		var card_vector: Vector2i = TextureManager.get_card_from_texture(self.texture)
		if card_vector != Vector2i.ZERO:
			self.card = Card.new(card_vector.x, card_vector.y)

	if self.card == null:  # But 'error' if this doesn't work
		return null  # This is almost an assertion, but returning null is a good way to handle this error.
	
	# Calculate the mouse offset relative to the original control.
	var mouse_offset: Vector2 = at_position - self.global_position
	var render_offset: Vector2 = (mouse_offset - at_position) - mouse_offset
	
	var drag_preview: Control = Control.new()
	var preview_texture: DragPreview = DragPreview.new(self, card, render_offset)
	drag_preview.add_child(preview_texture)  # A Control node must be root, for offset/positioning to work, for reasons.

	# Actually show the dragged preview
	self.set_drag_preview(drag_preview)

	# And remove the texture from the original control,
	# So it looks like we're moving a card, rather than duplicating it.
	self.remove_card()
 
	# Then we return the object needed for ._can_drop_data() and ._drop_data()
	return preview_texture.texture

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	# Cards can not intentially be dropped back into the hand,
	# but they will return to their origin when dropped invalidly.
	return false

func _drop_data(_pos, data):
	self.texture = data
