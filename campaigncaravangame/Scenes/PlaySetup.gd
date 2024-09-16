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
	var scene_resource: PackedScene = preload("res://TableTop.tscn")
	var new_scene_instance: GameManager = scene_resource.instantiate()
	
	# Step 2: Modify the scene instance before adding it to the tree
	new_scene_instance.some_property = 42  # Modify a property, e.g., set a variable
	new_scene_instance.some_method()  # Call a method to prepare the scene
	
	# Step 3: Optionally remove the current scene if you want to replace it
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()  # Remove the current scene from the tree
	
	# Step 4: Set the modified scene as the new current scene
	get_tree().current_scene = new_scene_instance  # Make it the active scene
	get_tree().root.add_child(new_scene_instance)  # Add it to the tree
	
	#self.get_tree().change_scene_to_file("res://TableTop.tscn")
