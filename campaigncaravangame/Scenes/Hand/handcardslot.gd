# Modified from: https://pastebin.com/vymW5TJS (https://www.youtube.com/watch?v=8cV-5ByZLOE)
extends CardSlot
 
class_name CardHandSlot

## Is likely to spawn a DraggedCard Card when the player goes to drag this card from thier hand.
func _get_drag_data(at_position: Vector2):

	if self.texture == null:  # But 'error' if this doesn't work
		return null  # This is almost an assertion, but returning null is a good way to handle this error.

	# Calculate the mouse offset relative to the original control.
	var mouse_offset: Vector2 = at_position - self.global_position
	var render_offset: Vector2 = (mouse_offset - at_position) - mouse_offset
	
	var drag_preview: Control = Control.new()
	var preview_texture: DraggedCard = DraggedCard.new(self, card, render_offset)
	drag_preview.add_child(preview_texture)  # A Control node must be root, for offset/positioning to work, for reasons.

	# Actually show the dragged preview
	self.set_drag_preview(drag_preview)

	# And remove the texture from the original control,
	# So it looks like we're moving a card, rather than duplicating it.
	# Only remove the texture, so we can pass self for AI player,
	# that will not be dragging cards with the UI
	#self.remove_card()
	self.texture = null
 
	# Then we return the object needed for ._can_drop_data() and ._drop_data()
	return preview_texture

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:

	if not (data is DraggedCard):
		return false

	var card_data = data as DraggedCard

	# TODO Kevin: Check that we are not trying to drop the card into the opponent's hand

	# We should probably not allow dropping a card which already has another destination.
	#	Although I don't know how this is posible.
	if card_data.destination != null:
		return false

	# Also swapping with ourselves could maybe cause weirdness,
	#	so let's also deny that.
	if card_data.source == self:
		return false

	# Dropping the card here will swap locations in the hand.
	return true

## Cards can be dropped back into a player's own hand, for reordering purposes.
func _drop_data(_pos, data):
	assert(data is DraggedCard)

	var card_data = data as DraggedCard

	assert(card_data.source != null)

	# We would've had to set card_data.destination here.
	#	But we have DraggedCard check whether its source has been overwritten.

	# Keep track of our current card
	var current_card: Card = self.card

	# Then swap it with the newly dropped card
	self.set_card(card_data.card)

	# And move our (now) old card to the source of the dragged card
	card_data.source.set_card(current_card)
