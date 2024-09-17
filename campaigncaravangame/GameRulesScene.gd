extends PanelContainer


class_name GameRulesScene


signal gamerules_changed(game_rules: GameRules)


func to_game_rules() -> GameRules:
	var game_rules = GameRules.new()
	

	if $HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MaxValueHBoxContainer/MaxValueLineEdit.text != "":
		game_rules.caravan_max_value = int($HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MaxValueHBoxContainer/MaxValueLineEdit.text)

	if $HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MinValueHBoxContainer/MinValueLineEdit.text != "":
		game_rules.caravan_min_value = int($HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MinValueHBoxContainer/MinValueLineEdit.text)

	if $HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MaxCardsHBoxContainer/MaxCardsLineEdit.text != "":
		game_rules.caravan_max_cards = int($HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MaxCardsHBoxContainer/MaxCardsLineEdit.text)

	game_rules.queen_changes_suit = $HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/QueenChangeSuitButton.is_pressed()
	game_rules.queen_changes_direction = $HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/QueenChangeDirectionButton.is_pressed()

	game_rules.number_card_allow_faces_first_round = $HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/FaceCardFirstRoundButton.is_pressed()
	game_rules.number_card_require_face_match_suit = $HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/FaceMatchSuitButton.is_pressed()
	#game_rules.number_card_max_faces = 0
	#if .text != "":
		#number_card_max_faces = int()

	if $HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HandSizeHBoxContainer/HandSizeLineEdit.text != "":
		game_rules.hand_size = int($HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HandSizeHBoxContainer/HandSizeLineEdit.text)

	if $HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckMinCardsHBoxContainer/MinCardsLineEdit.text != "":
		game_rules.deck_min_size = int($HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckMinCardsHBoxContainer/MinCardsLineEdit.text)

	if $HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckMaxCardsHBoxContainer/MaxCardsLineEdit.text != "":
		game_rules.deck_max_size = int($HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckMaxCardsHBoxContainer/MaxCardsLineEdit.text)
	game_rules.deck_shuffle = $HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/ShuffleHBoxContainer/ShuffleButton.is_pressed()
	game_rules.deck_require_unique_cards = $HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/UniqueCardsHBoxContainer2/UniqueCardsButton.is_pressed()


	game_rules.deck_seed = 0
	if $HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckSeedCardsHBoxContainer2/DeckSeedLineEdit.text != "":
		game_rules.deck_seed = int($HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckSeedCardsHBoxContainer2/DeckSeedLineEdit.text)
	
	
	return game_rules


func from_game_rules(game_rules: GameRules) -> void:

	
	$HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MaxValueHBoxContainer/MaxValueLineEdit.text = String.num_int64(game_rules.caravan_max_value)
	
	$HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MinValueHBoxContainer/MinValueLineEdit.text = String.num_int64(game_rules.caravan_min_value)
	$HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MaxCardsHBoxContainer/MaxCardsLineEdit.text = String.num_int64(game_rules.caravan_max_cards)

	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/QueenChangeSuitButton.button_pressed = game_rules.queen_changes_suit
	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/QueenChangeSuitButton.pressed.emit()
	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/QueenChangeDirectionButton.button_pressed = game_rules.queen_changes_direction
	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/QueenChangeDirectionButton.pressed.emit()

	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/FaceCardFirstRoundButton.button_pressed = game_rules.number_card_allow_faces_first_round
	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/FaceCardFirstRoundButton.pressed.emit()
	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/FaceMatchSuitButton.button_pressed = game_rules.number_card_require_face_match_suit
	$HBoxContainer/CardVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/FaceMatchSuitButton.pressed.emit()
	#game_rules.number_card_max_faces = 0
	#if .text != "":
		#number_card_max_faces = int()

	$HBoxContainer/CaravanVBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/HandSizeHBoxContainer/HandSizeLineEdit.text = String.num_int64(game_rules.hand_size)

	$HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckMinCardsHBoxContainer/MinCardsLineEdit.text = String.num_int64(game_rules.deck_min_size)
	$HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckMaxCardsHBoxContainer/MaxCardsLineEdit.text = String.num_int64(game_rules.deck_max_size)
	$HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/ShuffleHBoxContainer/ShuffleButton.button_pressed = game_rules.deck_shuffle
	$HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/ShuffleHBoxContainer/ShuffleButton.pressed.emit()
	$HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/UniqueCardsHBoxContainer2/UniqueCardsButton.button_pressed = game_rules.deck_require_unique_cards
	$HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/UniqueCardsHBoxContainer2/UniqueCardsButton.pressed.emit()


	$HBoxContainer/DeckVBoxContainer3/MarginContainer/HBoxContainer/VBoxContainer/DeckSeedCardsHBoxContainer2/DeckSeedLineEdit.text = String.num_int64(game_rules.deck_seed)


## The signal call order is important here,
##	this must be called after the LineEdit has been sanitized.
##  Luckily the call order seems correct.
func _on_line_edit_text_changed(_new_text: String) -> void:
	self.gamerules_changed.emit(self.to_game_rules())

func _on_button_pressed() -> void:
	self.gamerules_changed.emit(self.to_game_rules())
