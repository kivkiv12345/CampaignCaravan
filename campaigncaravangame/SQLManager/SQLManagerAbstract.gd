## Inspiration: https://www.youtube.com/watch?v=j-BRiTrw_F0

extends Resource


class_name SQLManagerAbstract


## This if the database exists, and that its version matches the game. Otherwise create it
func ensure_database() -> bool:
	assert(false)
	return false


func query_custom_decks() -> Array[CustomDeckScene]:
	self.ensure_database()
	assert(false)
	return []


func query_deck_cards(for_deck_name: String, callback: Callable) -> void:
	self.ensure_database()
	assert(false)
	callback.call([])


func delete_custom_deck(deck_name: String, callback: Callable) -> void:
	self.ensure_database()
	assert(false)


enum SaveCustomDeckResult {FAILED, UPDATED_EXISTING, SAVED_NEW, IN_PROGRESS}

## Will update the cards of an existing deck if one with the specified name already exists
func save_custom_deck(deck_name: String, deck_cards_arr: Array[DeckCardWithCounter], callback: Callable) -> SaveCustomDeckResult:
	
	self.ensure_database()
	assert(false)
	return SaveCustomDeckResult.FAILED
