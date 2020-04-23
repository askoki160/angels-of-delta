extends KinematicBody2D

onready var global_vars = get_node("/root/Global/")
onready var fields = global_vars.fields
var pos_index = 0
var init_position_index = 0
# needed for MoveField depending on dice number
var last_dice_thrown_number = 0

signal ended_turn

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerName.text = self.name
	set_position(init_position_index)
	
func set_position(board_index):
	if board_index != init_position_index:
		fields[self.pos_index]['occupied'] -= 1
	# update player index
	self.pos_index = board_index
	var field_pos = fields[self.pos_index]['location']
	var occupied = fields[self.pos_index]['occupied']
	# move player on the board
	self.position = field_pos + occupied * Vector2(10, 10)
	fields[self.pos_index]['occupied'] += 1

func move_to_position(position_index) -> void:
#	This function is used to update all players positions 
#   when server response is received
	var board_index = (position_index) % fields.size()
	set_position(board_index)
	
func take_turn(dice_number) -> void:
	var board_index = (self.pos_index + dice_number) % fields.size()
	if dice_number > 0:
		self.last_dice_thrown_number = dice_number
	set_position(board_index)
	emit_signal("ended_turn") # Once the turn has finished
