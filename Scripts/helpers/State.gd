extends Node


func _ready():
	pass

class PlayerState:
	var last_color_index = 0
	var player_colors = [
		Color(0.54902,0.07451,0.984314,1),
		Color(0.207843,0.886275,0.94902,1),
		Color(1,0,0.501961,1),
		Color(0.964706,0.87451,0.054902,1)
	]
	var current_player_index: int
	var players = []
	
	func _init():
		current_player_index = 0
		
	func set_current_index(index):
		current_player_index = index
		
	func add_player(player_instance):
		var color = player_colors[last_color_index]
		player_instance.get_node("Sprite").set_modulate(color)
		player_instance.get_node("PlayerName").set_modulate(color)
		self.last_color_index = (last_color_index + 1) % player_colors.size()
		players.append(player_instance)
		
	func get_current_index():
		return current_player_index
	
	func get_current_name():
		return players[current_player_index].name
		
	func get_current_instance():
		return players[current_player_index]
		
	func _next_player():
		current_player_index = (current_player_index + 1) % players.size()
