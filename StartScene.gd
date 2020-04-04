extends Node

onready var global_vars = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# start game
func _on_Button_pressed():
	Global.goto_scene("res://MainScene.tscn")


func _on_SpinBox_value_changed(value):
	global_vars.players = value
