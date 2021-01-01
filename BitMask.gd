extends Reference

class_name BitMask

var max_possible_solutions_per_grid: int
var true_bit_masks = []
var false_bit_mask: BitSet
var math = load("res://Math.gd").new()
var _category_size: int

func _init(my_category_size: int):
	_category_size = my_category_size
	max_possible_solutions_per_grid = math.factorial(_category_size)
	false_bit_mask = BitSet.new(max_possible_solutions_per_grid)
	true_bit_masks.resize(_category_size)
	for i in range(_category_size):
		true_bit_masks[i] = []
		true_bit_masks[i].resize(_category_size)
	_build_bit_masks(_category_size)

func get_true_bit_mask(row: int, col: int) -> BitSet:
	if row >= _category_size || col >= _category_size:
		push_error("Row or column are too large")
	return true_bit_masks[row][col]

func get_false_bit_mask(row: int, col: int) -> BitSet:
	var true_bit_mask: BitSet = true_bit_masks[row][col]
	false_bit_mask.set_in_range(0, max_possible_solutions_per_grid, true)
	false_bit_mask.bitwise_and_not(true_bit_mask)
	return false_bit_mask

func _build_bit_masks(category_size: int):
	for row in range(category_size):
		for col in range(category_size):
			true_bit_masks[row][col] = BitSet.new(max_possible_solutions_per_grid)
	var solution: Permutation = Permutation.new(category_size)
	for solution_id in range(math.factorial(category_size)):
		solution.set_rank(solution_id)
		for row in range(category_size):
			var col: int = solution.permutation_int_arr[row]
			true_bit_masks[row][col].set_at_index(solution_id, true)
