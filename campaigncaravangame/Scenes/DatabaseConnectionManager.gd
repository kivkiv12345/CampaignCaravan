extends PanelContainer



var gaas_connection: SQLManagerGAAS = null


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("enter"):
		%ConnectDatabaseButton.pressed.emit()


func _on_connect_database_button_pressed() -> void:
	assert(%ConnectDatabaseButton.visible)
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
	
	self.gaas_connection = SQLManagerGAAS.new()
	gaas_connection.hostname = %DatabaseHostnameLineEdit.text.rstrip("/")
	gaas_connection.login(%DatabaseUsernameLineEdit.text, %DatabasePasswordLineEdit.text, self._on_database_http_request_request_completed)
	
	%DisconnectDatabaseButton.visible = false
	%ConnectDatabaseButton.visible = false
	%SpinnerProgressBar.visible = true


func _on_disconnect_database_button_pressed() -> void:
	assert(%DisconnectDatabaseButton.visible)

	%DatabaseHostnameLineEdit.editable = true
	%DatabaseUsernameLineEdit.editable = true
	%DatabasePasswordLineEdit.editable = true
	
	SQLDB.reset_to_orignal_connection()
	
	%DisconnectDatabaseButton.visible = false
	%ConnectDatabaseButton.visible = true
	%SpinnerProgressBar.visible = false


func _on_login_succeeded() -> void:
	%DatabaseHostnameLineEdit.editable = false
	%DatabaseUsernameLineEdit.editable = false
	%DatabasePasswordLineEdit.editable = false
	
	SQLDB.connection = self.gaas_connection
	
	%DisconnectDatabaseButton.visible = true
	%ConnectDatabaseButton.visible = false
	%SpinnerProgressBar.visible = false


func _on_database_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	
	%DisconnectDatabaseButton.visible = false
	%ConnectDatabaseButton.visible = true
	%SpinnerProgressBar.visible = false

	if response_code < 200 or response_code >= 300:
		print(body.get_string_from_ascii())
		return  # Request failed

	self._on_login_succeeded()
