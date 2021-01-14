class_name Move
extends Reference


var cat1: int
var cat2: int
var elt1: int
var elt2: int
var target_state: bool
var _string: String


func _init(my_cat1: int, my_elt1: int, my_cat2: int, my_elt2: int, my_target_state: bool):
	cat1 = my_cat1
	elt1 = my_elt1
	cat2 = my_cat2
	elt2 = my_elt2
	target_state = my_target_state
	var truth_str = "true" if target_state else "false"
	_string = "_lp.set_grid_cell(" + str(cat1) + ", " + str(elt1) + ", " \
			+ str(cat2) + ", " + str(elt2) + ", " + truth_str + ")"


func _to_string() -> String:
	return _string
