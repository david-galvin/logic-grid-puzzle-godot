class_name Grid
extends Reference


const GridCellState = preload("res://grid_cell_state.gd")

var max_possible_solutions: int
var solutions_bitset: BitSet
var count_of_true_cells: int = 0
var count_of_false_cells: int = 0
var cat1: int
var cat2: int

var _bit_mask: BitMask
var _dimension: int # the number of rows, also the number of columns
var _math: Math = load("res://math.gd").new()
var _is_solved: bool = false
var _is_solvable: bool = true
var _grid_cell_matrix: Array = []
var _unsolved_cells: Array = []


func _init(my_dimension: int, my_bit_mask: BitMask, my_cat1 := 0, my_cat2 := 0) -> void:
	randomize()
	cat1 = my_cat1
	cat2 = my_cat2
	_dimension = my_dimension
	_grid_cell_matrix.resize(_dimension)
	for row in range(_dimension):
		_grid_cell_matrix[row] = []
		_grid_cell_matrix[row].resize(_dimension)
		for col in range(_dimension):
			_grid_cell_matrix[row][col] = GridCellState.UNKNOWN
			_unsolved_cells.append([row, col])
	_bit_mask = my_bit_mask
	max_possible_solutions = _math.factorial(_dimension)
	solutions_bitset = BitSet.new(max_possible_solutions)
	solutions_bitset.set_in_range(0, max_possible_solutions, true)


#TODO: Implement a return class for this
func get_random_unsolved_cell_coordinates() -> Array:
	if _unsolved_cells.size() == 0:
		push_error("There are no unsolved cells")
		return []
	var rand_index: int = randi() % _unsolved_cells.size()
	var coords: Array = _unsolved_cells[rand_index]
	var row: int = coords[0]
	var col: int = coords[1]
	if not _grid_cell_matrix[row][col] == GridCellState.UNKNOWN:
		_unsolved_cells.remove(rand_index)
		return get_random_unsolved_cell_coordinates()
	else:
		return coords


func read_cell(row: int, col: int):
	match _grid_cell_matrix[row][col]:
		GridCellState.UNKNOWN:
			return GridCellState.UNKNOWN
		GridCellState.FALSE:
			return GridCellState.FALSE
		GridCellState.TRUE:
			return GridCellState.TRUE
		GridCellState.UNSOLVABLE:
			return GridCellState.UNSOLVABLE


func merge_solutions_from_grid_trio(calculated_possible_solutions: BitSet) -> void:
	solutions_bitset.bitwise_and(calculated_possible_solutions)
	_update_solved_status()
	_update_grid_cell_matrix()


func is_solved() -> bool:
	return _is_solved


func is_solvable() -> bool:
	return _is_solvable


func set_cell(row: int, col: int, are_equal: bool) -> void:
	var true_bit_mask: BitSet = _bit_mask.get_true_bit_mask(row, col)
	if(are_equal):
		solutions_bitset.bitwise_and(true_bit_mask)
	else:
		solutions_bitset.bitwise_and_not(true_bit_mask)
	_update_solved_status()
	_update_grid_cell_matrix()


func get_row_str(row: int) -> String:
	_update_grid_cell_matrix()
	var row_str: String = ""
	for col in range(_dimension):
		match _grid_cell_matrix[row][col]:
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
	var bit: int = solutions_bitset.next_set_bit(0)
	if bit == -1:
		_is_solvable = false
	elif solutions_bitset.next_set_bit(bit) == -1:
		_is_solved = true


func _update_grid_cell_matrix() -> void:
	count_of_true_cells = 0
	count_of_false_cells = 0
	for row in range(_dimension):
		for col in range(_dimension):
			var true_bit_mask: BitSet = _bit_mask.get_true_bit_mask(row, col)
			var false_bit_mask: BitSet = _bit_mask.get_false_bit_mask(row, col)
			var some_true: bool = solutions_bitset.bitwise_intersects(true_bit_mask)
			var some_false: bool = solutions_bitset.bitwise_intersects(false_bit_mask)
			if some_true and some_false:
				_grid_cell_matrix[row][col] = GridCellState.UNKNOWN
			elif some_true:
				_grid_cell_matrix[row][col] = GridCellState.TRUE
				count_of_true_cells += 1
			elif some_false:
				_grid_cell_matrix[row][col] = GridCellState.FALSE
				count_of_false_cells += 1
			else:
				_grid_cell_matrix[row][col] = GridCellState.UNSOLVABLE
	_is_solved = (count_of_true_cells == _dimension)


func _to_string() -> String:
	var ret_str: String = ""
	for row in range(_dimension):
		ret_str += get_row_str(row) + "\n"
	return ret_str
