extends Node2D

class_name GameManager

#signal on_turn_changed


@export var players: Array[Player] = []
@export var starting_player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	for player in players:
		assert(player is Player)
		player.init()
		if player not in self.players:
			self.players.append(player)
	if self.starting_player == null:
		self.starting_player = self.players[0]  # Default starting player
	assert(self.starting_player in self.players)

## Check if the provided caravan is sold.
## This entails checking if the caravan is:
##	over/under-burdened, underbidding or tied with the opponent
func caravan_is_sold(caravan: Caravan) -> bool:

	if caravan.get_value() not in range(caravan.player.game_rules.caravan_min_value, caravan.player.game_rules.caravan_max_value+1):
		return false

	for player in players:
		assert(player is Player)
		
		if player == caravan.player:
			continue  # No need to check if we are outbidding our own caravan
			
		# TODO Kevin: Are we comfortable using the index to check for tied caravans.
		var opponent_caravan: Caravan = player.caravans[caravan.player.caravans.find(caravan)]
		if opponent_caravan.get_value() > caravan.player.game_rules.caravan_max_value:
			continue  # The opponent caravan is overburdened (Using our rules)
		
		# TODO Kevin: How do we indicate that a Caravan is tied (for the UI)?
		if opponent_caravan.get_value() >= caravan.get_value():
			return false  # We are either outbid or tied with this opponent caravan.
		
	return true


## Source: https://chatgpt.com
static func _get_unique_max_key(dict: Dictionary) -> Player:
	var max_value = 0
	var max_key = null
	var max_count = 0

	# Iterate through the dictionary to find the highest value and track its occurrences.
	for key in dict.keys():
		var value = dict[key]

		if value > max_value:
			max_value = value
			max_key = key
			max_count = 1  # Reset the count since we found a new max
		elif value == max_value:
			max_count += 1

	# If there's only one key with the max value, return it; otherwise, return null
	if max_count == 1:
		return max_key
	else:
		return null


func check_for_winner() -> Player:
	
	var players: Array[Player] = self.players
	assert(players.size() != 0)
	var num_caravans: int = players[0].game_rules.caravan_count
	
	# Exactly 1 caravan for every "pair" must be sold for someone to win.
	var index_sold: Array[bool] = []
	for i in range(num_caravans):
		index_sold.append(false)
		
	var num_caravans_won = {}

	# TODO Kevin: This loop is not super efficient,
	#	and could be improved by using a better API than caravan_is_sold()
	for player in players:
		
		# We don't yet know how to check for a winner, if there is an unequal number of caravans.
		assert(player is Player)
		assert(player.caravans.size() == num_caravans)
		assert(player.game_rules.caravan_count == num_caravans)
		
		num_caravans_won[player] = 0
		
		var caravan_idx: int = -1
		for caravan in player.caravans:
			caravan_idx += 1
			assert(caravan is Caravan)
			if caravan_is_sold(caravan):
				num_caravans_won[player] += 1
				index_sold[caravan_idx] = true  # A caravan on this index/pair has been sold
				
	var is_true = func (index: bool) -> bool:
		return index == true
				
	if not index_sold.all(is_true):
		return null  # There is still at least 1 caravan that has yet to be sold.
		
	var winning_player: Player = _get_unique_max_key(num_caravans_won)
	
	if winning_player == null:
		# 2 or more players have sold an equal number of caravans.
		#	This should not be possible with the default configuration of 2 players and 3 caravans.
		#	But maybe, in the future, we allow some situation where this can occur. 
		return null  
	
	return winning_player



func advance_turn(old_player: Player) -> void:
	
	var winning_player: Player = self.check_for_winner()
	
	if winning_player:
		for player in self.players:
			if player != winning_player:
				player.lose()
		print("Player %s has won!" % winning_player.name)
		return
	
	old_player.is_current_player = false
	var next_player_index = self.players.find(old_player) + 1
	if next_player_index >= self.players.size():
		next_player_index = 0
	
	var next_player: Player = self.players[next_player_index]
	next_player.is_current_player = true
	
	var num_current_players = 0
	for player in self.players:
		if player.is_current_player:
			num_current_players += 1
	assert(num_current_players == 1)
	
	# TODO Kevin: Starting the next turn from a signal,
	#	will happen before the last (AI) turn will properly finish.
	#	This probably means a game between AIs will play out in a recursive manner on the stack.
	next_player.start_turn()
