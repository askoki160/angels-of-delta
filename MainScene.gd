extends Node2D

onready var global_vars = get_node("/root/Global")
var Player = load("res://Player.tscn")

var state = Utils.PlayerState.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$NumberOfPlayers.text = str(global_vars.players)
	$CurrentPlayerTurn.text = "Current player turn: " + str(state.get_current_index())
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


func _on_Dice_dice_thrown(dice_number):
	var current_player = state.get_current_instance()
	current_player.take_turn(dice_number)

func _on_end_turn():
	state._next_player()
	$CurrentPlayerTurn.text = "Current player turn: " + str(state.get_current_index())
