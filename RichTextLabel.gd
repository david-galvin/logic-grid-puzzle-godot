extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_text("This is a test of the length of this damn thing")
	self.add_text(0b10000000000000000000000 as String)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
