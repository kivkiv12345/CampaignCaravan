extends TextureButton


class_name DeckCustomizerCardButton


signal desire_texture_preview(texture: Texture2D)
signal revoke_texture_preview(texture: Texture2D)


var card: Card = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.card == null:
		var card_vector: Vector2i = TextureManager.get_card_from_texture(self.texture_normal)
		self.card = Card.new(card_vector.x, card_vector.y)
	else:
		self.texture_normal = TextureManager.get_card_texture(self.card.suit, self.card.rank)


func _on_mouse_entered() -> void:
	self.desire_texture_preview.emit(self.texture_normal)


func _on_mouse_exited() -> void:
	#self.revoke_texture_preview.emit(self.texture_normal)  # Comment in to hide card preview when mouse leaves card
	pass


func _on_button_down() -> void:
	self.set_modulate(Color.GREEN_YELLOW)


func _on_button_up() -> void:
	self.set_modulate(Color.WHITE)
