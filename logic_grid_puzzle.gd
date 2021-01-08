class_name LogicGridPuzzle
extends Reference


# A number of terms are abbreviated to avoid long, confusing statements. 
# cat: category, e.g. 'job'
# elt: element, a member of a category, e.g. 'accountant'
# _perm: permutation
#
# Some definitions:
# rank: the rank of a permutation. The ordering is not lexicographic.
# inverse_rank: in conjunction with a rank, the rank that undoes it
# _implied_perm_matrix: For categories A, B, C, we can use a permutation to
#   represent any solution to the grids formed by all 3 pairs. Any two
#   solutions give us the third. E.g. if A, B and A, C are solved, then B, C
#   is fully determined. This is a double array that takes two perm_ranks as
#   inputs, and returns the perm_rank of the implied pairing.
# grid: a pair of categories.
const path_to_inverses_file = "permutation_inverses.dat"
const max_cat_size = 6

var _implied_perm_matrix: Array
var _perm: Permutation
var _grid_trio_solutions_bitsets: Array = []
var _rank_to_inverse_rank: Array = []
var _cat_count: int
var _cat_size: int
var _grid_trio_false_cells_threshold: int = 0
var _grids: Array = []
var _unsolved_grids: Array = []
var _times: Dictionary = {}


func _init(my_cat_count: int, my_cat_size: int) -> void:
	_times["_init"]  = 0
	_times["is_solved"] = 0
	_times["is_solvable"] = 0
	_times["set_grid_cell"]  = 0
	_times["apply_move"] = 0
	_times["get_random_unsolved_grid"]  = 0
	_times["_build_perm_lookup_table"] = 0
	_times["_build_inverse_rank_lookup_table"]  = 0
	_times["_scan_puzzle_solutions_for_implied_information"]  = 0
	_times["_check_all_trios_including_categories"] = 0
	_times["_check_all_trios_multiple_times"]  = 0
	_times["_calculate_implied_rank"]  = 0
	_times["_is_grid_trio_worth_checking"]  = 0
	_times["_check_grid_trio"]  = 0
	_times["_get_implied_grid_rank"] = 0
	_times["_to_string"] = 0
	_times["_get_grid_index"] = 0
	_times["_build_grids"]  = 0
	var _time = OS.get_ticks_msec()
	_cat_count = my_cat_count
	_cat_size = my_cat_size
	if _cat_size > max_cat_size:
		push_error("We can only handle categories of up to 6 elements.")
		return
	randomize()
	_grids = _build_grids()
	# The minimum number of false cells before a grid trio can yield
	# sufficient extra information to eliminate further cells
	_grid_trio_false_cells_threshold = _cat_size
	_perm = Permutation.new(_cat_size)
	var file = File.new()
	if _cat_size in range(2,8) and file.file_exists(path_to_inverses_file):
		file.open(path_to_inverses_file, File.READ)
		_rank_to_inverse_rank = file.get_var(true)[_cat_size]
		file.close()
	else:
		push_error("_rank_to_inverse_rank should be loaded from a file")
		_rank_to_inverse_rank.resize(Math.factorial(_cat_size))
		_build_inverse_rank_lookup_table()
		
	_implied_perm_matrix = _build_perm_lookup_table()
	_grid_trio_solutions_bitsets.resize(3)
	for i in range(3):
		_grid_trio_solutions_bitsets[i] = BitSet.new(Math.factorial(_cat_size))
	_times["_init"] += OS.get_ticks_msec() - _time


func print_times():
	print(str(_times))

func is_solved() -> bool:
	var _time = OS.get_ticks_msec()
	for grid in _grids:
		if grid.is_solved() == false:
			_times["is_solved"] += OS.get_ticks_msec() - _time
			return false
	_times["is_solved"] += OS.get_ticks_msec() - _time
	return true


func is_solvable() -> bool:
	var _time = OS.get_ticks_msec()
	for grid in _grids:
		if not grid.is_solvable():
			_times["is_solvable"] += OS.get_ticks_msec() - _time
			return false
	_times["is_solvable"] += OS.get_ticks_msec() - _time
	return true


func read_grid_cell(cat1: int, elt1: int, cat2: int, elt2: int):
	return _get_grid(cat1, cat2).read_cell(elt1, elt2)


func set_grid_cell(cat1: int, elt1: int, \
		cat2: int, elt2: int, target_state: bool) -> void:
	var _time = OS.get_ticks_msec()
	var grid: Grid = _get_grid(cat1, cat2)
	if grid.is_solved():
		push_error("Entering a move in a solved grid!")
	grid.set_cell(elt1, elt2, target_state)
	#_check_all_trios_including_categories(cat1, cat2)
	_check_all_trios_multiple_times(2)
	_times["set_grid_cell"] += OS.get_ticks_msec() - _time


func apply_move(move: Move) -> void:
	var _time = OS.get_ticks_msec()
	set_grid_cell(move.cat1, move.elt1, move.cat2, move.elt2, move.target_state)
	_times["apply_move"] += OS.get_ticks_msec() - _time


# This is only used for testing.
func get_random_unsolved_grid() -> Grid:
	var _time = OS.get_ticks_msec()
	if _unsolved_grids.size() == 0:
		push_error("There are no unsolved grids")
		print(self)
		_times["get_random_unsolved_grid"] += OS.get_ticks_msec() - _time
		return null
	var rand_index: int = randi() % _unsolved_grids.size()
	var rand_grid: Grid = _unsolved_grids[rand_index]
	if rand_grid.is_solved():
		_unsolved_grids.remove(rand_index)
		_times["get_random_unsolved_grid"] += OS.get_ticks_msec() - _time
		return get_random_unsolved_grid()
	else:
		_times["get_random_unsolved_grid"] += OS.get_ticks_msec() - _time
		return rand_grid


func _build_perm_lookup_table() -> Array:
	var _time = OS.get_ticks_msec()
	var num_solutions_per_grid: int = Math.factorial(_cat_size)
	var implied_solutions: Array = []
	implied_solutions.resize(num_solutions_per_grid)
	for left_grid_rank in range(num_solutions_per_grid):
		implied_solutions[left_grid_rank] = []
		implied_solutions[left_grid_rank].resize(num_solutions_per_grid)
	_times["_build_perm_lookup_table"] += OS.get_ticks_msec() - _time
	return implied_solutions


func _build_inverse_rank_lookup_table() -> void:
	var _time = OS.get_ticks_msec()
	push_error("This method should not be called.")
	for i in range(_rank_to_inverse_rank.size()):
		_perm.set_rank(i)
		_perm.invert()
		_rank_to_inverse_rank[i] = _perm.rank
	_times["_build_inverse_rank_lookup_table"] += OS.get_ticks_msec() - _time


# TODO: Convert the _check_trios code to check larger sets of categories as
# information can sometimes only be discovered this way. E.g. in a 4x3 puzzle,
# with categories A, B, C, D, we can have X's in the grid (is not) for:
# (A0, B0), (A0, C0), (A0, D0), (B0, D0), and (C0, D0). Then every solution 
# must have and 'O' for (B0, C0). I.e. B0 = C0. Why? Because:
# A0 and D0 not being B0 means they're collectively B1 & B2.
# A0 and D0 not being C0 means they're collectively C1 & C2.
# Thus B1 & B2 are collectively C1 & C2. We don't know which is which, but
# we know B0 must equal C0.

func _scan_puzzle_get_grids_to_permute() -> Array:
	var _time = OS.get_ticks_msec()
	var copy_of_grids: Array = _grids.duplicate()
	var grids_to_permute: Array = []
	
	# Here we find an MST where we consider categories as vertices and grids
	# as edges. We do this to avoid including redundant grids.
	copy_of_grids.sort_custom(GridSorter, "sort_by_cardinality")
	var sorted_edges: Array = []
	for grid in copy_of_grids:
		sorted_edges.append([grid.cat1, grid.cat2])
	var mst_edges: Array = Math.get_mst_edges(_cat_count, sorted_edges)
	
	# Add all grids with any information
	for edge in mst_edges:
		var grid: Grid = _get_grid(edge[0], edge[1])
		if grid.solutions_bitset.cardinality() == grid.max_possible_solutions:
			break 
		grids_to_permute.append(_get_grid(edge[0], edge[1]))
		
	_times["_scan_puzzle_get_grids_to_permute"] += OS.get_ticks_msec() - _time
	return grids_to_permute


func _scan_puzzle_get_ordered_list_of_operations(grids_to_permute: Array) -> Array:
	var operations: Array = []
	var left_grid: Grid
	var right_grid: Grid
	var lower_grid: Grid 
	var additional_solved_grids: Array = []
	for i in range(grids_to_permute.size() - 1):
		for j in range(i + 1, grids_to_permute.size()):
			var grid1: Grid = grids_to_permute[i]
			var grid2: Grid = grids_to_permute[j]
			var implied_grid_index: int
	
			if grid1.cat1 == grid2.cat1:
				if grid1.cat2 < grid2.cat2:
					left_grid = grid1
					right_grid = grid2
				else:
					left_grid = grid2
					right_grid = grid1
				implied_grid_index = 2
				lower_grid = _get_grid(right_grid.cat2, left_grid.cat1)
				additional_solved_grids.append(lower_grid)
			elif grid1.cat2 == grid2.cat2:
				if grid1.cat1 > grid2.cat1:
					left_grid = grid1
					lower_grid = grid2
				else:
					left_grid = grid2
					lower_grid = grid1
				right_grid = _get_grid(left_grid.cat1, lower_grid.cat1)
				additional_solved_grids.append(right_grid)
				implied_grid_index = 1
			elif grid1.cat1 == grid2.cat2 || grid1.cat2 == grid2.cat1:
				if grid1.cat1 > grid2.cat1:
					right_grid = grid1
					lower_grid = grid2
				else:
					right_grid = grid2
					lower_grid = grid1
				implied_grid_index = 0
				left_grid = _get_grid(right_grid.cat1, lower_grid.cat2)
				additional_solved_grids.append(left_grid)
			operations.append([left_grid, right_grid, lower_grid, implied_grid_index])
			
	return operations
	

func _scan_puzzle_solutions_for_implied_information() -> void:
	var _time = OS.get_ticks_msec()
	
	var grids_to_permute: Array = _scan_puzzle_get_grids_to_permute()
	
	# we'll use the same indexing for the solution as for the grids.
	var grid_solutions_bitsets: Array = []
	for _i in _grids.size():
		grid_solutions_bitsets.append(BitSet.new(Math.factorial(_cat_size)))
	
	var count_of_solutions_to_explore: int = 1
	for grid in grids_to_permute:
		count_of_solutions_to_explore *= grid.solutions_bitset.cardinality
	
	# TO DO:
	# We need to pre-compute:
	# 1) The pairs of grids in grids_to_permute to compare, the associated grid,
	#    and the combination of permutations that gets us the associated grid's rank.
	# 2) We will often need to use the ranks of implied grids to calculate other
	#    implied grids. We can compute this and the permutations in advance as well. 
	#
	# Use this precomputed data as follows:
	# 3) For every combination of valid ranks among grids_to_permute:
	#      For every pair of grids in our precomputed set, in our precomputed order:
	#        Use our precomputed pair of permutations to find and set the rank of the third grid.
	# 4) Now knowing the current rank of all grids, mark the associated bitset bit as true
	#    if the solution is valid for all grids. Do not mark as false regardless.
	# 5) At the end of this, A grid.rank with no valid solution will be marked false.
	
	# Need to store an array with:
	# 3 grid indices, 
	
	var operations: Array
	var grids_to_permute_solution_ranks_matrix: Array = []
	for grid in grids_to_permute:
		grids_to_permute_solution_ranks_matrix.append(grid.get_solution_ranks())
	
	var ranks_under_consideration: Array = []
	ranks_under_consideration.resize(grids_to_permute.size())
	var grid_solution_index: int
	var temp_solution_index: int
	for puzzle_solution_index in range(count_of_solutions_to_explore):
		temp_solution_index = puzzle_solution_index
		for i in range(grids_to_permute.size()):
			grid_solution_index = temp_solution_index % grids_to_permute[i].solutions_bitset.cardinality
			ranks_under_consideration[i] = grids_to_permute_solution_ranks_matrix[i][grid_solution_index]
			temp_solution_index /= grids_to_permute[i].solutions_bitset.cardinality
		
		operations = _scan_puzzle_get_ordered_list_of_operations(grids_to_permute)

			
	_times["_scan_puzzle_solutions_for_implied_information"] += OS.get_ticks_msec() - _time
	
	# TO DO: The grids in grids_to_permute are the minimum set of grids with
	# the minimum solutions to check that collectively determine the rest of
	# the puzzle. To extract this information, we need to check every pairwise
	# combination of every solution
	

func _check_all_trios_including_categories(cat1: int, cat2: int) -> void:
	var _time = OS.get_ticks_msec()
	for cat3 in range(_cat_count):
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
	_times["_check_all_trios_including_categories"] += OS.get_ticks_msec() - _time


#Dumb version checks all grid trios multiple times
func _check_all_trios_multiple_times(var num_times: int = 1) -> void:
	var _time = OS.get_ticks_msec()
	for _i in range(num_times):
		for cat1 in range(_cat_count - 2):
			for cat2 in range(cat1 + 1, _cat_count - 1):
				for cat3 in range(cat2 + 1, _cat_count):
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
	_times["_check_all_trios_multiple_times"] += OS.get_ticks_msec() - _time


func _calculate_implied_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	var _time = OS.get_ticks_msec()
	_perm.set_rank(left_grid_rank)
	_perm.permute_by_rank(_rank_to_inverse_rank[right_grid_rank])
	_times["_calculate_implied_rank"] += OS.get_ticks_msec() - _time
	return _perm.rank


func _is_grid_trio_worth_checking(_grid_trio) -> bool:
	var _time = OS.get_ticks_msec()
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
			_times["_is_grid_trio_worth_checking"] += OS.get_ticks_msec() - _time
			return true
	_times["_is_grid_trio_worth_checking"] += OS.get_ticks_msec() - _time
	return false


func _check_grid_trio(_grid_trio) -> void:
	var _time = OS.get_ticks_msec()
	var left_grid: Grid = _grid_trio[0]
	var right_grid: Grid = _grid_trio[1]
	var implied_grid: Grid = _grid_trio[2]
	for i in range(_grid_trio_solutions_bitsets.size()):
		_grid_trio_solutions_bitsets[i].clear()
	var left_grid_solutions_bitset: BitSet = _grid_trio_solutions_bitsets[0]
	var right_grid_solutions_bitset: BitSet = _grid_trio_solutions_bitsets[1]
	var implied_grid_solutions_bitset: BitSet = _grid_trio_solutions_bitsets[2]
	
	# Check all valid permutation rank combinations of the left and right grids
	var left_grid_rank: int = left_grid.solutions_bitset.next_set_bit(0)
	var right_grid_rank: int = right_grid.solutions_bitset.next_set_bit(0)
	while left_grid_rank >= 0 and left_grid_rank < left_grid.max_possible_solutions:
		while right_grid_rank >= 0 and right_grid_rank < right_grid.max_possible_solutions:
			var implied_grid_rank: int = _get_implied_grid_rank(left_grid_rank, right_grid_rank)
			if implied_grid.solutions_bitset.get_at_index(implied_grid_rank):
				left_grid_solutions_bitset.set_at_index(left_grid_rank, true)
				right_grid_solutions_bitset.set_at_index(right_grid_rank, true)
				implied_grid_solutions_bitset.set_at_index(implied_grid_rank, true)
			if right_grid_rank + 1 >= right_grid.max_possible_solutions:
				right_grid_rank = -1
			else:
				right_grid_rank = right_grid.solutions_bitset.next_set_bit(right_grid_rank + 1)
		if left_grid_rank + 1 >= left_grid.max_possible_solutions:
			left_grid_rank = -1
		else:
			left_grid_rank = left_grid.solutions_bitset.next_set_bit(left_grid_rank + 1)
			right_grid_rank = right_grid.solutions_bitset.next_set_bit(0)
	left_grid.merge_solutions_from_grid_trio(left_grid_solutions_bitset)
	right_grid.merge_solutions_from_grid_trio(right_grid_solutions_bitset)
	implied_grid.merge_solutions_from_grid_trio(implied_grid_solutions_bitset)
	_times["_check_grid_trio"] += OS.get_ticks_msec() - _time


# For categories A, B, C, and the three grids formed by the three ways of pairing
# these up, a solution to any two grids determines a solution to the thirds.
# Two of these will always be in the same row of the puzzle. Given the permutation
# ranks of the solutions of the two in the same row, this gives the permutation
# rank of the third.
func _get_implied_grid_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	var _time = OS.get_ticks_msec()
	if _implied_perm_matrix[left_grid_rank][right_grid_rank] == null:
		_implied_perm_matrix[left_grid_rank][right_grid_rank] = _calculate_implied_rank(left_grid_rank, right_grid_rank)
	_times["_get_implied_grid_rank"] += OS.get_ticks_msec() - _time
	return _implied_perm_matrix[left_grid_rank][right_grid_rank]


func _is_valid_cat(cat: int) -> bool:
	if cat < 0 or cat >= _cat_count:
		return false
	return true


func _is_valid_elt(elt: int) -> bool:
	if elt < 0 or elt >= _cat_size:
		return false
	return true


func _to_string() -> String:
	var _time = OS.get_ticks_msec()
	var print_str: String = ""
	for row_cat in range(_cat_count - 1, 0, -1):
		print_str += _get_repeated_string("-", (row_cat) * (_cat_size + 1)) + "\n"
		for row_grid in range(_cat_size):
			for col_cat in range(row_cat):
				print_str += "|" + _get_grid(row_cat, col_cat).get_row_str(row_grid)
			print_str += "\n"
	_times["_to_string"] += OS.get_ticks_msec() - _time
	return print_str


func _get_grid(cat1: int, cat2: int) -> Grid:
	# indexing is an arbitrary way to get a unique index for every row, col
	# pair. It depends on row_id > col_id
	return _grids[_get_grid_index(cat1, cat2)]


func _get_grid_index(cat1: int, cat2: int) -> int:
	var _time = OS.get_ticks_msec()
	if cat1 < cat2:
		return _get_grid_index(cat2, cat1)
	_times["_get_grid_index"] += OS.get_ticks_msec() - _time
	return cat1 * (cat1 - 1) / 2 + cat2


func _get_repeated_string(c: String, num_times: int) -> String:
	return c.repeat(num_times)


func _build_grids() -> Array:
	var _time = OS.get_ticks_msec()
	var bit_mask: BitMask = BitMask.new(_cat_size)
	var num_grids: int = (_cat_count - 1) * _cat_count / 2
	_grids.resize(num_grids)
	_unsolved_grids.resize(num_grids)
	for cat1 in range(1, _cat_count):
		for cat2 in range(0, cat1):
			var index: int = _get_grid_index(cat1, cat2)
			_grids[index] = Grid.new(_cat_size, bit_mask, cat1, cat2)
			_unsolved_grids[index] = _grids[index]
	_times["_build_grids"] += OS.get_ticks_msec() - _time
	return _grids
