extends RichTextLabel



func _on_deck_deck_size_changed(deck: DeckScene) -> void:
	self.text = "[center]%d cards[/center]" % deck.get_deck_size()
