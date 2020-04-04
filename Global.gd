extends Node

# default number of players
var players = 1
var current_scene = null

var fields: Array
var all_field_actions = [
		[Utils.BaseField.new(tr('Drink one'), tr('Start'))],
		[Utils.BaseField.new(tr('No one\'s drinking'), tr('Lame'))],
		[Utils.ChanceField.new(tr('Draw a card'), tr('Chance'))],
		[Utils.BaseField.new(tr('Drink two with a player opposite from you'), tr('Drink'))],
		[Utils.BaseField.new(tr('Rock, paper, scissors with the left player'), tr('Play'))],
		[Utils.BaseField.new(tr('Player opposite from you drinks'), tr('Drink'))],
		[Utils.BaseField.new(tr('Everyone but you drinks'), tr('Drink'))],
		[
			Utils.BaseField.new(tr('Give 5 sips to anyone'), tr('Drink')), 
			Utils.BaseField.new(tr('Drink 1 and give 3'), tr('Optional'))
		],
		[Utils.ChanceField.new(tr('Draw a card'), tr('Chance'))],
		[Utils.BaseField.new(tr('Only girls drink'), tr('Drink'))],
		[Utils.MoveField.new(tr('Drink 2 and go 3 steps back'), tr('Back'), -3)],
		[Utils.BaseField.new(tr('Play odd or even with the player on the left. Who wins drinks!'), tr('Play'))],
		[Utils.MoveStartField.new(tr('Back to beginning'), tr('Start'))],
		[Utils.BaseField.new(tr('Choose with whom you drink 2 sips'), tr('Drink'))],
		[Utils.PlayAgainField.new(tr('Drink 2 and play again'), tr('Drink'))],
		[Utils.BaseField.new(tr('Only guys drink!'), tr('Drink'))],
		[Utils.ChanceField.new(tr('Draw a card'), tr('Chance'))],
		[
			Utils.BaseField.new(tr('Drink 1 and give 3'), tr('Optional')),
			Utils.MoveField.new(tr('Go 3 steps back'), tr('Back'), -3)
		],
		[Utils.BaseField.new(tr('Everybody drinks'), tr('Drink'))],
		[Utils.BaseField.new(tr('Person on the left and person on the right of you drink!'), tr('Drink'))],
		[Utils.BaseField.new(tr('Rock, paper, scissors with the player on the right. Wo wins drinks!'), tr('Play'))],
		[Utils.BaseField.new(tr('Choose with whoom you drink 2?'), tr('Drink'))],
		[
			Utils.BaseField.new(tr('Drink 1 and give 3'), tr('Optional')),
			Utils.ChanceField.new(tr('Draw a card'), tr('Chance'))
		],
		[Utils.ThrowDiceField.new(tr('Throw a dice and drink that many times!'), tr('Drink'))],
		[Utils.BaseField.new(tr('Sobering time.'), tr('Lame'))],
		[Utils.MoveField.new(tr('Go back to your previous place'), tr('Back'), 0)],
		[Utils.BaseField.new(tr('Drink 2 with player closest to start. This applies in both directions.'), tr('Drink'))],
		[Utils.MoveStartField.new(tr('Back to beginning'), tr('Start'))],
		[Utils.BaseField.new(tr('Two players closest to start drink!'), tr('Drink'))],
		[Utils.BaseField.new(tr('Give 10 to whoever you want!'), tr('Drink'))],
	]

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files
	
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
