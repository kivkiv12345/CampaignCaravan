extends RichTextLabel

const slant: float = 0.5

@export var fix_rotation: bool = true  # Allow control over whether to correct rotation


func _ready() -> void:
	
	self.visible = false
	self.add_theme_font_size_override("normal_font_size", 52)
	
	if self.fix_rotation:
		self.pivot_offset = Vector2(self.size.x, self.size.y) / 2.0
		self.rotation = -self.get_global_transform_with_canvas().get_rotation() + self.slant


func _on_player_lost(_player: Player) -> void:
	self.set_modulate(Color.RED)
	self.text = "[center]LOSER[/center]"
	self.visible = true


func _on_player_won(_player: Player) -> void:
	self.set_modulate(Color.GREEN)
	self.text = "[center]WINNER[/center]"
	self.visible = true
