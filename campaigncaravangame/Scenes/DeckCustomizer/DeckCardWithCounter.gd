extends DeckCustomizerCardButton

class_name DeckCardWithCounter


signal card_count_changed(deck_card_with_counter: DeckCardWithCounter)


var _num_cards: int = 1


func _ready() -> void:
	super()
	# Make sure visual matches with value
	self.set_card_count(self._num_cards)
	
	# TODO Kevin: Not ideal that we emit the signal for the base card
	
	# .set_card_count() will not emit self.card_count_changed if the count is unchanged,
	#	and we don't change the count here in init,
	#	we just call self.set_card_count() to fix the text.
	#	So we emit the signal here, because surely the count changed if a new card is added.
	self.card_count_changed.emit(self)


func get_card_count() -> int:
	return self._num_cards


func set_card_count(count: int) -> void:
	
	var should_emit: bool = true
	if self._num_cards == count:
		should_emit = false
		
	self._num_cards = count

	%CardCountRichTextLabel.text = "[center]"

	if String.num_int64(self._num_cards).length() <= 3:
		%CardCountRichTextLabel.text += "x"

	%CardCountRichTextLabel.text += String.num_int64(self._num_cards)
	%CardCountRichTextLabel.text += "[/center]"
	
	if self._num_cards <= 0:
		# Remove self from tree before signal, to update save button correctly.
		self.get_parent().remove_child(self)
		self.queue_free()
		
	if should_emit:
		self.card_count_changed.emit(self)

func _on_pressed_dec_count() -> void:
	self.set_card_count(self._num_cards-1)
