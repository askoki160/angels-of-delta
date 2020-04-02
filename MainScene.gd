extends Node2D

onready var global_vars = get_node("/root/Global")
var Player = load("res://Player.tscn")
var x_offset = 0

class PlayerState:
	var current_player_index: int
	var players = []
	
	func _init():
		current_player_index = 0
		
	func add_player(player_instance):
		players.append(player_instance)
		
	func get_current_index():
		return current_player_index
		
	func get_current_instance():
		return players[current_player_index]
		
	func _next_player():
		current_player_index = (current_player_index + 1) % players.size()

var state = PlayerState.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(global_vars.players)
	$Label2.text = "Current player turn: " + str(state.get_current_index())
	for i in range(global_vars.players):
		var player = load("res://Player.tscn")
		var player_instance = player.instance()
		player_instance.set_name("player_" + str(i))
		# hardcoded position
		player_instance.position = Vector2(10 + x_offset, 60)
		x_offset += 30
		state.add_player(player_instance)
		add_child(player_instance)


func _on_Dice_dice_thrown(dice_number):
	var current_player = state.get_current_instance()
	var last_position = current_player.position
	last_position.x += dice_number * 100
	current_player.position = last_position
	state._next_player()
	$Label2.text = "Current player turn: " + str(state.get_current_index())
