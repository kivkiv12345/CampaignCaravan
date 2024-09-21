## Much of the drag-and-drop functionality has been inspired by: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
## Especially in regards to handling invalid drop locations.

extends TextureRect

class_name DraggedCard

var source: CardHandSlot = null
var destination: TextureRect = null  # Will be set by the OpenCardSlot._drop_data()

var card: Card = null  # Determines the preview


func _init(_source: CardHandSlot, _card: Card, render_offset: Vector2 = Vector2.ZERO):
	self.source = _source
	self.card = _card
	self.texture = _card.card_texture

	self.tree_exiting.connect(self._on_tree_exiting)
	self.tree_entered.connect(self._on_tree_entered)
	
	self.expand_mode = _source.expand_mode
	self.size = _source.size
		
	if render_offset:
		self.position = render_offset

#func _ready():
	##self.rotation = 150
	##self.offset_right += 1000
	#if card:
		#self.texture = card.card_texture

## Source: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
func _on_tree_exiting()->void:
	for slot in self.get_tree().get_nodes_in_group("OpenCardSlots"):
		assert(slot is CardSlot)
		slot.visible = false
	# As per the source linked above, this is a good location to emit a signal.
	# But for now it's probably better to message the destination directly.
	if self.destination == null:
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/menu/ui_menu_cancel.wav"), 0, 0, randf_range(0.98, 1.05))
		self.return_to_original_position()


func return_to_original_position() -> bool:
	if self.source.card != self.card:
		return false  # Someone has taken our slot while we were gone. We cannot override that card.
	
	self.source.set_card(self.card)
	return true
	# TODO Kevin: Should we destroy ourselves here?


func _on_tree_entered() -> void:
	for slot in self.source.hand.player.get_legal_slots(self.source):
		slot.visible = true
