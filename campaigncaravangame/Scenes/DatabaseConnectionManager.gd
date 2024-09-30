extends PanelContainer


func _token_test_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, saved_connection: SQLManagerGAAS) -> void:

	if response_code < 200 or response_code >= 300:
		self._on_disconnect_database_button_pressed()
		print(body.get_string_from_ascii())
		print("Error occurred with status code: %d" % response_code)
		return
		
	SQLDB.connection = saved_connection
	
	
	%DatabaseHostnameLineEdit.text = SQLDB.connection.hostname
	
	# We have long since forgotten which credentials were used to log in.
	#	We now only remember the token.
	%DatabaseUsernameLineEdit.text = ""
	%DatabasePasswordLineEdit.text = ""
	
	self._on_login_succeeded(SQLDB.connection)


func _defer_login(saved_connection: SQLManagerGAAS) -> void:
	var post_succeded: bool = saved_connection.test_token_validity(self._token_test_completed)
	if post_succeded:
		self._set_request_in_progress()

func _ready() -> void:
	
	var saved_connection: SQLManagerGAAS = SQLManagerGAAS.load_api_config()
	if saved_connection != null and saved_connection.hostname != "" and saved_connection.token != "":
		self._defer_login.call_deferred(saved_connection)
	
	
	if SQLDB.connection is SQLManagerGAAS:
		%DatabaseHostnameLineEdit.text = SQLDB.connection.hostname
		
		# We have long since forgotten which credentials were used to log in.
		#	We now only remember the token.
		%DatabaseUsernameLineEdit.text = ""
		%DatabasePasswordLineEdit.text = ""
		
		self._on_login_succeeded(SQLDB.connection)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("enter"):
		%ConnectDatabaseButton.pressed.emit()


func _set_request_in_progress() -> void:

	%DatabaseHostnameLineEdit.editable = false
	%DatabaseUsernameLineEdit.editable = false
	%DatabasePasswordLineEdit.editable = false
	
	%DisconnectDatabaseButton.visible = false
	%ConnectDatabaseButton.visible = false
	%SpinnerProgressBar.visible = true

func _on_connect_database_button_pressed() -> void:
	if not %ConnectDatabaseButton.visible:
		return
	#if not %DatabaseHTTPRequest.request_completed.is_connected(self._on_database_http_request_request_completed):
		#%DatabaseHTTPRequest.request_completed.connect(self._on_database_http_request_request_completed)
		#
	#var login_credentials: Dictionary = {
		#'username': %DatabaseUsernameLineEdit.text, 
		#'password': %DatabasePasswordLineEdit.text,
	#}
	#var db_url: String = ("%s/api/user-login/" % [%DatabaseHostnameLineEdit.text.rstrip("/")])
	#var headers: Array[String] = ["Content-Type: application/json"]
	#print(db_url)
	#%DatabaseHTTPRequest.request(db_url, headers, HTTPClient.METHOD_POST, JSON.stringify(login_credentials))
	
	var gaas_connection: SQLManagerGAAS = SQLManagerGAAS.new()
	gaas_connection.hostname = %DatabaseHostnameLineEdit.text.rstrip("/")
	var post_succeded: bool = gaas_connection.login(%DatabaseUsernameLineEdit.text, %DatabasePasswordLineEdit.text, self._on_database_http_request_request_completed.bind(gaas_connection).call)
	
	if post_succeded:
		self._set_request_in_progress()


func _on_disconnect_database_button_pressed() -> void:
	#assert(%DisconnectDatabaseButton.visible)

	%DatabaseHostnameLineEdit.editable = true
	%DatabaseUsernameLineEdit.editable = true
	%DatabasePasswordLineEdit.editable = true
	
	# Teardown
	if (SQLDB.connection is SQLManagerGAAS):
		SQLDB.connection.hostname = ""
		SQLDB.connection.token = ""
		SQLDB.connection.save_api_config()
	
	SQLDB.reset_to_orignal_connection()
	
	%DisconnectDatabaseButton.visible = false
	%ConnectDatabaseButton.visible = true
	%SpinnerProgressBar.visible = false


func _on_login_succeeded(successful_connection: SQLManagerGAAS) -> void:
	%DatabaseHostnameLineEdit.editable = false
	%DatabaseUsernameLineEdit.editable = false
	%DatabasePasswordLineEdit.editable = false
	
	SQLDB.connection = successful_connection
	
	%DisconnectDatabaseButton.visible = true
	%ConnectDatabaseButton.visible = false
	%SpinnerProgressBar.visible = false
	
	successful_connection.save_api_config()


func _on_database_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, gaas_connection: SQLManagerGAAS) -> void:
	
	%DisconnectDatabaseButton.visible = false
	%ConnectDatabaseButton.visible = true
	%SpinnerProgressBar.visible = false

	if response_code < 200 or response_code >= 300:
		%DatabaseHostnameLineEdit.editable = true
		%DatabaseUsernameLineEdit.editable = true
		%DatabasePasswordLineEdit.editable = true
		print(body.get_string_from_ascii())
		return  # Request failed

	self._on_login_succeeded(gaas_connection)
