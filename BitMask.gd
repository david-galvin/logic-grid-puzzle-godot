extends Node

class_name BitMask

var max_possible_solutions_per_grid: int
var true_bit_masks = []
var false_bit_mask: BitSet
var math = load("res://Math.gd").new()

func _init(category_size: int):
	max_possible_solutions_per_grid = math.factorial(category_size)
	false_bit_mask = BitSet.new(max_possible_solutions_per_grid)
	true_bit_masks.resize(category_size)
	for i in range(category_size):
		true_bit_masks[i] = []
		true_bit_masks[i].resize(category_size)
	_build_bit_masks(category_size)

func get_true_bit_mask(row: int, col: int) -> BitSet:
	return true_bit_masks[row][col]

func get_false_bit_mask(row: int, col: int) -> BitSet:
	var true_bit_mask: BitSet = true_bit_masks[row][col]
	false_bit_mask.set_in_range(0, max_possible_solutions_per_grid, true)
	false_bit_mask.bitwise_xor(true_bit_mask)
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
