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
		_category_size = 7
		_time_before = OS.get_ticks_msec()
		_lp = LogicGridPuzzle.new(_category_count, _category_size)
		print("Init new puz: " + str(OS.get_ticks_msec() - _time_before))

	func test_eliminate_possible_solutions():

# Do stuff
# Best: 100 milliseconds per move
# Okay: 300 ms per move

		for i in range(_category_size - 2):
			_time_before = OS.get_ticks_msec()
			_lp.eliminate_possible_solutions(0, 0, _category_count - 1, i, true)
			_times_arr.append(OS.get_ticks_msec() - _time_before) 
			
			_time_before = OS.get_ticks_msec()
			_lp.eliminate_possible_solutions(0, 1, _category_count - 1, i, true)
			_times_arr.append(OS.get_ticks_msec() - _time_before)
			 
			_time_before = OS.get_ticks_msec()
			_lp.eliminate_possible_solutions(0, 0, _category_count - 2, _category_size - i - 1, true)
			_times_arr.append(OS.get_ticks_msec() - _time_before) 
			
			_time_before = OS.get_ticks_msec()
			_lp.eliminate_possible_solutions(0, 1, _category_count - 2, _category_size - i - 1, true)
			_times_arr.append(OS.get_ticks_msec() - _time_before) 
		print("Max time per move " + str(_times_arr.max()))
		print(str(_times_arr))

		print(_lp)
