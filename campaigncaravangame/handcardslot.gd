# Modified from: https://pastebin.com/vymW5TJS (https://www.youtube.com/watch?v=8cV-5ByZLOE)
extends TextureRect
 
class_name CardHandSlot

## Is likely to spawn a DragPreview Card when the player goes to drag this card from thier hand.
func _get_drag_data(at_position: Vector2):
	
	# Using the texture itself feels pretty dirty, but maybe it's okay for now.
	var card_vector: Vector2i = TextureManager.get_card_from_texture(self.texture)
	var card: Card = Card.new(card_vector.x, card_vector.y)
	
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
	self.texture = null
 
	# Then we return the object needed for ._can_drop_data() and ._drop_data()
	return preview_texture.texture

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	# Cards can not intentially be dropped back into the hand,
	# but they will return to their origin when dropped invalidly.
	return false

func _drop_data(_pos, data):
	self.texture = data
