## Inspiration: https://www.youtube.com/watch?v=j-BRiTrw_F0

extends SQLManagerAbstract


class_name SQLManagerSQLite


var _db: SQLite = SQLite.new()


## This if the database exists, and that its version matches the game. Otherwise create it
func ensure_database() -> bool:
	
	# "default" is apparently the default path,
	#	so we use that to check if we have already established a connection to the database.
	#	This is not super ideal, ideally we would want a db.is_open()
	if (self._db.path != "default"):
		# Already connected to the database, which means we have already ensured its existance.
		return true

	# NOTE: Update the version number in the database name when changing the structure of tables.
	#	That way players can still go back to old versions of the game and keep their data.
	self._db.path = "res://data_v1.db"

	self._db.verbosity_level = SQLite.VerbosityLevel.NORMAL
	self._db.foreign_keys = true  # Must be set for godot-SQLite to handle foreign keys
	self._db.open_db()  # .db file will be created here, if it doesn't exist.

	
	var tables: Dictionary = {
		"Decks": {
			"id": {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
			"name": {"data_type":"text", "not_null": true, "unique": true},
		},
		
		"Cards": {
			"id": {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
			"suit": {"data_type":"int", "not_null": true},
			"rank": {"data_type":"int", "not_null": true},
		},
		
		# Use a many-to-many relationship between decks and cards,
		#	just so it doesn't look like we're going easy on the database.
		"DeckCards": {
			"id": {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
			
			# Normal columns
			"count": {"data_type":"int", "not_null": true},  # How many of this card is in this deck
			
			# NOTE: Ideally we would have these be unique_together,
			#	or a composite key.
			#	Evidently, the SQLite driver we use only supports one column being primary key,
			#	as well SQLite itself probably.
			# Foreign Keys
			"deck": {"data_type": "int", "foreign_key": "Decks.id", "not_null": true},
			"card": {"data_type": "int", "foreign_key": "Cards.id", "not_null": true},
		},
		
		# "GameRules": {
		# 	"id": {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
			
		# 	# Normal columns
		# 	# TODO Kevin: We should consider some static/const default value variables on GameRule.
		# 	#	It seems like that these should always be synced with the database.
		# 	"caravan_max_value": {"data_type":"int", "not_null": true, "default": 26},
		# 	"caravan_min_value": {"data_type":"int", "not_null": true, "default": 21},
		# 	"caravan_max_cards": {"data_type":"int", "not_null": true, "default": 20},

		# 	"queen_changes_suit": {"data_type":"int", "not_null": true, "default": 1},
		# 	"queen_changes_direction": {"data_type":"int", "not_null": true, "default": 0},

		# 	"number_card_allow_faces_first_round": {"data_type":"int", "not_null": true, "default": 1},
		# 	"number_card_require_face_match_suit": {"data_type":"int", "not_null": true, "default": 0},
		# 	"number_card_max_faces": {"data_type":"int", "not_null": true, "default": 3},

		# 	"hand_size": {"data_type":"int", "not_null": true, "default": 6},
		# 	"can_discard_caravans": {"data_type":"int", "not_null": true, "default": 1},
		# 	"require_all_caravans": {"data_type":"int", "not_null": true, "default": 0},

		# 	"deck_min_size": {"data_type":"int", "not_null": true, "default": 30},
		# 	"deck_max_size": {"data_type":"int", "not_null": true, "default": 108},
		# 	"deck_shuffle": {"data_type":"int", "not_null": true, "default": 1},
		# 	"deck_require_unique_cards": {"data_type":"int", "not_null": true, "default": 1},
	
		# 	"deck_seed": {"data_type":"int", "not_null": true, "default": 0},

		# 	# Foreign Keys
		# 	"deck": {"data_type": "int", "foreign_key": "Decks.id", "not_null": false},
		# },
	}
	
	for table_name in tables:
		
		var table_data: Dictionary = tables[table_name]

		# Check if the table already exists or not.
		self._db.query_with_bindings("SELECT name FROM sqlite_master WHERE type='table' AND name=?;", [table_name])
		if self._db.query_result.is_empty():
			# Table doesn't exist, let's create it.
			self._db.create_table(table_name, table_data)
	
	var existing_cards: Array = self._db.select_rows("Cards", "", ["*"])
	
	var card_array: Array[Card] = []
	for card_vector in TextureManager.texture_paths:
		card_array.append(Card.new(card_vector.x, card_vector.y))
	
	
	if existing_cards.size() > 0:
		# Check that the Cards table hasn't been tampered with
		assert(existing_cards.size() == card_array.size())
		
		var pk: int = 0
		for row in existing_cards:
			pk += 1
			assert(row["id"] == pk)
			assert(row["suit"] == card_array[pk-1].suit)
			assert(row["rank"] == card_array[pk-1].rank)
	else:  # Insert all the cards
		var card_data: Array[Dictionary] = []
		for card_vector in TextureManager.texture_paths:
			card_data.append({"suit": card_vector.x, "rank": card_vector.y})
		self._db.insert_rows("Cards", card_data)
		
	return true


func query_custom_decks(callback: Callable) -> void:
	self.ensure_database()
	
	var decks_query_result: Array = self._db.select_rows("Decks", "", ["*"])
	
	var custom_decks: Array[CustomDeckScene] = []
	for query_deck in decks_query_result:
		var custom_deck: CustomDeckScene = preload("res://Scenes/DeckCustomizer/CustomDeckScene.tscn").instantiate()
		custom_deck.set_deck_name(query_deck["name"])
		custom_decks.append(custom_deck)
	
	callback.call(custom_decks)


func query_deck_cards(for_deck_name: String, callback: Callable) -> void:
	self.ensure_database()
	
	var success: bool = true

	# Get the ID of the deck
	success = self._db.query_with_bindings("SELECT id FROM Decks WHERE name = ?", [for_deck_name,])
	assert(success)

	var existing_decks: Array[Dictionary] = self._db.query_result
	assert(existing_decks.size() == 1)
	
	var query_string : String = "SELECT count, suit, rank FROM DeckCards JOIN Cards ON Cards.id = DeckCards.card WHERE deck = ?;"
	var param_bindings : Array = [existing_decks[0]["id"]]
	
	success = self._db.query_with_bindings(query_string, param_bindings)
	assert(success)
	
	var deck_cards: Array[DeckCardWithCounter]
	for query_deck_card in self._db.query_result:
		var deck_card: DeckCardWithCounter = preload("res://Scenes/DeckCustomizer/DeckCardWithCounter.tscn").instantiate()
		deck_card.card = Card.new(query_deck_card["suit"], query_deck_card["rank"])
		deck_card.set_card_count(query_deck_card["count"])
		deck_cards.append(deck_card)
	
	callback.call(deck_cards)


func delete_custom_deck(deck_name: String, callback: Callable) -> void:

	self.ensure_database()

	var success: bool = true
	success = self._db.query_with_bindings("SELECT id FROM Decks WHERE name = ?", [deck_name,])
	assert(success)

	var existing_decks: Array[Dictionary] = self._db.query_result
	
	if existing_decks.size() == 0:
		callback.call(false)
		return
	
	assert(existing_decks.size() == 1)

	# First delete all the cards, to avoid any constraints.
	success = self._db.query_with_bindings("DELETE FROM DeckCards WHERE deck = ?", [existing_decks[0]["id"],])
	assert(success)

	# And now we can delete the deck itself
	success = self._db.query_with_bindings("DELETE FROM Decks WHERE id = ?", [existing_decks[0]["id"],])
	assert(success)

	callback.call(true)


## Will update the cards of an existing deck if one with the specified name already exists
func save_custom_deck(deck_name: String, deck_cards_arr: Array[DeckCardWithCounter], callback: Callable) -> SaveCustomDeckResult:
	
	self.ensure_database()
	
	var success: bool = true
	
	self._db.query_with_bindings("SELECT id FROM Decks WHERE name = ?", [deck_name])
	assert(success)
	
	var existing_decks: Array = self._db.query_result
	assert(existing_decks.size() <= 1)  # It shouldn't be possible to have multiple decks with the same name
	
	# Reuse variable, to avoid warning
	var insert_success: bool = true
	
	var saved_new: bool = false
	if existing_decks.size() == 0:  # A deck with this name doesn't exist.
		insert_success = self._db.insert_row("Decks", {"name": deck_name})
		assert(insert_success == true, "I'm not gonna bother with what happens if we can't insert decks, for now")
		
		# Now we need to get the primary key
		self._db.query_with_bindings("SELECT id FROM Decks WHERE name = ?", [deck_name])
		assert(success)
		
		existing_decks = self._db.query_result
		assert(existing_decks.size() == 1)
		saved_new = true
	
	
	var deckcard_data: Array[Dictionary] = []
	for deck_cards in deck_cards_arr:
		assert(deck_cards is DeckCardWithCounter)
		
		var card_vector: Vector2i = TextureManager.get_card_from_texture(deck_cards.texture_normal)
		var card: Card = Card.new(card_vector.x, card_vector.y)
		
		# ensure_database creates the database, such that Cards.pk == Card.get_index()+1 
		deckcard_data.append({"deck": existing_decks[0]["id"], "card": card.get_index()+1, "count": deck_cards.get_card_count()})

	# Just delete all the existing cards, and insert new ones, because we're lazy.
	success = self._db.query_with_bindings("DELETE FROM DeckCards WHERE deck = ?", [existing_decks[0]["id"],])
	assert(success)

	insert_success = self._db.insert_rows("DeckCards", deckcard_data)
	assert(insert_success == true, "I'm not gonna bother with what happens if we can't insert decks, for now")
	
	if saved_new:
		callback.call(SaveCustomDeckResult.SAVED_NEW)
		return SaveCustomDeckResult.SAVED_NEW
	else:
		callback.call(SaveCustomDeckResult.UPDATED_EXISTING)
		return SaveCustomDeckResult.UPDATED_EXISTING
