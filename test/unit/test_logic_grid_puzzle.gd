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
		_category_count = 3
		_category_size = 5
		_lp = LogicGridPuzzle.new(_category_count, _category_size)

	func test_eliminate_possible_solutions():
		_lp.eliminate_possible_solutions(2,0,0,0,true)
		_lp.eliminate_possible_solutions(2,0,0,1,true)
		_lp.eliminate_possible_solutions(2,0,0,2,true)
		_lp.eliminate_possible_solutions(2,0,1,0,true)
		#_lp.eliminate_possible_solutions(2,0,1,1,true)
		#_lp.eliminate_possible_solutions(2,0,1,2,true)
		_lp.eliminate_possible_solutions(2,1,0,0,true)
		_lp.eliminate_possible_solutions(2,1,0,1,true)
		_lp.eliminate_possible_solutions(2,1,0,2,true)
		_lp.eliminate_possible_solutions(2,1,1,0,true)
		#_lp.eliminate_possible_solutions(2,1,1,1,true)
		#_lp.eliminate_possible_solutions(2,1,1,2,true)
#		_lp.eliminate_possible_solutions(1,3,0,0,true)


		print(_lp)
