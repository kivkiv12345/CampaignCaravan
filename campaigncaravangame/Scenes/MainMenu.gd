extends Control


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
		player.min_delay = 1
		player.max_delay = 2

	human_replacement.init()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	$"MarginContainer/VBoxContainer/Play".grab_focus()

	background_restore_hook($TableTop)

	CaravanUtils.delay($TableTop.start, 0.5, $TableTop)

	if OS.get_name() == "Web":
		$MarginContainer/VBoxContainer/Exit.hide()


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
	self.get_tree().change_scene_to_file("res://Scenes/OptionsMenu.tscn")


func _on_exit_pressed() -> void:
	assert(OS.get_name() != "Web")
	# Give time for the button sound to play
	CaravanUtils.delay(self.get_tree().quit, 0.16, self)


func _on_custom_game_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/PlaySetup.tscn")
