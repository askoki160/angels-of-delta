extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func resize_sprite(height, width):
	var sizeto = Vector2(height, width)
	var size = get_node("OuterRect").get_size() 
	var size_inner = get_node("InnerRect").get_size() 
	var scale_vector: Vector2 = sizeto / size
	var scale_inner_vector: Vector2 = sizeto / size_inner
	#get_node("OuterRect").set_scale(scale_vector)
	#get_node("InnerRect").set_scale(scale_inner_vector)
