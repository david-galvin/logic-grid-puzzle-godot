extends "res://addons/gut/test.gd"


class TestPermutation:


	extends "res://addons/gut/test.gd"


	var Permutation = load("res://permutation.gd")
	var _perm = null
	

	func before_each():
		_perm = Permutation.new(5)
		

	func test_set_rank():
		_perm.set_rank(0)
		assert_eq(_perm.perm_int_arr, [1, 2, 3, 4, 0])
		_perm.set_rank(1)
		assert_eq(_perm.perm_int_arr, [4, 2, 3, 0, 1])


	func test_invert_perm():
		_perm.set_rank(1)
		_perm.invert_perm()
		assert_eq(_perm.perm_int_arr, [3, 4, 1, 2, 0])
	

	func test_update_rank():
		_perm.set_rank(5)
		_perm.perm_int_arr = [4, 2, 3, 0, 1]
		_perm.update_rank()
		assert_eq(_perm.rank, 1)
