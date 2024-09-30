## Inspiration: https://www.youtube.com/watch?v=j-BRiTrw_F0

extends SQLManagerAbstract


class_name SQLManagerGAAS


# TODO Kevin: I guess we should store both of these locally,
#	using the build in resource store system thing.
var token: String = ""
var hostname: String = "HTTP://localhost:8000/"

var request_manager: HTTPRequest = HTTPRequest.new()


func _on_login_finished(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:

	if response_code < 200 or response_code >= 300:
		print(body.get_string_from_ascii())
		print("Error occurred with status code: %d" % response_code)
		return
		
	self.token = JSON.parse_string(body.get_string_from_ascii())['token']


func login(username: String, password: String, callback: Callable) -> void:
	
	if not self.request_manager.is_inside_tree():
		# TODO Kevin: Memory leak?, and consequences for changing scene?
		SQLDB.get_tree().root.add_child(self.request_manager)
	
	if not self.request_manager.request_completed.is_connected(callback):
		self.request_manager.request_completed.connect(callback, ConnectFlags.CONNECT_ONE_SHOT)
	
	# TODO Kevin: Be careful about the call order of these callbacks signals
	if not self.request_manager.request_completed.is_connected(self._on_login_finished):
		self.request_manager.request_completed.connect(self._on_login_finished, ConnectFlags.CONNECT_ONE_SHOT)
		
	var login_credentials: Dictionary = {
		'username': username.strip_edges().strip_escapes(), 
		'password': password.strip_edges().strip_escapes(),
	}
	
	self.hostname = self.hostname.strip_edges().strip_escapes().rstrip("/")  # TODO Kevin: Weird place for side effect
	var db_url: String = ("%s/api/user-login/" % [self.hostname])
	var headers = [
		"Content-Type: application/json",
	]
	print(db_url)
	self.request_manager.request(db_url, headers, HTTPClient.METHOD_POST, JSON.stringify(login_credentials))



## This if the database exists, and that its version matches the game. Otherwise create it
func ensure_database() -> bool:
	
	if not self.token or self.token.length() <= 0:
		return false
		
	if not self.request_manager.is_inside_tree():
		# TODO Kevin: Memory leak?, and consequences for changing scene?
		SQLDB.get_tree().root.add_child(self.request_manager)
	
	# Assume migrations are applied and such
	return true


func query_custom_decks() -> Array[CustomDeckScene]:
	self.ensure_database()
	return []


func query_deck_cards(for_deck_name: String) -> Array[DeckCardWithCounter]:
	self.ensure_database()
	return []


func _on_custom_deck_deleted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	
	if response_code < 200 or response_code >= 300:
		print(body.get_string_from_ascii())
		print("Error occurred with status code: %d" % response_code)
		callback.call(false)  # Failed to delete deck
		return
	
	callback.call(true)  # Sucessfully deleted deck


func delete_custom_deck(deck_name: String, callback: Callable) -> void:

	self.ensure_database()
	
	# First, delete the existing deck if it exists (API call)
	var delete_url = self.hostname + "/api/decks/delete-by-name/" + deck_name + "/"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Token " + self.token.strip_edges(),
	]
	
	# Delete request first to ensure we overwrite existing decks with the same name
	self.request_manager.request_completed.connect(self._on_custom_deck_deleted.bind(callback).call, ConnectFlags.CONNECT_ONE_SHOT)
	var delete_response = request_manager.request(delete_url, headers, HTTPClient.METHOD_DELETE)


func _on_deckcards_saved(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	
	var deckcard_result: SaveCustomDeckResult = SaveCustomDeckResult.SAVED_NEW
	
	if response_code < 200 or response_code >= 300:
		print(body.get_string_from_ascii())
		print("Error occurred with status code: %d" % response_code)
		deckcard_result = SaveCustomDeckResult.FAILED
		
	callback.call(deckcard_result)


## Will update the cards of an existing deck if one with the specified name already exists
## Some HTTP request help from: https://chatgpt.com
func save_custom_deck(deck_name: String, deck_cards_arr: Array[DeckCardWithCounter], callback: Callable) -> SaveCustomDeckResult:
	
	self.ensure_database()
	
	# Prepare deck data to send for creation/update
	var cards_data = []
	for deck_card in deck_cards_arr:
		var card_data = {
			"suit": deck_card.card.suit,
			"rank": deck_card.card.rank,
			"count": deck_card.get_card_count()
		}
		cards_data.append(card_data)
	
	var deck_data = {
		"name": deck_name,
		"cards": cards_data
	}
	
	# Convert the deck data into JSON format
	var deck_json = JSON.stringify(deck_data)

	# Make a POST request to create or update the deck
	var post_url = self.hostname + "/api/decks/save/"
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Token " + self.token.strip_edges(),
	]
	
	self.request_manager.request_completed.connect(self._on_deckcards_saved.bind(callback).call, ConnectFlags.CONNECT_ONE_SHOT)
	var post_response = self.request_manager.request(post_url, headers, HTTPClient.METHOD_POST, deck_json)

	if post_response != OK:
		print("Error making the request")
		return SaveCustomDeckResult.FAILED
	
	return SaveCustomDeckResult.IN_PROGRESS
