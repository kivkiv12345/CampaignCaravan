extends Resource


class_name SQLManagerAbstract


## This if the database exists, and that its version matches the game. Otherwise create it
func ensure_database() -> bool:
	assert(false)
	return false


## Returns true if a query request is sent successfully
func query_custom_decks(callback: Callable) -> bool:
	self.ensure_database()
	assert(false)
	callback.call([])
	return false


func query_deck_cards(_for_deck_name: String, callback: Callable) -> void:
	self.ensure_database()
	assert(false)
	callback.call([])


func delete_custom_deck(_deck_name: String, callback: Callable) -> void:
	self.ensure_database()
	assert(false)
	callback.call(false)


enum SaveCustomDeckResult {FAILED, UPDATED_EXISTING, SAVED_NEW, IN_PROGRESS}

## Will update the cards of an existing deck if one with the specified name already exists
func save_custom_deck(_deck_name: String, _deck_cards_arr: Array[DeckCardWithCounter], callback: Callable) -> SaveCustomDeckResult:
	
	self.ensure_database()
	assert(false)
	callback.call(SaveCustomDeckResult.FAILED)
	return SaveCustomDeckResult.FAILED
