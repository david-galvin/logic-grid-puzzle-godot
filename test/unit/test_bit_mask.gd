extends "res://addons/gut/test.gd"


class TestBitMask:


	extends "res://addons/gut/test.gd"


	var BitMask = load("res://bit_mask.gd")
	var _bmask = null


	func before_each():
		_bmask = BitMask.new(5)


	func test_init():
		assert_eq(_bmask.max_possible_solutions_per_grid, 120)
		assert_eq(str(_bmask.false_bit_mask), str(BitSet.new(120)))
