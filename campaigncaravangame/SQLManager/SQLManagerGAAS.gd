## Inspiration: https://www.youtube.com/watch?v=j-BRiTrw_F0

extends SQLManagerAbstract


class_name SQLManagerGAAS


# TODO Kevin: I guess we should store both of these locally,
#	using the build in resource store system thing.
@export var token: String = ""
@export var hostname: String = "HTTP://localhost:8000/"

var request_manager: HTTPRequest = HTTPRequest.new()


func _on_login_finished(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:

	if response_code < 200 or response_code >= 300:
		print(body.get_string_from_ascii())
		print("Error occurred with status code: %d" % response_code)
		return
		
	self.token = JSON.parse_string(body.get_string_from_ascii())['token']


func login(username: String, password: String, callback: Callable) -> bool:
	
	if not self.request_manager.is_inside_tree():
		# TODO Kevin: Memory leak?, and consequences for changing scene?
		SQLDB.get_tree().root.add_child(self.request_manager)
		
	# TODO Kevin: Be careful about the call order of these callbacks signals
	if not self.request_manager.request_completed.is_connected(self._on_login_finished):
		self.request_manager.request_completed.connect(self._on_login_finished, ConnectFlags.CONNECT_ONE_SHOT)
	
	if not self.request_manager.request_completed.is_connected(callback):
		self.request_manager.request_completed.connect(callback, ConnectFlags.CONNECT_ONE_SHOT)

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
	var post_error = self.request_manager.request(db_url, headers, HTTPClient.METHOD_POST, JSON.stringify(login_credentials))

	return post_error == OK


## This if the database exists, and that its version matches the game. Otherwise create it
func ensure_database() -> bool:
	
	if not self.token or self.token.length() <= 0:
		return false
		
	if not self.request_manager.is_inside_tree():
		# TODO Kevin: Memory leak?, and consequences for changing scene?
		SQLDB.get_tree().root.add_child(self.request_manager)
	
	# Assume migrations are applied and such
	return true


func _on_query_custom_decks_response(_result: int, response_code: int, _received_headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	
	if response_code < 200 or response_code >= 300:
		print("Error fetching custom decks. Status Code: %d" % response_code)
		print(body.get_string_from_utf8())
		callback.call([])
		return
	
	var response_json = body.get_string_from_utf8()
	var decks_data = JSON.parse_string(response_json)

	# Array to store custom decks
	var custom_decks: Array[CustomDeckScene] = []

	for deck_data in decks_data:
		# Instantiate the CustomDeckScene and set the deck name
		var custom_deck: CustomDeckScene = preload("res://Scenes/DeckCustomizer/CustomDeckScene.tscn").instantiate()
		custom_deck.set_deck_name(deck_data["name"])
		custom_decks.append(custom_deck)
	
	# Pass the array of custom decks to the callback
	callback.call(custom_decks)


func query_custom_decks(callback: Callable) -> void:
	self.ensure_database()
	
	# Construct the URL to query custom decks
	var query_url = self.hostname.rstrip('/') + "/api/decks/"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Token " + self.token.strip_edges(),
	]

	# Connect to handle the response once the request completes
	self.request_manager.request_completed.connect(self._on_query_custom_decks_response.bind(callback).call, ConnectFlags.CONNECT_ONE_SHOT)

	# Make the GET request to query custom decks
	self.request_manager.request(query_url, headers, HTTPClient.METHOD_GET)


func _on_query_deck_cards_response(_result: int, response_code: int, _received_headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	
	if response_code < 200 or response_code >= 300:
		print("Error fetching deck cards. Status Code: %d" % response_code)
		print(body.get_string_from_utf8())
		callback.call([])
		return
		
	var response_json = body.get_string_from_utf8()
	var deck_cards_data = JSON.parse_string(response_json)

	var deck_cards: Array[DeckCardWithCounter] = []
	for card_data in deck_cards_data:
		var deck_card: DeckCardWithCounter = preload("res://Scenes/DeckCustomizer/DeckCardWithCounter.tscn").instantiate()
		deck_card.card = Card.new(int(card_data["suit"]), int(card_data["rank"]))
		deck_card.set_card_count(int(card_data["count"]))
		deck_cards.append(deck_card)
	
	callback.call(deck_cards)


func query_deck_cards(for_deck_name: String, callback: Callable) -> void:
	self.ensure_database()
	
	# URL-encode the deck name to handle spaces and special characters
	var encoded_deck_name = for_deck_name.uri_encode()
	
	# Construct the URL to query deck cards by deck name
	var query_url = self.hostname.rstrip('/') + "/api/deck-cards/?deck__name=" + encoded_deck_name
	var headers = [
		"Content-Type: application/json",
		"Authorization: Token " + self.token.strip_edges(),
	]

	# Connect to handle the response once the request completes
	if not self.request_manager.request_completed.is_connected(self._on_query_deck_cards_response.bind(callback).call):
		self.request_manager.request_completed.connect(self._on_query_deck_cards_response.bind(callback).call, ConnectFlags.CONNECT_ONE_SHOT)
	
	# Make the GET request to query deck cards
	self.request_manager.cancel_request()
	self.request_manager.request(query_url, headers, HTTPClient.METHOD_GET)


func _on_custom_deck_deleted(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	
	if response_code < 200 or response_code >= 300:
		print(body.get_string_from_ascii())
		print("Error occurred with status code: %d" % response_code)
		callback.call(false)  # Failed to delete deck
		return
	
	callback.call(true)  # Sucessfully deleted deck


func delete_custom_deck(deck_name: String, callback: Callable) -> void:

	self.ensure_database()
	
	var encoded_deck_name = deck_name.uri_encode()
	
	# First, delete the existing deck if it exists (API call)
	var delete_url = self.hostname.rstrip('/') + "/api/decks/delete-by-name/" + encoded_deck_name + "/"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Token " + self.token.strip_edges(),
	]
	
	# Delete request first to ensure we overwrite existing decks with the same name
	self.request_manager.request_completed.connect(self._on_custom_deck_deleted.bind(callback).call, ConnectFlags.CONNECT_ONE_SHOT)
	var _delete_response = request_manager.request(delete_url, headers, HTTPClient.METHOD_DELETE)
	# NOTE: We could check delete_response here


func _on_deckcards_saved(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	
	var deckcard_result: SaveCustomDeckResult = SaveCustomDeckResult.UPDATED_EXISTING
	
	if response_code < 200 or response_code >= 300:
		print(body.get_string_from_ascii())
		print("Error occurred with status code: %d" % response_code)
		deckcard_result = SaveCustomDeckResult.FAILED
	elif response_code == 201:
		deckcard_result = SaveCustomDeckResult.SAVED_NEW
		
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
	var post_url = self.hostname.rstrip('/') + "/api/decks/save/"
	
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





const _save_path: String = "user://api_config.tres"


func save_api_config() -> void:
	
	# Save it to a .tres file (you can use a custom path if you prefer)
	ResourceSaver.save(self, _save_path)


static func load_api_config() -> SQLManagerGAAS:

	if not FileAccess.file_exists(_save_path):
		return null
		
	var _self: SQLManagerGAAS = load(_save_path) as SQLManagerGAAS
	assert(_self != null)
	return _self
	

func test_token_validity(callback: Callable) -> bool:
	var test_url = self.hostname.rstrip('/') + "/api/validate-token/"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Token " + self.token.strip_edges(),
	]
	
	if not self.request_manager.is_inside_tree():
		# TODO Kevin: Memory leak?, and consequences for changing scene?
		SQLDB.get_tree().root.add_child(self.request_manager)
	
	if not self.request_manager.request_completed.is_connected(callback.bind(self).call):
		self.request_manager.request_completed.connect(callback.bind(self).call, ConnectFlags.CONNECT_ONE_SHOT)

	var error = self.request_manager.request(test_url, headers)

	if error != OK:
		print("Failed to send request: ", error)
		return false
	return true
