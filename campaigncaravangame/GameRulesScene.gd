extends PanelContainer


class_name GameRulesScene


signal gamerules_changed(game_rules: GameRules)


func to_game_rules() -> GameRules:
	var game_rules = GameRules.new()
	

	if %MaxValueLineEdit.text != "":
		game_rules.caravan_max_value = int(%MaxValueLineEdit.text)

	if %MinValueLineEdit.text != "":
		game_rules.caravan_min_value = int(%MinValueLineEdit.text)

	if %MaxCardsLineEdit.text != "":
		game_rules.caravan_max_cards = int(%MaxCardsLineEdit.text)

	game_rules.queen_changes_suit = %QueenChangeSuitButton.is_pressed()
	game_rules.queen_changes_direction = %QueenChangeDirectionButton.is_pressed()

	game_rules.number_card_allow_faces_first_round = %FaceCardFirstRoundButton.is_pressed()
	game_rules.number_card_require_face_match_suit = %FaceMatchSuitButton.is_pressed()

	if %MaxFacesLineEdit.text != "":
		game_rules.number_card_max_faces = int(%MaxFacesLineEdit.text)

	if %HandSizeLineEdit.text != "":
		game_rules.hand_size = int(%HandSizeLineEdit.text)

	if %DeckMinCardsLineEdit.text != "":
		game_rules.deck_min_size = int(%DeckMinCardsLineEdit.text)

	if %DeckMaxCardsLineEdit.text != "":
		game_rules.deck_max_size = int(%DeckMaxCardsLineEdit.text)
	game_rules.deck_shuffle = %ShuffleButton.is_pressed()
	game_rules.deck_require_unique_cards = %UniqueCardsButton.is_pressed()


	game_rules.deck_seed = 0
	if %DeckSeedLineEdit.text != "":
		game_rules.deck_seed = int(%DeckSeedLineEdit.text)
	
	
	return game_rules


func from_game_rules(game_rules: GameRules) -> void:

	
	%MaxValueLineEdit.text = String.num_int64(game_rules.caravan_max_value)
	
	%MinValueLineEdit.text = String.num_int64(game_rules.caravan_min_value)
	%MaxCardsLineEdit.text = String.num_int64(game_rules.caravan_max_cards)

	%QueenChangeSuitButton.button_pressed = game_rules.queen_changes_suit
	%QueenChangeSuitButton.pressed.emit()
	%QueenChangeDirectionButton.button_pressed = game_rules.queen_changes_direction
	%QueenChangeDirectionButton.pressed.emit()

	%FaceCardFirstRoundButton.button_pressed = game_rules.number_card_allow_faces_first_round
	%FaceCardFirstRoundButton.pressed.emit()
	%FaceMatchSuitButton.button_pressed = game_rules.number_card_require_face_match_suit
	%FaceMatchSuitButton.pressed.emit()
	#game_rules.number_card_max_faces = 0
	#if .text != "":
		#number_card_max_faces = int()

	%HandSizeLineEdit.text = String.num_int64(game_rules.hand_size)

	%DeckMinCardsLineEdit.text = String.num_int64(game_rules.deck_min_size)
	%DeckMaxCardsLineEdit.text = String.num_int64(game_rules.deck_max_size)
	%ShuffleButton.button_pressed = game_rules.deck_shuffle
	%ShuffleButton.pressed.emit()
	%UniqueCardsButton.button_pressed = game_rules.deck_require_unique_cards
	%UniqueCardsButton.pressed.emit()


	%DeckSeedLineEdit.text = String.num_int64(game_rules.deck_seed)


## The signal call order is important here,
##	this must be called after the LineEdit has been sanitized.
##  Luckily the call order seems correct.
func _on_line_edit_text_changed(_new_text: String) -> void:
	self.gamerules_changed.emit(self.to_game_rules())

func _on_button_pressed() -> void:
	self.gamerules_changed.emit(self.to_game_rules())


func _on_customize_deck_button_pressed() -> void:
	pass # Replace with function body.
