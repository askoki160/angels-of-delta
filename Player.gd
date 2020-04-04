extends KinematicBody2D

onready var global_vars = get_node("/root/Global/")
onready var fields = global_vars.fields
var pos_index = 0
var init_position_index = 0

signal ended_turn

# Called when the node enters the scene tree for the first time.
func _ready():
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
	
func take_turn(dice_number) -> void:
	var board_index = (self.pos_index + dice_number) % fields.size()
	set_position(board_index)
	emit_signal("ended_turn") # Once the turn has finished


func alert(text: String, title: String='Message') -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	add_child(dialog)
	dialog.popup_centered()
