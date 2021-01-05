class_name Move
extends Reference


var _cat1: int
var _cat2: int
var _elt1: int
var _elt2: int
var _truth_state: bool
var _string: String


func _init(cat1: int, elt1: int, cat2: int, elt2: int, truth_state: bool):
	_cat1 = cat1
	_elt1 = elt1
	_cat2 = cat2
	_elt2 = elt2
	_truth_state = truth_state
	var truth_str = "true" if _truth_state else "false"
	_string = "_lp.set_grid_cell(" + str(_cat1) + ", " + str(_elt1) + ", " \
			+ str(_cat2) + ", " + str(_elt2) + ", " + truth_str + ")\n"


func _to_string() -> String:
	return _string
