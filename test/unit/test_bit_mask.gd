extends "res://addons/gut/test.gd"

class TestBitMask:
	extends "res://addons/gut/test.gd"
	var BitMask = load("res://BitMask.gd")
	var _bmask = null

	func before_each():
		_bmask = BitMask.new(5)

	func test_init():
		assert_eq(_bmask.max_possible_solutions_per_grid, 120)
		assert_eq(_bmask.false_bit_mask.to_string(), BitSet.new(120).to_string())
