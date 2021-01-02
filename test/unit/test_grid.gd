extends "res://addons/gut/test.gd"

class TestGrid:
	extends "res://addons/gut/test.gd"
	var Grid = load("res://Grid.gd")
	var BitMask = load("res://BitMask.gd")
	var _grid: Grid = null
	var _bit_mask: BitMask = null
	var _category_size: int = 0
	
	func before_each():
		_category_size = 3
		_bit_mask = BitMask.new(_category_size)
		_grid = Grid.new(_category_size, _bit_mask)

	func test_eliminate_false():
		_grid.eliminate(0, 1, false)
		assert_eq("\n" + str(_grid), "\nXOX\n?X?\n?X?\n")

	func test_eliminate_true():
		_grid.eliminate(0, 1, true)
		assert_eq("\n" + str(_grid), "\n?X?\n???\n???\n")
		
		_grid.eliminate(0, 2, true)
		assert_eq("\n" + str(_grid), "\nOXX\nX??\nX??\n")
		
		var true_bit_mask: BitSet = _grid.bit_mask.get_true_bit_mask(0, 0)
		var false_bit_mask: BitSet = _grid.bit_mask.get_false_bit_mask(0, 0)
		var some_true: bool = _grid.all_possible_solutions.bitwise_intersects(true_bit_mask)
		var some_false: bool = _grid.all_possible_solutions.bitwise_intersects(false_bit_mask)
		assert_eq(some_true, true)
		assert_eq(some_false, false)
