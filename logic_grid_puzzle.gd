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
const PATH_TO_INVERSES_FILE = "permutation_inverses.dat"
const PATH_TO_SIZE_TO_PERM_MATRIX = "size_to_perm_matrix.dat"
const MAX_SOLUTIONS_TO_CHECK = 20_000

var _cat_count: int
var _cat_size: int
var _inverse_ranks: Array = []
var _rank_composition_matrix: Array
var _grids: Array = []
var _unsolved_grids: Array = []
var _size_to_cat_combos_to_is_scanned: Dictionary
var _timer = TimerDict.new()


func _init(my_cat_count: int, my_cat_size: int) -> void:
	_cat_count = my_cat_count
	_cat_size = my_cat_size
	randomize()
	_grids = _build_grids()
	_size_to_cat_combos_to_is_scanned = _get_size_to_cat_combos_to_is_scanned()
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
	if not grid.is_solvable():
		push_error("Puzzle is unsolvable")
	grid.set_cell(elt1, elt2, target_state)
	_recursive_solution_scan_new(cat1, cat2)
	_timer.end_timer("set_grid_cell")


func print_grid_solutions_bitset(cat1: int, cat2: int) -> void:
	print(str(_grids[_get_grid_index(cat1, cat2)].solutions_bitset))


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


func get_times():
	return str(_timer)


func _recursive_solution_scan_new(cat1: int, cat2: int) -> void:
	_set_cat_combos_scanned_to_false()
	var cat_to_is_scanned: Dictionary = _scan_puzzle_solutions_for_implied_information([]) 
	if _cat_count == 3 or _cat_count == cat_to_is_scanned.size():
		return
	_set_cat_combos_scanned_to_true(cat_to_is_scanned.keys())
	var max_cats_to_scan_at_once: int = cat_to_is_scanned.size()
	for size in range(max_cats_to_scan_at_once, 2, -1):
		for cat_combo in _size_to_cat_combos_to_is_scanned[size]:
			if not _size_to_cat_combos_to_is_scanned[size][cat_combo]:
				if cat_combo.has(cat1) and cat_combo.has(cat2):
					cat_to_is_scanned = _scan_puzzle_solutions_for_implied_information(cat_combo)
				_set_cat_combos_scanned_to_true(cat_to_is_scanned.keys())


func _set_rank_to_inverse_rank():
	var file = File.new()
	if _cat_size in range(2,8) and file.file_exists(PATH_TO_INVERSES_FILE):
		file.open(PATH_TO_INVERSES_FILE, File.READ)
		_inverse_ranks = file.get_var(true)[_cat_size]
		file.close()
	else:
		push_error("_inverse_ranks should be loaded from a file")
		_inverse_ranks = PermutationTools.get_inverse_rank_array(_cat_size)


func _set_perm_rank_matrix():
	var file = File.new()
	if _cat_size in range(2,7) and file.file_exists(PATH_TO_SIZE_TO_PERM_MATRIX):
		file.open(PATH_TO_SIZE_TO_PERM_MATRIX, File.READ)
		_rank_composition_matrix = file.get_var(true)[_cat_size]
		file.close()
	else:
		push_error("_rank_composition_matrix should be loaded from a file")
		_rank_composition_matrix = PermutationTools.get_perm_rank_matrix(_cat_size)


func _get_scannable_grids(cats_to_scan: Array = []) -> Array:
	var copy_of_grids: Array 
	
	if cats_to_scan.size() > 0:
		for i in range(cats_to_scan.size() - 1):
			var cat1: int = cats_to_scan[i]
			for j in range(i + 1, cats_to_scan.size()):
				var cat2: int = cats_to_scan[j]
				copy_of_grids.append(_get_grid(cat1, cat2))
	else:
		copy_of_grids = _grids.duplicate()
	
	var scannable_grids: Array = []
	
	# Here we find an MST where we consider categories as vertices and grids
	# as edges. We do this to avoid including redundant grids.
	copy_of_grids.sort_custom(GridSorter, "sort_by_cardinality")
	var sorted_edges: Array = []
	for grid in copy_of_grids:
		sorted_edges.append([grid.cat1, grid.cat2])
	var mst_edges: Array = Math.get_mst_edges(_cat_count, sorted_edges)
	
	# Add all grids with any information
	var total_cardinality: int = 1
	for edge in mst_edges:
		var grid: Grid = _get_grid(edge[0], edge[1])
		total_cardinality *= grid.solutions_bitset.cardinality()
		if total_cardinality > MAX_SOLUTIONS_TO_CHECK:
			break
		if grid.solutions_bitset.cardinality() == grid.max_possible_solutions:
			break 
		scannable_grids.append(_get_grid(edge[0], edge[1]))
		
	return scannable_grids


func get_scan_operations(scannable_grids: Array) -> Array:
	var cat_to_solved_grids: Array = []
	var num_grids_in_solution = Math.choose(scannable_grids.size(), 2) + scannable_grids.size()
	var grid_id_to_is_solved: Dictionary = {}
	
	cat_to_solved_grids.resize(_cat_count)
	for i in range(_cat_count):
		cat_to_solved_grids[i] = []
	
	for grid in scannable_grids:
		cat_to_solved_grids[grid.cat1].append([grid, grid.cat2])
		cat_to_solved_grids[grid.cat2].append([grid, grid.cat1])
		grid_id_to_is_solved[grid.id] = true
		
	var operations: Array = []
	
	var cat: int = 0
	var grid1: Grid
	var grid2: Grid
	var grid3: Grid
	var grid3_cat1: int
	var grid3_cat2: int
	var added_any_grids: bool = true
	while (grid_id_to_is_solved.size() < num_grids_in_solution) and ((not cat == 0) or added_any_grids):
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
					if not grid_id_to_is_solved.has(grid3.id):
						grid_id_to_is_solved[grid3.id] = true
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


func _scan_puzzle_is_a_solution_possible(operations_size: int) -> bool:
	if operations_size == 0:
		return false
	var count_of_data_cells: int = 0
	var num_grids_with_data: int = 0
	for grid in _grids:
		count_of_data_cells += grid.count_of_false_cells
		count_of_data_cells += grid.count_of_true_cells
		num_grids_with_data += 1
	if num_grids_with_data < 2 or count_of_data_cells < _cat_size:
		return false
	return true


func _scan_puzzle_solutions_for_implied_information(cats_to_scan: Array = []) -> Dictionary:
	
	var scannable_grids: Array = _get_scannable_grids(cats_to_scan)
	var operations: Array = get_scan_operations(scannable_grids)
	var number_of_solutions: int = 1
	for grid in scannable_grids:
		number_of_solutions *= grid.solutions_bitset.cardinality()
		
	var cat_to_is_scanned: Dictionary = {}
	if not _scan_puzzle_is_a_solution_possible(operations.size()):
		return cat_to_is_scanned
	
	for grid in scannable_grids:
		cat_to_is_scanned[grid.cat1] = true
		cat_to_is_scanned[grid.cat2] = true

	# we'll use the same indexing for the solution as for the grids.
	var grid_solutions_bitsets: Array = []
	for _i in _grids.size():
		grid_solutions_bitsets.append(BitSet.new(Math.factorial(_cat_size)))

	var grid_id_to_has_data: Dictionary = {}
	var scannable_grids_solutions_ranks_matrix: Array = []
	for grid in scannable_grids:
		scannable_grids_solutions_ranks_matrix.append(grid.get_solution_ranks())
		grid_id_to_has_data[grid.id] = true
	
	var pre_scan_grid_ranks: Array = []
	var post_scan_grid_ranks: Array = []
	pre_scan_grid_ranks.resize(_grids.size())
	post_scan_grid_ranks.resize(_grids.size())
	for grid in _grids:
		post_scan_grid_ranks[grid.id] = {}
		pre_scan_grid_ranks[grid.id] = grid.get_solution_ranks_dict()

	var grid_id_to_rank: Dictionary = {}
	for puzzle_solution_index in range(number_of_solutions):
		var temp_solution_index: int = puzzle_solution_index
		for i in range(scannable_grids.size()):
			var grid_id: int = scannable_grids[i].id
			var grid_solution_index: int = temp_solution_index % scannable_grids[i].solutions_bitset.cardinality()
			grid_id_to_rank[grid_id] = scannable_grids_solutions_ranks_matrix[i][grid_solution_index]
			temp_solution_index /= scannable_grids[i].solutions_bitset.cardinality()

		var row_grid_rank: int
		var col_grid_rank: int
		var implied_grid_rank: int
		var is_valid: bool
		for operation in operations:
			row_grid_rank = grid_id_to_rank[operation.row_grid_id]
			if operation.invert_row_perm:
				row_grid_rank = _inverse_ranks[row_grid_rank]
			col_grid_rank = grid_id_to_rank[operation.col_grid_id]
			if operation.invert_col_perm:
				col_grid_rank = _inverse_ranks[col_grid_rank]
			implied_grid_rank = _rank_composition_matrix[row_grid_rank][col_grid_rank]
			grid_id_to_rank[operation.implied_grid_id] = implied_grid_rank
			grid_id_to_has_data[operation.implied_grid_id] = true
			is_valid = pre_scan_grid_ranks[operation.implied_grid_id].has(implied_grid_rank)
			if not is_valid:
				break
		if is_valid:
			for grid_id in grid_id_to_rank:
				post_scan_grid_ranks[grid_id][grid_id_to_rank[grid_id]] = true
	for grid_id in grid_id_to_rank:
		for rank in post_scan_grid_ranks[grid_id]:
			grid_solutions_bitsets[grid_id].set_at_index(rank, true)
	for grid_id in _grids.size():
		if grid_id_to_has_data.has(grid_id):
			_grids[grid_id].merge_solutions_from_grid_trio(grid_solutions_bitsets[grid_id])
	return cat_to_is_scanned


#func thread_work(start_solution_index: int, stop_solution_index: int, \
#		scannable_grids: Array, operations: Array):
#	var grid_id_to_rank: Dictionary = {}
#	for puzzle_solution_index in range(start_solution_index, stop_solution_index):
#		var temp_solution_index: int = puzzle_solution_index
#		for i in range(scannable_grids.size()):
#			var grid_id: int = scannable_grids[i].id
#			var grid_solution_index: int = temp_solution_index % scannable_grids[i].solutions_bitset.cardinality()
#			grid_id_to_rank[grid_id] = scannable_grids_solutions_ranks_matrix[i][grid_solution_index]
#			temp_solution_index /= scannable_grids[i].solutions_bitset.cardinality()
#
#		var row_grid_rank: int
#		var col_grid_rank: int
#		var implied_grid_rank: int
#		var is_valid: bool
#		for operation in operations:
#			row_grid_rank = grid_id_to_rank[operation.row_grid_id]
#			if operation.invert_row_perm:
#				row_grid_rank = _inverse_ranks[row_grid_rank]
#			col_grid_rank = grid_id_to_rank[operation.col_grid_id]
#			if operation.invert_col_perm:
#				col_grid_rank = _inverse_ranks[col_grid_rank]
#			implied_grid_rank = _rank_composition_matrix[row_grid_rank][col_grid_rank]
#			grid_id_to_rank[operation.implied_grid_id] = implied_grid_rank
#			grid_id_to_has_data[operation.implied_grid_id] = true
#			is_valid = pre_scan_grid_ranks[operation.implied_grid_id].has(implied_grid_rank)
#			if not is_valid:
#				break
#		if is_valid:
#			for grid_id in grid_id_to_rank:
#				post_scan_grid_ranks[grid_id][grid_id_to_rank[grid_id]] = true


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


func _get_size_to_cat_combos_to_is_scanned() -> Dictionary:
	var size_to_cat_combos_to_is_scanned: Dictionary = {}
	for size in range(3, _cat_count):
		size_to_cat_combos_to_is_scanned[size] = {}
		for cat_combo in Math.get_subsets(Array(range(_cat_count)), size):
			size_to_cat_combos_to_is_scanned[size][cat_combo] = false
	return size_to_cat_combos_to_is_scanned


func _set_cat_combos_scanned_to_false() -> void:
	for size in _size_to_cat_combos_to_is_scanned:
		for cat_combo in _size_to_cat_combos_to_is_scanned[size]:
			_size_to_cat_combos_to_is_scanned[size][cat_combo] = false


func _set_cat_combos_scanned_to_true(cats: Array) -> void:
	for size in range(3, cats.size()):
		for cat_combo in Math.get_subsets(Array(range(_cat_count)), size):
			_size_to_cat_combos_to_is_scanned[size][cat_combo] = true
