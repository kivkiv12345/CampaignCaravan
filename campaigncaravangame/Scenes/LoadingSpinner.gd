## Source: https://www.bytesnsprites.com/posts/2022/spinner-progress-bar-in-godot/

extends TextureProgressBar


func _ready() -> void:
	var tween = self.get_tree().create_tween().set_loops()
	tween.bind_node(self)
	tween.tween_property(self, "radial_initial_angle", 360.0, 1.5).as_relative()
