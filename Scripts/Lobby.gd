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
		all_items = []

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

	if global_vars.is_room_master:
		$Code.text = global_vars.room_key
	else:
		remove_child($Code)
		remove_child($CodeLabel)
		remove_child($StartButton)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)
	
func _on_data():
	var players = global_vars.remote_players
	reset_items()
	for i in range(players.size()):
#		print("Player ", players[i])
		var player_json = Utils._string_to_json(players[i])
		add_item(str(i+1), player_json.name)
	
func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

func _on_StartButton_button_up():
	var payload_dict = {
		"start": true
	}
	_client.get_peer(1).put_packet(to_json(payload_dict).to_utf8())
