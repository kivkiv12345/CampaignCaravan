extends RichTextLabel

class_name CaravanValueCounter

@export var caravan: Caravan = null
@export var fix_rotation: bool = true  # Allow control over whether to correct rotation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.caravan.on_value_changed.connect(self._update_shown_value)
	self.text = String.num_int64(self.caravan.get_value())
	if self.fix_rotation:
		self.pivot_offset = Vector2i(self.size.x, self.size.y) / 2
		self.rotation = -self.get_global_transform_with_canvas().get_rotation()


func _update_shown_value(caravan: Caravan, old_value: int, new_value: int) -> void:
	self.text = String.num_int64(new_value)
