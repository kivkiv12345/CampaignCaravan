extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"MarginContainer/VBoxContainer/Play".grab_focus()


func _on_play_pressed() -> void:
	self.get_tree().change_scene_to_file("res://TableTop.tscn")


func _on_deck_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/OptionsMenu.tscn")


func _on_exit_pressed() -> void:
	# Give time for the button sound to play
	CaravanUtils.delay(self.get_tree().quit, 0.16, self)


func _on_custom_game_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/PlaySetup.tscn")
