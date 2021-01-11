class_name LogicGridPuzzle
extends Reference


# A number of terms are abbreviated to avoid long, confusing statements. 
# cat: category, e.g. 'job'
# elt: element, a member of a category, e.g. 'accountant'
#
# Some definitions:
# rank: the rank of a permutation. The ordering is not lexicographic.
# inverse_rank: in conjunction with a rank, the rank that undoes it
# grid: a pair of categories.
const path_to_inverses_file = "permutation_inverses.dat"
const path_to_size_to_perm_matrix = "size_to_perm_matrix.dat"
const max_cat_size = 6

var _rank_to_inverse_rank: Array = []
var _perm_rank_matrix: Array
var _cat_count: int
var _cat_size: int
var _grids: Array = []
var _unsolved_grids: Array = []
var _timer = TimerDict.new()


func _init(my_cat_count: int, my_cat_size: int) -> void:
	_cat_count = my_cat_count
	_cat_size = my_cat_size
	randomize()
	_grids = _build_grids()
	_set_rank_to_inverse_rank()
	_set_perm_rank_matrix()


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
		cat2: int, elt2: int, target_state: bool) -> void:
	_timer.start_timer("set_grid_cell")
	var grid: Grid = _get_grid(cat1, cat2)
	if grid.is_solved():
		push_error("Entering a move in a solved grid!")
	grid.set_cell(elt1, elt2, target_state)
	_scan_puzzle_solutions_for_implied_information() 
	_timer.end_timer("set_grid_cell")


func apply_move(move: Move) -> void:
	set_grid_cell(move.cat1, move.elt1, move.cat2, move.elt2, move.target_state)


# This is only used for testing.
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


func print_times():
	print(str(_timer))


func _set_rank_to_inverse_rank():
	var file = File.new()
	if _cat_size in range(2,8) and file.file_exists(path_to_inverses_file):
		file.open(path_to_inverses_file, File.READ)
		_rank_to_inverse_rank = file.get_var(true)[_cat_size]
		file.close()
	else:
		push_error("_rank_to_inverse_rank should be loaded from a file")
		_rank_to_inverse_rank = PermutationTools.get_inverse_rank_array(_cat_size)


func _set_perm_rank_matrix():
	var file = File.new()
	if _cat_size in range(2,7) and file.file_exists(path_to_size_to_perm_matrix):
		file.open(path_to_size_to_perm_matrix, File.READ)
		_perm_rank_matrix = file.get_var(true)[_cat_size]
		file.close()
	else:
		push_error("_perm_rank_matrix should be loaded from a file")
		_perm_rank_matrix = PermutationTools.get_perm_rank_matrix(_cat_size)


func _scan_puzzle_get_grids_to_permute() -> Array:
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
		
	return grids_to_permute


func scan_puzzle_get_ordered_list_of_operations(grids_to_permute: Array) -> Array:
	var cat_to_solved_grids: Array = []
	var num_grids_in_solution = Math.choose(grids_to_permute.size(), 2) + grids_to_permute.size()
	var solved_grid_ids: Dictionary = {}
	
	cat_to_solved_grids.resize(_cat_count)
	for i in range(_cat_count):
		cat_to_solved_grids[i] = []
	
	for grid in grids_to_permute:
		cat_to_solved_grids[grid.cat1].append([grid, grid.cat2])
		cat_to_solved_grids[grid.cat2].append([grid, grid.cat1])
		solved_grid_ids[grid.id] = true
		
	var operations: Array = []
	
	var cat: int = 0
	var sanity_count = 0
	var grid1: Grid
	var grid2: Grid
	var grid3: Grid
	var grid3_cat1: int
	var grid3_cat2: int
	var added_any_grids: bool = true
	while (solved_grid_ids.size() < num_grids_in_solution) and ((not cat == 0) or added_any_grids):
		sanity_count += 1
		if sanity_count >= 20:
			push_error("We shouldn't pass through this loop so many times")
			return []
		cat = (cat + 1) % _cat_count
		if cat == 0:
			added_any_grids = false
		if cat_to_solved_grids[cat].size() >= 2:
			for i in range(cat_to_solved_grids[cat].size() - 1):
				grid1 = cat_to_solved_grids[cat][i][0]
				grid3_cat1 = cat_to_solved_grids[cat][i][1]
				for j in range(i+1, cat_to_solved_grids[cat].size()):
					grid2 = cat_to_solved_grids[cat][j][0]
					grid3_cat2 = cat_to_solved_grids[cat][j][1]
					grid3 = _get_grid(grid3_cat1, grid3_cat2)
					if not solved_grid_ids.has(grid3.id):
						solved_grid_ids[grid3.id] = true
						cat_to_solved_grids[grid3.cat1].append([grid3, grid3.cat2])
						cat_to_solved_grids[grid3.cat2].append([grid3, grid3.cat1])
						added_any_grids = true
						if grid1.cat1 == grid2.cat1:
							if grid1.cat2 < grid2.cat2:
								operations.append(ScanOperation.new(grid1.id, false, grid2.id, true, grid3.id))
							else:
								operations.append(ScanOperation.new(grid2.id, false, grid1.id, true, grid3.id))
						elif grid1.cat2 == grid2.cat2:
							if grid1.cat1 > grid2.cat1:
								operations.append(ScanOperation.new(grid2.id, true, grid1.id, false, grid3.id))
							else:
								operations.append(ScanOperation.new(grid1.id, true, grid2.id, false, grid3.id))
						else:
							if grid1.cat1 == grid2.cat2:
								operations.append(ScanOperation.new(grid1.id, false, grid2.id, false, grid3.id))
							else:
								operations.append(ScanOperation.new(grid2.id, false, grid1.id, false, grid3.id))
	return operations


func _scan_puzzle_solutions_for_implied_information() -> void:
	var count_of_data_cells: int = 0
	var num_grids_with_data: int = 0
	for grid in _grids:
		count_of_data_cells += grid.count_of_false_cells
		count_of_data_cells += grid.count_of_true_cells
		num_grids_with_data += 1
	if num_grids_with_data < 2 or count_of_data_cells < _cat_size:
		return
	
	var grids_to_permute: Array = _scan_puzzle_get_grids_to_permute()
	var operations: Array = scan_puzzle_get_ordered_list_of_operations(grids_to_permute)

	if operations.size() == 0:
		return

	# we'll use the same indexing for the solution as for the grids.
	var grid_solutions_bitsets: Array = []
	for _i in _grids.size():
		grid_solutions_bitsets.append(BitSet.new(Math.factorial(_cat_size)))

	var count_of_solutions_to_explore: int = 1
	for grid in grids_to_permute:
		count_of_solutions_to_explore *= grid.solutions_bitset.cardinality()

	if count_of_solutions_to_explore > 50000:
		return

	_timer.start_timer("scanner: runs_past_thresholds")
	_timer.end_timer("scanner: runs_past_thresholds")

	var grid_ids_with_information: Dictionary = {}
	var grids_to_permute_solution_ranks_matrix: Array = []
	for grid in grids_to_permute:
		grids_to_permute_solution_ranks_matrix.append(grid.get_solution_ranks())
		grid_ids_with_information[grid.id] = true

	var grid_id_to_rank: Array = []
	grid_id_to_rank.resize(_grids.size())
	var grid_solution_index: int
	var temp_solution_index: int
	var grid_id: int
	var grid_id_to_solution_ranks: Array = []
	grid_id_to_solution_ranks.resize(_grids.size())
	for grid in _grids:
		grid_id_to_solution_ranks[grid.id] = grid.get_solution_ranks_dict()

	for puzzle_solution_index in range(count_of_solutions_to_explore):
		temp_solution_index = puzzle_solution_index
		for i in range(grids_to_permute.size()):
			grid_id = grids_to_permute[i].id
			grid_solution_index = temp_solution_index % grids_to_permute[i].solutions_bitset.cardinality()
			grid_id_to_rank[grid_id] = grids_to_permute_solution_ranks_matrix[i][grid_solution_index]
			temp_solution_index /= grids_to_permute[i].solutions_bitset.cardinality()

		var valid_solution: bool = true
		var row_grid_rank: int
		var col_grid_rank: int
		var implied_grid_rank: int
		var is_valid: bool
		for operation in operations:
			row_grid_rank = grid_id_to_rank[operation.row_grid_id]
			if operation.invert_row_perm:
				row_grid_rank = _rank_to_inverse_rank[row_grid_rank]
			col_grid_rank = grid_id_to_rank[operation.col_grid_id]
			if operation.invert_col_perm:
				col_grid_rank = _rank_to_inverse_rank[col_grid_rank]
			implied_grid_rank = _perm_rank_matrix[row_grid_rank][col_grid_rank]
			grid_id_to_rank[operation.implied_grid_id] = implied_grid_rank
			grid_ids_with_information[operation.implied_grid_id] = true
			is_valid = grid_id_to_solution_ranks[operation.implied_grid_id].has(implied_grid_rank)
			if not is_valid:
				valid_solution = false
				break

		if valid_solution:
			for id in _grids.size():
				if not grid_id_to_rank[id] == null:
					grid_solutions_bitsets[id].set_at_index(grid_id_to_rank[id], true)
	
	for id in _grids.size():
		if grid_ids_with_information.has(id):
			_grids[id].merge_solutions_from_grid_trio(grid_solutions_bitsets[id])


func _thread_scanner():
	pass


func _is_valid_cat(cat: int) -> bool:
	return cat in range(_cat_count)


func _is_valid_elt(elt: int) -> bool:
	return elt in range(_cat_size)


func _to_string() -> String:
	var print_str: String = ""
	for row_cat in range(_cat_count - 1, 0, -1):
		print_str += _get_repeated_string("-", (row_cat) * (_cat_size + 1)) + "\n"
		for row_grid in range(_cat_size):
			for col_cat in range(row_cat):
				print_str += "|" + _get_grid(row_cat, col_cat).get_row_str(row_grid)
			print_str += "\n"
	return print_str


func _get_grid(cat1: int, cat2: int) -> Grid:
	return _grids[_get_grid_index(cat1, cat2)]


func _get_grid_index(cat1: int, cat2: int) -> int:
	if cat1 < cat2:
		return _get_grid_index(cat2, cat1)
	return cat1 * (cat1 - 1) / 2 + cat2


func _get_repeated_string(c: String, num_times: int) -> String:
	return c.repeat(num_times)


func _build_grids() -> Array:
	var bit_mask: BitMask = BitMask.new(_cat_size)
	var num_grids: int = (_cat_count - 1) * _cat_count / 2
	_grids.resize(num_grids)
	_unsolved_grids.resize(num_grids)
	for cat1 in range(1, _cat_count):
		for cat2 in range(0, cat1):
			var index: int = _get_grid_index(cat1, cat2)
			_grids[index] = Grid.new(_cat_size, bit_mask, cat1, cat2, index)
			_unsolved_grids[index] = _grids[index]
	return _grids
