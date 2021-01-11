extends "res://addons/gut/test.gd"


class TestGDScript:


	extends "res://addons/gut/test.gd"
	
	var _timer: TimerDict
	
	func before_each():
		_timer = TimerDict.new()
		randomize()
	
	func test_array():
		var ints = [0, 1, 2, 3, 4]
		var num_times: int = 1000000
		var pints: PoolIntArray = PoolIntArray(ints)
		var dints: Dictionary = {}
		dints[0] = true
		dints[1] = true
		dints[2] = true
		dints[3] = true
		dints[4] = true
		var _a
		var _b
		var _c 
		var _d
		var _e
		ints.resize(5)
		pints.resize(5)
		_timer.start_timer("overall Array of ints")
		for _i in range(num_times):
			_a = ints[0]
			_b = ints[1]
			_c = ints[2]
			_d = ints[3]
			_e = ints[4]
		_timer.end_timer("overall Array of ints")
		_timer.start_timer("overall Array of pints")
		for _i in range(num_times):
			_a = pints[0]
			_b = pints[1]
			_c = pints[2]
			_d = pints[3]
			_e = pints[4]
		_timer.end_timer("overall Array of pints")
		_timer.start_timer("overall Dict")
		for _i in range(num_times):
			_a = dints.has(0)
			_b = dints.has(1)
			_c = dints.has(2)
			_d = dints.has(3)
			_e = dints.has(4)
		_timer.end_timer("overall Dict")
		print(_timer)
		
