extends Reference

class_name Grid

var category_size: int
var max_possible_solutions: int
var all_possible_solutions: BitSet
var bit_mask: BitMask
var math = load("res://Math.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(my_category_size: int, my_bit_mask: BitMask):
	category_size = my_category_size
	bit_mask = my_bit_mask
	max_possible_solutions = math.factorial(category_size)
	all_possible_solutions = BitSet.new(max_possible_solutions)
	all_possible_solutions.set_in_range(0, max_possible_solutions - 1, true)

func eliminate(category1_elt: int, category2_elt: int, are_equal: bool):
	var true_bit_mask: BitSet = bit_mask.get_true_bit_mask(category1_elt, category2_elt)
	if(are_equal):
		all_possible_solutions.bitwise_and_not(true_bit_mask)
	else:
		all_possible_solutions.bitwise_and(true_bit_mask)

func get_row_str(row: int) -> String:
	var row_str: String = ""
	for col in range(category_size):
		var true_bit_mask: BitSet = bit_mask.get_true_bit_mask(row, col)
		var false_bit_mask: BitSet = bit_mask.get_false_bit_mask(row, col)
		var some_true: bool = all_possible_solutions.bitwise_intersects(true_bit_mask)
		var some_false: bool = all_possible_solutions.bitwise_intersects(false_bit_mask)
		if some_true && some_false:
			row_str += "?"
		elif some_true:
			row_str += "O"
		elif some_false:
			row_str += "X"
		else:
			row_str += "*"
	return row_str

func to_string() -> String:
	var ret_str: String = ""
	for row in range(category_size):
		ret_str += get_row_str(row) + "\n"
	return ret_str

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
