## Super Abstract Base Class for card slots

extends TextureRect

class_name CardSlot

var card: Card = null

func _init() -> void:
	# We are connecting these signals in code,
	#	to make sure they're also applied to subclasses.
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)

## Update the card displayed in this slot
func set_card(new_card: Card) -> void:
	self.card = new_card
	self.texture = new_card.card_texture

func remove_card() -> void:
	self.card = null
	self.texture = null


## Inspired by: https://forum.godotengine.org/t/how-to-change-the-color-of-a-label-after-the-mouse-hovers-over-a-button/52092/2
func _on_mouse_entered():
	
	if not self.has_method("_can_drop_data"):
		return
	
	var drag_data = get_viewport().gui_get_drag_data()
	
	if self._can_drop_data(get_viewport().get_mouse_position(), drag_data):
		self.set_modulate(Color.GREEN_YELLOW)  # TODO Kevin: Ideally I would want a white/brigter color, but that erases the modulation.

## Inspired by: https://forum.godotengine.org/t/how-to-change-the-color-of-a-label-after-the-mouse-hovers-over-a-button/52092/2
func _on_mouse_exited():
	self.set_modulate(Color.WHITE)
