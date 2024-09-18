# This class has been sourced from: https://forum.godotengine.org/t/best-proper-way-to-do-ui-sounds-hover-click/39081/3

extends Node

var playback:AudioStreamPlaybackPolyphonic


func _enter_tree() -> void:
	# Create an audio player
	var player = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node:Node) -> void:
	
	if node is Button or node is TextureButton:

		if node.disabled:
			# TODO Kevin: We very much want to connect the signal, even if the button is disabled.
			#	But we can't check if the button is diabled in the signal.
			#	And right now we can rely on the fact that we don't disable/enable buttons on runtime.
			return
		# If the added node is a button we connect to its mouse_entered and pressed signals
		# and play a sound
		node.mouse_entered.connect(_play_hover)
		node.focus_entered.connect(_play_hover)
		node.pressed.connect(_play_pressed)


func _play_hover() -> void:
	# TODO Kevin: Really wish we could check if the button was disabled here.
	playback.play_stream(preload("res://FalloutNVUISounds/menu/ui_menu_focus.wav"), 0, 0, randf_range(0.95, 1.05))


func _play_pressed() -> void:
	# TODO Kevin: We probably can't avoid subclassing button if we want to play the correct sound when disabled.
	playback.play_stream(preload("res://FalloutNVUISounds/menu/ui_menu_ok.wav"), 0, 0, randf_range(0.9, 1.1))
