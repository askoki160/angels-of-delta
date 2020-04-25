extends Node2D

onready var global_vars = get_node("/root/Global")
onready var _client = global_vars._client
onready var all_field_actions = global_vars.all_field_actions
var Player = load("res://Scenes/Player.tscn")
var all_player_instances = []

var current_player = null
var state = State.PlayerState.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	_client.connect("data_received", self, "_on_data")
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	var map = Map.Map.new(self, global_vars.fields)
	map.generate_fields()
	_init_players()
	Network.send_json_data(_client, "info", 0)

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

func _init_players():
	state.set_current_index(global_vars.current_player_index)
	for i in range(global_vars.remote_players.size()):
		var player_json = Utils._string_to_json(global_vars.remote_players[i])
		var Player = load("res://Scenes/Player.tscn")
		var player_instance = Player.instance()

		player_instance.set_name(player_json.name)
		var player_sitting_position = i % global_vars.sitting_positions
		match (player_sitting_position):
			0:
				$PlayerPositionLegend.get_node("Left").text += player_json.name + ", "
			1:
				$PlayerPositionLegend.get_node("Top").text += player_json.name + ", "
			2:
				$PlayerPositionLegend.get_node("Right").text += player_json.name + ", "
			3:
				$PlayerPositionLegend.get_node("Bottom").text += player_json.name + ", "
		# connect all field instances
		player_instance.connect("ended_turn", self, "_on_end_turn")
		state.add_player(player_instance)
		all_player_instances.append(player_instance)
		add_child(player_instance)
	
	$CurrentPlayerTurn.text = "Current player turn: " + str(state.get_current_name())
	_update_dice_visibility()

func _update_dice_visibility():
	print("active vs local ", global_vars.current_player_index, " ", global_vars.client_index)
	if global_vars.current_player_index == global_vars.client_index:
		$Dice.visible = true
	else:
		$Dice.visible = false

func _on_data():
	var json_response = Network.parse_server_response(_client)
	if json_response.has('active_player'):
		print(" active_player ", json_response)
		state.set_current_index(int(json_response.active_player))
		global_vars.current_player_index = int(json_response.active_player)
	else:
		global_vars.remote_players = json_response.players
		# important only when player is disconnected during the game
		set_local_player_index()
	update_players_positions()

func update_players_positions():
		var players = global_vars.remote_players
		_update_dice_visibility()
		for i in range(players.size()):
			print("Updating player: ", players[i])
			var player_json = Utils._string_to_json(players[i])
			var current_position = int(player_json.position_index)
			var last_position = all_player_instances[i].pos_index
			if last_position != current_position:
				state.set_current_index(i)
				print(" curr ", current_position)
				print(" last ", last_position)
				self.current_player = state.get_current_instance()
				self.current_player.take_turn(current_position - last_position)
				print("New position index ", all_player_instances[i].pos_index)

func set_local_player_index():
	var players = global_vars.remote_players
	for i in range(players.size()):
		var player_json = Utils._string_to_json(players[i])
		print("Player ", players[i])
		if (player_json.name == global_vars.client_name):
			global_vars.client_index = i

func _on_Dice_dice_thrown(dice_number):
	Network.send_json_data(_client, "info", dice_number)

func alert(title: String, text: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.theme = load("res://assets/my_theme.tres")
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	add_child(dialog)
	dialog.popup_centered_minsize(Vector2(400, 100))

func _on_end_turn():
	var field_actions = all_field_actions[self.current_player.pos_index]
	var end_turn = true
	
	print("end 1 ", end_turn)
	
	for action in field_actions:
		match action.get_id():
			'BaseField':
				alert(action.title, action.message)
			'MoveField':
				alert(action.title, action.message)
				yield(get_tree().create_timer(2), "timeout")
				end_turn = false
				print("Move field: ", action.move_number)
				Network.send_json_data(_client, "info", action.move_number)
#				self.current_player.take_turn(action.move_number)
			'PlayAgainField':
				alert(action.title, action.message)
				end_turn = false
			'MovePreviousPositionField':
				alert(action.title, action.message)
				yield(get_tree().create_timer(2), "timeout")
				var last_thrown = self.current_player.last_dice_thrown_number
				end_turn = false
				print("Move previous field: ", last_thrown)
				Network.send_json_data(_client, "info", last_thrown)
			'MoveStartField':
				alert(action.title, action.message)
				Network.send_json_data(_client, "info", 0)
				print(" send ")
			'ThrowDiceField':
				var thrown = self.current_player.last_dice_thrown_number
				var complete_message = action.message + tr(" That is in your case: ") + str(thrown)
				alert(action.title, complete_message)
				end_turn = false
	print("end2 ", end_turn)
	if end_turn:
		state._next_player()
		print("current player index ", state.get_current_index())
		# set next player active
		global_vars.current_player_index = state.get_current_index()
		_update_dice_visibility()
		Network.send_json_data(_client, "turn_ended", state.get_current_index())
		# update current player turn
		$CurrentPlayerTurn.text = "Current player turn: " + str(state.get_current_name())
