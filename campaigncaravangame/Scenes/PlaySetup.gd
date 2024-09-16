extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_play_button_pressed() -> void:
	self.get_tree().change_scene_to_file("res://TableTop.tscn")
