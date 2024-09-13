extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"MarginContainer/VBoxContainer/Play".grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	#self.get_tree().change_scene_to_file("res://Scenes/PlaySetup.tscn")
	self.get_tree().change_scene_to_file("res://TableTop.tscn")


func _on_deck_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/OptionsMenu.tscn")


func _on_exit_pressed() -> void:
	self.get_tree().quit()
