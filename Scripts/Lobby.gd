extends Node2D

const PlayerItem = preload("res://Scenes/PlayerItem.tscn")

func addItem(itemIndex, itemName):
	var item = PlayerItem.instance()
	item.get_node("Name").text = itemName
	item.get_node("Order").text = itemIndex
	item.rect_min_size = Vector2(130, 30)
	$Panel/ScrollContainer/list.add_child(item)
	
func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	for i in range(40):
		var it = str(i)
		addItem(it, "Name " + it)
	#var new_player = preload('res://player/Player.tscn').instance()
	#new_player.name = str(get_tree().get_network_unique_id())
	#new_player.set_network_master(get_tree().get_network_unique_id())
	#add_child(new_player)
	var info = Network.self_data
	$AllPlayers.text += str(info.name)
	#new_player.init(info.name, info.position, false)

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://interface/Menu.tscn')
