extends Node

# The URL we will connect to
onready var secret_vars = get_node("/root/env_secrets")
onready var websocket_url = secret_vars.domain_ws_url + "/ws/game/"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func parse_server_response(_client):
	var parse_output =_client.get_peer(1).get_packet().get_string_from_utf8()
	if parse_output == "":
		print("Response is empty")
		return false

	var first_conversion = parse_json(parse_output)

	if typeof(first_conversion) == TYPE_DICTIONARY:
		return first_conversion
	return Utils._string_to_json(parse_json(parse_output))
	
func init_connection(_client, room_key):
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url + room_key + "/")
	if err != OK:
		print("Unable to connect")
		set_process(false)
		return
	set_process(true)
	print("connected: ", err)
	
func send_json_data(_client, key, value):
	_client.get_peer(1).put_packet(
		to_json({
			key: value	
		}).to_utf8()
	)
