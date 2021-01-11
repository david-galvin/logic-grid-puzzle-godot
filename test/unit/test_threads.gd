extends "res://addons/gut/test.gd"


class TestThreads:


	extends "res://addons/gut/test.gd"
	
	
	func test_thread():
		var num_msec := pow(2, 23)
		var _timer = TimerDict.new()
		#var num_threads: int
		var threads: Array = []
		var msec_delay: int
		var _msec_returned: int
		var run_name: String
		for num_threads in range(1, 17):
			run_name = "num_threads = " + str(num_threads)
			_timer.start_timer(run_name)
			threads.clear()
			for _i in range(num_threads):
				msec_delay = num_msec / num_threads
				threads.append(Thread.new())
				threads[-1].start(self, "_thread_msec_delay", msec_delay)
			_msec_returned = 0
			var x
			for thread in threads:
				x = thread.wait_to_finish()
				print(str(x))
			_timer.end_timer(run_name)
		print(str(_timer))



	# Run here and exit.
	# The argument is the userdata passed from start().
	# If no argument was passed, this one still needs to
	# be here and it will be null.
	func _thread_msec_delay(msecs: int) -> int:
		#print("In thread, delay = " + str(msecs))
		#OS.delay_msec (msecs) 
		var x: int = 0
		for i in range(msecs):
			x += 1
		return x

	# Thread must be disposed (or "joined"), for portability.
#	func _exit_tree():
#		thread.wait_to_finish()
#		print("Done!")
