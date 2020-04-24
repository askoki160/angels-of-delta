extends Node

func _ready():
	pass
	
func _string_to_json(input_text):
#	Convert string to json (only on the first level)
	if typeof(input_text) != TYPE_STRING:
		print("Wrong input type. Should be String.")
		return

	var json = JSON.parse(input_text)
	if json.error == OK:
		if typeof(json.result) == TYPE_DICTIONARY:
			return json.result
	else:
		# TODO: improve error handling
		print("Unexpected result")
		return false

class BaseField:
	export var BaseFieldID: String = 'BaseField'
	var title: String
	var message: String
	
	func _init(_message, _title):
		self.title = _title
		self.message = _message
		
	func get_id():
		return BaseFieldID

class MoveField extends BaseField:
	var move_number: int
	export var MoveFieldID: String = 'MoveField'
	
	func _init(_message, _title, _move_number).(_message, _title):
		self.move_number = _move_number
		
	func get_id():
		return MoveFieldID
		
class MovePreviousPositionField extends BaseField:
	export var MoveFieldID: String = 'MovePreviousPositionField'

	func _init(_message, _title).(_message, _title):
		pass

	func get_id():
		return MoveFieldID

class MoveStartField extends BaseField:
	var move_number: int = 0
	export var MoveStartFieldID: String = 'MoveStartField'
	
	func _init(_message, _title).(_message, _title):
		pass
		
	func get_id():
		return MoveStartFieldID

class ThrowDiceField extends BaseField:
	export var ThrowDiceFieldID: String = 'ThrowDiceField'

	func _init(_message, _title).(_message, _title):
		pass
		
	func get_id():
		return ThrowDiceFieldID

class PlayAgainField extends BaseField:
	export var PlayAgainFieldID: String = 'PlayAgainField'

	func _init(_message, _title).(_message, _title):
		pass
	
	func get_id():
		return PlayAgainFieldID

class ChanceField extends BaseField:
	# TODO: implement random draw of chance from the pile
	export var ChanceFieldID: String = 'ChanceField'
	
	func _init(_message, _title).(_message, _title):
		pass
		
	func get_id():
		return ChanceFieldID
