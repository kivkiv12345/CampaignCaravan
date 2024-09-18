extends TextureButton


signal desire_texture_preview(texture: Texture2D)
signal revoke_texture_preview(texture: Texture2D)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_pressed() -> void:
	print("CCCCCCCCC")
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	self.desire_texture_preview.emit(self.texture_normal)


func _on_mouse_exited() -> void:
	self.revoke_texture_preview.emit(self.texture_normal)


func _on_button_down() -> void:
	self.set_modulate(Color.GREEN_YELLOW)


func _on_button_up() -> void:
	self.set_modulate(Color.WHITE)
