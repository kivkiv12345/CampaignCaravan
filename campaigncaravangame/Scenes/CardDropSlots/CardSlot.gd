## Super Abstract Base Class for card slots

extends TextureRect

class_name CardSlot

var card: Card = null
@export var fix_rotation: bool = true  # Allow control over whether to correct rotation

func _ready() -> void:
	# We are connecting these signals in code,
	#	to make sure they're also applied to subclasses.
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)

#func _ready() -> void:
	#if self.fix_rotation:
		#self.pivot_offset = Vector2i(-self.size.x, -self.size.y) / 2
		#self.rotation = -self.get_global_transform_with_canvas().get_rotation()
#
#func _process(delta: float) -> void:
	#if self.fix_rotation:
		#self.pivot_offset = Vector2i(self.size.x, self.size.y) / 2
		#self.rotation += 0.0001/delta

## Update the card displayed in this slot
func set_card(new_card: Card) -> void:
	self.card = new_card
	self.texture = new_card.card_texture

func remove_card() -> void:
	self.card = null
	self.texture = null


## Needed for release export to work, probably because CardSlot is a base class
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return false


## May not be neccesary like _can_drop_data(), but we include it for completeness.
func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	return


## Inspired by: https://forum.godotengine.org/t/how-to-change-the-color-of-a-label-after-the-mouse-hovers-over-a-button/52092/2
## Returns a bool, indicating whether a card has snapped to this slot
func _on_mouse_entered() -> bool:
	
	if not self.has_method("_can_drop_data"):
		return false

	var drag_data = get_viewport().gui_get_drag_data()

	if not drag_data is DraggedCard:
		return false

	if not self._can_drop_data(get_viewport().get_mouse_position(), drag_data):
		return false

	self.set_modulate(Color.GREEN_YELLOW)  # TODO Kevin: Ideally I would want a white/brigter color, but that erases the modulation.

	if not self.is_in_group("OpenCardSlots"):
		# This is a CardHandSlot, or other subclass that we don't want snapping for.
		# This "if" is probably not very SOLID
		# Ideally we would connect this signal in a subclass,
		# but GDScript has neither multiple inheritance nor proper interfaces.
		# So OpenCardSlots is left as a humble group.
		# TODO Kevin: Actually, we could probably move parts of this signal to CaravanCardSlot
		return false

	drag_data.visible = false
	assert(self.card == null)
	assert(self.texture == null)
	# Setting the card here is merely meant as a preview to actually playing the card, 
	#	hence the previous asserts
	self.set_card(drag_data.card)
	
	return true


## Inspired by: https://forum.godotengine.org/t/how-to-change-the-color-of-a-label-after-the-mouse-hovers-over-a-button/52092/2
func _on_mouse_exited():
	
	self.set_modulate(Color.WHITE)
	
	if not self.is_in_group("OpenCardSlots"):
		# CardHandSlot, or other subclass that we don't want snapping for.
		# This is probably not very SOLID
		# Ideally we would connect this signal in a subclass,
		# but GDScript has neither multiple inheritance nor proper interfaces.
		# So OpenCardSlots is left as a humble group.
		# TODO Kevin: Actually, we could probably move parts of this signal to CaravanCardSlot
		return

	self.remove_card()
	var drag_data = get_viewport().gui_get_drag_data()
	
	if drag_data is DraggedCard:
		drag_data.visible = true
