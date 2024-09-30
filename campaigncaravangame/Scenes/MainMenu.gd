extends Control


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("pause"):
		if %HowToPlayOuterMarginContainer.visible == true:
			%HowToPlayBackButton.pressed.emit()
		if %OptionsOuterMarginContainer.visible == true:
			%OptionsBackButton.pressed.emit()


static func _dummy_player_ready(_player: Player) -> void:
	pass


func background_restore_hook(game_manager: GameManager):

	game_manager.restore_hook = background_restore_hook
	game_manager.auto_restart = true

	var human_replacement = game_manager.find_child("Players", false).get_child(0)
	human_replacement.set_script(BotPlayer)
	game_manager.starting_player = human_replacement  # Default starting player
	assert(human_replacement in game_manager.players)
	human_replacement.is_current_player = true
	human_replacement.reverse_caravans = true

	for player in game_manager.find_child("Players", false).get_children():
		assert(player is BotPlayer)
		player.min_delay = 1#0.02
		player.max_delay = 2#0.04

	# TODO Kevin: Handle this being async
	human_replacement.init(_dummy_player_ready.call)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	%"Play".grab_focus()

	background_restore_hook($TableTop)

	CaravanUtils.delay($TableTop.start, 0.5, $TableTop)

	if OS.get_name() == "Web":
		%Exit.hide()


func _on_play_pressed() -> void:

	# Step 1: Load and instantiate the scene
	var scene_resource: PackedScene = load("res://TableTop.tscn")
	var caravan_game: GameManager = scene_resource.instantiate()

	# Step 3: Optionally remove the current scene if you want to replace it
	var current_scene = self.get_tree().current_scene
	if current_scene:
		current_scene.queue_free()  # Remove the current scene from the tree
	self.queue_free()

	# Step 4: Set the modified scene as the new current scene
	
	self.get_tree().root.add_child(caravan_game)  # Add it to the tree
	self.get_tree().current_scene = caravan_game  # Make it the active scene


func _on_deck_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	#self.get_tree().change_scene_to_file("res://Scenes/OptionsMenu.tscn")
	
	%MainMenuMarginContainer.hide()
	
	if not %OptionsOuterMarginContainer.visible:
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/popup/ui_popup_messagewindow.wav"), 0, 0, randf_range(0.98, 1.05))
	
	%OptionsOuterMarginContainer.show()
	%OptionsBackButton.grab_focus()
	


func _on_exit_pressed() -> void:
	assert(OS.get_name() != "Web")
	# Give time for the button sound to play
	CaravanUtils.delay(self.get_tree().quit, 0.16, self)


func _on_custom_game_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/PlaySetup.tscn")


func _on_how_to_play_back_button_pressed() -> void:
	%HowToPlayOuterMarginContainer.hide()
	%OptionsOuterMarginContainer.hide()
	%MainMenuMarginContainer.show()
	# Probably not what the user want's to click again,
	#	but it would've been the last thing in focus.
	%HowToPlay.grab_focus()


func _on_options_back_button_pressed() -> void:
	%HowToPlayOuterMarginContainer.hide()
	%OptionsOuterMarginContainer.hide()
	%MainMenuMarginContainer.show()
	# Probably not what the user want's to click again,
	#	but it would've been the last thing in focus.
	%Options.grab_focus()


func _on_how_to_play_pressed() -> void:
	%MainMenuMarginContainer.hide()
	
	if not %HowToPlayOuterMarginContainer.visible:
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/popup/ui_popup_messagewindow.wav"), 0, 0, randf_range(0.98, 1.05))
	
	%HowToPlayOuterMarginContainer.show()
	%HowToPlayBackButton.grab_focus()


func _on_howtoplay_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
