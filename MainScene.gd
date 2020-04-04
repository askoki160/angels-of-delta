class_name Player
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
		
class Map:
	var n_rows: int = 7
	var n_cols: int = 10
	var field_rect_size : int
	var fields : Array
	var max_width: int
	var max_height: int
	var rect_width: int 
	var rect_height: int 
	var context
	
	func _init(context, fields_global):
		rect_width = 100
		rect_height = 100
		self.context = context
		fields = fields_global
		
	func add_to_global_fields(pos_x, pos_y, idx):
		var field_dict: Dictionary = {
			"id": idx,
			"location": Vector2(pos_x, pos_y),
			'occupied': 0,
			# TODO: field actions
			"actions": null
		}
		fields.append(field_dict)
		
	func generate_fields():
		"""
		Generate fields of the game. Starts from top left and goes clockwise.
		"""
		var position_x = -rect_width / 2
		var position_y = rect_height / 2
		var board_fields_extent = (n_cols + n_rows - 1)
		var cumulative_fields = board_fields_extent * 2
		var left_vertical_border = board_fields_extent + n_cols - 1
		
		for i in range(cumulative_fields):
			if i < n_cols:
				position_x += rect_width + 10
			elif n_cols <= i and i < board_fields_extent:
				position_y += rect_height + 10
			elif board_fields_extent <= i and i < left_vertical_border:
				position_x -= rect_width + 10
			else:
				position_y -= rect_height + 10
				
			var Field = load("res://Field.tscn")
			var field_instance = Field.instance()
			field_instance.position = Vector2(position_x, position_y)
			field_instance.resize_sprite(rect_height, rect_width)
			add_to_global_fields(position_x, position_y, i)
			context.add_child(field_instance)
			
var state = PlayerState.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(global_vars.players)
	$Label2.text = "Current player turn: " + str(state.get_current_index())
	var map = Map.new(self, global_vars.fields)
	map.generate_fields()
	for i in range(global_vars.players):
		var Player = load("res://Player.tscn")
		var player_instance = Player.instance()
		player_instance.set_name("player_" + str(i))
		# hardcoded position
		player_instance.position = Vector2(10 + x_offset, 60)
		# connect all field instances
		player_instance.connect("ended_turn", self, "_on_end_turn")
		x_offset += 30
		state.add_player(player_instance)
		add_child(player_instance)


func _on_Dice_dice_thrown(dice_number):
	var current_player = state.get_current_instance()
	current_player.take_turn(dice_number)

func _on_end_turn():
	state._next_player()
	$Label2.text = "Current player turn: " + str(state.get_current_index())
