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
		var a: int
		var b: int
		var c: int 
		var d: int
		var e: int
		ints.resize(5)
		pints.resize(5)
		_timer.start_timer("overall Array of ints")
		for i in range(num_times):
			a = ints[0]
			b = ints[1]
			c = ints[2]
			d = ints[3]
			e = ints[4]
		_timer.end_timer("overall Array of ints")
		_timer.start_timer("overall Array of pints")
		for i in range(num_times):
			a = pints[0]
			b = pints[1]
			c = pints[2]
			d = pints[3]
			e = pints[4]
		_timer.end_timer("overall Array of pints")
		_timer.start_timer("overall Dict")
		for i in range(num_times):
			dints.has(0)
			dints.has(1)
			dints.has(2)
			dints.has(3)
			dints.has(4)
		_timer.end_timer("overall Dict")
		print(_timer)
		
