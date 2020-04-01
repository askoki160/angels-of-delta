extends Node2D

onready var global_vars = get_node("/root/Global")
var Player = load("res://Player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(global_vars.players)
