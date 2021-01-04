class_name LogicGridPuzzle
extends Reference


# A number of terms are abbreviated to avoid long, confusing statements. 
# cat: category, e.g. 'job'
# elt: element, a member of a category, e.g. 'accountant'
# perm: permutation
#
# Some definitions:
# rank: the rank of a permutation. The ordering is not lexicographic.
# inverse_rank: in conjunction with a rank, the rank that undoes it
# implied_perm_ranks: For categories A, B, C, we can use a permutation to
#   represent any solution to the grids formed by all 3 pairs. Any two
#   solutions give us the third. E.g. if A, B and A, C are solved, then B, C
#   is fully determined. This is a double array that takes two perm_ranks as
#   inputs, and returns the perm_rank of the implied pairing.
# grid: a pair of categories.
var cat_count: int
var cat_size: int
var implied_perm_ranks: Array
var perm: Permutation
var grid_trio_solutions_bitsets: Array = []
var rank_to_inverse_rank: Array = []
var math: Math = load("res://math.gd").new()

var _grids: Array = []
var _unsolved_grids: Array = []
var _grid_trio_false_cells_threshold: int = 0


func _init(my_cat_count: int, my_cat_size: int) -> void:
	randomize()
	cat_count = my_cat_count
	cat_size = my_cat_size
	_grids = _build_grids()
	# The minimum number of false cells before a grid trio can yield
	# sufficient extra information to eliminate further cells
	_grid_trio_false_cells_threshold = 4 * (cat_size - 2) + 2
	perm = Permutation.new(cat_size)
	rank_to_inverse_rank.resize(math.factorial(cat_size))
	_build_inverse_rank_lookup_table()
	implied_perm_ranks = _build_perm_lookup_table()
	grid_trio_solutions_bitsets.resize(3)
	for i in range(3):
		grid_trio_solutions_bitsets[i] = BitSet.new(math.factorial(cat_size))


func is_solved() -> bool:
	for grid in _grids:
		if grid.is_solved() == false:
			return false
	return true


func is_solvable() -> bool:
	for grid in _grids:
		if not grid.is_solvable():
			return false
	return true


func read_grid_cell(cat1: int, elt1: int, cat2: int, elt2: int):
	return _get_grid(cat1, cat2).read_cell(elt1, elt2)


func set_grid_cell(cat1: int, elt1: int, \
		cat2: int, elt2: int, truth_val: bool) -> void:
	_get_grid(cat1, cat2).set_cell(elt1, elt2, truth_val)
	_check_all_trios_including_categories(cat1, cat2)


func get_random_unsolved_grid() -> Grid:
	if _unsolved_grids.size() == 0:
		push_error("There are no unsolved grids")
		print(self)
		return null
	var rand_index: int = randi() % _unsolved_grids.size()
	var rand_grid: Grid = _unsolved_grids[rand_index]
	if rand_grid.is_solved():
		_unsolved_grids.remove(rand_index)
		return get_random_unsolved_grid()
	else:
		return rand_grid


func _build_perm_lookup_table() -> Array:
	var num_solutions_per_grid: int = math.factorial(cat_size)
	var implied_solutions: Array = []
	implied_solutions.resize(num_solutions_per_grid)
	for left_grid_rank in range(num_solutions_per_grid):
		implied_solutions[left_grid_rank] = []
		implied_solutions[left_grid_rank].resize(num_solutions_per_grid)
	return implied_solutions


func _build_inverse_rank_lookup_table() -> void:
	for i in range(rank_to_inverse_rank.size()):
		perm.set_rank(i)
		perm.invert_perm()
		rank_to_inverse_rank[i] = perm.rank


func _check_all_trios_including_categories(cat1: int, cat2: int) -> void:
	for cat3 in range(cat_count):
		if ! [cat1, cat2].has(cat3):
			var cat_trio: Array = [cat1, cat2, cat3]
			cat_trio.sort()
			# The order of grids in grid_trio is important. The first two
			# need to be in the same row, with the first to the left of the
			# second. This means they should be in order of category size:
			# (big, small), (big, med), (med, small)
			var _grid_trio: Array = []
			_grid_trio.resize(3)
			_grid_trio[0] = _get_grid(cat_trio[2], cat_trio[0])
			_grid_trio[1] = _get_grid(cat_trio[2], cat_trio[1])
			_grid_trio[2] = _get_grid(cat_trio[1], cat_trio[0])
			if _is_grid_trio_worth_checking(_grid_trio):
				_check_grid_trio(_grid_trio)


func _calculate_implied_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	perm.set_rank(left_grid_rank)
	perm.permute_by_rank(rank_to_inverse_rank[right_grid_rank])
	return perm.rank


func _is_grid_trio_worth_checking(_grid_trio) -> bool:
	var count_of_false_cells_in_trio: int = 0
	var count_of_true_cells_in_trio: int = 0
	var num_grids_with_data: int = 0
	for grid in _grid_trio:
		count_of_false_cells_in_trio += grid.count_of_false_cells
		count_of_false_cells_in_trio += grid.count_of_true_cells
		num_grids_with_data += 1
	if (count_of_false_cells_in_trio >= _grid_trio_false_cells_threshold) or \
			(count_of_true_cells_in_trio >= 1):
		if num_grids_with_data >= 2:
			return true
	return false


func _check_grid_trio(_grid_trio) -> void:
	var left_grid: Grid = _grid_trio[0]
	var right_grid: Grid = _grid_trio[1]
	var implied_grid: Grid = _grid_trio[2]
	var left_grid_rank: int = left_grid.solutions_bitset.next_set_bit(0)
	var right_grid_rank: int = right_grid.solutions_bitset.next_set_bit(0)
	for i in range(grid_trio_solutions_bitsets.size()):
		grid_trio_solutions_bitsets[i].clear()
	var left_grid_solutions_bitset: BitSet = grid_trio_solutions_bitsets[0]
	var right_grid_solutions_bitset: BitSet = grid_trio_solutions_bitsets[1]
	var implied_grid_solutions_bitset: BitSet = grid_trio_solutions_bitsets[2]
	while left_grid_rank >= 0 and left_grid_rank < left_grid.max_possible_solutions - 1:
		while right_grid_rank >= 0 and right_grid_rank < right_grid.max_possible_solutions - 1:
			var implied_grid_rank: int = _get_implied_grid_rank(left_grid_rank, right_grid_rank)
			if implied_grid.solutions_bitset.get_at_index(implied_grid_rank):
				left_grid_solutions_bitset.set_at_index(left_grid_rank, true)
				right_grid_solutions_bitset.set_at_index(right_grid_rank, true)
				implied_grid_solutions_bitset.set_at_index(implied_grid_rank, true)
			right_grid_rank = right_grid.solutions_bitset.next_set_bit(right_grid_rank + 1)
		left_grid_rank = left_grid.solutions_bitset.next_set_bit(left_grid_rank + 1)
		right_grid_rank = right_grid.solutions_bitset.next_set_bit(0)
	left_grid.merge_solutions_from_grid_trio(left_grid_solutions_bitset)
	right_grid.merge_solutions_from_grid_trio(right_grid_solutions_bitset)
	implied_grid.merge_solutions_from_grid_trio(implied_grid_solutions_bitset)


func _get_implied_grid_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	if implied_perm_ranks[left_grid_rank][right_grid_rank] == null:
		implied_perm_ranks[left_grid_rank][right_grid_rank] = _calculate_implied_rank(left_grid_rank, right_grid_rank)
	return implied_perm_ranks[left_grid_rank][right_grid_rank]


func _is_valid_cat(cat: int) -> bool:
	if cat < 0 or cat >= cat_count:
		return false
	return true


func _is_valid_elt(elt: int) -> bool:
	if elt < 0 or elt >= cat_size:
		return false
	return true


func _to_string() -> String:
	var print_str: String = ""
	for row_cat in range(cat_count - 1, 0, -1):
		print_str += _get_repeated_string("-", (row_cat) * (cat_size + 1)) + "\n"
		for row_grid in range(cat_size):
			for col_cat in range(row_cat):
				print_str += "|" + _get_grid(row_cat, col_cat).get_row_str(row_grid)
			print_str += "\n"
	return print_str


func _get_grid(cat1: int, cat2: int) -> Grid:
	# indexing is an arbitrary way to get a unique index for every row, col
	# pair. It depends on row_id > col_id
	return _grids[_get_grid_index(cat1, cat2)]


func _get_grid_index(cat1: int, cat2: int) -> int:
	if cat1 < cat2:
		return _get_grid_index(cat2, cat1)
	return cat1 * (cat1 - 1) / 2 + cat2


func _get_repeated_string(c: String, num_times: int) -> String:
	return c.repeat(num_times)


func _build_grids() -> Array:
	var bit_mask: BitMask = BitMask.new(cat_size)
	var num_grids: int = (cat_count - 1) * cat_count / 2
	_grids.resize(num_grids)
	_unsolved_grids.resize(num_grids)
	for cat1 in range(1, cat_count):
		for cat2 in range(0, cat1):
			var index: int = _get_grid_index(cat1, cat2)
			_grids[index] = Grid.new(cat_size, bit_mask, cat1, cat2)
			_unsolved_grids[index] = _grids[index]
	return _grids
