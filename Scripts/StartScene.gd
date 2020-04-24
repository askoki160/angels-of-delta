extends Node2D

onready var global_vars = get_node("/root/Global")
onready var _client = global_vars._client


const get_room_url = "http://localhost:8000/game/get-room/"
var _player_name = ""

func _on_NameField_text_changed(new_text):
	_player_name = new_text

func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")
	# warning-ignore:return_value_discarded
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

# create lobby
func _on_CreateButton_pressed():
	$HTTPRequest.request(get_room_url)

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	global_vars.room_key = json.result.room_key
	global_vars.is_room_master = true
	print(json.result.room_key)
	Network.init_connection(_client, global_vars.room_key)

func _on_JoinButton_pressed():
	global_vars.is_room_master = false
	global_vars.room_key = $RoomField.text
	print("join with ", global_vars.room_key)
	Network.init_connection(_client, global_vars.room_key)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	Network.send_json_data(_client, "name", _player_name)
	print("name ", _player_name)
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/LobbyScene.tscn")

func _on_data():
	var json_response = Network.parse_server_response(_client)
	if json_response && json_response.has('players'):
		global_vars.remote_players = json_response.players
		_client.disconnect("data_received", self, "_on_data")
		print("disconnect")

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
