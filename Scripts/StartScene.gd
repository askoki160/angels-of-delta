extends Node2D

onready var global_vars = get_node("/root/Global")
onready var _client = global_vars._client
onready var websocket_url = global_vars.websocket_url
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


func init_connection():
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	set_process(true)
	print("connected: ", err)

# start game
func _on_CreateButton_pressed():
	init_connection()


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
	var payload_dict = {
		"name": _player_name
	}
	_client.get_peer(1).put_packet(to_json(payload_dict).to_utf8())
	Global.goto_scene("res://Scenes/LobbyScene.tscn")

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var parse_output =_client.get_peer(1).get_packet().get_string_from_utf8()
		
	var json = JSON.parse(parse_json(parse_output))
	if json.error == OK:
		if typeof(json.result) == TYPE_DICTIONARY:
			print(json.result.players)
			global_vars.remote_players = json.result.players
	else:
		print("unexpected results")
	
func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

func _on_JoinButton_pressed():
	init_connection()
	
func _load_game():
	get_tree().change_scene("res://Scenes/LobbyScene.tscn")
