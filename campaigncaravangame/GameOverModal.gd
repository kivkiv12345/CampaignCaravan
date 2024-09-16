extends PanelContainer

class_name GameOverModal


@export var delay: float = 2
@export var game_manager: GameManager = null

var _end_game_player: Player = null


func _input(event: InputEvent) -> void:
	if event.is_action("pause"):
		if self._end_game_player == null:
			$VBoxContainer/MarginContainer/Label.text = "Game is still in progress"
		self.make_visible_and_focus()
		if get_viewport().gui_get_focus_owner() == null:
			$VBoxContainer/ContinueMargin/Continue.grab_focus()


func make_visible_and_focus() -> void:
	
	if not self.visible:
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/popup/ui_popup_messagewindow.wav"), 0, 0, randf_range(0.98, 1.05))
	
	self.visible = true
	if get_viewport().gui_get_focus_owner() == null:
		$VBoxContainer/MarginContainer2/RestartButton.grab_focus()


func _on_restart_button_pressed() -> void:
	assert(self.game_manager)
	self.game_manager.queue_free()  # Remove the current scene from the tree

	# TODO Kevin: Account for game settings.
	#	Maybe store a game of fresly started games, we can restore?
	
	# Step 1: Load and instantiate the scene
	var scene_resource: PackedScene = load("res://TableTop.tscn")
	var caravan_game: GameManager = scene_resource.instantiate()

	# Step 3: Optionally remove the current scene if you want to replace it
	var current_scene = self.get_tree().current_scene
	if current_scene:
		current_scene.queue_free()  # Remove the current scene from the tree
	self.queue_free()

	# Step 4: Set the modified scene as the new current scene
	self.get_tree().current_scene = caravan_game  # Make it the active scene
	self.get_tree().root.add_child(caravan_game)  # Add it to the tree


func _on_main_menu_button_pressed() -> void:
	assert(self.game_manager)
	self.game_manager.queue_free()  # Remove the current scene from the tree
	self.get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_quit_button_pressed() -> void:
	# Give time for the button sound to play
	CaravanUtils.delay(self.get_tree().quit, 0.16, self)


func _on_player_lost(player: Player) -> void:
	
	if player.is_enemy_player:
		return  # Not our human player
		
	self._end_game_player = player

	var num_caps_lost: int = randi_range(100, 400)

	$VBoxContainer/MarginContainer/Label.text = "Too bad, you lost %d caps" % num_caps_lost
	
	$VBoxContainer/ContinueMargin.visible = false
	
	if self.delay != 0:
		# Add a slight delay, for added effect.
		CaravanUtils.delay(self.make_visible_and_focus, self.delay, self)
	else:
		self.make_visible_and_focus()


func _on_player_won(player: Player) -> void:
	
	if player.is_enemy_player:
		return  # Not our human player
		
	self._end_game_player = player
		
	var num_caps_won: int = randi_range(100, 400)

	$VBoxContainer/MarginContainer/Label.text = "Congratulations, you won %d caps!" % num_caps_won
	
	$VBoxContainer/ContinueMargin.visible = false
	
	if self.delay != 0:
		# Add a slight delay, for added effect.
		CaravanUtils.delay(self.make_visible_and_focus, self.delay, self)
	else:
		self.make_visible_and_focus()


func _on_continue_pressed() -> void:
	self.visible = false
