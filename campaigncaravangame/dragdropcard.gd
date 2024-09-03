# Source: https://pastebin.com/vymW5TJS (https://www.youtube.com/watch?v=8cV-5ByZLOE)
extends TextureRect
 
func _get_drag_data(at_position):
	var preview_texture = TextureRect.new()
 
	preview_texture.texture = self.texture
	preview_texture.expand_mode = self.expand_mode
	preview_texture.size = self.size
 
	var preview = Control.new()
	preview.add_child(preview_texture)
 
	set_drag_preview(preview)
	self.texture = null
 
	return preview_texture.texture
 
func _can_drop_data(_pos, data):
	return data is Texture2D
 
 
func _drop_data(_pos, data):
	self.texture = data
