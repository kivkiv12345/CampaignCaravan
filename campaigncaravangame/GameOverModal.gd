extends PanelContainer

class_name GameOverModal


@export var delay: float = 2

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
	# TODO Kevin: Account for game settings.
	#	Maybe store a game of fresly started games, we can restore?
	self.get_tree().change_scene_to_file("res://TableTop.tscn")


func _on_main_menu_button_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_quit_button_pressed() -> void:
	self.get_tree().quit()


func _delay_appearance() -> void:

	var timer: Timer = Timer.new()
	timer.wait_time = self.delay  # Add a slight delay, for added effect.
	timer.one_shot = true
	timer.connect("timeout", self.make_visible_and_focus, ConnectFlags.CONNECT_ONE_SHOT)  # ONE_SHOT automatically cleans up
	self.add_child(timer)  # Add the timer to the scene tree
	timer.start()


func _on_player_lost(player: Player) -> void:
	
	if player.is_enemy_player:
		return  # Not our human player
		
	self._end_game_player = player

	var num_caps_lost: int = randi_range(100, 400)

	$VBoxContainer/MarginContainer/Label.text = "Too bad, you lost %d caps" % num_caps_lost
	
	$VBoxContainer/ContinueMargin.visible = false
	
	if self.delay != 0:
		self._delay_appearance()
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
		self._delay_appearance()
	else:
		self.make_visible_and_focus()


func _on_continue_pressed() -> void:
	self.visible = false
