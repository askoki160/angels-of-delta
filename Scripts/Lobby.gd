extends Node2D

onready var global_vars = get_node("/root/Global")
onready var _client = global_vars._client
onready var websocket_url = global_vars.websocket_url

const PlayerItem = preload("res://Scenes/PlayerItem.tscn")
var all_items = []

func reset_items():
	if all_items.size() != 0:
		for i in range(all_items.size()):
			$Panel/ScrollContainer/list.remove_child(all_items[i])

func add_item(itemIndex, itemName):
	var item = PlayerItem.instance()
	item.get_node("Name").text = itemName
	item.get_node("Order").text = itemIndex
	item.rect_min_size = Vector2(130, 30)
	all_items.append(item)
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
	if global_vars.is_room_master:
		$Code.text = global_vars.room_key
	else:
		remove_child($Code)
		remove_child($CodeLabel)
		remove_child($StartButton)

func _on_data():
	var parse_output =_client.get_peer(1).get_packet().get_string_from_utf8()
	if parse_output != "":
		print("1st ", parse_output)
		var json = JSON.parse(parse_json(parse_output))
		print("json ", json)
		if json.error == OK:
			if typeof(json.result) == TYPE_DICTIONARY:
				print(json.result.players)
				global_vars.remote_players = json.result.players
		else:
			print("unexpected results")
		
		print("Global players: ", global_vars.remote_players)
	var players = global_vars.remote_players
	reset_items()
	for i in range(players.size()):
		add_item(str(i+1), players[i])
	
func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
