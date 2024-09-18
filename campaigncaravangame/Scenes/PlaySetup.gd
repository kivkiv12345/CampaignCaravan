extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_viewport().gui_get_focus_owner() == null:
		self.find_child("BackButton").grab_focus()


func _on_back_button_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


## With late init help from: https://chatgpt.com
func _on_play_button_pressed() -> void:

	# Step 1: Load and instantiate the scene
	var scene_resource: PackedScene = load("res://TableTop.tscn")
	var caravan_game: GameManager = scene_resource.instantiate()

	# Step 2: Modify the scene instance before adding it to the tree
	var players: Control = caravan_game.get_node("Players")

	for player in players.get_children():
		assert(player is Player)

		if player.is_enemy_player:
			player.game_rules = %EnemySettings.to_game_rules()
		else:
			player.game_rules = %OurSettings.to_game_rules()

		if player.game_rules.check_errors().size() != 0:
			return  # We cannot allow the game to start with these rules

	# Step 3: Optionally remove the current scene if you want to replace it
	var current_scene = self.get_tree().current_scene
	if current_scene:
		current_scene.queue_free()  # Remove the current scene from the tree
	self.queue_free()
	
	# Step 4: Set the modified scene as the new current scene
	self.get_tree().root.add_child(caravan_game)  # Add it to the tree
	self.get_tree().current_scene = caravan_game  # Make it the active scene


## Disable the play button, if an invalid configuration is detected.
func _on_gamerules_changed(_game_rules: GameRules) -> void:
	
	var play_button: Button = %PlayButton

	if %EnemySettings.has_errors():
		play_button.disabled = true
		return

	if %OurSettings.has_errors():
		play_button.disabled = true
		return

	play_button.disabled = false


func _on_manage_decks_button_pressed(_game_rules_scene: GameRulesScene) -> void:
	
	%DeckCustomizerVBoxContainer.show()
	%PlayerSettingsVBoxContainer.hide()


func _on_deck_customizer_save() -> void:
	
	%DeckCustomizerVBoxContainer.hide()
	%PlayerSettingsVBoxContainer.show()


func _on_deck_customizer_back() -> void:
	
	%DeckCustomizerVBoxContainer.hide()
	%PlayerSettingsVBoxContainer.show()
