extends Node2D

onready var global_vars = get_node("/root/Global")
var Player = load("res://Player.tscn")
var players = []
var x_offset = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(global_vars.players)
	for i in range(global_vars.players):
		var player = load("res://Player.tscn")
		var player_instance = player.instance()
		player_instance.set_name("player_" + str(i))
		# hardcoded position
		player_instance.position = Vector2(10 + x_offset, 60)
		x_offset += 30
		add_child(player_instance)
