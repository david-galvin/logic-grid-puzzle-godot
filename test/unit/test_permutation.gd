extends "res://addons/gut/test.gd"


class TestPermutation:


	extends "res://addons/gut/test.gd"


	var Permutation = load("res://permutation.gd")
	var _perm = null
	

	func before_each():
		_perm = Permutation.new(5)
		

	func test_set_rank():
		_perm.set_rank(0)
		assert_eq(_perm.perm_ints, [1, 2, 3, 4, 0])
		_perm.set_rank(1)
		assert_eq(_perm.perm_ints, [4, 2, 3, 0, 1])


	func test_invert():
		_perm.set_rank(1)
		_perm.invert()
		assert_eq(_perm.perm_ints, [3, 4, 1, 2, 0])


class TestPermutationMath:


	extends "res://addons/gut/test.gd"


	var Permutation = load("res://permutation.gd")
	var _perm1 = null
	var _perm2 = null
	var _perm3 = null


	func test_perm_composition():
		# left, right, and lower refer to the positions of the 3 grids of a logic
		# puzzle formed by 3 pairs of 3 categories. There will be two in a row,
		# and 2 in a col, with the 'lower' one always below the right of the
		# two grids in a row.
		var perm_size: int = 5
		var left_rank = 8
		var right_rank = 11
		var lower_rank = 94
		var left_grid_perm = Permutation.new(perm_size)
		var right_grid_perm = Permutation.new(perm_size)
		var lower_grid_perm = Permutation.new(perm_size)
		var utility_perm = Permutation.new(perm_size)
		left_grid_perm.set_rank(left_rank)
		right_grid_perm.set_rank(right_rank)
		lower_grid_perm.set_rank(lower_rank)
		
		# Confirm left = right(lower)
		utility_perm.set_rank(lower_rank)
		utility_perm.permute_by_rank(right_rank)
		assert_eq(utility_perm.rank, left_rank)
		
		# confirm right = left(inverse of lower)
		utility_perm.set_rank(lower_rank)
		utility_perm.invert()
		utility_perm.permute_by_rank(left_rank)
		assert_eq(utility_perm.rank, right_rank)
		
		# confirm lower = inverse_of_right(left)
		utility_perm.set_rank(right_rank)
		utility_perm.invert()
		var inverse_of_right_rank: int = utility_perm.rank
		utility_perm.set_rank(left_rank)
		utility_perm.permute_by_rank(inverse_of_right_rank)
		assert_eq(utility_perm.rank, lower_rank)


class TestPermutationRanks:


	extends "res://addons/gut/test.gd"


	var Permutation = load("res://permutation.gd")
	var _perm: Permutation = null
	
	func test_rank_to_inverse_rank_file():
		var file = File.new()
		var _start_time = OS.get_ticks_msec()
		file.open("permutation_inverses.dat", File.READ)
		var size_to_rank_to_inverse_rank = file.get_var(true)
		file.close()
		gut.p("permutation_inverses.dat load time: " + str(OS.get_ticks_msec() - _start_time))
		for size in range(3, 7):
			_perm = Permutation.new(size)

			for rank in range(3,6):
				_perm.set_rank(rank)
				_perm.invert()
				assert_eq(_perm.rank, size_to_rank_to_inverse_rank[size][rank])
	
	
	func test_rank_matrix_file():
		var _start_time = OS.get_ticks_msec()
		var file = File.new()
		file.open("size_to_perm_matrix.dat", File.READ)
		var size_to_perm_matrix = file.get_var(true)
		file.close()
		gut.p("size_to_perm_matrix.dat load time: " + str(OS.get_ticks_msec() - _start_time))
		file.open("permutation_inverses.dat", File.READ)
		var size_to_rank_to_inverse_rank = file.get_var(true)
		file.close()
		var file_rank: int
		for size in range(3, 7):
			_perm = Permutation.new(size)
			for left_grid_rank in range(3,5):
				for right_grid_rank in range(left_grid_rank, 6):
					_perm.set_rank(left_grid_rank)
					_perm.permute_by_rank(size_to_rank_to_inverse_rank[size][right_grid_rank])
					file_rank = size_to_perm_matrix[size][left_grid_rank][size_to_rank_to_inverse_rank[size][right_grid_rank]]
					assert_eq(file_rank, _perm.rank)
