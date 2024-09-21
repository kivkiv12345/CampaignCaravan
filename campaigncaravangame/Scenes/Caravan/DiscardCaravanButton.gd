extends PanelContainer


class_name DiscardCaravanButton


@export var caravan: Caravan = null


func update_visibility() -> void:
	
	if get_viewport().gui_get_drag_data() == null:
		self.visible = false
		return

	if not self.caravan.player.is_current_player:
		self.visible = false
		return
	
	if self.caravan.player.is_enemy_player:
		self.visible = false
		return  # Almost an assert here, but I don't feel like it.

	if not self.caravan.can_discard_caravan():
		self.visible = false
		return

	self.visible = true

func _on_player_turn_started(player: Player) -> void:
	assert(self.caravan.player.is_current_player)
	self.update_visibility()
	

func _on_player_turn_ended(_player: Player) -> void:
	self.update_visibility()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(self.caravan)
	assert(self.caravan.player)
	
	self.hide()
	
	self.caravan.player.turn_ended.connect(self._on_player_turn_ended)
	self.caravan.player.turn_started.connect(self._on_player_turn_started)


func _on_discard_caravan_button_pressed() -> void:
	self.caravan.try_discard_caravan()
