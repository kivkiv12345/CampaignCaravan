extends Node2D

class_name GameManager

#signal on_turn_changed


@export var players: Array[Player] = []
@export var current_player: Player = null

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
	for node in $Players.get_children():
		if node is Player and node not in self.players:
			self.players.append(node)
	if self.current_player == null:
		self.current_player = self.players[0]  # Default starting player

func advance_turn(old_player: Player) -> void:
	var next_player_index = self.players.find(old_player) + 1
	if next_player_index >= self.players.size():
		next_player_index = 0
	
	var next_player: Player = self.players[next_player_index]
	self.current_player = next_player
	
	# TODO Kevin: Starting the next turn from a signal,
	#	will happen before the last (AI) turn will properly finish.
	#	This probably means a game between AIs will play out in a recursive manner on the stack.
	next_player.start_turn()
