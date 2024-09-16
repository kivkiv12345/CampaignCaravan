extends Button

@export var from: GameRulesScene
@export var to: GameRulesScene

func _ready() -> void:
	assert(self.from != null)
	assert(self.to != null)
	self.pressed.connect(self._on_copy_pressed)
	

func _on_copy_pressed() -> void:
	self.to.from_game_rules(self.from.to_game_rules())
