extends DeckCustomizerCardButton

class_name DeckCardWithCounter

var _num_cards: int = 1


func _ready() -> void:
	super()
	# Make sure visual matches with value
	self.set_card_count(self._num_cards)


func get_card_count() -> int:
	return self._num_cards


func set_card_count(count: int) -> void:
	
	self._num_cards = count

	if self._num_cards <= 0:
		self.queue_free()

	%CardCountRichTextLabel.text = "[center]"

	if String.num_int64(self._num_cards).length() <= 3:
		%CardCountRichTextLabel.text += "x"

	%CardCountRichTextLabel.text += String.num_int64(self._num_cards)
	%CardCountRichTextLabel.text += "[/center]"

func _on_pressed_dec_count() -> void:
	self.set_card_count(self._num_cards-1)
