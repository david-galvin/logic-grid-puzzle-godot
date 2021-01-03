extends "res://addons/gut/test.gd"

class TestLogicGridPuzzle:
	extends "res://addons/gut/test.gd"
	var LogicGridPuzzle = load("res://LogicGridPuzzle.gd")
	var _category_count: int = 0
	var _category_size: int = 0
	var _lp = null
	var _time_before = null
	var _times_arr = []

	func before_each():
		_category_count = 5
		_category_size = 5
		_time_before = OS.get_ticks_msec()
		_lp = LogicGridPuzzle.new(_category_count, _category_size)

	func test_eliminate_possible_solutions():

		#for i in range(_category_size - 2):
		#	_lp.eliminate_possible_solutions(0, 0, _category_count - 1, i, true)
		#	_lp.eliminate_possible_solutions(0, 1, _category_count - 1, i, true)
		#	_lp.eliminate_possible_solutions(0, 0, _category_count - 2, _category_size - i - 1, true)
		#	_lp.eliminate_possible_solutions(0, 1, _category_count - 2, _category_size - i - 1, true)
		_lp.eliminate_possible_solutions(3,0,0,1,true)
		
		for i in range(7, 3, -1):
			print(str(i))
		
		for i in range(7,0,-1):
			print(str(i))

		print(_lp)
