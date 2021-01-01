extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var category_count: int = 3
	var category_size: int = 5
	var lp = LogicGridPuzzle.new(category_count, category_size)
	for i in range(category_size - 2):
		#lp.eliminate_possible_solutions(0, 0, category_count - 1, i, true)
		#lp.eliminate_possible_solutions(0, 1, category_count - 1, i, true)
		#lp.eliminate_possible_solutions(0, 0, category_count - 2, category_size - i - 1, true)
		lp.eliminate_possible_solutions(0, 1, category_count - 2, category_size - i - 1, true)
		
	lp.print_puzzle()
	var x = BitSet.new(77)
	x.set_at_index(0, true)
	x.set_at_index(75, true)
	print(x.to_string())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
