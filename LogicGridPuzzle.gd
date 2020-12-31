extends Node

class_name LogicGridPuzzle

var category_count: int
var category_size: int
var grids_arr = []
var max_solutions_to_check_per_grid_trio: int = 5000000
var use_permutation_lookup_table: bool
var permutation_ranks = [[]]
var permutation: Permutation
var grid_trio = [].resize(3)
var possible_trio_solutions = []
var rank_to_inverse_rank = []
var math = load("res://Math.gd").new()

func _init(my_category_count: int, my_category_size: int):
	category_count = my_category_count
	category_size = my_category_size

func _build_permutation_lookup_table():
	var num_solutions_per_grid: int = math.factorial(category_size)
	var implied_solutions = [[]]
	implied_solutions.resize(category_size)
	for left_grid_rank in range(num_solutions_per_grid):
		implied_solutions[left_grid_rank].resize(category_size)
		for right_grid_rank in range(num_solutions_per_grid):
			implied_solutions[left_grid_rank][right_grid_rank] = _calculate_implied_rank(left_grid_rank, right_grid_rank)
	return implied_solutions

func _build_inverse_rank_lookup_table():
	for i in range(rank_to_inverse_rank.size):
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
	elif category2 < category1:
		eliminate_possible_solutions(category2, element2, category1, element1, truth_val)
	else:
		push_error("The categories must be different")

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
	return false

func check_grid_trio():
	pass

func _is_valid_category(category: int) -> bool:
	return false

func _is_valid_element(element: int) -> bool:
	return false

func to_string() -> String:
	return ""

func print_puzzle():
	pass

func _get_grid(category1: int, category2: int) -> Grid:
	return grids_arr[0]

func _get_repeated_string(c: String, num_times: int) -> String:
	return ""

func _build_grids():
	pass














