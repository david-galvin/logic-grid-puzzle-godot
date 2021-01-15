extends "res://addons/gut/test.gd"


class TestMath:


	extends "res://addons/gut/test.gd"


#	var Permutation = load("res://permutation.gd")
#	var _perm = null
		

	func test_get_subsets():
		var arr: Array = ['A', 'B', 'C', 'D', 'E']
		var subset_size: int = 3
		var result: Array = [['A', 'B', 'C'], ['A', 'B', 'D'], ['A', 'B', 'E'], \
				['A', 'C', 'D'], ['A', 'C', 'E'], ['A', 'D', 'E'], ['B', 'C', 'D'], \
				['B', 'C', 'E'], ['B', 'D', 'E'], ['C', 'D', 'E']]
		assert_eq(Math.get_subsets(arr, subset_size), result)
