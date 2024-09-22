extends PanelContainer


class_name GameRulesScene


signal gamerules_changed(game_rules: GameRules)
signal manage_decks_button_pressed(game_rules_scene: GameRulesScene)


@onready var use_custom_deck_button: Button = %CustomizeDeckButton
var custom_deck_optionbutton: OptionButton = null


func _ready() -> void:
	if OS.get_name() == "Web":
		%CustomizeDeckButton.visible = false
	else:
		self.set_custom_deck_options(SqlManager.query_custom_decks())


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
	
	game_rules.can_discard_caravans = %CanDiscardCaravansButton.is_pressed()

	if %DeckMinCardsLineEdit.text != "":
		game_rules.deck_min_size = int(%DeckMinCardsLineEdit.text)

	if %DeckMaxCardsLineEdit.text != "":
		game_rules.deck_max_size = int(%DeckMaxCardsLineEdit.text)
	game_rules.deck_shuffle = %ShuffleButton.is_pressed()
	game_rules.deck_require_unique_cards = %UniqueCardsButton.is_pressed()


	game_rules.deck_seed = 0
	if %DeckSeedLineEdit.text != "":
		game_rules.deck_seed = int(%DeckSeedLineEdit.text)
	
	if %CustomizeDeckButton.is_pressed():
		var selected_id: int = self.custom_deck_optionbutton.get_selected_id()
		if selected_id > 1:
			game_rules.custom_deck_name = self.custom_deck_optionbutton.get_item_text(self.custom_deck_optionbutton.get_item_index(selected_id))
	
	return game_rules


## Extends GameRule.check_errors(),
##	by also checking if custom deck is selected without actually selecting a deck.
func has_errors() -> bool:
	
	if self.to_game_rules().check_errors().size() > 0:
		return true
	
	if self.use_custom_deck_button.is_pressed():
		if self.custom_deck_optionbutton.get_selected_id() == 0:  # No custom deck selected
			return true
			
	return false


func from_game_rules(game_rules: GameRules) -> void:

	
	%MaxValueLineEdit.text = String.num_int64(game_rules.caravan_max_value)
	
	%MinValueLineEdit.text = String.num_int64(game_rules.caravan_min_value)
	%MaxCardsLineEdit.text = String.num_int64(game_rules.caravan_max_cards)

	%QueenChangeSuitButton.button_pressed = game_rules.queen_changes_suit
	# %QueenChangeSuitButton.pressed.emit()
	%QueenChangeSuitButton._update_checkbox_icon()
	%QueenChangeDirectionButton.button_pressed = game_rules.queen_changes_direction
	# %QueenChangeDirectionButton.pressed.emit()
	%QueenChangeDirectionButton._update_checkbox_icon()

	%FaceCardFirstRoundButton.button_pressed = game_rules.number_card_allow_faces_first_round
	# %FaceCardFirstRoundButton.pressed.emit()
	%FaceCardFirstRoundButton._update_checkbox_icon()
	%FaceMatchSuitButton.button_pressed = game_rules.number_card_require_face_match_suit
	# %FaceMatchSuitButton.pressed.emit()
	%FaceMatchSuitButton._update_checkbox_icon()
	
	%MaxFacesLineEdit.text = String.num_int64(game_rules.number_card_max_faces)

	%HandSizeLineEdit.text = String.num_int64(game_rules.hand_size)
	
	%CanDiscardCaravansButton.button_pressed = game_rules.can_discard_caravans
	# %CanDiscardCaravansButton.pressed.emit()
	%CanDiscardCaravansButton._update_checkbox_icon()

	%DeckMinCardsLineEdit.text = String.num_int64(game_rules.deck_min_size)
	%DeckMaxCardsLineEdit.text = String.num_int64(game_rules.deck_max_size)
	%ShuffleButton.button_pressed = game_rules.deck_shuffle
	# %ShuffleButton.pressed.emit()
	%ShuffleButton._update_checkbox_icon()
	%UniqueCardsButton.button_pressed = game_rules.deck_require_unique_cards
	# %UniqueCardsButton.pressed.emit()
	%UniqueCardsButton._update_checkbox_icon()


	%DeckSeedLineEdit.text = String.num_int64(game_rules.deck_seed)
	
	for idx in range(self.custom_deck_optionbutton.item_count):
		if self.custom_deck_optionbutton.get_item_text(idx) == game_rules.custom_deck_name:
			self.custom_deck_optionbutton.select(idx)
			break
	
	

## The signal call order is important here,
##	this must be called after the LineEdit has been sanitized.
##  Luckily the call order seems correct.
func _on_line_edit_text_changed(_new_text: String) -> void:
	self.gamerules_changed.emit(self.to_game_rules())

func _on_button_pressed() -> void:
	self.gamerules_changed.emit(self.to_game_rules())


func _on_customize_deck_button_pressed() -> void:

	if %CustomizeDeckButton.is_pressed():
		%SeededDeckOptionsHBoxContainer.hide()
		%CustomDeckOptionsHBoxContainer.show()
	else:
		%SeededDeckOptionsHBoxContainer.show()
		%CustomDeckOptionsHBoxContainer.hide()


func _on_custom_deck_item_selected(_index: int) -> void:
	self.gamerules_changed.emit(self.to_game_rules())


func _on_manage_decks_button_pressed() -> void:
	self.manage_decks_button_pressed.emit(self)


func set_custom_deck_options(custom_decks: Array[CustomDeckScene]) -> void:
	
	# Have we already added custom options?
	if %CustomDeckOptionHBoxContainer.get_child_count() > 2:
		# Pop back
		%CustomDeckOptionHBoxContainer.remove_child(%CustomDeckOptionHBoxContainer.get_child(%CustomDeckOptionHBoxContainer.get_child_count()-1))
		
	self.custom_deck_optionbutton = %BaseCustomDeckOptionButton.duplicate()
	
	for custom_deck in custom_decks:
		self.custom_deck_optionbutton.add_item(custom_deck.get_deck_name())
	
	%BaseCustomDeckOptionButton.visible = false
	self.custom_deck_optionbutton.visible = true
	%CustomDeckOptionHBoxContainer.add_child(self.custom_deck_optionbutton)
	
