extends Node2D

onready var global_vars = get_node("/root/Global")
onready var _client = global_vars._client
onready var websocket_url = global_vars.websocket_url

const PlayerItem = preload("res://Scenes/PlayerItem.tscn")

func addItem(itemIndex, itemName):
	var item = PlayerItem.instance()
	item.get_node("Name").text = itemName
	item.get_node("Order").text = itemIndex
	item.rect_min_size = Vector2(130, 30)
	$Panel/ScrollContainer/list.add_child(item)
	
func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")
	_client.connect("peer_packet", self, "_on_data")


func _on_data():
	var players = global_vars.remote_players
	for i in range(players.size()):
		addItem(str(i+1), players[i])
	
func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
