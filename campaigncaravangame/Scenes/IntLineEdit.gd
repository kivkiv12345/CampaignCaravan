extends LineEdit


## A bit of help from: https://chatgpt.com
func _on_text_changed(new_text: String) -> void:
	# Store the current caret position
	var caret_pos = self.caret_column
	
	# Filter the input to allow only valid integers
	var valid_text = ""
	for char in new_text:
		if char.is_valid_int():
			valid_text += char
	
	# Update the text
	self.text = valid_text
	
	# If the caret position is beyond the new text length, adjust it
	if caret_pos > valid_text.length():
		caret_pos = valid_text.length()

	# Restore the caret position
	self.caret_column = caret_pos
