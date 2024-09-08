extends Node2D


@export var players: Array[Player] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var you: Player = Player.new()
	#you.name = "TestPlayer"
	#$Hand.player = you
	#you.hand = $Hand
	#$Caravan1.player = you
	#$Caravan2.player = you
	#$Caravan3.player = you
	#self.players.append(you)
	for node in self.get_children():
		if node is Player:
			self.players.append(node)
