extends Reference

class_name LogicGridPuzzle

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
#   solutions give us the third. E.g. if A,B and A,C are solved, then B,C
#   is fully determined. This is a double array that takes two perm_ranks as
#   inputs, and returns the perm_rank of the implied pairing.
# grid: a pair of categories.
# grid_trio: 3 grids formed pairwise from 3 categories
var cat_count: int
var cat_size: int
var _grid_arr = []
var implied_perm_ranks
var perm: Permutation
var grid_trio = []
var possible_trio_solutions = []
var rank_to_inverse_rank = []
var math = load("res://Math.gd").new()
var _grid_trio_false_cells_threshold: int = 0

func _init(my_cat_count: int, my_cat_size: int):
	grid_trio.resize(3)
	cat_count = my_cat_count
	cat_size = my_cat_size
	_grid_arr = _build_grids()
	# The minimum number of false cells before a grid trio can yield
	# sufficient extra information to eliminate further cells
	_grid_trio_false_cells_threshold = 4 * (cat_size - 2) + 2
	perm = Permutation.new(cat_size)
	rank_to_inverse_rank.resize(math.factorial(cat_size))
	_build_inverse_rank_lookup_table()
	implied_perm_ranks = _build_perm_lookup_table()
	possible_trio_solutions.resize(3)
	for i in range(3):
		possible_trio_solutions[i] = BitSet.new(math.factorial(cat_size))

func _build_perm_lookup_table():
	var num_solutions_per_grid: int = math.factorial(cat_size)
	var implied_solutions = []
	implied_solutions.resize(num_solutions_per_grid)
	for left_grid_rank in range(num_solutions_per_grid):
		implied_solutions[left_grid_rank] = []
		implied_solutions[left_grid_rank].resize(num_solutions_per_grid)
	return implied_solutions

func _build_inverse_rank_lookup_table():
	for i in range(rank_to_inverse_rank.size()):
		perm.set_rank(i)
		perm.invert_perm()
		rank_to_inverse_rank[i] = perm.rank

func get_implied_grid_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	if implied_perm_ranks[left_grid_rank][right_grid_rank] == null:
		implied_perm_ranks[left_grid_rank][right_grid_rank] = _calculate_implied_rank(left_grid_rank, right_grid_rank)
	return implied_perm_ranks[left_grid_rank][right_grid_rank]

func _calculate_implied_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	perm.set_rank(left_grid_rank)
	perm.permute_by_rank(rank_to_inverse_rank[right_grid_rank])
	return perm.rank

func eliminate_possible_solutions(cat1: int, elt1: int, \
cat2: int, elt2: int, truth_val: bool):
	_get_grid(cat1, cat2).eliminate(elt1, elt2, truth_val)
	check_all_trios_including_categories(cat1, cat2)

func check_all_trios_including_categories(cat1: int, cat2: int):
	for cat3 in range(cat_count):
		if ! [cat1, cat2].has(cat3):
			var cat_trio = [cat1, cat2, cat3]
			cat_trio.sort()
			grid_trio[0] = _get_grid(cat_trio[2], cat_trio[0])
			grid_trio[1] = _get_grid(cat_trio[2], cat_trio[1])
			grid_trio[2] = _get_grid(cat_trio[1], cat_trio[0])
			if _is_grid_trio_worth_checking():
				check_grid_trio()

func _is_grid_trio_worth_checking() -> bool:
	var count_of_false_cells_in_trio: int = 0
	var count_of_true_cells_in_trio: int = 0
	var num_grids_with_data: int = 0
	for grid in grid_trio:
		count_of_false_cells_in_trio += grid.count_of_false_cells
		count_of_false_cells_in_trio += grid.count_of_true_cells
		num_grids_with_data += 1
	if (count_of_false_cells_in_trio >= _grid_trio_false_cells_threshold) || \
	(count_of_true_cells_in_trio >= 1):
		if num_grids_with_data >= 2:
			return true
	return false

func check_grid_trio():
	var left_grid: Grid = grid_trio[0]
	var right_grid: Grid = grid_trio[1]
	var implied_grid: Grid = grid_trio[2]
	var left_grid_rank: int = left_grid.all_possible_solutions.next_set_bit(0)
	var right_grid_rank: int = right_grid.all_possible_solutions.next_set_bit(0)
	for i in range(possible_trio_solutions.size()):
		possible_trio_solutions[i].clear()
	var left_grid_possible_solutions: BitSet = possible_trio_solutions[0]
	var right_grid_possible_solutions: BitSet = possible_trio_solutions[1]
	var implied_possible_solutions: BitSet = possible_trio_solutions[2]
	while left_grid_rank >= 0 && left_grid_rank < left_grid.max_possible_solutions - 1:
		while right_grid_rank >= 0 && right_grid_rank < right_grid.max_possible_solutions - 1:
			var implied_grid_rank: int = get_implied_grid_rank(left_grid_rank, right_grid_rank)
			if implied_grid.all_possible_solutions.get_at_index(implied_grid_rank):
				left_grid_possible_solutions.set_at_index(left_grid_rank, true)
				right_grid_possible_solutions.set_at_index(right_grid_rank, true)
				implied_possible_solutions.set_at_index(implied_grid_rank, true)
			right_grid_rank = right_grid.all_possible_solutions.next_set_bit(right_grid_rank + 1)
		left_grid_rank = left_grid.all_possible_solutions.next_set_bit(left_grid_rank + 1)
		right_grid_rank = right_grid.all_possible_solutions.next_set_bit(0)
	left_grid.merge_possible_solutions_from_grid_trio(left_grid_possible_solutions)
	right_grid.merge_possible_solutions_from_grid_trio(right_grid_possible_solutions)
	implied_grid.merge_possible_solutions_from_grid_trio(implied_possible_solutions)

func _is_valid_cat(cat: int) -> bool:
	if cat < 0 || cat >= cat_count:
		return false
	return true

func _is_valid_elt(elt: int) -> bool:
	if elt < 0 || elt >= cat_size:
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

func print_puzzle():
	print_debug(_to_string())

func _get_grid(cat1: int, cat2: int) -> Grid:
	#indexing is an arbitrary way to get a unique index for every row, col
	#pair. It depends on row_id > col_id
	return _grid_arr[_get_grid_index(cat1, cat2)]

func _get_grid_index(cat1: int, cat2: int) -> int:
	if cat1 < cat2:
		return _get_grid_index(cat2, cat1)
	return cat1 * (cat1 - 1) / 2 + cat2

func _get_repeated_string(c: String, num_times: int) -> String:
	return c.repeat(num_times)

func _build_grids():
	var bit_mask: BitMask = BitMask.new(cat_size)
	var num_grids: int = (cat_count - 1) * cat_count / 2
	_grid_arr.resize(num_grids)
	for i in range(num_grids):
		_grid_arr[i] = Grid.new(cat_size, bit_mask)
	return _grid_arr
