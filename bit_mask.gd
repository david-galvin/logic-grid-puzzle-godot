class_name BitMask
extends Reference


var max_possible_solutions_per_grid: int
var true_bit_masks: Array = []
var false_bit_mask: BitSet

var _cat_size: int


func _init(my_cat_size: int) -> void:
	_cat_size = my_cat_size
	max_possible_solutions_per_grid = Math.factorial(_cat_size)
	false_bit_mask = BitSet.new(max_possible_solutions_per_grid)
	true_bit_masks.resize(_cat_size)
	for i in range(_cat_size):
		true_bit_masks[i] = []
		true_bit_masks[i].resize(_cat_size)
	_build_bit_masks(_cat_size)


func get_true_bit_mask(row: int, col: int) -> BitSet:
	if row >= _cat_size or col >= _cat_size:
		push_error("Row or column are too large")
	return true_bit_masks[row][col]


func get_false_bit_mask(row: int, col: int) -> BitSet:
	var true_bit_mask: BitSet = true_bit_masks[row][col]
	false_bit_mask.set_in_range(0, max_possible_solutions_per_grid, true)
	false_bit_mask.bitwise_and_not(true_bit_mask)
	return false_bit_mask


func _build_bit_masks(cat_size: int) -> void:
	for row in range(cat_size):
		for col in range(cat_size):
			true_bit_masks[row][col] = BitSet.new(max_possible_solutions_per_grid)
	var solution: Permutation = Permutation.new(cat_size)
	for solution_id in range(Math.factorial(cat_size)):
		solution.set_rank(solution_id)
		for row in range(cat_size):
			var col: int = solution.perm_ints[row]
			true_bit_masks[row][col].set_at_index(solution_id, true)
