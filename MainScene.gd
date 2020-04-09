extends Node2D

onready var global_vars = get_node("/root/Global")
onready var all_field_actions = global_vars.all_field_actions
var Player = load("res://Player.tscn")

var state = Utils.PlayerState.new()
var current_player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var map = Utils.Map.new(self, global_vars.fields)
	map.generate_fields()
	for i in range(global_vars.players):
		var Player = load("res://Player.tscn")
		var player_instance = Player.instance()
		player_instance.set_name("player_" + str(i))
		# connect all field instances
		player_instance.connect("ended_turn", self, "_on_end_turn")
		state.add_player(player_instance)
		add_child(player_instance)
	
	$CurrentPlayerTurn.text = "Current player turn: " + str(state.get_current_name())


func _on_Dice_dice_thrown(dice_number):
	self.current_player = state.get_current_instance()
	self.current_player.take_turn(dice_number)

func alert(title: String, text: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	add_child(dialog)
	dialog.popup_centered_minsize(Vector2(400, 100))
	
func _on_end_turn():
	var field_actions = all_field_actions[self.current_player.pos_index]
	var end_turn = true
	
	for action in field_actions:
		match action.get_id():
			'BaseField':
				alert(action.title, action.message)
			'MoveField':
				alert(action.title, action.message)
				yield(get_tree().create_timer(2), "timeout")
				self.current_player.take_turn(action.move_number)
			'PlayAgainField':
				alert(action.title, action.message)
				end_turn = false
			'MovePreviousPositionField':
				alert(action.title, action.message)
				yield(get_tree().create_timer(2), "timeout")
				var last_thrown = self.current_player.last_dice_thrown_number
				self.current_player.take_turn(-last_thrown)
			'MoveStartField':
				alert(action.title, action.message)
				self.current_player.set_position(0)
			'ThrowDiceField':
				var thrown = self.current_player.last_dice_thrown_number
				var complete_message = action.message + tr(" That is in your case: ") + str(thrown)
				alert(action.title, complete_message)
	if end_turn:
		state._next_player()
	# update current player turn
	$CurrentPlayerTurn.text = "Current player turn: " + str(state.get_current_name())
