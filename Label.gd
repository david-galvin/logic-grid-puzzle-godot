extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var x = 7219428434016260000
var math = load("res://Math.gd").new()
var ans

#var z = Permutation.new(5)

var w = BitSet.new(50)
var r = BitSet.new(50)

#choose(66,33) is 63 bits!

# can handle 20!

# Called when the node enters the scene tree for the first time.
func _ready():
	#math = get_node("res://Math.gd")
	#z.set_rank(3)
	w.set_in_range(5,10,true)
	r.set_in_range(3,8,true)
	w.bitwise_and(r)
	self.set_text(str(w.next_set_bit(5)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
