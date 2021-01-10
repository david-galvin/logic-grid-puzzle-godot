class_name TimerDict
extends Reference

var _run_times: Dictionary = {}
var _counts: Dictionary = {}
var _run_timestamp: Dictionary = {}

func start_timer(name: String) -> void:
	if not _run_times.has(name):
		_run_times[name] = 0
		_run_timestamp[name] = 0
		_counts[name] = 0
	_run_timestamp[name] = OS.get_ticks_msec()
	_counts[name] += 1

func end_timer(name: String) -> void:
	_run_times[name] += OS.get_ticks_msec() - _run_timestamp[name]

func _to_string():
	var _string: String = ""
	for name in _run_times:
		_string += name + ": total = " + str(_run_times[name]) + " = " + str(_counts[name]) + " * "+ str( float(_run_times[name]) / float(_counts[name])) + "\n"
	return _string
