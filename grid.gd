class_name Grid
extends Reference


var max_possible_solutions: int
var all_possible_solutions: BitSet
var bit_mask: BitMask
var count_of_true_cells: int = 0
var count_of_false_cells: int = 0

var _cat_size: int
var _math: Math = load("res://math.gd").new()
var _is_solved: bool = false
var _is_solvable: bool = true
var _grid_cells: Array = []


func _init(my_cat_size: int, my_bit_mask: BitMask) -> void:
	_cat_size = my_cat_size
	_grid_cells.resize(_cat_size)
	for i in range(_cat_size):
		_grid_cells[i] = []
		_grid_cells[i].resize(_cat_size)
	bit_mask = my_bit_mask
	max_possible_solutions = _math.factorial(_cat_size)
	all_possible_solutions = BitSet.new(max_possible_solutions)
	all_possible_solutions.set_in_range(0, max_possible_solutions, true)


func merge_possible_solutions_from_grid_trio(calculated_possible_solutions: BitSet) -> void:
	all_possible_solutions.bitwise_and(calculated_possible_solutions)
	_update_grid_cells()

func is_solved() -> bool:
	return _is_solved

func is_solvable() -> bool:
	return _is_solvable


func eliminate(cat1_elt: int, cat2_elt: int, are_equal: bool) -> void:
	var true_bit_mask: BitSet = bit_mask.get_true_bit_mask(cat1_elt, cat2_elt)
	if(are_equal):
		all_possible_solutions.bitwise_and_not(true_bit_mask)
	else:
		all_possible_solutions.bitwise_and(true_bit_mask)
	_update_solved_status()
	_update_grid_cells()


func get_row_str(row: int) -> String:
	_update_grid_cells()
	var row_str: String = ""
	for col in range(_cat_size):
		match _grid_cells[row][col]:
			null:
				row_str += "?"
			true:
				row_str += "O"
			false:
				row_str += "X"
			"*":
				row_str += "*"
	return row_str


func _update_solved_status() -> void:
	var bit: int = all_possible_solutions.next_set_bit(0)
	if bit == -1:
		_is_solvable = false
		push_error("No solution!")
	elif all_possible_solutions.next_set_bit(bit) == -1:
		_is_solved = true


func _update_grid_cells() -> void:
	count_of_true_cells = 0
	count_of_false_cells = 0
	for row in range(_cat_size):
		for col in range(_cat_size):
			var true_bit_mask: BitSet = bit_mask.get_true_bit_mask(row, col)
			var false_bit_mask: BitSet = bit_mask.get_false_bit_mask(row, col)
			var some_true: bool = all_possible_solutions.bitwise_intersects(true_bit_mask)
			var some_false: bool = all_possible_solutions.bitwise_intersects(false_bit_mask)
			if some_true and some_false:
				_grid_cells[row][col] = null
			elif some_true:
				_grid_cells[row][col] = true
				count_of_true_cells += 1
			elif some_false:
				_grid_cells[row][col] = false
				count_of_false_cells += 1
			else:
				_grid_cells[row][col] = "*"
	_is_solved = (count_of_true_cells == _cat_size)


func _to_string() -> String:
	var ret_str: String = ""
	for row in range(_cat_size):
		ret_str += get_row_str(row) + "\n"
	return ret_str
