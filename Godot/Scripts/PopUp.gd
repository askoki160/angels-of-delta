extends RichTextLabel

var fields = ['Prvo polje', 'Drugo', 'Trece', '4', '5', '6', '7']
var idx = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_bbcode(fields[idx])
	set_visible_characters(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
