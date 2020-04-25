extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
	
	func _init(_context, fields_global):
		rect_width = 100
		rect_height = 100
		self.context = _context
		fields = fields_global
		
	func add_to_global_fields(pos_x, pos_y, idx):
		var field_dict: Dictionary = {
			"id": idx,
			"location": Vector2(pos_x, pos_y),
			'occupied': 0,
			"actions": self.context.all_field_actions[idx]
		}
		fields.append(field_dict)
		
	func generate_fields():
		"""
		Generate fields of the game. Starts from top left and goes clockwise.
		"""
		# warning-ignore:integer_division
		var position_x = -int(rect_width / 2)
		# warning-ignore:integer_division
		var position_y = int(rect_height / 2) + 20
		var board_fields_extent = (n_cols + n_rows - 2)
		var cumulative_fields = board_fields_extent * 2
		var right_vertical_border = board_fields_extent + 1
		var left_vertical_border = board_fields_extent + n_cols
		
		for i in range(cumulative_fields):
			if i < n_cols:
				position_x += rect_width + 10
			elif n_cols <= i and i < right_vertical_border:
				position_y += rect_height + 10
			elif right_vertical_border <= i and i < left_vertical_border:
				position_x -= rect_width + 10
			else:
				position_y -= rect_height + 10
				
			var Field = load("res://Scenes/Field.tscn")
			var field_instance = Field.instance()
			field_instance.position = Vector2(position_x, position_y)
			field_instance.resize_sprite(rect_height, rect_width)
			add_to_global_fields(position_x, position_y, i)
			context.add_child(field_instance)
