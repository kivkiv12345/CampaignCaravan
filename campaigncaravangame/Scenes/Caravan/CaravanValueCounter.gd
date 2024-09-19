extends PanelContainer

class_name CaravanValueCounter

@export var caravan: Caravan = null
@export var fix_rotation: bool = true  # Allow control over whether to correct rotation
@onready var default_color: Color = %CaravanValueCounterText.get_theme_color("default_color")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if self.caravan == null and self.get_parent() is Caravan:
		self.caravan = self.get_parent()
	
	self.caravan.on_value_changed.connect(self._update_shown_value)
	self.caravan.new_sold_status.connect(self._update_sold_status)
	self._update_shown_value(self.caravan, self.caravan.get_value(), self.caravan.get_value())
	if self.fix_rotation:
		self.pivot_offset = Vector2(self.size.x, self.size.y) / 2.0
		self.rotation = -self.get_global_transform_with_canvas().get_rotation()


func _update_sold_status(_caravan: Caravan, sold_status: Caravan.SoldStatus) -> void:
	
	const SoldStatus = Caravan.SoldStatus
	
	match sold_status:
		SoldStatus.OVERBURDENED:
			%CaravanValueCounterText.add_theme_color_override("default_color", Color.RED)
		SoldStatus.TIED:
			%CaravanValueCounterText.add_theme_color_override("default_color", Color.DEEP_SKY_BLUE)
		SoldStatus.SOLD:
			%CaravanValueCounterText.add_theme_color_override("default_color", Color.GREEN)
		_:  # Default
			%CaravanValueCounterText.add_theme_color_override("default_color", self.default_color)


func _update_shown_value(_caravan: Caravan, _old_value: int, new_value: int) -> void:
		
	self._update_sold_status(_caravan, _caravan.player.game_manager.get_caravan_sold_status(_caravan))

	%CaravanValueCounterText.text = "[center]"
	%CaravanValueCounterText.text += String.num_int64(new_value)
	%CaravanValueCounterText.text += "[/center]"


# TODO Kevin: Make like a _on_pending_value_change() signal handler,
#	that shows an arrow to the new value. Would also need an _on_abort_pending_value_change()
