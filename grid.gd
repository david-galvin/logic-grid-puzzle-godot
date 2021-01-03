class_name Grid
extends Reference


enum GridCellState {
	TRUE,
	FALSE,
	UNKNOWN,
	UNSOLVABLE
}

var max_possible_solutions: int
var all_possible_solutions: BitSet
var bit_mask: BitMask
var count_of_true_cells: int = 0
var count_of_false_cells: int = 0

var _dimension: int # the number of rows, also the number of columns
var _math: Math = load("res://math.gd").new()
var _is_solved: bool = false
var _is_solvable: bool = true
var _grid_cells: Array = []


func _init(my_dimension: int, my_bit_mask: BitMask) -> void:
	_dimension = my_dimension
	_grid_cells.resize(_dimension)
	for i in range(_dimension):
		_grid_cells[i] = []
		_grid_cells[i].resize(_dimension)
	bit_mask = my_bit_mask
	max_possible_solutions = _math.factorial(_dimension)
	all_possible_solutions = BitSet.new(max_possible_solutions)
	all_possible_solutions.set_in_range(0, max_possible_solutions, true)


func merge_possible_solutions_from_grid_trio(calculated_possible_solutions: BitSet) -> void:
	all_possible_solutions.bitwise_and(calculated_possible_solutions)
	_update_grid_cells()

func is_solved() -> bool:
	return _is_solved

func is_solvable() -> bool:
	return _is_solvable


func eliminate(row_elt: int, col_elt: int, are_equal: bool) -> void:
	var true_bit_mask: BitSet = bit_mask.get_true_bit_mask(row_elt, col_elt)
	if(are_equal):
		all_possible_solutions.bitwise_and_not(true_bit_mask)
	else:
		all_possible_solutions.bitwise_and(true_bit_mask)
	_update_solved_status()
	_update_grid_cells()


func get_row_str(row: int) -> String:
	_update_grid_cells()
	var row_str: String = ""
	for col in range(_dimension):
		match _grid_cells[row][col]:
			GridCellState.UNKNOWN:
				row_str += "?"
			GridCellState.TRUE:
				row_str += "O"
			GridCellState.FALSE:
				row_str += "X"
			GridCellState.UNSOLVABLE:
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
	for row in range(_dimension):
		for col in range(_dimension):
			var true_bit_mask: BitSet = bit_mask.get_true_bit_mask(row, col)
			var false_bit_mask: BitSet = bit_mask.get_false_bit_mask(row, col)
			var some_true: bool = all_possible_solutions.bitwise_intersects(true_bit_mask)
			var some_false: bool = all_possible_solutions.bitwise_intersects(false_bit_mask)
			if some_true and some_false:
				_grid_cells[row][col] = GridCellState.UNKNOWN
			elif some_true:
				_grid_cells[row][col] = GridCellState.TRUE
				count_of_true_cells += 1
			elif some_false:
				_grid_cells[row][col] = GridCellState.FALSE
				count_of_false_cells += 1
			else:
				_grid_cells[row][col] = GridCellState.UNSOLVABLE
	_is_solved = (count_of_true_cells == _dimension)


func _to_string() -> String:
	var ret_str: String = ""
	for row in range(_dimension):
		ret_str += get_row_str(row) + "\n"
	return ret_str
