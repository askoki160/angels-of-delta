extends KinematicBody2D

# TODO: dice generator which connects to the player object
var dice_number = 2

var speedHorizontal = 200
var speedVertical = 0
# original starting point for character
var targetPos = Vector2(980, 1200)
	
var velocity : Vector2 = Vector2()
var direction = Vector2.DOWN

# find the node when game starts
onready var sprite : Sprite = get_node("Sprite")

func _physics_process(delta):
	velocity.x = speedHorizontal
	velocity.y = speedVertical
	velocity = move_and_slide(velocity, direction)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func alert(text: String, title: String='Message') -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	add_child(dialog)
	dialog.popup_centered()


func _on_StartField_body_entered(body):
	if dice_number <= 0:
		speedHorizontal = 0
		speedVertical = 0
		OS.alert("Start", "All drink!")
	else:
		speedHorizontal = 200
		speedVertical = 0


func _on_Field2_body_exited(body):
	dice_number -= 1
	if dice_number <= 0:
		speedHorizontal = 0
		speedVertical = 0
		OS.alert("Drink 3", "Drink field, what a surprise!")
		

func _on_Field3_body_shape_entered(body_id, body, body_shape, area_shape):
	dice_number -= 1
	if dice_number <= 0:
		speedHorizontal = 0
		speedVertical = 0
		OS.alert("Drink 4", "Drink field, what a surprise!")
	else:
		speedHorizontal = 0
		speedVertical = 200



func _on_Field4_body_entered(body):
	dice_number -= 1
	if dice_number <= 0:
		speedHorizontal = 0
		speedVertical = 0
		OS.alert("Drink 5", "Drink field, what a surprise!")
	else:
		speedHorizontal = -200
		speedVertical = 0	


func _on_Field5_body_entered(body):
	dice_number -= 1
	if dice_number <= 0:
		speedHorizontal = 0
		speedVertical = 0
		OS.alert("Drink 6", "Drink field, what a surprise!")
	else:
		speedHorizontal = 0
		speedVertical = -200
