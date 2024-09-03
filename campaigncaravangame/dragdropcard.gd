# Modified from: https://pastebin.com/vymW5TJS (https://www.youtube.com/watch?v=8cV-5ByZLOE)
extends TextureRect
 
func _get_drag_data(at_position):

	# Duplicating nodes apparently has trouble copying scripts,
	# but perhaps this is what we want for dragdropcard.gd.
	# Otherwise we may consider creating a new scene with load("res://NormalCardSlot.tscn").
	var preview_texture: TextureRect = self.duplicate()

	# Got a little help from https://chatgpt.com here with preview.get_node().
	# I thought .get_node() was a global function indexing from the tree root,
	# I didn't relize it's a method called on self.
	# (sometimes I wish typing self. wasn't optional...)
	var panel: Panel = preview_texture.get_node("Panel")
	preview_texture.remove_child(panel)

	# Ensure the preview is positioned relative to the mouse cursor.
	# Set the position of the preview_texture to zero within the Control.
	preview_texture.position = Vector2.ZERO

	# The original script would create a TextureRect.new() here,
	# and set the desired properties.
	# But I think it's more flexible to simple duplicate the one we have.
	# Unfortunatly this is recursive, which we actually don't care for.
	#var preview_texture = TextureRect.new()
	#preview_texture.texture = self.texture
	#preview_texture.expand_mode = self.expand_mode
	#preview_texture.size = self.size

	var preview: Control = Control.new()
	preview.add_child(preview_texture)

	# Calculate the mouse offset relative to the original control.
	var mouse_offset = at_position - self.global_position

	# Set the duplicated node's position to the offset relative to the mouse.
	preview_texture.position = (mouse_offset - at_position) - mouse_offset

	# Actually show the dragged preview
	self.set_drag_preview(preview)

	# And remove the texture from the original control,
	# So it looks like we're moving a card, rather than duplicating it.
	self.texture = null
 
	# Then we return the object needed for ._can_drop_data() and ._drop_data()
	return preview_texture.texture

func _can_drop_data(_pos, data):
	return data is Texture2D

func _drop_data(_pos, data):
	self.texture = data
