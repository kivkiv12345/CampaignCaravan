extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_viewport().gui_get_focus_owner() == null:
			self.find_child("BackButton").grab_focus()


func _on_back_button_pressed() -> void:
	self.get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_play_button_pressed() -> void:
	self.get_tree().change_scene_to_file("res://TableTop.tscn")
