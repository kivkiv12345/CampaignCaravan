extends PanelContainer

class_name GameOverModal


@export var delay: float = 2
@export var game_manager: GameManager = null

var _end_game_player: Player = null


func _input(event: InputEvent) -> void:
	
	# TODO Kevin: This is not really the ideal property to check on.
	#	But it works for our use case of running the game in the background of the main menu.
	if self.game_manager.auto_restart:
		return
	
	if event.is_action("pause"):
		if self._end_game_player == null:
			$VBoxContainer/MarginContainer/Label.text = "Game is still in progress"
		self.make_visible_and_focus()
		if get_viewport().gui_get_focus_owner() == null:
			$VBoxContainer/ContinueMargin/Continue.grab_focus()


func make_visible_and_focus() -> void:

	if OS.get_name() == "Web":
		$VBoxContainer/MarginContainer4/QuitButton.hide()

	if not self.visible:
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/popup/ui_popup_messagewindow.wav"), 0, 0, randf_range(0.98, 1.05))

	self.visible = true
	if get_viewport().gui_get_focus_owner() == null:
		$VBoxContainer/MarginContainer2/RestartButton.grab_focus()


func _on_restart_button_pressed() -> void:
	assert(self.game_manager)
	self.game_manager.restart()


func _on_main_menu_button_pressed() -> void:
	assert(self.game_manager)
	# Step 1: Load and instantiate the scene
	var scene_resource: PackedScene = load("res://Scenes/MainMenu.tscn")
	var main_menu = scene_resource.instantiate()

	#self.get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	self.get_tree().get_root().add_child(main_menu)  # Add it to the tree
	self.get_tree().current_scene = main_menu  # Make it the active scene

	self.get_tree().get_root().remove_child(self.game_manager)
	#self.game_manager.queue_free()  # Remove the current scene from the tree


func _on_quit_button_pressed() -> void:
	# Give time for the button sound to play
	CaravanUtils.delay(self.get_tree().quit, 0.16, self)


func _on_player_lost(player: Player) -> void:

	if self.game_manager.auto_restart:
		return

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

	if self.game_manager.auto_restart:
		return

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
