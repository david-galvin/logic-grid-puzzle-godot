extends "res://addons/gut/test.gd"


class TestBitSet:


	extends "res://addons/gut/test.gd"


	var BitSet = load("res://bit_set.gd")
	var _bset = null
	var _big_bset = null
	var _big_padding_size: int = 70
	var _big_padding_str: String = "%0*d" % [_big_padding_size, 0]
	

	func before_each():
		_bset = BitSet.new(10)
		_big_bset = BitSet.new(10 + _big_padding_size)
	

	func test_initial_state():
		assert_eq(str(_bset), "0000000000")
		
		assert_eq(str(_big_bset), "0000000000" + _big_padding_str)
		

	func test_set_at_index():
		_bset.set_at_index(2, true)
		assert_eq(str(_bset), "0000000100")
		_bset.set_at_index(2, false)
		assert_eq(str(_bset), "0000000000")
		
		_big_bset.set_at_index(2 + _big_padding_size, true)
		assert_eq(str(_big_bset), "0000000100" + _big_padding_str)
		_big_bset.set_at_index(2 + _big_padding_size, false)
		assert_eq(str(_big_bset), "0000000000" + _big_padding_str)
	

	func test_set_in_range():
		_bset.set_in_range(1, 5, true)
		assert_eq(str(_bset), "0000011110")
		_bset.set_in_range(3, 5, false)
		assert_eq(str(_bset), "0000000110")
		
		_big_bset.set_in_range(1 + _big_padding_size, 5 + _big_padding_size, true)
		assert_eq(str(_big_bset), "0000011110" + _big_padding_str)
		_big_bset.set_in_range(3 + _big_padding_size, 5 + _big_padding_size, false)
		assert_eq(str(_big_bset), "0000000110" + _big_padding_str)
	

	func test_next_set_bit():
		_bset.set_in_range(2, 4, true)
		_bset.set_at_index(5, true)
		assert_eq(_bset.next_set_bit(0), 2)
		assert_eq(_bset.next_set_bit(1), 2)
		assert_eq(_bset.next_set_bit(2), 2)
		assert_eq(_bset.next_set_bit(3), 3)
		assert_eq(_bset.next_set_bit(4), 5)
		assert_eq(_bset.next_set_bit(5), 5)
		assert_eq(_bset.next_set_bit(6), -1)

		_big_bset.set_in_range(2 + _big_padding_size, 4 + _big_padding_size, true)
		_big_bset.set_at_index(5 + _big_padding_size, true)
		assert_eq(_big_bset.next_set_bit(0), 2 + _big_padding_size)
		assert_eq(_big_bset.next_set_bit(0 + _big_padding_size), 2 + _big_padding_size)
		assert_eq(_big_bset.next_set_bit(1 + _big_padding_size), 2 + _big_padding_size)
		assert_eq(_big_bset.next_set_bit(2 + _big_padding_size), 2 + _big_padding_size)
		assert_eq(_big_bset.next_set_bit(3 + _big_padding_size), 3 + _big_padding_size)
		assert_eq(_big_bset.next_set_bit(4 + _big_padding_size), 5 + _big_padding_size)
		assert_eq(_big_bset.next_set_bit(5 + _big_padding_size), 5 + _big_padding_size)
		assert_eq(_big_bset.next_set_bit(6 + _big_padding_size), -1)
	

	func test_get_at_index():
		_bset.set_at_index(1, true)
		_bset.set_at_index(3, true)
		assert_eq(_bset.get_at_index(0), false)
		assert_eq(_bset.get_at_index(1), true)
		assert_eq(_bset.get_at_index(2), false)
		assert_eq(_bset.get_at_index(3), true)
		assert_eq(_bset.get_at_index(4), false)

		_big_bset.set_at_index(1 + _big_padding_size, true)
		_big_bset.set_at_index(3 + _big_padding_size, true)
		assert_eq(_big_bset.get_at_index(0 + _big_padding_size), false)
		assert_eq(_big_bset.get_at_index(1 + _big_padding_size), true)
		assert_eq(_big_bset.get_at_index(2 + _big_padding_size), false)
		assert_eq(_big_bset.get_at_index(3 + _big_padding_size), true)
		assert_eq(_big_bset.get_at_index(4 + _big_padding_size), false)
	

	func test_clear():
		_bset.set_in_range(2, 7, true)
		_bset.clear()
		assert_eq(str(_bset), "0000000000")
		
		_big_bset.set_in_range(2 + _big_padding_size, 7 + _big_padding_size, true)
		_big_bset.clear()
		assert_eq(str(_big_bset), "0000000000" + _big_padding_str)
	

	func test_cardinality():
		assert_eq(_bset.cardinality(), 0)
		_bset.set_at_index(2, true)
		assert_eq(_bset.cardinality(), 1)
		_bset.set_at_index(4, true)
		assert_eq(_bset.cardinality(), 2)
		_bset.set_in_range(1, 6, true)
		assert_eq(_bset.cardinality(), 5)
		_bset.set_at_index(1, false)
		assert_eq(_bset.cardinality(), 4)
		_bset.set_in_range(4, 8, false)
		assert_eq(_bset.cardinality(), 2)

		assert_eq(_big_bset.cardinality(), 0)
		_big_bset.set_at_index(2 + _big_padding_size, true)
		assert_eq(_big_bset.cardinality(), 1)
		_big_bset.set_at_index(4 + _big_padding_size, true)
		assert_eq(_big_bset.cardinality(), 2)
		_big_bset.set_in_range(1 + _big_padding_size, 6 + _big_padding_size, true)
		assert_eq(_big_bset.cardinality(), 5)
		_big_bset.set_at_index(1 + _big_padding_size, false)
		assert_eq(_big_bset.cardinality(), 4)
		_big_bset.set_in_range(4 + _big_padding_size, 8 + _big_padding_size, false)
		assert_eq(_big_bset.cardinality(), 2)
		
		
class TestBitSetPairwise:
	extends "res://addons/gut/test.gd"
	var BitSet = load("res://bit_set.gd")
	var _bset = null
	var _bset2 = null	
	var _big_bset = null
	var _big_bset2 = null
	var _big_padding_size: int = 70
	var _big_padding_str: String = "%0*d" % [_big_padding_size, 0]
	

	func before_each():
		_bset = BitSet.new(10)
		_bset2 = BitSet.new(10)
		_big_bset = BitSet.new(10 + _big_padding_size)
		_big_bset2 = BitSet.new(10 + _big_padding_size)
		

	func test_bitwise_and():
		_bset.set_in_range(1, 6, true)
		_bset2.set_in_range(3, 7, true)
		_bset.bitwise_and(_bset2)
		assert_eq(str(_bset), "0000111000")

		_big_bset.set_in_range(1 + _big_padding_size, 6 + _big_padding_size, true)
		_big_bset2.set_in_range(3 + _big_padding_size, 8 + _big_padding_size, true)
		_big_bset.bitwise_and(_big_bset2)
		assert_eq(str(_big_bset), "0000111000" + _big_padding_str)
	

	func test_bitwise_xor():
		_bset.set_in_range(1, 6, true)
		_bset2.set_in_range(3, 8, true)
		_bset.bitwise_xor(_bset2)
		assert_eq(str(_bset), "0011000110")

		_big_bset.set_in_range(1 + _big_padding_size, 6 + _big_padding_size, true)
		_big_bset2.set_in_range(3 + _big_padding_size, 8 + _big_padding_size, true)
		_big_bset.bitwise_xor(_big_bset2)
		assert_eq(str(_big_bset), "0011000110" + _big_padding_str)
	

	func test_bitwise_and_not():
		_bset.set_in_range(1, 6, true)
		_bset2.set_in_range(3, 8, true)
		_bset.bitwise_and_not(_bset2)
		assert_eq(str(_bset), "0000000110")

		_big_bset.set_in_range(1 + _big_padding_size, 6 + _big_padding_size, true)
		_big_bset2.set_in_range(3 + _big_padding_size, 8 + _big_padding_size, true)
		_big_bset.bitwise_and_not(_big_bset2)
		assert_eq(str(_big_bset), "0000000110" + _big_padding_str)
	

	func test_bitwise_intersects():
		_bset.set_in_range(1, 4, true)
		_bset2.set_in_range(4, 8, true)
		assert_eq(_bset.bitwise_intersects(_bset2), false)
		_bset2.set_at_index(3, true)
		assert_eq(_bset.bitwise_intersects(_bset2), true)

		_big_bset.set_in_range(1 + _big_padding_size, 4 + _big_padding_size, true)
		_big_bset2.set_in_range(4 + _big_padding_size, 8 + _big_padding_size, true)
		assert_eq(_big_bset.bitwise_intersects(_big_bset2), false)
		_big_bset2.set_at_index(3 + _big_padding_size, true)
		assert_eq(_big_bset.bitwise_intersects(_big_bset2), true)
