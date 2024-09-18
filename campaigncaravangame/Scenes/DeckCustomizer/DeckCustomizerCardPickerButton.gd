extends DeckCustomizerCardButton


class_name DeckCustomizerCardPickerButton


signal card_picker_clicked(button: DeckCustomizerCardPickerButton)


func _on_pressed() -> void:
	self.card_picker_clicked.emit(self)
