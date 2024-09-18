## Inspiration: https://www.youtube.com/watch?v=j-BRiTrw_F0

extends Node


var db: SQLite = SQLite.new()

func _ready() -> void:
	# TODO Kevin: We are gonna use lazy ensure once 
	self.ensure_database()


## This if the database exists, and that its version matches the game. Otherwise create it
func ensure_database() -> void:
	
	# "default" is apparently the default path,
	#	so we use that to check if we have already established a connection to the database.
	#	This is not super ideal, ideally we would want a db.is_open()
	if (db.path != "default"):
		# Already connected to the database, which means we have already ensured its existance.
		return

	# NOTE: Update the version number in the database name when changing the structure of tables.
	#	That way players can still go back to old versions of the game and keep their data.
	db.path = "res://data_v1.db"

	db.verbosity_level = SQLite.VerbosityLevel.VERY_VERBOSE
	db.foreign_keys = true
	db.open_db()  # .db file will be created here, if it doesn't exist.

	
	var tables: Dictionary = {
		"Decks": {
			"id": {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
			"name": {"data_type":"text", "not_null": true},
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
			
			# TODO Kevin: Ideally we would have this be unique_together
			"deck": {"data_type": "int", "foreign_key": "Decks.id", "not_null": true},
			"card": {"data_type": "int", "foreign_key": "Cards.id", "not_null": true},
		},
	}
	
	for table_name in tables:
		
		var table_data: Dictionary = tables[table_name]

		# Check if the table already exists or not.
		db.query_with_bindings("SELECT name FROM sqlite_master WHERE type='table' AND name=?;", [table_name])
		if db.query_result.is_empty():
			# Database doesn't exist, let's create it.
			db.create_table(table_name, table_data)
	
	
	# TODO Kevin: Check how much card is already in the database
	return
	
	# Insert all the cards
	var card_data: Array[Dictionary] = []
	for card_vector in TextureManager.texture_paths:
		card_data.append({"suit": card_vector.x, "rank": card_vector.y})
	db.insert_rows("Cards", card_data)
