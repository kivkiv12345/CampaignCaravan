extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(self._update_checkbox_icon)
	self._update_checkbox_icon()


func _update_checkbox_icon() -> void:
	if self.is_pressed():
		self.icon = preload("res://MCMChecked.png")
	else:
		self.icon = preload("res://MCMUnchecked.png")
