# Modified from: https://pastebin.com/vymW5TJS (https://www.youtube.com/watch?v=8cV-5ByZLOE)
extends TextureRect
 
## Is likely to spawn a DragPreview Card when the player goes to drag this card from thier hand.
func _get_drag_data(at_position):
	
	# Using the texture itself feels pretty dirty, but maybe it's okay for now.
	var card_vector: Vector2i = TextureManager.get_card_from_texture(self.texture)
	var card_instance: Card = Card.new(card_vector.x, card_vector.y)
	
	const drag_preview_scene = preload("res://DragPreview.tscn")
	var drag_preview: Control = drag_preview_scene.instantiate()
	var preview_texture: DragPreview = drag_preview.get_node("TextureRect")
	
	preview_texture.card = card_instance
	preview_texture.texture = self.texture
	preview_texture.expand_mode = self.expand_mode
	preview_texture.size = self.size

	# Calculate the mouse offset relative to the original control.
	var mouse_offset = at_position - self.global_position

	# Set the duplicated node's position to the offset relative to the mouse.
	var offset: Vector2 = (mouse_offset - at_position) - mouse_offset
	
	preview_texture.position = (mouse_offset - at_position) - mouse_offset

	# Actually show the dragged preview
	self.set_drag_preview(drag_preview)

	# And remove the texture from the original control,
	# So it looks like we're moving a card, rather than duplicating it.
	self.texture = null
 
	# Then we return the object needed for ._can_drop_data() and ._drop_data()
	return preview_texture.texture

func _can_drop_data(_pos, data):
	return data is Texture2D

func _drop_data(_pos, data):
	self.texture = data
