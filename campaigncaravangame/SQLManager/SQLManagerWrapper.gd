## Autoload wrapping a SQLManager, such that it may be reassigned.

extends Node


@onready var connection: SQLManagerAbstract = self._get_original_connection()


func _get_original_connection() -> SQLManagerAbstract:
	return SQLManagerSQLite.new()


func reset_to_orignal_connection() -> void:
	self.connection = self._get_original_connection()
