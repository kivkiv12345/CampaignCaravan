# Modified from: https://pastebin.com/vymW5TJS (https://www.youtube.com/watch?v=8cV-5ByZLOE)
extends CardSlot
 
class_name CardHandSlot

@export var hand: Hand = null


func _ready() -> void:
	self.hand = self.find_parent("Hand")


func _on_card_played(dropslot: CardSlot) -> void:
	assert(self.hand != null)
	self.hand._on_card_played(dropslot, self)

## Show the back texture of cards in the opponent's hand
func set_card(new_card: Card) -> void:
	super(new_card)
	if self.hand.player.is_enemy_player:
		self.texture = new_card.back_texture

## Is likely to spawn a DraggedCard Card when the player goes to drag this card from thier hand.
func _get_drag_data(at_position: Vector2):

	if self.texture == null:  # But 'error' if this doesn't work
		return null  # This is almost an assertion, but returning null is a good way to handle this error.
		
	if self.hand.player.is_enemy_player:
		return null  # We are not allowed to take cards out of the enemy' hand

	if self.hand.player.has_lost:
		return null  # Players that have lost can only spectate

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

	# Check that we are not trying to drop the card into the opponent's hand
	if self.hand.player != card_data.source.hand.player:
		return false

	# We should probably not allow dropping a card which already has another destination.
	#	Although I don't know how this is posible.
	if card_data.destination != null:
		return false

	# Also swapping with ourselves could maybe cause weirdness,
	#	so let's also deny that.
	if card_data.source == self:
		return false
		
	# TODO Kevin: Maybe it would be good to check whether this card is in play (being dragged),
	#	which would prevent bugs with swapping cards that have already been played.
	#	But this probably requires introducing a new field, which incurs more state.

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

	# TODO Kevin: This is a pretty spaghetti place to reset the visual feedback.
	#	But all other slots can rely on the fact that they go invisible when the card is dropped,
	#	and then wait for the mouse to leave their hitbox to reset their color.
	self.set_modulate(Color.WHITE)
