extends KinematicBody2D

var speedHorizontal = 200
var speedVertical = 0
# original starting point for character
var targetPos = Vector2(980, 1200)
	
var velocity : Vector2 = Vector2()
var direction = Vector2.DOWN
var start_pos = Vector2(980, 1200)

onready var global_vars = get_node("/root/Global/")
var pos_index = 0

signal ended_turn

func _physics_process(delta):
	pass
	#velocity.x = speedHorizontal
	#velocity.y = speedVertical
	#velocity = move_and_slide(velocity, direction)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func take_turn(dice_number) -> void:
	var fields = global_vars.fields
	fields[self.pos_index]['occupied'] -= 1
	
	self.pos_index = (self.pos_index + dice_number) % fields.size()
	var field_pos = fields[self.pos_index]['location']
	var occupied = fields[self.pos_index]['occupied']
	
	#var last_position = self.position
	#last_position.x += dice_number * 100
	self.position = field_pos + occupied * Vector2(10, 10)
	
	fields[self.pos_index]['occupied'] += 1
	
	
	emit_signal("ended_turn") # Once the turn has finished


func alert(text: String, title: String='Message') -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	add_child(dialog)
	dialog.popup_centered()


#func _on_StartField_body_entered(body):
#	if dice_number <= 0:
#		speedHorizontal = 0
#		speedVertical = 0
#		OS.alert("Start", "All drink!")
#	else:
#		speedHorizontal = 200
#		speedVertical = 0
#
#
#func _on_Field2_body_exited(body):
#	dice_number -= 1
#	if dice_number <= 0:
#		speedHorizontal = 0
#		speedVertical = 0
#		OS.alert("Drink 3", "Drink field, what a surprise!")
#
#
#func _on_Field3_body_shape_entered(body_id, body, body_shape, area_shape):
#	dice_number -= 1
#	if dice_number <= 0:
#		speedHorizontal = 0
#		speedVertical = 0
#		OS.alert("Drink 4", "Drink field, what a surprise!")
#	else:
#		speedHorizontal = 0
#		speedVertical = 200
#
#
#
#func _on_Field4_body_entered(body):
#	dice_number -= 1
#	if dice_number <= 0:
#		speedHorizontal = 0
#		speedVertical = 0
#		OS.alert("Drink 5", "Drink field, what a surprise!")
#	else:
#		speedHorizontal = -200
#		speedVertical = 0	
#
#
#func _on_Field5_body_entered(body):
#	dice_number -= 1
#	if dice_number <= 0:
#		speedHorizontal = 0
#		speedVertical = 0
#		OS.alert("Drink 6", "Drink field, what a surprise!")
#	else:
#		speedHorizontal = 0
#		speedVertical = -200
