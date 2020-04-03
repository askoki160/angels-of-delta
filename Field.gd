extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func resize_sprite(height, width):
	var sizeto = Vector2(height, width)
	var size = get_node("Sprite").get_texture().get_size() 
	var scale_vector: Vector2 = sizeto / size
	get_node("Sprite").set_scale(scale_vector)
