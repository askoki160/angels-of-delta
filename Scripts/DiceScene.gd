extends Node2D

signal dice_thrown

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	# simulate throwing the dice
	var dice_number = randi() % 6 + 1
	$Label.text = str(dice_number)
	emit_signal("dice_thrown", dice_number)
