extends Reference

class_name LogicGridPuzzle

var category_count: int
var category_size: int
var grids_arr = []
var max_solutions_to_check_per_grid_trio: int = 5000000
var use_permutation_lookup_table: bool
var permutation_ranks = [[]]
var permutation: Permutation
var grid_trio = []
var possible_trio_solutions = []
var rank_to_inverse_rank = []
var math = load("res://Math.gd").new()

func _init(my_category_count: int, my_category_size: int):
	grid_trio.resize(3)
	category_count = my_category_count
	category_size = my_category_size
	grids_arr = _build_grids()
	use_permutation_lookup_table = (category_size <= 7)
	permutation = Permutation.new(category_size)
	rank_to_inverse_rank.resize(math.factorial(category_size))
	_build_inverse_rank_lookup_table()
	if use_permutation_lookup_table:
		permutation_ranks = _build_permutation_lookup_table()
	else:
		permutation_ranks = null
	possible_trio_solutions.resize(3)
	for i in range(3):
		possible_trio_solutions[i] = BitSet.new(math.factorial(category_size))

func _build_permutation_lookup_table():
	var num_solutions_per_grid: int = math.factorial(category_size)
	var implied_solutions = []
	implied_solutions.resize(num_solutions_per_grid)
	for left_grid_rank in range(num_solutions_per_grid):
		implied_solutions[left_grid_rank] = []
		implied_solutions[left_grid_rank].resize(num_solutions_per_grid)
		for right_grid_rank in range(num_solutions_per_grid):
			implied_solutions[left_grid_rank][right_grid_rank] = _calculate_implied_rank(left_grid_rank, right_grid_rank)
	return implied_solutions

func _build_inverse_rank_lookup_table():
	for i in range(rank_to_inverse_rank.size()):
		permutation.set_rank(i)
		permutation.invert_permutation()
		rank_to_inverse_rank[i] = permutation.rank

func get_implied_grid_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	if use_permutation_lookup_table:
		return permutation_ranks[left_grid_rank][right_grid_rank]
	else:
		return _calculate_implied_rank(left_grid_rank, right_grid_rank)

func _calculate_implied_rank(left_grid_rank: int, right_grid_rank: int) -> int:
	permutation.set_rank(left_grid_rank)
	permutation.permute_by_rank(rank_to_inverse_rank[right_grid_rank])
	return permutation.rank

func eliminate_possible_solutions(category1: int, element1: int, category2: int, element2: int, truth_val: bool):
	if category1 < category2:
		_get_grid(category1, category2).eliminate(element1, element2, truth_val)
		#check_all_trios_including_categories(category1, category2)
		check_all_trios()
	elif category2 < category1:
		eliminate_possible_solutions(category2, element2, category1, element1, truth_val)
	else:
		push_error("The categories must be different")
	
#TODO CHECK ALL TRIOS THAT ARE AFFECTED BY THIS MOVE!

func check_all_trios_including_categories(category1: int, category2: int):
	var cat_matches: int = 0
	for row_category in range(0, category_count - 2):
		if [category1, category2].has(row_category):
			cat_matches += 1
		for left_grid_category in range(category_count - 1, row_category + 1, -1):
			if [category1, category2].has(left_grid_category):
				cat_matches += 1 
			grid_trio[0] = _get_grid(row_category, left_grid_category)
			for right_grid_category in range(left_grid_category - 1, row_category, -1):
				if [category1, category2].has(right_grid_category):
					cat_matches += 1 
				if cat_matches == 2:
					grid_trio[1] = _get_grid(row_category, right_grid_category)
					grid_trio[2] = _get_grid(right_grid_category, left_grid_category)
					if _is_grid_trio_worth_checking():
						check_grid_trio()
				
# For all trios of categories A, B, C, check the pairs AB, AC, and BC for  
# implied information about valid solutions
func check_all_trios():
	# note that a logic puzzle has grid rows from 0 to n-1 going down, 
	# but columns n to 1 going left to right.
	for row_category in range(0, category_count - 2):
		for left_grid_category in range(category_count - 1, row_category + 1, -1):
			grid_trio[0] = _get_grid(row_category, left_grid_category)
			for right_grid_category in range(left_grid_category - 1, row_category, -1):
				grid_trio[1] = _get_grid(row_category, right_grid_category)
				grid_trio[2] = _get_grid(right_grid_category, left_grid_category)
				if _is_grid_trio_worth_checking():
					check_grid_trio()

func _is_grid_trio_worth_checking() -> bool:
	var num_solutions_to_check: int = 1
	var num_grids_with_data: int = 0
	for grid in grid_trio:
		num_solutions_to_check *= grid.all_possible_solutions.cardinality()
		if num_solutions_to_check > max_solutions_to_check_per_grid_trio:
			return false
		if grid.all_possible_solutions.cardinality() < grid.max_possible_solutions:
			num_grids_with_data += 1
			if num_grids_with_data >= 2:
				return true
	return false

#TODO SPEED THIS UP!!!!
#MAYBE ID WHICH BITS ARE STILL AMBIGUOUS AND STOP AS SOON AS THEY HAVE
#BOTH A TRUE AND FALSE SOLUTION
#Maybe only keep track of internally possible solutions, then stop
#as soon as we find that all unsolved cells in a grid can't be determined.
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
	left_grid.all_possible_solutions.bitwise_and(left_grid_possible_solutions)
	right_grid.all_possible_solutions.bitwise_and(right_grid_possible_solutions)
	implied_grid.all_possible_solutions.bitwise_and(implied_possible_solutions)

func _is_valid_category(category: int) -> bool:
	if category < 0 || category >= category_count:
		return false
	return true

func _is_valid_element(element: int) -> bool:
	if element < 0 || element >= category_size:
		return false
	return true

func to_string() -> String:
	var print_str: String = ""
	for category1 in range(category_count - 1):
		print_str += _get_repeated_string("-", (category_count - 1 - category1) * (category_size + 1)) + "\n"
		for row in range(category_size):
			for category2 in range(category_count -1, category1, -1):
				print_str += "|" + _get_grid(category1, category2).get_row_str(row)
			print_str += "\n"
	return print_str

func print_puzzle():
	print_debug(to_string())

func _get_grid(category1: int, category2: int) -> Grid:
# warning-ignore:integer_division
		var index: int =  grids_arr.size() - (category_count - 1 - category1) * (category_count - category1) / 2 + (category_count - category2 - 1);
		return grids_arr[index]

func _get_repeated_string(c: String, num_times: int) -> String:
	return c.repeat(num_times)

func _build_grids():
	var bit_mask: BitMask = BitMask.new(category_size)
# warning-ignore:integer_division
	var num_grids: int = (category_count - 1) * category_count / 2
	grids_arr.resize(num_grids)
	for i in range(num_grids):
		grids_arr[i] = Grid.new(category_size, bit_mask)
	return grids_arr














