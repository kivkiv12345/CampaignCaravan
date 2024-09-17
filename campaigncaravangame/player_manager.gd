extends Control

class_name GameManager

#signal on_turn_changed


@export var players: Array[Player] = []
@export var starting_player: Player = null
@export var auto_restart: bool = false
@export var auto_restart_delay: float = 3

var game_over_man: bool = false
var restore_hook: Callable

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
	self.starting_player.is_current_player = true

const SoldStatus = Caravan.SoldStatus

## Notify opposing caravans that they may now be sold,
## due to a possible change to the value of the provided caravan.
func notify_opponent_caravans(caravan: Caravan) -> void:
	for player in self.players:
		assert(player is Player)

		if player == caravan.player:
			continue  # No need to notify ourselves

		# TODO Kevin: Are we comfortable using the index to check for tied caravans.
		var opponent_caravan: Caravan = player.caravans[caravan.player.caravans.find(caravan)]
		if opponent_caravan.get_value() > caravan.player.game_rules.caravan_max_value:
			continue  # The opponent caravan is overburdened (Using our rules)

		if opponent_caravan.get_value() in range(opponent_caravan.player.game_rules.caravan_min_value, opponent_caravan.player.game_rules.caravan_max_value+1):
			opponent_caravan.update_sold_status(SoldStatus.SOLD)

## Check if the provided caravan is sold.
## This entails checking if the caravan is:
##	over/under-burdened, underbidding or tied with the opponent
## It might initally seem that this method should exist on the Caravn class,
##	but the Caravan is only loosly coupled to the larger game state.
##	So it has no concept about opponent caravans.
##	Which is needed to determine if a caravan has been outbid, or is tied.
func get_caravan_sold_status(caravan: Caravan) -> SoldStatus:

	if caravan.get_value() < caravan.player.game_rules.caravan_min_value:
		self.notify_opponent_caravans(caravan)
		return SoldStatus.UNDERBURDENED
	elif caravan.get_value() > caravan.player.game_rules.caravan_max_value:
		self.notify_opponent_caravans(caravan)
		return SoldStatus.OVERBURDENED

	for player in self.players:
		assert(player is Player)

		if player == caravan.player:
			continue  # No need to check if we are outbidding our own caravan

		# TODO Kevin: Are we comfortable using the index to check for tied caravans.
		var opponent_caravan: Caravan = player.caravans[caravan.player.caravans.find(caravan)]
		if opponent_caravan.get_value() > caravan.player.game_rules.caravan_max_value:
			continue  # The opponent caravan is overburdened (Using our rules)

		if opponent_caravan.get_value() > caravan.get_value():
			# Opponent caravan must be sold, because it is outbidding us, without being overburdened
			assert(opponent_caravan.get_value() in range(opponent_caravan.player.game_rules.caravan_min_value, opponent_caravan.player.game_rules.caravan_max_value+1))
			# TODO Kevin: Maybe this is a bit spaghetti,
			#	but we need to tell the other caravan, that it is outbid now.
			opponent_caravan.update_sold_status(SoldStatus.SOLD)
			return SoldStatus.OUTBID
		elif opponent_caravan.get_value() == caravan.get_value():
			# TODO Kevin: This is just as spaghetti as the outbid situation.
			opponent_caravan.update_sold_status(SoldStatus.TIED)
			return SoldStatus.TIED
		elif caravan.get_value() > opponent_caravan.get_value():
			# Tell the opponent caravan that we just outbid it (Yes; this is also spaghetti)
			opponent_caravan.update_sold_status(SoldStatus.OUTBID)

	# Success!
	return SoldStatus.SOLD


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

	var _players: Array[Player] = self.players
	assert(_players.size() != 0)
	var num_caravans: int = _players[0].game_rules.caravan_count
	
	# Check if all but 1 player has lost
	var not_lost_player: Player = null
	var num_active_players: int = 0
	for player in _players:
		if not player.has_lost:
			num_active_players += 1
			not_lost_player = player
			
	assert(num_active_players != 0)
	if num_active_players == 1:
		return not_lost_player  # This is the last remaining player, so they must have won
	
	# Exactly 1 caravan for every "pair" must be sold for someone to win.
	var index_sold: Array[bool] = []
	for i in range(num_caravans):
		index_sold.append(false)
		
	var num_caravans_won = {}

	# TODO Kevin: This loop is not super efficient,
	#	and could be improved by using a better API than caravan_is_sold()
	for player in _players:
		
		# We don't yet know how to check for a winner, if there is an unequal number of caravans.
		assert(player is Player)
		assert(player.caravans.size() == num_caravans, ("player.caravans.size() %d, num_caravans %d" % [player.caravans.size(), num_caravans]))
		assert(player.game_rules.caravan_count == num_caravans)
		
		num_caravans_won[player] = 0
		
		var caravan_idx: int = -1
		for caravan in player.caravans:
			caravan_idx += 1
			assert(caravan is Caravan)
			if get_caravan_sold_status(caravan) == SoldStatus.SOLD:
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

static func _random_caps_up_sound():
	# TODO Kevin: Now we just need to have the UI show: "you picked up 105 caps"
	const caps_sounds = [
		preload("res://FalloutNVUISounds/items/bottlecaps/up/ui_items_bottlecaps_up_01.wav"),
		preload("res://FalloutNVUISounds/items/bottlecaps/up/ui_items_bottlecaps_up_02.wav"),
		preload("res://FalloutNVUISounds/items/bottlecaps/up/ui_items_bottlecaps_up_03.wav"),
		preload("res://FalloutNVUISounds/items/bottlecaps/up/ui_items_bottlecaps_up_04.wav"),
	]
	var rand_index:int = randi() % caps_sounds.size()
	SoundManager.playback.play_stream(caps_sounds[rand_index], 0, 0, randf_range(0.98, 1.05))

static func _random_caps_down_sound():
	const caps_sounds = [
		preload("res://FalloutNVUISounds/items/bottlecaps/down/ui_items_bottlecaps_down_01.wav"),
		preload("res://FalloutNVUISounds/items/bottlecaps/down/ui_items_bottlecaps_down_02.wav"),
	]
	var rand_index:int = randi() % caps_sounds.size()
	SoundManager.playback.play_stream(caps_sounds[rand_index], 0, 0, randf_range(0.98, 1.05))

func celebrate_winner(winning_player: Player):
	
	if self.game_over_man:  # We have already celebrated the winner
		return
	self.game_over_man = true
	
	for player in self.players:
		if player != winning_player:
			player.lose()
	
	if winning_player.is_enemy_player:  # We lost
		_random_caps_down_sound()
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/reputation/ui_rep_bad.wav"), 0, 0, randf_range(0.98, 1.05))
	else:  # We won, yay!
		_random_caps_up_sound()
		SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/reputation/ui_rep_good.wav"), 0, 0, randf_range(0.98, 1.05))

		if not self.auto_restart:
			if randi_range(0, 1) == 1:  # 50% chance of playing the level up sound
				CaravanUtils.delay(_level_up_sound, 1.8, self)

		# TODO Kevin: Could be pretty fun with a random change of level up sound here
		#SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/popup/ui_popup_experienceup.wav"), 0, 0, randf_range(0.98, 1.05))
	print("Player %s has won!" % winning_player.name)
	winning_player.win()


static func _level_up_sound() -> void:
	SoundManager.playback.play_stream(preload("res://FalloutNVUISounds/ui_leveluptext.wav"), 0, 0, randf_range(0.98, 1.05))


func restart() -> void:

	# TODO Kevin: Account for game settings.
	#	Maybe store a game of fresly started games, we can restore?
	
	# Step 1: Load and instantiate the scene
	var scene_resource: PackedScene = load("res://TableTop.tscn")
	var caravan_game: GameManager = scene_resource.instantiate()

	if self.restore_hook:
		self.restore_hook.call(caravan_game)
		
	var self_index: int = self.get_index()

	# Step 4: Set the modified scene as the new current scene
	self.get_tree().get_root().add_child(caravan_game)  # Add it to the tree
	self.get_tree().current_scene = caravan_game  # Make it the active scene
	self.queue_free()
	#self.get_tree().get_root().remove_child(self)
	self.get_tree().get_root().move_child(caravan_game, self_index)
	
	CaravanUtils.delay(caravan_game.start, 1, caravan_game)


func start() -> void:

	# No need to advance turn, we are waiting forthe player.
	# TODO Kevin: This is probably a bit spaghetti
	for player in self.players:
		if player is HumanPlayer:
			assert(player.is_current_player)
			return

	self.advance_turn(self.starting_player)


func advance_turn(old_player: Player) -> void:
	
	# We should be responsible for advanding to the next player.
	# This also helps to guard against weird stuff from the Player.lost() signal.
	assert(old_player.is_current_player)
	
	var winning_player: Player = self.check_for_winner()
	if winning_player:
		self.celebrate_winner(winning_player)

		if self.auto_restart:
			CaravanUtils.delay(self.restart, self.auto_restart_delay, self)
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
	#	This probably means a game between AIs will play out recursivly on the stack.
	next_player.start_turn()

func on_player_lost(player: Player) -> void:
	if not self.game_over_man and player.is_current_player:
		self.advance_turn(player)


# TODO Kevin: Add panels, underlaying the caravans, showing how they are paired
