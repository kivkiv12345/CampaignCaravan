extends RichTextLabel

class_name CaravanValueCounter

@export var caravan: Caravan = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.caravan.on_value_changed.connect(self._update_shown_value)
	self.text = String.num_int64(self.caravan.get_value())


func _update_shown_value(caravan: Caravan, old_value: int, new_value: int) -> void:
	self.text = String.num_int64(new_value)
